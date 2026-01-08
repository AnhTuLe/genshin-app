# 📚 Phase 1: User Authentication - Learning Plan

Kế hoạch học tập chi tiết cho Phase 1, tập trung vào việc học các kiến thức cần thiết trước khi implement.

---

## 🎯 Mục tiêu Phase 1

Sau khi hoàn thành Phase 1, bạn sẽ:

- ✅ Hiểu cách hoạt động của Authentication & Authorization trong ASP.NET Core
- ✅ Biết cách setup và sử dụng ASP.NET Core Identity
- ✅ Hiểu JWT tokens và cách implement JWT authentication
- ✅ Có thể tạo RESTful APIs cho user registration/login
- ✅ Frontend có thể gọi APIs và xử lý authentication flow

---

## 📖 Kiến thức cần học (Theo Career Guide)

### 1. ASP.NET Core Authentication & Authorization

- ASP.NET Core Identity
- JWT (JSON Web Tokens)
- Authentication vs Authorization
- Claims-based authentication
- Role-based access control (RBAC)

### 2. .NET Core Fundamentals

- Dependency Injection
- Configuration (appsettings.json, IConfiguration)
- Middleware pipeline
- IActionResult và API responses

### 3. Entity Framework Core

- DbContext
- Migrations
- Relationships (User → Roles)
- Code First approach

### 4. RESTful API

- HTTP methods (POST, GET)
- Status codes (200, 201, 400, 401)
- Request/Response models
- API versioning (basic)

---

## 📋 Learning Path - Step by Step

### 📘 STEP 1: Học về Authentication Concepts (1-2 ngày)

**Mục tiêu**: Hiểu các khái niệm cơ bản

#### Kiến thức cần nắm:

1. **Authentication là gì?**

   - Xác định "Who you are" (Bạn là ai)
   - Verify identity của user
   - Ví dụ: Login với username/password

2. **Authorization là gì?**

   - Xác định "What you can do" (Bạn có thể làm gì)
   - Check permissions sau khi đã authenticated
   - Ví dụ: Admin có thể delete users, User chỉ có thể view

3. **ASP.NET Core Identity là gì?**

   - Framework quản lý user accounts
   - Built-in: Password hashing, Email confirmation, Role management
   - Database schema cho users, roles, claims

4. **JWT Token là gì?**
   - JSON Web Token
   - Stateless authentication (không cần lưu session trên server)
   - Structure: Header.Payload.Signature
   - Expiration time

#### Learning Resources:

- [ ] **Đọc**: Microsoft Docs - [Introduction to Identity](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity?view=aspnetcore-8.0)
- [ ] **Đọc**: [JWT.io](https://jwt.io/introduction) - Understanding JWT
- [ ] **Xem video**: YouTube - "ASP.NET Core Identity Explained" (15-20 phút)
- [ ] **Xem video**: "JWT Authentication in ASP.NET Core" (20-30 phút)

#### Checklist:

- [ ] Hiểu difference giữa Authentication và Authorization
- [ ] Hiểu Identity là gì và tại sao cần dùng
- [ ] Hiểu JWT token structure và cách hoạt động
- [ ] Biết khi nào dùng JWT vs Session-based auth

**Estimated Time**: 2-4 giờ

---

### 📘 STEP 2: Setup ASP.NET Core Identity (2-3 ngày)

**Mục tiêu**: Setup Identity trong project và hiểu cách nó hoạt động

#### Tasks:

1. **Day 1: Research và Planning**

   - [ ] Đọc docs về Identity setup
   - [ ] Hiểu Identity DbContext
   - [ ] Hiểu IdentityUser class
   - [ ] Plan database structure

2. **Day 2: Install Packages**

   - [ ] Install `Microsoft.AspNetCore.Identity.EntityFrameworkCore`
   - [ ] Install `Microsoft.EntityFrameworkCore.SqlServer` (hoặc PostgreSQL)
   - [ ] Install `Microsoft.EntityFrameworkCore.Tools` (cho migrations)
   - [ ] Hiểu mỗi package làm gì

3. **Day 3: Create ApplicationUser**

   - [ ] Tạo class ApplicationUser extends IdentityUser
   - [ ] Thêm custom properties (FirstName, LastName, etc.)
   - [ ] Hiểu tại sao cần extend IdentityUser

4. **Day 4: Configure Identity trong Program.cs**

   - [ ] Add Identity service vào DI container
   - [ ] Configure Identity options (password requirements, lockout, etc.)
   - [ ] Add Identity DbContext
   - [ ] Hiểu mỗi configuration option

5. **Day 5: Create Migration**
   - [ ] Tạo migration cho Identity tables
   - [ ] Review migration files (hiểu các tables được tạo)
   - [ ] Apply migration
   - [ ] Kiểm tra database tables

#### Learning Resources:

- [ ] **Docs**: [Configure Identity](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity-configuration?view=aspnetcore-8.0)
- [ ] **Tutorial**: Microsoft Learn - "Add Identity to an ASP.NET Core project"
- [ ] **Video**: "ASP.NET Core Identity Setup Tutorial"

#### Concepts cần hiểu:

- [ ] Dependency Injection - Services.AddIdentity()
- [ ] DbContext - IdentityDbContext
- [ ] Migrations - dotnet ef migrations add
- [ ] Database schema - Identity tables structure

#### Checklist:

- [ ] Identity packages installed
- [ ] ApplicationUser created
- [ ] Identity configured trong Program.cs
- [ ] Migration created và applied
- [ ] Database có Identity tables
- [ ] Hiểu mỗi Identity table dùng để làm gì

**Estimated Time**: 8-12 giờ

---

### 📘 STEP 3: Implement User Registration (2-3 ngày)

**Mục tiêu**: Tạo API endpoint để user đăng ký

#### Tasks:

1. **Day 1: Design API Contract**

   - [ ] Thiết kế RegisterRequest DTO (Email, Password, ConfirmPassword, etc.)
   - [ ] Thiết kế RegisterResponse DTO (Success, UserId, Errors)
   - [ ] Viết API documentation (Swagger annotations)
   - [ ] Hiểu DTO pattern và tại sao cần DTO

2. **Day 2: Create Registration Service**

   - [ ] Tạo IUserService interface
   - [ ] Implement UserService
   - [ ] Inject UserManager<ApplicationUser>
   - [ ] Implement registration logic:
     - Validate input
     - Check email exists
     - Create user với UserManager
     - Handle errors
   - [ ] Hiểu UserManager là gì

3. **Day 3: Create Controller**

   - [ ] Tạo AuthController
   - [ ] Create Register endpoint [HttpPost("register")]
   - [ ] Validate model state
   - [ ] Call service
   - [ ] Return appropriate status codes
   - [ ] Add Swagger documentation

4. **Day 4: Error Handling**

   - [ ] Handle Identity errors
   - [ ] Return meaningful error messages
   - [ ] Custom error responses
   - [ ] Test với invalid data

5. **Day 5: Testing**
   - [ ] Test registration với Postman/Swagger
   - [ ] Test validation
   - [ ] Test duplicate email
   - [ ] Verify user created trong database

#### Learning Resources:

- [ ] **Docs**: [UserManager<TUser>](https://learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.identity.usermanager-1)
- [ ] **Docs**: [Create user with Identity](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity?view=aspnetcore-8.0#create-a-user)
- [ ] **Video**: "Implement User Registration in ASP.NET Core"

#### Concepts cần hiểu:

- [ ] DTO (Data Transfer Object) pattern
- [ ] Model Validation
- [ ] UserManager<TUser> - Identity service
- [ ] IActionResult và status codes
- [ ] Error handling patterns

#### Checklist:

- [ ] RegisterRequest DTO created
- [ ] UserService implemented
- [ ] Register endpoint working
- [ ] Can create user via API
- [ ] Error handling working
- [ ] Tested với Postman/Swagger

**Estimated Time**: 10-15 giờ

---

### 📘 STEP 4: Implement JWT Authentication (3-4 ngày)

**Mục tiêu**: Setup JWT và tạo Login endpoint

#### Tasks:

1. **Day 1: Understand JWT Configuration**

   - [ ] Hiểu JWT settings (Secret Key, Issuer, Audience, Expiration)
   - [ ] Add JWT settings vào appsettings.json
   - [ ] Create JwtSettings class
   - [ ] Bind configuration với IOptions<JwtSettings>
   - [ ] Hiểu Options Pattern

2. **Day 2: Install và Configure JWT**

   - [ ] Install `Microsoft.AspNetCore.Authentication.JwtBearer`
   - [ ] Configure JWT authentication scheme
   - [ ] Setup token validation parameters
   - [ ] Hiểu mỗi configuration option

3. **Day 3: Create JWT Service**

   - [ ] Create IJwtService interface
   - [ ] Implement JwtService
   - [ ] Method: GenerateToken(ApplicationUser)
   - [ ] Add claims (UserId, Email, Roles)
   - [ ] Set expiration time
   - [ ] Hiểu Claims là gì

4. **Day 4: Implement Login**

   - [ ] Create LoginRequest DTO
   - [ ] Create LoginResponse DTO (Token, RefreshToken, ExpiresIn)
   - [ ] Implement login logic:
     - Find user by email
     - Verify password với UserManager
     - Generate JWT token
     - Return token
   - [ ] Handle invalid credentials

5. **Day 5: Test Login**
   - [ ] Test login với valid credentials
   - [ ] Test login với invalid credentials
   - [ ] Verify token trong [jwt.io](https://jwt.io)
   - [ ] Test token expiration

#### Learning Resources:

- [ ] **Docs**: [JWT Authentication in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/jwt-authn?view=aspnetcore-8.0)
- [ ] **Docs**: [Options Pattern](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration/options?view=aspnetcore-8.0)
- [ ] **Video**: "JWT Authentication Tutorial in ASP.NET Core"
- [ ] **Tool**: [jwt.io](https://jwt.io) - Debug JWT tokens

#### Concepts cần hiểu:

- [ ] JWT structure (Header, Payload, Signature)
- [ ] Claims - Thông tin trong token
- [ ] Options Pattern - IOptions<T>
- [ ] Authentication Scheme
- [ ] Token expiration và refresh

#### Checklist:

- [ ] JWT packages installed
- [ ] JWT configured trong Program.cs
- [ ] JwtService implemented
- [ ] Login endpoint working
- [ ] Can generate và verify JWT tokens
- [ ] Token có claims (UserId, Email)

**Estimated Time**: 12-16 giờ

---

### 📘 STEP 5: Protect APIs với Authorization (2-3 ngày)

**Mục tiêu**: Bảo vệ APIs và implement role-based authorization

#### Tasks:

1. **Day 1: Understand Authorization Attributes**

   - [ ] [Authorize] attribute
   - [ ] [AllowAnonymous] attribute
   - [ ] Test protected endpoint without token
   - [ ] Test protected endpoint với token

2. **Day 2: Implement GetCurrentUser**

   - [ ] Create GetCurrentUser endpoint
   - [ ] Get user info từ JWT claims
   - [ ] Return user profile
   - [ ] Test endpoint

3. **Day 3: Role-based Authorization**

   - [ ] Create Roles (Admin, User)
   - [ ] Assign role to user
   - [ ] [Authorize(Roles = "Admin")]
   - [ ] Test role-based access

4. **Day 4: Custom Authorization Policies**

   - [ ] Create custom policy
   - [ ] [Authorize(Policy = "RequireAdmin")]
   - [ ] Test policies

5. **Day 5: Review và Practice**
   - [ ] Review all authorization concepts
   - [ ] Practice với different scenarios
   - [ ] Document authorization rules

#### Learning Resources:

- [ ] **Docs**: [Authorization in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/security/authorization/introduction?view=aspnetcore-8.0)
- [ ] **Docs**: [Role-based Authorization](https://learn.microsoft.com/en-us/aspnet/core/security/authorization/roles?view=aspnetcore-8.0)
- [ ] **Video**: "Authorization in ASP.NET Core"

#### Concepts cần hiểu:

- [ ] [Authorize] attribute
- [ ] Claims-based authorization
- [ ] Role-based authorization
- [ ] Policy-based authorization
- [ ] User.Identity vs User.Claims

#### Checklist:

- [ ] Can protect endpoints với [Authorize]
- [ ] GetCurrentUser endpoint working
- [ ] Roles created và assigned
- [ ] Role-based authorization working
- [ ] Custom policies working

**Estimated Time**: 10-15 giờ

---

### 📘 STEP 6: Frontend Authentication (3-4 ngày)

**Mục tiêu**: Frontend có thể login/register và call protected APIs

#### Tasks:

1. **Day 1: Setup Axios và API Service**

   - [ ] Install axios
   - [ ] Create API service (api.ts)
   - [ ] Setup base URL
   - [ ] Create axios instance
   - [ ] Hiểu axios interceptors

2. **Day 2: Implement API Calls**

   - [ ] Create register API function
   - [ ] Create login API function
   - [ ] Create getCurrentUser API function
   - [ ] Handle API errors
   - [ ] Test với backend

3. **Day 3: Auth Context/State Management**

   - [ ] Create AuthContext
   - [ ] Store token trong localStorage
   - [ ] Store user info
   - [ ] AuthProvider component
   - [ ] useAuth hook

4. **Day 4: Login/Register Pages**

   - [ ] Create Login page
   - [ ] Create Register page
   - [ ] Form validation
   - [ ] Handle submit
   - [ ] Redirect after login

5. **Day 5: Protected Routes**

   - [ ] Create ProtectedRoute component
   - [ ] Redirect to login if not authenticated
   - [ ] Setup route protection
   - [ ] Logout functionality

6. **Day 6: Axios Interceptor**
   - [ ] Setup request interceptor (add token)
   - [ ] Setup response interceptor (handle 401)
   - [ ] Auto logout khi token expired
   - [ ] Test interceptor

#### Learning Resources:

- [ ] **Docs**: [Axios Documentation](https://axios-http.com/docs/intro)
- [ ] **Docs**: [React Context API](https://react.dev/reference/react/useContext)
- [ ] **Video**: "React Authentication with JWT"

#### Concepts cần hiểu:

- [ ] Axios - HTTP client
- [ ] Axios interceptors
- [ ] React Context API
- [ ] localStorage
- [ ] Protected routes
- [ ] Token storage và security

#### Checklist:

- [ ] Axios setup và configured
- [ ] Can call register/login APIs
- [ ] AuthContext working
- [ ] Login/Register pages working
- [ ] Protected routes working
- [ ] Token stored và sent with requests
- [ ] Auto logout khi token expired

**Estimated Time**: 15-20 giờ

---

### 📘 STEP 7: Password Reset Flow (Optional - 2 ngày)

**Mục tiêu**: Implement forgot password và reset password

#### Tasks:

1. **Day 1: Forgot Password**

   - [ ] Create ForgotPasswordRequest DTO
   - [ ] Generate reset token với UserManager
   - [ ] Send email với reset link (có thể mock email)
   - [ ] Create ForgotPassword endpoint

2. **Day 2: Reset Password**
   - [ ] Create ResetPasswordRequest DTO
   - [ ] Validate reset token
   - [ ] Reset password với UserManager
   - [ ] Create ResetPassword endpoint
   - [ ] Test flow

#### Learning Resources:

- [ ] **Docs**: [Password Reset with Identity](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/accconfirm?view=aspnetcore-8.0)

#### Checklist:

- [ ] Forgot password working
- [ ] Reset password working
- [ ] Can reset password với valid token

**Estimated Time**: 6-8 giờ (Optional)

---

## 📊 Tổng kết Timeline

| Step   | Tên                       | Thời gian |
| ------ | ------------------------- | --------- |
| Step 1 | Authentication Concepts   | 2-4 giờ   |
| Step 2 | Setup Identity            | 8-12 giờ  |
| Step 3 | User Registration         | 10-15 giờ |
| Step 4 | JWT Authentication        | 12-16 giờ |
| Step 5 | Authorization             | 10-15 giờ |
| Step 6 | Frontend Auth             | 15-20 giờ |
| Step 7 | Password Reset (Optional) | 6-8 giờ   |

**Total**: ~70-90 giờ (2-3 tuần part-time)

---

## ✅ Phase 1 Deliverables Checklist

### Backend:

- [ ] ASP.NET Core Identity setup
- [ ] ApplicationUser created
- [ ] Database migration applied
- [ ] Register endpoint working
- [ ] Login endpoint working
- [ ] JWT authentication configured
- [ ] GetCurrentUser endpoint working
- [ ] Protected endpoints working
- [ ] Role-based authorization working

### Frontend:

- [ ] API service setup (axios)
- [ ] Login page
- [ ] Register page
- [ ] AuthContext/State management
- [ ] Protected routes
- [ ] Token management
- [ ] Auto logout on token expiration

### Testing:

- [ ] Test registration
- [ ] Test login
- [ ] Test protected APIs
- [ ] Test role-based access
- [ ] Test frontend auth flow

---

## 🎓 Learning Strategy

### Cho mỗi Step:

1. **Đọc tài liệu trước** (30 phút - 1 giờ)

   - Đọc Microsoft Docs
   - Hiểu concepts
   - Note lại questions

2. **Xem video tutorial** (30 phút - 1 giờ)

   - Follow along
   - Pause và rewind khi cần
   - Note important points

3. **Thực hành** (Phần lớn thời gian)

   - Implement từng bước nhỏ
   - Test thường xuyên
   - Debug khi gặp lỗi
   - Experiment và học từ mistakes

4. **Review và Document** (30 phút)
   - Review code
   - Document learnings
   - Note concepts quan trọng

### Tips:

- ✅ **Don't rush** - Hiểu concepts quan trọng hơn code nhanh
- ✅ **Test often** - Test sau mỗi thay đổi nhỏ
- ✅ **Ask questions** - Google, Stack Overflow, communities
- ✅ **Break it down** - Chia nhỏ tasks, làm từng bước
- ✅ **Take notes** - Note lại những gì học được
- ✅ **Experiment** - Thử nghiệm với code để hiểu rõ hơn

---

## 🚀 Ready to Start?

**Bắt đầu với Step 1**: Học về Authentication Concepts

Sau khi hoàn thành mỗi Step, bạn sẽ:

- Hiểu concepts cơ bản
- Có code working
- Ready cho step tiếp theo

**Bạn có muốn tôi tạo checklist chi tiết cho Step 1 không?** Hoặc bạn muốn bắt đầu với Step nào?
