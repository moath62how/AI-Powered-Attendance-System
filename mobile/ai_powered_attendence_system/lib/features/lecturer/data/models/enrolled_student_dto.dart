//! Enrolled Student DTO

class EnrolledStudentDto {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? studentId;

  const EnrolledStudentDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.studentId,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory EnrolledStudentDto.fromJson(Map<String, dynamic> json) {
    return EnrolledStudentDto(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      studentId: json['studentId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (studentId != null) 'studentId': studentId,
      };
}

