import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../models/onboarding_page_data.dart';
import 'illustrations/check_in_illustration.dart';
import 'illustrations/proximity_illustration.dart';
import 'illustrations/stats_illustration.dart';

const double kOnboardingMaxContentWidth = 520;

/// Individual page display within the onboarding PageView
class OnboardingPage extends StatefulWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Staggered intervals within the 700 ms controller
  late final Animation<double> _illFade;
  late final Animation<double> _illScale;
  late final Animation<Offset> _labelSlide;
  late final Animation<double> _labelFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _descSlide;
  late final Animation<double> _descFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _buildAnimations();
    _ctrl.forward();
  }

  void _buildAnimations() {
    // Illustration: 0–60 %
    final illCurve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _illFade = Tween<double>(begin: 0.0, end: 1.0).animate(illCurve);
    _illScale = Tween<double>(begin: 0.85, end: 1.0).animate(illCurve);

    // Label: 30–65 %
    final labelCurve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOutCubic),
    );
    _labelFade = Tween<double>(begin: 0.0, end: 1.0).animate(labelCurve);
    _labelSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(labelCurve);

    // Title: 42–78 %
    final titleCurve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.42, 0.78, curve: Curves.easeOutCubic),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(titleCurve);
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(titleCurve);

    // Description: 55–90 %
    final descCurve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
    );
    _descFade = Tween<double>(begin: 0.0, end: 1.0).animate(descCurve);
    _descSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(descCurve);
  }

  @override
  void didUpdateWidget(OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
        ..._buildBackgroundBlobs(widget.data.type, size, w),

        // Foreground Content
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: kOnboardingMaxContentWidth,
              ),
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
                          child: FadeTransition(
                            opacity: _illFade,
                            child: ScaleTransition(
                              scale: _illScale,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: _buildIllustration(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Page Header Text & Body
                    FadeTransition(
                      opacity: _labelFade,
                      child: SlideTransition(
                        position: _labelSlide,
                        child: Text(
                          'SMART UNIVERSITY ATTENDANCE',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          widget.data.title,
                          style: GoogleFonts.inter(
                            fontSize: titleSize,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _descFade,
                      child: SlideTransition(
                        position: _descSlide,
                        child: Text(
                          widget.data.description,
                          style: GoogleFonts.inter(
                            fontSize: descSize,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
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

  List<Widget> _buildBackgroundBlobs(
    OnboardingIllustrationType type,
    Size size,
    double w,
  ) {
    final blobSize = (w * 0.85).clamp(240.0, 480.0);

    switch (type) {
      case OnboardingIllustrationType.checkIn:
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
      case OnboardingIllustrationType.proximity:
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
      case OnboardingIllustrationType.stats:
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
    switch (widget.data.type) {
      case OnboardingIllustrationType.checkIn:
        return const CheckInIllustration();
      case OnboardingIllustrationType.proximity:
        return const ProximityIllustration();
      case OnboardingIllustrationType.stats:
        return const StatsIllustration();
    }
  }
}


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
