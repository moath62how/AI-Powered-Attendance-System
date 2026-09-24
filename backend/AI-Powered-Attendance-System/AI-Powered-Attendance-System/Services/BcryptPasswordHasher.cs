namespace AI_Powered_Attendance_System.Services;

public class BcryptPasswordHasher : IPasswordHasher
{
    // Work factor 12 is a good balance of security and speed today.
    // The factor is stored inside the hash, so raising it later won't break existing users.
    private const int WorkFactor = 12;

    public string Hash(string password) =>
        BCrypt.Net.BCrypt.HashPassword(password, WorkFactor);

    public bool Verify(string password, string passwordHash) =>
        BCrypt.Net.BCrypt.Verify(password, passwordHash);
}