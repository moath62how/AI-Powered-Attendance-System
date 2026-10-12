namespace AI_Powered_Attendance_System.DTOs.Auth
{
    public class ResetPasswordWithCodeRequestDto
    {
        public string Email { get; set; } = string.Empty;

        public string Code { get; set; } = string.Empty;

        public string NewPassword { get; set; } = string.Empty;
    }
}
