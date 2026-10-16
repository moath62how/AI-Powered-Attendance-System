using AI_Powered_Attendance_System.DTOs.Timetable;

namespace AI_Powered_Attendance_System.Services
{
    public interface ICourseTimetableService
    {
        Task<CourseTimetableEntryResponseDto?> CreateAsync(
      Guid lecturerId,
      Guid courseId,
      CreateCourseTimetableEntryRequestDto request,
      CancellationToken cancellationToken = default);

        Task<CourseTimetableEntryResponseDto?> UpdateAsync(
            Guid lecturerId,
            Guid courseId,
            Guid entryId,
            CreateCourseTimetableEntryRequestDto request,
            CancellationToken cancellationToken = default);

        Task<bool> DeleteAsync(
            Guid lecturerId,
            Guid courseId,
            Guid entryId,
            CancellationToken cancellationToken = default);

        Task<IReadOnlyList<CourseTimetableEntryResponseDto>?> GetByCourseAsync(
            Guid lecturerId,
            Guid courseId,
            CancellationToken cancellationToken = default);
    }
}
