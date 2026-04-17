import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class FoodMatchScreen extends StatefulWidget {
  final String locationName;
  final List<Color> gradientColors;

  const FoodMatchScreen({
    super.key,
    required this.locationName,
    required this.gradientColors,
  });

  @override
  State<FoodMatchScreen> createState() => _FoodMatchScreenState();
}

class _FoodMatchScreenState extends State<FoodMatchScreen> {
  List<_Meal> _meals = [];
  bool _loading = true;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> _fetchMeals() async {
    // Strip common suffixes to get a searchable keyword
    final cleaned = widget.locationName
        .replaceAll(
          RegExp(
            r'\b(restaurant|cafe|eatery|grill|kitchen|bar|diner|bistro|food|house|spot)\b',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    final keyword = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).join(' ');

    if (await _searchMeals(keyword.isNotEmpty ? keyword : 'chicken')) return;

    // Fallback: filter by popular categories
    for (final cat in ['Chicken', 'Seafood', 'Beef', 'Vegetarian']) {
      if (await _filterByCategory(cat)) return;
    }

    // Final fallback: static dishes
    if (mounted) {
      setState(() {
        _meals = _staticFallback;
        _offline = true;
        _loading = false;
      });
    }
  }

  Future<bool> _searchMeals(String query) async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 7);
      final req = await client.getUrl(
        Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/search.php?s=${Uri.encodeComponent(query)}',
        ),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(body) as Map;
      final meals = data['meals'] as List?;
      if (meals != null && meals.isNotEmpty) {
        if (mounted) {
          setState(() {
            _meals = meals.take(8).map((m) => _Meal.fromJson(m)).toList();
            _loading = false;
          });
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _filterByCategory(String category) async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 7);
      final req = await client.getUrl(
        Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?c=$category',
        ),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(body) as Map;
      final meals = data['meals'] as List?;
      if (meals != null && meals.isNotEmpty) {
        if (mounted) {
          setState(() {
            _meals = meals
                .take(6)
                .map((m) => _Meal(
                      name: m['strMeal'] as String? ?? '',
                      category: category,
                      area: '',
                      thumb: m['strMealThumb'] as String? ?? '',
                    ))
                .toList();
            _loading = false;
          });
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  static const _staticFallback = [
    _Meal(name: 'Grilled Tilapia', category: 'Seafood', area: 'Ghanaian', thumb: ''),
    _Meal(name: 'Jollof Rice', category: 'Rice Dish', area: 'West African', thumb: ''),
    _Meal(name: 'Fried Plantain (Kelewele)', category: 'Street Food', area: 'Ghanaian', thumb: ''),
    _Meal(name: 'Groundnut Soup', category: 'Soup', area: 'Ghanaian', thumb: ''),
    _Meal(name: 'Waakye', category: 'Rice & Beans', area: 'Ghanaian', thumb: ''),
    _Meal(name: 'Fufu & Light Soup', category: 'Traditional', area: 'Ghanaian', thumb: ''),
  ];

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1825),
      body: Column(
        children: [
          _buildHeader(context),
          if (!_loading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
              child: Row(
                children: [
                  Icon(
                    _offline
                        ? Icons.wifi_off_rounded
                        : Icons.restaurant_menu_rounded,
                    size: 15,
                    color: const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _offline
                        ? 'Showing local suggestions · connect for more'
                        : '${_meals.length} dish${_meals.length == 1 ? '' : 'es'} you might enjoy',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF00C2CC),
                          strokeWidth: 2,
                        ),
                        SizedBox(height: 14),
                        Text('Finding the best dishes…',
                            style: TextStyle(
                                color: Color(0xFF6B7280), fontSize: 13)),
                      ],
                    ),
                  )
                : _meals.isEmpty
                    ? const Center(
                        child: Text('No dishes found',
                            style: TextStyle(
                                color: Color(0xFF6B7280), fontSize: 14)),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 10, 16, 24),
                        itemCount: _meals.length,
                        itemBuilder: (_, i) => _MealCard(
                          meal: _meals[i],
                          gradientColors: widget.gradientColors,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Food Match',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.locationName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const Text('🍽️', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Meal card ─────────────────────────────────────────────────────────────────

class _MealCard extends StatelessWidget {
  final _Meal meal;
  final List<Color> gradientColors;

  const _MealCard({required this.meal, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    final accent = gradientColors.last;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF162030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243447)),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: meal.thumb.isNotEmpty
                ? Image.network(
                    meal.thumb,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _placeholder(gradientColors),
                  )
                : _placeholder(gradientColors),
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (meal.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            meal.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ),
                      if (meal.area.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '· ${meal.area}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _placeholder(List<Color> colors) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.map((c) => c.withValues(alpha: 0.45)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text('🍽️', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _Meal {
  final String name;
  final String category;
  final String area;
  final String thumb;

  const _Meal({
    required this.name,
    required this.category,
    required this.area,
    required this.thumb,
  });

  factory _Meal.fromJson(Map m) => _Meal(
        name: m['strMeal'] as String? ?? '',
        category: m['strCategory'] as String? ?? '',
        area: m['strArea'] as String? ?? '',
        thumb: m['strMealThumb'] as String? ?? '',
      );
}
