namespace AI_Powered_Attendance_System.Services
{
    public interface IEmailService
    {
        Task SendPasswordResetLinkEmailAsync(
           string email,
           string resetToken,
           CancellationToken cancellationToken = default);


        Task SendPasswordResetCodeEmailAsync(
           string email,
           string resetCode,
           CancellationToken cancellationToken = default);
    }
}
