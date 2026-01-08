# Script để kiểm tra database và migrations
# Chay: .\backend\scripts\check-database.ps1

Write-Host "`n=== KIEM TRA DATABASE VA MIGRATIONS ===`n" -ForegroundColor Cyan

# Kiểm tra containers đang chạy
Write-Host "1. Kiem tra containers..." -ForegroundColor Yellow
$sqlContainer = docker ps --filter "name=sqlserver" --format "{{.Names}}" 2>&1
$backendContainer = docker ps --filter "name=backend" --format "{{.Names}}" 2>&1

if ($sqlContainer -match "sqlserver") {
    Write-Host "   [OK] SQL Server container dang chay" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] SQL Server container khong chay" -ForegroundColor Red
    Write-Host "          Chay: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

if ($backendContainer -match "backend") {
    Write-Host "   [OK] Backend container dang chay" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Backend container khong chay" -ForegroundColor Red
    Write-Host "          Chay: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

# Kiểm tra logs backend để xem migrations
Write-Host "`n2. Kiem tra migrations trong logs..." -ForegroundColor Yellow
$logs = docker-compose logs backend --tail 100 2>&1

if ($logs -match "Đang áp dụng database migrations" -or $logs -match "Database migrations đã được áp dụng thành công") {
    Write-Host "   [OK] Migrations da duoc chay!" -ForegroundColor Green
    
    if ($logs -match "seed") {
        Write-Host "   [OK] Seed data da duoc chay!" -ForegroundColor Green
    }
} else {
    Write-Host "   [WARN] Khong thay migrations trong logs" -ForegroundColor Yellow
    Write-Host "          Xem chi tiet: docker-compose logs backend" -ForegroundColor Gray
}

# Kiểm tra database qua SQL query
Write-Host "`n3. Kiem tra tables trong database..." -ForegroundColor Yellow

$query = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo' ORDER BY TABLE_NAME;"

$result = docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Kimchau@1997" -d PriceArbitrageDB -Q "$query" -h -1 2>&1

if ($LASTEXITCODE -eq 0 -and $result -and $result.Count -gt 0) {
    Write-Host "   [OK] Tim thay cac tables trong database:" -ForegroundColor Green
    $result | Where-Object { $_ -and $_ -notmatch "^-" -and $_ -notmatch "^$" } | ForEach-Object {
        Write-Host "      - $_" -ForegroundColor Gray
    }
    
    # Kiểm tra Identity tables
    $hasIdentityTables = $result -match "AspNetUsers|AspNetRoles|AspNetUserRoles"
    if ($hasIdentityTables) {
        Write-Host "   [OK] Identity tables da duoc tao!" -ForegroundColor Green
    }
} else {
    Write-Host "   [ERROR] Khong the ket noi den database hoac database trong" -ForegroundColor Red
    Write-Host "          Co the migrations chua duoc chay" -ForegroundColor Yellow
    Write-Host "          Xem logs: docker-compose logs backend" -ForegroundColor Gray
}

# Kiểm tra users đã được seed chưa
Write-Host "`n4. Kiem tra seed data (users)..." -ForegroundColor Yellow

$userQuery = "SELECT COUNT(*) as UserCount FROM AspNetUsers;"
$userResult = docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Kimchau@1997" -d PriceArbitrageDB -Q "$userQuery" -h -1 -W 2>&1

if ($LASTEXITCODE -eq 0 -and $userResult) {
    $userCount = ($userResult | Where-Object { $_ -match "^\d+$" }) -join ""
    if ($userCount -and [int]$userCount -gt 0) {
        Write-Host "   [OK] Tim thay $userCount user(s) trong database" -ForegroundColor Green
    } else {
        Write-Host "   [WARN] Khong co user nao trong database" -ForegroundColor Yellow
        Write-Host "          Seed data co the chua duoc chay" -ForegroundColor Gray
    }
} else {
    Write-Host "   [WARN] Khong the kiem tra users (co the table chua duoc tao)" -ForegroundColor Yellow
}

Write-Host "`n=== HOAN TAT! ===`n" -ForegroundColor Cyan
Write-Host "Luu y:" -ForegroundColor Yellow
Write-Host "  - Neu khong thay tables, chay: docker-compose restart backend" -ForegroundColor Gray
Write-Host "  - Xem logs chi tiet: docker-compose logs backend -f" -ForegroundColor Gray
Write-Host ""
