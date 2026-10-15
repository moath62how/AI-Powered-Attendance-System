using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AI_Powered_Attendance_System.Migrations
{
    /// <inheritdoc />
    public partial class AddUniqueCourseCode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Courses_CourseCode",
                table: "Courses",
                column: "CourseCode",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Courses_CourseCode",
                table: "Courses");
        }
    }
}
