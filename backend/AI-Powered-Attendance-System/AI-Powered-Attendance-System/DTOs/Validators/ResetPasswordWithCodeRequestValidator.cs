using AI_Powered_Attendance_System.DTOs.Auth;
using FluentValidation;

namespace AI_Powered_Attendance_System.DTOs.Validators;

public class ResetPasswordWithCodeRequestValidator
    : AbstractValidator<ResetPasswordWithCodeRequestDto>
{
    public ResetPasswordWithCodeRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .WithMessage("A valid email address is required.");

        RuleFor(x => x.Code)
            .NotEmpty()
            .Matches(@"^\d{5}$")
            .WithMessage("Reset code must contain exactly 5 digits.");

        RuleFor(x => x.NewPassword)
            .NotEmpty()
            .MinimumLength(8)
            .MaximumLength(128)
            .Matches(@"[^a-zA-Z0-9]")
            .WithMessage(
                "Password must contain at least one special character.");
    }
}