namespace AI_Powered_Attendance_System.Services
{
    public interface IJwtService
    {
        (string AccessToken, DateTime ExpiresAtUtc) GenerateToken(
         Guid userId,
         string email,
         string role);
    }
}
