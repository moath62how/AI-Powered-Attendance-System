import 'dart:io';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/network/api_config.dart';

/// Allows self-signed local development certificates (e.g., ASP.NET Core dev-certs)
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = DevHttpOverrides();
  await ApiConfig.init();
  runApp(const AttendifyApp());
}
