using AI_Powered_Attendance_System.Data;
using AI_Powered_Attendance_System.Middleware;
using AI_Powered_Attendance_System.Services;
using AI_Powered_Attendance_System.Settings;
using AI_Powered_Attendance_System.OpenApi;
using FluentValidation;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using System.Text;

namespace AI_Powered_Attendance_System;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Add services to the container.
        builder.Services.AddControllers();

        // Database
        builder.Services.AddDbContext<AppDbContext>(options =>
            options.UseSqlServer(
                builder.Configuration.GetConnectionString("DefaultConnection")));

        // JWT Settings
        builder.Services.Configure<JwtSettings>(
            builder.Configuration.GetSection("Jwt"));

        // JWT Token Service
        builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();

        // JWT Authentication
        var jwtSettings = builder.Configuration
            .GetSection("Jwt")
            .Get<JwtSettings>()!;

        var jwtSecret = builder.Configuration["Jwt:Secret"]
            ?? throw new InvalidOperationException(
                "Jwt:Secret is not configured. Set it via User Secrets or environment variables.");

        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = jwtSettings.Issuer,

                    ValidateAudience = true,
                    ValidAudience = jwtSettings.Audience,

                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(jwtSecret)),

                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                };
            });

        builder.Services.AddAuthorization();

        // Validation
        builder.Services.AddValidatorsFromAssemblyContaining<Program>();

        // Password Hasher
        builder.Services.AddScoped<IPasswordHasher, BcryptPasswordHasher>();

        // Auth Service
        builder.Services.AddScoped<IAuthService, AuthService>();

        // OpenAPI
        builder.Services.AddOpenApi(options =>
        {
            options.AddDocumentTransformer<BearerSecuritySchemeTransformer>();
        });

        var app = builder.Build();

        // Global Exception Handling
        app.UseMiddleware<ExceptionHandlingMiddleware>();

        // OpenAPI
        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
            app.MapScalarApiReference();
        }   

        app.UseHttpsRedirection();

        // Authentication must come before Authorization
        app.UseAuthentication();
        app.UseAuthorization();

        app.MapControllers();

        app.Run();
    }
}