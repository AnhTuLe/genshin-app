# 🏗️ Tại sao tổ chức code theo Clean Architecture?

## 📋 Câu hỏi

**"Tại sao lại tách code thành các layers như vậy? Tại sao không đặt tất cả vào một project cho đơn giản?"**

---

## 🎯 Trả lời ngắn gọn

Tách code thành các layers giúp:
- ✅ **Dễ bảo trì** - Sửa bug ở một nơi không ảnh hưởng nơi khác
- ✅ **Dễ test** - Test từng layer độc lập
- ✅ **Dễ mở rộng** - Thêm tính năng mới không phá vỡ code cũ
- ✅ **Dễ làm việc nhóm** - Nhiều người code cùng lúc không conflict
- ✅ **Tái sử dụng** - Business logic dùng được cho nhiều frontend (Web, Mobile, Desktop)

---

## 🔍 Ví dụ cụ thể: Auth API

Hãy xem cách chúng ta tổ chức Auth API:

### Cấu trúc hiện tại:

```
Domain Layer (Core - Trung tâm) ⭐
├── Entities/                             ← Business entities (User, Product, Order...)
├── ValueObjects/                         ← Value objects (Email, Money, Address...)
├── Enums/                                ← Enumerations (UserRole, OrderStatus...)
└── Interfaces/                           ← Repository interfaces (IUserRepository...)
    └── ❌ KHÔNG phụ thuộc layer nào!

Application Layer (Business Logic)
├── DTOs/Auth/RegisterRequest.cs        ← Định nghĩa dữ liệu vào
├── DTOs/Auth/LoginRequest.cs            ← Định nghĩa dữ liệu vào
├── DTOs/Auth/AuthResponse.cs            ← Định nghĩa dữ liệu ra
├── DTOs/Auth/UserInfoResponse.cs        ← Định nghĩa dữ liệu ra
└── Interfaces/IAuthService.cs           ← Định nghĩa "CÁCH LÀM" (interface)
    └── Phụ thuộc: Domain Layer

Infrastructure Layer (Implementation)
└── Services/AuthService.cs              ← Thực hiện "CÁCH LÀM" (implementation)
    └── Phụ thuộc: Domain + Application

API Layer (Presentation)
├── Controllers/AuthController.cs        ← Nhận request, gọi service
├── Models/JwtSettings.cs                ← Cấu hình riêng cho API
└── Program.cs                           ← Setup và cấu hình
    └── Phụ thuộc: Application + Infrastructure
```

---

## 💡 Tại sao tách như vậy?

### 0. Domain Layer - Core (Trung tâm) ⭐

**Vị trí:** `Domain/Entities/`, `Domain/ValueObjects/`, `Domain/Enums/`, `Domain/Interfaces/`

**Chứa:**
- ✅ **Entities** - Business entities (User, Product, Order, etc.)
- ✅ **Value Objects** - Immutable objects (Email, Money, Address, etc.)
- ✅ **Enums** - Enumerations (UserRole, OrderStatus, etc.)
- ✅ **Interfaces** - Repository/service interfaces (IUserRepository, IEmailService, etc.)
- ✅ **Business Rules** - Core business logic và validation

**Ví dụ:**

```csharp
// Domain/Entities/User.cs
namespace PriceArbitrage.Domain.Entities;

public class User
{
    public Guid Id { get; private set; }
    public string Email { get; private set; }
    public string UserName { get; private set; }
    public UserRole Role { get; private set; }
    public DateTime CreatedAt { get; private set; }
    
    // Business logic methods
    public bool CanDelete()
    {
        return Role != UserRole.Admin;  // Business rule: Admin không thể bị xóa
    }
    
    public void ChangeRole(UserRole newRole)
    {
        if (Role == UserRole.Admin && newRole != UserRole.Admin)
        {
            throw new InvalidOperationException("Không thể thay đổi role của Admin");
        }
        Role = newRole;
    }
}

// Domain/ValueObjects/Email.cs
public class Email
{
    public string Value { get; private set; }
    
    public Email(string value)
    {
        if (string.IsNullOrWhiteSpace(value) || !value.Contains("@"))
        {
            throw new ArgumentException("Email không hợp lệ");
        }
        Value = value.ToLowerInvariant();
    }
    
    public override bool Equals(object? obj)
    {
        return obj is Email email && email.Value == Value;
    }
}

// Domain/Enums/UserRole.cs
public enum UserRole
{
    User = 1,
    Moderator = 2,
    Admin = 3
}

// Domain/Interfaces/IUserRepository.cs
public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid id);
    Task<User?> GetByEmailAsync(string email);
    Task<User> AddAsync(User user);
    Task UpdateAsync(User user);
    Task DeleteAsync(Guid id);
}
```

**Tại sao ở đây và tại sao quan trọng nhất?**

1. ✅ **KHÔNG phụ thuộc gì cả** - Pure C# code, không cần database, HTTP, framework
   ```csharp
   // ✅ ĐÚNG: Domain chỉ có C# thuần
   public class User { }
   
   // ❌ SAI: Domain không được import
   // using Microsoft.EntityFrameworkCore;  // ← KHÔNG được!
   // using Microsoft.AspNetCore.Mvc;       // ← KHÔNG được!
   ```

2. ✅ **Chứa business rules cốt lõi** - Logic nghiệp vụ quan trọng nhất
   ```csharp
   // Business rule: User phải có email hợp lệ
   public void SetEmail(string email)
   {
       if (!IsValidEmail(email))
           throw new BusinessException("Email không hợp lệ");
       Email = email;
   }
   ```

3. ✅ **Độc lập với công nghệ** - Có thể đổi database, framework mà Domain không cần sửa
   - Đổi SQL Server → PostgreSQL? Domain không cần sửa
   - Đổi ASP.NET Core → FastAPI? Domain không cần sửa
   - Đổi Entity Framework → Dapper? Domain không cần sửa

4. ✅ **Test dễ nhất** - Pure C# class, test không cần mock, database, HTTP
   ```csharp
   [Fact]
   public void User_CanDelete_ShouldReturnFalse_WhenRoleIsAdmin()
   {
       var user = new User { Role = UserRole.Admin };
       Assert.False(user.CanDelete());
   }
   ```

5. ✅ **Tái sử dụng cao nhất** - Dùng cho Web API, Mobile API, Desktop App, Console App
   ```csharp
   // Cùng một User entity dùng cho:
   // - Web API (ASP.NET Core)
   // - Mobile API (ASP.NET Core)
   // - Desktop App (WPF, WinForms)
   // - Console App
   // - Microservices khác
   ```

**Mối quan hệ với các layers:**

```
Domain Layer (Core) ⭐
    ↑
    │ references
    │
Application Layer
    ↑
    │ references
    │
Infrastructure Layer
    ↑
    │ references
    │
API Layer
```

**Nguyên tắc:**
- ✅ Outer layers (API, Infrastructure, Application) **PHỤ THUỘC** Domain
- ✅ Domain **KHÔNG PHỤ THUỘC** bất kỳ layer nào
- ✅ Domain chỉ có **pure C# code**

**Ví dụ thực tế:**

Giả sử bạn có entity `Product` trong Domain:

```csharp
// Domain/Entities/Product.cs
public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
    public int Stock { get; set; }
    
    // Business rule
    public bool IsAvailable()
    {
        return Stock > 0 && Price > 0;
    }
    
    public void ReduceStock(int quantity)
    {
        if (quantity <= 0)
            throw new ArgumentException("Số lượng phải lớn hơn 0");
        
        if (Stock < quantity)
            throw new InvalidOperationException("Không đủ hàng");
        
        Stock -= quantity;
    }
}
```

**Entity này được dùng ở:**
- ✅ Application Layer - Business logic sử dụng `Product.IsAvailable()`
- ✅ Infrastructure Layer - Repository lưu `Product` vào database
- ✅ API Layer - Controller trả về thông tin `Product`

**Nhưng Product entity KHÔNG biết:**
- ❌ Nó được lưu ở database nào (SQL Server, PostgreSQL, MongoDB)
- ❌ Nó được trả về qua HTTP như thế nào (JSON, XML)
- ❌ Nó được validate như thế nào (FluentValidation, DataAnnotations)

**→ Domain hoàn toàn độc lập!**

---

### 1. Application Layer - Business Logic (Nghiệp vụ)

**Vị trí:** `Application/DTOs/Auth/` và `Application/Interfaces/`

**Chứa:**
- ✅ DTOs (Data Transfer Objects) - Định nghĩa cấu trúc dữ liệu
- ✅ Interfaces - Định nghĩa "CÁCH LÀM" nhưng CHƯA làm

**Ví dụ:**

```csharp
// Application/DTOs/Auth/RegisterRequest.cs
public class RegisterRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [MinLength(8)]
    public string Password { get; set; } = string.Empty;
}

// Application/Interfaces/IAuthService.cs
public interface IAuthService
{
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);
    Task<AuthResponse?> LoginAsync(LoginRequest request);
}
```

**Tại sao ở đây?**
- ✅ **Phụ thuộc Domain Layer** - Sử dụng entities, interfaces từ Domain
- ✅ **Không phụ thuộc vào cách implement** - Chỉ định nghĩa "Làm gì", không phải "Làm như thế nào"
- ✅ **Có thể dùng cho nhiều UI** - Web API, Mobile API, gRPC, GraphQL
- ✅ **Dễ test** - Có thể mock interface để test
- ✅ **Business rules rõ ràng** - Validation rules nằm trong DTOs

**Mối quan hệ với Domain:**
```csharp
// Application/Services/IProductService.cs
public interface IProductService
{
    Task<ProductDto> GetProductAsync(Guid id);  // ← Sử dụng Product entity từ Domain
}

// Application Layer sử dụng Domain entities
public class ProductService : IProductService
{
    private readonly IProductRepository _repository;  // ← Interface từ Domain!
    
    public async Task<ProductDto> GetProductAsync(Guid id)
    {
        var product = await _repository.GetByIdAsync(id);  // ← Trả về Product entity (Domain)
        if (product == null || !product.IsAvailable())  // ← Sử dụng business logic từ Domain
        {
            throw new NotFoundException("Product không tồn tại hoặc không có sẵn");
        }
        return MapToDto(product);
    }
}
```

**Ví dụ: Nếu bạn muốn tạo Mobile App, bạn chỉ cần dùng lại:**
- `RegisterRequest`, `LoginRequest` từ Application layer
- `IAuthService` interface
- **Domain entities** vẫn được dùng chung
- **KHÔNG cần** thay đổi gì trong Application và Domain layers!

---

### 2. Infrastructure Layer - Implementation (Cách thực hiện)

**Vị trí:** `Infrastructure/Services/AuthService.cs`

**Chứa:**
- ✅ Implement interfaces từ Application layer
- ✅ Tương tác với database, external services
- ✅ Cụ thể hóa "CÁCH LÀM"

**Ví dụ:**

```csharp
// Infrastructure/Services/AuthService.cs
public class AuthService : IAuthService
{
    private readonly UserManager<IdentityUser> _userManager;
    private readonly SignInManager<IdentityUser> _signInManager;
    
    public AuthService(
        UserManager<IdentityUser> userManager,
        SignInManager<IdentityUser> signInManager)
    {
        _userManager = userManager;  // ← Sử dụng ASP.NET Core Identity
        _signInManager = signInManager;
    }
    
    public async Task<AuthResponse?> RegisterAsync(RegisterRequest request)
    {
        // Cụ thể: Dùng Identity để tạo user
        var user = new IdentityUser { Email = request.Email };
        await _userManager.CreateAsync(user, request.Password);
        // ...
    }
}
```

**Tại sao ở đây?**
- ✅ **Phụ thuộc Domain và Application** - Implement interfaces từ Application, sử dụng entities từ Domain
- ✅ **Tách biệt implementation** - Nếu đổi từ Identity sang JWT khác, chỉ sửa Infrastructure
- ✅ **Có thể có nhiều implementation** - Ví dụ: `AuthServiceIdentity`, `AuthServiceCustom`
- ✅ **Dễ thay đổi** - Đổi database (SQL Server → PostgreSQL) chỉ cần sửa Infrastructure
- ✅ **Application và Domain không biết** - Không cần biết bạn dùng Identity hay custom authentication

**Mối quan hệ với Domain:**
```csharp
// Infrastructure/Repositories/ProductRepository.cs
public class ProductRepository : IProductRepository  // ← Implement interface từ Domain
{
    private readonly ApplicationDbContext _context;
    
    public async Task<Product> GetByIdAsync(Guid id)  // ← Trả về Product entity (Domain)
    {
        return await _context.Products.FindAsync(id);  // ← Entity Framework map từ DB
    }
    
    public async Task<Product> AddAsync(Product product)  // ← Nhận Product entity (Domain)
    {
        if (!product.IsAvailable())  // ← Sử dụng business logic từ Domain
        {
            throw new BusinessException("Không thể thêm sản phẩm không có sẵn");
        }
        
        _context.Products.Add(product);
        await _context.SaveChangesAsync();
        return product;
    }
}
```

**Ví dụ: Nếu bạn muốn đổi từ ASP.NET Core Identity sang custom authentication:**

```csharp
// Chỉ cần tạo implementation mới:
public class CustomAuthService : IAuthService
{
    // Custom implementation
    // Vẫn sử dụng User entity từ Domain
    // Application và Domain layers KHÔNG cần thay đổi gì!
}

// Đổi database: SQL Server → PostgreSQL
// Chỉ cần sửa Infrastructure/Data/ApplicationDbContext.cs
// Domain entities KHÔNG cần thay đổi!
```

---

### 3. API Layer - Presentation (Giao diện người dùng)

**Vị trí:** `API/Controllers/AuthController.cs`

**Chứa:**
- ✅ Controllers - Nhận HTTP requests
- ✅ Routing - Định nghĩa URLs
- ✅ HTTP-specific logic - Status codes, headers

**Ví dụ:**

```csharp
// API/Controllers/AuthController.cs
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;  // ← Dùng interface từ Application
    
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var response = await _authService.RegisterAsync(request);  // ← Gọi service
        return Ok(response);  // ← Trả về HTTP response
    }
}
```

**Tại sao ở đây?**
- ✅ **Chỉ xử lý HTTP** - Controllers chỉ biết về HTTP, không biết business logic
- ✅ **Có thể thay đổi framework** - Đổi từ ASP.NET Core sang FastAPI (Python) chỉ cần làm lại API layer
- ✅ **Dễ thêm endpoints** - Thêm endpoint mới không ảnh hưởng business logic
- ✅ **Có thể tạo nhiều APIs** - Web API, Mobile API, Admin API đều dùng chung Application layer

**Ví dụ: Nếu bạn muốn tạo GraphQL API:**

```csharp
// Chỉ cần tạo GraphQL layer mới:
public class AuthQuery
{
    private readonly IAuthService _authService;  // ← Vẫn dùng chung interface!
    
    // GraphQL resolvers
}

// Application layer KHÔNG cần thay đổi!
```

---

## 🔄 Luồng hoạt động

### Khi user đăng ký (với Domain Layer):

```
1. User gửi HTTP POST /api/auth/register
   ↓
2. AuthController (API Layer) nhận request
   ↓
3. AuthController gọi IAuthService.RegisterAsync() (Application Layer)
   ↓
4. AuthService (Infrastructure Layer) implement logic:
   - Sử dụng IUserRepository (interface từ Domain)
   - Tạo User entity (từ Domain)
   - Áp dụng business rules từ User entity (Domain)
   - Lưu User vào database qua Repository
   - Generate JWT token
   ↓
5. Trả về AuthResponse (DTO từ Application layer)
   ↓
6. AuthController trả về HTTP 200 OK với response
```

**Vai trò của Domain Layer:**
- ✅ **IUserRepository** interface - Định nghĩa cách lưu user (từ Domain)
- ✅ **User** entity - Chứa business rules (từ Domain)
- ✅ **Email** value object - Validation email (từ Domain)
- ✅ **UserRole** enum - Định nghĩa roles (từ Domain)

**Chú ý:**
- Controller **KHÔNG biết** cách tạo user (Identity hay custom)
- Controller **KHÔNG biết** cách generate token (JWT hay gì khác)
- Controller **CHỈ biết** gọi service và trả về response
- **Domain Layer** chứa business rules cốt lõi, không phụ thuộc gì

### Ví dụ Domain Layer trong Auth Flow:

```csharp
// Domain/Entities/User.cs
public class User
{
    public Guid Id { get; private set; }
    public Email Email { get; private set; }  // ← Value Object từ Domain
    public string UserName { get; private set; }
    public UserRole Role { get; private set; }  // ← Enum từ Domain
    
    // Business rule từ Domain
    public bool CanChangeRole()
    {
        return Role != UserRole.Admin;  // Admin không thể đổi role
    }
    
    public void ChangeRole(UserRole newRole)
    {
        if (!CanChangeRole())
            throw new BusinessException("Admin không thể đổi role");
        Role = newRole;
    }
}

// Domain/Interfaces/IUserRepository.cs
public interface IUserRepository  // ← Interface từ Domain
{
    Task<User?> GetByEmailAsync(Email email);
    Task<User> AddAsync(User user);
    Task UpdateAsync(User user);
}

// Infrastructure/Repositories/UserRepository.cs - Implement interface từ Domain
public class UserRepository : IUserRepository
{
    private readonly ApplicationDbContext _context;
    
    public async Task<User?> GetByEmailAsync(Email email)
    {
        // Query database, map to User entity (Domain)
        var userEntity = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == email.Value);
        
        if (userEntity == null) return null;
        
        return new User  // ← Tạo User entity từ Domain
        {
            Id = userEntity.Id,
            Email = new Email(userEntity.Email),  // ← Sử dụng Email value object
            UserName = userEntity.UserName,
            Role = (UserRole)userEntity.Role  // ← Sử dụng UserRole enum
        };
    }
}

// Application/Services/IAuthService.cs
public interface IAuthService
{
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);
}

// Infrastructure/Services/AuthService.cs
public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;  // ← Interface từ Domain
    
    public async Task<AuthResponse?> RegisterAsync(RegisterRequest request)
    {
        var email = new Email(request.Email);  // ← Sử dụng Email value object (Domain)
        
        // Kiểm tra email đã tồn tại (qua interface từ Domain)
        var existingUser = await _userRepository.GetByEmailAsync(email);
        if (existingUser != null)
            return null;
        
        // Tạo User entity (Domain)
        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = email,  // ← Email value object
            UserName = request.UserName,
            Role = UserRole.User  // ← UserRole enum từ Domain
        };
        
        // Lưu qua repository (interface từ Domain)
        await _userRepository.AddAsync(user);
        
        // Business rule từ Domain
        if (!user.CanChangeRole())  // ← Sử dụng method từ User entity
        {
            // Logic...
        }
        
        return new AuthResponse { /* ... */ };
    }
}
```

**Kết quả:**
- ✅ Domain Layer chứa tất cả business rules (User.CanChangeRole(), Email validation)
- ✅ Application Layer chỉ biết interfaces từ Domain
- ✅ Infrastructure Layer implement interfaces từ Domain
- ✅ Nếu đổi database/framework: **Domain không cần sửa**

---

## 🎯 Lợi ích thực tế

### 1. **Dễ bảo trì (Maintainability)**

**Ví dụ:** Bạn cần thay đổi cách validate password

**Nếu KHÔNG tách layers:**
```csharp
// Tất cả trong Controller
[HttpPost("register")]
public async Task<IActionResult> Register([FromBody] RegisterRequest request)
{
    // Validation logic ở đây
    // Database logic ở đây
    // JWT logic ở đây
    // Tất cả lẫn lộn!
}
```

**Phải sửa:** Controller → Có thể ảnh hưởng routing, HTTP handling

**Với Clean Architecture:**
```csharp
// Validation ở Application Layer (DTO)
[Required]
[MinLength(8)]
public string Password { get; set; }

// Logic ở Infrastructure Layer
// Controller KHÔNG cần sửa!
```

---

### 2. **Dễ test (Testability)**

**Test Application Layer:**
```csharp
// Test RegisterRequest validation
var request = new RegisterRequest { Email = "test@test.com" };
var result = Validator.Validate(request);
Assert.False(result.IsValid);
```

**Test Infrastructure Layer:**
```csharp
// Mock UserManager
var mockUserManager = new Mock<UserManager<IdentityUser>>();
var service = new AuthService(mockUserManager.Object);
// Test logic không cần database thật
```

**Test API Layer:**
```csharp
// Mock IAuthService
var mockService = new Mock<IAuthService>();
var controller = new AuthController(mockService.Object);
// Test HTTP responses
```

**→ Mỗi layer test độc lập!**

---

### 3. **Dễ mở rộng (Scalability)**

**Ví dụ:** Thêm OAuth2 login

**Với Clean Architecture:**

```csharp
// 1. Thêm method vào Interface (Application Layer)
public interface IAuthService
{
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);
    Task<AuthResponse?> LoginAsync(LoginRequest request);
    Task<AuthResponse?> LoginWithOAuthAsync(OAuthRequest request);  // ← Thêm mới
}

// 2. Implement trong Infrastructure Layer
public class AuthService : IAuthService
{
    public async Task<AuthResponse?> LoginWithOAuthAsync(OAuthRequest request)
    {
        // OAuth2 logic
    }
}

// 3. Thêm endpoint trong API Layer
[HttpPost("oauth")]
public async Task<IActionResult> LoginWithOAuth([FromBody] OAuthRequest request)
{
    var response = await _authService.LoginWithOAuthAsync(request);
    return Ok(response);
}
```

**→ Mỗi layer chỉ thêm code mới, không sửa code cũ!**

---

### 4. **Tái sử dụng (Reusability)**

**Ví dụ:** Bạn muốn tạo:
- ✅ Web API (ASP.NET Core)
- ✅ Mobile API (ASP.NET Core)
- ✅ Admin Dashboard API (ASP.NET Core)
- ✅ GraphQL API

**Với Clean Architecture:**
- ✅ **Application Layer** - Dùng chung cho tất cả
- ✅ **Infrastructure Layer** - Dùng chung cho tất cả
- ✅ **API Layer** - Chỉ làm mới cho mỗi loại API

**Không cần viết lại business logic!**

---

### 5. **Làm việc nhóm (Team Collaboration)**

**Ví dụ:** Team có 3 developers

**Developer A** - Frontend:
- Chỉ cần biết DTOs (RegisterRequest, AuthResponse)
- Có thể code frontend song song với backend

**Developer B** - Business Logic:
- Code Application Layer (DTOs, Interfaces)
- Không cần biết database hay HTTP

**Developer C** - Backend:
- Code Infrastructure Layer (AuthService implementation)
- Không cần biết frontend

**→ Mỗi người code độc lập, ít conflict!**

---

## 📊 So sánh: Với và Không có Clean Architecture

### ❌ KHÔNG có Clean Architecture (Tất cả trong một file):

```csharp
// AuthController.cs (2000 dòng code!)
[ApiController]
public class AuthController : ControllerBase
{
    // Database connection
    private readonly SqlConnection _connection;
    
    // HTTP logic
    [HttpPost("register")]
    public async Task<IActionResult> Register(...)
    {
        // Validation logic
        if (string.IsNullOrEmpty(email)) return BadRequest();
        
        // Database logic
        var command = new SqlCommand("INSERT INTO Users...", _connection);
        
        // JWT logic
        var token = GenerateJWT(...);
        
        // Business logic
        if (user.Role == "Admin") { ... }
        
        // Tất cả lẫn lộn!
    }
}
```

**Vấn đề:**
- ❌ Khó test - Phải setup database, HTTP server
- ❌ Khó sửa - Sửa một chỗ có thể ảnh hưởng nhiều chỗ
- ❌ Khó mở rộng - Thêm tính năng phải sửa file lớn
- ❌ Khó tái sử dụng - Không thể dùng cho Mobile API
- ❌ Conflict khi làm nhóm - Nhiều người sửa cùng file

---

### ✅ CÓ Clean Architecture:

```csharp
// Application/DTOs/Auth/RegisterRequest.cs (20 dòng)
public class RegisterRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; }
}

// Application/Interfaces/IAuthService.cs (5 dòng)
public interface IAuthService
{
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);
}

// Infrastructure/Services/AuthService.cs (50 dòng)
public class AuthService : IAuthService
{
    // Business logic
    public async Task<AuthResponse?> RegisterAsync(RegisterRequest request) { ... }
}

// API/Controllers/AuthController.cs (10 dòng)
[ApiController]
public class AuthController : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var response = await _authService.RegisterAsync(request);
        return Ok(response);
    }
}
```

**Lợi ích:**
- ✅ Dễ test - Test từng layer độc lập
- ✅ Dễ sửa - Sửa một layer không ảnh hưởng layer khác
- ✅ Dễ mở rộng - Thêm code mới, không sửa code cũ
- ✅ Dễ tái sử dụng - Application layer dùng cho nhiều API
- ✅ Ít conflict - Mỗi người code layer khác nhau

---

## 🎓 Nguyên tắc Clean Architecture

### 1. Dependency Inversion (Đảo ngược phụ thuộc)

**Nguyên tắc:**
- ✅ Outer layers (API) phụ thuộc inner layers (Application)
- ✅ Inner layers (Application) KHÔNG phụ thuộc outer layers

**Ví dụ:**
```csharp
// ✅ ĐÚNG: API phụ thuộc Application
// API/Controllers/AuthController.cs
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;  // ← Interface từ Application
}

// ❌ SAI: Application phụ thuộc API
// Application/Services/AuthService.cs
public class AuthService
{
    private readonly AuthController _controller;  // ← KHÔNG được!
}
```

---

### 2. Separation of Concerns (Tách biệt mối quan tâm)

**Nguyên tắc:**
- ✅ Mỗi layer chỉ lo một việc
- ✅ API layer: Chỉ lo HTTP
- ✅ Application layer: Chỉ lo business logic
- ✅ Infrastructure layer: Chỉ lo database/external services

**Ví dụ:**
```csharp
// ✅ API Layer - Chỉ lo HTTP
[HttpPost("register")]
public async Task<IActionResult> Register(...) { }

// ✅ Application Layer - Chỉ lo business rules
public interface IAuthService
{
    Task<AuthResponse?> RegisterAsync(RegisterRequest request);
}

// ✅ Infrastructure Layer - Chỉ lo implementation
public class AuthService : IAuthService
{
    // Database, Identity logic
}
```

---

## 📝 Tóm tắt

### Domain Layer (Core) ⭐ - Quan trọng nhất
- ✅ **Chứa:** Entities, Value Objects, Enums, Interfaces
- ✅ **Mục đích:** Chứa business rules và entities cốt lõi
- ✅ **Không phụ thuộc:** KHÔNG phụ thuộc bất kỳ layer nào (pure C#)
- ✅ **Lợi ích:** 
  - Độc lập hoàn toàn với công nghệ
  - Có thể đổi database/framework mà không cần sửa Domain
  - Test dễ nhất (pure C# classes)
  - Tái sử dụng cao nhất (dùng cho mọi loại application)

### Application Layer (Business Logic)
- ✅ **Chứa:** DTOs, Service Interfaces, Use Cases
- ✅ **Mục đích:** Định nghĩa "LÀM GÌ" (What)
- ✅ **Phụ thuộc:** Domain Layer (sử dụng entities, interfaces)
- ✅ **Không phụ thuộc:** Database, HTTP, Framework implementation
- ✅ **Lợi ích:** 
  - Dùng lại cho nhiều UI (Web, Mobile, Desktop)
  - Dễ test (mock repositories)
  - Business rules rõ ràng

### Infrastructure Layer (Implementation)
- ✅ **Chứa:** Service implementations, Database access, External services
- ✅ **Mục đích:** Định nghĩa "LÀM NHƯ THẾ NÀO" (How)
- ✅ **Phụ thuộc:** Domain + Application Layers
- ✅ **Lợi ích:** 
  - Dễ thay đổi implementation (Identity → Custom, SQL Server → PostgreSQL)
  - Có thể có nhiều implementations cho cùng một interface
  - Tách biệt với business logic

### API Layer (Presentation)
- ✅ **Chứa:** Controllers, Routing, HTTP handling, Configuration
- ✅ **Mục đích:** Giao tiếp với client (HTTP)
- ✅ **Phụ thuộc:** Application Layer (qua interfaces)
- ✅ **Lợi ích:** 
  - Có thể thay đổi framework (ASP.NET Core → FastAPI)
  - Có thể tạo nhiều APIs (Web, Mobile, Admin) dùng chung Application/Domain
  - Chỉ xử lý HTTP, không biết business logic

---

## 🎯 Kết luận

Tổ chức code theo Clean Architecture giống như **xây nhà có tầng**:

```
┌─────────────────────────────────────┐
│  Third Floor (API Layer)            │  ← Giao diện người dùng (HTTP)
│  - Controllers, Routing             │
├─────────────────────────────────────┤
│  Second Floor (Infrastructure)      │  ← Kỹ thuật (Database, External Services)
│  - Repositories, Service Impl       │
├─────────────────────────────────────┤
│  First Floor (Application)          │  ← Nghiệp vụ (Use Cases, DTOs)
│  - Business Logic, Interfaces       │
├─────────────────────────────────────┤
│  Foundation (Domain) ⭐              │  ← Cốt lõi (Entities, Business Rules)
│  - Entities, Value Objects          │
│  - KHÔNG phụ thuộc gì!              │
└─────────────────────────────────────┘
```

### Domain Layer là gì? ⭐

**Domain Layer = Nền móng vững chắc nhất**

- ✅ **Không phụ thuộc gì** - Pure C# code, không cần database, HTTP, framework
- ✅ **Chứa business rules cốt lõi** - Logic nghiệp vụ quan trọng nhất
- ✅ **Độc lập với công nghệ** - Có thể đổi bất kỳ công nghệ nào mà Domain không cần sửa
- ✅ **Test dễ nhất** - Pure C# classes, không cần mock gì
- ✅ **Tái sử dụng cao nhất** - Dùng cho Web, Mobile, Desktop, Console, Microservices

**Ví dụ thực tế:**
- Nếu đổi SQL Server → PostgreSQL: **Domain không cần sửa**
- Nếu đổi ASP.NET Core → FastAPI: **Domain không cần sửa**
- Nếu đổi Entity Framework → Dapper: **Domain không cần sửa**
- Nếu tạo Mobile App mới: **Domain dùng lại 100%**

**Mỗi tầng có nhiệm vụ riêng, độc lập, dễ sửa, dễ mở rộng!**

**Domain Layer = Trái tim của ứng dụng - Bảo vệ business rules không bị ảnh hưởng bởi thay đổi công nghệ!**

---

**Tác giả**: Genshin App Team  
**Cập nhật**: 2026-01-08
