# 🚀 Setup Commands - Clean Architecture từ cấu trúc hiện tại

Plan triển khai Clean Architecture dựa trên cấu trúc hiện tại: `backend/` và `frontend/` đã có sẵn.

---

## 📋 Cấu trúc hiện tại

```
Genshin/
├── backend/          ← API project hiện tại (sample code)
│   ├── Controllers/
│   ├── Program.cs
│   └── Genshin.API.csproj
└── frontend/         ← React project hiện tại (sample code)
    ├── src/
    └── package.json
```

---

## 🎯 Mục tiêu: Tổ chức lại thành Clean Architecture

### Cấu trúc mục tiêu:

```
Genshin/
├── backend/
│   ├── PriceArbitrage.sln              ← Solution file
│   ├── PriceArbitrage.API/             ← API project (giữ nguyên backend, tổ chức lại)
│   │   ├── Controllers/
│   │   ├── Program.cs
│   │   └── PriceArbitrage.API.csproj
│   ├── PriceArbitrage.Application/     ← NEW: Business logic
│   ├── PriceArbitrage.Domain/          ← NEW: Entities, Interfaces
│   ├── PriceArbitrage.Infrastructure/  ← NEW: Data access, Services
│   └── PriceArbitrage.Tests/           ← NEW: Tests (optional)
└── frontend/                            ← Giữ nguyên
    └── src/
```

---

## 📋 Prerequisites

```bash
# Verify .NET SDK installed
cd /home/anhlt/Workspace/Genshin
dotnet --version
# Should show: 8.0.x or higher
```

---

## 🚀 STEP 1: Tạo Solution File

**Mục tiêu**: Tạo solution file để quản lý nhiều projects

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet new sln -n PriceArbitrage
```

**Verify:**

```bash
ls -la *.sln
# Should see: PriceArbitrage.sln
```

**Checklist:**

- [ ] Solution file created

---

## 🚀 STEP 2: Tổ chức lại Backend Project

**Mục tiêu**: Tổ chức lại backend hiện tại thành PriceArbitrage.API

### Option A: Giữ nguyên structure, chỉ rename (Recommended)

```bash
cd /home/anhlt/Workspace/Genshin/backend

# Tạo solution (nếu chưa có)
dotnet new sln -n PriceArbitrage

# Add existing project to solution
dotnet sln add Genshin.API.csproj

# Tạo folders để tổ chức code
mkdir -p Controllers/Auth Controllers/Products
mkdir -p Extensions Middleware
```

**Checklist:**

- [ ] Solution file created
- [ ] Existing project added to solution
- [ ] Folders organized

### Option B: Rename project (Nếu muốn đồng nhất tên)

```bash
# Rename .csproj file
mv Genshin.API.csproj PriceArbitrage.API.csproj

# Update namespace trong các files
# (Có thể làm sau, không bắt buộc ngay)
```

**Note**: Giữ nguyên tên `Genshin.API` cũng được, không ảnh hưởng.

---

## 🚀 STEP 3: Tạo Domain Project

**Mục tiêu**: Tạo core layer cho entities và interfaces

```bash
cd /home/anhlt/Workspace/Genshin/backend

# Tạo project
dotnet new classlib -n PriceArbitrage.Domain -f net8.0

# Add to solution
dotnet sln add PriceArbitrage.Domain/PriceArbitrage.Domain.csproj

# Tạo folder structure
cd PriceArbitrage.Domain
mkdir -p Entities ValueObjects Enums Interfaces
cd ..
```

**Verify:**

```bash
ls PriceArbitrage.Domain/
# Should see: Entities, ValueObjects, Enums, Interfaces folders
```

**Checklist:**

- [ ] Domain project created
- [ ] Folders created
- [ ] Added to solution

---

## 🚀 STEP 4: Tạo Application Project

**Mục tiêu**: Tạo layer cho business logic và DTOs

```bash
cd /home/anhlt/Workspace/Genshin/backend

# Tạo project
dotnet new classlib -n PriceArbitrage.Application -f net8.0

# Add to solution
dotnet sln add PriceArbitrage.Application/PriceArbitrage.Application.csproj

# Add reference to Domain
cd PriceArbitrage.Application
dotnet add reference ../PriceArbitrage.Domain/PriceArbitrage.Domain.csproj

# Tạo folder structure
mkdir -p Services
mkdir -p DTOs/Auth DTOs/Product DTOs/Common
mkdir -p Mappings Interfaces
cd ..
```

**Verify:**

```bash
cat PriceArbitrage.Application/PriceArbitrage.Application.csproj
# Should see: ProjectReference to Domain
```

**Checklist:**

- [ ] Application project created
- [ ] Reference to Domain added
- [ ] Folders created
- [ ] Added to solution

---

## 🚀 STEP 5: Tạo Infrastructure Project

**Mục tiêu**: Tạo layer cho data access và external services

```bash
cd /home/anhlt/Workspace/Genshin/backend

# Tạo project
dotnet new classlib -n PriceArbitrage.Infrastructure -f net8.0

# Add to solution
dotnet sln add PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj

# Add references
cd PriceArbitrage.Infrastructure
dotnet add reference ../PriceArbitrage.Domain/PriceArbitrage.Domain.csproj
dotnet add reference ../PriceArbitrage.Application/PriceArbitrage.Application.csproj

# Install packages cần thiết
dotnet add package Microsoft.EntityFrameworkCore --version 8.0.0
dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.0
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 8.0.0

# Tạo folder structure
mkdir -p Data/Configurations
mkdir -p Services
mkdir -p Repositories
mkdir -p External/Scrapers
mkdir -p Configuration
cd ..
```

**Verify:**

```bash
cat PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj
# Should see: References và packages
```

**Checklist:**

- [ ] Infrastructure project created
- [ ] References added
- [ ] Packages installed
- [ ] Folders created
- [ ] Added to solution

---

## 🚀 STEP 6: Link API Project với các layers

**Mục tiêu**: Kết nối API project với Application và Infrastructure

```bash
cd /home/anhlt/Workspace/Genshin/backend

# Add references từ API project (đang ở trong backend folder)
# Note: Solution file ở backend/, projects mới cũng ở backend/
dotnet add Genshin.API.csproj reference PriceArbitrage.Application/PriceArbitrage.Application.csproj
dotnet add Genshin.API.csproj reference PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj

# Hoặc nếu bạn muốn vào folder backend (nếu có nested structure):
# cd backend  # (nếu backend/backend structure)
# dotnet add reference ../PriceArbitrage.Application/PriceArbitrage.Application.csproj
# dotnet add reference ../PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj

# Verify references
cat Genshin.API.csproj
# Should see: ProjectReference to Application và Infrastructure
```

**Checklist:**

- [ ] API project references Application
- [ ] API project references Infrastructure
- [ ] References verified

---

## 🚀 STEP 7: Tạo Test Project (Optional)

**Mục tiêu**: Setup project cho testing

```bash
cd /home/anhlt/Workspace/Genshin/backend

# Tạo project
dotnet new xunit -n PriceArbitrage.Tests -f net8.0

# Add to solution
dotnet sln add PriceArbitrage.Tests/PriceArbitrage.Tests.csproj

# Add references
cd PriceArbitrage.Tests
dotnet add reference ../PriceArbitrage.Domain/PriceArbitrage.Domain.csproj
dotnet add reference ../PriceArbitrage.Application/PriceArbitrage.Application.csproj
dotnet add reference ../PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj

# Install test packages
dotnet add package Moq --version 4.20.69
dotnet add package FluentAssertions --version 6.12.0
dotnet add package Microsoft.AspNetCore.Mvc.Testing --version 8.0.0
cd ..
```

**Checklist:**

- [ ] Test project created (optional)
- [ ] References added
- [ ] Packages installed

---

## 🚀 STEP 8: Verify và Build

**Mục tiêu**: Verify structure và build solution

```bash
cd /home/anhlt/Workspace/Genshin/backend

# List all projects in solution
dotnet sln list

# Expected output:
# Project reference(s)
# --------------------
# backend/Genshin.API.csproj (hoặc PriceArbitrage.API.csproj)
# PriceArbitrage.Application
# PriceArbitrage.Domain
# PriceArbitrage.Infrastructure
# PriceArbitrage.Tests (nếu tạo)

# Build solution
dotnet build

# Should see: Build succeeded
```

**Checklist:**

- [ ] All projects in solution
- [ ] Solution builds successfully
- [ ] No errors

---

## ✅ STEP 9: Verify Project References

**Mục tiêu**: Đảm bảo dependencies đúng theo Clean Architecture

### Check Domain (should have NO references):

```bash
cat PriceArbitrage.Domain/PriceArbitrage.Domain.csproj
# Should NOT have any ProjectReference
# ✅ Domain is independent
```

### Check Application (should reference Domain only):

```bash
cat PriceArbitrage.Application/PriceArbitrage.Application.csproj
# Should have: ProjectReference to Domain
# ✅ Application depends on Domain only
```

### Check Infrastructure (should reference Domain + Application):

```bash
cat PriceArbitrage.Infrastructure/PriceArbitrage.Infrastructure.csproj
# Should have:
# - ProjectReference to Domain
# - ProjectReference to Application
# ✅ Infrastructure depends on Domain và Application
```

### Check API (should reference Application + Infrastructure):

```bash
cat backend/Genshin.API.csproj
# Should have:
# - ProjectReference to Application
# - ProjectReference to Infrastructure
# ✅ API depends on Application và Infrastructure
```

---

## ✅ STEP 10: Final Verification

```bash
cd /home/anhlt/Workspace/Genshin/backend

# 1. Check solution structure
dotnet sln list

# 2. Build solution
dotnet build

# 3. Check each project compiles individually
dotnet build PriceArbitrage.Domain
dotnet build PriceArbitrage.Application
dotnet build PriceArbitrage.Infrastructure
dotnet build backend

# All should succeed!
```

**Checklist:**

- [ ] Solution builds successfully
- [ ] All projects compile
- [ ] No circular dependencies
- [ ] Dependencies flow correctly

---

## 📁 Cấu trúc sau khi setup

```
Genshin/
├── backend/
│   ├── PriceArbitrage.sln                    ← Solution file
│   ├── backend/                              ← API project (giữ nguyên)
│   │   ├── Controllers/
│   │   │   ├── WeatherForecastController.cs  ← Sample code (giữ lại)
│   │   │   └── AuthController.cs             ← Sẽ tạo sau
│   │   ├── Extensions/                       ← NEW
│   │   ├── Middleware/                       ← NEW
│   │   ├── Program.cs                        ← Giữ nguyên, sẽ update
│   │   └── Genshin.API.csproj                ← Giữ nguyên
│   │
│   ├── PriceArbitrage.Domain/                ← NEW
│   │   ├── Entities/                         ← Sẽ tạo entities ở đây
│   │   ├── ValueObjects/
│   │   ├── Enums/
│   │   ├── Interfaces/                       ← Repository interfaces
│   │   └── PriceArbitrage.Domain.csproj
│   │
│   ├── PriceArbitrage.Application/           ← NEW
│   │   ├── Services/                         ← Business logic
│   │   ├── DTOs/                             ← Request/Response models
│   │   ├── Mappings/                         ← AutoMapper configs
│   │   ├── Interfaces/                       ← Service interfaces
│   │   └── PriceArbitrage.Application.csproj
│   │
│   ├── PriceArbitrage.Infrastructure/        ← NEW
│   │   ├── Data/                             ← DbContext, EF Core
│   │   ├── Services/                         ← JWT, Email, etc.
│   │   ├── Repositories/                     ← Implement repositories
│   │   ├── External/                         ← Scrapers, AI services
│   │   └── PriceArbitrage.Infrastructure.csproj
│   │
│   └── PriceArbitrage.Tests/                 ← NEW (optional)
│       └── PriceArbitrage.Tests.csproj
│
└── frontend/                                  ← Giữ nguyên
    ├── src/
    ├── package.json
    └── ...
```

---

## 📝 Migration Plan: Di chuyển code hiện tại

### Phase 1: Giữ nguyên code sample

- ✅ Giữ `WeatherForecastController.cs` để reference
- ✅ Giữ `Program.cs` hiện tại
- ✅ Tất cả vẫn hoạt động bình thường

### Phase 2: Bắt đầu migrate (khi implement features mới)

- ✅ Tạo entities trong Domain layer
- ✅ Tạo services trong Application layer
- ✅ Implement repositories trong Infrastructure layer
- ✅ Tạo controllers trong API layer
- ✅ Di chuyển code từ sample sang Clean Architecture dần dần

### Phase 3: Cleanup (sau khi có code mới)

- ⏳ Xóa sample code khi không cần nữa
- ⏳ Refactor theo Clean Architecture patterns

---

## 🔄 Next Steps - Migration Strategy

### Bước tiếp theo sau khi setup:

1. **Verify Structure**

   - [ ] Solution builds successfully
   - [ ] All references correct
   - [ ] Ready for next phase

2. **Database Design** (Week 1, Day 3-4)

   - [ ] Design database schema
   - [ ] Create Entity models trong Domain layer
   - [ ] Setup EF Core trong Infrastructure layer

3. **Identity Setup** (Week 2)

   - [ ] Setup Identity trong Infrastructure
   - [ ] Create ApplicationUser trong Domain
   - [ ] Configure trong API project

4. **Gradual Migration**
   - [ ] Giữ sample code cho đến khi có code mới
   - [ ] Implement features mới theo Clean Architecture
   - [ ] Di chuyển code cũ dần dần

---

## 🐛 Troubleshooting

### Error: "Project not found"

```bash
# Check current directory
pwd
# Should be: /home/anhlt/Workspace/Genshin/backend

# Check project exists
ls -la *.csproj
ls -la PriceArbitrage.*/
```

### Error: "Circular dependency"

- ✅ Verify: Domain has NO references
- ✅ Verify: Application references Domain only
- ✅ Verify: Infrastructure references Domain + Application
- ✅ Verify: API references Application + Infrastructure

### Error: "Build failed"

```bash
# Restore packages first
dotnet restore

# Clean and rebuild
dotnet clean
dotnet build

# Check .NET version
dotnet --version
```

---

## 📝 Important Notes

### Giữ nguyên những gì có sẵn:

- ✅ `backend/` folder và structure
- ✅ `Genshin.API.csproj` (có thể giữ tên này)
- ✅ Sample code (`WeatherForecastController`) để reference
- ✅ `frontend/` folder (không thay đổi)

### Chỉ thêm mới:

- ✅ Solution file
- ✅ Domain, Application, Infrastructure projects
- ✅ Folders để organize code
- ✅ Project references

### Migration Strategy:

- 🎯 **Không** xóa code cũ ngay
- 🎯 Implement features mới theo Clean Architecture
- 🎯 Di chuyển code cũ dần dần khi refactor

---

## ✅ Final Checklist

### Setup Complete:

- [ ] Solution file created
- [ ] Domain project created
- [ ] Application project created
- [ ] Infrastructure project created
- [ ] API project linked với các layers
- [ ] All projects in solution
- [ ] Solution builds successfully
- [ ] References verified

### Ready for:

- [ ] Database Design (next step)
- [ ] Entity creation
- [ ] Identity setup

---

**Ready to start! Bắt đầu với Step 1!** 🚀
