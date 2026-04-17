import 'package:flutter/material.dart';
import 'plan_screen.dart';

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
    'Under GH₵50',
    'GH₵50 – 150',
    'GH₵150 – 300',
    'No limit 🤙',
  ];

  bool get _canSubmit =>
      _selectedVibes.isNotEmpty &&
      _selectedTime != null &&
      _selectedBudget != null;

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
                      onTap: _canSubmit ? () {} : null,
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
                        child: Row(
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

  // ── Budget options (single-select list) ──────────────────────────────────

  Widget _buildBudgetOptions() {
    return Column(
      children: List.generate(_budgetOptions.length, (i) {
        final selected = _selectedBudget == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedBudget = i),
          child: _OptionCard(
            label: _budgetOptions[i],
            selected: selected,
            singleSelect: true,
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
                onTap: () {},
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
  final bool singleSelect;

  const _OptionCard({
    required this.label,
    required this.selected,
    this.singleSelect = false,
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
              shape: singleSelect ? BoxShape.circle : BoxShape.rectangle,
              borderRadius:
                  singleSelect ? null : BorderRadius.circular(6),
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
