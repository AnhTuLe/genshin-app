# ✅ Phase 1: User Authentication - Quick Checklist

Checklist nhanh để track progress qua từng step.

---

## 📊 Progress Overview

- [ ] **STEP 1**: Authentication Concepts (0%)
- [ ] **STEP 2**: Setup Identity (0%)
- [ ] **STEP 3**: User Registration (0%)
- [ ] **STEP 4**: JWT Authentication (0%)
- [ ] **STEP 5**: Authorization (0%)
- [ ] **STEP 6**: Frontend Auth (0%)
- [ ] **STEP 7**: Password Reset (Optional) (0%)

---

## 📘 STEP 1: Authentication Concepts

**Status**: ⬜ Not Started | 🔄 In Progress | ✅ Completed

### Learning:

- [ ] Đọc Microsoft Docs về Identity
- [ ] Đọc JWT.io introduction
- [ ] Xem video "ASP.NET Core Identity Explained"
- [ ] Xem video "JWT Authentication in ASP.NET Core"

### Understanding:

- [ ] Hiểu Authentication là gì
- [ ] Hiểu Authorization là gì
- [ ] Hiểu Identity framework
- [ ] Hiểu JWT structure và cách hoạt động

### Notes:

- [ ] Ghi chú về concepts quan trọng
- [ ] Questions cần tìm hiểu thêm

**Completed**: **_ / _**

---

## 📘 STEP 2: Setup Identity

**Status**: ⬜ Not Started | 🔄 In Progress | ✅ Completed

### Packages:

- [ ] Microsoft.AspNetCore.Identity.EntityFrameworkCore
- [ ] Microsoft.EntityFrameworkCore.SqlServer
- [ ] Microsoft.EntityFrameworkCore.Tools

### Implementation:

- [ ] ApplicationUser class created
- [ ] Identity configured trong Program.cs
- [ ] Migration created
- [ ] Migration applied
- [ ] Database tables verified

### Understanding:

- [ ] Hiểu Identity DbContext
- [ ] Hiểu ApplicationUser extension
- [ ] Hiểu Identity configuration options
- [ ] Hiểu Identity tables structure

**Completed**: **_ / _**

---

## 📘 STEP 3: User Registration

**Status**: ⬜ Not Started | 🔄 In Progress | ✅ Completed

### DTOs:

- [ ] RegisterRequest DTO
- [ ] RegisterResponse DTO

### Service:

- [ ] IUserService interface
- [ ] UserService implementation
- [ ] Registration logic

### Controller:

- [ ] AuthController created
- [ ] Register endpoint [HttpPost]
- [ ] Model validation
- [ ] Error handling

### Testing:

- [ ] Test registration với valid data
- [ ] Test validation errors
- [ ] Test duplicate email
- [ ] Verify user trong database

**Completed**: **_ / _**

---

## 📘 STEP 4: JWT Authentication

**Status**: ⬜ Not Started | 🔄 In Progress | ✅ Completed

### Configuration:

- [ ] JWT settings trong appsettings.json
- [ ] JwtSettings class
- [ ] JWT packages installed
- [ ] JWT configured trong Program.cs

### Service:

- [ ] IJwtService interface
- [ ] JwtService implementation
- [ ] GenerateToken method

### Login:

- [ ] LoginRequest DTO
- [ ] LoginResponse DTO
- [ ] Login endpoint implemented
- [ ] Token generation working

### Testing:

- [ ] Test login với valid credentials
- [ ] Test login với invalid credentials
- [ ] Verify token trong jwt.io
- [ ] Test token expiration

**Completed**: **_ / _**

---

## 📘 STEP 5: Authorization

**Status**: ⬜ Not Started | 🔄 In Progress | ✅ Completed

### Basics:

- [ ] [Authorize] attribute tested
- [ ] [AllowAnonymous] attribute tested
- [ ] GetCurrentUser endpoint

### Roles:

- [ ] Roles created (Admin, User)
- [ ] Role assignment working
- [ ] Role-based authorization tested

### Policies:

- [ ] Custom policy created
- [ ] Policy-based authorization tested

**Completed**: **_ / _**

---

## 📘 STEP 6: Frontend Auth

**Status**: ⬜ Not Started | 🔄 In Progress | ✅ Completed

### Setup:

- [ ] Axios installed
- [ ] API service created
- [ ] Base URL configured

### API Calls:

- [ ] Register API function
- [ ] Login API function
- [ ] GetCurrentUser API function

### State Management:

- [ ] AuthContext created
- [ ] useAuth hook
- [ ] Token storage (localStorage)
- [ ] User info storage

### Pages:

- [ ] Login page
- [ ] Register page
- [ ] Form validation
- [ ] Error handling

### Routes:

- [ ] ProtectedRoute component
- [ ] Route protection setup
- [ ] Logout functionality

### Interceptors:

- [ ] Request interceptor (add token)
- [ ] Response interceptor (handle 401)
- [ ] Auto logout on token expiration

**Completed**: **_ / _**

---

## 📘 STEP 7: Password Reset (Optional)

**Status**: ⬜ Not Started | 🔄 In Progress | ✅ Completed | ❌ Skipped

### Forgot Password:

- [ ] ForgotPasswordRequest DTO
- [ ] ForgotPassword endpoint
- [ ] Reset token generation

### Reset Password:

- [ ] ResetPasswordRequest DTO
- [ ] ResetPassword endpoint
- [ ] Token validation

### Testing:

- [ ] Test forgot password flow
- [ ] Test reset password flow

**Completed**: **_ / _**

---

## 🎯 Phase 1 Final Checklist

### Backend:

- [ ] Identity setup complete
- [ ] Registration working
- [ ] Login working
- [ ] JWT tokens working
- [ ] Protected endpoints working
- [ ] Authorization working

### Frontend:

- [ ] Login page working
- [ ] Register page working
- [ ] Token management working
- [ ] Protected routes working
- [ ] Auto logout working

### Documentation:

- [ ] Code documented
- [ ] API endpoints documented
- [ ] Notes về learnings

---

## 📝 Daily Progress Log

### Week 1:

- **Day 1**: **********\_\_\_\_**********
- **Day 2**: **********\_\_\_\_**********
- **Day 3**: **********\_\_\_\_**********
- **Day 4**: **********\_\_\_\_**********
- **Day 5**: **********\_\_\_\_**********

### Week 2:

- **Day 1**: **********\_\_\_\_**********
- **Day 2**: **********\_\_\_\_**********
- **Day 3**: **********\_\_\_\_**********
- **Day 4**: **********\_\_\_\_**********
- **Day 5**: **********\_\_\_\_**********

### Week 3:

- **Day 1**: **********\_\_\_\_**********
- **Day 2**: **********\_\_\_\_**********
- **Day 3**: **********\_\_\_\_**********
- **Day 4**: **********\_\_\_\_**********
- **Day 5**: **********\_\_\_\_**********

---

## 💡 Tips

- Check off items khi hoàn thành
- Update status khi bắt đầu step mới
- Ghi chú learnings và blockers
- Celebrate small wins! 🎉
