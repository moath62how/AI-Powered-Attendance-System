using AI_Powered_Attendance_System.Settings;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;

namespace AI_Powered_Attendance_System.Services;

public class EmailService : IEmailService
{
    private readonly EmailSettings _settings;

    public EmailService(IOptions<EmailSettings> options)
    {
        _settings = options.Value;
    }

    public async Task SendPasswordResetEmailAsync(
        string email,
        string resetToken,
        string resetCode,
        CancellationToken cancellationToken = default)
    {
        var message = new MimeMessage();

        message.From.Add(
            new MailboxAddress(
                _settings.FromName,
                _settings.FromEmail));

        message.To.Add(
            MailboxAddress.Parse(email));

        message.Subject = "Password Reset";

        var resetLink =
            $"{_settings.ResetPasswordUrl}?email={Uri.EscapeDataString(email)}&token={Uri.EscapeDataString(resetToken)}";

        message.Body = new BodyBuilder
        {
            HtmlBody = $"""
                <h2>Password Reset</h2>

                <p>
                    We received a request to reset your password.
                </p>

                <h3>Option 1: Reset using the link</h3>

                <p>
                    <a href="{resetLink}">Reset Password</a>
                </p>

                <p>This link will expire in 1 hour.</p>

                <hr />

                <h3>Option 2: Reset using the verification code</h3>

                <p>Your 5-digit password reset code is:</p>

                <h1 style="letter-spacing: 8px; font-family: monospace;">
                    {resetCode}
                </h1>

                <p>
                    This code will expire in 10 minutes.
                </p>

                <p>
                    Do not share this code with anyone.
                </p>

                <p>
                    If you did not request a password reset,
                    you can safely ignore this email.
                </p>
                """
        }.ToMessageBody();

        using var smtp = new SmtpClient();

        await smtp.ConnectAsync(
            _settings.Host,
            _settings.Port,
            SecureSocketOptions.StartTls,
            cancellationToken);

        await smtp.AuthenticateAsync(
            _settings.Username,
            _settings.Password,
            cancellationToken);

        await smtp.SendAsync(
            message,
            cancellationToken);

        await smtp.DisconnectAsync(
            true,
            cancellationToken);
    }
}