using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AI_Powered_Attendance_System.Migrations
{
    /// <inheritdoc />
    public partial class AddUniqueMobileDeviceId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Users_MobileDeviceId",
                table: "Users",
                column: "MobileDeviceId",
                unique: true,
                filter: "[MobileDeviceId] IS NOT NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Users_MobileDeviceId",
                table: "Users");
        }
    }
}
