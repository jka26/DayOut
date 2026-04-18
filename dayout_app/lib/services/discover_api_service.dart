import 'api_service.dart';

/// Service for the Discover feed and activity recording endpoints.
class DiscoverApiService {
  DiscoverApiService._();

  /// Fetch nearby discover feed entries ordered by visit count.
  ///
  /// [lat] / [lng] — centre point for Haversine distance calculation.
  /// [limit]       — number of results to return (max 50, default 20).
  static Future<List<Map<String, dynamic>>> getFeed({
    required double lat,
    required double lng,
    int limit = 20,
  }) async {
    final clampedLimit = limit.clamp(1, 50);
    final path = 'discover/feed.php?lat=$lat&lng=$lng&limit=$clampedLimit';

    final response = await ApiService.get(path);

    if (response.containsKey('error')) {
      return [];
    }

    final raw = response['feed'];
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Record a visit or save action for a place.
  ///
  /// Uses INSERT … ON DUPLICATE KEY UPDATE on the backend so this is safe
  /// to call multiple times for the same [placeId].
  static Future<void> recordActivity({
    required String placeId,
    required String placeName,
    required double lat,
    required double lng,
    required String category,
    String action = 'visit',
    String moodTags = '',
  }) async {
    await ApiService.post('discover/activity.php', {
      'place_id': placeId,
      'place_name': placeName,
      'latitude': lat,
      'longitude': lng,
      'place_category': category,
      'action': action,
      'mood_tags': moodTags,
    });
  }
}
