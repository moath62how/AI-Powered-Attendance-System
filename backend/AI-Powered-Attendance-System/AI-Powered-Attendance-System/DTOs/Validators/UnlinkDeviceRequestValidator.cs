using AI_Powered_Attendance_System.DTOs.Auth;
using FluentValidation;

namespace AI_Powered_Attendance_System.Validators
{
    public class UnlinkDeviceRequestValidator : AbstractValidator<UnlinkDeviceRequestDto>
    {
        public UnlinkDeviceRequestValidator()
        {
            RuleLevelCascadeMode = CascadeMode.Stop;

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required.");
        }
    }
}