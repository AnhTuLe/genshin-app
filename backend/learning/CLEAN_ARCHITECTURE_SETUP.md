# 🏗️ Clean Architecture Setup Guide

Hướng dẫn chi tiết để setup Clean Architecture cho dự án Price Arbitrage Platform.

---

## 🎯 Clean Architecture là gì?

### Định nghĩa:

**Clean Architecture** (Kiến trúc sạch) là một kiến trúc phần mềm giúp:

- ✅ **Separation of Concerns** - Tách biệt rõ ràng các layers
- ✅ **Dependency Inversion** - Dependencies hướng vào trong (toward core)
- ✅ **Testable** - Dễ dàng test từng layer độc lập
- ✅ **Maintainable** - Dễ bảo trì và mở rộng
- ✅ **Independent** - Không phụ thuộc vào frameworks, databases, UI

### Layers trong Clean Architecture:

```
┌─────────────────────────────────────┐
│   Presentation Layer (API)          │  ← Controllers, HTTP
├─────────────────────────────────────┤
│   Application Layer                 │  ← Use Cases, Business Logic
├─────────────────────────────────────┤
│   Domain Layer (Core)               │  ← Entities, Interfaces
├─────────────────────────────────────┤
│   Infrastructure Layer              │  ← Data Access, External Services
└─────────────────────────────────────┘
```

**Dependency Flow**:

- Outer layers depend on inner layers
- Inner layers KHÔNG depend on outer layers

---

## 📁 Project Structure

### Solution Structure:

```
PriceArbitrage.sln
│
├── PriceArbitrage.API/                    (Presentation Layer)
│   ├── Controllers/
│   ├── Program.cs
│   ├── Properties/
│   └── PriceArbitrage.API.csproj
│
├── PriceArbitrage.Application/            (Application Layer)
│   ├── Services/
│   ├── DTOs/
│   ├── Mappings/
│   ├── Interfaces/
│   └── PriceArbitrage.Application.csproj
│
├── PriceArbitrage.Domain/                 (Domain Layer - Core)
│   ├── Entities/
│   ├── ValueObjects/
│   ├── Enums/
│   ├── Interfaces/
│   └── PriceArbitrage.Domain.csproj
│
├── PriceArbitrage.Infrastructure/         (Infrastructure Layer)
│   ├── Data/
│   ├── Services/
│   ├── Repositories/
│   ├── External/
│   └── PriceArbitrage.Infrastructure.csproj
│
└── PriceArbitrage.Tests/                  (Tests)
    ├── Unit/
    ├── Integration/
    └── PriceArbitrage.Tests.csproj
```

---

## 🎯 Mỗi Layer làm gì?

### 1. Domain Layer (Core - Trung tâm)

**Nhiệm vụ:**

- ✅ Chứa business entities (Product, User, Order, etc.)
- ✅ Chứa interfaces (IProductRepository, IUserService, etc.)
- ✅ Chứa value objects, enums
- ✅ Business rules và validation
- ✅ **KHÔNG** phụ thuộc vào bất kỳ layer nào khác

**Ví dụ:**

```csharp
// Domain/Entities/Product.cs
namespace PriceArbitrage.Domain.Entities;

public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
    // Business logic ở đây
}
```

### 2. Application Layer (Business Logic)

**Nhiệm vụ:**

- ✅ Use cases (RegisterUser, CreateProduct, etc.)
- ✅ Business logic
- ✅ DTOs (Data Transfer Objects)
- ✅ Mapping (Entity ↔ DTO)
- ✅ Interfaces cho services
- ✅ **Chỉ phụ thuộc Domain Layer**

**Ví dụ:**

```csharp
// Application/Services/IUserService.cs
namespace PriceArbitrage.Application.Services;

public interface IUserService
{
    Task<RegisterResponse> RegisterAsync(RegisterRequest request);
}
```

### 3. Infrastructure Layer (Data & External Services)

**Nhiệm vụ:**

- ✅ Implement interfaces từ Application/Domain
- ✅ Data access (EF Core, Repositories)
- ✅ External services (Email, Scraping, AI)
- ✅ Database configuration
- ✅ **Phụ thuộc Application và Domain**

**Ví dụ:**

```csharp
// Infrastructure/Repositories/ProductRepository.cs
public class ProductRepository : IProductRepository
{
    // Implement interface từ Domain
}
```

### 4. Presentation Layer (API)

**Nhiệm vụ:**

- ✅ Controllers
- ✅ HTTP request/response
- ✅ API endpoints
- ✅ Authentication/Authorization
- ✅ **Phụ thuộc Application Layer**

**Ví dụ:**

```csharp
// API/Controllers/ProductsController.cs
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var products = await _productService.GetAllAsync();
        return Ok(products);
    }
}
```

---

## 🚀 Step-by-Step Setup

### STEP 1: Tạo Solution File

**Task:** Tạo solution file để quản lý nhiều projects

**Commands:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet new sln -n PriceArbitrage
```

**Kết quả:** `PriceArbitrage.sln` được tạo

**Checklist:**

- [ ] Solution file created

---

### STEP 2: Tạo Domain Project (Core Layer)

**Task:** Tạo project cho Domain layer (core, không phụ thuộc gì)

**Commands:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet new classlib -n PriceArbitrage.Domain -f net8.0
dotnet sln add PriceArbitrage.Domain/PriceArbitrage.Domain.csproj
```

**Folder Structure sẽ tạo:**

```
PriceArbitrage.Domain/
├── Entities/
├── ValueObjects/
├── Enums/
├── Interfaces/
└── PriceArbitrage.Domain.csproj
```

**Tạo folders:**

```bash
cd PriceArbitrage.Domain
mkdir Entities
mkdir ValueObjects
mkdir Enums
mkdir Interfaces
```

**Checklist:**

- [ ] Domain project created
- [ ] Folders created
- [ ] Project added to solution

---

### STEP 3: Tạo Application Project

**Task:** Tạo project cho Application layer (business logic)

**Commands:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet new classlib -n PriceArbitrage.Application -f net8.0
dotnet sln add PriceArbitrage.Application/PriceArbitrage.Application.csproj
```

**Setup Project Reference:**

```bash
cd PriceArbitrage.Application
dotnet add reference ../PriceArbitrage.Domain/PriceArbitrage.Domain.csproj
```

**Folder Structure:**

```bash
cd PriceArbitrage.Application
mkdir Services
mkdir DTOs
mkdir Mappings
mkdir Interfaces
```

**Checklist:**

- [ ] Application project created
- [ ] Reference to Domain added
- [ ] Folders created
- [ ] Project added to solution

---

### STEP 4: Tạo Infrastructure Project

**Task:** Tạo project cho Infrastructure layer (data access, external services)

**Commands:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet new classlib -n PriceArbitrage.Infrastructure -f net8.0
dotnet sln add PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj
```

**Setup Project References:**

```bash
cd PriceArbitrage.Infrastructure
dotnet add reference ../PriceArbitrage.Domain/PriceArbitrage.Domain.csproj
dotnet add reference ../PriceArbitrage.Application/PriceArbitrage.Application.csproj
```

**Install Packages (sẽ cần sau này):**

```bash
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
```

**Folder Structure:**

```bash
mkdir Data
mkdir Services
mkdir Repositories
mkdir External
mkdir Configuration
```

**Checklist:**

- [ ] Infrastructure project created
- [ ] References to Domain and Application added
- [ ] Basic packages installed
- [ ] Folders created
- [ ] Project added to solution

---

### STEP 5: Setup API Project (Rename existing backend)

**Task:** Rename và tổ chức lại API project hiện tại

**Option 1: Giữ nguyên backend folder (đơn giản hơn)**

- Chuyển backend thành PriceArbitrage.API

**Option 2: Tạo mới (nếu muốn fresh start)**

**Commands:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
# Rename folder hoặc tạo mới
# Nếu giữ nguyên, chỉ cần rename project
```

**Update .csproj:**

- Rename `Genshin.API.csproj` → `PriceArbitrage.API.csproj`

**Setup Project References:**

```bash
cd backend  # hoặc PriceArbitrage.API
dotnet add reference ../PriceArbitrage.Application/PriceArbitrage.Application.csproj
dotnet add reference ../PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj
```

**Update Namespace:**

- Đổi namespace từ `Genshin.API` → `PriceArbitrage.API`

**Folder Structure:**

```
PriceArbitrage.API/
├── Controllers/
├── Middleware/
├── Extensions/
├── Program.cs
└── PriceArbitrage.API.csproj
```

**Checklist:**

- [ ] API project configured
- [ ] References to Application and Infrastructure added
- [ ] Namespace updated
- [ ] Project added to solution

---

### STEP 6: Tạo Test Project (Optional)

**Task:** Tạo project cho tests

**Commands:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet new xunit -n PriceArbitrage.Tests -f net8.0
dotnet sln add PriceArbitrage.Tests/PriceArbitrage.Tests.csproj
```

**Setup Project References:**

```bash
cd PriceArbitrage.Tests
dotnet add reference ../PriceArbitrage.Domain/PriceArbitrage.Domain.csproj
dotnet add reference ../PriceArbitrage.Application/PriceArbitrage.Application.csproj
dotnet add reference ../PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj
```

**Install Test Packages:**

```bash
dotnet add package Moq
dotnet add package FluentAssertions
dotnet add package Microsoft.AspNetCore.Mvc.Testing
```

**Checklist:**

- [ ] Test project created
- [ ] References added
- [ ] Test packages installed
- [ ] Project added to solution

---

### STEP 7: Verify Solution Structure

**Commands:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet sln list
```

**Expected output:**

```
Project reference(s)
--------------------
PriceArbitrage.API
PriceArbitrage.Application
PriceArbitrage.Domain
PriceArbitrage.Infrastructure
PriceArbitrage.Tests
```

**Checklist:**

- [ ] All projects in solution
- [ ] References correct
- [ ] Solution builds successfully

---

### STEP 8: Build và Test

**Commands:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet build
```

**Expected:**

- ✅ Build succeeded
- ✅ No errors

**Checklist:**

- [ ] Solution builds successfully
- [ ] No errors

---

## 📐 Dependency Graph (Biểu đồ phụ thuộc)

```
API (Presentation)
  ↓ depends on
Application (Business Logic)
  ↓ depends on
Domain (Core)
  ↑
Infrastructure (Implementation)
  ↑ depends on
```

**Rules:**

- ✅ API → Application ✅
- ✅ API → Infrastructure ✅
- ✅ Application → Domain ✅
- ✅ Infrastructure → Domain ✅
- ✅ Infrastructure → Application ✅
- ❌ Domain → Không depend vào gì ❌
- ❌ Application → Infrastructure ❌

---

## 📝 Example Structure sau khi setup

### Domain Layer:

```
PriceArbitrage.Domain/
├── Entities/
│   ├── Product.cs
│   ├── ApplicationUser.cs
│   ├── ProductPrice.cs
│   └── Watchlist.cs
├── Interfaces/
│   ├── IProductRepository.cs
│   └── IUnitOfWork.cs
├── Enums/
│   └── Marketplace.cs
└── PriceArbitrage.Domain.csproj
```

### Application Layer:

```
PriceArbitrage.Application/
├── Services/
│   ├── IUserService.cs
│   ├── UserService.cs
│   ├── IProductService.cs
│   └── ProductService.cs
├── DTOs/
│   ├── Auth/
│   │   ├── RegisterRequest.cs
│   │   └── LoginRequest.cs
│   └── Product/
│       └── ProductDto.cs
└── PriceArbitrage.Application.csproj
```

### Infrastructure Layer:

```
PriceArbitrage.Infrastructure/
├── Data/
│   ├── ApplicationDbContext.cs
│   └── Configurations/
├── Repositories/
│   ├── ProductRepository.cs
│   └── BaseRepository.cs
├── Services/
│   ├── JwtService.cs
│   └── EmailService.cs
└── PriceArbitrage.Infrastructure.csproj
```

### API Layer:

```
PriceArbitrage.API/
├── Controllers/
│   ├── AuthController.cs
│   └── ProductsController.cs
├── Extensions/
│   └── ServiceExtensions.cs
├── Program.cs
└── PriceArbitrage.API.csproj
```

---

## ⚙️ Configure Dependency Injection

### Tạo Extension Methods (Best Practice)

**File:** `PriceArbitrage.API/Extensions/ServiceExtensions.cs`

```csharp
// Example structure (bạn sẽ implement sau)
namespace PriceArbitrage.API.Extensions;

public static class ServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Register Application services
        // services.AddScoped<IUserService, UserService>();
        return services;
    }

    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        // Register Infrastructure services
        // services.AddDbContext<ApplicationDbContext>(...);
        return services;
    }
}
```

**Update Program.cs:**

```csharp
using PriceArbitrage.API.Extensions;

// Add services
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);
```

---

## ✅ Final Checklist

### Solution Structure:

- [ ] Solution file created
- [ ] Domain project created và added
- [ ] Application project created và added
- [ ] Infrastructure project created và added
- [ ] API project configured và added
- [ ] Test project created và added (optional)

### Project References:

- [ ] Application references Domain
- [ ] Infrastructure references Domain và Application
- [ ] API references Application và Infrastructure
- [ ] Tests reference all projects (if created)

### Folders:

- [ ] Domain folders created (Entities, Interfaces, Enums)
- [ ] Application folders created (Services, DTOs)
- [ ] Infrastructure folders created (Data, Repositories, Services)
- [ ] API folders organized (Controllers, Extensions)

### Build:

- [ ] Solution builds successfully
- [ ] No errors
- [ ] All projects compile

### Next Steps:

- [ ] Ready for Database Design (STEP 2)
- [ ] Ready for Entity creation
- [ ] Ready for Identity setup

---

## 🎓 Learning Points

### Tại sao Clean Architecture?

1. **Separation of Concerns**

   - Mỗi layer có trách nhiệm riêng
   - Dễ hiểu và maintain

2. **Testability**

   - Test từng layer độc lập
   - Dễ mock dependencies

3. **Flexibility**

   - Thay đổi database → Chỉ sửa Infrastructure
   - Thay đổi UI → Chỉ sửa API layer
   - Business logic (Domain) không đổi

4. **Scalability**
   - Dễ thêm features mới
   - Dễ refactor
   - Dễ onboard team members

### Dependency Rules:

- ✅ **Inner layers** không biết về outer layers
- ✅ **Domain** = Core, không depend vào gì
- ✅ **Dependencies** flow inward (vào trong)
- ✅ **Use interfaces** để invert dependencies

---

## 🚀 Commands Summary

```bash
# Tạo solution
dotnet new sln -n PriceArbitrage

# Tạo projects
dotnet new classlib -n PriceArbitrage.Domain -f net8.0
dotnet new classlib -n PriceArbitrage.Application -f net8.0
dotnet new classlib -n PriceArbitrage.Infrastructure -f net8.0

# Add to solution
dotnet sln add PriceArbitrage.Domain/PriceArbitrage.Domain.csproj
dotnet sln add PriceArbitrage.Application/PriceArbitrage.Application.csproj
dotnet sln add PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj

# Add references
cd PriceArbitrage.Application
dotnet add reference ../PriceArbitrage.Domain/PriceArbitrage.Domain.csproj

cd ../PriceArbitrage.Infrastructure
dotnet add reference ../PriceArbitrage.Domain/PriceArbitrage.Domain.csproj
dotnet add reference ../PriceArbitrage.Application/PriceArbitrage.Application.csproj

# Build
cd ..
dotnet build
```

---

## 💡 Tips

1. **Start simple** - Bắt đầu với structure cơ bản, refine dần
2. **Follow dependencies** - Luôn check dependencies flow đúng
3. **Use interfaces** - Định nghĩa interfaces ở Domain/Application
4. **Test as you go** - Test mỗi layer khi implement
5. **Document** - Ghi chú tại sao đặt code ở đâu

---

## 🎯 Next Steps

Sau khi hoàn thành setup:

1. ✅ Verify structure
2. ✅ Build successfully
3. 📋 Move to next task: Database Design & EF Core

**Ready to code!** 🚀
