using AI_Powered_Attendance_System.DTOs.Auth;
using FluentValidation;

namespace AI_Powered_Attendance_System.Validators;

public class LoginRequestValidator : AbstractValidator<LoginRequestDto>
{
    public LoginRequestValidator()
    {
        RuleLevelCascadeMode = CascadeMode.Stop;

        RuleFor(x => x.Identifier)
            .NotEmpty().WithMessage("Email or Student ID is required.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.");
    }
}