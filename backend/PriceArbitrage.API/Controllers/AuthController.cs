using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PriceArbitrage.Application.DTOs.Auth;
using PriceArbitrage.Application.Interfaces;
using System.Security.Claims;

namespace PriceArbitrage.API.Controllers;

/// <summary>
/// Controller cho Authentication (Đăng ký, Đăng nhập)
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IAuthService authService, ILogger<AuthController> logger)
    {
        _authService = authService;
        _logger = logger;
    }

    /// <summary>
    /// Đăng ký user mới
    /// </summary>
    /// <param name="request">Thông tin đăng ký</param>
    /// <returns>Token và thông tin user</returns>
    /// <response code="200">Đăng ký thành công</response>
    /// <response code="400">Dữ liệu không hợp lệ hoặc email/username đã tồn tại</response>
    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var response = await _authService.RegisterAsync(request);

        if (response == null)
        {
            return BadRequest(new
            {
                message = "Đăng ký thất bại. Email hoặc Username có thể đã được sử dụng.",
                errors = ModelState
            });
        }

        return Ok(response);
    }

    /// <summary>
    /// Đăng nhập user
    /// </summary>
    /// <param name="request">Thông tin đăng nhập</param>
    /// <returns>Token và thông tin user</returns>
    /// <response code="200">Đăng nhập thành công</response>
    /// <response code="401">Email hoặc password không đúng</response>
    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var response = await _authService.LoginAsync(request);

        if (response == null)
        {
            return Unauthorized(new
            {
                message = "Email hoặc password không đúng. Vui lòng thử lại."
            });
        }

        return Ok(response);
    }

    /// <summary>
    /// Lấy thông tin user hiện tại
    /// </summary>
    /// <returns>Thông tin user</returns>
    /// <response code="200">Lấy thông tin thành công</response>
    /// <response code="401">Chưa đăng nhập</response>
    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(UserInfoResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetCurrentUser()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        
        if (string.IsNullOrEmpty(userId))
        {
            return Unauthorized(new { message = "Không tìm thấy thông tin user" });
        }

        var user = await _authService.GetCurrentUserAsync(userId);

        if (user == null)
        {
            return NotFound(new { message = "Không tìm thấy user" });
        }

        return Ok(user);
    }
}
