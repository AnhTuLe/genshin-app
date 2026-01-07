# 🚀 Deployment Guide - Genshin Project

Hướng dẫn chi tiết các cách deploy dự án React + .NET Core.

## 📋 Mục lục

1. [Deploy với Docker (Recommended)](#1-deploy-với-docker-recommended)
2. [Deploy riêng biệt Frontend & Backend](#2-deploy-riêng-biệt-frontend--backend)
3. [Deploy lên Cloud Platforms](#3-deploy-lên-cloud-platforms)
4. [Deploy trên VPS/Server](#4-deploy-trên-vpsserver)
5. [Environment Variables](#5-environment-variables)
6. [SSL/HTTPS Configuration](#6-sslhttps-configuration)

---

## 1. Deploy với Docker (Recommended)

### Yêu cầu

- Docker và Docker Compose đã cài đặt

### Bước thực hiện

```bash
# Build và chạy với Docker Compose
docker-compose up -d --build

# Xem logs
docker-compose logs -f

# Dừng services
docker-compose down

# Dừng và xóa volumes
docker-compose down -v
```

### Services

- **Backend**: `http://localhost:5000` hoặc port bạn cấu hình
- **Frontend**: `http://localhost:3000`

### Kiểm tra

```bash
# Kiểm tra containers đang chạy
docker-compose ps

# Kiểm tra logs của từng service
docker-compose logs backend
docker-compose logs frontend
```

---

## 2. Deploy riêng biệt Frontend & Backend

### 2.1. Deploy Backend (.NET Core)

#### Trên Linux Server

```bash
# 1. Cài đặt .NET 8.0 Runtime
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 8.0 --runtime aspnetcore

# 2. Publish application
cd backend
dotnet publish -c Release -o ./publish

# 3. Chạy application (với systemd service)
sudo nano /etc/systemd/system/genshin-api.service
```

**File service (/etc/systemd/system/genshin-api.service):**

```ini
[Unit]
Description=Genshin API Service
After=network.target

[Service]
Type=notify
ExecStart=/usr/bin/dotnet /var/www/genshin-api/Genshin.API.dll
Restart=always
RestartSec=10
KestrelEndpoints=http://localhost:5000
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=http://localhost:5000

[Install]
WantedBy=multi-user.target
```

```bash
# 4. Enable và start service
sudo systemctl enable genshin-api
sudo systemctl start genshin-api
sudo systemctl status genshin-api
```

#### Sử dụng Nginx làm Reverse Proxy

```nginx
# /etc/nginx/sites-available/genshin-api
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/genshin-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 2.2. Deploy Frontend (React)

#### Build Production

```bash
cd frontend
npm install
npm run build
```

Output sẽ ở thư mục `frontend/dist/`

#### Với Nginx

```nginx
# /etc/nginx/sites-available/genshin-frontend
server {
    listen 80;
    server_name yourdomain.com;

    root /var/www/genshin-frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Copy build files
sudo cp -r frontend/dist/* /var/www/genshin-frontend/

# Enable site
sudo ln -s /etc/nginx/sites-available/genshin-frontend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 3. Deploy lên Cloud Platforms

### 3.1. Azure App Service

#### Backend (.NET Core)

```bash
# 1. Cài đặt Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# 2. Login
az login

# 3. Tạo Resource Group
az group create --name genshin-rg --location eastus

# 4. Tạo App Service Plan
az appservice plan create --name genshin-plan --resource-group genshin-rg --sku B1 --is-linux

# 5. Tạo Web App
az webapp create --resource-group genshin-rg --plan genshin-plan --name genshin-api --runtime "DOTNET|8.0"

# 6. Deploy code
cd backend
az webapp up --name genshin-api --resource-group genshin-rg
```

#### Frontend (React)

**Option 1: Azure Static Web Apps**

```bash
# Install Azure Static Web Apps CLI
npm install -g @azure/static-web-apps-cli

# Build frontend
cd frontend
npm run build

# Deploy
swa deploy ./dist --app-name genshin-frontend --resource-group genshin-rg
```

**Option 2: Azure App Service (Node.js)**

```bash
# Tạo Web App với Node.js runtime
az webapp create --resource-group genshin-rg --plan genshin-plan --name genshin-frontend --runtime "NODE|18-lts"

# Deploy
cd frontend
az webapp up --name genshin-frontend --resource-group genshin-rg
```

### 3.2. AWS

#### Backend - AWS Elastic Beanstalk

```bash
# 1. Install EB CLI
pip install awsebcli

# 2. Initialize EB
cd backend
eb init -p "64bit Amazon Linux 2 v2.5.8 running .NET Core" genshin-api

# 3. Create environment
eb create genshin-api-env

# 4. Deploy
eb deploy
```

#### Frontend - AWS Amplify hoặc S3 + CloudFront

**Với AWS Amplify:**

1. Kết nối GitHub repository
2. Amplify tự động detect React app
3. Build settings:
   ```yaml
   version: 1
   frontend:
     phases:
       preBuild:
         commands:
           - npm install
       build:
         commands:
           - npm run build
     artifacts:
       baseDirectory: dist
       files:
         - "**/*"
   ```

**Với S3 + CloudFront:**

```bash
# 1. Build frontend
cd frontend
npm run build

# 2. Sync to S3
aws s3 sync dist/ s3://your-bucket-name --delete

# 3. Configure CloudFront distribution
# (Thực hiện qua AWS Console)
```

### 3.3. Vercel (Frontend - Recommended cho React)

```bash
# 1. Install Vercel CLI
npm i -g vercel

# 2. Deploy
cd frontend
vercel

# Hoặc kết nối GitHub repo trực tiếp trên Vercel Dashboard
```

**Cấu hình `vercel.json`:**

```json
{
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://your-backend-api.com/api/:path*"
    }
  ]
}
```

### 3.4. Railway

**Backend:**

```bash
# 1. Install Railway CLI
npm i -g @railway/cli

# 2. Login
railway login

# 3. Initialize và deploy
cd backend
railway init
railway up
```

**Frontend:**

```bash
cd frontend
railway init
railway up
```

---

## 4. Deploy trên VPS/Server

### Yêu cầu

- Ubuntu 20.04+ hoặc Linux distribution tương tự
- SSH access với quyền sudo
- Domain name (optional nhưng recommended)

### Bước 1: Chuẩn bị Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Cài đặt Nginx
sudo apt install nginx -y

# Cài đặt .NET 8.0 Runtime (cho backend)
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x dotnet-install.sh
sudo ./dotnet-install.sh --channel 8.0 --runtime aspnetcore --install-dir /usr/share/dotnet

# Cài đặt Node.js 18+ (cho build frontend)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Cài đặt Docker (nếu dùng Docker)
sudo apt install docker.io docker-compose -y
sudo systemctl enable docker
sudo systemctl start docker
```

### Bước 2: Clone Repository

```bash
# Tạo user cho ứng dụng
sudo adduser --disabled-password --gecos "" genshin

# Clone repo
cd /home/genshin
git clone https://github.com/AnhTuLe/genshin-app.git
cd genshin-app
```

### Bước 3: Deploy Backend

```bash
cd backend

# Publish application
export PATH="$PATH:/usr/share/dotnet"
dotnet publish -c Release -o /var/www/genshin-api

# Tạo systemd service (xem phần 2.1)
# Hoặc dùng Docker (xem phần 1)
```

### Bước 4: Deploy Frontend

```bash
cd frontend

# Build
npm install
npm run build

# Copy files
sudo cp -r dist/* /var/www/genshin-frontend/
```

### Bước 5: Cấu hình Nginx

Xem phần 2.1 và 2.2 để cấu hình Nginx reverse proxy.

### Bước 6: Setup SSL với Let's Encrypt

```bash
# Cài đặt Certbot
sudo apt install certbot python3-certbot-nginx -y

# Lấy SSL certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal (đã tự động setup)
sudo certbot renew --dry-run
```

---

## 5. Environment Variables

### Backend (.NET Core)

Tạo file `appsettings.Production.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "YOUR_PRODUCTION_CONNECTION_STRING"
  },
  "JwtSettings": {
    "SecretKey": "YOUR_SECRET_KEY",
    "Issuer": "https://yourdomain.com",
    "Audience": "https://yourdomain.com"
  },
  "CorsOrigins": ["https://yourdomain.com", "https://www.yourdomain.com"]
}
```

**Hoặc dùng Environment Variables:**

```bash
export ASPNETCORE_ENVIRONMENT=Production
export ConnectionStrings__DefaultConnection="YOUR_CONNECTION_STRING"
```

### Frontend (React)

Tạo file `.env.production`:

```env
VITE_API_BASE_URL=https://api.yourdomain.com
VITE_APP_NAME=Genshin App
```

**Sử dụng trong code:**

```typescript
const API_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:5000";
```

**Lưu ý:** Với Vite, biến môi trường phải có prefix `VITE_` để được expose.

---

## 6. SSL/HTTPS Configuration

### Với Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # ... rest of config
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

### Với .NET Core (Kestrel)

Trong `Program.cs`, cấu hình HTTPS:

```csharp
builder.WebHost.ConfigureKestrel(options =>
{
    options.Listen(IPAddress.Any, 5000);
    options.Listen(IPAddress.Any, 5001, listenOptions =>
    {
        listenOptions.UseHttps("/path/to/certificate.pfx", "password");
    });
});
```

---

## 7. Monitoring & Logging

### Application Insights (Azure)

```bash
# Thêm package
cd backend
dotnet add package Microsoft.ApplicationInsights.AspNetCore

# Cấu hình trong Program.cs
builder.Services.AddApplicationInsightsTelemetry();
```

### Health Checks

```csharp
// Program.cs
builder.Services.AddHealthChecks();
app.MapHealthChecks("/health");
```

---

## 8. CI/CD Pipeline

### GitHub Actions Example

Tạo file `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: "8.0.x"
      - name: Restore dependencies
        run: dotnet restore backend
      - name: Build
        run: dotnet build backend --no-restore
      - name: Publish
        run: dotnet publish backend -c Release -o ./publish
      - name: Deploy to server
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          source: "./publish"
          target: "/var/www/genshin-api"

  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
      - name: Install dependencies
        run: npm install --prefix frontend
      - name: Build
        run: npm run build --prefix frontend
      - name: Deploy
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          source: "./frontend/dist"
          target: "/var/www/genshin-frontend"
```

---

## 9. Checklist trước khi Deploy

- [ ] Đã test kỹ trên môi trường development
- [ ] Đã cấu hình environment variables cho production
- [ ] Đã setup database (nếu có)
- [ ] Đã cấu hình CORS đúng với domain production
- [ ] Đã setup SSL/HTTPS
- [ ] Đã cấu hình logging và monitoring
- [ ] Đã backup database (nếu có)
- [ ] Đã test health checks
- [ ] Đã cấu hình firewall rules
- [ ] Đã setup auto-scaling (nếu cần)
- [ ] Đã cấu hình CDN cho static files (nếu cần)

---

## 10. Troubleshooting

### Backend không chạy

```bash
# Kiểm tra logs
sudo journalctl -u genshin-api -f

# Kiểm tra port
sudo netstat -tlnp | grep 5000

# Kiểm tra permissions
sudo chown -R www-data:www-data /var/www/genshin-api
```

### Frontend không load được API

- Kiểm tra CORS configuration trong backend
- Kiểm tra API base URL trong frontend env
- Kiểm tra Nginx reverse proxy configuration

### SSL Certificate issues

```bash
# Kiểm tra certificate
sudo certbot certificates

# Renew manually
sudo certbot renew
```

---

## 📚 Tài liệu tham khảo

- [.NET Core Deployment](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/)
- [React Deployment](https://react.dev/learn/start-a-new-react-project#production-builds)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
