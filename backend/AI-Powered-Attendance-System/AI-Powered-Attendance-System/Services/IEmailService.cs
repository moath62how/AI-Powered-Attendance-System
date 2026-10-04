namespace AI_Powered_Attendance_System.Services
{
    public interface IEmailService
    {
        Task SendPasswordResetEmailAsync(string email,string resetToken, CancellationToken cancellationToken = default);
    }
}
