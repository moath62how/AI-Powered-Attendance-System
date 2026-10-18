using AI_Powered_Attendance_System.DTOs.Courses;
using FluentValidation;

namespace AI_Powered_Attendance_System.DTOs.Validators
{
    public class UpdateCourseRequestValidator : AbstractValidator<UpdateCourseRequestDto>
    {
        private static readonly string[] AllowedEnrollmentModes = { "AutoApprove", "Closed" };

        public UpdateCourseRequestValidator()
        {
            // Each rule only runs when that field was actually sent (PATCH semantics).

            RuleFor(x => x.CourseName)
                .NotEmpty().WithMessage("Course name cannot be empty.")
                .MaximumLength(150).WithMessage("Course name must not exceed 150 characters.")
                .When(x => x.CourseName is not null);

            RuleFor(x => x.CourseCode)
                .NotEmpty().WithMessage("Course code cannot be empty.")
                .MaximumLength(30).WithMessage("Course code must not exceed 30 characters.")
                .Matches("^[A-Za-z0-9-]+$").WithMessage("Course code can contain only letters, numbers, and hyphens.")
                .When(x => x.CourseCode is not null);

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Course description cannot be empty.")
                .MaximumLength(2000).WithMessage("Course description must not exceed 2000 characters.")
                .When(x => x.Description is not null);

            RuleFor(x => x.Semester)
                .NotEmpty().WithMessage("Course semester cannot be empty.")
                .MaximumLength(50).WithMessage("Course semester must not exceed 50 characters.")
                .When(x => x.Semester is not null);

            RuleFor(x => x.EnrollmentMode)
                .Must(mode => AllowedEnrollmentModes.Contains(mode, StringComparer.OrdinalIgnoreCase))
                .WithMessage("Enrollment mode must be either 'AutoApprove' or 'Closed'.")
                .When(x => x.EnrollmentMode is not null);

            RuleFor(x => x.Image)
                .Must(image => image!.Length > 0)
                .WithMessage("Course image cannot be empty.")
                .Must(image => image!.ContentType == "image/jpeg" || image.ContentType == "image/png")
                .WithMessage("Course image must be JPG or PNG.")
                .When(x => x.Image is not null);
        }
    }
}