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
        var role = Enum.Parse<UserRole>(request.Role, ignoreCase: true);

        string? studentId = role == UserRole.Student
            ? request.StudentId!.Trim()
            : null;

        if (await EmailExistsAsync(email, cancellationToken))
            throw new ConflictException("An account with this email already exists.");

        if (studentId is not null && await StudentIdExistsAsync(studentId, cancellationToken))
            throw new ConflictException("An account with this Student ID already exists.");

        var now = DateTime.UtcNow;

        var user = new User
        {
            Id = Guid.NewGuid(),
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            PhoneNumber = request.PhoneNumber.Trim(),
            Email = email,
            StudentId = studentId,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Role = role,
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
            if (await EmailExistsAsync(email, cancellationToken))
                throw new ConflictException("An account with this email already exists.");

            if (studentId is not null && await StudentIdExistsAsync(studentId, cancellationToken))
                throw new ConflictException("An account with this Student ID already exists.");

            throw;
        }

        return ToDto(user);
    }

    public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken cancellationToken = default)
    {
        var identifier = request.Identifier.Trim();
        var isEmail = identifier.Contains('@');

        // Tracked (not AsNoTracking) because a mobile login may bind the device
        // and that change needs to be saved below.
        User? user;
        if (isEmail)
        {
            var email = identifier.ToLowerInvariant();
            user = await _db.Users.FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
        }
        else
        {
            user = await _db.Users.FirstOrDefaultAsync(u => u.StudentId == identifier, cancellationToken);
        }

        // Same message whether the identifier is unknown or the password is wrong,
        // so a caller can't use this endpoint to discover which accounts exist.
        if (user is null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedException("Invalid credentials.");

        // Device binding only applies to mobile clients; web login stays unrestricted.
        var isMobile = string.Equals(request.ClientType, "Mobile", StringComparison.OrdinalIgnoreCase);

        if (isMobile)
        {
            var deviceId = request.DeviceId!.Trim(); // validator guarantees non-empty for Mobile

            if (user.MobileDeviceId is null)
            {
                // Reject if this device is already bound to a DIFFERENT account.
                var deviceTakenByAnotherAccount = await _db.Users
                    .AsNoTracking()
                    .AnyAsync(u => u.MobileDeviceId == deviceId && u.Id != user.Id, cancellationToken);

                if (deviceTakenByAnotherAccount)
                    throw new ForbiddenException("This device is already linked to another account.");

                // First mobile login: bind this device to the account.
                user.MobileDeviceId = deviceId;
                user.MobileDeviceLinkedAtUtc = DateTime.UtcNow;
            }
            else if (!string.Equals(user.MobileDeviceId, deviceId, StringComparison.Ordinal))
            {
                throw new ForbiddenException("This account is already linked to another device.");
            }
            // else: same device as before, proceed normally.
        }

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
            ExpiresAtUtc = DateTime.UtcNow.AddDays(7),
            CreatedAtUtc = DateTime.UtcNow
        };

        _db.RefreshTokens.Add(refreshTokenEntity);

        try
        {
            await _db.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException) when (isMobile)
        {
            // Another request bound this device to a different account in the meantime;
            // the unique index rejected this save.
            throw new ForbiddenException("This device is already linked to another account.");
        }

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

    // Unlinks the account's bound mobile device after confirming the current password.
    public async Task UnlinkDeviceAsync(Guid userId, UnlinkDeviceRequestDto request, CancellationToken cancellationToken = default)
    {
        var user = await _db.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);

        if (user is null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
            throw new UnauthorizedException("Invalid password.");

        user.MobileDeviceId = null;
        user.MobileDeviceLinkedAtUtc = null;
        user.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync(cancellationToken);
    }

    private Task<bool> EmailExistsAsync(string email, CancellationToken cancellationToken) =>
        _db.Users.AsNoTracking().AnyAsync(u => u.Email == email, cancellationToken);

    private Task<bool> StudentIdExistsAsync(string studentId, CancellationToken cancellationToken) =>
        _db.Users.AsNoTracking().AnyAsync(u => u.StudentId == studentId, cancellationToken);

    private static UserDto ToDto(User user) => new()
    {
        Id = user.Id,
        FirstName = user.FirstName,
        LastName = user.LastName,
        PhoneNumber = user.PhoneNumber,
        Email = user.Email,
        StudentId = user.StudentId,
        Role = user.Role.ToString(),
        CreatedAt = user.CreatedAt
    };

    public async Task ForgotPasswordAsync(
     ForgotPasswordRequestDto request,
     CancellationToken cancellationToken = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await _db.Users
            .FirstOrDefaultAsync(
                u => u.Email == email,
                cancellationToken);

        // Do not reveal whether the email exists.
        if (user is null)
            return;

        var now = DateTime.UtcNow;

        // Allow a resend only after 60 seconds.
        if (user.PasswordResetCodeSentAtUtc.HasValue &&
            user.PasswordResetCodeSentAtUtc.Value > now.AddSeconds(-60))
        {
            return;
        }

        // Do not reset the failed-attempt limit while an active code
        // is locked. The user can use the link or wait for expiration.
        if (user.PasswordResetCodeFailedAttempts >= 5 &&
            user.PasswordResetCodeExpiresAtUtc.HasValue &&
            user.PasswordResetCodeExpiresAtUtc.Value > now)
        {
            return;
        }

        // Reset the counter only when the previous code has expired.
        if (!user.PasswordResetCodeExpiresAtUtc.HasValue ||
            user.PasswordResetCodeExpiresAtUtc.Value <= now)
        {
            user.PasswordResetCodeFailedAttempts = 0;
        }

        // Generate the reset-link token.
        var tokenBytes = RandomNumberGenerator.GetBytes(32);
        var token = Convert.ToBase64String(tokenBytes);

        var tokenHash = Convert.ToBase64String(
            SHA256.HashData(tokenBytes));

        // Generate a secure 5-digit code, including possible leading zeros.
        var code = RandomNumberGenerator
            .GetInt32(0, 100000)
            .ToString("D5");

        var codeHash = _passwordHasher.Hash(code);

        // Save reset-link data.
        user.PasswordResetTokenHash = tokenHash;
        user.PasswordResetTokenExpiresAt = now.AddHours(1);
        user.PasswordResetTokenUsedAt = null;

        // Save reset-code data.
        user.PasswordResetCodeHash = codeHash;
        user.PasswordResetCodeExpiresAtUtc = now.AddMinutes(10);
        user.PasswordResetCodeSentAtUtc = now;

        await _db.SaveChangesAsync(cancellationToken);

        await _emailService.SendPasswordResetEmailAsync(
            user.Email,
            token,
            code,
            cancellationToken);
    }

    public async Task<bool> ResetPasswordAsync(
     ResetPasswordRequestDto request,
     CancellationToken cancellationToken = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await _db.Users
            .FirstOrDefaultAsync(
                u => u.Email == email,
                cancellationToken);

        if (user is null ||
            user.PasswordResetTokenHash is null ||
            user.PasswordResetTokenExpiresAt is null ||
            user.PasswordResetTokenExpiresAt <= DateTime.UtcNow ||
            user.PasswordResetTokenUsedAt is not null)
        {
            return false;
        }

        byte[] tokenBytes;

        try
        {
            tokenBytes = Convert.FromBase64String(request.Token);
        }
        catch (FormatException)
        {
            return false;
        }

        var tokenHash = Convert.ToBase64String(
            SHA256.HashData(tokenBytes));

        if (tokenHash != user.PasswordResetTokenHash)
            return false;

        var now = DateTime.UtcNow;

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        user.UpdatedAt = now;

        // Invalidate the reset link.
        user.PasswordResetTokenHash = null;
        user.PasswordResetTokenExpiresAt = null;
        user.PasswordResetTokenUsedAt = now;

        // Invalidate the reset code too.
        user.PasswordResetCodeHash = null;
        user.PasswordResetCodeExpiresAtUtc = null;
        user.PasswordResetCodeSentAtUtc = null;
        user.PasswordResetCodeFailedAttempts = 0;

        await RevokeActiveRefreshTokensAsync(
            user.Id,
            now,
            cancellationToken);

        await _db.SaveChangesAsync(cancellationToken);

        return true;
    }
    public async Task<bool> ResetPasswordWithCodeAsync(
    ResetPasswordWithCodeRequestDto request,
    CancellationToken cancellationToken = default)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await _db.Users
            .FirstOrDefaultAsync(
                u => u.Email == email,
                cancellationToken);

        var now = DateTime.UtcNow;

        if (user is null ||
            user.PasswordResetCodeHash is null ||
            user.PasswordResetCodeExpiresAtUtc is null ||
            user.PasswordResetCodeExpiresAtUtc <= now ||
            user.PasswordResetCodeFailedAttempts >= 5)
        {
            return false;
        }

        // Verify the submitted code against the stored hash.
        if (!_passwordHasher.Verify(
                request.Code,
                user.PasswordResetCodeHash))
        {
            user.PasswordResetCodeFailedAttempts++;

            await _db.SaveChangesAsync(cancellationToken);

            return false;
        }

        // The code is valid.
        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        user.UpdatedAt = now;

        // Invalidate both reset methods.
        user.PasswordResetTokenHash = null;
        user.PasswordResetTokenExpiresAt = null;
        user.PasswordResetTokenUsedAt = now;

        user.PasswordResetCodeHash = null;
        user.PasswordResetCodeExpiresAtUtc = null;
        user.PasswordResetCodeSentAtUtc = null;
        user.PasswordResetCodeFailedAttempts = 0;

        await RevokeActiveRefreshTokensAsync(
            user.Id,
            now,
            cancellationToken);

        await _db.SaveChangesAsync(cancellationToken);

        return true;
    }
    private async Task RevokeActiveRefreshTokensAsync(
    Guid userId,
    DateTime now,
    CancellationToken cancellationToken)
    {
        var activeTokens = await _db.RefreshTokens
            .Where(t =>
                t.UserId == userId &&
                t.RevokedAtUtc == null)
            .ToListAsync(cancellationToken);

        foreach (var token in activeTokens)
        {
            token.RevokedAtUtc = now;
        }
    }
}