import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

//! Device Service

class DeviceService {
  static const String _deviceIdKey = 'attendify_device_id';
  static String? _cachedDeviceId;

  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null && _cachedDeviceId!.isNotEmpty) {
      return _cachedDeviceId!;
    }

    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString(_deviceIdKey);

    if (storedId == null || storedId.trim().isEmpty) {
      storedId = _generateGuid();
      await prefs.setString(_deviceIdKey, storedId);
    }

    _cachedDeviceId = storedId;
    return storedId;
  }

  static Future<void> setDeviceId(String deviceId) async {
    _cachedDeviceId = deviceId.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, _cachedDeviceId!);
  }

  static Future<String> resetDeviceId() async {
    final newId = _generateGuid();
    _cachedDeviceId = newId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, newId);
    return newId;
  }

  static Future<void> clearDeviceId() async {
    _cachedDeviceId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }

  static String _generateGuid() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));

    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;

    String hex(int byte) => byte.toRadixString(16).padLeft(2, '0');

    return '${values.sublist(0, 4).map(hex).join()}-'
        '${values.sublist(4, 6).map(hex).join()}-'
        '${values.sublist(6, 8).map(hex).join()}-'
        '${values.sublist(8, 10).map(hex).join()}-'
        '${values.sublist(10, 16).map(hex).join()}';
  }
}
