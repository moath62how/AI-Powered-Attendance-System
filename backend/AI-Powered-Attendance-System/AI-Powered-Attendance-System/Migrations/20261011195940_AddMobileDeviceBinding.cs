using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AI_Powered_Attendance_System.Migrations
{
    /// <inheritdoc />
    public partial class AddMobileDeviceBinding : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "MobileDeviceId",
                table: "Users",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "MobileDeviceLinkedAtUtc",
                table: "Users",
                type: "datetime2",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "MobileDeviceId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "MobileDeviceLinkedAtUtc",
                table: "Users");
        }
    }
}
