# 🚀 Quick Start Deployment Guide

Hướng dẫn nhanh để deploy dự án trong 5 phút.

## Option 1: Docker (Khuyến nghị - Dễ nhất)

```bash
# 1. Clone repository
git clone https://github.com/AnhTuLe/genshin-app.git
cd genshin-app

# 2. Chạy với Docker Compose
docker-compose up -d --build

# 3. Truy cập
# Frontend: http://localhost:3000
# Backend API: http://localhost:5000
# Swagger: http://localhost:5000/swagger
```

**Xong!** Dự án đã chạy.

---

## Option 2: Deploy Manual trên Server

### Bước 1: Chuẩn bị Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Cài .NET 8.0
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
sudo ./dotnet-install.sh --channel 8.0 --runtime aspnetcore --install-dir /usr/share/dotnet

# Cài Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Cài Nginx
sudo apt install nginx -y
```

### Bước 2: Clone và Build

```bash
# Clone repo
cd /var/www
sudo git clone https://github.com/AnhTuLe/genshin-app.git
cd genshin-app

# Build Backend
cd backend
export PATH="$PATH:/usr/share/dotnet"
dotnet publish -c Release -o /var/www/genshin-api

# Build Frontend
cd ../frontend
npm install
npm run build
sudo cp -r dist/* /var/www/genshin-frontend/
```

### Bước 3: Cấu hình Services

```bash
# Copy systemd service
sudo cp deployment/systemd/genshin-api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable genshin-api
sudo systemctl start genshin-api

# Copy Nginx configs
sudo cp deployment/nginx/backend.conf /etc/nginx/sites-available/genshin-api
sudo cp deployment/nginx/frontend.conf /etc/nginx/sites-available/genshin-frontend

# Sửa domain trong configs
sudo nano /etc/nginx/sites-available/genshin-api
sudo nano /etc/nginx/sites-available/genshin-frontend

# Enable sites
sudo ln -s /etc/nginx/sites-available/genshin-api /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/genshin-frontend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Bước 4: SSL với Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com
```

---

## Option 3: Deploy lên Cloud (Azure/AWS/Vercel)

### Azure (Backend + Frontend)

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Deploy Backend
cd backend
az webapp up --name genshin-api --resource-group genshin-rg --runtime "DOTNET|8.0"

# Deploy Frontend (Static Web App)
cd ../frontend
npm install -g @azure/static-web-apps-cli
npm run build
swa deploy ./dist --app-name genshin-frontend
```

### Vercel (Frontend - Dễ nhất cho React)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd frontend
vercel

# Hoặc connect GitHub repo trực tiếp trên vercel.com
```

### Railway (Cả Backend và Frontend)

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login và deploy
railway login
railway init
railway up
```

---

## Checklist nhanh

- [ ] Server/VPS đã sẵn sàng hoặc đã tạo Cloud account
- [ ] Domain đã trỏ về server IP (nếu có)
- [ ] Đã clone repository
- [ ] Đã build cả Backend và Frontend
- [ ] Đã cấu hình environment variables
- [ ] Đã setup SSL (Let's Encrypt)
- [ ] Đã test kết nối Frontend → Backend

---

## Troubleshooting nhanh

**Backend không chạy?**
```bash
sudo systemctl status genshin-api
sudo journalctl -u genshin-api -f
```

**Frontend không load API?**
- Kiểm tra CORS trong backend
- Kiểm tra API URL trong frontend `.env`

**404 trên Frontend?**
- Đảm bảo Nginx config có `try_files $uri $uri/ /index.html;`

---

## Xem thêm

Xem file `DEPLOYMENT.md` để biết hướng dẫn chi tiết hơn.

