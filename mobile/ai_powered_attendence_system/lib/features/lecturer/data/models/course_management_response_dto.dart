import 'course_timetable_entry_response_dto.dart';
import 'enrolled_student_dto.dart';

//! Course Management Response DTO

class CourseManagementResponseDto {
  final String id;
  final String courseName;
  final String courseCode;
  final String description;
  final String semester;
  final String imagePath;
  final String enrollmentMode;
  final String lecturerId;
  final DateTime createdAtUtc;
  final List<CourseTimetableEntryResponseDto> timetable;
  final int enrolledStudentsCount;
  final List<EnrolledStudentDto> enrolledStudents;

  const CourseManagementResponseDto({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.description,
    required this.semester,
    required this.imagePath,
    required this.enrollmentMode,
    required this.lecturerId,
    required this.createdAtUtc,
    this.timetable = const [],
    this.enrolledStudentsCount = 0,
    this.enrolledStudents = const [],
  });

  factory CourseManagementResponseDto.fromJson(Map<String, dynamic> json) {
    return CourseManagementResponseDto(
      id: (json['id'] ?? '').toString(),
      courseName: (json['courseName'] ?? '').toString(),
      courseCode: (json['courseCode'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      semester: (json['semester'] ?? '').toString(),
      imagePath: (json['imagePath'] ?? '').toString(),
      enrollmentMode: (json['enrollmentMode'] ?? 'Closed').toString(),
      lecturerId: (json['lecturerId'] ?? '').toString(),
      createdAtUtc: json['createdAtUtc'] != null
          ? DateTime.tryParse(json['createdAtUtc'].toString()) ?? DateTime.now()
          : DateTime.now(),
      timetable: (json['timetable'] as List? ?? [])
          .map((e) => CourseTimetableEntryResponseDto.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      enrolledStudentsCount:
          (json['enrolledStudentsCount'] as num?)?.toInt() ?? 0,
      enrolledStudents: (json['enrolledStudents'] as List? ?? [])
          .map((e) => EnrolledStudentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

