using AI_Powered_Attendance_System.Data;
using Microsoft.EntityFrameworkCore;
using FluentValidation;
using AI_Powered_Attendance_System.Services;
using AI_Powered_Attendance_System.Middleware;

namespace AI_Powered_Attendance_System
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            builder.Services.AddControllers();

            // validation
            builder.Services.AddValidatorsFromAssemblyContaining<Program>();

            // add db context
            builder.Services.AddDbContext<AppDbContext>(options =>
                options.UseSqlServer(
                    builder.Configuration.GetConnectionString("DefaultConnection")));

            //PasswordHasher
            builder.Services.AddScoped<IPasswordHasher, BcryptPasswordHasher>();
            builder.Services.AddScoped<IAuthService, AuthService>();

            // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
            builder.Services.AddOpenApi();

            var app = builder.Build();

            app.UseMiddleware<ExceptionHandlingMiddleware>();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())

                // Configure the HTTP request pipeline.
                if (app.Environment.IsDevelopment())
            {
                app.MapOpenApi();
            }

            app.UseHttpsRedirection();

            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }
}