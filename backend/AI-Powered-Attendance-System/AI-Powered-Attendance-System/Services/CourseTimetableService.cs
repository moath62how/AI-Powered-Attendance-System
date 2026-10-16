using AI_Powered_Attendance_System.Data;
using AI_Powered_Attendance_System.DTOs.Timetable;
using AI_Powered_Attendance_System.Entities;
using AI_Powered_Attendance_System.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace AI_Powered_Attendance_System.Services
{
    public class CourseTimetableService : ICourseTimetableService
    {
        private readonly AppDbContext _db;
        public CourseTimetableService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<CourseTimetableEntryResponseDto?> CreateAsync(
            Guid lecturerId,
            Guid courseId,
            CreateCourseTimetableEntryRequestDto request,
            CancellationToken cancellationToken = default)
        {
            var courseExists = await _db.Courses
                .AnyAsync(
                    c => c.Id == courseId &&
                         c.LecturerId == lecturerId,
                    cancellationToken);

            if (!courseExists)
                return null;

            var (day, startTime, endTime) = GetScheduleDetails(request);

            await EnsureNoConflictAsync(
                courseId,
                day,
                startTime,
                endTime,
                null,
                cancellationToken);

            var now = DateTime.UtcNow;

            var entry = new CourseTimetableEntry
            {
                Id = Guid.NewGuid(),
                CourseId = courseId,
                Day = day,
                StartTime = startTime,
                EndTime = endTime,
                CreatedAtUtc = now,
                UpdatedAtUtc = now
            };

            _db.CourseTimetableEntries.Add(entry);

            await _db.SaveChangesAsync(cancellationToken);

            return ToResponseDto(entry);
        }

        public async Task<CourseTimetableEntryResponseDto?> UpdateAsync(
            Guid lecturerId,
            Guid courseId,
            Guid entryId,
            CreateCourseTimetableEntryRequestDto request,
            CancellationToken cancellationToken = default)
        {
            var entry = await _db.CourseTimetableEntries
                .FirstOrDefaultAsync(
                    t => t.Id == entryId &&
                         t.CourseId == courseId &&
                         t.Course.LecturerId == lecturerId,
                    cancellationToken);

            if (entry is null)
                return null;

            var (day, startTime, endTime) = GetScheduleDetails(request);

            await EnsureNoConflictAsync(
                courseId,
                day,
                startTime,
                endTime,
                entryId,
                cancellationToken);

            entry.Day = day;
            entry.StartTime = startTime;
            entry.EndTime = endTime;
            entry.UpdatedAtUtc = DateTime.UtcNow;

            await _db.SaveChangesAsync(cancellationToken);

            return ToResponseDto(entry);
        }

        public async Task<bool> DeleteAsync(
            Guid lecturerId,
            Guid courseId,
            Guid entryId,
            CancellationToken cancellationToken = default)
        {
            var entry = await _db.CourseTimetableEntries
                .FirstOrDefaultAsync(
                    t => t.Id == entryId &&
                         t.CourseId == courseId &&
                         t.Course.LecturerId == lecturerId,
                    cancellationToken);

            if (entry is null)
                return false;

            _db.CourseTimetableEntries.Remove(entry);

            await _db.SaveChangesAsync(cancellationToken);

            return true;
        }

        public async Task<IReadOnlyList<CourseTimetableEntryResponseDto>?> GetByCourseAsync(
            Guid lecturerId,
            Guid courseId,
            CancellationToken cancellationToken = default)
        {
            var courseExists = await _db.Courses
                .AnyAsync(
                    c => c.Id == courseId &&
                         c.LecturerId == lecturerId,
                    cancellationToken);

            if (!courseExists)
                return null;

            var entries = await _db.CourseTimetableEntries
                .Where(t => t.CourseId == courseId)
                .OrderBy(t => ((int)t.Day + 6) % 7)
                .ThenBy(t => t.StartTime)
                .ToListAsync(cancellationToken);

            return entries
                .Select(ToResponseDto)
                .ToList();
        }

        private async Task EnsureNoConflictAsync(
            Guid courseId,
            DayOfWeek day,
            TimeOnly startTime,
            TimeOnly endTime,
            Guid? excludedEntryId,
            CancellationToken cancellationToken)
        {
            var conflictExists = await _db.CourseTimetableEntries
                .AnyAsync(
                    t => t.CourseId == courseId &&
                         t.Day == day &&
                         (!excludedEntryId.HasValue ||
                          t.Id != excludedEntryId.Value) &&
                         t.StartTime < endTime &&
                         t.EndTime > startTime,
                    cancellationToken);

            if (conflictExists)
            {
                throw new ConflictException(
                    "This timetable entry overlaps an existing entry for the course.");
            }
        }

        private static (
            DayOfWeek Day,
            TimeOnly StartTime,
            TimeOnly EndTime) GetScheduleDetails(
                CreateCourseTimetableEntryRequestDto request)
        {
            var dayText = request.Day?.Trim();

            if (string.IsNullOrWhiteSpace(dayText) ||
                !Enum.GetNames<DayOfWeek>().Contains(
                    dayText,
                    StringComparer.OrdinalIgnoreCase) ||
                !Enum.TryParse<DayOfWeek>(
                    dayText,
                    true,
                    out var day))
            {
                throw new ArgumentException(
                    "Day must be a valid day of the week.");
            }

            if (!request.StartTime.HasValue ||
                !request.EndTime.HasValue ||
                request.StartTime.Value >= request.EndTime.Value)
            {
                throw new ArgumentException(
                    "Start time must be earlier than end time.");
            }

            return (
                day,
                request.StartTime.Value,
                request.EndTime.Value);
        }

        private static CourseTimetableEntryResponseDto ToResponseDto(
            CourseTimetableEntry entry)
        {
            return new CourseTimetableEntryResponseDto
            {
                Id = entry.Id,
                CourseId = entry.CourseId,
                Day = entry.Day.ToString(),
                StartTime = entry.StartTime,
                EndTime = entry.EndTime,
                CreatedAtUtc = entry.CreatedAtUtc,
                UpdatedAtUtc = entry.UpdatedAtUtc
            };
        }
    }
}