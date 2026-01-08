namespace PriceArbitrage.API.Models;

/// <summary>
/// Cấu hình JWT Settings
/// </summary>
public class JwtSettings
{
    public string SecretKey { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int ExpirationMinutes { get; set; } = 60; // Default 60 phút
}
