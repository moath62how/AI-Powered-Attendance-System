import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../auth/login_screen.dart';

/// Maximum content width for tablet / large screen constraints
const double _kMaxContentWidth = 520;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <_PageData>[
    _PageData(
      title: 'Attendance made\nsimple',
      description:
          'Track your attendance automatically and stay on top of your university classes.',
      type: _Illustration.checkIn,
    ),
    _PageData(
      title: 'Your attendance,\nautomatically tracked',
      description:
          'Attendify detects your presence in class using proximity technology and records your attendance securely.',
      type: _Illustration.proximity,
    ),
    _PageData(
      title: 'Never lose track of\nyour attendance',
      description:
          'View your attendance percentage, class history, absences, and academic attendance insights in one place.',
      type: _Illustration.stats,
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
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _navigateToAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Page View
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
            ),

            // Top indicator & bottom next button overlay
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 24, 0),
                          child: _DotsIndicator(
                            count: _pages.length,
                            index: _index,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 24, 24),
                          child: _NextButton(
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

// ═════════════════ Page Data Model ═════════════════

enum _Illustration { checkIn, proximity, stats }

class _PageData {
  final String title;
  final String description;
  final _Illustration type;

  const _PageData({
    required this.title,
    required this.description,
    required this.type,
  });
}

// ═════════════════ Single Onboarding Page ═════════════════

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    // Relative sizes for responsive typography & components
    final titleSize = (w * 0.075).clamp(24.0, 34.0);
    final descSize = (w * 0.032).clamp(12.0, 15.0);

    return Stack(
      children: [
        // Atmosphere Background Blobs sampled from Figma frames (Node 143:65)
        ..._buildBackgroundBlobs(data.type, size, w),

        // Foreground Content
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Illustration fitting top area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 56, bottom: 16),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _buildIllustration(),
                          ),
                        ),
                      ),
                    ),

                    // Page Header Text & Body
                    Text(
                      'SMART UNIVERSITY ATTENDANCE',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.title,
                      style: GoogleFonts.inter(
                        fontSize: titleSize,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.description,
                      style: GoogleFonts.inter(
                        fontSize: descSize,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // Spacing for bottom action button
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBackgroundBlobs(_Illustration type, Size size, double w) {
    final blobSize = (w * 0.85).clamp(240.0, 480.0);

    switch (type) {
      case _Illustration.checkIn:
        return [
          Positioned(
            top: size.height * 0.05,
            left: -blobSize * 0.25,
            child: _Blob(color: AppColors.yellow, size: blobSize),
          ),
          Positioned(
            top: size.height * 0.12,
            right: -blobSize * 0.25,
            child: _Blob(color: AppColors.pink, size: blobSize * 1.1),
          ),
          Positioned(
            top: size.height * 0.35,
            right: -blobSize * 0.20,
            child: _Blob(color: AppColors.blue, size: blobSize * 0.9),
          ),
        ];
      case _Illustration.proximity:
        return [
          Positioned(
            top: size.height * 0.08,
            left: -blobSize * 0.25,
            child: _Blob(color: AppColors.blue, size: blobSize * 1.1),
          ),
          Positioned(
            top: size.height * 0.15,
            right: -blobSize * 0.20,
            child: _Blob(color: AppColors.pink, size: blobSize),
          ),
          Positioned(
            top: size.height * 0.38,
            right: -blobSize * 0.25,
            child: _Blob(color: AppColors.glowLavender, size: blobSize),
          ),
        ];
      case _Illustration.stats:
        return [
          Positioned(
            top: size.height * 0.06,
            left: -blobSize * 0.20,
            child: _Blob(color: AppColors.glowLavender, size: blobSize * 1.1),
          ),
          Positioned(
            top: size.height * 0.18,
            right: -blobSize * 0.25,
            child: _Blob(color: AppColors.yellow, size: blobSize),
          ),
          Positioned(
            top: size.height * 0.40,
            right: -blobSize * 0.20,
            child: _Blob(color: AppColors.lightGreen, size: blobSize * 0.9),
          ),
        ];
    }
  }

  Widget _buildIllustration() {
    switch (data.type) {
      case _Illustration.checkIn:
        return const _CheckInIllustration();
      case _Illustration.proximity:
        return const _ProximityIllustration();
      case _Illustration.stats:
        return const _StatsIllustration();
    }
  }
}

// ═════════════════ Illustrations ═════════════════

/// Page 1: Rotated "Checked in" Card
class _CheckInIllustration extends StatelessWidget {
  const _CheckInIllustration();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.07,
      child: Container(
        width: 270,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: _glassCard(),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFDDD6F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Computer Networks',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Checked in',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFFD5EBDD),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 13, color: AppColors.trueColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page 2: Concentric Proximity Radar Rings with User Icon
class _ProximityIllustration extends StatelessWidget {
  const _ProximityIllustration();

  @override
  Widget build(BuildContext context) {
    Widget ring(double size) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          ),
        );

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ring(250),
          ring(175),
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          Positioned(
            top: 28,
            right: 6,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFBEFB0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on_outlined, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 3: Attendance Statistics Card (87% Circular Progress & Bars)
class _StatsIllustration extends StatelessWidget {
  const _StatsIllustration();

  @override
  Widget build(BuildContext context) {
    Widget bar(Color color, double widthFactor) => Container(
          height: 7,
          width: 100 * widthFactor,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );

    return Transform.rotate(
      angle: -0.09,
      child: Container(
        width: 270,
        height: 160,
        padding: const EdgeInsets.all(22),
        decoration: _glassCard(),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 84,
                    height: 84,
                    child: CircularProgressIndicator(
                      value: 0.87,
                      strokeWidth: 9,
                      color: Color(0xFFDAD3F6),
                      backgroundColor: Color(0xFFEFEBFA),
                    ),
                  ),
                  Text(
                    '87%',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(const Color(0xFFE6E4E0), 1.0),
                  const SizedBox(height: 12),
                  bar(const Color(0xFFF6E48E), 0.75),
                  const SizedBox(height: 12),
                  bar(const Color(0xFFCDE3F3), 0.9),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _glassCard() => BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.95),
          const Color(0xFFFBF7EA).withValues(alpha: 0.9),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ],
    );

// ═════════════════ Shared Components ═════════════════

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.55),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;
  const _DotsIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(left: 4),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.ink : const Color(0xFFD5D3CE),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final double progress;
  final VoidCallback onTap;

  const _NextButton({
    required this.label,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 350),
                  builder: (context, value, child) => SizedBox(
                    width: 46,
                    height: 46,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 2,
                      color: AppColors.ink,
                      backgroundColor: AppColors.cardBorder,
                    ),
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: AppColors.textPrimary,
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
