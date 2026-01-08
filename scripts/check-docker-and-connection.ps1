# Script kiểm tra Docker và Connection
# Chạy: .\scripts\check-docker-and-connection.ps1

Write-Host "`n🔍 KIỂM TRA DOCKER VÀ CONNECTION`n" -ForegroundColor Cyan

# 1. Kiểm tra Docker đang chạy
Write-Host "1️⃣ Kiểm tra Docker Service..." -ForegroundColor Yellow
$dockerService = Get-Service -Name "Docker*" -ErrorAction SilentlyContinue
if ($dockerService) {
    $running = $dockerService | Where-Object { $_.Status -eq 'Running' }
    if ($running) {
        Write-Host "   ✅ Docker Service đang chạy" -ForegroundColor Green
        $running | ForEach-Object { Write-Host "      - $($_.Name): $($_.Status)" -ForegroundColor Gray }
    } else {
        Write-Host "   ❌ Docker Service chưa chạy" -ForegroundColor Red
        Write-Host "      Chạy: Start-Service -Name 'Docker Desktop Service'" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠️  Không tìm thấy Docker Service" -ForegroundColor Yellow
    Write-Host "      Đảm bảo Docker Desktop đã được cài đặt" -ForegroundColor Yellow
}

# 2. Kiểm tra Docker containers
Write-Host "`n2️⃣ Kiểm tra Docker Containers..." -ForegroundColor Yellow
try {
    $containers = docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Docker CLI hoạt động" -ForegroundColor Green
        Write-Host "`n   Containers:" -ForegroundColor Gray
        $containers | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
        
        # Kiểm tra containers cụ thể
        $backendContainer = docker ps --filter "name=backend" --format "{{.Names}}" 2>&1
        $frontendContainer = docker ps --filter "name=frontend" --format "{{.Names}}" 2>&1
        
        if ($backendContainer) {
            Write-Host "`n   ✅ Backend container đang chạy: $backendContainer" -ForegroundColor Green
        } else {
            Write-Host "`n   ❌ Backend container chưa chạy" -ForegroundColor Red
            Write-Host "      Chạy: docker-compose up -d backend" -ForegroundColor Yellow
        }
        
        if ($frontendContainer) {
            Write-Host "   ✅ Frontend container đang chạy: $frontendContainer" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Frontend container chưa chạy" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ❌ Lỗi khi chạy Docker CLI: $containers" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Lỗi: $_" -ForegroundColor Red
}

# 3. Kiểm tra API endpoint
Write-Host "`n3️⃣ Kiểm tra API Backend (http://localhost:5000)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/swagger" -Method GET -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ API Backend đang chạy và phản hồi" -ForegroundColor Green
        Write-Host "      Swagger UI: http://localhost:5000/swagger" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ❌ API Backend không phản hồi hoặc chưa chạy" -ForegroundColor Red
    Write-Host "      Lỗi: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host "      Kiểm tra: docker-compose logs backend" -ForegroundColor Yellow
}

# 4. Kiểm tra Health Check endpoint (nếu có)
Write-Host "`n4️⃣ Kiểm tra Health Check endpoint..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:5000/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    if ($healthResponse.StatusCode -eq 200) {
        $healthData = $healthResponse.Content | ConvertFrom-Json -ErrorAction SilentlyContinue
        Write-Host "   ✅ Health Check OK" -ForegroundColor Green
        if ($healthData) {
            Write-Host "      Status: $($healthData.status)" -ForegroundColor Gray
            if ($healthData.checks) {
                $healthData.checks | ForEach-Object {
                    $status = if ($_.status -eq "Healthy") { "✅" } else { "❌" }
                    Write-Host "      $status $($_.name): $($_.status)" -ForegroundColor Gray
                }
            }
        }
    }
} catch {
    Write-Host "   ⚠️  Health Check endpoint chưa có hoặc chưa cấu hình" -ForegroundColor Yellow
    Write-Host "      (Sẽ được thêm vào Program.cs)" -ForegroundColor Gray
}

# 5. Kiểm tra SQL Server Connection
Write-Host "`n5️⃣ Kiểm tra SQL Server Connection..." -ForegroundColor Yellow
$connectionString = "Server=localhost,1433;Database=master;User Id=sa;Password=letuanh821993;TrustServerCertificate=true;"

try {
    # Thử load System.Data.SqlClient
    Add-Type -AssemblyName System.Data -ErrorAction Stop
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "   ✅ Kết nối SQL Server thành công!" -ForegroundColor Green
    
    # Kiểm tra database
    $dbCommand = New-Object System.Data.SqlClient.SqlCommand("SELECT name FROM sys.databases WHERE name = 'PriceArbitrageDB'", $connection)
    $dbExists = $dbCommand.ExecuteScalar()
    
    if ($dbExists) {
        Write-Host "   ✅ Database 'PriceArbitrageDB' đã tồn tại" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Database 'PriceArbitrageDB' chưa tồn tại" -ForegroundColor Yellow
        Write-Host "      Tạo database: sqlcmd -S localhost,1433 -U sa -P letuanh821993 -Q 'CREATE DATABASE PriceArbitrageDB'" -ForegroundColor Gray
    }
    
    $connection.Close()
} catch {
    Write-Host "   ❌ Lỗi kết nối SQL Server: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "      Kiểm tra:" -ForegroundColor Yellow
    Write-Host "      1. SQL Server đang chạy: Get-Service -Name 'MSSQL*'" -ForegroundColor Gray
    Write-Host "      2. Port 1433 đã mở" -ForegroundColor Gray
    Write-Host "      3. Username/Password đúng" -ForegroundColor Gray
}

# 6. Kiểm tra Frontend
Write-Host "`n6️⃣ Kiểm tra Frontend (http://localhost:3000)..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 5 -ErrorAction Stop
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Frontend đang chạy và phản hồi" -ForegroundColor Green
        Write-Host "      URL: http://localhost:3000" -ForegroundColor Gray
    }
} catch {
    Write-Host "   ⚠️  Frontend không phản hồi hoặc chưa chạy" -ForegroundColor Yellow
    Write-Host "      Kiểm tra: docker-compose logs frontend" -ForegroundColor Gray
}

Write-Host "`n✨ Hoàn tất kiểm tra!`n" -ForegroundColor Cyan
