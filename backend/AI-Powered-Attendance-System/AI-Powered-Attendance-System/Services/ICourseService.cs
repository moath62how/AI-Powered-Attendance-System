using AI_Powered_Attendance_System.DTOs.Courses;

namespace AI_Powered_Attendance_System.Services
{
    public  interface ICourseService
    {
        Task<CourseResponseDto> CreateAsync(
       CreateCourseRequestDto request,
       Guid lecturerId,
       CancellationToken cancellationToken = default);
    }
}
