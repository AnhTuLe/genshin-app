using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using PriceArbitrage.Application.DTOs.Auth;
using PriceArbitrage.Application.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace PriceArbitrage.Infrastructure.Services;

/// <summary>
/// Implementation của IAuthService
/// </summary>
public class AuthService : IAuthService
{
    private readonly UserManager<IdentityUser> _userManager;
    private readonly SignInManager<IdentityUser> _signInManager;
    private readonly ILogger<AuthService> _logger;
    private readonly string _secretKey;
    private readonly string _issuer;
    private readonly string _audience;
    private readonly int _expirationMinutes;

    public AuthService(
        UserManager<IdentityUser> userManager,
        SignInManager<IdentityUser> signInManager,
        ILogger<AuthService> logger,
        IConfiguration configuration)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _logger = logger;
        
        // Đọc JWT settings từ configuration (không phụ thuộc vào API layer)
        _secretKey = configuration["JwtSettings:SecretKey"] 
            ?? "YourVeryLongAndSecureSecretKeyForJWTTokenGeneration2024!@#$%^&*()MustBeAtLeast32Characters";
        _issuer = configuration["JwtSettings:Issuer"] ?? "PriceArbitrageAPI";
        _audience = configuration["JwtSettings:Audience"] ?? "PriceArbitrageClient";
        _expirationMinutes = int.TryParse(configuration["JwtSettings:ExpirationMinutes"], out var exp) ? exp : 60;
    }

    public async Task<AuthResponse?> RegisterAsync(RegisterRequest request)
    {
        try
        {
            // Kiểm tra email đã tồn tại chưa
            var existingUser = await _userManager.FindByEmailAsync(request.Email);
            if (existingUser != null)
            {
                _logger.LogWarning("Email {Email} đã được sử dụng", request.Email);
                return null;
            }

            // Kiểm tra username đã tồn tại chưa
            var existingUserByUsername = await _userManager.FindByNameAsync(request.UserName);
            if (existingUserByUsername != null)
            {
                _logger.LogWarning("Username {UserName} đã được sử dụng", request.UserName);
                return null;
            }

            // Tạo user mới
            var user = new IdentityUser
            {
                UserName = request.UserName,
                Email = request.Email,
                EmailConfirmed = false // Có thể thêm email confirmation sau
            };

            var result = await _userManager.CreateAsync(user, request.Password);

            if (!result.Succeeded)
            {
                _logger.LogWarning("Tạo user thất bại: {Errors}", string.Join(", ", result.Errors.Select(e => e.Description)));
                return null;
            }

            // Gán role "User" mặc định
            await _userManager.AddToRoleAsync(user, "User");

            // Tạo JWT token
            var roles = await _userManager.GetRolesAsync(user);
            var token = GenerateJwtToken(user, roles);

            _logger.LogInformation("User {Email} đã được đăng ký thành công", request.Email);

            return new AuthResponse
            {
                Token = token,
                ExpiresAt = DateTime.UtcNow.AddMinutes(_expirationMinutes),
                UserId = user.Id,
                Email = user.Email ?? string.Empty,
                UserName = user.UserName ?? string.Empty,
                Roles = roles
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi đăng ký user {Email}", request.Email);
            return null;
        }
    }

    public async Task<AuthResponse?> LoginAsync(LoginRequest request)
    {
        try
        {
            // Tìm user theo email
            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null)
            {
                _logger.LogWarning("Email {Email} không tồn tại", request.Email);
                return null;
            }

            // Kiểm tra password
            var result = await _signInManager.CheckPasswordSignInAsync(user, request.Password, lockoutOnFailure: true);

            if (!result.Succeeded)
            {
                if (result.IsLockedOut)
                {
                    _logger.LogWarning("Tài khoản {Email} đã bị khóa", request.Email);
                }
                else
                {
                    _logger.LogWarning("Password không đúng cho email {Email}", request.Email);
                }
                return null;
            }

            // Lấy roles của user
            var roles = await _userManager.GetRolesAsync(user);

            // Tạo JWT token
            var token = GenerateJwtToken(user, roles);

            _logger.LogInformation("User {Email} đã đăng nhập thành công", request.Email);

            return new AuthResponse
            {
                Token = token,
                ExpiresAt = DateTime.UtcNow.AddMinutes(_expirationMinutes),
                UserId = user.Id,
                Email = user.Email ?? string.Empty,
                UserName = user.UserName ?? string.Empty,
                Roles = roles
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi đăng nhập user {Email}", request.Email);
            return null;
        }
    }

    public async Task<UserInfoResponse?> GetCurrentUserAsync(string userId)
    {
        try
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
            {
                return null;
            }

            var roles = await _userManager.GetRolesAsync(user);

            return new UserInfoResponse
            {
                UserId = user.Id,
                Email = user.Email ?? string.Empty,
                UserName = user.UserName ?? string.Empty,
                Roles = roles,
                EmailConfirmed = user.EmailConfirmed
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Lỗi khi lấy thông tin user {UserId}", userId);
            return null;
        }
    }

    /// <summary>
    /// Tạo JWT token
    /// </summary>
    private string GenerateJwtToken(IdentityUser user, IList<string> roles)
    {
        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id),
            new Claim(JwtRegisteredClaimNames.Email, user.Email ?? string.Empty),
            new Claim(JwtRegisteredClaimNames.UniqueName, user.UserName ?? string.Empty),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        // Thêm roles vào claims
        foreach (var role in roles)
        {
            claims.Add(new Claim(ClaimTypes.Role, role));
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_secretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _issuer,
            audience: _audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_expirationMinutes),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
