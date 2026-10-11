namespace AI_Powered_Attendance_System.Exceptions;

public class ForbiddenException : Exception
{
    public ForbiddenException(string message) : base(message) { }
}