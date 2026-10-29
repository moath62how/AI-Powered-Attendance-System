//! Prerequisite Model

class Prerequisite {
  final String courseCode;
  final String minimumGrade;

  const Prerequisite({
    required this.courseCode,
    required this.minimumGrade,
  });

  factory Prerequisite.fromJson(Map<String, dynamic> json) => Prerequisite(
        courseCode: (json['courseCode'] ?? '').toString(),
        minimumGrade: (json['minimumGrade'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'courseCode': courseCode,
        'minimumGrade': minimumGrade,
      };
}

