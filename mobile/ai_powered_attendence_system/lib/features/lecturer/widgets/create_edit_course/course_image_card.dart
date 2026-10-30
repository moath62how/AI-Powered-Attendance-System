import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

//! Course Image Picker Card

class CourseImageCard extends StatelessWidget {
  final File? imageFile;
  final String? initialImageUrl;
  final VoidCallback onPickImage;

  const CourseImageCard({
    super.key,
    this.imageFile,
    this.initialImageUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = imageFile != null;
    final hasInitialUrl = initialImageUrl != null && initialImageUrl!.isNotEmpty;
    final hasImage = hasFile || hasInitialUrl;

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEBEBEB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 67,
              height: 62,
              child: _buildImageContent(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Course Image',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onPickImage,
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 20,
                        color: Color(0xFF487F6E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Add a cover image for this course',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (hasImage) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4F1EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: Color(0xFF43B57B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Uploaded',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF43B57B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    GestureDetector(
                      onTap: onPickImage,
                      child: Text(
                        hasImage ? 'Change image' : 'Upload image',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3B3B3B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    if (initialImageUrl != null && initialImageUrl!.isNotEmpty) {
      if (initialImageUrl!.startsWith('http://') ||
          initialImageUrl!.startsWith('https://')) {
        return Image.network(
          initialImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
      return Image.asset(
        initialImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF0F4F2),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFF9EABA4),
          size: 28,
        ),
      ),
    );
  }
}
