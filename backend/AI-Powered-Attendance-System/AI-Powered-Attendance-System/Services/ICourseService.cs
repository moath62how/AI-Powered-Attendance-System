using AI_Powered_Attendance_System.DTOs.Courses;

namespace AI_Powered_Attendance_System.Services
{
    public interface ICourseService
    {
        Task<CourseResponseDto> CreateAsync(
            CreateCourseRequestDto request,
            Guid lecturerId,
            CancellationToken cancellationToken = default);

        Task<CourseResponseDto?> GetByIdAsync(
            Guid courseId,
            CancellationToken cancellationToken = default);

        Task<CourseResponseDto> UpdateAsync(
            Guid courseId,
            UpdateCourseRequestDto request,
            Guid lecturerId,
            CancellationToken cancellationToken = default);

        Task<bool> DeleteAsync(
            Guid courseId,
            Guid lecturerId,
            CancellationToken cancellationToken = default);

        // Lecturer-only. Full management view: course info, timetable, and enrolled roster.
        Task<CourseManagementResponseDto> GetManagementDetailsAsync(
            Guid courseId,
            Guid lecturerId,
            CancellationToken cancellationToken = default);
    }
}