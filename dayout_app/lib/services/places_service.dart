import 'dart:convert';
import 'dart:io';
import 'dart:math';
import '../models/app_place.dart';
import 'weather_service.dart';
import 'wiki_image_service.dart';

class PlacesService {
  // Accra city centre fallback
  static const _defaultLat = 5.5600;
  static const _defaultLon = -0.2050;

  /// Returns nearby places sorted by weather.
  /// Uses [lat]/[lng] when supplied, else Accra centre.
  /// Tries Overpass (OpenStreetMap) first, falls back to static curated data.
  static Future<List<AppPlace>> fetchNearby({
    WeatherData? weather,
    double? lat,
    double? lng,
  }) async {
    final searchLat = lat ?? _defaultLat;
    final searchLng = lng ?? _defaultLon;

    List<AppPlace> places = await _fetchFromOverpass(searchLat, searchLng);

    if (places.isEmpty) {
      places = _buildStaticWithDistance(searchLat, searchLng);
    }

    _sortByWeather(places, weather);
    places = await _enrichWithImages(places);
    return places;
  }

  // ── Overpass API (OpenStreetMap) ─────────────────────────────────────────

  static Future<List<AppPlace>> _fetchFromOverpass(
      double lat, double lng) async {
    final query = '''
[out:json][timeout:20];
(
  node(around:20000,$lat,$lng)["amenity"~"^(restaurant|cafe|bar|nightclub|cinema|museum|theatre)\$"];
  node(around:20000,$lat,$lng)["leisure"~"^(park|garden|beach|sports_centre|fitness_centre)\$"];
  node(around:20000,$lat,$lng)["tourism"~"^(attraction|museum|gallery|theme_park)\$"];
  node(around:20000,$lat,$lng)["natural"="beach"];
  node(around:20000,$lat,$lng)["shop"="mall"];
);
out body 30;
''';
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15);
      final req = await client
          .postUrl(Uri.parse('https://overpass-api.de/api/interpreter'));
      req.headers.set(
          HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
      req.write('data=${Uri.encodeComponent(query)}');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      if (res.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final elements = data['elements'] as List? ?? [];
        final places = elements
            .map((e) =>
                _fromOverpass(e as Map<String, dynamic>, lat, lng))
            .whereType<AppPlace>()
            .toList();

        // De-duplicate by name (OSM can return duplicates)
        final seen = <String>{};
        return places.where((p) => seen.add(p.name.toLowerCase())).toList();
      }
    } catch (_) {}
    return [];
  }

  static AppPlace? _fromOverpass(
      Map<String, dynamic> e, double originLat, double originLng) {
    try {
      final tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? {};
      final name = (tags['name'] as String?)?.trim() ??
          (tags['name:en'] as String?)?.trim() ??
          '';
      if (name.isEmpty) return null;

      final lat = (e['lat'] as num?)?.toDouble();
      final lng = (e['lon'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;

      final category = _osmCategory(tags);
      final isOutdoor = _outdoorCategories.contains(category.toLowerCase());
      final dist = _haversineMeters(originLat, originLng, lat, lng);

      return AppPlace(
        id: 'osm_${e['id']}',
        name: name,
        category: category,
        lat: lat,
        lng: lng,
        distanceMeters: dist,
        isOutdoor: isOutdoor,
      );
    } catch (_) {}
    return null;
  }

  static String _osmCategory(Map<String, dynamic> tags) {
    final amenity = tags['amenity'] as String? ?? '';
    final leisure = tags['leisure'] as String? ?? '';
    final tourism = tags['tourism'] as String? ?? '';
    final shop = tags['shop'] as String? ?? '';
    final natural = tags['natural'] as String? ?? '';

    if (natural == 'beach' || leisure == 'beach' || amenity == 'beach_resort') { return 'Beach'; }
    if (amenity == 'restaurant') { return 'Restaurant'; }
    if (amenity == 'cafe') { return 'Cafe'; }
    if (amenity == 'bar' || amenity == 'pub' || amenity == 'nightclub') { return 'Nightlife'; }
    if (amenity == 'cinema' || amenity == 'theatre') { return 'Entertainment'; }
    if (amenity == 'museum' || tourism == 'museum' || tourism == 'gallery') { return 'Museum'; }
    if (leisure == 'park' || leisure == 'garden') { return 'Park'; }
    if (leisure == 'sports_centre' || leisure == 'fitness_centre') { return 'Sports'; }
    if (tourism == 'attraction' || tourism == 'theme_park') { return 'Attraction'; }
    if (shop == 'mall') { return 'Shopping'; }
    return 'Place';
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static const _outdoorCategories = {
    'beach', 'park', 'garden', 'attraction', 'nature', 'sports',
  };

  static void _sortByWeather(List<AppPlace> places, WeatherData? weather) {
    if (weather == null) return;
    places.sort((a, b) {
      if (weather.isOutdoorFriendly) {
        if (a.isOutdoor && !b.isOutdoor) return -1;
        if (!a.isOutdoor && b.isOutdoor) return 1;
      } else {
        if (!a.isOutdoor && b.isOutdoor) return -1;
        if (a.isOutdoor && !b.isOutdoor) return 1;
      }
      return 0;
    });
  }

  /// Fetches Wikipedia thumbnails for all places in parallel.
  /// Known static places use their article title; others try by name.
  /// Places that already have a thumbnail (or fail) are returned unchanged.
  static Future<List<AppPlace>> _enrichWithImages(List<AppPlace> places) async {
    final futures = places.map((p) async {
      if (p.thumbnailUrl != null) return p;
      String? url;
      final knownTitle = WikiImageService.articleTitle(p.id);
      if (knownTitle != null) {
        url = await WikiImageService.fetchThumbnail(knownTitle);
      }
      url ??= await WikiImageService.fetchByName(p.name);
      if (url == null) return p;
      return AppPlace(
        id: p.id,
        name: p.name,
        category: p.category,
        lat: p.lat,
        lng: p.lng,
        rating: p.rating,
        distanceMeters: p.distanceMeters,
        isOutdoor: p.isOutdoor,
        thumbnailUrl: url,
      );
    });
    return Future.wait(futures);
  }

  static int _haversineMeters(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return (r * 2 * atan2(sqrt(a), sqrt(1 - a))).round();
  }

  static double _rad(double deg) => deg * pi / 180;

  // ── Static fallback — real Accra places ──────────────────────────────────

  static List<AppPlace> _buildStaticWithDistance(
      double originLat, double originLng) {
    return _staticPlaces.map((p) {
      final dist = _haversineMeters(originLat, originLng, p.lat, p.lng);
      return AppPlace(
        id: p.id,
        name: p.name,
        category: p.category,
        lat: p.lat,
        lng: p.lng,
        distanceMeters: dist,
        isOutdoor: p.isOutdoor,
      );
    }).toList();
  }

  static const _staticPlaces = <AppPlace>[
    AppPlace(id: 'labadi_beach',      name: 'Labadi Beach',               category: 'Beach',       lat: 5.5502, lng: -0.1467, distanceMeters: 3200,  isOutdoor: true),
    AppPlace(id: 'aburi_gardens',     name: 'Aburi Botanical Gardens',    category: 'Park',        lat: 5.8521, lng: -0.1751, distanceMeters: 38000, isOutdoor: true),
    AppPlace(id: 'legon_gardens',     name: 'Legon Botanical Gardens',    category: 'Park',        lat: 5.6502, lng: -0.1869, distanceMeters: 12000, isOutdoor: true),
    AppPlace(id: 'laboma_beach',      name: 'Laboma Beach',               category: 'Beach',       lat: 5.5310, lng: -0.0852, distanceMeters: 8300,  isOutdoor: true),
    AppPlace(id: 'independence_sq',   name: 'Independence Square',        category: 'Attraction',  lat: 5.5481, lng: -0.2014, distanceMeters: 4200,  isOutdoor: true),
    AppPlace(id: 'kwame_mausoleum',   name: 'Kwame Nkrumah Mausoleum',   category: 'Attraction',  lat: 5.5490, lng: -0.2068, distanceMeters: 4600,  isOutdoor: true),
    AppPlace(id: 'gamezone_osu',      name: 'GameZone Osu',               category: 'Arcade',      lat: 5.5560, lng: -0.1813, distanceMeters: 1800,  isOutdoor: false),
    AppPlace(id: 'national_museum',   name: 'National Museum of Ghana',   category: 'Museum',      lat: 5.5614, lng: -0.2044, distanceMeters: 5400,  isOutdoor: false),
    AppPlace(id: 'santoku',           name: 'Santoku Restaurant',         category: 'Restaurant',  lat: 5.5573, lng: -0.1772, distanceMeters: 2100,  isOutdoor: false),
    AppPlace(id: 'buka_restaurant',   name: 'Buka Restaurant',            category: 'Restaurant',  lat: 5.5590, lng: -0.1870, distanceMeters: 2400,  isOutdoor: false),
    AppPlace(id: 'republic_bar',      name: 'Republic Bar & Grill',       category: 'Nightlife',   lat: 5.5578, lng: -0.1840, distanceMeters: 2200,  isOutdoor: false),
    AppPlace(id: 'accra_mall',        name: 'Accra Mall',                 category: 'Shopping',    lat: 5.6037, lng: -0.1870, distanceMeters: 6700,  isOutdoor: false),
    AppPlace(id: 'marina_mall',       name: 'Marina Mall',                category: 'Shopping',    lat: 5.5588, lng: -0.1936, distanceMeters: 2800,  isOutdoor: false),
    AppPlace(id: 'national_theatre',  name: 'National Theatre Ghana',     category: 'Entertainment', lat: 5.5505, lng: -0.2040, distanceMeters: 4500, isOutdoor: false),
    AppPlace(id: 'la_pleasure_beach', name: 'La Pleasure Beach',          category: 'Beach',       lat: 5.5495, lng: -0.1475, distanceMeters: 3400,  isOutdoor: true),
  ];
}
