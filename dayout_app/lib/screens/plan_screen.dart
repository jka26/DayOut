import 'package:flutter/material.dart';
import '../models/plan_store.dart';
import 'food_match_screen.dart';
import 'fun_facts_screen.dart';
import 'save_plan_screen.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int _selectedVibe = -1;
  final List<_PlaceData> _itinerary = [];
  final Map<_PlaceData, TimeOfDay?> _stopTimes = {};
  final Map<_PlaceData, DateTime?> _stopDates = {};
  final List<_FriendAvatar> _invitedFriends = [
    _FriendAvatar(initials: 'KA', color: Color(0xFF00C2CC)),
    _FriendAvatar(initials: 'EB', color: Color(0xFFE91E8C)),
  ];

  static const _vibes = [
    _VibeData(icon: Icons.apps_rounded, label: 'All'),
    _VibeData(icon: Icons.self_improvement_rounded, label: 'Chill'),
    _VibeData(icon: Icons.directions_run_rounded, label: 'Active'),
    _VibeData(icon: Icons.family_restroom_rounded, label: 'Family'),
    _VibeData(icon: Icons.favorite_border_rounded, label: 'Date'),
  ];

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
      } else {
        _itinerary.add(place);
      }
    });
  }

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
                    child: const Text(
                      'Step 1 of 3',
                      style: TextStyle(
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
                  _StepBubble(number: 1, label: 'Pick\nplaces', active: true),
                  _StepLine(active: false),
                  _StepBubble(number: 2, label: 'Set\ntimes', active: false),
                  _StepLine(active: false),
                  _StepBubble(
                      number: 3, label: 'Invite\n& save', active: false),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFFA726),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '31°C and sunny — outdoor spots ranked first today',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF92610A),
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
        ..._suggestions.map((place) => _PlaceCard(
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
            child: Column(
              children: const [
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
        if (_itinerary.isNotEmpty) _buildInviteFriends(),
      ],
    );
  }

  // ── Invite friends ────────────────────────────────────────────────────────

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
          Row(
            children: [
              ..._invitedFriends.map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
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
                  )),
              // Add button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF374151),
                    width: 1.5,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: const Icon(Icons.add_rounded,
                    size: 18, color: Color(0xFF6B7280)),
              ),
              const SizedBox(width: 10),
              const Text(
                'Add from contacts',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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

      PlanStore.add(SavedPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: DateTime.now(),
        stops: _itinerary
            .map((p) => StopInfo(name: p.name, color: p.color, emoji: p.emoji))
            .toList(),
        friendInitials: _invitedFriends.map((f) => f.initials).toList(),
      ));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SavePlanScreen()),
      );
    }
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final canSave = _itinerary.isNotEmpty;
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
                  const SizedBox(width: 10),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF00C2CC).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF00C2CC)
                              .withValues(alpha: 0.4)),
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: Color(0xFF00C2CC),
                      size: 20,
                    ),
                  ),
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

class _FriendAvatar {
  final String initials;
  final Color color;
  const _FriendAvatar({required this.initials, required this.color});
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
