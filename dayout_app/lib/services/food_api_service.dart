import 'api_service.dart';

/// Service for fetching food suggestions from the DayOut `/food` endpoint.
class FoodApiService {
  FoodApiService._();

  /// Fetch food suggestions filtered by [bestFor] context and [weather] condition.
  ///
  /// Returns up to 8 suggestions ordered by local-first, then random.
  /// Returns an empty list on error or when no results are found.
  static Future<List<Map<String, dynamic>>> getSuggestions({
    required String bestFor,
    required String weather,
  }) async {
    final path =
        'food/suggest.php?best_for=${Uri.encodeComponent(bestFor)}&weather=${Uri.encodeComponent(weather)}';

    final response = await ApiService.get(path);

    if (response.containsKey('error')) {
      return [];
    }

    final raw = response['suggestions'];
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
