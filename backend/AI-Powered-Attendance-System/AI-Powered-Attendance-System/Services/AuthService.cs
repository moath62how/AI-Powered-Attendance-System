using AI_Powered_Attendance_System.Data;
using AI_Powered_Attendance_System.DTOs.Auth;
using AI_Powered_Attendance_System.Entities;
using AI_Powered_Attendance_System.Exceptions;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;

namespace AI_Powered_Attendance_System.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _db;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IRefreshTokenService _refreshTokenService;
    private readonly IEmailService _emailService;
    public AuthService(AppDbContext db, IPasswordHasher passwordHasher, IJwtTokenService jwtTokenService, IRefreshTokenService refreshTokenService, IEmailService emailService)
    {
        _db = db;
        _passwordHasher = passwordHasher;
        _jwtTokenService = jwtTokenService;
        _refreshTokenService = refreshTokenService;
        _emailService = emailService;
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
        var oldRefreshTokens = await _db.RefreshTokens
    .Where(r => r.UserId == user.Id && r.RevokedAtUtc == null)
    .ToListAsync(cancellationToken);

        foreach (var oldToken in oldRefreshTokens)
        {
            oldToken.RevokedAtUtc = DateTime.UtcNow;
        }
        var (refreshToken, refreshTokenHash) = _refreshTokenService.CreateToken();

        var refreshTokenEntity = new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            TokenHash = refreshTokenHash,
            ///for changing
            ExpiresAtUtc = DateTime.UtcNow.AddDays(7),
            CreatedAtUtc = DateTime.UtcNow
        };

        _db.RefreshTokens.Add(refreshTokenEntity);

        await _db.SaveChangesAsync(cancellationToken);
        return new AuthResponseDto
        {
            AccessToken = token,
            RefreshToken = refreshToken,
            ExpiresAtUtc = expiresAt,
            User = ToDto(user)
        };
    }
    public async Task<AuthResponseDto?> RefreshAsync(
    RefreshTokenRequestDto request,
    CancellationToken cancellationToken = default)
    {
        var tokenHash = _refreshTokenService.HashToken(request.RefreshToken);

        var refreshToken = await _db.RefreshTokens
            .Include(r => r.User)
            .FirstOrDefaultAsync(
                r => r.TokenHash == tokenHash,
                cancellationToken);

        if (refreshToken is null)
            return null;

        if (refreshToken.RevokedAtUtc is not null)
            return null;

        if (refreshToken.ExpiresAtUtc <= DateTime.UtcNow)
            return null;

        var user = refreshToken.User;

        var (accessToken, expiresAt) = _jwtTokenService.GenerateToken(user);

        return new AuthResponseDto
        {
            AccessToken = accessToken,
            RefreshToken = request.RefreshToken,
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

    public async Task<string?> ForgotPasswordAsync(
    ForgotPasswordRequestDto request,
    CancellationToken cancellationToken = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await _db.Users
            .FirstOrDefaultAsync(u => u.Email == email, cancellationToken);

        if (user is null)
            return null;

        var tokenBytes = RandomNumberGenerator.GetBytes(32);
        var token = Convert.ToBase64String(tokenBytes);


        var tokenHashBytes = SHA256.HashData(tokenBytes);
        var tokenHash = Convert.ToBase64String(tokenHashBytes);

        user.PasswordResetTokenHash = tokenHash;
        user.PasswordResetTokenExpiresAt = DateTime.UtcNow.AddHours(1);
        user.PasswordResetTokenUsedAt = null;

        await _db.SaveChangesAsync(cancellationToken);
        await _emailService.SendPasswordResetEmailAsync( user.Email,token,cancellationToken);
       
        return token;
    }

    public async Task<bool> ResetPasswordAsync(
    ResetPasswordRequestDto request,
    CancellationToken cancellationToken = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await _db.Users
            .FirstOrDefaultAsync(u => u.Email == email, cancellationToken);

        if (user is null)
            return false;

        if (user.PasswordResetTokenHash is null)
            return false;

        if (user.PasswordResetTokenExpiresAt is null ||
            user.PasswordResetTokenExpiresAt <= DateTime.UtcNow)
            return false;

        if (user.PasswordResetTokenUsedAt is not null)
            return false;

        
        byte[] tokenBytes;

        try
        {
            tokenBytes = Convert.FromBase64String(request.Token);
        }
        catch (FormatException)
        {
            return false;
        }

       
        var tokenHashBytes = SHA256.HashData(tokenBytes);
        var tokenHash = Convert.ToBase64String(tokenHashBytes);

        if (tokenHash != user.PasswordResetTokenHash)
            return false;

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);

        
        user.PasswordResetTokenUsedAt = DateTime.UtcNow;

        
        user.PasswordResetTokenHash = null;
        user.PasswordResetTokenExpiresAt = null;

        user.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync(cancellationToken);

        return true;
    }
}