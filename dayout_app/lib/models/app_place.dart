import 'package:flutter/material.dart';

/// Shared place model used across the app and populated from the Places API.
class AppPlace {
  final String id;
  final String name;
  final String category; // e.g. 'Restaurant', 'Beach', 'Park'
  final double lat;
  final double lng;
  final double? rating;       // null until fetched from API
  final int? distanceMeters;  // null if unknown
  final bool isOutdoor;

  const AppPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    this.rating,
    this.distanceMeters,
    required this.isOutdoor,
  });

  // ── Computed display helpers ───────────────────────────────────────────────

  String get distanceStr {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 1000) return '${distanceMeters}m';
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
  }

  /// Stable pseudo-rating derived from id when real rating is unavailable.
  double get displayRating => rating ?? (3.8 + (id.hashCode.abs() % 12) * 0.1);

  String get emoji => _emoji[category.toLowerCase()] ?? '📍';
  Color get color => _color[category.toLowerCase()] ?? const Color(0xFF00C2CC);
  List<Color> get gradientColors =>
      _gradient[category.toLowerCase()] ??
      const [Color(0xFF004D52), Color(0xFF00C2CC)];
  IconData get icon => _icon[category.toLowerCase()] ?? Icons.location_on_rounded;

  String get badge => isOutdoor ? 'Outdoor' : 'Indoor';
  Color get badgeColor =>
      isOutdoor ? const Color(0xFF22C55E) : const Color(0xFF7C3AED);
  IconData get badgeIcon =>
      isOutdoor ? Icons.wb_sunny_rounded : Icons.bolt_rounded;

  String get socialText {
    final n = (id.hashCode.abs() % 55) + 5;
    return '$n people interested today';
  }

  // ── Equality (needed for Map keys in plan screen) ─────────────────────────

  @override
  bool operator ==(Object other) => other is AppPlace && other.id == id;

  @override
  int get hashCode => id.hashCode;

  // ── Category mappings ─────────────────────────────────────────────────────

  static const _emoji = <String, String>{
    'restaurant': '🍽️',
    'cafe': '☕',
    'beach': '🏖️',
    'park': '🌿',
    'garden': '🌿',
    'museum': '🏛️',
    'shopping': '🛍️',
    'mall': '🛍️',
    'arcade': '🕹️',
    'entertainment': '🎭',
    'hotel': '🏨',
    'leisure': '🏨',
    'nightlife': '🎵',
    'bar': '🍺',
    'attraction': '📸',
  };

  static const _color = <String, Color>{
    'restaurant': Color(0xFFF59E0B),
    'cafe': Color(0xFFD97706),
    'beach': Color(0xFF00C2CC),
    'park': Color(0xFF22C55E),
    'garden': Color(0xFF16A34A),
    'museum': Color(0xFF3B82F6),
    'shopping': Color(0xFFEC4899),
    'mall': Color(0xFFEC4899),
    'arcade': Color(0xFF7C3AED),
    'entertainment': Color(0xFF7C3AED),
    'hotel': Color(0xFFD97706),
    'leisure': Color(0xFFD97706),
    'nightlife': Color(0xFF6366F1),
    'attraction': Color(0xFF06B6D4),
  };

  static const _gradient = <String, List<Color>>{
    'restaurant': [Color(0xFF78350F), Color(0xFFF59E0B)],
    'cafe': [Color(0xFF451A03), Color(0xFFD97706)],
    'beach': [Color(0xFF004D52), Color(0xFF00C2CC)],
    'park': [Color(0xFF064E3B), Color(0xFF10B981)],
    'garden': [Color(0xFF14532D), Color(0xFF16A34A)],
    'museum': [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    'shopping': [Color(0xFF831843), Color(0xFFEC4899)],
    'mall': [Color(0xFF831843), Color(0xFFEC4899)],
    'arcade': [Color(0xFF4C1D95), Color(0xFF7C3AED)],
    'entertainment': [Color(0xFF4C1D95), Color(0xFF7C3AED)],
    'hotel': [Color(0xFF451A03), Color(0xFFD97706)],
    'leisure': [Color(0xFF451A03), Color(0xFFD97706)],
    'nightlife': [Color(0xFF1E1B4B), Color(0xFF6366F1)],
    'attraction': [Color(0xFF0C4A6E), Color(0xFF06B6D4)],
  };

  static const _icon = <String, IconData>{
    'restaurant': Icons.restaurant_rounded,
    'cafe': Icons.local_cafe_rounded,
    'beach': Icons.beach_access_rounded,
    'park': Icons.park_rounded,
    'garden': Icons.eco_rounded,
    'museum': Icons.museum_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'mall': Icons.shopping_bag_rounded,
    'arcade': Icons.sports_esports_rounded,
    'entertainment': Icons.theater_comedy_rounded,
    'hotel': Icons.hotel_rounded,
    'leisure': Icons.hotel_rounded,
    'nightlife': Icons.nightlife_rounded,
    'attraction': Icons.camera_alt_rounded,
  };
}
