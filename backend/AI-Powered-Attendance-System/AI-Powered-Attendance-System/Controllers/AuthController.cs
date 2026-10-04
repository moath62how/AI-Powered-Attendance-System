using AI_Powered_Attendance_System.DTOs.Auth;
using AI_Powered_Attendance_System.Services;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace AI_Powered_Attendance_System.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IValidator<RegisterRequestDto> _registerValidator;
    private readonly IValidator<LoginRequestDto> _loginValidator;
    private readonly IValidator<ForgotPasswordRequestDto> _forgotPasswordValidator;
    private readonly IValidator<ResetPasswordRequestDto> _resetPasswordValidator;
    private readonly IValidator<RefreshTokenRequestDto> _refreshTokenValidator;
    public AuthController(
        IAuthService authService,
        IValidator<RegisterRequestDto> registerValidator,
        IValidator<LoginRequestDto> loginValidator,
           IValidator<ForgotPasswordRequestDto> forgotPasswordValidator,
    IValidator<ResetPasswordRequestDto> resetPasswordValidator,
    IValidator<RefreshTokenRequestDto> refreshTokenValidator)
    {
        _authService = authService;
        _registerValidator = registerValidator;
        _loginValidator = loginValidator;
        _forgotPasswordValidator = forgotPasswordValidator;
        _resetPasswordValidator = resetPasswordValidator;
        _refreshTokenValidator = refreshTokenValidator;

    }

    [HttpPost("register")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Register(RegisterRequestDto request, CancellationToken cancellationToken)
    {
        var validation = await _registerValidator.ValidateAsync(request, cancellationToken);

        if (!validation.IsValid)
            return ValidationProblem(new ValidationProblemDetails(validation.ToDictionary()));

        var user = await _authService.RegisterAsync(request, cancellationToken);

        return StatusCode(StatusCodes.Status201Created, user);
    }

    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login(LoginRequestDto request, CancellationToken cancellationToken)
    {
        var validation = await _loginValidator.ValidateAsync(request, cancellationToken);

        if (!validation.IsValid)
            return ValidationProblem(new ValidationProblemDetails(validation.ToDictionary()));

        var result = await _authService.LoginAsync(request, cancellationToken);

        return Ok(result);
    }

    [HttpPost("refresh")]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Refresh(
    RefreshTokenRequestDto request,
    CancellationToken cancellationToken)
    {
        var validation = await _refreshTokenValidator.ValidateAsync(
            request,
            cancellationToken);

        if (!validation.IsValid)
            return ValidationProblem(
                new ValidationProblemDetails(validation.ToDictionary()));

        var result = await _authService.RefreshAsync(
            request,
            cancellationToken);

        if (result is null)
            return Unauthorized(new
            {
                message = "Invalid or expired refresh token."
            });

        return Ok(result);
    }
    [HttpPost("forgot-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ForgotPassword(
    ForgotPasswordRequestDto request,
    CancellationToken cancellationToken)
    {
        var validation = await _forgotPasswordValidator.ValidateAsync(
            request,
            cancellationToken);

        if (!validation.IsValid)
            return ValidationProblem(
                new ValidationProblemDetails(validation.ToDictionary()));

        var token = await _authService.ForgotPasswordAsync(
            request,
            cancellationToken);

        return Ok(new
        {
            message = "Password reset token generated.",
            token
        });
    }
    [HttpPost("reset-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ResetPassword(
    ResetPasswordRequestDto request,
    CancellationToken cancellationToken)
    {
        var validation = await _resetPasswordValidator.ValidateAsync(
            request,
            cancellationToken);

        if (!validation.IsValid)
            return ValidationProblem(
                new ValidationProblemDetails(validation.ToDictionary()));

        var result = await _authService.ResetPasswordAsync(
            request,
            cancellationToken);

        if (!result)
            return BadRequest(new
            {
                message = "Invalid or expired reset token."
            });

        return Ok(new
        {
            message = "Password has been reset successfully."
        });
    }

    [HttpGet("me")]
    [Authorize(Roles = "Lecturer")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public IActionResult Me()
    {
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
            ?? User.FindFirst("sub")?.Value;
        var email = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;
        var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;

        return Ok(new { userId, email, role });
    }
}