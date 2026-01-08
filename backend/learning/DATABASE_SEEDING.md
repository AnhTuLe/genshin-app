# Database Seeding Guide

## 📋 Tổng quan

Hệ thống Database Seeding tự động tạo database và seed dữ liệu ban đầu khi ứng dụng khởi động lần đầu. Điều này đảm bảo:

- ✅ Mọi developer clone code về đều có database giống nhau
- ✅ Không cần phải setup database thủ công
- ✅ Dữ liệu mẫu tự động được tạo

---

## 🚀 Cách hoạt động

### 1. Tự động khi Start App

Khi bạn chạy ứng dụng trong **Development mode**, hệ thống sẽ:

1. **Tự động apply migrations** - Tạo/chạy tất cả migrations để tạo database schema
2. **Tự động seed dữ liệu** - Thêm dữ liệu mẫu vào database

Xem code trong `Program.cs`:

```csharp
// Tự động apply migrations và seed dữ liệu khi start
var isDevelopment = app.Environment.IsDevelopment();
await app.UseDatabaseMigrationAndSeedingAsync(isDevelopment);
```

### 2. Files liên quan

- **`DatabaseSeeder.cs`**: Chứa logic seed dữ liệu (users, roles, v.v.)
- **`DatabaseExtensions.cs`**: Extension methods để migrate và seed
- **`Program.cs`**: Gọi seed khi start app

---

## 📝 Dữ liệu được Seed tự động

### Roles (Vai trò)
- `Admin` - Quản trị viên
- `User` - Người dùng thông thường  
- `Moderator` - Điều hành viên

### Users (Người dùng mẫu)

#### Admin Account
- **Email**: `admin@example.com`
- **Username**: `admin`
- **Password**: `Admin@123`
- **Role**: `Admin`

#### User Account
- **Email**: `user@example.com`
- **Username**: `user`
- **Password**: `User@123`
- **Role**: `User`

⚠️ **LƯU Ý**: Hãy đổi mật khẩu ngay sau khi đăng nhập lần đầu!

---

## 🛠️ Sử dụng

### Cách 1: Tự động (Khuyến nghị)

Chỉ cần chạy ứng dụng trong Development mode:

```powershell
# Chạy backend API
cd backend\PriceArbitrage.API
dotnet run
```

Hoặc với Docker:

```powershell
docker-compose up
```

Database sẽ tự động được migrate và seed!

### Cách 2: Thủ công

Nếu muốn seed database thủ công:

```powershell
# Chạy script seed
.\backend\scripts\seed-database.ps1
```

---

## ✏️ Thêm dữ liệu Seed mới

### Bước 1: Mở `DatabaseSeeder.cs`

File: `backend/PriceArbitrage.Infrastructure/Data/DatabaseSeeder.cs`

### Bước 2: Thêm logic seed vào `SeedApplicationDataAsync`

Ví dụ: Seed Products

```csharp
private static async Task SeedApplicationDataAsync(ApplicationDbContext context)
{
    // Kiểm tra xem đã có dữ liệu chưa
    var productsExist = await context.Products.AnyAsync();
    
    if (!productsExist)
    {
        context.Products.AddRange(new[]
        {
            new Product 
            { 
                Name = "Product 1", 
                Price = 100,
                CreatedAt = DateTime.UtcNow
            },
            new Product 
            { 
                Name = "Product 2", 
                Price = 200,
                CreatedAt = DateTime.UtcNow
            }
        });
        
        await context.SaveChangesAsync();
    }
}
```

### Bước 3: Tạo Migration nếu cần

Nếu bạn thêm entity mới:

```powershell
cd backend\PriceArbitrage.API
dotnet ef migrations add AddProducts --project ..\PriceArbitrage.Infrastructure
```

### Bước 4: Test

Chạy lại app và kiểm tra xem dữ liệu đã được seed chưa.

---

## 🔍 Kiểm tra dữ liệu đã Seed

### Cách 1: Qua SQL Server Management Studio

1. Kết nối đến SQL Server (localhost,1433)
2. Login với `sa` / `Kimchau@1997`
3. Chọn database `PriceArbitrageDB`
4. Xem các bảng: `AspNetUsers`, `AspNetRoles`, `AspNetUserRoles`

### Cách 2: Qua API Endpoint

Tạo controller để kiểm tra (nếu cần):

```csharp
[ApiController]
[Route("api/[controller]")]
public class SeedController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly UserManager<IdentityUser> _userManager;

    [HttpGet("check")]
    public async Task<IActionResult> CheckSeededData()
    {
        var userCount = await _context.Users.CountAsync();
        var roleCount = await _context.Roles.CountAsync();
        
        return Ok(new 
        { 
            Users = userCount, 
            Roles = roleCount 
        });
    }
}
```

---

## ❓ FAQ

### Q: Seed data có chạy trong Production không?

**A:** Không! Seed data chỉ chạy trong **Development mode**. Trong Production, bạn nên seed dữ liệu thủ công hoặc qua scripts riêng.

Xem trong `Program.cs`:

```csharp
var isDevelopment = app.Environment.IsDevelopment();
await app.UseDatabaseMigrationAndSeedingAsync(isDevelopment);
```

### Q: Seed data có bị duplicate không?

**A:** Không! Logic seed đã kiểm tra dữ liệu tồn tại trước khi seed:

```csharp
var adminUser = await userManager.FindByEmailAsync(adminEmail);
if (adminUser == null) // Chỉ tạo nếu chưa tồn tại
{
    // Tạo user...
}
```

### Q: Làm sao để reset database và seed lại?

**A:** Có 2 cách:

**Cách 1: Drop và tạo lại**
```powershell
cd backend\PriceArbitrage.API
dotnet ef database drop --force
dotnet ef database update
dotnet run  # Sẽ tự động seed lại
```

**Cách 2: Xóa data trong tables**
```sql
DELETE FROM AspNetUserRoles;
DELETE FROM AspNetUsers;
DELETE FROM AspNetRoles;
```

Sau đó chạy lại app, seed sẽ tự động chạy.

### Q: Làm sao seed data trong Production?

**A:** Tạo một script riêng hoặc endpoint admin để seed data. **KHÔNG** tự động seed trong Production!

---

## 📚 Tài liệu liên quan

- [EF Core Migrations](https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/)
- [ASP.NET Core Identity](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity)
- [Database Seeding Best Practices](https://learn.microsoft.com/en-us/ef/core/modeling/data-seeding)

---

## 🎯 Best Practices

1. ✅ **Luôn kiểm tra dữ liệu tồn tại** trước khi seed
2. ✅ **Seed data chỉ chạy trong Development**
3. ✅ **Sử dụng migrations** để quản lý schema
4. ✅ **Không seed dữ liệu nhạy cảm** (real passwords, personal data)
5. ✅ **Document dữ liệu seed** trong file này

---

**Tác giả**: Genshin App Team  
**Cập nhật**: 2026-01-08
