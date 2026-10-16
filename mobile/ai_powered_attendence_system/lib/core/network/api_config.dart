import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Network configuration for connecting to the backend API.
///
/// Handles mobile emulator loopback routing:
/// - Android Emulator loopback: https://10.0.2.2:7127/api
/// - iOS Simulator / Localhost: https://localhost:7127/api
class ApiConfig {
  static const String _customBaseUrlKey = 'attendify_custom_base_url';
  static const int defaultPort = 7127;
  static const String defaultScheme = 'https';

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return '$defaultScheme://localhost:$defaultPort/api';
    }
    try {
      if (Platform.isAndroid) {
        return '$defaultScheme://10.0.2.2:$defaultPort/api';
      }
    } catch (_) {}
    return '$defaultScheme://localhost:$defaultPort/api';
  }

  static String _currentBaseUrl = defaultBaseUrl;

  static String get baseUrl => _currentBaseUrl;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString(_customBaseUrlKey);
    // If a custom URL is stored and does not refer to the old HTTP 5244 port
    if (custom != null && custom.trim().isNotEmpty && !custom.contains('5244')) {
      _currentBaseUrl = custom.trim();
    } else {
      _currentBaseUrl = defaultBaseUrl;
      if (custom != null && custom.contains('5244')) {
        await prefs.remove(_customBaseUrlKey);
      }
    }
  }

  static Future<void> setBaseUrl(String url) async {
    _currentBaseUrl = url.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customBaseUrlKey, _currentBaseUrl);
  }

  static Future<void> resetToDefault() async {
    _currentBaseUrl = defaultBaseUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customBaseUrlKey);
  }
}
