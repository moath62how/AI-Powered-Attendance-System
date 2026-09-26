namespace AI_Powered_Attendance_System.Services
{
    public interface IRefreshTokenService
    {
        (string Token, string TokenHash) CreateToken();
        string HashToken(string token);
    }
}
