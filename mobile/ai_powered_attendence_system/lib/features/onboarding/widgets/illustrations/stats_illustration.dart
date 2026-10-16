import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Attendance Statistics Card (87% Circular Progress & Bars) for onboarding slide 3
class StatsIllustration extends StatelessWidget {
  const StatsIllustration({super.key});

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
        decoration: BoxDecoration(
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
        ),
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
