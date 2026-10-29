import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/course_models.dart';
import 'prerequisite_row.dart';

//! Prerequisites Section

class PrerequisitesSection extends StatelessWidget {
  final List<Prerequisite> prerequisites;
  final ValueChanged<int> onRemove;
  final VoidCallback onAdd;

  const PrerequisitesSection({
    super.key,
    required this.prerequisites,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prerequisites',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (int i = 0; i < prerequisites.length; i++)
              PrerequisiteChip(
                prerequisite: prerequisites[i],
                backgroundColor: i % 2 == 0
                    ? const Color(0xFFE3EFF2)
                    : const Color(0xFFE3EFE9),
                onRemove: () => onRemove(i),
              ),
            AddCourseChipButton(onTap: onAdd),
          ],
        ),
      ],
    );
  }
}
