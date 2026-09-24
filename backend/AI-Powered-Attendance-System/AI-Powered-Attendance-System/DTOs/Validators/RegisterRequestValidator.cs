using AI_Powered_Attendance_System.DTOs.Auth;
using FluentValidation;

namespace AI_Powered_Attendance_System.Validators;

public class RegisterRequestValidator : AbstractValidator<RegisterRequestDto>
{
    // Admin is intentionally missing: it can't be created through public registration.
    private static readonly string[] AllowedRoles = { "Student", "Lecturer" };

    public RegisterRequestValidator()
    {
        // Stop at the first failing rule per property, so one field
        // doesn't return several overlapping messages.
        RuleLevelCascadeMode = CascadeMode.Stop;

        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("First name is required.")
            .MaximumLength(100).WithMessage("First name must not exceed 100 characters.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Last name is required.")
            .MaximumLength(100).WithMessage("Last name must not exceed 100 characters.");

        // Optional leading '+', then 7-15 digits (international E.164 length limit).
        RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("Phone number is required.")
            .Matches(@"^\+?[0-9]{7,15}$")
            .WithMessage("Phone number must contain 7 to 15 digits, with an optional leading '+'.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required.")
            .MaximumLength(255).WithMessage("Email must not exceed 255 characters.")
            .EmailAddress().WithMessage("Email is not a valid email address.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required.")
            .MinimumLength(8).WithMessage("Password must be at least 8 characters.")
            .MaximumLength(72).WithMessage("Password must not exceed 72 characters.") // BCrypt only uses the first 72 bytes
            .Matches("[A-Z]").WithMessage("Password must contain at least one uppercase letter.")
            .Matches("[a-z]").WithMessage("Password must contain at least one lowercase letter.")
            .Matches("[0-9]").WithMessage("Password must contain at least one digit.")
            .Matches("[^a-zA-Z0-9]").WithMessage("Password must contain at least one special character.");

        RuleFor(x => x.Role)
            .NotEmpty().WithMessage("Role is required.")
            .Must(role => AllowedRoles.Contains(role, StringComparer.OrdinalIgnoreCase))
            .WithMessage("Role must be either 'Student' or 'Lecturer'.");
    }
}