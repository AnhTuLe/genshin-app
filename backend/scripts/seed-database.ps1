# Script để seed database thủ công
# Chay: .\backend\scripts\seed-database.ps1

Write-Host "`n=== DATABASE SEEDING ===`n" -ForegroundColor Cyan

# Kiểm tra xem đang ở đúng thư mục không
$backendPath = Split-Path -Parent $PSScriptRoot
$apiPath = Join-Path $backendPath "PriceArbitrage.API"

if (-not (Test-Path $apiPath)) {
    Write-Host "[ERROR] Khong tim thay thu muc PriceArbitrage.API" -ForegroundColor Red
    Write-Host "       Dang o: $PWD" -ForegroundColor Yellow
    Write-Host "       Chay script tu thu muc root cua project" -ForegroundColor Yellow
    exit 1
}

# Điều hướng đến thư mục API
Push-Location $apiPath

try {
    Write-Host "1. Kiem tra connection string..." -ForegroundColor Yellow
    
    # Kiểm tra appsettings.Development.json
    $appsettingsPath = Join-Path $apiPath "appsettings.Development.json"
    if (Test-Path $appsettingsPath) {
        Write-Host "   [OK] Tim thay appsettings.Development.json" -ForegroundColor Green
    } else {
        Write-Host "   [WARN] Khong tim thay appsettings.Development.json" -ForegroundColor Yellow
        Write-Host "          Su dung appsettings.json" -ForegroundColor Gray
    }

    Write-Host "`n2. Dang apply migrations..." -ForegroundColor Yellow
    dotnet ef database update --project ..\PriceArbitrage.Infrastructure\PriceArbitrage.Infrastructure.csproj --startup-project PriceArbitrage.API.csproj
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Migrations da duoc apply thanh cong!" -ForegroundColor Green
    } else {
        Write-Host "   [ERROR] Co loi khi apply migrations" -ForegroundColor Red
        exit 1
    }

    Write-Host "`n3. Dang seed du lieu..." -ForegroundColor Yellow
    Write-Host "   Note: Seed data se tu dong chay khi start app trong Development mode" -ForegroundColor Gray
    Write-Host "   Hoac co the tao mot controller endpoint de seed data thu cong" -ForegroundColor Gray

    Write-Host "`n[OK] Database da san sang!" -ForegroundColor Green
    Write-Host "`nThong tin tai khoan mac dinh:" -ForegroundColor Cyan
    Write-Host "  Admin: admin@example.com / Admin@123" -ForegroundColor Gray
    Write-Host "  User:  user@example.com / User@123" -ForegroundColor Gray
    Write-Host "`nLuu y: Hay doi mat khau sau khi dang nhap lan dau!" -ForegroundColor Yellow

} catch {
    Write-Host "`n[ERROR] Co loi xay ra: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

Write-Host "`n=== HOAN TAT! ===`n" -ForegroundColor Cyan
