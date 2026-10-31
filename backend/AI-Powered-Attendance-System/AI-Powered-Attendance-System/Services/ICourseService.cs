using AI_Powered_Attendance_System.DTOs.Common;
using AI_Powered_Attendance_System.DTOs.Courses;
using AI_Powered_Attendance_System.Entities;

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

        Task<CourseManagementResponseDto> GetManagementDetailsAsync(
            Guid courseId,
            Guid lecturerId,
            CancellationToken cancellationToken = default);

        // Lecturer's own courses, optionally filtered by academic year, paginated.
        Task<PagedResultDto<CourseListItemDto>> GetMyCoursesAsync(
            Guid lecturerId,
            AcademicYear? academicYear,
            int page,
            int pageSize,
            CancellationToken cancellationToken = default);
    }
}