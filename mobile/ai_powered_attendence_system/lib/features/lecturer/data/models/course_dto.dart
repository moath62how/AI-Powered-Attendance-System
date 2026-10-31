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
  final String semester;
  final String academicYear;
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
    required this.semester,
    required this.academicYear,
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
      department: '',
      description: dto.description,
      semester: dto.semester,
      academicYear: '',
      prerequisites: const [],
      enrollmentStatus:
          EnrollmentStatusExtension.fromBackend(dto.enrollmentMode),
      studentCount: 0,
      avgAttendance: 0,
      scheduleTime: firstEntry != null
          ? '${firstEntry.startTime} - ${firstEntry.endTime}'
          : '',
      scheduleDay: firstEntry?.day ?? '',
      hall: '',
      imagePath: dto.imagePath,
    );
  }

  factory CourseDto.fromJson(Map<String, dynamic> json) {
    //! Maps CourseListItemDto (backend) → CourseDto (Flutter)
    //! Backend: courseName, courseCode, enrollmentMode, enrolledStudentsCount, semester, academicYear
    //! Fallback: name, code, enrollmentStatus, studentCount (local/cached format)

    final name         = (json['courseName']   ?? json['name']        ?? '').toString();
    final code         = (json['courseCode']    ?? json['code']        ?? '').toString();
    final department   = (json['department']    ?? '').toString();
    final description  = (json['description']   ?? '').toString();
    final semester     = (json['semester']      ?? '').toString();
    final academicYear = (json['academicYear']  ?? '').toString();
    final imagePath    = json['imagePath']?.toString();

    //! enrolledStudentsCount (backend list-item) → studentCount
    final studentCount =
        (json['enrolledStudentsCount'] as num?)?.toInt() ??
        (json['studentCount']          as num?)?.toInt() ??
        0;

    final avgAttendance = (json['avgAttendance'] as num?)?.toDouble() ?? 0.0;
    final scheduleTime  = (json['scheduleTime']  ?? '').toString();
    final scheduleDay   = (json['scheduleDay']   ?? '').toString();
    final hall          = (json['hall']          ?? '').toString();

    //! enrollmentMode (backend) or enrollmentStatus (local) — case-insensitive
    final rawStatus = (json['enrollmentMode'] ?? json['enrollmentStatus'] ?? '').toString();
    final enrollmentStatus = rawStatus.toLowerCase() == 'closed'
        ? EnrollmentStatus.closed
        : EnrollmentStatus.open;

    final prerequisites = (json['prerequisites'] as List? ?? [])
        .map((e) => Prerequisite.fromJson(e as Map<String, dynamic>))
        .toList();

    return CourseDto(
      id: (json['id'] ?? '').toString(),
      name: name,
      code: code,
      department: department,
      description: description,
      semester: semester,
      academicYear: academicYear,
      prerequisites: prerequisites,
      enrollmentStatus: enrollmentStatus,
      studentCount: studentCount,
      avgAttendance: avgAttendance,
      scheduleTime: scheduleTime,
      scheduleDay: scheduleDay,
      hall: hall,
      imagePath: imagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'department': department,
        'description': description,
        'semester': semester,
        'academicYear': academicYear,
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
