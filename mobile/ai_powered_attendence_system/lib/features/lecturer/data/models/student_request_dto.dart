//! Student Request DTOs

enum RequestType { enrollment, deviceChange, attendanceCorrection }

enum RequestStatus { pending, approved, declined }

class StudentRequestDto {
  final String id;
  final String studentName;
  final String studentId;
  final String initials;
  final RequestType type;
  final RequestStatus status;
  final String timeAgo;
  final String primaryInfo;
  final String secondaryInfo;
  final String courseInfo;

  const StudentRequestDto({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.initials,
    required this.type,
    required this.status,
    required this.timeAgo,
    required this.primaryInfo,
    required this.secondaryInfo,
    required this.courseInfo,
  });

  factory StudentRequestDto.fromJson(Map<String, dynamic> json) =>
      StudentRequestDto(
        id: (json['id'] ?? '').toString(),
        studentName: (json['studentName'] ?? '').toString(),
        studentId: (json['studentId'] ?? '').toString(),
        initials: (json['initials'] ?? '').toString(),
        type: _parseType(json['type']?.toString() ?? ''),
        status: _parseStatus(json['status']?.toString() ?? ''),
        timeAgo: (json['timeAgo'] ?? '').toString(),
        primaryInfo: (json['primaryInfo'] ?? '').toString(),
        secondaryInfo: (json['secondaryInfo'] ?? '').toString(),
        courseInfo: (json['courseInfo'] ?? '').toString(),
      );

  static RequestType _parseType(String raw) {
    switch (raw) {
      case 'deviceChange':
        return RequestType.deviceChange;
      case 'attendanceCorrection':
        return RequestType.attendanceCorrection;
      default:
        return RequestType.enrollment;
    }
  }

  static RequestStatus _parseStatus(String raw) {
    switch (raw) {
      case 'approved':
        return RequestStatus.approved;
      case 'declined':
        return RequestStatus.declined;
      default:
        return RequestStatus.pending;
    }
  }
}

