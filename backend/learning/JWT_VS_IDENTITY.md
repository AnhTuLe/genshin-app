# 🔄 JWT vs Identity - Sự khác biệt và mối quan hệ

Giải thích rõ ràng sự khác biệt giữa JWT và ASP.NET Core Identity, và cách chúng làm việc cùng nhau.

---

## 🎯 Tóm tắt nhanh

| | **Identity** | **JWT** |
|---|------------|---------|
| **Là gì?** | Framework quản lý users | Token format |
| **Mục đích** | User management | Authentication |
| **Trả lời câu hỏi** | "Làm sao lưu và quản lý users?" | "Làm sao authenticate requests?" |
| **Khi nào dùng?** | Khi cần quản lý users | Khi cần stateless authentication |
| **Database** | ✅ Cần database (lưu users) | ❌ Không cần database (stateless) |

---

## 🏗️ Identity - Framework quản lý Users

### Định nghĩa:
**Identity** là một **framework** (thư viện) giúp bạn quản lý user accounts trong ứng dụng.

### Nhiệm vụ của Identity:

1. **Quản lý Users** (CRUD)
   - Tạo user mới
   - Lưu thông tin user vào database
   - Update/Delete users

2. **Bảo mật Passwords**
   - Hash passwords (tự động)
   - Verify passwords (tự động)
   - Không lưu plain text passwords

3. **Quản lý Roles**
   - Tạo roles (Admin, User, etc.)
   - Assign roles cho users

4. **Security Features**
   - Account lockout (khóa sau nhiều lần sai password)
   - Email verification
   - Password reset

### Identity làm gì:

```csharp
// Identity quản lý users
var user = new ApplicationUser { Email = "user@example.com" };
await userManager.CreateAsync(user, "Password123!");
// ✅ Identity tự động hash password
// ✅ Identity lưu user vào database
// ✅ Identity quản lý tất cả thông tin user
```

### Identity = Database + Services

- ✅ **Cần Database**: Lưu users, roles, passwords (hashed)
- ✅ **UserManager Service**: Quản lý users
- ✅ **RoleManager Service**: Quản lý roles

---

## 🎫 JWT - Token Format

### Định nghĩa:
**JWT** là một **format/token** (định dạng token) để truyền thông tin về user giữa client và server.

### Nhiệm vụ của JWT:

1. **Xác thực Requests** (Authentication)
   - Chứng minh user đã login
   - Không cần query database mỗi request

2. **Chứa User Info**
   - User ID
   - Email
   - Roles
   - Claims

3. **Stateless**
   - Server không cần lưu session
   - Token tự chứa tất cả info cần thiết

### JWT làm gì:

```csharp
// JWT chứa thông tin về user
var token = GenerateJWT(user);
// Token chứa: { userId, email, roles }
// Client gửi token trong mỗi request
// Server verify token (không cần query database)
```

### JWT = Token String

- ❌ **Không cần Database**: Token tự chứa info
- ✅ **Stateless**: Server không lưu gì
- ✅ **Self-contained**: Token có đầy đủ thông tin

---

## 🔄 Sự khác biệt chính

### 1. Vai trò khác nhau

**Identity:**
```
"Tôi quản lý users trong database"
- Lưu user info
- Hash passwords
- Quản lý roles
```

**JWT:**
```
"Tôi là token để chứng minh user đã login"
- Chứa user info
- Được gửi trong mỗi request
- Server verify mà không cần query database
```

### 2. Khi nào cần Database?

**Identity:**
- ✅ **CẦN** database
- Lưu users, passwords, roles
- Query database khi login, register

**JWT:**
- ❌ **KHÔNG CẦN** database (cho authentication)
- Token tự chứa info
- Server chỉ verify signature

### 3. Lifetime (Vòng đời)

**Identity:**
- ✅ **Persistent** (vĩnh viễn)
- User tồn tại trong database
- Không expire

**JWT:**
- ⏰ **Temporary** (tạm thời)
- Token có expiration time
- Expire sau 1 giờ, 1 ngày, etc.

### 4. Khi nào dùng?

**Identity - Dùng khi:**
- ✅ Cần quản lý users (register, login)
- ✅ Cần lưu passwords an toàn
- ✅ Cần quản lý roles
- ✅ Cần password reset, email verification

**JWT - Dùng khi:**
- ✅ Cần authenticate API requests
- ✅ Cần stateless authentication
- ✅ Cần scale (nhiều servers)
- ✅ Phù hợp với SPA/Mobile apps

---

## 🤝 Identity và JWT làm việc cùng nhau

### Flow hoàn chỉnh:

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: User Registration                                    │
└─────────────────────────────────────────────────────────────┘
         ↓
    Identity tạo user
    (Lưu vào database)
         ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: User Login                                           │
└─────────────────────────────────────────────────────────────┘
         ↓
    User nhập: Email + Password
         ↓
    Identity verify credentials
    (Query database, check password hash)
         ↓
    ✅ Credentials valid
         ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: Generate JWT Token                                   │
└─────────────────────────────────────────────────────────────┘
         ↓
    Tạo JWT token
    (Chứa: UserId, Email, Roles)
         ↓
    Return token cho client
         ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: API Requests                                         │
└─────────────────────────────────────────────────────────────┘
         ↓
    Client gửi request với JWT token
    Authorization: Bearer <token>
         ↓
    Server verify JWT token
    (Không cần query database!)
         ↓
    Extract user info từ token
         ↓
    Authorize request
         ↓
    Return response
```

### Code Example:

```csharp
// STEP 1: Registration (Identity)
var user = new ApplicationUser { Email = "user@example.com" };
await userManager.CreateAsync(user, "Password123!");
// ✅ Identity lưu user vào database

// STEP 2: Login (Identity verify)
var user = await userManager.FindByEmailAsync(email);
var isValid = await userManager.CheckPasswordAsync(user, password);
// ✅ Identity verify từ database

// STEP 3: Generate JWT (nếu login thành công)
if (isValid)
{
    var token = jwtService.GenerateToken(user);
    // ✅ JWT token chứa user info
    return token;
}

// STEP 4: Protect API (JWT verify)
[Authorize]
public IActionResult GetProfile()
{
    // Server extract user info từ JWT token
    // ✅ Không cần query database
    var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    return Ok(userId);
}
```

---

## 📊 So sánh chi tiết

### Identity

**Là gì:**
- Framework/Thư viện

**Làm gì:**
- Quản lý users trong database
- Hash và verify passwords
- Quản lý roles

**Cần database:**
- ✅ Có (lưu users, passwords, roles)

**Khi nào dùng:**
- Register user
- Login (verify password)
- Change password
- Manage roles
- Account management

**Ví dụ:**
```csharp
// Identity: Quản lý users
await userManager.CreateAsync(user, password);
await userManager.FindByEmailAsync(email);
await userManager.CheckPasswordAsync(user, password);
```

---

### JWT

**Là gì:**
- Token format/Định dạng token

**Làm gì:**
- Authenticate requests
- Chứa user info
- Stateless authentication

**Cần database:**
- ❌ Không (stateless)

**Khi nào dùng:**
- Authenticate API requests
- Protect endpoints
- Mobile/SPA authentication
- Cross-domain authentication

**Ví dụ:**
```csharp
// JWT: Generate và verify token
var token = jwtService.GenerateToken(user);
// Token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

// Server verify token (không query database)
// Token chứa: { userId: "123", email: "user@example.com" }
```

---

## 💡 Tại sao cần cả hai?

### Scenario: E-Commerce Platform

**1. User Registration (Cần Identity):**
```
User muốn đăng ký tài khoản
→ Identity tạo user trong database
→ Identity hash password
→ User được lưu vào database
```

**2. User Login (Cần Identity):**
```
User login với email/password
→ Identity verify từ database
→ Identity check password hash
→ ✅ Valid → Generate JWT token
```

**3. Access Protected API (Cần JWT):**
```
User muốn xem profile
→ Client gửi JWT token
→ Server verify JWT (không query database)
→ ✅ Token valid → Return profile
```

### Nếu chỉ dùng Identity (không có JWT):

```csharp
// Mỗi request phải query database
[Authorize]
public IActionResult GetProfile()
{
    // ❌ Phải query database mỗi lần
    var user = await userManager.FindByIdAsync(userId);
    return Ok(user);
}
```

**Vấn đề:**
- ❌ Slow (phải query database mỗi request)
- ❌ Khó scale (nhiều servers cần share sessions)
- ❌ Không phù hợp với stateless APIs

### Với JWT:

```csharp
// Không cần query database
[Authorize]
public IActionResult GetProfile()
{
    // ✅ Extract từ JWT token (đã có trong token)
    var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    return Ok(userId);
}
```

**Lợi ích:**
- ✅ Fast (không query database)
- ✅ Scalable (stateless)
- ✅ Phù hợp với APIs

---

## 🎯 Kết hợp Identity + JWT (Best Practice)

### Architecture:

```
┌─────────────────────┐
│   Identity          │  ← Quản lý users
│   (Database)        │
└─────────────────────┘
         │
         │ (Khi login)
         ↓
┌─────────────────────┐
│   JWT Service       │  ← Generate token
└─────────────────────┘
         │
         │ (Return token)
         ↓
┌─────────────────────┐
│   Client            │  ← Store token
└─────────────────────┘
         │
         │ (Send với requests)
         ↓
┌─────────────────────┐
│   Protected APIs    │  ← Verify token
└─────────────────────┘
```

### Responsibilities:

**Identity:**
- ✅ User registration
- ✅ Password verification
- ✅ User management
- ✅ Role management

**JWT:**
- ✅ API authentication
- ✅ Stateless requests
- ✅ Token generation
- ✅ Token verification

---

## 📝 Tóm tắt

### Identity:
- 🎯 **Mục đích**: Quản lý users
- 💾 **Storage**: Database
- 🔐 **Security**: Password hashing
- 👥 **Features**: Roles, claims, lockout

### JWT:
- 🎯 **Mục đích**: Authenticate requests
- 💾 **Storage**: Không cần (stateless)
- 🔐 **Security**: Token signature
- ⚡ **Features**: Fast, scalable

### Kết hợp:
- ✅ **Identity** cho user management
- ✅ **JWT** cho API authentication
- ✅ **Best practice** cho modern web apps

---

## ✅ Checklist: Hiểu sự khác biệt

Sau khi đọc, bạn nên có thể trả lời:

- [ ] Identity làm gì? JWT làm gì?
- [ ] Khi nào cần Identity? Khi nào cần JWT?
- [ ] Tại sao cần cả hai?
- [ ] Identity và JWT làm việc cùng nhau như thế nào?
- [ ] Identity cần database, JWT có cần không?
- [ ] Trong flow login, Identity làm gì? JWT làm gì?

---

## 🚀 Next Steps

Bây giờ bạn đã hiểu:
1. ✅ Identity = User management framework
2. ✅ JWT = Authentication token
3. ✅ Cả hai làm việc cùng nhau
4. ✅ Best practice: Dùng cả hai

**Ready to implement!** 🎉
