namespace AI_Powered_Attendance_System.DTOs.Auth;

public class LoginRequestDto
{
    public string Identifier { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;

    // "Web" or "Mobile". Omit or "Web" = no device restriction.
    public string? ClientType { get; set; }

    // Required when ClientType is "Mobile". A stable GUID generated once
    // by the mobile app and stored in Keychain/Keystore.
    public string? DeviceId { get; set; }
}