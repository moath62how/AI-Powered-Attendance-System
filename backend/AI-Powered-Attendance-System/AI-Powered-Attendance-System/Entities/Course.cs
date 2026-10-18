using System.ComponentModel.DataAnnotations;

namespace AI_Powered_Attendance_System.Entities
{
    public class Course
    {
        public Guid Id { get; set; }

        [Required]
        [MaxLength(150)]
        public string CourseName { get; set; } = string.Empty;

        [Required]
        [MaxLength(30)]
        public string CourseCode { get; set; } = string.Empty;

        [Required]
        [MaxLength(2000)]
        public string Description { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string Semester { get; set; } = string.Empty;

        [Required]
        [MaxLength(500)]
        public string ImagePath { get; set; } = string.Empty;

        [Required]
        public CourseEnrollmentMode EnrollmentMode { get; set; } = CourseEnrollmentMode.Closed;
        public Guid LecturerId { get; set; }

        public User Lecturer { get; set; } = null!;

        public DateTime CreatedAtUtc { get; set; }

        public DateTime UpdatedAtUtc { get; set; }
    }
}
