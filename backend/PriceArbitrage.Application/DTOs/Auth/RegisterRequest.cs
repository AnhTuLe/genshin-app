using System.ComponentModel.DataAnnotations;

namespace PriceArbitrage.Application.DTOs.Auth;

/// <summary>
/// Request DTO cho đăng ký user mới
/// </summary>
public class RegisterRequest
{
    [Required(ErrorMessage = "Email là bắt buộc")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Username là bắt buộc")]
    [MinLength(3, ErrorMessage = "Username phải có ít nhất 3 ký tự")]
    [MaxLength(50, ErrorMessage = "Username không được vượt quá 50 ký tự")]
    public string UserName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password là bắt buộc")]
    [MinLength(8, ErrorMessage = "Password phải có ít nhất 8 ký tự")]
    [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$", 
        ErrorMessage = "Password phải chứa ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt")]
    public string Password { get; set; } = string.Empty;

    [Required(ErrorMessage = "Xác nhận password là bắt buộc")]
    [Compare("Password", ErrorMessage = "Password và xác nhận password không khớp")]
    public string ConfirmPassword { get; set; } = string.Empty;
}
