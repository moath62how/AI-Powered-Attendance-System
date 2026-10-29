import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/token_storage_service.dart';
import '../../widgets/attendify_logo.dart';
import '../../widgets/splash_atmosphere.dart';
import '../lecturer/my_courses_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  void _checkInitialRoute() {
    _timer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final token = await TokenStorageService.getAccessToken();
      final user = await TokenStorageService.getUser();
      if (!mounted) return;

      if (token != null && token.isNotEmpty && user != null) {
        final role = user.role.toLowerCase();
        if (role == 'lecturer' || role == 'teacher') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MyCoursesScreen()),
          );
          return;
        }
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const SplashAtmosphere(),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 11),
                  const AttendifyLogo(),
                  const SizedBox(height: 10),
                  Text(
                    'Smart Attendance, Made Simple',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      letterSpacing: -0.1,
                      color: AppColors.tagline,
                    ),
                  ),
                  const Spacer(flex: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
