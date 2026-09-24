using AI_Powered_Attendance_System.DTOs.Auth;
using AI_Powered_Attendance_System.Services;
using FluentValidation;
using Microsoft.AspNetCore.Mvc;

namespace AI_Powered_Attendance_System.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IValidator<RegisterRequestDto> _registerValidator;

    public AuthController(IAuthService authService, IValidator<RegisterRequestDto> registerValidator)
    {
        _authService = authService;
        _registerValidator = registerValidator;
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
}