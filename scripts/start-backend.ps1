# Script start backend (Docker + SQL Server + Backend API)
# Chay: .\scripts\start-backend.ps1

Write-Host "`n=== START BACKEND SERVICES ===`n" -ForegroundColor Cyan

# 1. Kiem tra Docker dang chay
Write-Host "1. Kiem tra Docker..." -ForegroundColor Yellow
try {
    docker ps > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Docker dang chay" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] Docker chua chay hoac chua cai dat" -ForegroundColor Red
        Write-Host "      Khoi dong Docker Desktop va thu lai" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "   [ERROR] Docker khong tim thay" -ForegroundColor Red
    exit 1
}

# 2. Dung cac containers cu neu co
Write-Host "`n2. Dung cac containers cu..." -ForegroundColor Yellow
docker-compose down 2>&1 | Out-Null
Write-Host "   [OK] Da dung cac containers cu" -ForegroundColor Green

# 3. Build va start services
Write-Host "`n3. Build va start services..." -ForegroundColor Yellow
Write-Host "   Dang build images (co the mat 2-5 phut lan dau)..." -ForegroundColor Gray

docker-compose up -d --build

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Services da duoc khoi dong!" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Co loi khi khoi dong services" -ForegroundColor Red
    Write-Host "      Xem logs: docker-compose logs" -ForegroundColor Yellow
    exit 1
}

# 4. Cho services khoi dong
Write-Host "`n4. Cho services khoi dong (30 giay)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# 5. Kiem tra trang thai
Write-Host "`n5. Kiem tra trang thai services..." -ForegroundColor Yellow
docker-compose ps

# 6. Kiem tra SQL Server
Write-Host "`n6. Kiem tra SQL Server..." -ForegroundColor Yellow
$sqlStatus = docker ps --filter "name=sqlserver" --format "{{.Status}}" 2>&1
if ($sqlStatus -match "Up") {
    Write-Host "   [OK] SQL Server dang chay" -ForegroundColor Green
} else {
    Write-Host "   [WARN] SQL Server chua san sang" -ForegroundColor Yellow
    Write-Host "      Xem logs: docker-compose logs sqlserver" -ForegroundColor Gray
}

# 7. Kiem tra Backend API
Write-Host "`n7. Kiem tra Backend API..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   [OK] Backend API dang chay!" -ForegroundColor Green
        Write-Host "      Health Check: http://localhost:5000/health" -ForegroundColor Gray
        Write-Host "      Swagger UI: http://localhost:5000/swagger" -ForegroundColor Gray
    }
} catch {
    Write-Host "   [WARN] Backend API chua san sang (co the can them thoi gian)" -ForegroundColor Yellow
    Write-Host "      Xem logs: docker-compose logs backend" -ForegroundColor Gray
}

Write-Host "`n=== HOAN TAT! ===`n" -ForegroundColor Cyan
Write-Host "Cac services da duoc khoi dong:" -ForegroundColor Green
Write-Host "  - SQL Server: localhost,1433" -ForegroundColor Gray
Write-Host "  - Backend API: http://localhost:5000" -ForegroundColor Gray
Write-Host "  - Swagger UI: http://localhost:5000/swagger" -ForegroundColor Gray
Write-Host "`nCac lenh huu ich:" -ForegroundColor Yellow
Write-Host "  - Xem logs: docker-compose logs -f" -ForegroundColor Gray
Write-Host "  - Dung services: docker-compose down" -ForegroundColor Gray
Write-Host "  - Restart: docker-compose restart backend" -ForegroundColor Gray
Write-Host ""
