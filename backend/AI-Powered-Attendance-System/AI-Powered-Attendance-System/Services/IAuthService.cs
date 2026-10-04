using AI_Powered_Attendance_System.DTOs.Auth;

namespace AI_Powered_Attendance_System.Services;

public interface IAuthService
{
    Task<UserDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default);
    Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default);
    Task<string?> ForgotPasswordAsync( ForgotPasswordRequestDto request,CancellationToken cancellationToken = default);

    Task<bool> ResetPasswordAsync( ResetPasswordRequestDto request,CancellationToken cancellationToken = default);
    Task<AuthResponseDto?> RefreshAsync( RefreshTokenRequestDto request,CancellationToken cancellationToken = default);

}