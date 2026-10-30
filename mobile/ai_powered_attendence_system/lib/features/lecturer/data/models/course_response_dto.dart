import 'course_timetable_entry_response_dto.dart';

//! Course Response DTO

class CourseResponseDto {
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

  const CourseResponseDto({
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
  });

  factory CourseResponseDto.fromJson(Map<String, dynamic> json) {
    return CourseResponseDto(
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
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'courseCode': courseCode,
        'description': description,
        'semester': semester,
        'imagePath': imagePath,
        'enrollmentMode': enrollmentMode,
        'lecturerId': lecturerId,
        'createdAtUtc': createdAtUtc.toIso8601String(),
        'timetable': timetable.map((e) => e.toJson()).toList(),
      };
}

