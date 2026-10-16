namespace AI_Powered_Attendance_System.DTOs.Timetable
{
    public class CreateCourseTimetableEntryRequestDto
    {
        public string? Day { get; set; }

        public TimeOnly? StartTime { get; set; }

        public TimeOnly? EndTime { get; set; }
    }
}
