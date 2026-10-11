using AI_Powered_Attendance_System.Data;
using AI_Powered_Attendance_System.DTOs.Courses;
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
                throw new UnauthorizedException(
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

            await using (var stream = new FileStream(
                filePath,
                FileMode.CreateNew))
            {
                await image.CopyToAsync(
                    stream,
                    cancellationToken);
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
                LecturerId = lecturerId,
                CreatedAtUtc = now,
                UpdatedAtUtc = now
            };

            _db.Courses.Add(course);

            await _db.SaveChangesAsync(cancellationToken);

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

    }
}
