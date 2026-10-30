import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_colors.dart';
import '../data/models/course_models.dart';
import 'requests/avatar_initials.dart';
import 'requests/request_action_button.dart';

//! Request Card

class RequestCard extends StatelessWidget {
  final StudentRequestDto request;
  final String acceptLabel;
  final VoidCallback? onAccept;
  final String declineLabel;
  final VoidCallback? onDecline;

  const RequestCard({
    super.key,
    required this.request,
    required this.acceptLabel,
    required this.declineLabel,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentRow(),
          const SizedBox(height: 8),
          _buildInfoRows(),
          const SizedBox(height: 12),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStudentRow() {
    return Row(
      children: [
        AvatarInitials(initials: request.initials),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.studentName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    request.timeAgo,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                request.studentId,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRows() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.courseInfo,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          request.primaryInfo,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        if (request.secondaryInfo.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            request.secondaryInfo,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: RequestActionButton(
            label: declineLabel,
            isPrimary: false,
            onTap: onDecline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RequestActionButton(
            label: acceptLabel,
            isPrimary: true,
            onTap: onAccept,
          ),
        ),
      ],
    );
  }
}
