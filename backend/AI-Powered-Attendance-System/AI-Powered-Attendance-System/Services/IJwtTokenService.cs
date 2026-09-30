using AI_Powered_Attendance_System.Entities;

namespace AI_Powered_Attendance_System.Services;

public interface IJwtTokenService
{
    (string Token, DateTime ExpiresAtUtc) GenerateToken(User user);
}