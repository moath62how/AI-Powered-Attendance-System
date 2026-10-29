import 'dart:io';

//! Create Course Request DTO

class CreateCourseRequestDto {
  final String courseName;
  final String courseCode;
  final String description;
  final String semester;
  final File? image;
  final String? imagePath;

  const CreateCourseRequestDto({
    required this.courseName,
    required this.courseCode,
    required this.description,
    required this.semester,
    this.image,
    this.imagePath,
  });
}

