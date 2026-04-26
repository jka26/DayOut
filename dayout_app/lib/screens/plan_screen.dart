import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/plan_store.dart';
import '../services/weather_service.dart';
import 'food_match_screen.dart';
import 'fun_facts_screen.dart';
import 'save_plan_screen.dart';

class PlanScreen extends StatefulWidget {
  final SavedPlan? initialPlan;
  const PlanScreen({super.key, this.initialPlan});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int _selectedVibe = -1;
  int _currentStep = 1;
  final List<_PlaceData> _itinerary = [];
  final Map<_PlaceData, TimeOfDay?> _stopTimes = {};
  final Map<_PlaceData, DateTime?> _stopDates = {};
  final List<_FriendData> _invitedFriends = [];
  String? _editingPlanId;
  WeatherData? _weather;

  static const _avatarColors = [
    Color(0xFF00C2CC), Color(0xFFE91E8C), Color(0xFF7C3AED),
    Color(0xFFF59E0B), Color(0xFF22C55E), Color(0xFFEF4444),
  ];

  @override
  void initState() {
    super.initState();
    WeatherService.fetchAccra().then((w) {
      if (mounted) setState(() => _weather = w);
    });
    final plan = widget.initialPlan;
    if (plan != null) {
      _editingPlanId = plan.id;
      _currentStep = 3;
      for (final s in plan.stops) {
        _itinerary.add(_PlaceData.fromStop(s));
      }
      for (var i = 0; i < plan.friendNames.length; i++) {
        final name = plan.friendNames[i];
        final parts = name.trim().split(' ');
        final initials = parts.length >= 2
            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
            : name.substring(0, name.length.clamp(0, 2)).toUpperCase();
        _invitedFriends.add(_FriendData(
          id: 'restored_$i',
          name: name,
          initials: initials,
          color: _avatarColors[i % _avatarColors.length],
        ));
      }
    }
  }

  static const _vibes = [
    _VibeData(icon: Icons.apps_rounded, label: 'All'),
    _VibeData(icon: Icons.self_improvement_rounded, label: 'Chill'),
    _VibeData(icon: Icons.directions_run_rounded, label: 'Active'),
    _VibeData(icon: Icons.family_restroom_rounded, label: 'Family'),
    _VibeData(icon: Icons.favorite_border_rounded, label: 'Date'),
  ];

  static const _vibeCategories = <int, Set<String>>{
    1: {'beach', 'park', 'restaurant', 'cafe', 'nature', 'leisure'},
    2: {'beach', 'park', 'arcade', 'sports', 'nature', 'attraction'},
    3: {'park', 'museum', 'beach', 'arcade', 'attraction', 'shopping'},
    4: {'restaurant', 'cafe', 'beach', 'nightlife', 'rooftop', 'leisure'},
  };

  List<_PlaceData> get _filteredSuggestions {
    if (_selectedVibe <= 0) return _suggestions;
    final allowed = _vibeCategories[_selectedVibe];
    if (allowed == null) return _suggestions;
    final filtered = _suggestions
        .where((p) => allowed.contains(p.category.toLowerCase()))
        .toList();
    return filtered.isEmpty ? _suggestions : filtered;
  }

  static const _suggestions = [
    _PlaceData(
      emoji: '🏖️',
      color: Color(0xFF00C2CC),
      name: 'Labadi Beach',
      category: 'Beach',
      distance: '3.2 km',
      rating: 4.7,
      badge: 'Perfect today',
      badgeIcon: Icons.wb_sunny_rounded,
      badgeColor: Color(0xFFFFA726),
    ),
    _PlaceData(
      emoji: '🕹️',
      color: Color(0xFF7C3AED),
      name: 'GameZone Osu',
      category: 'Arcade',
      distance: '1.8 km',
      rating: 4.5,
      badge: 'Indoor · any weather',
      badgeIcon: Icons.bolt_rounded,
      badgeColor: Color(0xFF7C3AED),
    ),
    _PlaceData(
      emoji: '🌿',
      color: Color(0xFF22C55E),
      name: 'Aburi Botanical Garden',
      category: 'Park',
      distance: '38 km',
      rating: 4.4,
      badge: 'Great today',
      badgeIcon: Icons.check_circle_rounded,
      badgeColor: Color(0xFF22C55E),
    ),
    _PlaceData(
      emoji: '🍽️',
      color: Color(0xFFF59E0B),
      name: 'Santoku Restaurant',
      category: 'Restaurant',
      distance: '2.1 km',
      rating: 4.6,
      badge: 'Food stop',
      badgeIcon: Icons.restaurant_rounded,
      badgeColor: Color(0xFFE91E8C),
    ),
  ];

  void _toggle(_PlaceData place) {
    setState(() {
      if (_itinerary.contains(place)) {
        _itinerary.remove(place);
        if (_itinerary.isEmpty) _currentStep = 1;
      } else {
        _itinerary.add(place);
        if (_currentStep < 2) _currentStep = 2;
      }
    });
  }

  void _advanceToStep3() => setState(() => _currentStep = 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1825),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeatherBanner(),
                  _buildVibeSection(),
                  _buildSuggestedPlaces(),
                  _buildItinerary(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            children: [
              Row(
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
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Plan an Outing',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Step $_currentStep of 3',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Step progress
              Row(
                children: [
                  _StepBubble(number: 1, label: 'Pick\nplaces', active: _currentStep >= 1),
                  _StepLine(active: _currentStep >= 2),
                  _StepBubble(number: 2, label: 'Set\ntimes', active: _currentStep >= 2),
                  _StepLine(active: _currentStep >= 3),
                  _StepBubble(number: 3, label: 'Invite\n& save', active: _currentStep >= 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Weather banner ────────────────────────────────────────────────────────

  Widget _buildWeatherBanner() {
    final isOutdoor = _weather?.isOutdoorFriendly ?? true;
    final dotColor = isOutdoor ? const Color(0xFFFFA726) : const Color(0xFF4A90D9);
    final textColor = isOutdoor ? const Color(0xFF92610A) : const Color(0xFF1E4A7A);
    final bgColor = isOutdoor ? const Color(0xFFFFFBEB) : const Color(0xFFEFF6FF);
    final borderColor = isOutdoor ? const Color(0xFFFFE082) : const Color(0xFFBFDBFE);
    final text = _weather == null
        ? 'Loading weather…'
        : _weather!.bannerText;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Vibe section ──────────────────────────────────────────────────────────

  Widget _buildVibeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'CHOOSE A VIBE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 1.3,
            ),
          ),
        ),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _vibes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final selected = _selectedVibe == i;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedVibe = selected ? -1 : i),
                child: Container(
                  width: 66,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF00C2CC).withValues(alpha: 0.12)
                        : const Color(0xFF162030),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF00C2CC)
                          : const Color(0xFF243447),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _vibes[i].icon,
                        size: 22,
                        color: selected
                            ? const Color(0xFF00C2CC)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _vibes[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? const Color(0xFF00C2CC)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Suggested places ──────────────────────────────────────────────────────

  Widget _buildSuggestedPlaces() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'SUGGESTED PLACES — TAP TO ADD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 1.3,
            ),
          ),
        ),
        ..._filteredSuggestions.map((place) => _PlaceCard(
              place: place,
              added: _itinerary.contains(place),
              onTap: () => _toggle(place),
            )),
      ],
    );
  }

  // ── Itinerary ─────────────────────────────────────────────────────────────

  Future<void> _pickTime(BuildContext context, _PlaceData place) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _stopTimes[place] ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _stopTimes[place] = picked);
  }

  Future<void> _pickDate(BuildContext context, _PlaceData place) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _stopDates[place] ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _stopDates[place] = picked);
  }

  Widget _buildItinerary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              const Text(
                'Your Itinerary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C2CC).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF00C2CC).withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${_itinerary.length} stop${_itinerary.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00C2CC),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_itinerary.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF162030),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF243447)),
            ),
            child: const Column(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 34, color: Color(0xFF374151)),
                SizedBox(height: 12),
                Text(
                  'Tap any place above to add it to your plan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _itinerary.asMap().entries.map((e) {
                final place = e.value;
                final time = _stopTimes[place];
                final date = _stopDates[place];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF162030),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF243447)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Stop header ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFA726),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                place.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                _itinerary.remove(place);
                                _stopTimes.remove(place);
                                _stopDates.remove(place);
                              }),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF374151),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(Icons.close_rounded,
                                    size: 14, color: Color(0xFF9CA3AF)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Divider ──────────────────────────────────────
                      const Divider(
                          height: 1, color: Color(0xFF243447), indent: 14, endIndent: 14),
                      // ── Planning fields ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _PlanFieldButton(
                                    icon: Icons.access_time_rounded,
                                    label: time != null
                                        ? time.format(context)
                                        : 'Set time',
                                    active: time != null,
                                    onTap: () => _pickTime(context, place),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _PlanFieldButton(
                                    icon: Icons.calendar_month_outlined,
                                    label: date != null
                                        ? '${date.day}/${date.month}/${date.year}'
                                        : 'Set date',
                                    active: date != null,
                                    onTap: () => _pickDate(context, place),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _PlanFieldButton(
                              icon: Icons.person_add_alt_1_rounded,
                              label: 'Invite friends to this stop',
                              active: false,
                              onTap: () {},
                              fullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        if (_currentStep == 2 && _itinerary.isNotEmpty) _buildContinueButton(),
        if (_currentStep >= 3) _buildInviteFriends(),
      ],
    );
  }

  // ── Continue to step 3 ───────────────────────────────────────────────────

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GestureDetector(
        onTap: _advanceToStep3,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF00C2CC).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF00C2CC).withValues(alpha: 0.45),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue to Invite & Save',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00C2CC),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded,
                  color: Color(0xFF00C2CC), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Invite friends ────────────────────────────────────────────────────────

  Future<void> _pickContacts() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF162030),
          title: const Text('Contacts access needed',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          content: const Text(
            'Contacts access was denied. Go to Settings → Apps → DayOut → Permissions and enable Contacts.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                  style: TextStyle(color: Color(0xFF00C2CC))),
            ),
          ],
        ),
      );
      return;
    }
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    if (!mounted) return;

    final selectedIds = _invitedFriends.map((f) => f.id).toSet();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF162030),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ContactPickerSheet(
        contacts: contacts,
        selectedIds: selectedIds,
        avatarColors: _avatarColors,
        onDone: (picked) {
          setState(() {
            _invitedFriends.clear();
            _invitedFriends.addAll(picked);
          });
        },
      ),
    );
  }

  Widget _buildInviteFriends() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INVITE FRIENDS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ..._invitedFriends.map((f) => GestureDetector(
                    onTap: () => setState(() => _invitedFriends.remove(f)),
                    child: Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: f.color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              f.initials,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 9, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )),
              GestureDetector(
                onTap: _pickContacts,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00C2CC).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_alt_1_rounded,
                          size: 16, color: Color(0xFF00C2CC)),
                      SizedBox(width: 6),
                      Text(
                        'Add from contacts',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF00C2CC)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Save plan ─────────────────────────────────────────────────────────────

  Future<void> _savePlan(BuildContext context) async {
    final nameController = TextEditingController(
      text: _itinerary.isNotEmpty ? '${_itinerary.first.name.split(' ').first} Outing' : 'My Plan',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF162030),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name your plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Give this outing a memorable name.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D3D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF243447)),
                ),
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Beach Saturday',
                    hintStyle: TextStyle(color: Color(0xFF6B7280)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF243447),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('Cancel',
                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF004D52), Color(0xFF00C2CC)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('Save',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
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
    );

    if (confirmed == true && context.mounted) {
      final name = nameController.text.trim().isEmpty
          ? 'My Plan'
          : nameController.text.trim();

      final plan = SavedPlan(
        id: _editingPlanId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: widget.initialPlan?.createdAt ?? DateTime.now(),
        stops: _itinerary
            .map((p) => StopInfo(
                  name: p.name,
                  color: p.color,
                  emoji: p.emoji,
                  category: p.category,
                ))
            .toList(),
        friendInitials: _invitedFriends.map((f) => f.initials).toList(),
        friendNames: _invitedFriends.map((f) => f.name).toList(),
      );
      if (_editingPlanId != null) {
        PlanStore.update(plan);
      } else {
        PlanStore.add(plan);
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SavePlanScreen()),
      );
    }
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final canSave = _itinerary.isNotEmpty && _currentStep >= 3;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1825),
        border: Border(top: BorderSide(color: Color(0xFF162030))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: canSave ? () => _savePlan(context) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 50,
                        decoration: BoxDecoration(
                          color: canSave
                              ? const Color(0xFF00C2CC)
                              : const Color(0xFF162030),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_rounded,
                              size: 18,
                              color: canSave
                                  ? Colors.white
                                  : const Color(0xFF374151),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Save Plan Offline',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: canSave
                                    ? Colors.white
                                    : const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 10),
                  // Container(
                  //   width: 50,
                  //   height: 50,
                  //   decoration: BoxDecoration(
                  //     color:
                  //         const Color(0xFF00C2CC).withValues(alpha: 0.12),
                  //     shape: BoxShape.circle,
                  //     border: Border.all(
                  //         color: const Color(0xFF00C2CC)
                  //             .withValues(alpha: 0.4)),
                  //   ),
                    // child: const Icon(
                    //   Icons.arrow_downward_rounded,
                    //   color: Color(0xFF00C2CC),
                    //   size: 20,
                    // ),
                  
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canSave
                        ? Icons.check_circle_outline_rounded
                        : Icons.info_outline_rounded,
                    size: 14,
                    color: const Color(0xFF00C2CC),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    canSave
                        ? 'Plan will be saved offline — accessible without WiFi'
                        : _itinerary.isEmpty
                            ? 'Add at least one stop to continue'
                            : _currentStep == 2
                                ? 'Tap "Continue to Invite & Save" to reach Step 3'
                                : 'Add at least one stop to save the plan',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _FriendData {
  final String id;
  final String name;
  final String initials;
  final Color color;
  const _FriendData({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
  });
}

class _VibeData {
  final IconData icon;
  final String label;
  const _VibeData({required this.icon, required this.label});
}

class _PlaceData {
  final String emoji;
  final Color color;
  final String name;
  final String category;
  final String distance;
  final double rating;
  final String badge;
  final IconData badgeIcon;
  final Color badgeColor;

  const _PlaceData({
    required this.emoji,
    required this.color,
    required this.name,
    required this.category,
    required this.distance,
    required this.rating,
    required this.badge,
    required this.badgeIcon,
    required this.badgeColor,
  });

  static _PlaceData fromStop(StopInfo s) => _PlaceData(
        emoji: s.emoji,
        color: s.color,
        name: s.name,
        category: s.category,
        distance: '',
        rating: 4.0,
        badge: 'Saved stop',
        badgeIcon: Icons.bookmark_rounded,
        badgeColor: s.color,
      );
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _PlanFieldButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool fullWidth;

  const _PlanFieldButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00C2CC).withValues(alpha: 0.1)
              : const Color(0xFF1E2D3D),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? const Color(0xFF00C2CC).withValues(alpha: 0.5)
                : const Color(0xFF2E3D4E),
          ),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: fullWidth
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 15,
              color: active
                  ? const Color(0xFF00C2CC)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active
                    ? const Color(0xFF00C2CC)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBubble extends StatelessWidget {
  final int number;
  final String label;
  final bool active;

  const _StepBubble({
    required this.number,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: active
                    ? const Color(0xFF004D52)
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 22),
        color: active
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.2),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final _PlaceData place;
  final bool added;
  final VoidCallback onTap;

  const _PlaceCard({
    required this.place,
    required this.added,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF162030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: added
              ? const Color(0xFF00C2CC).withValues(alpha: 0.5)
              : const Color(0xFF243447),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: place.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(place.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '${place.category} · ${place.distance}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.star_rounded,
                            size: 12, color: Color(0xFFFFA726)),
                        const SizedBox(width: 2),
                        Text(
                          place.rating.toString(),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(place.badgeIcon,
                            size: 12, color: place.badgeColor),
                        const SizedBox(width: 4),
                        Text(
                          place.badge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: place.badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Add / added button
              GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: added
                        ? const Color(0xFF00C2CC).withValues(alpha: 0.15)
                        : const Color(0xFF243447),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: added
                          ? const Color(0xFF00C2CC)
                          : const Color(0xFF374151),
                    ),
                  ),
                  child: Icon(
                    added ? Icons.check_rounded : Icons.add_rounded,
                    size: 18,
                    color: added
                        ? const Color(0xFF00C2CC)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
          // ── Action buttons ─────────────────────────────────────────
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFF1E2D3D)),
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
                        gradientColors: [
                          place.color.withValues(alpha: 0.6),
                          place.color,
                        ],
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
                          gradientColors: [
                            place.color.withValues(alpha: 0.6),
                            place.color,
                          ],
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
    );
  }
}

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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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

// ── Contact picker bottom sheet ───────────────────────────────────────────────

class _ContactPickerSheet extends StatefulWidget {
  final List<Contact> contacts;
  final Set<String> selectedIds;
  final List<Color> avatarColors;
  final void Function(List<_FriendData>) onDone;

  const _ContactPickerSheet({
    required this.contacts,
    required this.selectedIds,
    required this.avatarColors,
    required this.onDone,
  });

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  late Set<String> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedIds);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  List<Contact> get _filtered {
    if (_query.isEmpty) return widget.contacts;
    final q = _query.toLowerCase();
    return widget.contacts
        .where((c) => c.displayName.toLowerCase().contains(q))
        .toList();
  }

  void _done() {
    final colors = widget.avatarColors;
    final friends = <_FriendData>[];
    var colorIndex = 0;
    for (final c in widget.contacts) {
      if (_selected.contains(c.id)) {
        friends.add(_FriendData(
          id: c.id,
          name: c.displayName,
          initials: _initials(c.displayName),
          color: colors[colorIndex % colors.length],
        ));
        colorIndex++;
      }
    }
    widget.onDone(friends);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Choose friends',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _done,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF004D52), Color(0xFF00C2CC)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Done${_selected.isNotEmpty ? ' (${_selected.length})' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E2D3D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF243447)),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search contacts…',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Color(0xFF6B7280), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No contacts found',
                        style: TextStyle(color: Color(0xFF6B7280))))
                : ListView.builder(
                    controller: controller,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final c = _filtered[i];
                      final selected = _selected.contains(c.id);
                      final initials = _initials(c.displayName);
                      final color = widget.avatarColors[
                          c.id.hashCode.abs() % widget.avatarColors.length];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          c.displayName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        trailing: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? const Color(0xFF00C2CC)
                                : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF00C2CC)
                                  : const Color(0xFF374151),
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check_rounded,
                                  size: 13, color: Colors.white)
                              : null,
                        ),
                        onTap: () => setState(() {
                          if (selected) {
                            _selected.remove(c.id);
                          } else {
                            _selected.add(c.id);
                          }
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
