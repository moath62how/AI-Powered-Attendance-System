import 'package:flutter/material.dart';

import '../features/splash/splash_screen.dart';
import 'theme/app_theme.dart';

class AttendifyApp extends StatelessWidget {
  const AttendifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
