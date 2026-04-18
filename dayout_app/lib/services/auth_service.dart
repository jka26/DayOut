import 'api_service.dart';

/// Result returned by [AuthService.register] and [AuthService.login].
class AuthResult {
  final bool success;
  final String? token;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthResult({
    required this.success,
    this.token,
    this.user,
    this.error,
  });
}

/// Authentication service — wraps the DayOut `/auth` endpoints.
class AuthService {
  AuthService._();

  /// Register a new account. Returns [AuthResult] with token + user on success.
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('auth/register.php', {
      'name': name,
      'email': email,
      'password': password,
    });

    if (response.containsKey('error')) {
      return AuthResult(success: false, error: response['error'] as String?);
    }

    final token = response['token'] as String?;
    final user = response['user'] as Map<String, dynamic>?;

    if (token == null) {
      return const AuthResult(success: false, error: 'Unexpected response from server');
    }

    await ApiService.setToken(token);

    return AuthResult(success: true, token: token, user: user);
  }

  /// Log in with existing credentials. Saves the JWT token on success.
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('auth/login.php', {
      'email': email,
      'password': password,
    });

    if (response.containsKey('error')) {
      return AuthResult(success: false, error: response['error'] as String?);
    }

    final token = response['token'] as String?;
    final user = response['user'] as Map<String, dynamic>?;

    if (token == null) {
      return const AuthResult(success: false, error: 'Unexpected response from server');
    }

    await ApiService.setToken(token);

    return AuthResult(success: true, token: token, user: user);
  }

  /// Clear the stored JWT token (log out).
  static Future<void> logout() async {
    await ApiService.clearToken();
  }

  /// Fetch the currently authenticated user's profile.
  /// Returns null if unauthenticated or on error.
  static Future<Map<String, dynamic>?> me() async {
    final response = await ApiService.get('auth/me.php');

    if (response.containsKey('error')) {
      return null;
    }

    return response['user'] as Map<String, dynamic>?;
  }
}
