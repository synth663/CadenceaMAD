import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class ApiClient {
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  final http.Client _http;

  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  Future<http.Response> get(
    String path, {
    bool authenticated = false,
    Map<String, String?> queryParameters = const {},
  }) {
    return _send(
      'GET',
      path,
      authenticated: authenticated,
      queryParameters: queryParameters,
    );
  }

  Future<http.Response> postJson(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = false,
    Map<String, String?> queryParameters = const {},
  }) {
    return _send(
      'POST',
      path,
      authenticated: authenticated,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<bool> hasAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey) != null;
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  Future<void> saveTokens(Map<String, dynamic>? tokens) async {
    if (tokens == null) return;

    final prefs = await SharedPreferences.getInstance();
    final access = tokens['access'];
    final refresh = tokens['refresh'];

    if (access is String && access.isNotEmpty) {
      await prefs.setString(accessTokenKey, access);
    }
    if (refresh is String && refresh.isNotEmpty) {
      await prefs.setString(refreshTokenKey, refresh);
    }
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
  }

  Future<bool> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(refreshTokenKey);
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final response = await _http
          .post(
            ApiConfig.uri('/auth/token/refresh/'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refresh}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          await saveTokens(decoded);
          return decoded['access'] is String;
        }
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }

    await clearTokens();
    return false;
  }

  Future<http.Response> _send(
    String method,
    String path, {
    bool authenticated = false,
    Map<String, String?> queryParameters = const {},
    Map<String, dynamic>? body,
  }) async {
    final response = await _sendRaw(
      method,
      path,
      authenticated: authenticated,
      queryParameters: queryParameters,
      body: body,
    );

    if (authenticated && response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        return _sendRaw(
          method,
          path,
          authenticated: true,
          queryParameters: queryParameters,
          body: body,
        );
      }
    }

    return response;
  }

  Future<http.Response> _sendRaw(
    String method,
    String path, {
    bool authenticated = false,
    Map<String, String?> queryParameters = const {},
    Map<String, dynamic>? body,
  }) async {
    final headers = <String, String>{};

    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }

    if (authenticated) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(accessTokenKey);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final uri = ApiConfig.uri(path, queryParameters: queryParameters);
    final encodedBody = body == null ? null : jsonEncode(body);

    switch (method) {
      case 'GET':
        return _http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 10));
      case 'POST':
        return _http
            .post(uri, headers: headers, body: encodedBody)
            .timeout(const Duration(seconds: 10));
      default:
        throw UnsupportedError('Unsupported HTTP method: $method');
    }
  }
}
