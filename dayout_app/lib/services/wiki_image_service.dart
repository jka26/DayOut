import 'dart:convert';
import 'dart:io';

/// Fetches a thumbnail image URL from the Wikipedia REST API.
/// No API key required.
class WikiImageService {
  static const _base = 'https://en.wikipedia.org/api/rest_v1/page/summary/';

  /// Known Wikipedia article titles for static Accra places.
  static const _knownTitles = <String, String?>{
    'labadi_beach':      'Labadi_Beach',
    'aburi_gardens':     'Aburi_Botanical_Gardens',
    'legon_gardens':     'University_of_Ghana_Botanical_Garden',
    'laboma_beach':      'Laboma_Beach',
    'independence_sq':   'Independence_Square,_Accra',
    'kwame_mausoleum':   'Kwame_Nkrumah_Mausoleum',
    'national_museum':   'National_Museum_of_Ghana',
    'accra_mall':        'Accra_Mall',
    'national_theatre':  'National_Theatre_of_Ghana',
    'gamezone_osu':      null, // no Wikipedia article
    'santoku':           null,
    'buka_restaurant':   null,
    'republic_bar':      null,
    'marina_mall':       null,
    'la_pleasure_beach': null,
  };

  /// Returns the cached known thumbnail URL or null for a static place id.
  static String? knownUrl(String placeId) {
    final title = _knownTitles[placeId];
    if (title == null) return null;
    // Wikimedia thumbnail pattern is stable for these articles.
    return null; // resolved lazily via fetch
  }

  /// Fetches a thumbnail URL from Wikipedia for the given article title.
  /// Returns null on failure or if no image exists.
  static Future<String?> fetchThumbnail(String articleTitle) async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 6);
      final req = await client.getUrl(
          Uri.parse('$_base${Uri.encodeComponent(articleTitle)}'));
      req.headers.set('User-Agent', 'DayOutApp/1.0 (educational project)');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      if (res.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        final thumb = data['thumbnail'] as Map<String, dynamic>?;
        return thumb?['source'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Looks up a thumbnail for a place name by searching Wikipedia.
  /// Appends "Accra" to improve relevance for local places.
  static Future<String?> fetchByName(String placeName) async {
    final title = placeName.replaceAll(' ', '_');
    final result = await fetchThumbnail(title);
    if (result != null) return result;
    return fetchThumbnail('${title}_Accra');
  }

  /// Title map for use in PlacesService.
  static String? articleTitle(String placeId) => _knownTitles[placeId];
}
