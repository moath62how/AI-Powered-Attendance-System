namespace AI_Powered_Attendance_System.DTOs.Auth;

public class LoginRequestDto
{
    public string Identifier { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}