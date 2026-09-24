namespace AI_Powered_Attendance_System.Services
{
    public interface IJwtService
    {
        string GenerateToken(Guid userId, string email, string role);
    }
}
