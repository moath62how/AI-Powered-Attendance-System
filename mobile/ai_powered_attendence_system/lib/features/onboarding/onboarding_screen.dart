import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../auth/login_screen.dart';
import 'models/onboarding_page_data.dart';
import 'widgets/dots_indicator.dart';
import 'widgets/next_button.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <OnboardingPageData>[
    OnboardingPageData(
      title: 'Attendance made\nsimple',
      description:
          'Track your attendance automatically and stay on top of your university classes.',
      type: OnboardingIllustrationType.checkIn,
    ),
    OnboardingPageData(
      title: 'Your attendance,\nautomatically tracked',
      description: 'Attendify detects your presence in class using proximity technology and records your attendance securely.',
      type: OnboardingIllustrationType.proximity,
    ),
    OnboardingPageData(
      title: 'Never lose track of\nyour attendance',
      description: 'View your attendance percentage, class history, absences, and academic attendance insights in one place.',
      type: OnboardingIllustrationType.stats,
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      _navigateToAuth();
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    }
  }

  void _navigateToAuth() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
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
          children: [
            // Page View
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => OnboardingPage(data: _pages[i]),
            ),

            // Top indicator & bottom next button overlay
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kOnboardingMaxContentWidth),
                  child: Stack(
                    children: [
                      if (!_isLast)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                            child: TextButton(
                              onPressed: _navigateToAuth,
                              child: Text(
                                'Skip',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Color.fromARGB(255, 77, 76, 76),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 24, 0),
                          child: DotsIndicator(count: _pages.length, index: _index),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 24, 24),
                          child: OnboardingNextButton(
                            label: _isLast ? 'get started!' : 'Next',
                            progress: (_index + 1) / _pages.length,
                            onTap: _next,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
