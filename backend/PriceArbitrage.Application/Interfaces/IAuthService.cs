using PriceArbitrage.Application.DTOs.Auth;

namespace PriceArbitrage.Application.Interfaces;

/// <summary>
/// Interface cho Authentication Service
/// </summary>
public interface IAuthService
{
    /// <summary>
    /// Đăng ký user mới
    /// </summary>
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);

    /// <summary>
    /// Đăng nhập user
    /// </summary>
    Task<AuthResponse?> LoginAsync(LoginRequest request);

    /// <summary>
    /// Lấy thông tin user hiện tại
    /// </summary>
    Task<UserInfoResponse?> GetCurrentUserAsync(string userId);
}
