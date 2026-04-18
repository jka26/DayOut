import 'dart:convert';
import 'dart:io';
import '../config/env.dart';
import '../models/app_place.dart';
import 'weather_service.dart';

class PlacesService {
  // Accra city centre
  static const _lat = 5.5600;
  static const _lon = -0.2050;

  // Foursquare category IDs used in the search
  // 13000=Food, 16000=Outdoors, 10000=Arts&Entertainment, 17000=Retail, 19000=Travel
  static const _fsqCategories = '13000,16000,10000,17000,19000';

  /// Returns nearby places, sorted by weather when [weather] is provided.
  /// Falls back to static curated data when the Foursquare key is not set.
  static Future<List<AppPlace>> fetchNearby({WeatherData? weather}) async {
    List<AppPlace> places = [];

    if (Env.hasPlaces) {
      places = await _fetchFromFoursquare();
    }

    if (places.isEmpty) {
      places = List.of(_staticPlaces); // use curated fallback
    }

    _sortByWeather(places, weather);
    return places;
  }

  // ── Foursquare v3 ──────────────────────────────────────────────────────────

  static Future<List<AppPlace>> _fetchFromFoursquare() async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8);
      final req = await client.getUrl(Uri.parse(
        'https://api.foursquare.com/v3/places/search'
        '?ll=$_lat,$_lon&radius=25000&categories=$_fsqCategories&limit=20&sort=DISTANCE',
      ));
      req.headers
        ..add('Authorization', Env.foursquareKey)
        ..add('Accept', 'application/json');

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      if (res.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final results = data['results'] as List? ?? [];
        return results
            .map((r) => _fromFoursquare(r as Map<String, dynamic>))
            .whereType<AppPlace>()
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static AppPlace? _fromFoursquare(Map<String, dynamic> r) {
    try {
      final name = r['name'] as String? ?? '';
      if (name.isEmpty) return null;

      final cats = r['categories'] as List? ?? [];
      final rawCat = cats.isNotEmpty
          ? (cats.first['name'] as String? ?? 'Place')
          : 'Place';

      final geo = (r['geocodes'] as Map?)?['main'] as Map? ?? {};
      final lat = (geo['latitude'] as num?)?.toDouble() ?? _lat;
      final lng = (geo['longitude'] as num?)?.toDouble() ?? _lon;
      final dist = r['distance'] as int?;

      final category = _normaliseCategory(rawCat);
      final isOutdoor = _outdoorCategories.contains(category.toLowerCase());

      return AppPlace(
        id: r['fsq_id'] as String? ?? name,
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

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _normaliseCategory(String raw) {
    final c = raw.toLowerCase();
    if (c.contains('restaurant') || c.contains('food court')) return 'Restaurant';
    if (c.contains('cafe') || c.contains('coffee')) return 'Cafe';
    if (c.contains('beach')) return 'Beach';
    if (c.contains('park') || c.contains('garden') || c.contains('botanical')) return 'Park';
    if (c.contains('museum') || c.contains('gallery') || c.contains('art')) return 'Museum';
    if (c.contains('mall') || c.contains('shopping')) return 'Shopping';
    if (c.contains('arcade') || c.contains('game') || c.contains('bowling')) return 'Arcade';
    if (c.contains('hotel') || c.contains('hostel') || c.contains('resort')) return 'Leisure';
    if (c.contains('bar') || c.contains('club') || c.contains('lounge')) return 'Nightlife';
    if (c.contains('attraction') || c.contains('landmark') || c.contains('monument')) return 'Attraction';
    return raw; // keep original if no match
  }

  static const _outdoorCategories = {
    'beach', 'park', 'garden', 'attraction', 'nature', 'outdoor',
  };

  static void _sortByWeather(List<AppPlace> places, WeatherData? weather) {
    if (weather == null) return;
    places.sort((a, b) {
      if (weather.isOutdoorFriendly) {
        // Outdoor spots first
        if (a.isOutdoor && !b.isOutdoor) return -1;
        if (!a.isOutdoor && b.isOutdoor) return 1;
      } else {
        // Indoor spots first
        if (!a.isOutdoor && b.isOutdoor) return -1;
        if (a.isOutdoor && !b.isOutdoor) return 1;
      }
      return 0;
    });
  }

  // ── Static fallback — real Accra places ───────────────────────────────────

  static const _staticPlaces = <AppPlace>[
    AppPlace(id: 'labadi_beach',      name: 'Labadi Beach',                  category: 'Beach',      lat: 5.5502, lng: -0.1467, distanceMeters: 3200,  isOutdoor: true),
    AppPlace(id: 'aburi_gardens',     name: 'Aburi Botanical Gardens',       category: 'Park',       lat: 5.8521, lng: -0.1751, distanceMeters: 38000, isOutdoor: true),
    AppPlace(id: 'legon_gardens',     name: 'Legon Botanical Gardens',       category: 'Park',       lat: 5.6502, lng: -0.1869, distanceMeters: 12000, isOutdoor: true),
    AppPlace(id: 'laboma_beach',      name: 'Laboma Beach',                  category: 'Beach',      lat: 5.5310, lng: -0.0852, distanceMeters: 8300,  isOutdoor: true),
    AppPlace(id: 'independence_sq',   name: 'Independence Square',           category: 'Attraction', lat: 5.5481, lng: -0.2014, distanceMeters: 4200,  isOutdoor: true),
    AppPlace(id: 'gamezone_osu',      name: 'GameZone Osu',                  category: 'Arcade',     lat: 5.5560, lng: -0.1813, distanceMeters: 1800,  isOutdoor: false),
    AppPlace(id: 'national_museum',   name: 'National Museum of Ghana',      category: 'Museum',     lat: 5.5614, lng: -0.2044, distanceMeters: 5400,  isOutdoor: false),
    AppPlace(id: 'santoku',           name: 'Santoku Restaurant',            category: 'Restaurant', lat: 5.5573, lng: -0.1772, distanceMeters: 2100,  isOutdoor: false),
    AppPlace(id: 'accra_mall',        name: 'Accra Mall',                    category: 'Shopping',   lat: 5.6037, lng: -0.1870, distanceMeters: 6700,  isOutdoor: false),
    AppPlace(id: 'marina_mall',       name: 'Marina Mall',                   category: 'Shopping',   lat: 5.5588, lng: -0.1936, distanceMeters: 2800,  isOutdoor: false),
    AppPlace(id: 'movenpick',         name: 'Mövenpick Ambassador Hotel',    category: 'Leisure',    lat: 5.5501, lng: -0.2090, distanceMeters: 4000,  isOutdoor: false),
    AppPlace(id: 'la_pleasure_beach', name: 'La Pleasure Beach',             category: 'Beach',      lat: 5.5495, lng: -0.1475, distanceMeters: 3400,  isOutdoor: true),
    AppPlace(id: 'w_accra',           name: 'W Accra Hotel',                 category: 'Leisure',    lat: 5.5497, lng: -0.1770, distanceMeters: 2600,  isOutdoor: false),
    AppPlace(id: 'kempinski_hotel',   name: 'Kempinski Gold Coast City',     category: 'Leisure',    lat: 5.5529, lng: -0.1869, distanceMeters: 2100,  isOutdoor: false),
    AppPlace(id: 'buka_restaurant',   name: 'Buka Restaurant',               category: 'Restaurant', lat: 5.5590, lng: -0.1870, distanceMeters: 2400,  isOutdoor: false),
  ];
}
