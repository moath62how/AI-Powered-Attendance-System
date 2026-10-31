using AI_Powered_Attendance_System.DTOs.Courses;
using FluentValidation;

namespace AI_Powered_Attendance_System.DTOs.Validators
{
    public class CreateCourseRequestValidator : AbstractValidator<CreateCourseRequestDto>
    {
        public CreateCourseRequestValidator()
        {
            RuleFor(x => x.CourseName)
                .NotEmpty()
                .WithMessage("Course name is required.")
                .MaximumLength(150)
                .WithMessage("Course name must not exceed 150 characters.");

            RuleFor(x => x.CourseCode)
                .NotEmpty()
                .WithMessage("Course code is required.")
                .MaximumLength(30)
                .WithMessage("Course code must not exceed 30 characters.")
                .Matches("^[A-Za-z0-9-]+$")
                .WithMessage("Course code can contain only letters, numbers, and hyphens.");

            RuleFor(x => x.Description)
                .NotEmpty()
                .WithMessage("Course description is required.")
                .MaximumLength(2000)
                .WithMessage("Course description must not exceed 2000 characters.");

            RuleFor(x => x.Semester)
                .NotEmpty()
                .WithMessage("Course semester is required.")
                .MaximumLength(50)
                .WithMessage("Course semester must not exceed 50 characters.");

            RuleFor(x => x.Image)
                .Must(image => image!.Length > 0)
                .WithMessage("Course image cannot be empty.")
                .Must(image => image!.ContentType == "image/jpeg" ||
                               image.ContentType == "image/png")
                .WithMessage("Course image must be JPG or PNG.")
                .When(x => x.Image is not null);
        }   
    }
}