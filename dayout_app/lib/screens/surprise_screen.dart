import 'package:flutter/material.dart';
import '../services/surprise_planner.dart';
import 'save_plan_screen.dart';
import 'plan_screen.dart';
import 'surprise_result_screen.dart';

class SurpriseScreen extends StatefulWidget {
  const SurpriseScreen({super.key});

  @override
  State<SurpriseScreen> createState() => _SurpriseScreenState();
}

class _SurpriseScreenState extends State<SurpriseScreen> {
  final Set<int> _selectedVibes = {};
  int? _selectedTime;
  int? _selectedBudget;
  final _extraController = TextEditingController();

  static const _vibeOptions = [
    'Something outdoors & active',
    'Chill with friends at a nice spot',
    'Good food is a must',
    'Family-friendly vibes',
    'Something fun & nostalgic',
    'Budget-friendly day out',
  ];

  static const _timeOptions = [
    ('🌅', 'Morning'),
    ('☀️', 'Midday'),
    ('🌆', 'Evening'),
    ('🌙', 'Night'),
  ];

  static const _budgetOptions = [
    ('💰', 'Budget-Friendly'),
    ('💵', 'Moderate'),
    ('💎', 'No Limit'),
  ];

  bool _loading = false;

  bool get _canSubmit =>
      _selectedVibes.isNotEmpty &&
      _selectedTime != null &&
      _selectedBudget != null;

  Future<void> _generate() async {
    setState(() => _loading = true);
    // Brief delay for effect
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);

    final plan = SurprisePlannerService.generate(
      vibeIndices: _selectedVibes,
      timeIndex: _selectedTime!,
      budgetIndex: _selectedBudget!,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurpriseResultScreen(plan: plan)),
    );
  }

  @override
  void dispose() {
    _extraController.dispose();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    label: 'What sounds good to you?',
                    child: _buildVibeOptions(),
                  ),
                  _buildSection(
                    label: 'When are you heading out?',
                    child: _buildTimeOptions(),
                  ),
                  _buildSection(
                    label: "What's your budget?",
                    child: _buildBudgetOptions(),
                  ),
                  _buildSection(
                    label: 'Anything else?',
                    child: _buildTextInput(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: GestureDetector(
                      onTap: _canSubmit && !_loading ? _generate : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _canSubmit
                              ? const LinearGradient(
                                  colors: [Color(0xFF004D52), Color(0xFF00C2CC)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: _canSubmit ? null : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 18,
                                    color: _canSubmit
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Surprise Me!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _canSubmit
                                          ? Colors.white
                                          : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF004D52), Color(0xFF006B72)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI PLANNER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00C2CC).withValues(alpha: 0.9),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Surprise Me',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tell me what you're feeling — I'll plan the rest.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.star_rounded,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section wrapper ───────────────────────────────────────────────────────

  Widget _buildSection({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // ── Vibe options (multi-select) ───────────────────────────────────────────

  Widget _buildVibeOptions() {
    return Column(
      children: List.generate(_vibeOptions.length, (i) {
        final selected = _selectedVibes.contains(i);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _selectedVibes.remove(i);
            } else {
              _selectedVibes.add(i);
            }
          }),
          child: _OptionCard(
            label: _vibeOptions[i],
            selected: selected,
          ),
        );
      }),
    );
  }

  // ── Time options (single-select, 2×2 grid) ────────────────────────────────

  Widget _buildTimeOptions() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.2,
      children: List.generate(_timeOptions.length, (i) {
        final selected = _selectedTime == i;
        final (emoji, label) = _timeOptions[i];
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF00C2CC)
                    : const Color(0xFFE5E7EB),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF004D52)
                        : const Color(0xFF374151),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle_rounded,
                      size: 14, color: Color(0xFF00C2CC)),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Budget options (3-card row) ───────────────────────────────────────────

  Widget _buildBudgetOptions() {
    return Row(
      children: List.generate(_budgetOptions.length, (i) {
        final (emoji, label) = _budgetOptions[i];
        final selected = _selectedBudget == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedBudget = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: i < _budgetOptions.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? const Color(0xFF00C2CC) : const Color(0xFFE5E7EB),
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: const Color(0xFF00C2CC).withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
                    : [const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? const Color(0xFF004D52) : const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Text input ────────────────────────────────────────────────────────────

  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _extraController,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1A1A2E),
        ),
        decoration: const InputDecoration(
          hintText: 'e.g. we have 4 people, near Accra...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
        maxLines: 3,
        minLines: 2,
      ),
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
                selected: false,
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
                icon: Icons.star_rounded,
                label: 'Surprise',
                selected: true,
                onTap: () {},
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

// ── Shared widgets ────────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final String label;
  final bool selected;

  const _OptionCard({
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              selected ? const Color(0xFF00C2CC) : const Color(0xFFE5E7EB),
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? const Color(0xFF004D52)
                    : const Color(0xFF374151),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(6),
              color: selected
                  ? const Color(0xFF00C2CC)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? const Color(0xFF00C2CC)
                    : const Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
            child: selected
                ? const Icon(Icons.check_rounded,
                    size: 13, color: Colors.white)
                : null,
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
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
