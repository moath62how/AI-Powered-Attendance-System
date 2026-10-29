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
            var extension = GetExtensionOrThrow(image.ContentType);
            var webRootPath = GetWebRootPath();
            var uploadFolder = Path.Combine(webRootPath, "uploads", "courses");
            Directory.CreateDirectory(uploadFolder);

            var fileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadFolder, fileName);

            await using (var stream = new FileStream(filePath, FileMode.CreateNew))
            {
                await image.CopyToAsync(stream, cancellationToken);
            }

            var now = DateTime.UtcNow;

            var course = new Course
            {
                Id = Guid.NewGuid(),
                CourseName = request.CourseName.Trim(),
                CourseCode = courseCode,
                Description = request.Description.Trim(),
                Semester = request.Semester.Trim(),
                ImagePath = $"/uploads/courses/{fileName}",
                EnrollmentMode = CourseEnrollmentMode.Closed,
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

            return ToDto(course);
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

            var timetable = await GetTimetableAsync(courseId, cancellationToken);

            var dto = ToDto(course);
            dto.Timetable = timetable;
            return dto;
        }

        public async Task<CourseResponseDto> UpdateAsync(
            Guid courseId,
            UpdateCourseRequestDto request,
            Guid lecturerId,
            CancellationToken cancellationToken = default)
        {
            var course = await _db.Courses
                .FirstOrDefaultAsync(c => c.Id == courseId, cancellationToken);

            if (course is null)
                throw new NotFoundException("Course not found.");

            if (course.LecturerId != lecturerId)
                throw new ForbiddenException("You are not allowed to edit this course.");

            var webRootPath = GetWebRootPath();

            string? newCourseCode = null;
            if (request.CourseCode is not null)
            {
                newCourseCode = request.CourseCode.Trim().ToUpperInvariant();

                if (!string.Equals(newCourseCode, course.CourseCode, StringComparison.Ordinal))
                {
                    var codeTaken = await _db.Courses.AnyAsync(
                        c => c.CourseCode == newCourseCode && c.Id != courseId,
                        cancellationToken);

                    if (codeTaken)
                        throw new ConflictException("A course with this code already exists.");
                }
            }

            string? newImagePath = null;
            string? newFilePath = null;

            if (request.Image is not null)
            {
                var extension = GetExtensionOrThrow(request.Image.ContentType);
                var uploadFolder = Path.Combine(webRootPath, "uploads", "courses");
                Directory.CreateDirectory(uploadFolder);

                var fileName = $"{Guid.NewGuid()}{extension}";
                newFilePath = Path.Combine(uploadFolder, fileName);

                await using (var stream = new FileStream(newFilePath, FileMode.CreateNew))
                {
                    await request.Image.CopyToAsync(stream, cancellationToken);
                }

                newImagePath = $"/uploads/courses/{fileName}";
            }

            var oldImagePath = course.ImagePath;

            if (request.CourseName is not null)
                course.CourseName = request.CourseName.Trim();

            if (newCourseCode is not null)
                course.CourseCode = newCourseCode;

            if (request.Description is not null)
                course.Description = request.Description.Trim();

            if (request.Semester is not null)
                course.Semester = request.Semester.Trim();

            if (request.EnrollmentMode is not null)
                course.EnrollmentMode = Enum.Parse<CourseEnrollmentMode>(request.EnrollmentMode, ignoreCase: true);

            if (newImagePath is not null)
                course.ImagePath = newImagePath;

            course.UpdatedAtUtc = DateTime.UtcNow;

            try
            {
                await _db.SaveChangesAsync(cancellationToken);
            }
            catch (DbUpdateException)
            {
                if (newFilePath is not null && File.Exists(newFilePath))
                    File.Delete(newFilePath);

                if (newCourseCode is not null &&
                    await _db.Courses.AnyAsync(c => c.CourseCode == newCourseCode && c.Id != courseId, cancellationToken))
                    throw new ConflictException("A course with this code already exists.");

                throw;
            }

            if (newImagePath is not null)
            {
                var oldFullPath = Path.Combine(
                    webRootPath,
                    oldImagePath.TrimStart('/').Replace('/', Path.DirectorySeparatorChar));

                if (File.Exists(oldFullPath))
                    File.Delete(oldFullPath);
            }

            return ToDto(course);
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

        public async Task<CourseManagementResponseDto> GetManagementDetailsAsync(
            Guid courseId,
            Guid lecturerId,
            CancellationToken cancellationToken = default)
        {
            var course = await _db.Courses
                .AsNoTracking()
                .FirstOrDefaultAsync(c => c.Id == courseId, cancellationToken);

            if (course is null)
                throw new NotFoundException("Course not found.");

            // Ownership check: only the lecturer who owns this course can see its management details.
            if (course.LecturerId != lecturerId)
                throw new ForbiddenException("You are not allowed to view this course's management details.");

            var timetable = await GetTimetableAsync(courseId, cancellationToken);

            var enrolledStudents = await _db.CourseEnrollments
                .AsNoTracking()
                .Where(e => e.CourseId == courseId && e.Status == CourseEnrollmentStatus.Approved)
                .Join(
                    _db.Users,
                    enrollment => enrollment.StudentId,
                    user => user.Id,
                    (enrollment, user) => new EnrolledStudentDto
                    {
                        Id = user.Id,
                        FirstName = user.FirstName,
                        LastName = user.LastName,
                        Email = user.Email,
                        StudentId = user.StudentId
                    })
                .ToListAsync(cancellationToken);

            return new CourseManagementResponseDto
            {
                Id = course.Id,
                CourseName = course.CourseName,
                CourseCode = course.CourseCode,
                Description = course.Description,
                Semester = course.Semester,
                ImagePath = course.ImagePath,
                EnrollmentMode = course.EnrollmentMode.ToString(),
                LecturerId = course.LecturerId,
                CreatedAtUtc = course.CreatedAtUtc,
                Timetable = timetable,
                EnrolledStudentsCount = enrolledStudents.Count,
                EnrolledStudents = enrolledStudents
            };
        }

        private async Task<List<CourseTimetableEntryResponseDto>> GetTimetableAsync(
            Guid courseId,
            CancellationToken cancellationToken)
        {
            return await _db.CourseTimetableEntries
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
        }

        private static string GetExtensionOrThrow(string? contentType) => contentType switch
        {
            "image/jpeg" => ".jpg",
            "image/png" => ".png",
            _ => throw new ArgumentException("Only JPG and PNG images are allowed.")
        };

        private string GetWebRootPath() =>
            _environment.WebRootPath ?? Path.Combine(_environment.ContentRootPath, "wwwroot");

        private static CourseResponseDto ToDto(Course course) => new()
        {
            Id = course.Id,
            CourseName = course.CourseName,
            CourseCode = course.CourseCode,
            Description = course.Description,
            Semester = course.Semester,
            ImagePath = course.ImagePath,
            EnrollmentMode = course.EnrollmentMode.ToString(),
            LecturerId = course.LecturerId,
            CreatedAtUtc = course.CreatedAtUtc
        };
    }
}