import 'dart:io';

//! Update Course Request DTO

class UpdateCourseRequestDto {
  final String? courseName;
  final String? courseCode;
  final String? description;
  final String? semester;
  final String? enrollmentMode;
  final File? image;
  final String? imagePath;

  const UpdateCourseRequestDto({
    this.courseName,
    this.courseCode,
    this.description,
    this.semester,
    this.enrollmentMode,
    this.image,
    this.imagePath,
  });
}

