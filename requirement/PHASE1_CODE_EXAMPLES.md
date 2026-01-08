# 💻 Phase 1: Code Examples Reference

Code examples nhỏ để tham khảo khi implement. **Đây là reference, không phải code đầy đủ.**

---

## 📘 STEP 2: Setup Identity

### Example 1: ApplicationUser Class

```csharp
// Domain/Entities/ApplicationUser.cs
using Microsoft.AspNetCore.Identity;

namespace PriceArbitrage.Domain.Entities
{
    public class ApplicationUser : IdentityUser
    {
        // Custom properties
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties (nếu cần)
        // public virtual ICollection<Watchlist> Watchlists { get; set; }
    }
}
```

**Notes:**
- Extends `IdentityUser` (có sẵn: Id, Email, UserName, PasswordHash, etc.)
- Thêm custom properties nếu cần
- `CreatedAt` tự động set khi tạo

---

### Example 2: Identity DbContext

```csharp
// Infrastructure/Data/ApplicationDbContext.cs
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using PriceArbitrage.Domain.Entities;

namespace PriceArbitrage.Infrastructure.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // Add your DbSets here later
        // public DbSet<Product> Products { get; set; }
        
        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);
            
            // Custom configurations nếu cần
            // builder.Entity<ApplicationUser>(entity =>
            // {
            //     entity.Property(e => e.FirstName).HasMaxLength(100);
            // });
        }
    }
}
```

**Notes:**
- Extends `IdentityDbContext<ApplicationUser>`
- Base class tự động tạo Identity tables
- Override `OnModelCreating` để custom configuration

---

### Example 3: Configure Identity trong Program.cs

```csharp
// Program.cs - Add này vào ConfigureServices
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    // Password settings
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = true;
    options.Password.RequireLowercase = true;
    
    // User settings
    options.User.RequireUniqueEmail = true;
    
    // Lockout settings
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
    options.Lockout.MaxFailedAccessAttempts = 5;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Add DbContext
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
```

**Notes:**
- `AddIdentity` configures Identity services
- `AddEntityFrameworkStores` kết nối với database
- `AddDefaultTokenProviders` cho email confirmation, password reset

---

## 📘 STEP 3: User Registration

### Example 4: RegisterRequest DTO

```csharp
// Application/DTOs/Auth/RegisterRequest.cs
using System.ComponentModel.DataAnnotations;

namespace PriceArbitrage.Application.DTOs.Auth
{
    public class RegisterRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        
        [Required]
        [StringLength(100, MinimumLength = 8)]
        public string Password { get; set; } = string.Empty;
        
        [Required]
        [Compare("Password")]
        public string ConfirmPassword { get; set; } = string.Empty;
        
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
    }
}
```

**Notes:**
- Data annotations để validate
- `[Compare]` để check ConfirmPassword match Password
- DTO pattern: tách request model khỏi entity

---

### Example 5: RegisterResponse DTO

```csharp
// Application/DTOs/Auth/RegisterResponse.cs
namespace PriceArbitrage.Application.DTOs.Auth
{
    public class RegisterResponse
    {
        public bool Success { get; set; }
        public string? UserId { get; set; }
        public string? Email { get; set; }
        public List<string> Errors { get; set; } = new();
    }
}
```

**Notes:**
- Simple response model
- List errors nếu có validation errors

---

### Example 6: UserService - Registration Logic

```csharp
// Application/Services/IUserService.cs
using PriceArbitrage.Application.DTOs.Auth;

namespace PriceArbitrage.Application.Services
{
    public interface IUserService
    {
        Task<RegisterResponse> RegisterAsync(RegisterRequest request);
    }
}
```

```csharp
// Application/Services/UserService.cs
using Microsoft.AspNetCore.Identity;
using PriceArbitrage.Application.DTOs.Auth;
using PriceArbitrage.Domain.Entities;

namespace PriceArbitrage.Application.Services
{
    public class UserService : IUserService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        
        public UserService(UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
        }
        
        public async Task<RegisterResponse> RegisterAsync(RegisterRequest request)
        {
            // Check if user exists
            var existingUser = await _userManager.FindByEmailAsync(request.Email);
            if (existingUser != null)
            {
                return new RegisterResponse
                {
                    Success = false,
                    Errors = new List<string> { "Email already exists" }
                };
            }
            
            // Create new user
            var user = new ApplicationUser
            {
                Email = request.Email,
                UserName = request.Email, // Thường dùng Email làm UserName
                FirstName = request.FirstName,
                LastName = request.LastName
            };
            
            // Create user với password (Identity tự hash password)
            var result = await _userManager.CreateAsync(user, request.Password);
            
            if (result.Succeeded)
            {
                return new RegisterResponse
                {
                    Success = true,
                    UserId = user.Id,
                    Email = user.Email
                };
            }
            
            // Collect errors
            return new RegisterResponse
            {
                Success = false,
                Errors = result.Errors.Select(e => e.Description).ToList()
            };
        }
    }
}
```

**Notes:**
- Inject `UserManager<ApplicationUser>` qua DI
- `CreateAsync` tự động hash password
- `result.Errors` chứa Identity validation errors

---

### Example 7: AuthController - Register Endpoint

```csharp
// API/Controllers/AuthController.cs
using Microsoft.AspNetCore.Mvc;
using PriceArbitrage.Application.DTOs.Auth;
using PriceArbitrage.Application.Services;

namespace PriceArbitrage.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IUserService _userService;
        
        public AuthController(IUserService userService)
        {
            _userService = userService;
        }
        
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            // Model validation (tự động bởi ASP.NET Core)
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            
            var result = await _userService.RegisterAsync(request);
            
            if (result.Success)
            {
                return Ok(result);
            }
            
            return BadRequest(result);
        }
    }
}
```

**Notes:**
- `[ApiController]` tự động validate ModelState
- Return appropriate status codes
- 200 OK cho success, 400 BadRequest cho errors

---

## 📘 STEP 4: JWT Authentication

### Example 8: JWT Settings Configuration

```csharp
// Infrastructure/Settings/JwtSettings.cs
namespace PriceArbitrage.Infrastructure.Settings
{
    public class JwtSettings
    {
        public string SecretKey { get; set; } = string.Empty;
        public string Issuer { get; set; } = string.Empty;
        public string Audience { get; set; } = string.Empty;
        public int ExpirationMinutes { get; set; } = 60;
    }
}
```

```json
// appsettings.json
{
  "JwtSettings": {
    "SecretKey": "YourVeryLongAndSecureSecretKeyHere_Min32Characters",
    "Issuer": "PriceArbitrageAPI",
    "Audience": "PriceArbitrageClient",
    "ExpirationMinutes": 60
  }
}
```

**Notes:**
- SecretKey phải dài và phức tạp (min 32 characters)
- Issuer: Tên của API
- Audience: Tên của client app

---

### Example 9: JWT Service

```csharp
// Application/Services/IJwtService.cs
using PriceArbitrage.Domain.Entities;
using System.Security.Claims;

namespace PriceArbitrage.Application.Services
{
    public interface IJwtService
    {
        string GenerateToken(ApplicationUser user);
    }
}
```

```csharp
// Infrastructure/Services/JwtService.cs
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using PriceArbitrage.Application.Services;
using PriceArbitrage.Domain.Entities;
using PriceArbitrage.Infrastructure.Settings;

namespace PriceArbitrage.Infrastructure.Services
{
    public class JwtService : IJwtService
    {
        private readonly JwtSettings _jwtSettings;
        
        public JwtService(IOptions<JwtSettings> jwtSettings)
        {
            _jwtSettings = jwtSettings.Value;
        }
        
        public string GenerateToken(ApplicationUser user)
        {
            // Create claims
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Email, user.Email ?? string.Empty),
                new Claim(ClaimTypes.Name, user.UserName ?? string.Empty)
            };
            
            // Create signing credentials
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.SecretKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            
            // Create token
            var token = new JwtSecurityToken(
                issuer: _jwtSettings.Issuer,
                audience: _jwtSettings.Audience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(_jwtSettings.ExpirationMinutes),
                signingCredentials: credentials
            );
            
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
```

**Notes:**
- Claims chứa user info
- Signing credentials dùng để ký token
- Token có expiration time
- Return token string

---

### Example 10: Configure JWT trong Program.cs

```csharp
// Program.cs
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

// Add JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>()!;

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings.Issuer,
        ValidAudience = jwtSettings.Audience,
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtSettings.SecretKey))
    };
});

// Don't forget to add UseAuthentication!
app.UseAuthentication(); // Phải đặt TRƯỚC UseAuthorization
app.UseAuthorization();
```

**Notes:**
- `UseAuthentication` phải đặt TRƯỚC `UseAuthorization`
- TokenValidationParameters config cách verify token

---

### Example 11: Login Endpoint

```csharp
// Application/DTOs/Auth/LoginRequest.cs
public class LoginRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    public string Password { get; set; } = string.Empty;
}
```

```csharp
// Application/DTOs/Auth/LoginResponse.cs
public class LoginResponse
{
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public string UserId { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}
```

```csharp
// UserService - Add login method
public async Task<LoginResponse?> LoginAsync(LoginRequest request)
{
    var user = await _userManager.FindByEmailAsync(request.Email);
    if (user == null)
    {
        return null; // User not found
    }
    
    // Verify password
    var isPasswordValid = await _userManager.CheckPasswordAsync(user, request.Password);
    if (!isPasswordValid)
    {
        return null; // Invalid password
    }
    
    // Generate token
    var token = _jwtService.GenerateToken(user);
    
    return new LoginResponse
    {
        Token = token,
        ExpiresAt = DateTime.UtcNow.AddMinutes(_jwtSettings.ExpirationMinutes),
        UserId = user.Id,
        Email = user.Email ?? string.Empty
    };
}
```

```csharp
// AuthController - Login endpoint
[HttpPost("login")]
public async Task<IActionResult> Login([FromBody] LoginRequest request)
{
    if (!ModelState.IsValid)
    {
        return BadRequest(ModelState);
    }
    
    var result = await _userService.LoginAsync(request);
    
    if (result == null)
    {
        return Unauthorized(new { message = "Invalid email or password" });
    }
    
    return Ok(result);
}
```

**Notes:**
- `CheckPasswordAsync` verify password (Identity tự compare với hash)
- Return null nếu invalid (không expose thông tin chi tiết)
- Return token nếu success

---

## 📘 STEP 5: Authorization

### Example 12: Protect Endpoint

```csharp
[HttpGet("profile")]
[Authorize] // Require authentication
public async Task<IActionResult> GetProfile()
{
    // Get user ID from claims
    var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    
    if (string.IsNullOrEmpty(userId))
    {
        return Unauthorized();
    }
    
    var user = await _userManager.FindByIdAsync(userId);
    
    return Ok(new
    {
        Id = user.Id,
        Email = user.Email,
        FirstName = user.FirstName,
        LastName = user.LastName
    });
}
```

**Notes:**
- `[Authorize]` require authentication
- `User` object chứa claims từ JWT token
- Extract UserId từ claims

---

### Example 13: Role-based Authorization

```csharp
// Assign role khi register
await _userManager.AddToRoleAsync(user, "User");

// Protect endpoint với role
[HttpGet("admin/users")]
[Authorize(Roles = "Admin")]
public async Task<IActionResult> GetAllUsers()
{
    // Only Admin can access
    var users = _userManager.Users.ToList();
    return Ok(users);
}
```

**Notes:**
- `AddToRoleAsync` assign role
- `[Authorize(Roles = "Admin")]` require role

---

## 📘 STEP 6: Frontend Auth

### Example 14: Axios API Service

```typescript
// src/services/api.ts
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:5000/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - Add token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor - Handle 401
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

**Notes:**
- Request interceptor: tự động thêm token vào header
- Response interceptor: auto logout nếu 401

---

### Example 15: Auth Context

```typescript
// src/contexts/AuthContext.tsx
import React, { createContext, useContext, useState, useEffect } from 'react';
import api from '../services/api';

interface User {
  id: string;
  email: string;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);

  useEffect(() => {
    // Load token from localStorage on mount
    const savedToken = localStorage.getItem('token');
    if (savedToken) {
      setToken(savedToken);
      // Optionally: fetch user info
    }
  }, []);

  const login = async (email: string, password: string) => {
    const response = await api.post('/auth/login', { email, password });
    const { token: newToken, userId, email: userEmail } = response.data;
    
    setToken(newToken);
    setUser({ id: userId, email: userEmail });
    localStorage.setItem('token', newToken);
  };

  const register = async (email: string, password: string) => {
    await api.post('/auth/register', { email, password });
    // After registration, login
    await login(email, password);
  };

  const logout = () => {
    setToken(null);
    setUser(null);
    localStorage.removeItem('token');
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        login,
        register,
        logout,
        isAuthenticated: !!token,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

**Notes:**
- Context để share auth state
- Store token trong localStorage
- `useAuth` hook để dùng trong components

---

### Example 16: Login Page

```typescript
// src/pages/Login.tsx
import { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    try {
      await login(email, password);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Login failed');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        required
      />
      {error && <div className="error">{error}</div>}
      <button type="submit">Login</button>
    </form>
  );
};
```

**Notes:**
- Simple form với controlled inputs
- Handle errors
- Redirect sau khi login success

---

### Example 17: Protected Route

```typescript
// src/components/ProtectedRoute.tsx
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
};
```

**Usage:**
```typescript
// App.tsx
<Route
  path="/dashboard"
  element={
    <ProtectedRoute>
      <Dashboard />
    </ProtectedRoute>
  }
/>
```

**Notes:**
- Check authentication
- Redirect nếu chưa login

---

## ⚠️ Important Notes

1. **Secret Key**: Never commit secret key vào Git! Dùng User Secrets hoặc Environment Variables

2. **Password Hashing**: Identity tự động hash, không cần tự làm

3. **Token Storage**: localStorage không phải cách an toàn nhất, nhưng OK cho learning

4. **Error Messages**: Không expose chi tiết errors trong production

5. **Validation**: Always validate input ở cả client và server

---

## 📝 Reference Checklist

Khi implement, check:
- [ ] DTOs có validation attributes
- [ ] Services inject dependencies qua constructor
- [ ] Controllers return appropriate status codes
- [ ] Error handling ở mọi nơi
- [ ] JWT secret key không commit vào Git
- [ ] Frontend có error handling
- [ ] Token được add vào requests

---

**Remember**: Đây là examples để reference. Bạn nên:
- Hiểu cách hoạt động trước
- Tự implement
- Test thường xuyên
- Modify theo nhu cầu

**Good luck!** 🚀
