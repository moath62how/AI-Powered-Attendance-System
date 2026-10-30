//! Timetable Entry Response DTO

class CourseTimetableEntryResponseDto {
  final String id;
  final String courseId;
  final String day;
  final String startTime;
  final String endTime;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  const CourseTimetableEntryResponseDto({
    required this.id,
    required this.courseId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  factory CourseTimetableEntryResponseDto.fromJson(Map<String, dynamic> json) {
    return CourseTimetableEntryResponseDto(
      id: (json['id'] ?? '').toString(),
      courseId: (json['courseId'] ?? '').toString(),
      day: (json['day'] ?? '').toString(),
      startTime: (json['startTime'] ?? '').toString(),
      endTime: (json['endTime'] ?? '').toString(),
      createdAtUtc: json['createdAtUtc'] != null
          ? DateTime.tryParse(json['createdAtUtc'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAtUtc: json['updatedAtUtc'] != null
          ? DateTime.tryParse(json['updatedAtUtc'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
        'createdAtUtc': createdAtUtc.toIso8601String(),
        'updatedAtUtc': updatedAtUtc.toIso8601String(),
      };
}

