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
    [Authorize(Roles = "Lecturer")]
    public class CoursesController : ControllerBase
    {
        private readonly ICourseService _courseService;
        private readonly IValidator<CreateCourseRequestDto> _validator;

        public CoursesController(
            ICourseService courseService,
            IValidator<CreateCourseRequestDto> validator)
        {
            _courseService = courseService;
            _validator = validator;
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(CourseResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
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

            
            return StatusCode(StatusCodes.Status201Created, course);
        }
    }
}