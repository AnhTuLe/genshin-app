# Genshin Project

Dự án full-stack với **ReactJS** (Frontend) và **.NET Core** (Backend).

## 🏗️ Kiến trúc

### Mô hình triển khai: **Tách biệt Frontend/Backend**

- **Frontend**: React với TypeScript, build thành static files
- **Backend**: .NET Core Web API, cung cấp RESTful API
- **Giao tiếp**: HTTP/HTTPS qua REST API
- **Triển khai**: Frontend và Backend có thể deploy độc lập

## 📁 Cấu trúc dự án

```
Genshin/
├── frontend/          # React Application
│   ├── src/
│   ├── public/
│   └── package.json
├── backend/           # .NET Core Web API
│   ├── Controllers/
│   ├── Models/
│   ├── Services/
│   └── Program.cs
└── README.md
```

## 🚀 Cài đặt và Chạy

### Backend (.NET Core)

```bash
cd backend
dotnet restore
dotnet run
```

Backend sẽ chạy tại: `http://localhost:5000` hoặc `https://localhost:5001`

### Frontend (React)

```bash
cd frontend
npm install
npm start
```

Frontend sẽ chạy tại: `http://localhost:3000`

## 📝 Ghi chú

- Cấu hình CORS trong backend để cho phép frontend gọi API
- Sử dụng JWT cho authentication nếu cần
- Environment variables cho các cấu hình khác nhau (dev, staging, production)

## 🔧 Tech Stack

**Frontend:**

- React 18+
- TypeScript
- Modern tooling (Vite hoặc Create React App)

**Backend:**

- .NET 8.0
- ASP.NET Core Web API
- Entity Framework Core (nếu dùng database)

## 📚 Xu hướng hiện tại (2024-2025)

1. **Tách biệt hoàn toàn Frontend/Backend**: Mỗi phần deploy độc lập
2. **TypeScript**: Sử dụng cho cả Frontend để type-safe
3. **RESTful API**: Chuẩn giao tiếp giữa Frontend và Backend
4. **Microservices**: (Cho dự án lớn) Tách Backend thành nhiều services nhỏ
5. **Containerization**: Docker cho dễ deploy và scale
6. **Cloud Deployment**: Azure, AWS, hoặc Google Cloud
