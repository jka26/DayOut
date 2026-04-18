import 'api_service.dart';

/// Service for plan CRUD operations against the DayOut `/plans` endpoints.
class PlanApiService {
  PlanApiService._();

  /// Fetch all plans for the authenticated user (with nested stops + friends).
  static Future<List<Map<String, dynamic>>> getPlans() async {
    final response = await ApiService.get('plans/index.php');

    if (response.containsKey('error')) {
      return [];
    }

    final raw = response['plans'];
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Create a new plan with optional stops and friends.
  ///
  /// [stops]   — each map must contain: `place_name`, `latitude`, `longitude`,
  ///             `stop_order`; optional: `place_id`, `arrival_time`, `weather_badge`.
  /// [friends] — each map must contain: `name`, `contact`.
  static Future<Map<String, dynamic>?> createPlan({
    required String planName,
    required String vibe,
    String? outingDate,
    String? weatherContext,
    List<Map<String, dynamic>> stops = const [],
    List<Map<String, dynamic>> friends = const [],
  }) async {
    final body = <String, dynamic>{
      'plan_name': planName,
      'vibe': vibe,
      if (outingDate != null) 'outing_date': outingDate,
      if (weatherContext != null) 'weather_context': weatherContext,
      'stops': stops,
      'friends': friends,
    };

    final response = await ApiService.post('plans/index.php', body);

    if (response.containsKey('error')) {
      return null;
    }

    return response['plan'] as Map<String, dynamic>?;
  }

  /// Update mutable fields of an existing plan.
  static Future<bool> updatePlan(int id, Map<String, dynamic> updates) async {
    final response = await ApiService.put('plans/plan.php?id=$id', updates);
    return !response.containsKey('error');
  }

  /// Permanently delete a plan (cascade removes stops, friends, facts).
  static Future<bool> deletePlan(int id) async {
    final response = await ApiService.delete('plans/plan.php?id=$id');
    return !response.containsKey('error');
  }

  /// Mark a plan as available offline.
  static Future<bool> markOffline(int id) async {
    return updatePlan(id, {'is_offline': 1});
  }
}
