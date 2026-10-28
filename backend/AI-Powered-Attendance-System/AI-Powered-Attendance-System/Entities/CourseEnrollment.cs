namespace AI_Powered_Attendance_System.Entities
{
    public class CourseEnrollment
    {
        public Guid Id { get; set; }

        public Guid CourseId { get; set; }
        public Course Course { get; set; } = null!;

        public Guid StudentId { get; set; }
        public User Student { get; set; } = null!;

        public CourseEnrollmentStatus Status { get; set; } = CourseEnrollmentStatus.Pending;

        public DateTime RequestedAtUtc { get; set; }
        public DateTime? RespondedAtUtc { get; set; }
    }
}