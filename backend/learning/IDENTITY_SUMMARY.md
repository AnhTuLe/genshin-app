# 📚 ASP.NET Core Identity - Tóm tắt

Tóm tắt ngắn gọn và dễ hiểu về ASP.NET Core Identity.

---

## 🎯 Identity là gì?

**ASP.NET Core Identity** là framework của Microsoft giúp quản lý user accounts trong ứng dụng web.

### Tưởng tượng:
- Identity = "Thư viện sẵn có" để xử lý users
- Thay vì tự code từ đầu, bạn dùng Identity → Tiết kiệm thời gian và đảm bảo security

---

## ❓ Tại sao cần Identity?

### Nếu tự làm (không dùng Identity):
```
❌ Phải tự implement password hashing (BCrypt, PBKDF2)
❌ Phải tự thiết kế database schema cho users
❌ Phải tự implement email verification
❌ Phải tự implement password reset
❌ Phải tự implement role management
❌ Phải tự implement account lockout (khóa sau nhiều lần sai password)
❌ Phải tự implement security best practices
❌ Rất dễ mắc lỗi security
```

### Với Identity:
```
✅ Password hashing tự động (bảo mật)
✅ Database schema có sẵn (chuẩn)
✅ Email verification built-in
✅ Password reset built-in
✅ Role management built-in
✅ Account lockout built-in
✅ Security best practices được implement sẵn
✅ Được test kỹ, ít bugs
```

**Kết luận**: Dùng Identity = Tiết kiệm thời gian + Bảo mật tốt hơn

---

## 🏗️ Identity Architecture (Kiến trúc)

### Core Components (Các thành phần chính):

#### 1. **IdentityUser**
```csharp
// Class đại diện cho một user
public class IdentityUser
{
    public string Id { get; set; }              // Unique ID
    public string UserName { get; set; }        // Username
    public string Email { get; set; }           // Email
    public string PasswordHash { get; set; }    // Password (đã hash, KHÔNG phải plain text)
    public bool EmailConfirmed { get; set; }    // Đã confirm email chưa?
    public bool LockoutEnabled { get; set; }    // Có bị khóa không?
    // ... nhiều properties khác
}
```

**Bạn có thể extend:**
```csharp
public class ApplicationUser : IdentityUser
{
    public string FirstName { get; set; }  // Custom property
    public string LastName { get; set; }   // Custom property
}
```

#### 2. **UserManager<TUser>**
```csharp
// Service để quản lý users (CRUD operations)
UserManager<ApplicationUser> userManager;

// Các methods phổ biến:
await userManager.CreateAsync(user, password);      // Tạo user mới
await userManager.FindByEmailAsync(email);          // Tìm user theo email
await userManager.CheckPasswordAsync(user, password); // Kiểm tra password
await userManager.AddToRoleAsync(user, "Admin");     // Thêm role cho user
await userManager.ChangePasswordAsync(user, oldPwd, newPwd); // Đổi password
```

**Lưu ý**: 
- UserManager tự động hash password khi tạo user
- UserManager tự động verify password khi check

#### 3. **IdentityDbContext**
```csharp
// Database context cho Identity
public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
{
    // IdentityDbContext tự động tạo các tables cần thiết
}
```

#### 4. **Database Tables**

Khi setup Identity, các tables sau được tự động tạo:

| Table | Mục đích |
|-------|----------|
| **AspNetUsers** | Lưu thông tin users |
| **AspNetRoles** | Lưu roles (Admin, User, etc.) |
| **AspNetUserRoles** | Bảng liên kết User ↔ Role (Many-to-Many) |
| **AspNetUserClaims** | Lưu claims của user |
| **AspNetRoleClaims** | Lưu claims của role |
| **AspNetUserLogins** | Lưu external logins (Google, Facebook) |
| **AspNetUserTokens** | Lưu tokens (email confirmation, password reset) |

---

## 🔄 Identity Flow (Quy trình hoạt động)

### 1. User Registration (Đăng ký):

```
User nhập: Email + Password
        ↓
Identity tạo user object
        ↓
Identity hash password (tự động)
        ↓
Identity lưu vào database
        ↓
Return: Success hoặc Errors
```

**Code example:**
```csharp
var user = new ApplicationUser { Email = "user@example.com" };
var result = await userManager.CreateAsync(user, "Password123!");
// Password tự động được hash, không lưu plain text
```

### 2. User Login (Đăng nhập):

```
User nhập: Email + Password
        ↓
Identity tìm user theo email
        ↓
Identity verify password (so sánh hash)
        ↓
If valid → Return user
If invalid → Return null/error
```

**Code example:**
```csharp
var user = await userManager.FindByEmailAsync("user@example.com");
if (user != null)
{
    var isValid = await userManager.CheckPasswordAsync(user, "Password123!");
    // Identity tự động hash "Password123!" và so sánh với PasswordHash trong DB
}
```

### 3. Password Hashing (Mã hóa mật khẩu):

```
Password: "MyPassword123"
        ↓
Identity hash (PBKDF2 hoặc BCrypt)
        ↓
Hash: "$2a$11$N9qo8uLOickgx2ZMRZoMye..."
        ↓
Lưu vào database (KHÔNG lưu plain text)
```

**Important**: 
- Password KHÔNG BAO GIỜ được lưu plain text
- Identity tự động hash khi tạo user
- Identity tự động verify khi check password
- Bạn không cần tự làm gì cả!

---

## ⚙️ Setup Identity (Cài đặt)

### Bước 1: Install Packages
```bash
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
```

### Bước 2: Create ApplicationUser
```csharp
public class ApplicationUser : IdentityUser
{
    // Custom properties
}
```

### Bước 3: Create DbContext
```csharp
public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options) { }
}
```

### Bước 4: Configure trong Program.cs
```csharp
// Add Identity
builder.Services.AddIdentity<ApplicationUser, IdentityRole>(options =>
{
    // Password requirements
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 8;
    options.Password.RequireUppercase = true;
    
    // User settings
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Add DbContext
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));
```

### Bước 5: Create Migration
```bash
dotnet ef migrations add AddIdentity
dotnet ef database update
```

**Result**: Database có đầy đủ Identity tables!

---

## 🔑 Key Concepts (Khái niệm quan trọng)

### 1. UserManager<TUser>

**Là gì?** Service để quản lý users

**Làm gì?**
- Create/Update/Delete users
- Hash và verify passwords
- Manage roles
- Manage claims
- Lock/unlock accounts

**Lưu ý**: UserManager được inject qua Dependency Injection

### 2. Password Hashing

**Identity tự động:**
- Hash password khi tạo user
- Verify password khi login
- Bạn không cần tự làm

**Algorithms**: PBKDF2 (default) hoặc BCrypt

### 3. Roles (Vai trò)

**Ví dụ**: Admin, User, Moderator

**Cách dùng:**
```csharp
// Tạo role
await roleManager.CreateAsync(new IdentityRole("Admin"));

// Assign role
await userManager.AddToRoleAsync(user, "Admin");

// Check role
var isAdmin = await userManager.IsInRoleAsync(user, "Admin");
```

### 4. Claims (Yêu cầu/Thông tin)

**Claims** = Thông tin về user (User ID, Email, Role, etc.)

**Ví dụ:**
```csharp
// Add claim
await userManager.AddClaimAsync(user, new Claim("CanEdit", "true"));

// Get claims
var claims = await userManager.GetClaimsAsync(user);
```

---

## 💡 Common Use Cases (Trường hợp sử dụng thường gặp)

### Use Case 1: Register User
```csharp
var user = new ApplicationUser 
{ 
    Email = request.Email,
    UserName = request.Email 
};
var result = await userManager.CreateAsync(user, request.Password);
// Password tự động được hash
```

### Use Case 2: Login
```csharp
var user = await userManager.FindByEmailAsync(email);
if (user != null)
{
    var isValid = await userManager.CheckPasswordAsync(user, password);
    // Identity tự verify password
}
```

### Use Case 3: Change Password
```csharp
await userManager.ChangePasswordAsync(user, oldPassword, newPassword);
// Identity tự hash new password
```

### Use Case 4: Reset Password
```csharp
// Generate token
var token = await userManager.GeneratePasswordResetTokenAsync(user);

// Reset password
await userManager.ResetPasswordAsync(user, token, newPassword);
```

### Use Case 5: Assign Role
```csharp
await userManager.AddToRoleAsync(user, "Admin");
```

---

## 🎯 Identity vs Manual Implementation

| Feature | Identity | Tự làm |
|---------|----------|--------|
| Password Hashing | ✅ Tự động | ❌ Phải tự code |
| Database Schema | ✅ Có sẵn | ❌ Phải thiết kế |
| Security | ✅ Best practices | ⚠️ Dễ mắc lỗi |
| Email Verification | ✅ Built-in | ❌ Phải tự làm |
| Password Reset | ✅ Built-in | ❌ Phải tự làm |
| Role Management | ✅ Built-in | ❌ Phải tự làm |
| Development Time | ✅ Nhanh | ❌ Lâu |

**Kết luận**: Dùng Identity = Nhanh hơn + An toàn hơn

---

## ⚠️ Important Points (Điểm quan trọng)

### 1. Password Security
- ✅ Identity tự động hash passwords
- ✅ KHÔNG BAO GIỜ lưu plain text password
- ✅ Password hash không thể reverse (one-way)

### 2. UserManager Lifetime
- ✅ UserManager được inject qua DI
- ✅ Lifetime: Scoped (per request)
- ✅ Thread-safe

### 3. Database Schema
- ✅ Identity tự động tạo tables
- ✅ Có thể customize thông qua migrations
- ✅ Không nên sửa trực tiếp tables (dùng Identity APIs)

### 4. Extensibility
- ✅ Có thể extend IdentityUser (thêm custom properties)
- ✅ Có thể customize password requirements
- ✅ Có thể customize lockout settings

---

## 🔗 Identity và JWT

### Kết hợp như thế nào?

```
Identity: Quản lý users, passwords, roles
    ↓
User login với Identity
    ↓
Identity verify credentials
    ↓
Nếu thành công → Generate JWT token (chứa user info)
    ↓
Client dùng JWT token cho các requests tiếp theo
```

**Tóm lại:**
- **Identity** = Quản lý users và credentials
- **JWT** = Stateless authentication token
- **Kết hợp cả hai** = Best practice

---

## 📝 Tóm tắt

### Identity là:
- ✅ Framework quản lý user accounts
- ✅ Built-in password hashing (bảo mật)
- ✅ Built-in role management
- ✅ Built-in security features
- ✅ Tiết kiệm thời gian development

### Identity Components:
1. **IdentityUser** - Đại diện user
2. **UserManager** - Service quản lý users
3. **IdentityDbContext** - Database context
4. **Database Tables** - Tự động tạo

### Workflow:
1. Setup Identity (packages, configuration)
2. Create ApplicationUser
3. Use UserManager để quản lý users
4. Identity tự động handle security

### Key Takeaway:
**Identity = "Thư viện sẵn có" để xử lý users một cách an toàn và nhanh chóng**

---

## ✅ Checklist: Hiểu Identity

Sau khi đọc, bạn nên có thể trả lời:

- [ ] Identity là gì và tại sao cần dùng?
- [ ] UserManager làm gì?
- [ ] Password được hash như thế nào?
- [ ] Identity tạo những tables gì trong database?
- [ ] Làm sao để tạo user mới với Identity?
- [ ] Làm sao để verify password với Identity?
- [ ] Identity và JWT khác nhau như thế nào?

---

## 🚀 Next Steps

Bây giờ bạn đã hiểu Identity, bạn có thể:
1. Bắt đầu implement STEP 2: Setup Identity
2. Reference code examples trong `PHASE1_CODE_EXAMPLES.md`
3. Thực hành với UserManager

**Ready to code!** 💻
