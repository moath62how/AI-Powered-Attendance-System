//! Create Course Timetable Entry Request DTO

class CreateCourseTimetableEntryRequestDto {
  final String day;
  final String startTime;
  final String endTime;

  const CreateCourseTimetableEntryRequestDto({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
      };
}

