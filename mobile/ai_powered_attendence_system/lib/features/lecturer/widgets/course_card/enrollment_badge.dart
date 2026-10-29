import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/course_models.dart';

//! Enrollment Badge

class EnrollmentBadge extends StatelessWidget {
  final EnrollmentStatus status;

  const EnrollmentBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isOpen = status == EnrollmentStatus.open;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFE6F0ED) : Colors.black.withValues(alpha: 0.07),
        border: isOpen
            ? Border.all(color: const Color(0xFF487F6E), width: 1)
            : null,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isOpen ? const Color(0xFF006143) : AppColors.textSecondary,
        ),
      ),
    );
  }
}

