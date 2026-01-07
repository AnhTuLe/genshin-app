# Frontend - React + TypeScript + Vite

## Cài đặt

### Yêu cầu
- Node.js 18+ và npm/yarn/pnpm

### Chạy dự án

```bash
# Cài đặt dependencies
npm install

# Chạy development server
npm run dev

# Build cho production
npm run build

# Preview production build
npm run preview
```

## Cấu hình

- **Port**: Mặc định chạy tại `http://localhost:3000`
- **API Proxy**: Đã cấu hình proxy để gọi API backend tại `http://localhost:5000`
- **Framework**: Vite (build tool hiện đại, nhanh hơn Create React App)

## Cấu trúc

```
frontend/
├── src/
│   ├── App.tsx          # Component chính
│   ├── App.css          # Styles cho App
│   ├── main.tsx         # Entry point
│   └── index.css        # Global styles
├── public/              # Static files
├── index.html           # HTML template
├── vite.config.ts       # Vite configuration
└── package.json         # Dependencies
```

