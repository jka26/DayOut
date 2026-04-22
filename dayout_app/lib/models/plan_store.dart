import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StopInfo {
  final String name;
  final Color color;
  final String emoji;
  final String category;

  const StopInfo({
    required this.name,
    required this.color,
    required this.emoji,
    this.category = 'Place',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color.toARGB32(),
        'emoji': emoji,
        'category': category,
      };

  factory StopInfo.fromJson(Map<String, dynamic> j) => StopInfo(
        name: j['name'] as String,
        color: Color(j['color'] as int),
        emoji: j['emoji'] as String,
        category: j['category'] as String? ?? 'Place',
      );
}

class SavedPlan {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<StopInfo> stops;
  final List<String> friendInitials;
  final List<String> friendNames;
  final bool isSurprise;

  const SavedPlan({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.stops,
    required this.friendInitials,
    this.friendNames = const [],
    this.isSurprise = false,
  });

  bool get isSolo => friendInitials.isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'stops': stops.map((s) => s.toJson()).toList(),
        'friendInitials': friendInitials,
        'friendNames': friendNames,
        'isSurprise': isSurprise,
      };

  factory SavedPlan.fromJson(Map<String, dynamic> j) => SavedPlan(
        id: j['id'] as String,
        name: j['name'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        stops: (j['stops'] as List)
            .map((s) => StopInfo.fromJson(s as Map<String, dynamic>))
            .toList(),
        friendInitials: List<String>.from(j['friendInitials'] as List),
        friendNames: List<String>.from(j['friendNames'] as List? ?? []),
        isSurprise: j['isSurprise'] as bool? ?? false,
      );
}

class PlanStore {
  static final List<SavedPlan> plans = [];
  static const _key = 'dayout_saved_plans';

  /// Call once at app startup to restore persisted plans.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      plans
        ..clear()
        ..addAll(list.map((e) => SavedPlan.fromJson(e as Map<String, dynamic>)));
    } catch (_) {}
  }

  static void add(SavedPlan plan) {
    plans.add(plan);
    _persist();
  }

  static void remove(String id) {
    plans.removeWhere((p) => p.id == id);
    _persist();
  }

  static void update(SavedPlan plan) {
    final i = plans.indexWhere((p) => p.id == plan.id);
    if (i >= 0) plans[i] = plan;
    _persist();
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(plans.map((p) => p.toJson()).toList()));
    } catch (_) {}
  }
}
