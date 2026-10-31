using AI_Powered_Attendance_System.DTOs.Courses;
using FluentValidation;

namespace AI_Powered_Attendance_System.DTOs.Validators
{
    public class MyCoursesQueryValidator : AbstractValidator<MyCoursesQueryDto>
    {
        private static readonly string[] AllowedAcademicYears = { "First", "Second", "Third", "Fourth" };

        public MyCoursesQueryValidator()
        {
            RuleFor(x => x.AcademicYear)
                .Must(year => AllowedAcademicYears.Contains(year, StringComparer.OrdinalIgnoreCase))
                .WithMessage("Academic year must be one of: First, Second, Third, Fourth.")
                .When(x => x.AcademicYear is not null);

            RuleFor(x => x.Page)
                .GreaterThanOrEqualTo(1).WithMessage("Page must be at least 1.")
                // Upper bound prevents int overflow in (page - 1) * pageSize.
                .LessThanOrEqualTo(1_000_000).WithMessage("Page must not exceed 1,000,000.");

            RuleFor(x => x.PageSize)
                .InclusiveBetween(1, 50).WithMessage("Page size must be between 1 and 50.");
        }
    }
}