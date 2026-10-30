import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../data/models/course_models.dart';
import 'course_card/course_action_button.dart';
import 'course_card/course_stat_item.dart';
import 'course_card/enrollment_badge.dart';
//! Course Card

class CourseCard extends StatelessWidget {
  final CourseDto course;
  final Color cardColor;
  final VoidCallback? onEdit;
  final VoidCallback? onStudents;

  const CourseCard({
    super.key,
    required this.course,
    required this.cardColor,
    this.onEdit,
    this.onStudents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStats(),
          const SizedBox(height: 14),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${course.code} . ${course.department}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                course.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        EnrollmentBadge(status: course.enrollmentStatus),
      ],
    );
  }

  Widget _buildStats() {
    final avgPct = course.avgAttendance.toStringAsFixed(0);
    final stats = [
      CourseStatItem(value: '${course.studentCount}', label: 'Students'),
      CourseStatItem(value: '$avgPct%', label: 'Avg attendance'),
      CourseStatItem(value: course.scheduleTime, label: course.scheduleDay),
      CourseStatItem(value: course.hall, label: 'Hall'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            stats[i],
            if (i < stats.length - 1) const StatDivider(),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        CourseActionButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          filled: true,
          onTap: onEdit,
        ),
        const SizedBox(width: 10),
        CourseActionButton(
          icon: Icons.people_outline_rounded,
          label: 'Students',
          onTap: onStudents,
        ),
      ],
    );
  }
}
