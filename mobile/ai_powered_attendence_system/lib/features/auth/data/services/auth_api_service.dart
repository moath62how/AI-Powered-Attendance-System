import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../models/auth_models.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class AuthApiService {
  static const Duration _timeout = Duration(seconds: 20);

  //! Helpers

  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> _authHeaders(String accessToken) => {
        ..._jsonHeaders,
        'Authorization': 'Bearer $accessToken',
      };

  static String _url(String path) => '${ApiConfig.baseUrl}/$path';

  static Future<http.Response> _post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(_url(path));
    var res = await http
        .post(
          uri,
          headers: headers ?? _jsonHeaders,
          body: body,
        )
        .timeout(_timeout);

    if ((res.statusCode == 307 || res.statusCode == 308) &&
        res.headers.containsKey('location')) {
      var location = res.headers['location']!;
      try {
        if (Platform.isAndroid) {
          location = location
              .replaceFirst('://localhost:', '://10.0.2.2:')
              .replaceFirst('://127.0.0.1:', '://10.0.2.2:');
        }
      } catch (_) {}

      res = await http
          .post(
            Uri.parse(location),
            headers: headers ?? _jsonHeaders,
            body: body,
          )
          .timeout(_timeout);
    }

    _assertOk(res);
    return res;
  }

  static String _parseError(String body, int statusCode) {
    try {
      final map = jsonDecode(body);
      if (map is Map) {
        if (map.containsKey('errors')) {
          final errors = map['errors'];
          if (errors is Map) {
            final messages = errors.values
                .expand<String>((v) => (v as List).cast<String>())
                .toList();
            if (messages.isNotEmpty) return messages.join(' ');
          }
        }
        final msg = map['detail'] ?? map['title'] ?? map['message'];
        if (msg != null) return msg.toString();
      }
    } catch (_) {}
    return _defaultMessage(statusCode);
  }

  static String _defaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Invalid credentials. Please try again.';
      case 403:
        return 'This account is already bound to another device.';
      case 404:
        return 'Account not found.';
      case 409:
        return 'An account with this email or ID already exists.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong (HTTP $statusCode).';
    }
  }

  static void _assertOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final msg = _parseError(res.body, res.statusCode);
    throw ApiException(statusCode: res.statusCode, message: msg);
  }

  //! Endpoints

  static Future<UserDto> register(RegisterRequestDto request) async {
    final res = await _post(
      'auth/register',
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return UserDto.fromJson(body);
  }

  static Future<AuthResponseDto> login(LoginRequestDto request) async {
    final res = await _post(
      'auth/login',
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthResponseDto.fromJson(body);
  }

  static Future<void> forgotPassword(ForgotPasswordRequestDto request) async {
    await _post(
      'auth/forgot-password',
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );
  }

  static Future<void> resetPasswordWithCode(
    ResetPasswordWithCodeRequestDto request,
  ) async {
    await _post(
      'auth/reset-password-with-code',
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );
  }

  static Future<AuthResponseDto> refresh(
    RefreshTokenRequestDto request,
  ) async {
    final res = await _post(
      'auth/refresh',
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthResponseDto.fromJson(body);
  }

  static Future<void> unlinkDevice({
    required String accessToken,
    required String password,
  }) async {
    await _post(
      'auth/unlink-device',
      headers: _authHeaders(accessToken),
      body: jsonEncode({'password': password}),
    );
  }
}
