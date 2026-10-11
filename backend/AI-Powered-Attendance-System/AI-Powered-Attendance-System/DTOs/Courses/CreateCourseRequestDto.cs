
using Microsoft.AspNetCore.Http;

namespace AI_Powered_Attendance_System.DTOs.Courses
{
    public class CreateCourseRequestDto
    {
        public string CourseName { get; set; } = string.Empty;

        public string CourseCode { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        public string Semester { get; set; } = string.Empty;

        public IFormFile? Image { get; set; }
    }
}
