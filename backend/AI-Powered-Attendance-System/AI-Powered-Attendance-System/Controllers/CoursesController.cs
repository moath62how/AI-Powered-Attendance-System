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

        public CoursesController(
            ICourseService courseService,
            IValidator<CreateCourseRequestDto> validator)
        {
            _courseService = courseService;
            _validator = validator;
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public async Task<ActionResult<CourseResponseDto>> Create(
            [FromForm] CreateCourseRequestDto request,
            CancellationToken cancellationToken)
        {
            // Validate the request
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

          
            var userIdValue = User.FindFirstValue(
                ClaimTypes.NameIdentifier);

            if (!Guid.TryParse(userIdValue, out var lecturerId))
            {
                return Unauthorized();
            }

           
            var course = await _courseService.CreateAsync(
                request,
                lecturerId,
                cancellationToken);

            return CreatedAtAction(
                nameof(Create),
                new { id = course.Id },
                course);
        }
    }
}