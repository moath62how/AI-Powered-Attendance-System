using AI_Powered_Attendance_System.Data;
using AI_Powered_Attendance_System.DTOs.Courses;
using AI_Powered_Attendance_System.DTOs.Timetable;
using AI_Powered_Attendance_System.Entities;
using AI_Powered_Attendance_System.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace AI_Powered_Attendance_System.Services
{
    public class CourseService : ICourseService
    {
        private readonly AppDbContext _db;
        private readonly IWebHostEnvironment _environment;

        public CourseService(
            AppDbContext db,
            IWebHostEnvironment environment)
        {
            _db = db;
            _environment = environment;
        }

        public async Task<CourseResponseDto> CreateAsync(
            CreateCourseRequestDto request,
            Guid lecturerId,
            CancellationToken cancellationToken = default)
        {
            var lecturer = await _db.Users
                .FirstOrDefaultAsync(
                    u => u.Id == lecturerId,
                    cancellationToken);


            if (lecturer is null ||
                lecturer.Role != UserRole.Lecturer)
            {
                throw new ForbiddenException(
                    "Only lecturers can create courses.");
            }

            var courseCode = request.CourseCode.Trim().ToUpperInvariant();

            var courseExists = await _db.Courses
                .AnyAsync(
                    c => c.CourseCode == courseCode,
                    cancellationToken);

            if (courseExists)
            {
                throw new ConflictException(
                    "A course with this code already exists.");
            }

            var image = request.Image!;

            var extension = image.ContentType switch
            {
                "image/jpeg" => ".jpg",
                "image/png" => ".png",
                _ => throw new ArgumentException(
                    "Only JPG and PNG images are allowed.")
            };

            var webRootPath = _environment.WebRootPath
                ?? Path.Combine(
                    _environment.ContentRootPath,
                    "wwwroot");

            var uploadFolder = Path.Combine(
                webRootPath,
                "uploads",
                "courses");

            Directory.CreateDirectory(uploadFolder);

            var fileName = $"{Guid.NewGuid()}{extension}";

            var filePath = Path.Combine(
                uploadFolder,
                fileName);

            Course course;
            var now = DateTime.UtcNow;

            await using (var stream = new FileStream(
                filePath,
                FileMode.CreateNew))
            {
                await image.CopyToAsync(
                    stream,
                    cancellationToken);
            }

            course = new Course
            {
                Id = Guid.NewGuid(),
                CourseName = request.CourseName.Trim(),
                CourseCode = courseCode,
                Description = request.Description.Trim(),
                Semester = request.Semester.Trim(),
                ImagePath = $"/uploads/courses/{fileName}",
                LecturerId = lecturerId,
                CreatedAtUtc = now,
                UpdatedAtUtc = now
            };

            _db.Courses.Add(course);

            try
            {
                await _db.SaveChangesAsync(cancellationToken);
            }
            catch (DbUpdateException)
            {

                if (File.Exists(filePath))
                    File.Delete(filePath);

                if (await _db.Courses.AnyAsync(c => c.CourseCode == courseCode, cancellationToken))
                    throw new ConflictException("A course with this code already exists.");

                throw;
            }

            return new CourseResponseDto
            {
                Id = course.Id,
                CourseName = course.CourseName,
                CourseCode = course.CourseCode,
                Description = course.Description,
                Semester = course.Semester,
                ImagePath = course.ImagePath,
                LecturerId = course.LecturerId,
                CreatedAtUtc = course.CreatedAtUtc
            };
        }
            public async Task<CourseResponseDto?> GetByIdAsync(
    Guid courseId,
    CancellationToken cancellationToken = default)
        {
            var course = await _db.Courses
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    c => c.Id == courseId,
                    cancellationToken);

            if (course is null)
                return null;

            var timetable = await _db.CourseTimetableEntries
                .AsNoTracking()
                .Where(t => t.CourseId == courseId)
                .OrderBy(t => ((int)t.Day + 6) % 7)
                .ThenBy(t => t.StartTime)
                .Select(t => new CourseTimetableEntryResponseDto
                {
                    Id = t.Id,
                    CourseId = t.CourseId,
                    Day = t.Day.ToString(),
                    StartTime = t.StartTime,
                    EndTime = t.EndTime,
                    CreatedAtUtc = t.CreatedAtUtc,
                    UpdatedAtUtc = t.UpdatedAtUtc
                })
                .ToListAsync(cancellationToken);

            return new CourseResponseDto
            {
                Id = course.Id,
                CourseName = course.CourseName,
                CourseCode = course.CourseCode,
                Description = course.Description,
                Semester = course.Semester,
                ImagePath = course.ImagePath,
                LecturerId = course.LecturerId,
                CreatedAtUtc = course.CreatedAtUtc,
                Timetable = timetable
            };
        }
        public async Task<bool> DeleteAsync(
    Guid courseId,
    Guid lecturerId,
    CancellationToken cancellationToken = default)
        {
            var course = await _db.Courses
                .FirstOrDefaultAsync(
                    c => c.Id == courseId &&
                         c.LecturerId == lecturerId,
                    cancellationToken);


            if (course is null)
                return false;

            _db.Courses.Remove(course);

            await _db.SaveChangesAsync(cancellationToken);

            return true;
        }
    }
    }
