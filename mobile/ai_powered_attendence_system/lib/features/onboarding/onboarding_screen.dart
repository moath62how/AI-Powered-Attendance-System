import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../widgets/attendify_logo.dart';
import '../../widgets/splash_atmosphere.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      tag: 'Smart university attendance',
      title: 'Attendance made simple',
      description:
          'Track your attendance automatically and stay on top of your university classes.',
      buttonText: 'Next',
    ),
    _OnboardingData(
      tag: 'Smart university attendance',
      title: 'Your attendance,\nautomatically tracked',
      description:
          'Attendify detects your presence in class using proximity technology and records your attendance securely.',
      buttonText: 'Next',
    ),
    _OnboardingData(
      tag: 'Smart university attendance',
      title: 'Never lose track of your attendance',
      description:
          'View your attendance percentage, class history, absences, and academic attendance insights in one place.',
      buttonText: 'Get Started!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _navigateToAuth() {
    // Navigate to Login/Auth screen placeholder or target screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Login...'),
        duration: Duration(seconds: 2),
      ),
    );
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
        backgroundColor: AppColors.backgroundCream,
        body: Stack(
          children: [
            const SplashAtmosphere(),
            SafeArea(
              child: Column(
                children: [
                  // Top bar with Skip button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AttendifyLogo(markSize: 32, showWordmark: false),
                        if (_currentPage < _pages.length - 1)
                          TextButton(
                            onPressed: _navigateToAuth,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 36),
                      ],
                    ),
                  ),

                  // Carousel
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _OnboardingPageView(
                          pageIndex: index,
                          data: _pages[index],
                        );
                      },
                    ),
                  ),

                  // Bottom bar with indicators and Next button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.ink
                                    : AppColors.cardBorder,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _onNextPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _pages[_currentPage].buttonText,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String tag;
  final String title;
  final String description;
  final String buttonText;

  const _OnboardingData({
    required this.tag,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final int pageIndex;
  final _OnboardingData data;

  const _OnboardingPageView({
    required this.pageIndex,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),

          // Illustration Card Area matching Figma frame nodes
          Center(
            child: _buildIllustrationCard(pageIndex),
          ),

          const Spacer(),

          // Tagline pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.badgeBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              data.tag,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.badgeText,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Main Headline
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIllustrationCard(int index) {
    switch (index) {
      case 0:
        return const _CourseCheckInCard();
      case 1:
        return const _ProximityRadarCard();
      case 2:
      default:
        return const _AttendanceRateCard();
    }
  }
}

/// Slide 1 Illustration Card: Course Check-In Card
class _CourseCheckInCard extends StatelessWidget {
  const _CourseCheckInCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const AttendifyLogo(markSize: 34, showWordmark: false),
              const SizedBox(width: 10),
              Text(
                'Attendify',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundCream,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Computer Networks',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.checkedInBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.checkedInGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Checked in',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.checkedInGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Just now',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Slide 2 Illustration Card: Proximity Detection Radar Card
class _ProximityRadarCard extends StatelessWidget {
  const _ProximityRadarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radar pulse rings
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glowMint.withValues(alpha: 0.3),
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glowLavender.withValues(alpha: 0.5),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ink,
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

/// Slide 3 Illustration Card: Attendance Rate Card (87%)
class _AttendanceRateCard extends StatelessWidget {
  const _AttendanceRateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glowYellow,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                '87%',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Overall Attendance',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '26 of 30 lectures attended',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.87,
                    minHeight: 6,
                    backgroundColor: AppColors.cardBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
