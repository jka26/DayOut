import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _contentController;

  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  // Individual float offsets for each icon
  final List<double> _phaseOffsets = [0, 0.4, 0.8, 1.2, 0.6, 1.0, 0.2, 1.4];

  final List<_ActivityIcon> _icons = [
    _ActivityIcon('🎡', const Offset(-0.85, -0.55), 56),
    _ActivityIcon('🍕', const Offset(0.80, -0.60), 50),
    _ActivityIcon('🏖️', const Offset(-0.75, 0.10), 48),
    _ActivityIcon('🎮', const Offset(0.78, 0.08), 52),
    _ActivityIcon('🍦', const Offset(-0.55, 0.65), 44),
    _ActivityIcon('⛺', const Offset(0.55, 0.62), 46),
    _ActivityIcon('🎭', const Offset(-0.20, -0.78), 42),
    _ActivityIcon('🥗', const Offset(0.22, 0.82), 44),
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001F22),
              Color(0xFF003D42),
              Color(0xFF005F66),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Floating activity icons around the screen
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Stack(
                  children: List.generate(_icons.length, (i) {
                    final icon = _icons[i];
                    final phase = _phaseOffsets[i];
                    final floatY = math.sin(
                          (_floatController.value * 2 * math.pi) + phase,
                        ) *
                        10;
                    final floatX = math.cos(
                          (_floatController.value * 2 * math.pi * 0.6) + phase,
                        ) *
                        5;

                    return Positioned(
                      left: (size.width / 2) +
                          (icon.alignment.dx * size.width / 2) +
                          floatX -
                          icon.size / 2,
                      top: (size.height / 2) +
                          (icon.alignment.dy * size.height / 2) +
                          floatY -
                          icon.size / 2,
                      child: Opacity(
                        opacity: 0.75,
                        child: Text(
                          icon.emoji,
                          style: TextStyle(fontSize: icon.size.toDouble()),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),

            // Frosted center content
            FadeTransition(
              opacity: _contentOpacity,
              child: SlideTransition(
                position: _contentSlide,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 36,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      const Text('📍', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 8),
                      const Text(
                        'DayOut',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tagline
                      Text(
                        'Plan an outing!',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Sign Up button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SignUpScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2CC),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
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
    );
  }
}

class _ActivityIcon {
  final String emoji;
  final Offset alignment;
  final int size;

  const _ActivityIcon(this.emoji, this.alignment, this.size);
}