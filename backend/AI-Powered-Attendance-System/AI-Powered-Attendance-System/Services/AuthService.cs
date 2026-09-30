using AI_Powered_Attendance_System.Data;
using AI_Powered_Attendance_System.DTOs.Auth;
using AI_Powered_Attendance_System.Entities;
using AI_Powered_Attendance_System.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace AI_Powered_Attendance_System.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _db;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenService _jwtTokenService;

    public AuthService(AppDbContext db, IPasswordHasher passwordHasher, IJwtTokenService jwtTokenService)
    {
        _db = db;
        _passwordHasher = passwordHasher;
        _jwtTokenService = jwtTokenService;
    }

    // Assumes the request was already validated by RegisterRequestValidator.
    public async Task<UserDto> RegisterAsync(RegisterRequestDto request, CancellationToken cancellationToken = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        if (await EmailExistsAsync(email, cancellationToken))
            throw new ConflictException("An account with this email already exists.");

        var now = DateTime.UtcNow;

        var user = new User
        {
            Id = Guid.NewGuid(),
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            PhoneNumber = request.PhoneNumber.Trim(),
            Email = email,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Role = Enum.Parse<UserRole>(request.Role, ignoreCase: true),
            CreatedAt = now,
            UpdatedAt = now
        };

        _db.Users.Add(user);

        try
        {
            await _db.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            // Two requests with the same email passed the check above at the same time;
            // the unique index rejected the second one.
            if (await EmailExistsAsync(email, cancellationToken))
                throw new ConflictException("An account with this email already exists.");

            // Not a duplicate-email problem, so let it surface as a 500.
            throw;
        }

        return ToDto(user);
    }

    public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await _db.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Email == email, cancellationToken);

        // Same message whether the email is unknown or the password is wrong,
        // so a caller can't use this endpoint to discover which emails are registered.
        if (user is null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedException("Invalid email or password.");

        var (token, expiresAt) = _jwtTokenService.GenerateToken(user);

        return new AuthResponseDto
        {
            AccessToken = token,
            ExpiresAtUtc = expiresAt,
            User = ToDto(user)
        };
    }

    private Task<bool> EmailExistsAsync(string email, CancellationToken cancellationToken) =>
        _db.Users.AsNoTracking().AnyAsync(u => u.Email == email, cancellationToken);

    private static UserDto ToDto(User user) => new()
    {
        Id = user.Id,
        FirstName = user.FirstName,
        LastName = user.LastName,
        PhoneNumber = user.PhoneNumber,
        Email = user.Email,
        Role = user.Role.ToString(),
        CreatedAt = user.CreatedAt
    };
}