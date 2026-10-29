import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/course_models.dart';

//! Prerequisite Chip

class PrerequisiteChip extends StatelessWidget {
  final Prerequisite prerequisite;
  final VoidCallback onRemove;
  final Color backgroundColor;

  const PrerequisiteChip({
    super.key,
    required this.prerequisite,
    required this.onRemove,
    this.backgroundColor = const Color(0xFFE3EFF2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prerequisite.courseCode.isEmpty ? 'Course' : prerequisite.courseCode,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF002E20),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFF002E20),
            ),
          ),
        ],
      ),
    );
  }
}

//! Add Course Chip Button

class AddCourseChipButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddCourseChipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1F6854), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              size: 14,
              color: Color(0xFF1F6854),
            ),
            const SizedBox(width: 4),
            Text(
              'add course',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1F6854),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
