import 'package:flutter/material.dart';

class StopInfo {
  final String name;
  final Color color;
  final String emoji;
  const StopInfo({
    required this.name,
    required this.color,
    required this.emoji,
  });
}

class SavedPlan {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<StopInfo> stops;
  final List<String> friendInitials;

  const SavedPlan({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.stops,
    required this.friendInitials,
  });

  bool get isSolo => friendInitials.isEmpty;
}

class PlanStore {
  static final List<SavedPlan> plans = [];

  static void add(SavedPlan plan) => plans.add(plan);
  static void remove(String id) => plans.removeWhere((p) => p.id == id);
}
