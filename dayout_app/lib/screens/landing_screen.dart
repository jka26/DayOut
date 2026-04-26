import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'discover_screen.dart';
import 'plan_screen.dart';
import 'save_plan_screen.dart';
import 'surprise_screen.dart';
import '../models/app_place.dart';
import '../services/auth_service.dart';
import '../services/places_service.dart';
import '../services/weather_service.dart';
import '../widgets/logout_button.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  // ignore: prefer_final_fields
  int _selectedNavIndex = 0;
  String _displayName = '';
  int _selectedFilter = 0;
  List<AppPlace> _livePlaces = [];
  bool _placesLoading = true;
  WeatherData? _weather;

  static const _filters = ['All', 'Outdoor', 'Food', 'Indoor'];
  static const _filterCategories = <int, Set<String>>{
    1: {'beach', 'park', 'attraction', 'sports', 'garden'},
    2: {'restaurant', 'cafe', 'nightlife'},
    3: {'museum', 'shopping', 'arcade', 'entertainment', 'leisure'},
  };

  List<AppPlace> get _filteredPlaces {
    if (_selectedFilter == 0) return _livePlaces;
    final cats = _filterCategories[_selectedFilter];
    if (cats == null) return _livePlaces;
    final filtered = _livePlaces
        .where((p) => cats.contains(p.category.toLowerCase()))
        .toList();
    return filtered.isEmpty ? _livePlaces : filtered;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _loadUser() async {
    final user = await AuthService.me();
    if (user != null && mounted) {
      setState(() {
        _displayName = (user['name'] as String? ?? '').split(' ').first;
      });
    }
  }

  Future<void> _loadPlaces() async {
    double? deviceLat, deviceLng;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 5)));
        deviceLat = pos.latitude;
        deviceLng = pos.longitude;
      }
    } catch (_) {}
    final weather = await WeatherService.fetchAccra();
    final places = await PlacesService.fetchNearby(
        weather: weather, lat: deviceLat, lng: deviceLng);
    if (!mounted) return;
    setState(() {
      _weather = weather;
      _livePlaces = places;
      _placesLoading = false;
    });
  }

  static String _categoryEmoji(String cat) {
    switch (cat.toLowerCase()) {
      case 'beach': return '🏖️';
      case 'park': case 'garden': return '🌿';
      case 'restaurant': return '🍽️';
      case 'cafe': return '☕';
      case 'museum': return '🏛️';
      case 'arcade': return '🕹️';
      case 'shopping': return '🛍️';
      case 'nightlife': return '🍸';
      case 'attraction': return '📍';
      case 'entertainment': return '🎭';
      case 'sports': return '⚽';
      default: return '📌';
    }
  }

  static Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'beach': return const Color(0xFF00C2CC);
      case 'park': case 'garden': return const Color(0xFF22C55E);
      case 'restaurant': return const Color(0xFFF59E0B);
      case 'cafe': return const Color(0xFFD97706);
      case 'museum': return const Color(0xFF6B7280);
      case 'arcade': return const Color(0xFF7C3AED);
      case 'shopping': return const Color(0xFF0891B2);
      case 'nightlife': return const Color(0xFF1D4ED8);
      case 'attraction': return const Color(0xFFEF4444);
      case 'entertainment': return const Color(0xFFEC4899);
      case 'sports': return const Color(0xFF16A34A);
      default: return const Color(0xFF374151);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPlaces();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: Column(
            children: [
              // ── Top dark header ──────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF004D52), Color(0xFF00C2CC)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting
                        Row(
                          children: [
                            Text(
                              '$_greeting${_displayName.isNotEmpty ? ', $_displayName' : ''} ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text('👋', style: TextStyle(fontSize: 14)),
                            const Spacer(),
                            const LogoutButton(),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Headline
                        const Text(
                          'Where are we\ngoing today?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Weather card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _weather == null
                                      ? const Color(0xFFFFB300)
                                      : _weather!.isOutdoorFriendly
                                          ? const Color(0xFFFFB300)
                                          : const Color(0xFF4A90D9),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _weather == null
                                        ? '☀️'
                                        : _weather!.isOutdoorFriendly
                                            ? '☀️'
                                            : '🌧️',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _weather == null
                                        ? 'Loading weather…'
                                        : '${_weather!.tempCelsius.round()}°C · ${_weather!.description}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _weather == null
                                        ? 'Accra, Ghana'
                                        : _weather!.isOutdoorFriendly
                                            ? 'Great day for an outdoor outing!'
                                            : 'Indoor activities recommended today',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Action buttons — side by side
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.calendar_today_outlined,
                                label: 'Plan an Outing',
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF004D52),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PlanScreen(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.star_outline_rounded,
                                label: 'Surprise Me',
                                backgroundColor: Colors.white.withValues(alpha: 0.18),
                                foregroundColor: Colors.white,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SurpriseScreen(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom white scrollable section ──────────────────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Quick Picks Near You ──────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Quick Picks Near You',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'See all',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00C2CC),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                _CategoryCard(
                                  emoji: '🕹️',
                                  label: 'Arcades',
                                  count: '6 nearby',
                                  color: Color(0xFF7C3AED),
                                ),
                                SizedBox(width: 12),
                                _CategoryCard(
                                  emoji: '🌿',
                                  label: 'Parks',
                                  count: '4 nearby',
                                  color: Color(0xFF00C2CC),
                                ),
                                SizedBox(width: 12),
                                _CategoryCard(
                                  emoji: '🏖️',
                                  label: 'Beaches',
                                  count: '3 nearby',
                                  color: Color(0xFF0284C7),
                                ),
                                SizedBox(width: 12),
                                _CategoryCard(
                                  emoji: '🍽️',
                                  label: 'Restaurants',
                                  count: '12 nearby',
                                  color: Color(0xFFE91E8C),
                                ),
                              ],
                            ),
                          ),
                          ),

                          const SizedBox(height: 24),

                          // ── Nearby Places ─────────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Nearby Places',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const DiscoverScreen()),
                                  ),
                                  child: const Text(
                                    'See all',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00C2CC),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Filter tabs
                          SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _filters.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                final active = _selectedFilter == i;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedFilter = i),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? const Color(0xFF00C2CC)
                                          : const Color(0xFFEEF0F3),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _filters[i],
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: active
                                              ? Colors.white
                                              : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Place cards
                          if (_placesLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00C2CC),
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  for (int i = 0;
                                      i <
                                          _filteredPlaces
                                              .take(5)
                                              .length;
                                      i++) ...[
                                    _LocationCard(
                                      emoji: _categoryEmoji(
                                          _filteredPlaces[i].category),
                                      color: _categoryColor(
                                          _filteredPlaces[i].category),
                                      name: _filteredPlaces[i].name,
                                      category: _filteredPlaces[i].category,
                                      distance: _filteredPlaces[i].distanceStr,
                                      rating: _filteredPlaces[i].displayRating,
                                      badge: _filteredPlaces[i].badge,
                                      badgeColor: _filteredPlaces[i].badgeColor,
                                      thumbnailUrl: _filteredPlaces[i].thumbnailUrl,
                                    ),
                                    if (i < _filteredPlaces.take(5).length - 1)
                                      const SizedBox(height: 12),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Bottom nav bar ────────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: _selectedNavIndex == 0,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LandingScreen(),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Discover',
                  selected: _selectedNavIndex == 1,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DiscoverScreen(),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Plan',
                  selected: _selectedNavIndex == 2,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlanScreen(),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.star_outline_rounded,
                  label: 'Surprise',
                  selected: _selectedNavIndex == 3,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SurpriseScreen(),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.bookmark_outline_rounded,
                  label: 'Saved',
                  selected: _selectedNavIndex == 4,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavePlanScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final BoxBorder? border;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foregroundColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String count;
  final Color color;

  const _CategoryCard({
    required this.emoji,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          Text(
            count,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String emoji;
  final Color color;
  final String name;
  final String category;
  final String distance;
  final double rating;
  final String badge;
  final Color badgeColor;
  final String? thumbnailUrl;

  const _LocationCard({
    required this.emoji,
    required this.color,
    required this.name,
    required this.category,
    required this.distance,
    required this.rating,
    required this.badge,
    required this.badgeColor,
    this.thumbnailUrl,
  });

  Widget _emojiPlaceholder() => Container(
        width: 56,
        height: 56,
        color: color.withValues(alpha: 0.15),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: thumbnailUrl != null
                ? Image.network(
                    thumbnailUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _emojiPlaceholder(),
                  )
                : _emojiPlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$category · $distance',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_rounded,
                        size: 12, color: Color(0xFFFFA726)),
                    const SizedBox(width: 2),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF00C2CC) : const Color(0xFF9CA3AF);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
