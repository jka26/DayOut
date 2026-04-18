import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _exitController;

  late Animation<double> _ring1Scale;
  late Animation<double> _ring2Scale;
  late Animation<double> _ring3Scale;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Ripple rings
    _ring1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _ring2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    _ring3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Logo pop
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Text slide up
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Exit fade
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ringController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _exitController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    final token = await ApiService.getToken();
    if (mounted) {
      final route = (token != null && token.isNotEmpty) ? '/landing' : '/welcome';
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C2CC),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _ringController,
          _logoController,
          _textController,
          _exitController,
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _exitOpacity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Color(0xFF00E5FF),
                        Color(0xFF00C2CC),
                        Color(0xFF006B73),
                      ],
                    ),
                  ),
                ),

                // Ripple rings
                _buildRing(_ring3Scale.value, 0.06),
                _buildRing(_ring2Scale.value, 0.10),
                _buildRing(_ring1Scale.value, 0.15),

                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo circle
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value.clamp(0.0, 1.0),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '📍',
                              style: TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App name + tagline
                    FadeTransition(
                      opacity: _textOpacity,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            const Text(
                              'DayOut',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Spend your day, your way.',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.85),
                                letterSpacing: 1.5,
                              ),
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
        },
      ),
    );
  }

  Widget _buildRing(double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(opacity),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}