using System.ComponentModel.DataAnnotations;

namespace PriceArbitrage.Application.DTOs.Auth;

/// <summary>
/// Request DTO cho đăng nhập
/// </summary>
public class LoginRequest
{
    [Required(ErrorMessage = "Email là bắt buộc")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password là bắt buộc")]
    public string Password { get; set; } = string.Empty;
}
