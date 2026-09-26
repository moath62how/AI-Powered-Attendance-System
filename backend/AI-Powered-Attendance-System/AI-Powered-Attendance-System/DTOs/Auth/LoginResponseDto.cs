namespace AI_Powered_Attendance_System.DTOs.Auth
{
    public class LoginResponseDto
    {
        public string AccessToken { get; set; } = string.Empty;
        public string RefreshToken { get; set; } = string.Empty;

        public DateTime ExpiresAtUtc { get; set; }

        public UserDto User { get; set; } = null!;

    }
}
