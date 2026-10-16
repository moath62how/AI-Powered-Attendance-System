namespace AI_Powered_Attendance_System.DTOs.Timetable
{
    public class CourseTimetableEntryResponseDto
    {
        public Guid Id { get; set; }

        public Guid CourseId { get; set; }

        public string Day { get; set; } = string.Empty;

        public TimeOnly StartTime { get; set; }

        public TimeOnly EndTime { get; set; }

        public DateTime CreatedAtUtc { get; set; }

        public DateTime UpdatedAtUtc { get; set; }
    }
}
