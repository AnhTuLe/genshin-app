namespace PriceArbitrage.Application.DTOs.Auth;

/// <summary>
/// Response DTO cho thông tin user hiện tại
/// </summary>
public class UserInfoResponse
{
    public string UserId { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public IList<string> Roles { get; set; } = new List<string>();
    public bool EmailConfirmed { get; set; }
}
