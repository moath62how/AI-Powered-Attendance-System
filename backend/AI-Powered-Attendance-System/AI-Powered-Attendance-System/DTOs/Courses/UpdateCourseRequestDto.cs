using Microsoft.AspNetCore.Http;

namespace AI_Powered_Attendance_System.DTOs.Courses
{
    public class UpdateCourseRequestDto
    {
        public string? CourseName { get; set; }

        public string? CourseCode { get; set; }

        public string? Description { get; set; }

        public string? Semester { get; set; }

        // "AutoApprove" or "Closed"
        public string? EnrollmentMode { get; set; }

        // If omitted, the existing cover photo is kept unchanged.
        public IFormFile? Image { get; set; }
    }
}