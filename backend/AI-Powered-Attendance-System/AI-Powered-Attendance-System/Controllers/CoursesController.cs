using AI_Powered_Attendance_System.DTOs.Courses;
using AI_Powered_Attendance_System.Services;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AI_Powered_Attendance_System.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CoursesController : ControllerBase
    {
        private readonly ICourseService _courseService;
        private readonly IValidator<CreateCourseRequestDto> _validator;
        private readonly IValidator<UpdateCourseRequestDto> _updateValidator;

        public CoursesController(
            ICourseService courseService,
            IValidator<CreateCourseRequestDto> validator,
            IValidator<UpdateCourseRequestDto> updateValidator)
        {
            _courseService = courseService;
            _validator = validator;
            _updateValidator = updateValidator;
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(CourseResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        [Authorize(Roles = "Lecturer")]
        public async Task<ActionResult<CourseResponseDto>> Create(
            [FromForm] CreateCourseRequestDto request,
            CancellationToken cancellationToken)
        {
            var validationResult = await _validator.ValidateAsync(
                request,
                cancellationToken);

            if (!validationResult.IsValid)
            {
                return BadRequest(new
                {
                    message = "Course validation failed.",
                    errors = validationResult.Errors.Select(e => new
                    {
                        field = e.PropertyName,
                        error = e.ErrorMessage
                    })
                });
            }

            var userIdValue = User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? User.FindFirstValue("sub");

            if (!Guid.TryParse(userIdValue, out var lecturerId))
            {
                return Unauthorized();
            }

            var course = await _courseService.CreateAsync(
                request,
                lecturerId,
                cancellationToken);

            return CreatedAtAction(
                nameof(GetById),
                new { id = course.Id },
                course);
        }


        [HttpGet("{id:guid}")]
        public async Task<ActionResult<CourseResponseDto>> GetById(
            Guid id,
            CancellationToken cancellationToken)
        {
            var course = await _courseService.GetByIdAsync(
                id,
                cancellationToken);

            if (course is null)
            {
                return NotFound(new
                {
                    message = "Course not found."
                });
            }

            return Ok(course);
        }


        [HttpPatch("{id:guid}")]
        [Authorize(Roles = "Lecturer")]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(CourseResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<ActionResult<object>> Update(
            Guid id,
            [FromForm] UpdateCourseRequestDto request,
            CancellationToken cancellationToken)
        {
            var validationResult = await _updateValidator.ValidateAsync(
                request,
                cancellationToken);

            if (!validationResult.IsValid)
            {
                return BadRequest(new
                {
                    message = "Course validation failed.",
                    errors = validationResult.Errors.Select(e => new
                    {
                        field = e.PropertyName,
                        error = e.ErrorMessage
                    })
                });
            }

            var userIdValue = User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? User.FindFirstValue("sub");

            if (!Guid.TryParse(userIdValue, out var lecturerId))
            {
                return Unauthorized();
            }

            var course = await _courseService.UpdateAsync(
                id,
                request,
                lecturerId,
                cancellationToken);

            return Ok(new
            {
                message = "Course updated successfully.",
                course
            });
        }


        [HttpDelete("{courseId:guid}")]
        [Authorize(Roles = "Lecturer")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Delete(
            Guid courseId,
            CancellationToken cancellationToken)
        {
            var userIdValue =
                User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? User.FindFirstValue("sub");

            if (!Guid.TryParse(userIdValue, out var lecturerId))
            {
                return Unauthorized();
            }

            var deleted = await _courseService.DeleteAsync(
                courseId,
                lecturerId,
                cancellationToken);

            if (!deleted)
            {
                return NotFound(new
                {
                    message = "Course not found."
                });
            }

            return Ok(new
            {
                message = "Course deleted successfully."
            });
        }
    }
}