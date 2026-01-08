# 🔍 Cơ chế Swagger phát hiện và hiển thị API

Giải thích chi tiết cách Swagger tự động phát hiện và hiển thị các API endpoints.

---

## 🎯 Swagger là gì?

**Swagger** = Công cụ để tự động generate API documentation từ code của bạn.

### Cách hoạt động:

```
Your Code (Controllers)
    ↓
Swagger scans code (dùng Reflection)
    ↓
Generate OpenAPI specification (JSON)
    ↓
Swagger UI hiển thị documentation
```

---

## 📋 Quy trình từ Code đến Swagger UI

### Step 1: Bạn viết Controller

```csharp
// Controllers/WeatherForecastController.cs
namespace PriceArbitrage.API.Controllers;

[ApiController]              // ← Attribute đánh dấu đây là API Controller
[Route("api/[controller]")]  // ← Route template
public class WeatherForecastController : ControllerBase
{
    [HttpGet]                // ← HTTP Method
    public IEnumerable<WeatherForecast> Get()
    {
        // ...
    }
}
```

**Các thành phần quan trọng:**

- `[ApiController]` - Đánh dấu đây là API Controller
- `[Route("api/[controller]")]` - Định nghĩa route
- `[HttpGet]` - Định nghĩa HTTP method
- `ControllerBase` - Base class cho API controllers

---

### Step 2: Swagger được cấu hình trong Program.cs

```csharp
// Program.cs
builder.Services.AddEndpointsApiExplorer();  // ← Enable API exploration
builder.Services.AddSwaggerGen();            // ← Generate Swagger documentation

// ...

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();      // ← Serve Swagger JSON
    app.UseSwaggerUI();    // ← Serve Swagger UI
}
```

**Giải thích:**

- `AddEndpointsApiExplorer()` - Cho phép ASP.NET Core explore (tìm kiếm) các endpoints
- `AddSwaggerGen()` - Generate Swagger/OpenAPI specification từ metadata
- `UseSwagger()` - Serve file JSON (OpenAPI spec)
- `UseSwaggerUI()` - Serve UI interface để xem documentation

---

## 🔍 Cơ chế Reflection (Phản chiếu)

### ASP.NET Core dùng Reflection để:

1. **Tìm tất cả Controllers**

   ```csharp
   // ASP.NET Core tự động scan:
   - Tất cả classes kế thừa ControllerBase
   - Có [ApiController] attribute
   - Hoặc có "Controller" trong tên class
   ```

2. **Phát hiện Actions (Methods)**

   ```csharp
   // Tìm methods có:
   - [HttpGet], [HttpPost], [HttpPut], [HttpDelete], etc.
   - Hoặc method name bắt đầu bằng: Get, Post, Put, Delete
   - Return type: IActionResult, Task<IActionResult>, etc.
   ```

3. **Trích xuất Metadata**
   ```csharp
   // Thu thập thông tin:
   - Route template: "api/[controller]" → "api/weatherforecast"
   - HTTP method: [HttpGet] → GET
   - Parameters: method parameters
   - Return type: IEnumerable<WeatherForecast>
   - Response codes: 200 OK (default)
   ```

---

## 📊 Ví dụ cụ thể với WeatherForecastController

### Code của bạn:

```csharp
[ApiController]
[Route("api/[controller]")]
public class WeatherForecastController : ControllerBase
{
    [HttpGet]
    public IEnumerable<WeatherForecast> Get()
    {
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();
    }
}
```

### Swagger phân tích như sau:

#### 1. Phát hiện Controller:

```
✓ Class: WeatherForecastController
✓ Inherits: ControllerBase
✓ Has [ApiController] attribute
✓ Has [Route("api/[controller]")] attribute
→ Route base: "api/weatherforecast" (từ [controller] = WeatherForecast)
```

#### 2. Phát hiện Action:

```
✓ Method: Get()
✓ Has [HttpGet] attribute
✓ Route: "" (empty = use base route)
→ Final route: "api/weatherforecast" + "" = "api/weatherforecast"
→ HTTP Method: GET
```

#### 3. Phân tích Parameters:

```
✓ No parameters
→ No query params, no body, no route params
```

#### 4. Phân tích Return Type:

```
✓ Return type: IEnumerable<WeatherForecast>
→ Response type: array of WeatherForecast
→ Swagger sẽ inspect WeatherForecast record để biết schema
```

#### 5. Tự động inspect WeatherForecast:

```csharp
public record WeatherForecast
{
    public DateOnly Date { get; set; }
    public int TemperatureC { get; set; }
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
    public string? Summary { get; set; }
}
```

Swagger phân tích:

```
✓ Properties:
  - Date: DateOnly → string (date format)
  - TemperatureC: int → integer
  - TemperatureF: int (readonly) → integer
  - Summary: string? → string (nullable)
```

---

## 🔄 Quy trình chi tiết

### Phase 1: Application Startup

```
1. Program.cs chạy
2. builder.Services.AddSwaggerGen()
   → Register SwaggerGenerator service
   → Setup document metadata
3. app.UseSwagger()
   → Register middleware để serve /swagger/v1/swagger.json
4. app.UseSwaggerUI()
   → Register middleware để serve /swagger/index.html
```

### Phase 2: Request đến /swagger/index.html

```
1. User truy cập: http://localhost:5000/swagger
2. SwaggerUI middleware intercept request
3. Return HTML page với Swagger UI JavaScript
4. JavaScript load từ: /swagger/v1/swagger.json
```

### Phase 3: Request đến /swagger/v1/swagger.json

```
1. JavaScript request: GET /swagger/v1/swagger.json
2. Swagger middleware intercept
3. SwaggerGenerator được gọi:
   a. Scan tất cả controllers (dùng Reflection)
   b. Phát hiện actions và routes
   c. Generate OpenAPI JSON specification
4. Return JSON response
```

### Phase 4: Swagger UI Render

```
1. JavaScript nhận được JSON
2. Parse OpenAPI specification
3. Render UI:
   - List tất cả endpoints
   - Show request/response schemas
   - Generate "Try it out" forms
```

---

## 🎨 Các Attributes quan trọng

### 1. `[ApiController]`

```csharp
[ApiController]
public class WeatherForecastController : ControllerBase
```

**Tác dụng:**

- Đánh dấu đây là API Controller
- Enable API-specific behaviors:
  - Automatic model validation
  - 400 Bad Request nếu model invalid
  - Problem details cho errors
- Swagger sẽ include controller này trong documentation

### 2. `[Route]`

```csharp
[Route("api/[controller]")]
```

**Tác dụng:**

- Định nghĩa route template
- `[controller]` = tên controller (bỏ "Controller" suffix)
  - `WeatherForecastController` → `weatherforecast`
- Swagger sử dụng để generate endpoint path

### 3. HTTP Method Attributes

```csharp
[HttpGet]    // GET
[HttpPost]   // POST
[HttpPut]    // PUT
[HttpDelete] // DELETE
```

**Tác dụng:**

- Định nghĩa HTTP method
- Swagger sử dụng để biết method nào cho endpoint

### 4. `[ProducesResponseType]` (Optional)

```csharp
[HttpGet]
[ProducesResponseType(StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status400BadRequest)]
public IActionResult Get()
{
    // ...
}
```

**Tác dụng:**

- Document response types và status codes
- Swagger sẽ hiển thị tất cả possible responses

---

## 🔍 Cách Swagger tìm Controllers

### Convention-based Discovery:

Swagger tìm controllers theo các tiêu chí sau:

1. **Class name ends with "Controller"**

   ```
   ✓ WeatherForecastController
   ✓ ProductController
   ✗ ProductService (không có Controller suffix)
   ```

2. **Inherits from ControllerBase hoặc Controller**

   ```csharp
   ✓ public class XController : ControllerBase
   ✓ public class XController : Controller
   ✗ public class XController (không inherit)
   ```

3. **Has [ApiController] attribute**

   ```csharp
   ✓ [ApiController] public class XController
   ✗ public class XController (không có attribute)
   ```

4. **Not abstract, not generic**
   ```csharp
   ✓ public class XController
   ✗ public abstract class XController
   ✗ public class XController<T>
   ```

---

## 📝 OpenAPI Specification (swagger.json)

### Khi bạn truy cập `/swagger/v1/swagger.json`:

```json
{
  "openapi": "3.0.1",
  "info": {
    "title": "PriceArbitrage.API",
    "version": "1.0"
  },
  "paths": {
    "/api/WeatherForecast": {
      "get": {
        "tags": ["WeatherForecast"],
        "responses": {
          "200": {
            "description": "Success",
            "content": {
              "application/json": {
                "schema": {
                  "type": "array",
                  "items": {
                    "$ref": "#/components/schemas/WeatherForecast"
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "WeatherForecast": {
        "type": "object",
        "properties": {
          "date": { "type": "string", "format": "date" },
          "temperatureC": { "type": "integer" },
          "temperatureF": { "type": "integer" },
          "summary": { "type": "string", "nullable": true }
        }
      }
    }
  }
}
```

**Swagger UI đọc file này và render:**

- Endpoint: `GET /api/WeatherForecast`
- Response schema: Array of WeatherForecast
- Schema definition: WeatherForecast properties

---

## 🎯 Tại sao WeatherForecastController xuất hiện?

### Checklist Swagger phát hiện:

- [x] **Class name**: `WeatherForecastController` ✓ (ends with "Controller")
- [x] **Inheritance**: `: ControllerBase` ✓
- [x] **Attribute**: `[ApiController]` ✓
- [x] **Route**: `[Route("api/[controller]")]` ✓
- [x] **Action**: `[HttpGet] Get()` ✓
- [x] **Public method**: `public` ✓

**Kết quả**: ✅ Swagger include controller này!

---

## 🔧 Nếu API không xuất hiện?

### Các lý do phổ biến:

1. **Thiếu [ApiController]**

   ```csharp
   // ❌ Không xuất hiện
   public class WeatherForecastController : ControllerBase

   // ✅ Xuất hiện
   [ApiController]
   public class WeatherForecastController : ControllerBase
   ```

2. **Tên class không có "Controller"**

   ```csharp
   // ❌ Không xuất hiện
   [ApiController]
   public class WeatherService : ControllerBase

   // ✅ Xuất hiện
   [ApiController]
   public class WeatherController : ControllerBase
   ```

3. **Action không có HTTP attribute**

   ```csharp
   // ❌ Không xuất hiện
   public IEnumerable<WeatherForecast> Get() // Missing [HttpGet]

   // ✅ Xuất hiện
   [HttpGet]
   public IEnumerable<WeatherForecast> Get()
   ```

4. **Method private/protected**

   ```csharp
   // ❌ Không xuất hiện
   private IEnumerable<WeatherForecast> Get()

   // ✅ Xuất hiện
   public IEnumerable<WeatherForecast> Get()
   ```

---

## 💡 Best Practices

### 1. Luôn dùng [ApiController]

```csharp
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
```

### 2. Document Responses

```csharp
[HttpGet("{id}")]
[ProducesResponseType(StatusCodes.Status200OK)]
[ProducesResponseType(StatusCodes.Status404NotFound)]
public async Task<ActionResult<Product>> Get(int id)
{
    // ...
}
```

### 3. Add XML Comments (cho Swagger descriptions)

```csharp
/// <summary>
/// Gets weather forecast for the next 5 days
/// </summary>
/// <returns>List of weather forecasts</returns>
[HttpGet]
public IEnumerable<WeatherForecast> Get()
{
    // ...
}
```

### 4. Customize Swagger UI

```csharp
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Price Arbitrage API",
        Version = "v1",
        Description = "API for price arbitrage platform"
    });

    // Include XML comments
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    c.IncludeXmlComments(xmlPath);
});
```

---

## 📚 Tóm tắt

### Cơ chế hoạt động:

1. **Reflection**: ASP.NET Core dùng Reflection để scan controllers
2. **Conventions**: Dựa vào naming conventions và attributes
3. **Metadata**: Trích xuất metadata từ code
4. **OpenAPI**: Generate OpenAPI JSON specification
5. **UI**: Swagger UI render từ JSON specification

### Flow:

```
Your Code
    ↓ (Reflection)
Controller Discovery
    ↓ (Metadata Extraction)
OpenAPI Specification (JSON)
    ↓ (Swagger UI)
Documentation Displayed
```

### Điều kiện để API xuất hiện:

1. ✅ Class name ends with "Controller"
2. ✅ Inherits ControllerBase/Controller
3. ✅ Has [ApiController] (recommended)
4. ✅ Public methods với HTTP attributes
5. ✅ Swagger được enable trong Program.cs

---

**Bây giờ bạn đã hiểu cơ chế rồi!** 🎉
