import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/course_models.dart';

//! Enrollment Status Card

class EnrollmentStatusCard extends StatelessWidget {
  final EnrollmentStatus currentStatus;
  final ValueChanged<EnrollmentStatus> onStatusChanged;

  const EnrollmentStatusCard({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrollment Status',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _EnrollmentOption(
                  status: EnrollmentStatus.open,
                  isSelected: currentStatus == EnrollmentStatus.open,
                  onTap: () => onStatusChanged(EnrollmentStatus.open),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EnrollmentOption(
                  status: EnrollmentStatus.closed,
                  isSelected: currentStatus == EnrollmentStatus.closed,
                  onTap: () => onStatusChanged(EnrollmentStatus.closed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//! Enrollment Option Item

class _EnrollmentOption extends StatelessWidget {
  final EnrollmentStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _EnrollmentOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.ink : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.ink : const Color(0xFFC2C2C2),
                      width: isSelected ? 5 : 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              status.description,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

