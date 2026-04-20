import 'package:flutter/material.dart';

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
}

class PlanStore {
  static final List<SavedPlan> plans = [];

  static void add(SavedPlan plan) => plans.add(plan);

  static void remove(String id) => plans.removeWhere((p) => p.id == id);

  static void update(SavedPlan plan) {
    final i = plans.indexWhere((p) => p.id == plan.id);
    if (i >= 0) plans[i] = plan;
  }
}
