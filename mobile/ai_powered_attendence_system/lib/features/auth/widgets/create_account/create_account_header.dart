import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Header for Create Account screen displaying category badge, title, and subtitle
class CreateAccountHeader extends StatelessWidget {
  const CreateAccountHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UNIVERSITY ACCESS',
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w500,
            color: AppColors.badgeText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Create your\naccount',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            height: 1.10,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Use your university credentials to get started',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
