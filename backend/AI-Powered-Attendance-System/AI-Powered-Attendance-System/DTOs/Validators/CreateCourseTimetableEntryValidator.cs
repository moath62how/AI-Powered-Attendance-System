using AI_Powered_Attendance_System.DTOs.Timetable;
using FluentValidation;

namespace AI_Powered_Attendance_System.DTOs.Validators
{
    public class CreateCourseTimetableEntryValidator : AbstractValidator<CreateCourseTimetableEntryRequestDto>
    {
        public CreateCourseTimetableEntryValidator()
        {
            RuleFor(x => x.Day)
                .NotEmpty()
                .WithMessage("Day is required.")
                .Must(day =>
                    !string.IsNullOrWhiteSpace(day) &&
                    Enum.GetNames<DayOfWeek>().Contains(
                        day.Trim(),
                        StringComparer.OrdinalIgnoreCase))
                .WithMessage(
                    "Day must be a valid day of the week.");

            RuleFor(x => x.StartTime)
                .NotNull()
                .WithMessage("Start time is required.")
                .Must((request, startTime) =>
                    startTime.HasValue &&
                    request.EndTime.HasValue &&
                    startTime.Value < request.EndTime.Value)
                .WithMessage(
                    "Start time must be earlier than end time.");

            RuleFor(x => x.EndTime)
                .NotNull()
                .WithMessage("End time is required.")
                .Must((request, endTime) =>
                    endTime.HasValue &&
                    request.StartTime.HasValue &&
                    endTime.Value > request.StartTime.Value)
                .WithMessage(
                    "End time must be later than start time.");

        }
    }
}