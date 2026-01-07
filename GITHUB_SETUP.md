# Hướng dẫn Push Code lên GitHub

## Bước 1: Tạo Repository trên GitHub

1. Đăng nhập vào [GitHub](https://github.com)
2. Click nút **"+"** ở góc trên bên phải → chọn **"New repository"**
3. Điền thông tin:
   - **Repository name**: `Genshin` (hoặc tên bạn muốn)
   - **Description**: `Full-stack project with React and .NET Core`
   - Chọn **Public** hoặc **Private**
   - **KHÔNG** tích vào "Initialize this repository with a README" (vì đã có code rồi)
4. Click **"Create repository"**

## Bước 2: Kết nối Local Repository với GitHub

Sau khi tạo repo trên GitHub, bạn sẽ thấy URL của repository. Chạy các lệnh sau:

```bash
# Thêm remote origin (thay YOUR_USERNAME bằng username GitHub của bạn)
git remote add origin https://github.com/YOUR_USERNAME/Genshin.git

# Hoặc nếu dùng SSH:
# git remote add origin git@github.com:YOUR_USERNAME/Genshin.git

# Push code lên GitHub
git push -u origin main
```

## Nếu bạn đã có GitHub repository sẵn:

```bash
# Thay YOUR_USERNAME/Genshin bằng repo của bạn
git remote add origin https://github.com/YOUR_USERNAME/Genshin.git
git push -u origin main
```

## Lưu ý:

- Nếu GitHub yêu cầu authentication, bạn có thể:
  - Sử dụng **Personal Access Token** thay vì password
  - Hoặc cấu hình **SSH keys** cho GitHub

## Sau khi push thành công:

Bạn có thể xem code tại: `https://github.com/YOUR_USERNAME/Genshin`
