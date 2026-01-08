# 📚 STEP 1: Authentication Concepts - Giải thích Chi tiết

Giải thích chi tiết các khái niệm cần hiểu trước khi implement.

---

## 🔐 1. Authentication là gì?

### Định nghĩa:
**Authentication** (Xác thực) là quá trình xác định danh tính của người dùng - trả lời câu hỏi **"Who are you?"** (Bạn là ai?)

### Ví dụ trong thực tế:
- Đăng nhập vào email với username/password
- Quẹt thẻ ATM (thẻ chứng minh bạn là chủ thẻ)
- Vân tay unlock điện thoại

### Trong Web Development:
```
User nhập: Email + Password
        ↓
System kiểm tra: Email có tồn tại? Password đúng không?
        ↓
Nếu đúng → User được authenticated (đã xác thực)
Nếu sai → Authentication failed (không xác thực được)
```

### Authentication Methods phổ biến:
1. **Username/Password** - Phổ biến nhất
2. **OAuth** - Đăng nhập qua Google, Facebook
3. **Biometric** - Vân tay, Face ID
4. **Multi-factor** - Password + SMS code

### Key Points:
- ✅ Authentication = Verify identity
- ✅ Trả lời: "Bạn là ai?"
- ✅ Diễn ra TRƯỚC authorization

---

## 🛡️ 2. Authorization là gì?

### Định nghĩa:
**Authorization** (Ủy quyền) là quá trình xác định quyền truy cập của người dùng đã được authenticated - trả lời câu hỏi **"What can you do?"** (Bạn có thể làm gì?)

### Ví dụ trong thực tế:
- Admin có thể xóa users, User thường thì không
- Owner có thể edit post, Others chỉ có thể view
- Premium user có thể xem content, Free user thì không

### Trong Web Development:
```
User đã authenticated
        ↓
User muốn DELETE /api/users/123
        ↓
System kiểm tra: User có quyền DELETE không?
        ↓
Nếu có quyền → Authorization successful (cho phép)
Nếu không → Authorization failed (403 Forbidden)
```

### Authorization Levels:
1. **Role-based** - Dựa vào role (Admin, User, Guest)
2. **Claim-based** - Dựa vào claims (CanEdit, CanDelete)
3. **Policy-based** - Dựa vào policy (RequireAge18)
4. **Resource-based** - Dựa vào resource ownership

### Key Points:
- ✅ Authorization = Check permissions
- ✅ Trả lời: "Bạn có thể làm gì?"
- ✅ Diễn ra SAU authentication

---

## 🔄 3. Mối quan hệ giữa Authentication và Authorization

### Flow:
```
1. User request → Need authentication?
   ↓ YES
2. Authenticate → Verify identity
   ↓ SUCCESS
3. User authenticated → Need authorization?
   ↓ YES
4. Authorize → Check permissions
   ↓ SUCCESS/Failure
5. Allow/Deny access
```

### Ví dụ cụ thể:

**Scenario**: User muốn xóa một product

```
1. User gọi DELETE /api/products/123
2. System: "Bạn đã login chưa?" → Authentication check
   - Nếu chưa → 401 Unauthorized
   - Nếu rồi → Continue
3. System: "Bạn có quyền xóa không?" → Authorization check
   - Nếu là Admin → 200 OK (cho phép)
   - Nếu là User → 403 Forbidden (không có quyền)
```

### Remember:
- ❌ **401 Unauthorized** = Authentication failed (chưa login hoặc token invalid)
- ✅ **403 Forbidden** = Authorization failed (đã login nhưng không có quyền)

---

## 🏗️ 4. ASP.NET Core Identity là gì?

### Định nghĩa:
**ASP.NET Core Identity** là một framework được Microsoft xây dựng để quản lý user accounts, authentication và authorization trong ASP.NET Core applications.

### Tại sao cần Identity?

**Nếu không dùng Identity:**
- ❌ Phải tự implement password hashing
- ❌ Phải tự implement email verification
- ❌ Phải tự implement password reset
- ❌ Phải tự implement role management
- ❌ Phải tự implement lockout (khóa tài khoản sau nhiều lần sai password)
- ❌ Phải tự thiết kế database schema cho users

**Với Identity:**
- ✅ Password hashing tự động (BCrypt)
- ✅ Email verification built-in
- ✅ Password reset built-in
- ✅ Role management built-in
- ✅ Account lockout built-in
- ✅ Database schema có sẵn
- ✅ Security best practices được implement sẵn

### Identity Components:

1. **IdentityUser** - Represents a user
   ```csharp
   - Id (string)
   - UserName
   - Email
   - PasswordHash (hashed, không lưu plain text)
   - EmailConfirmed
   - LockoutEnabled
   - ...
   ```

2. **IdentityRole** - Represents a role
   ```csharp
   - Id
   - Name (Admin, User, etc.)
   ```

3. **UserManager<TUser>** - Service để quản lý users
   ```csharp
   - CreateAsync(user, password)
   - FindByEmailAsync(email)
   - CheckPasswordAsync(user, password)
   - AddToRoleAsync(user, role)
   ```

4. **SignInManager<TUser>** - Service để đăng nhập
   ```csharp
   - PasswordSignInAsync(user, password, ...)
   ```

5. **IdentityDbContext** - Database context cho Identity tables

### Identity Database Tables:

Khi setup Identity, các tables sau được tạo:

- **AspNetUsers** - User accounts
- **AspNetRoles** - Roles (Admin, User, etc.)
- **AspNetUserRoles** - User-Role relationships
- **AspNetUserClaims** - User claims
- **AspNetRoleClaims** - Role claims
- **AspNetUserLogins** - External logins (Google, Facebook)
- **AspNetUserTokens** - User tokens

### Key Points:
- ✅ Identity = Framework để quản lý users
- ✅ Sử dụng sẵn → Không cần code từ đầu
- ✅ Security best practices built-in
- ✅ Extensible (có thể extend ApplicationUser)

---

## 🎫 5. JWT (JSON Web Token) là gì?

### Định nghĩa:
**JWT** là một chuẩn mở (RFC 7519) để truyền thông tin an toàn giữa các parties dưới dạng JSON object.

### Tại sao cần JWT?

**Vấn đề với Session-based Authentication:**
- ❌ Server phải lưu session (memory hoặc database)
- ❌ Khó scale (nhiều servers phải share sessions)
- ❌ Không phù hợp với mobile apps
- ❌ Không stateless (cần lưu trạng thái)

**JWT giải quyết:**
- ✅ Stateless (server không cần lưu gì)
- ✅ Dễ scale (không cần share sessions)
- ✅ Phù hợp với mobile/SPA
- ✅ Compact (nhỏ gọn, dễ truyền)

### JWT Structure:

JWT có 3 parts, separated by dots (.):

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

**Format**: `Header.Payload.Signature`

#### 1. Header:
```json
{
  "alg": "HS256",  // Algorithm (HMAC SHA256)
  "typ": "JWT"     // Type
}
```
→ Base64 encoded

#### 2. Payload (Claims):
```json
{
  "sub": "1234567890",           // Subject (User ID)
  "name": "John Doe",            // User name
  "email": "john@example.com",   // User email
  "role": "Admin",               // User role
  "iat": 1516239022,             // Issued at (timestamp)
  "exp": 1516242622              // Expiration (timestamp)
}
```
→ Base64 encoded

**Claims Types:**
- **Registered claims**: sub, exp, iat, iss (standard claims)
- **Public claims**: Có thể tự định nghĩa
- **Private claims**: Custom claims cho ứng dụng

#### 3. Signature:
```
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret
)
```
→ Đảm bảo token không bị giả mạo

### JWT Flow:

```
1. User login với email/password
   ↓
2. Server verify credentials
   ↓
3. Server generate JWT token
   ↓
4. Server return token cho client
   ↓
5. Client store token (localStorage, memory)
   ↓
6. Client gửi token trong header mỗi request:
   Authorization: Bearer <token>
   ↓
7. Server verify token signature
   ↓
8. Server extract claims từ token
   ↓
9. Server check authorization
   ↓
10. Server return response
```

### JWT Advantages:

✅ **Stateless** - Server không cần lưu sessions
✅ **Scalable** - Dễ scale horizontal
✅ **Cross-domain** - Có thể dùng cho nhiều domains
✅ **Mobile-friendly** - Phù hợp với mobile apps
✅ **Self-contained** - Token chứa tất cả info cần thiết

### JWT Disadvantages:

⚠️ **Token size** - Lớn hơn session ID
⚠️ **Cannot revoke** - Không thể revoke token trước khi expire (phải dùng blacklist)
⚠️ **Security** - Nếu token bị lộ, attacker có thể dùng đến khi expire

### JWT Security Best Practices:

1. **HTTPS only** - Luôn dùng HTTPS
2. **Short expiration** - Set expiration ngắn (15 phút - 1 giờ)
3. **Refresh tokens** - Dùng refresh token để renew
4. **Strong secret** - Secret key phải mạnh và dài
5. **Store safely** - Client phải store token an toàn

### Key Points:
- ✅ JWT = Stateless authentication token
- ✅ Format: Header.Payload.Signature
- ✅ Self-contained (chứa user info)
- ✅ Phù hợp với SPA/Mobile apps
- ✅ Cần bảo mật tốt

---

## 🔗 6. Kết hợp Identity và JWT

### Flow hoàn chỉnh:

```
1. User đăng ký
   ↓
2. Identity tạo user account
   ↓
3. User login với Identity
   ↓
4. Identity verify password
   ↓
5. Generate JWT token (chứa user info)
   ↓
6. Return JWT token cho client
   ↓
7. Client dùng JWT token cho các requests tiếp theo
   ↓
8. Server verify JWT token (không cần query Identity mỗi lần)
```

### Tại sao kết hợp?

- **Identity**: Quản lý users, passwords, roles
- **JWT**: Stateless authentication cho APIs

### Best Practice:
- ✅ Dùng Identity để quản lý users
- ✅ Dùng JWT để authenticate API requests
- ✅ JWT chứa minimal info (UserId, Email, Roles)
- ✅ Server verify JWT signature (không cần query database mỗi request)

---

## 📝 Tóm tắt

| Concept | Trả lời | Khi nào dùng |
|---------|---------|--------------|
| **Authentication** | "Who are you?" | Login, verify identity |
| **Authorization** | "What can you do?" | Check permissions |
| **Identity** | Framework quản lý users | User management, passwords |
| **JWT** | Stateless token | API authentication |

### Remember:
1. Authentication → Authorization (thứ tự quan trọng)
2. Identity = Quản lý users
3. JWT = Authentication token
4. Combine cả hai cho best practice

---

## ✅ Checklist Hiểu Concepts

Sau khi đọc và hiểu, bạn nên có thể trả lời:

- [ ] Authentication khác Authorization như thế nào?
- [ ] Tại sao cần ASP.NET Core Identity?
- [ ] JWT structure như thế nào? (3 parts)
- [ ] Tại sao dùng JWT thay vì sessions?
- [ ] Khi nào cần Authentication? Khi nào cần Authorization?
- [ ] Identity và JWT làm việc cùng nhau như thế nào?

---

**Bạn đã sẵn sàng cho STEP 2 chưa?** 🚀
