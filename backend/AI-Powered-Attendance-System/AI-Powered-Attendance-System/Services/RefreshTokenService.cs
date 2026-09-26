using System.Security.Cryptography;
using System.Text;

namespace AI_Powered_Attendance_System.Services
{
    public class RefreshTokenService : IRefreshTokenService
    {
       
            public (string Token, string TokenHash) CreateToken()
        {
            var tokenBytes = RandomNumberGenerator.GetBytes(64);

            var token = Convert.ToBase64String(tokenBytes);

            var tokenHash = HashToken(token);

            return (token, tokenHash);
        }
        public string HashToken(string token)
        {
            return Convert.ToBase64String(
                SHA256.HashData(Encoding.UTF8.GetBytes(token)));
        }
    }
}