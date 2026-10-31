namespace AI_Powered_Attendance_System.DTOs.Courses
{
    public class CourseListItemDto
    {
        public Guid Id { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string CourseCode { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Semester { get; set; } = string.Empty;
        public string AcademicYear { get; set; } = string.Empty;
        public string? ImagePath { get; set; }
        public string EnrollmentMode { get; set; } = string.Empty;
        public int EnrolledStudentsCount { get; set; }
        public DateTime CreatedAtUtc { get; set; }
    }
}