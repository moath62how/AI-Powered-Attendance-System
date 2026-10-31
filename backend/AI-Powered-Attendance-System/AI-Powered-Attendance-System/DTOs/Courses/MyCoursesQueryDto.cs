namespace AI_Powered_Attendance_System.DTOs.Courses
{
    public class MyCoursesQueryDto
    {
        public string? AcademicYear { get; set; }

        public int Page { get; set; } = 1;

        public int PageSize { get; set; } = 10;
    }
}