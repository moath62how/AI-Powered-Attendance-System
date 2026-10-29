import 'course_response_dto.dart';
import 'enrollment_status.dart';
import 'prerequisite.dart';

//! Course UI DTO

class CourseDto {
  final String id;
  final String name;
  final String code;
  final String department;
  final String description;
  final List<Prerequisite> prerequisites;
  final EnrollmentStatus enrollmentStatus;
  final int studentCount;
  final double avgAttendance;
  final String scheduleTime;
  final String scheduleDay;
  final String hall;
  final String? imagePath;

  const CourseDto({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
    required this.description,
    required this.prerequisites,
    required this.enrollmentStatus,
    required this.studentCount,
    required this.avgAttendance,
    required this.scheduleTime,
    required this.scheduleDay,
    required this.hall,
    this.imagePath,
  });

  factory CourseDto.fromResponse(CourseResponseDto dto) {
    final firstEntry = dto.timetable.isNotEmpty ? dto.timetable.first : null;
    return CourseDto(
      id: dto.id,
      name: dto.courseName,
      code: dto.courseCode,
      department: 'CS',
      description: dto.description,
      prerequisites: const [],
      enrollmentStatus:
          EnrollmentStatusExtension.fromBackend(dto.enrollmentMode),
      studentCount: 0,
      avgAttendance: 0,
      scheduleTime: firstEntry != null
          ? '${firstEntry.startTime} - ${firstEntry.endTime}'
          : '09:00 AM',
      scheduleDay: firstEntry?.day ?? 'Sunday',
      hall: 'Hall A',
      imagePath: dto.imagePath,
    );
  }

  factory CourseDto.fromJson(Map<String, dynamic> json) => CourseDto(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        code: (json['code'] ?? '').toString(),
        department: (json['department'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        prerequisites: (json['prerequisites'] as List? ?? [])
            .map((e) => Prerequisite.fromJson(e as Map<String, dynamic>))
            .toList(),
        enrollmentStatus:
            (json['enrollmentStatus']?.toString() ?? '') == 'Closed'
                ? EnrollmentStatus.closed
                : EnrollmentStatus.open,
        studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
        avgAttendance: (json['avgAttendance'] as num?)?.toDouble() ?? 0.0,
        scheduleTime: (json['scheduleTime'] ?? '').toString(),
        scheduleDay: (json['scheduleDay'] ?? '').toString(),
        hall: (json['hall'] ?? '').toString(),
        imagePath: json['imagePath']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'department': department,
        'description': description,
        'prerequisites': prerequisites.map((e) => e.toJson()).toList(),
        'enrollmentStatus': enrollmentStatus.label,
        'studentCount': studentCount,
        'avgAttendance': avgAttendance,
        'scheduleTime': scheduleTime,
        'scheduleDay': scheduleDay,
        'hall': hall,
        if (imagePath != null) 'imagePath': imagePath,
      };
}

