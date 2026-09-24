using AI_Powered_Attendance_System.DTOs.Auth;

namespace AI_Powered_Attendance_System.Services;

public interface IAuthService
{
    Task<UserDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default);
}