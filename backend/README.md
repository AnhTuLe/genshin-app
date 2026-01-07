# Backend - .NET Core Web API

## Cài đặt

### Yêu cầu
- .NET 8.0 SDK hoặc mới hơn

### Chạy dự án

```bash
# Restore packages
dotnet restore

# Chạy ứng dụng
dotnet run

# Hoặc với watch mode (tự động reload khi có thay đổi)
dotnet watch run
```

## API Endpoints

- Swagger UI: `http://localhost:5000/swagger` hoặc `https://localhost:5001/swagger`
- API Base URL: `http://localhost:5000/api` hoặc `https://localhost:5001/api`

## Cấu hình CORS

Backend đã được cấu hình để cho phép frontend React gọi API từ:
- `http://localhost:3000` (Create React App)
- `http://localhost:5173` (Vite)

Bạn có thể điều chỉnh trong `Program.cs` nếu cần.

