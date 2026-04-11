import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'landing_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();

    _passwordCtrl.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final p = _passwordCtrl.text;
    int strength = 0;
    if (p.length >= 6) strength++;
    if (p.length >= 10) strength++;
    if (p.contains(RegExp(r'[0-9]'))) strength++;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) strength++;
    setState(() => _passwordStrength = strength);
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 1: return 'Weak';
      case 2: return 'Fair — add numbers or symbols';
      case 3: return 'Good';
      case 4: return 'Strong 💪';
      default: return '';
    }
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 1: return const Color(0xFFE53935);
      case 2: return const Color(0xFFFFB300);
      case 3: return const Color(0xFF00C2CC);
      case 4: return const Color(0xFF00897B);
      default: return Colors.grey.shade200;
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate auth delay — replace with real auth logic
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LandingScreen()),
      );
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Eyebrow
                        Text(
                          'GET STARTED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00E5FF).withOpacity(0.8),
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Headline
                        const Text(
                          'Create your\nDayOut account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          'Your first outing starts here 🎉',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── White card ───────────────────────────────────────
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5FEFF),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(24, 32, 24, 40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email
                              const _FieldLabel(label: 'Email address'),
                              const SizedBox(height: 10),
                              _InputField(
                                controller: _emailCtrl,
                                hint: 'you@example.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Email is required';
                                  if (!v.contains('@'))
                                    return 'Enter a valid email';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Password
                              const _FieldLabel(label: 'Password'),
                              const SizedBox(height: 10),
                              _InputField(
                                controller: _passwordCtrl,
                                hint: 'Create a password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: !_passwordVisible,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() =>
                                      _passwordVisible = !_passwordVisible),
                                  child: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey.shade400,
                                    size: 18,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Password is required';
                                  if (v.length < 6)
                                    return 'Minimum 6 characters';
                                  return null;
                                },
                              ),

                              // Password strength bar
                              if (_passwordCtrl.text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: List.generate(4, (i) {
                                    return Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: i < 3 ? 4 : 0),
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: i < _passwordStrength
                                              ? _strengthColor
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _strengthLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _strengthColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Confirm password
                              const _FieldLabel(label: 'Confirm password'),
                              const SizedBox(height: 10),
                              _InputField(
                                controller: _confirmPasswordCtrl,
                                hint: 'Re-enter your password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: !_confirmPasswordVisible,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() =>
                                      _confirmPasswordVisible =
                                          !_confirmPasswordVisible),
                                  child: Icon(
                                    _confirmPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey.shade400,
                                    size: 18,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Please confirm your password';
                                  if (v != _passwordCtrl.text)
                                    return 'Passwords do not match';
                                  return null;
                                },
                              ),

                              // Error banner
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 16),
                                _ErrorBanner(message: _errorMessage!),
                              ],

                              const SizedBox(height: 28),

                              // Create account button
                              _CreateAccountButton(
                                isLoading: _isLoading,
                                onTap: _handleSignUp,
                              ),

                              const SizedBox(height: 28),

                              // Sign in redirect
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _goToLogin,
                                    child: const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF00A8B0),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
        letterSpacing: 0.2,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF00C2CC)),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 40),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00C2CC), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE53935), width: 2),
        ),
      ),
    );
  }
}

class _CreateAccountButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _CreateAccountButton({required this.isLoading, required this.onTap});

  @override
  State<_CreateAccountButton> createState() => _CreateAccountButtonState();
}

class _CreateAccountButtonState extends State<_CreateAccountButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C2CC), Color(0xFF00E5FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C2CC).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFE53935).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFE53935), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}