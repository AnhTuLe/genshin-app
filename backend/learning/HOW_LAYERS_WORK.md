# 🔄 Cách các Layers trong Clean Architecture hoạt động

Tài liệu này giải thích chi tiết cách các Layers tương tác với nhau khi bạn chỉ chạy project **Presentation Layer (API)**.

---

## 🎯 Câu hỏi chính

**"Nếu tôi chỉ run duy nhất project Presentation Layer (API) thì tầng này sẽ hoạt động như thế nào với Application Layer, Domain Layer (Core), Infrastructure Layer?"**

**Trả lời ngắn gọn:** Khi bạn chạy API project, .NET sẽ **tự động load tất cả các project dependencies** thông qua **Project References**. Tất cả các layers sẽ được compile và chạy cùng nhau như một ứng dụng duy nhất.

---

## 📦 1. Project References - Cách .NET kết nối các Layers

### 1.1. Cấu trúc Project References trong dự án của bạn

Khi xem file `.csproj` của API project:

```14:17:backend/PriceArbitrage.API/PriceArbitrage.API.csproj
  <ItemGroup>
    <ProjectReference Include="..\PriceArbitrage.Application\PriceArbitrage.Application.csproj" />
    <ProjectReference Include="..\PriceArbitrage.Infrastructure\PriceArbitrage.Infrastructure.csproj" />
  </ItemGroup>
```

**Điều này có nghĩa:**

- API project **phụ thuộc** vào Application và Infrastructure
- Khi build/run API project, .NET sẽ **tự động build** Application và Infrastructure trước
- Application project lại phụ thuộc vào Domain
- Infrastructure project phụ thuộc vào Domain và Application

### 1.2. Dependency Chain (Chuỗi phụ thuộc)

```
API (Presentation Layer)
  ↓ references
Application Layer
  ↓ references
Domain Layer (Core)
  ↑
Infrastructure Layer
  ↑ references
```

**Khi bạn chạy:**

```bash
dotnet run --project PriceArbitrage.API
```

**.NET sẽ tự động:**

1. ✅ Build Domain project (vì Application và Infrastructure cần nó)
2. ✅ Build Application project (vì API cần nó)
3. ✅ Build Infrastructure project (vì API cần nó)
4. ✅ Build API project
5. ✅ Chạy API project với tất cả dependencies đã được load

**Kết quả:** Tất cả các layers được compile thành **một executable duy nhất** hoặc **một tập hợp DLLs** chạy cùng nhau.

---

## 🔌 2. Dependency Injection - Cách các Layers giao tiếp

### 2.1. Dependency Injection Container

Khi API project khởi động, nó tạo một **Dependency Injection (DI) Container** trong `Program.cs`:

```1:10:backend/PriceArbitrage.API/Program.cs
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
```

**DI Container này:**

- Quản lý tất cả các services từ tất cả các layers
- Tự động inject dependencies khi cần
- Đảm bảo các layers có thể giao tiếp với nhau

### 2.2. Cách đăng ký Services từ các Layers

**Ví dụ cấu trúc (theo best practice):**

```csharp
// PriceArbitrage.API/Extensions/ServiceExtensions.cs
namespace PriceArbitrage.API.Extensions;

public static class ServiceExtensions
{
    // Đăng ký services từ Application Layer
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Đăng ký Application services
        services.AddScoped<IProductService, ProductService>();
        services.AddScoped<IUserService, UserService>();
        return services;
    }

    // Đăng ký services từ Infrastructure Layer
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Đăng ký Database Context
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));

        // Đăng ký Repositories (implementations từ Infrastructure)
        services.AddScoped<IProductRepository, ProductRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        // Đăng ký External Services
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IScrapingService, ScrapingService>();

        return services;
    }
}
```

**Trong Program.cs:**

```csharp
using PriceArbitrage.API.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Đăng ký services từ các layers
builder.Services.AddApplicationServices();        // ← Application Layer
builder.Services.AddInfrastructureServices(builder.Configuration);  // ← Infrastructure Layer

builder.Services.AddControllers();
// ... other services
```

---

## 🔄 3. Luồng hoạt động khi một Request đến API

### 3.1. Ví dụ: GET /api/products

**Bước 1: Request đến API Controller**

```csharp
// PriceArbitrage.API/Controllers/ProductsController.cs
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;  // ← Interface từ Application Layer

    // Constructor Injection - DI Container tự động inject
    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var products = await _productService.GetAllAsync();  // ← Gọi Application Layer
        return Ok(products);
    }
}
```

**Bước 2: Application Layer xử lý Business Logic**

```csharp
// PriceArbitrage.Application/Services/ProductService.cs
namespace PriceArbitrage.Application.Services;

public class ProductService : IProductService
{
    private readonly IProductRepository _productRepository;  // ← Interface từ Domain Layer

    // Constructor Injection
    public ProductService(IProductRepository productRepository)
    {
        _productRepository = productRepository;
    }

    public async Task<List<ProductDto>> GetAllAsync()
    {
        // 1. Lấy entities từ Repository (Infrastructure sẽ implement)
        var products = await _productRepository.GetAllAsync();  // ← Gọi Infrastructure Layer

        // 2. Map Entity → DTO (Business Logic)
        var productDtos = products.Select(p => new ProductDto
        {
            Id = p.Id,
            Name = p.Name,
            SKU = p.SKU,
            // ... mapping logic
        }).ToList();

        return productDtos;
    }
}
```

**Bước 3: Infrastructure Layer truy cập Database**

```csharp
// PriceArbitrage.Infrastructure/Repositories/ProductRepository.cs
namespace PriceArbitrage.Infrastructure.Repositories;

public class ProductRepository : IProductRepository  // ← Implement interface từ Domain
{
    private readonly ApplicationDbContext _context;  // ← EF Core DbContext

    public ProductRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Product>> GetAllAsync()
    {
        // Truy cập database thông qua EF Core
        return await _context.Products
            .AsNoTracking()
            .ToListAsync();
    }
}
```

**Bước 4: Domain Layer - Entities được sử dụng**

```csharp
// PriceArbitrage.Domain/Entities/Product.cs
namespace PriceArbitrage.Domain.Entities;

public class Product  // ← Core Entity, không phụ thuộc gì
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string SKU { get; set; } = string.Empty;
    // ... other properties
}
```

### 3.2. Sơ đồ luồng hoạt động

```
HTTP Request: GET /api/products
    ↓
┌─────────────────────────────────────┐
│ 1. API Layer (Controller)           │
│    ProductsController.GetAll()      │
│    ↓ inject IProductService         │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ 2. Application Layer                │
│    ProductService.GetAllAsync()     │
│    ↓ inject IProductRepository     │
│    ↓ Business Logic & Mapping      │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ 3. Infrastructure Layer             │
│    ProductRepository.GetAllAsync()  │
│    ↓ inject ApplicationDbContext    │
│    ↓ Database Query (EF Core)      │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ 4. Domain Layer (Entities)          │
│    Product entity được trả về      │
│    (Pure C# class, no dependencies) │
└─────────────────────────────────────┘
    ↓
Response: List<ProductDto> → JSON
```

---

## 🎯 4. Tại sao chỉ cần chạy API project?

### 4.1. .NET Project References

Khi API project có **Project References** đến Application và Infrastructure:

```xml
<ProjectReference Include="..\PriceArbitrage.Application\PriceArbitrage.Application.csproj" />
<ProjectReference Include="..\PriceArbitrage.Infrastructure\PriceArbitrage.Infrastructure.csproj" />
```

**.NET sẽ:**

- ✅ **Tự động compile** tất cả các projects được reference
- ✅ **Link tất cả DLLs** lại với nhau
- ✅ **Load tất cả assemblies** vào memory khi runtime
- ✅ **Resolve dependencies** tự động

### 4.2. Build Output

Khi bạn build API project:

```bash
dotnet build PriceArbitrage.API
```

**Output sẽ chứa:**

```
bin/Debug/net8.0/
├── PriceArbitrage.API.dll          ← API project
├── PriceArbitrage.API.exe          ← Entry point
├── PriceArbitrage.Application.dll  ← Application layer
├── PriceArbitrage.Domain.dll       ← Domain layer
├── PriceArbitrage.Infrastructure.dll ← Infrastructure layer
└── ... (other dependencies)
```

**Khi chạy `PriceArbitrage.API.exe`:**

- Tất cả các DLLs được load vào memory
- Tất cả các layers hoạt động cùng nhau
- DI Container kết nối tất cả các services

### 4.3. Runtime Execution

```
┌─────────────────────────────────────────────┐
│  dotnet run --project PriceArbitrage.API   │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  1. .NET Runtime khởi động                  │
│  2. Load PriceArbitrage.API.dll             │
│  3. Load PriceArbitrage.Application.dll     │
│  4. Load PriceArbitrage.Domain.dll          │
│  5. Load PriceArbitrage.Infrastructure.dll  │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  Program.cs được execute                    │
│  - Tạo DI Container                         │
│  - Đăng ký services từ tất cả layers       │
│  - Khởi động Web Server (Kestrel)           │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  API Server chạy                            │
│  - Tất cả layers sẵn sàng                   │
│  - Controllers có thể inject services       │
│  - Services có thể inject repositories      │
│  - Repositories có thể truy cập database    │
└─────────────────────────────────────────────┘
```

---

## 🔍 5. Chi tiết cách mỗi Layer hoạt động

### 5.1. Domain Layer (Core) - Không phụ thuộc gì

**Đặc điểm:**

- ✅ **Pure C# classes** - Không có dependencies
- ✅ **Entities, Interfaces, Value Objects, Enums**
- ✅ **Business Rules** - Logic nghiệp vụ cốt lõi
- ❌ **KHÔNG** có project references đến layers khác

**Ví dụ:**

```csharp
// PriceArbitrage.Domain/Entities/Product.cs
public class Product
{
    public Guid Id { get; set; }
    public string Name { get; set; }

    // Business logic
    public bool IsValid()
    {
        return !string.IsNullOrEmpty(Name);
    }
}

// PriceArbitrage.Domain/Interfaces/IProductRepository.cs
public interface IProductRepository
{
    Task<List<Product>> GetAllAsync();
    Task<Product?> GetByIdAsync(Guid id);
}
```

**Khi runtime:**

- Domain classes được load vào memory
- Các interfaces được sử dụng bởi Application và Infrastructure
- **Không có code nào trong Domain tự chạy** - nó chỉ là definitions

### 5.2. Application Layer - Business Logic

**Đặc điểm:**

- ✅ **Use Cases** - Các tác vụ nghiệp vụ
- ✅ **DTOs** - Data Transfer Objects
- ✅ **Services** - Business logic services
- ✅ **Chỉ phụ thuộc Domain** (references Domain project)

**Ví dụ:**

```csharp
// PriceArbitrage.Application/Services/IProductService.cs
public interface IProductService
{
    Task<List<ProductDto>> GetAllAsync();
}

// PriceArbitrage.Application/Services/ProductService.cs
public class ProductService : IProductService
{
    private readonly IProductRepository _repository;  // ← Interface từ Domain

    public ProductService(IProductRepository repository)
    {
        _repository = repository;
    }

    public async Task<List<ProductDto>> GetAllAsync()
    {
        var products = await _repository.GetAllAsync();  // ← Gọi Infrastructure
        return products.Select(p => MapToDto(p)).ToList();
    }
}
```

**Khi runtime:**

- Application services được đăng ký vào DI Container
- Được inject vào Controllers
- **Chạy khi được gọi từ API layer**

### 5.3. Infrastructure Layer - Implementations

**Đặc điểm:**

- ✅ **Implement interfaces** từ Domain/Application
- ✅ **Data Access** - EF Core, Repositories
- ✅ **External Services** - Email, Scraping, APIs
- ✅ **Phụ thuộc Domain và Application**

**Ví dụ:**

```csharp
// PriceArbitrage.Infrastructure/Repositories/ProductRepository.cs
public class ProductRepository : IProductRepository  // ← Implement Domain interface
{
    private readonly ApplicationDbContext _context;

    public ProductRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Product>> GetAllAsync()
    {
        return await _context.Products.ToListAsync();
    }
}
```

**Khi runtime:**

- Infrastructure implementations được đăng ký vào DI Container
- Được inject vào Application services
- **Chạy khi Application services gọi**

### 5.4. Presentation Layer (API) - Entry Point

**Đặc điểm:**

- ✅ **Controllers** - HTTP endpoints
- ✅ **Program.cs** - Entry point, DI configuration
- ✅ **Phụ thuộc Application và Infrastructure**

**Ví dụ:**

```csharp
// Program.cs - Entry point
var builder = WebApplication.CreateBuilder(args);

// Đăng ký services từ các layers
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);

var app = builder.Build();
app.MapControllers();
app.Run();  // ← Server chạy ở đây
```

**Khi runtime:**

- **Đây là nơi bắt đầu** - Program.cs được execute đầu tiên
- DI Container được tạo và đăng ký tất cả services
- Web Server (Kestrel) khởi động
- **Tất cả layers đã sẵn sàng hoạt động**

---

## 🎓 6. Tóm tắt - Cách các Layers hoạt động

### 6.1. Build Time (Khi compile)

```
dotnet build PriceArbitrage.API
    ↓
1. Build Domain (vì Application cần nó)
2. Build Application (vì API cần nó)
3. Build Infrastructure (vì API cần nó)
4. Build API
5. Link tất cả DLLs lại với nhau
```

### 6.2. Runtime (Khi chạy)

```
dotnet run --project PriceArbitrage.API
    ↓
1. Load tất cả DLLs vào memory
2. Execute Program.cs
3. Tạo DI Container
4. Đăng ký services từ tất cả layers
5. Khởi động Web Server
6. Sẵn sàng nhận requests
```

### 6.3. Request Flow (Khi có HTTP request)

```
HTTP Request
    ↓
API Controller (Presentation)
    ↓ inject
Application Service (Application)
    ↓ inject
Repository (Infrastructure)
    ↓ query
Database
    ↓ return
Domain Entity
    ↓ map
DTO
    ↓ return
JSON Response
```

---

## ✅ 7. Kết luận

### Câu trả lời cho câu hỏi của bạn:

**"Nếu tôi chỉ run duy nhất project Presentation Layer (API) thì tầng này sẽ hoạt động như thế nào?"**

1. ✅ **Tất cả layers được load tự động** - Nhờ Project References
2. ✅ **Tất cả layers hoạt động cùng nhau** - Trong cùng một process
3. ✅ **DI Container kết nối các layers** - Thông qua interfaces
4. ✅ **API là entry point** - Nhưng tất cả layers đều chạy
5. ✅ **Không cần chạy riêng từng layer** - .NET tự động quản lý

### Điểm quan trọng:

- **Project References** = Compile-time dependencies
- **Dependency Injection** = Runtime connections
- **Interfaces** = Contracts giữa các layers
- **Tất cả chạy trong một process** = Một ứng dụng duy nhất

---

## 🚀 8. Test thực tế

Bạn có thể verify bằng cách:

```bash
# 1. Build chỉ API project
dotnet build PriceArbitrage.API

# 2. Xem output - sẽ thấy tất cả DLLs
ls bin/Debug/net8.0/

# 3. Chạy API project
dotnet run --project PriceArbitrage.API

# 4. Tất cả layers đã được load và sẵn sàng!
```

---

**Tài liệu này giải thích cách Clean Architecture hoạt động trong thực tế khi bạn chỉ chạy API project!** 🎯
