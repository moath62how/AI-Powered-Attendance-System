using AI_Powered_Attendance_System.DTOs.Timetable;
using AI_Powered_Attendance_System.Entities;
using AI_Powered_Attendance_System.Services;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AI_Powered_Attendance_System.Controllers
{
    [ApiController]
    [Route("api/courses/{courseId:guid}/timetable")]
    [Authorize(Roles = "Lecturer")]
    public class CourseTimetableController : ControllerBase
    {
        private readonly ICourseTimetableService _timetableService;
        private readonly IValidator<CreateCourseTimetableEntryRequestDto> _validator;

        public CourseTimetableController(
            ICourseTimetableService timetableService,
            IValidator<CreateCourseTimetableEntryRequestDto> validator)
        {
            _timetableService = timetableService;
            _validator = validator;
        }

        [HttpGet]
        public async Task<IActionResult> GetByCourse(
            Guid courseId,
            CancellationToken cancellationToken)
        {
            var lecturerId = GetLecturerId();

            if (lecturerId is null)
                return Unauthorized();

            var entries = await _timetableService.GetByCourseAsync(
                lecturerId.Value,
                courseId,
                cancellationToken);

            if (entries is null)
                return NotFound(new { message = "Course not found." });

            return Ok(entries);
        }

        [HttpPost]
        public async Task<IActionResult> Create(
            Guid courseId,
            [FromBody] CreateCourseTimetableEntryRequestDto request,
            CancellationToken cancellationToken)
        {
            var validation = await _validator.ValidateAsync(
                request,
                cancellationToken);

            if (!validation.IsValid)
            {
                return BadRequest(new
                {
                    message = "Timetable validation failed.",
                    errors = validation.Errors.Select(e => new
                    {
                        field = e.PropertyName,
                        error = e.ErrorMessage
                    })
                });
            }

            var lecturerId = GetLecturerId();

            if (lecturerId is null)
                return Unauthorized();

            var entry = await _timetableService.CreateAsync(
                lecturerId.Value,
                courseId,
                request,
                cancellationToken);

            if (entry is null)
                return NotFound(new { message = "Course not found." });

            return CreatedAtAction(
                nameof(GetByCourse),
                new { courseId },
                entry);
        }

        [HttpPut("{entryId:guid}")]
        public async Task<IActionResult> Update(
            Guid courseId,
            Guid entryId,
            [FromBody] CreateCourseTimetableEntryRequestDto request,
            CancellationToken cancellationToken)
        {
            var validation = await _validator.ValidateAsync(
                request,
                cancellationToken);

            if (!validation.IsValid)
            {
                return BadRequest(new
                {
                    message = "Timetable validation failed.",
                    errors = validation.Errors.Select(e => new
                    {
                        field = e.PropertyName,
                        error = e.ErrorMessage
                    })
                });
            }

            var lecturerId = GetLecturerId();

            if (lecturerId is null)
                return Unauthorized();

            var entry = await _timetableService.UpdateAsync(
                lecturerId.Value,
                courseId,
                entryId,
                request,
                cancellationToken);

            if (entry is null)
                return NotFound(new
                {
                    message = "Course or timetable entry not found."
                });

            return Ok(entry);
        }

        [HttpDelete("{entryId:guid}")]
        public async Task<IActionResult> Delete(
            Guid courseId,
            Guid entryId,
            CancellationToken cancellationToken)
        {
            var lecturerId = GetLecturerId();

            if (lecturerId is null)
                return Unauthorized();

            var deleted = await _timetableService.DeleteAsync(
                lecturerId.Value,
                courseId,
                entryId,
                cancellationToken);

            if (!deleted)
                return NotFound(new
                {
                    message = "Course or timetable entry not found."
                });

            return NoContent();
        }

        private Guid? GetLecturerId()
        {
            var userIdValue =
                User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? User.FindFirstValue("sub");

            if (Guid.TryParse(userIdValue, out var lecturerId))
                return lecturerId;

            return null;
        }
    }
}
