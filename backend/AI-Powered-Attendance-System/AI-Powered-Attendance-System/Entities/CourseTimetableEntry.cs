namespace AI_Powered_Attendance_System.Entities
{
    public class CourseTimetableEntry
    {
        public Guid Id { get; set; }

        public Guid CourseId { get; set; }

        public Course Course { get; set; } = null!;

        public DayOfWeek Day { get; set; }

        public TimeOnly StartTime { get; set; }

        public TimeOnly EndTime { get; set; }

        public DateTime CreatedAtUtc { get; set; }

        public DateTime UpdatedAtUtc { get; set; }
    }
}
