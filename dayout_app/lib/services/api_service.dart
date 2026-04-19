import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/env.dart';

/// Base HTTP service for communicating with the DayOut PHP backend.
///
/// Stores and retrieves the JWT token via SharedPreferences.
/// All methods return a [Map<String, dynamic>]; on network failure
/// `{'error': 'Network error'}` is returned.
class ApiService {
  static const _tokenKey = 'auth_token';
  static const _timeout = Duration(seconds: 30);

  // ── Token management ──────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── URL builder ───────────────────────────────────────────────────────────

  static Uri _buildUri(String path) {
    final base = Env.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final cleanPath = path.replaceAll(RegExp(r'^/'), '');
    return Uri.parse('$base/$cleanPath');
  }

  // ── Shared request helper ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await getToken();
      final client = HttpClient();
      client.connectionTimeout = _timeout;

      final uri = _buildUri(path);
      final request = await client.openUrl(method, uri);

      // Headers
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      if (token != null && token.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $token');
      }

      // Body
      if (body != null) {
        final encoded = jsonEncode(body);
        request.contentLength = utf8.encode(encoded).length;
        request.write(encoded);
      }

      final response = await request.close().timeout(_timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      try {
        final raw = jsonDecode(responseBody);
        if (raw is Map<String, dynamic>) {
          return raw;
        }
        return {'data': raw};
      } catch (_) {
        // Server returned non-JSON (HTML error page, redirect, etc.)
        final preview = responseBody.length > 200 ? responseBody.substring(0, 200) : responseBody;
        return {
          'error': 'Non-JSON response (HTTP ${response.statusCode}): $preview',
        };
      }
    } on SocketException catch (e) {
      return {'error': 'Network error: $e'};
    } on HttpException catch (e) {
      return {'error': 'Network error: $e'};
    } on TimeoutException {
      return {'error': 'Request timed out. The server may be starting up — please try again.'};
    } catch (e) {
      return {'error': 'Error: $e'};
    }
  }

  // ── Public HTTP methods ───────────────────────────────────────────────────

  static Future<Map<String, dynamic>> get(String path) =>
      _request('GET', path);

  static Future<Map<String, dynamic>> post(
          String path, Map<String, dynamic> body) =>
      _request('POST', path, body: body);

  static Future<Map<String, dynamic>> put(
          String path, Map<String, dynamic> body) =>
      _request('PUT', path, body: body);

  static Future<Map<String, dynamic>> delete(String path) =>
      _request('DELETE', path);
}
