# 🚀 Cách chạy Backend - Trước và Sau

Giải thích tại sao cách chạy backend thay đổi sau khi tổ chức lại cấu trúc.

---

## 🔄 Thay đổi cấu trúc

### Trước đây (Sau khi tổ chức lại):

```
backend/
├── Program.cs                    ← Ở root
├── PriceArbitrage.API.csproj     ← Ở root
├── Controllers/
├── Properties/
└── ...
```

### Bây giờ (Clean Architecture):

```
backend/
├── PriceArbitrage.API/           ← Project folder mới
│   ├── Program.cs                ← Đã move vào đây
│   ├── PriceArbitrage.API.csproj ← Đã move vào đây
│   ├── Controllers/
│   └── ...
├── PriceArbitrage.Application/
├── PriceArbitrage.Domain/
└── PriceArbitrage.Infrastructure/
```

---

## ❓ Tại sao cần thay đổi lệnh?

### 1. `dotnet run` hoạt động như thế nào?

`dotnet run` sẽ:

1. Tìm file `.csproj` trong thư mục hiện tại
2. Nếu không tìm thấy, tìm trong parent directories
3. Nếu vẫn không tìm thấy → Error

### Trước đây:

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet run
# ✅ Tìm thấy PriceArbitrage.API.csproj ở ngay trong folder hiện tại
```

### Bây giờ:

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet run
# ❌ Không tìm thấy .csproj ở đây
# File đã move vào PriceArbitrage.API/ folder

cd /home/anhlt/Workspace/Genshin/backend/PriceArbitrage.API
dotnet run
# ✅ Tìm thấy PriceArbitrage.API.csproj
```

---

## 🎯 Các cách chạy backend

### Cách 1: CD vào folder project (Cách hiện tại)

```bash
cd /home/anhlt/Workspace/Genshin/backend/PriceArbitrage.API
dotnet run
```

**Hoặc một dòng:**

```bash
cd /home/anhlt/Workspace/Genshin/backend/PriceArbitrage.API && dotnet run
```

**Ưu điểm:**

- ✅ Đơn giản, rõ ràng
- ✅ Đúng folder của project

**Nhược điểm:**

- ❌ Phải nhớ path dài

---

### Cách 2: Dùng `--project` flag (Recommended!)

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet run --project PriceArbitrage.API/PriceArbitrage.API.csproj
```

**Hoặc:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet run --project PriceArbitrage.API
```

**Ưu điểm:**

- ✅ Có thể chạy từ bất kỳ đâu (miễn là trong backend/)
- ✅ Rõ ràng project nào đang chạy
- ✅ Không cần cd vào subfolder

**Nhược điểm:**

- ❌ Lệnh hơi dài

---

### Cách 3: Dùng Solution file

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet run --project PriceArbitrage.API
```

**Hoặc build solution trước:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet build PriceArbitrage.sln
dotnet run --project PriceArbitrage.API
```

---

### Cách 4: Tạo script để đơn giản hóa

**Tạo file `run-backend.sh` trong backend/:**

```bash
#!/bin/bash
cd "$(dirname "$0")/PriceArbitrage.API"
dotnet run
```

**Sử dụng:**

```bash
cd /home/anhlt/Workspace/Genshin/backend
./run-backend.sh
```

---

## 🔧 Vấn đề về `~/.dotnet/dotnet`

### Tại sao cần `~/.dotnet/dotnet`?

Vì `dotnet` chưa được thêm vào PATH của hệ thống.

### Giải pháp: Thêm vào PATH (Permanent)

**Option 1: Thêm vào ~/.bashrc**

```bash
# Add vào cuối file ~/.bashrc
export PATH="$HOME/.dotnet:$PATH"
```

**Sau đó:**

```bash
source ~/.bashrc
```

**Kiểm tra:**

```bash
which dotnet
# Should show: /home/anhlt/.dotnet/dotnet
```

**Bây giờ bạn có thể dùng:**

```bash
cd /home/anhlt/Workspace/Genshin/backend/PriceArbitrage.API
dotnet run  # ← Không cần ~/.dotnet/dotnet nữa
```

---

## 📋 So sánh các cách

| Cách                  | Lệnh                                      | Ưu điểm           | Nhược điểm    |
| --------------------- | ----------------------------------------- | ----------------- | ------------- |
| **1. CD vào folder**  | `cd PriceArbitrage.API && dotnet run`     | Đơn giản          | Phải nhớ path |
| **2. --project flag** | `dotnet run --project PriceArbitrage.API` | Rõ ràng, flexible | Lệnh dài      |
| **3. Script**         | `./run-backend.sh`                        | Rất đơn giản      | Cần tạo file  |
| **4. Alias**          | `run-api`                                 | Đơn giản nhất     | Cần setup     |

---

## 🎯 Recommended Setup

### Step 1: Thêm dotnet vào PATH

```bash
# Add vào ~/.bashrc
echo 'export PATH="$HOME/.dotnet:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
which dotnet
```

### Step 2: Tạo alias (Optional)

```bash
# Add vào ~/.bashrc
echo 'alias run-api="cd /home/anhlt/Workspace/Genshin/backend && dotnet run --project PriceArbitrage.API"' >> ~/.bashrc
source ~/.bashrc

# Sử dụng
run-api
```

### Step 3: Hoặc tạo script

```bash
# Tạo file run-api.sh
cat > /home/anhlt/Workspace/Genshin/backend/run-api.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
dotnet run --project PriceArbitrage.API
EOF

chmod +x /home/anhlt/Workspace/Genshin/backend/run-api.sh

# Sử dụng
cd /home/anhlt/Workspace/Genshin/backend
./run-api.sh
```

---

## 💡 Best Practice

### Nên dùng:

```bash
# Từ backend/ folder
dotnet run --project PriceArbitrage.API
```

**Lý do:**

- ✅ Rõ ràng project nào đang chạy
- ✅ Có thể chạy từ solution root
- ✅ Dễ tích hợp vào scripts/CI-CD

### Tránh:

```bash
# ❌ Phải cd vào subfolder mỗi lần
cd PriceArbitrage.API && dotnet run
```

---

## 🎯 Tóm tắt

### Trước đây:

- File `.csproj` ở root → `dotnet run` từ root

### Bây giờ:

- File `.csproj` trong `PriceArbitrage.API/` folder
- Cần chỉ định project: `dotnet run --project PriceArbitrage.API`

### Lý do:

- **Clean Architecture**: Mỗi project có folder riêng
- **Tổ chức tốt hơn**: Dễ quản lý nhiều projects
- **Nhất quán**: Giống các projects khác (Application, Domain, Infrastructure)

---

## ✅ Quick Reference

### Chạy từ backend/ folder:

```bash
cd /home/anhlt/Workspace/Genshin/backend
dotnet run --project PriceArbitrage.API
```

### Hoặc cd vào project folder:

```bash
cd /home/anhlt/Workspace/Genshin/backend/PriceArbitrage.API
dotnet run
```

### Setup PATH để dùng `dotnet` trực tiếp:

```bash
export PATH="$HOME/.dotnet:$PATH"
```

---

**Bây giờ bạn đã hiểu tại sao!** 🎉
