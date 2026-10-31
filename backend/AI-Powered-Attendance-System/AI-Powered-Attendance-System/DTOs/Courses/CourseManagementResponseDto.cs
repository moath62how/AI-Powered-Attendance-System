using AI_Powered_Attendance_System.DTOs.Timetable;

namespace AI_Powered_Attendance_System.DTOs.Courses
{
    public class CourseManagementResponseDto
    {
        public Guid Id { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Semester { get; set; } = string.Empty;
        public string? ImagePath { get; set; }
        public string EnrollmentMode { get; set; } = string.Empty;
        public Guid LecturerId { get; set; }
        public DateTime CreatedAtUtc { get; set; }

        public List<CourseTimetableEntryResponseDto> Timetable { get; set; } = new();

        public int EnrolledStudentsCount { get; set; }
        public List<EnrolledStudentDto> EnrolledStudents { get; set; } = new();
    }
}