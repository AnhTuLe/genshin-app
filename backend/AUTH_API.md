# Authentication API Documentation

## 📋 Tổng quan

Hệ thống Authentication sử dụng **ASP.NET Core Identity** + **JWT Bearer Token** để quản lý đăng ký, đăng nhập và authorization.

### Kiến trúc
- **Identity**: Quản lý users, passwords, roles trong database
- **JWT**: Stateless authentication token cho API requests
- **Clean Architecture**: Tách biệt layers (API, Application, Infrastructure)

---

## 🔐 API Endpoints

### Base URL
```
http://localhost:5000/api/auth
```

### Swagger UI
```
http://localhost:5000/swagger
```

---

## 1. Register (Đăng ký)

### Endpoint
```
POST /api/auth/register
```

### Request Body
```json
{
  "email": "user@example.com",
  "userName": "username",
  "password": "Password@123",
  "confirmPassword": "Password@123"
}
```

### Validation Rules
- **Email**: Bắt buộc, phải là email hợp lệ
- **UserName**: Bắt buộc, 3-50 ký tự
- **Password**: Bắt buộc, ít nhất 8 ký tự, phải chứa:
  - Ít nhất 1 chữ hoa
  - Ít nhất 1 chữ thường
  - Ít nhất 1 số
  - Ít nhất 1 ký tự đặc biệt (@$!%*?&#)
- **ConfirmPassword**: Phải khớp với password

### Response (200 OK)
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2026-01-08T18:00:00Z",
  "userId": "abc123...",
  "email": "user@example.com",
  "userName": "username",
  "roles": ["User"]
}
```

### Response (400 Bad Request)
```json
{
  "message": "Đăng ký thất bại. Email hoặc Username có thể đã được sử dụng.",
  "errors": { ... }
}
```

---

## 2. Login (Đăng nhập)

### Endpoint
```
POST /api/auth/login
```

### Request Body
```json
{
  "email": "user@example.com",
  "password": "Password@123"
}
```

### Validation Rules
- **Email**: Bắt buộc, phải là email hợp lệ
- **Password**: Bắt buộc

### Response (200 OK)
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2026-01-08T18:00:00Z",
  "userId": "abc123...",
  "email": "user@example.com",
  "userName": "username",
  "roles": ["User"]
}
```

### Response (401 Unauthorized)
```json
{
  "message": "Email hoặc password không đúng. Vui lòng thử lại."
}
```

### Lưu ý
- Nếu đăng nhập sai 5 lần, tài khoản sẽ bị khóa trong 5 phút
- Token có thời hạn 60 phút (có thể cấu hình trong appsettings.json)

---

## 3. Get Current User (Lấy thông tin user hiện tại)

### Endpoint
```
GET /api/auth/me
```

### Headers
```
Authorization: Bearer {token}
```

### Response (200 OK)
```json
{
  "userId": "abc123...",
  "email": "user@example.com",
  "userName": "username",
  "roles": ["User"],
  "emailConfirmed": false
}
```

### Response (401 Unauthorized)
```json
{
  "message": "Không tìm thấy thông tin user"
}
```

### Response (404 Not Found)
```json
{
  "message": "Không tìm thấy user"
}
```

---

## 🧪 Testing với Swagger

### Bước 1: Mở Swagger UI
```
http://localhost:5000/swagger
```

### Bước 2: Test Register
1. Tìm endpoint `POST /api/auth/register`
2. Click "Try it out"
3. Nhập thông tin đăng ký
4. Click "Execute"
5. Copy token từ response

### Bước 3: Test Login
1. Tìm endpoint `POST /api/auth/login`
2. Click "Try it out"
3. Nhập email/password (hoặc dùng tài khoản seed: `admin@example.com` / `Admin@123`)
4. Click "Execute"
5. Copy token từ response

### Bước 4: Test Get Current User
1. Tìm endpoint `GET /api/auth/me`
2. Click "Authorize" button (🔒) ở trên cùng
3. Nhập token: `Bearer {your_token}`
4. Click "Authorize"
5. Click "Try it out"
6. Click "Execute"

---

## 🧪 Testing với cURL

### Register
```bash
curl -X POST "http://localhost:5000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "userName": "testuser",
    "password": "Test@123",
    "confirmPassword": "Test@123"
  }'
```

### Login
```bash
curl -X POST "http://localhost:5000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "Admin@123"
  }'
```

### Get Current User
```bash
curl -X GET "http://localhost:5000/api/auth/me" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 🧪 Testing với PowerShell

### Register
```powershell
$body = @{
    email = "test@example.com"
    userName = "testuser"
    password = "Test@123"
    confirmPassword = "Test@123"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/api/auth/register" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"
```

### Login
```powershell
$body = @{
    email = "admin@example.com"
    password = "Admin@123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/login" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"

# Lưu token
$token = $response.token
Write-Host "Token: $token"
```

### Get Current User
```powershell
$headers = @{
    Authorization = "Bearer $token"
}

Invoke-RestMethod -Uri "http://localhost:5000/api/auth/me" `
    -Method Get `
    -Headers $headers
```

---

## 🔑 Tài khoản Seed (Mẫu)

Khi database được seed, các tài khoản sau sẽ tự động được tạo:

### Admin Account
- **Email**: `admin@example.com`
- **Username**: `admin`
- **Password**: `Admin@123`
- **Role**: `Admin`

### User Account
- **Email**: `user@example.com`
- **Username**: `user`
- **Password**: `User@123`
- **Role**: `User`

⚠️ **Lưu ý**: Hãy đổi mật khẩu sau khi đăng nhập lần đầu!

---

## ⚙️ Cấu hình JWT

File: `appsettings.json` hoặc `appsettings.Development.json`

```json
{
  "JwtSettings": {
    "SecretKey": "YourVeryLongAndSecureSecretKeyForJWTTokenGeneration2024!@#$%^&*()MustBeAtLeast32Characters",
    "Issuer": "PriceArbitrageAPI",
    "Audience": "PriceArbitrageClient",
    "ExpirationMinutes": 60
  }
}
```

### Parameters
- **SecretKey**: Secret key để sign JWT token (phải ít nhất 32 ký tự)
- **Issuer**: Tên issuer của token
- **Audience**: Tên audience của token
- **ExpirationMinutes**: Thời hạn token (mặc định: 60 phút)

⚠️ **Production**: Hãy thay đổi SecretKey và lưu trong environment variables hoặc secret manager!

---

## 🔒 Sử dụng JWT Token trong Frontend

### 1. Sau khi login, lưu token
```javascript
const response = await fetch('http://localhost:5000/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password })
});

const data = await response.json();
localStorage.setItem('token', data.token);
```

### 2. Gửi token trong mỗi request
```javascript
const token = localStorage.getItem('token');

const response = await fetch('http://localhost:5000/api/auth/me', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
```

---

## 📚 Files liên quan

### Application Layer
- `Application/DTOs/Auth/RegisterRequest.cs`
- `Application/DTOs/Auth/LoginRequest.cs`
- `Application/DTOs/Auth/AuthResponse.cs`
- `Application/DTOs/Auth/UserInfoResponse.cs`
- `Application/Interfaces/IAuthService.cs`

### Infrastructure Layer
- `Infrastructure/Services/AuthService.cs`

### API Layer
- `API/Controllers/AuthController.cs`
- `API/Models/JwtSettings.cs`
- `API/Program.cs` (JWT configuration)

---

## ✅ Checklist

- [x] Register endpoint
- [x] Login endpoint
- [x] Get current user endpoint
- [x] JWT token generation
- [x] JWT token validation
- [x] Password validation
- [x] Role-based authorization
- [x] Swagger integration
- [x] Error handling
- [x] Logging

---

**Tác giả**: Genshin App Team  
**Cập nhật**: 2026-01-08
