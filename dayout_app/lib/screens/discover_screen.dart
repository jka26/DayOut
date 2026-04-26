import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/weather_service.dart';
import '../services/places_service.dart';
import 'food_match_screen.dart';
import 'fun_facts_screen.dart';
import 'plan_screen.dart';
import 'save_plan_screen.dart';
import 'surprise_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<_PlaceData> _livePlaces = [];
  bool _placesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    double? deviceLat, deviceLng;
    try {
      final permission = await Geolocator.checkPermission() == LocationPermission.denied
          ? await Geolocator.requestPermission()
          : await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 5)));
        deviceLat = pos.latitude;
        deviceLng = pos.longitude;
      }
    } catch (_) {}
    final weather = await WeatherService.fetchAccra();
    final appPlaces = await PlacesService.fetchNearby(
        weather: weather, lat: deviceLat, lng: deviceLng);
    if (!mounted) return;
    setState(() {
      _livePlaces = appPlaces.map((p) => _PlaceData(
            name: p.name,
            category: p.category,
            distance: p.distanceStr,
            rating: p.displayRating,
            badge: p.badge,
            badgeColor: _categoryColor(p.category),
            gradientColors: _categoryGradient(p.category),
            icon: _categoryIcon(p.category),
            social: p.socialText,
            lat: p.lat,
            lng: p.lng,
            thumbnailUrl: p.thumbnailUrl,
          )).toList();
      _placesLoading = false;
    });
  }

  static Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'beach': return const Color(0xFF00C2CC);
      case 'park': return const Color(0xFF22C55E);
      case 'restaurant': return const Color(0xFFF59E0B);
      case 'cafe': return const Color(0xFFD97706);
      case 'museum': return const Color(0xFF6B7280);
      case 'arcade': return const Color(0xFF7C3AED);
      case 'shopping': return const Color(0xFF0891B2);
      case 'nightlife': return const Color(0xFF1D4ED8);
      case 'attraction': return const Color(0xFFEF4444);
      default: return const Color(0xFF374151);
    }
  }

  static List<Color> _categoryGradient(String cat) {
    switch (cat.toLowerCase()) {
      case 'beach': return [const Color(0xFF004D52), const Color(0xFF00C2CC)];
      case 'park': return [const Color(0xFF064E3B), const Color(0xFF10B981)];
      case 'restaurant': return [const Color(0xFF78350F), const Color(0xFFF59E0B)];
      case 'cafe': return [const Color(0xFF92400E), const Color(0xFFD97706)];
      case 'museum': return [const Color(0xFF374151), const Color(0xFF9CA3AF)];
      case 'arcade': return [const Color(0xFF4C1D95), const Color(0xFF7C3AED)];
      case 'shopping': return [const Color(0xFF0C4A6E), const Color(0xFF0891B2)];
      case 'nightlife': return [const Color(0xFF1E1B4B), const Color(0xFF4F46E5)];
      case 'attraction': return [const Color(0xFF7F1D1D), const Color(0xFFEF4444)];
      default: return [const Color(0xFF1F2937), const Color(0xFF374151)];
    }
  }

  static IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'beach': return Icons.beach_access_rounded;
      case 'park': return Icons.eco_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'cafe': return Icons.coffee_rounded;
      case 'museum': return Icons.museum_rounded;
      case 'arcade': return Icons.sports_esports_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'nightlife': return Icons.nightlife_rounded;
      case 'attraction': return Icons.place_rounded;
      default: return Icons.location_on_rounded;
    }
  }

  static const _places = [
    _PlaceData(
      name: 'Labadi Beach',
      category: 'Beach',
      distance: '3.2 km',
      rating: 4.7,
      badge: 'Popular',
      badgeColor: Color(0xFF00C2CC),
      gradientColors: [Color(0xFF004D52), Color(0xFF00C2CC)],
      icon: Icons.beach_access_rounded,
      social: '47 people planning to visit today',
      lat: 5.5502,
      lng: -0.1467,
    ),
    _PlaceData(
      name: 'Aburi Botanical Gardens',
      category: 'Park',
      distance: '38 km',
      rating: 4.4,
      badge: 'Hidden Gem',
      badgeColor: Color(0xFF22C55E),
      gradientColors: [Color(0xFF064E3B), Color(0xFF10B981)],
      icon: Icons.eco_rounded,
      social: '12 people visited recently',
      lat: 5.8521,
      lng: -0.1751,
    ),
    _PlaceData(
      name: 'GameZone Osu',
      category: 'Arcade',
      distance: '1.8 km',
      rating: 4.5,
      badge: 'Trending',
      badgeColor: Color(0xFF7C3AED),
      gradientColors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
      icon: Icons.sports_esports_rounded,
      social: '28 people loved it this week',
      lat: 5.5560,
      lng: -0.1813,
    ),
    _PlaceData(
      name: 'National Museum of Ghana',
      category: 'Museum',
      distance: '5.4 km',
      rating: 4.2,
      badge: 'Must-see',
      badgeColor: Color(0xFF3B82F6),
      gradientColors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
      icon: Icons.museum_rounded,
      social: '19 people saved this spot',
      lat: 5.5614,
      lng: -0.2044,
    ),
    _PlaceData(
      name: 'Santoku Restaurant',
      category: 'Restaurant',
      distance: '2.1 km',
      rating: 4.6,
      badge: 'Top Rated',
      badgeColor: Color(0xFFF59E0B),
      gradientColors: [Color(0xFF78350F), Color(0xFFF59E0B)],
      icon: Icons.restaurant_rounded,
      social: '33 people dined here today',
      lat: 5.5573,
      lng: -0.1772,
    ),
    _PlaceData(
      name: 'Accra Mall',
      category: 'Shopping',
      distance: '6.7 km',
      rating: 4.3,
      badge: 'Local Fav',
      badgeColor: Color(0xFFEC4899),
      gradientColors: [Color(0xFF831843), Color(0xFFEC4899)],
      icon: Icons.shopping_bag_rounded,
      social: '61 people here right now',
      lat: 5.6037,
      lng: -0.1870,
    ),
    _PlaceData(
      name: 'Laboma Beach',
      category: 'Beach',
      distance: '8.3 km',
      rating: 4.1,
      badge: 'Chill Spot',
      badgeColor: Color(0xFF06B6D4),
      gradientColors: [Color(0xFF0C4A6E), Color(0xFF06B6D4)],
      icon: Icons.waves_rounded,
      social: '15 people relaxing today',
      lat: 5.5310,
      lng: -0.0852,
    ),
    _PlaceData(
      name: 'Mövenpick Ambassador Hotel',
      category: 'Leisure',
      distance: '4.0 km',
      rating: 4.8,
      badge: 'Premium',
      badgeColor: Color(0xFFD97706),
      gradientColors: [Color(0xFF451A03), Color(0xFFD97706)],
      icon: Icons.hotel_rounded,
      social: '9 people recommended this',
      lat: 5.5501,
      lng: -0.2090,
    ),
    _PlaceData(
      name: 'Legon Botanical Gardens',
      category: 'Park',
      distance: '12 km',
      rating: 4.0,
      badge: 'Nature Walk',
      badgeColor: Color(0xFF16A34A),
      gradientColors: [Color(0xFF14532D), Color(0xFF16A34A)],
      icon: Icons.park_rounded,
      social: '8 people visited this week',
      lat: 5.6502,
      lng: -0.1869,
    ),
  ];

  List<_PlaceData> get _activeList =>
      _livePlaces.isNotEmpty ? _livePlaces : _places;

  List<_PlaceData> get _filtered {
    if (_searchQuery.isEmpty) return _activeList;
    final q = _searchQuery.toLowerCase();
    return _activeList
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _placesLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00C2CC),
                      strokeWidth: 2,
                    ),
                  )
                : _filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) => _PlaceCard(
                          place: _filtered[i],
                          onTap: () =>
                              _showLocationSheet(context, _filtered[i]),
                        ),
                      ),
          ),
          _buildBottomNav(context),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Explore spots near you',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   width: 42,
                  //   height: 42,
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFF00C2CC).withValues(alpha: 0.1),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: const Icon(
                  //     Icons.tune_rounded,
                  //     color: Color(0xFF00C2CC),
                  //     size: 20,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search places, parks, food...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 18,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No results for "$_searchQuery"',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location bottom sheet ─────────────────────────────────────────────────

  void _showLocationSheet(BuildContext context, _PlaceData place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationSheet(place: place),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    return Container(
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
                selected: false,
                onTap: () => Navigator.pop(context),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Discover',
                selected: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Plan',
                selected: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlanScreen()),
                ),
              ),
              _NavItem(
                icon: Icons.star_outline_rounded,
                label: 'Surprise',
                selected: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SurpriseScreen()),
                ),
              ),
              _NavItem(
                icon: Icons.bookmark_outline_rounded,
                label: 'Saved',
                selected: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavePlanScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Place card ────────────────────────────────────────────────────────────────

class _PlaceCard extends StatelessWidget {
  final _PlaceData place;
  final VoidCallback onTap;

  const _PlaceCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image / gradient area ──────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: place.gradientColors,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Wiki image (covers gradient when available)
                    if (place.thumbnailUrl != null)
                      Image.network(
                        place.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    // Watermark icon (shown only when no image)
                    if (place.thumbnailUrl == null)
                      Center(
                        child: Icon(
                          place.icon,
                          size: 90,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    // Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: place.badgeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              place.badge,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: place.badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tap to view map hint
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Tap for directions',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Text area ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Color(0xFFFFA726)),
                          const SizedBox(width: 3),
                          Text(
                            place.rating.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 3),
                      Text(
                        '${place.category} · ${place.distance}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.people_outline_rounded,
                          size: 13, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(
                        place.social,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  // ── Action buttons ──────────────────────────────
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionChip(
                          emoji: '✨',
                          label: 'Fun Facts',
                          color: const Color(0xFF00C2CC),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FunFactsScreen(
                                locationName: place.name,
                                category: place.category,
                                gradientColors: place.gradientColors,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (const {'restaurant', 'cafe', 'eatery'}
                          .contains(place.category.toLowerCase())) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionChip(
                            emoji: '🍽️',
                            label: 'Food Match',
                            color: const Color(0xFFF59E0B),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FoodMatchScreen(
                                  locationName: place.name,
                                  gradientColors: place.gradientColors,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Location bottom sheet ─────────────────────────────────────────────────────

class _LocationSheet extends StatelessWidget {
  final _PlaceData place;
  const _LocationSheet({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Real OSM map
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.hardEdge,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(place.lat, place.lng),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.dayout.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(place.lat, place.lng),
                      width: 48,
                      height: 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: place.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: place.gradientColors.last
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(place.icon,
                                size: 18, color: Colors.white),
                          ),
                          Container(
                            width: 2,
                            height: 10,
                            color: place.gradientColors.last,
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: place.gradientColors.last
                                  .withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: place.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(place.icon, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        '${place.category} · ${place.distance} away',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: Color(0xFFFFA726)),
                    const SizedBox(width: 3),
                    Text(
                      place.rating.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Coordinates
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.my_location_rounded,
                    size: 13, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  '${place.lat.toStringAsFixed(4)}°N, ${place.lng.abs().toStringAsFixed(4)}°W',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Get Directions button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004D52), Color(0xFF00C2CC)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton.icon(
                  onPressed: () async {
                    final geoUri = Uri.parse(
                        'geo:${place.lat},${place.lng}?q=${place.lat},${place.lng}(${Uri.encodeComponent(place.name)})');
                    if (await canLaunchUrl(geoUri)) {
                      await launchUrl(geoUri);
                    } else {
                      final webUri = Uri.parse(
                          'https://www.openstreetmap.org/?mlat=${place.lat}&mlon=${place.lng}&zoom=16');
                      await launchUrl(webUri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.directions_rounded,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Get Directions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map grid painter ──────────────────────────────────────────────────────────

// ── Data model ────────────────────────────────────────────────────────────────

class _PlaceData {
  final String name;
  final String category;
  final String distance;
  final double rating;
  final String badge;
  final Color badgeColor;
  final List<Color> gradientColors;
  final IconData icon;
  final String social;
  final double lat;
  final double lng;
  final String? thumbnailUrl;

  const _PlaceData({
    required this.name,
    required this.category,
    required this.distance,
    required this.rating,
    required this.badge,
    required this.badgeColor,
    required this.gradientColors,
    required this.icon,
    required this.social,
    required this.lat,
    required this.lng,
    this.thumbnailUrl,
  });
}

// ── Nav item ──────────────────────────────────────────────────────────────────

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
    final color =
        selected ? const Color(0xFF00C2CC) : const Color(0xFF9CA3AF);
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

// ── Action chip ───────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
