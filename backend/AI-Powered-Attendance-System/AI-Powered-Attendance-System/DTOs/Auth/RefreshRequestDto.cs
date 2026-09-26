using System.ComponentModel.DataAnnotations;

namespace AI_Powered_Attendance_System.DTOs.Auth
{
    public class RefreshRequestDto
    {
        [Required]
        public string RefreshToken { get; set; } = string.Empty;
    }
}
