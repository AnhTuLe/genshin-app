# Script kiem tra ket noi SQL Server
# Chay: .\backend\scripts\test-sql-connection.ps1

# Set encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n=== KIEM TRA KET NOI SQL SERVER ===`n" -ForegroundColor Cyan

# Connection string - doc tu appsettings.json hoac su dung password mac dinh
# Neu SQL Server chay trong Docker, password co the la: Kimchau@1997
# Neu SQL Server chay Windows Service, password co the la: letuanh821993

# Thu doc password tu Docker container truoc
$dockerPassword = ""
try {
    $dockerEnvOutput = docker inspect sqlserver --format='{{range .Config.Env}}{{println .}}{{end}}' 2>&1
    if ($LASTEXITCODE -eq 0 -and $dockerEnvOutput) {
        $saPasswordLine = $dockerEnvOutput | Select-String -Pattern "^SA_PASSWORD=(.+)$"
        if ($saPasswordLine) {
            $dockerPassword = $saPasswordLine.Matches[0].Groups[1].Value.Trim()
            Write-Host "   [INFO] Tim thay password tu Docker container" -ForegroundColor Gray
        }
    }
} catch {
    # Khong tim thay
}

# Su dung password tu Docker neu co, neu khong thi thu password mac dinh
if ($dockerPassword -and $dockerPassword -ne "") {
    $password = $dockerPassword
} else {
    # Thu cac password pho bien
    $password = "Kimchau@1997"  # Password mac dinh cho Docker SQL Server
}

$connectionString = "Server=localhost,1433;Database=master;User Id=sa;Password=$password;TrustServerCertificate=true;"
$dbConnectionString = "Server=localhost,1433;Database=PriceArbitrageDB;User Id=sa;Password=$password;TrustServerCertificate=true;"

# 1. Kiem tra SQL Server (Docker hoac Windows Service)
Write-Host "1. Kiem tra SQL Server..." -ForegroundColor Yellow

# Kiem tra Docker containers truoc
$dockerRunning = $false
try {
    $sqlContainer = docker ps --filter "name=sql" --format "{{.Names}}" 2>&1
    if ($LASTEXITCODE -eq 0 -and $sqlContainer) {
        $containerStatus = docker ps --filter "name=sql" --format "{{.Status}}" 2>&1
        $containerPorts = docker ps --filter "name=sql" --format "{{.Ports}}" 2>&1
        Write-Host "   [OK] SQL Server dang chay trong Docker:" -ForegroundColor Green
        Write-Host "      Container: $sqlContainer" -ForegroundColor Gray
        Write-Host "      Status: $containerStatus" -ForegroundColor Gray
        Write-Host "      Ports: $containerPorts" -ForegroundColor Gray
        $dockerRunning = $true
    }
} catch {
    # Docker khong co hoac khong chay
}

# Neu khong co trong Docker, kiem tra Windows Service
if (-not $dockerRunning) {
    Write-Host "   Kiem tra Windows Service..." -ForegroundColor Gray
    $sqlServices = Get-Service -Name "MSSQL*" -ErrorAction SilentlyContinue
    if ($sqlServices) {
        $running = $sqlServices | Where-Object { $_.Status -eq 'Running' }
        if ($running) {
            Write-Host "   [OK] SQL Server Service dang chay:" -ForegroundColor Green
            $running | ForEach-Object { Write-Host "      - $($_.Name): $($_.Status)" -ForegroundColor Gray }
        } else {
            Write-Host "   [WARN] SQL Server Service chua chay" -ForegroundColor Yellow
            Write-Host "      Neu SQL Server chay trong Docker, bo qua canh bao nay" -ForegroundColor Gray
            Write-Host "      Neu chay Windows Service: Start-Service -Name 'MSSQLSERVER'" -ForegroundColor Gray
        }
    } else {
        Write-Host "   [INFO] Khong tim thay SQL Server Windows Service" -ForegroundColor Gray
        Write-Host "      SQL Server co the dang chay trong Docker hoac chua duoc cai dat" -ForegroundColor Gray
    }
}

# 2. Kiem tra Port 1433
Write-Host "`n2. Kiem tra Port 1433..." -ForegroundColor Yellow
try {
    $port = Get-NetTCPConnection -LocalPort 1433 -ErrorAction SilentlyContinue
    if ($port) {
        Write-Host "   [OK] Port 1433 dang duoc su dung (SQL Server dang lang nghe)" -ForegroundColor Green
    } else {
        Write-Host "   [WARN] Port 1433 khong duoc su dung" -ForegroundColor Yellow
        Write-Host "      SQL Server co the chua khoi dong hoac dang dung port khac" -ForegroundColor Gray
    }
} catch {
    Write-Host "   [WARN] Khong the kiem tra port 1433" -ForegroundColor Yellow
}

# 3. Kiem tra ket noi bang .NET
Write-Host "`n3. Kiem tra ket noi bang .NET..." -ForegroundColor Yellow
try {
    # Thu load System.Data
    Add-Type -AssemblyName System.Data -ErrorAction Stop
    
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "   [OK] Ket noi den SQL Server thanh cong!" -ForegroundColor Green
    
    # Kiem tra version
    $versionCommand = New-Object System.Data.SqlClient.SqlCommand("SELECT @@VERSION", $connection)
    $version = $versionCommand.ExecuteScalar()
    Write-Host "   SQL Server Version:" -ForegroundColor Gray
    $versionLines = $version -split "`n"
    if ($versionLines.Count -gt 0) {
        Write-Host "      $($versionLines[0])" -ForegroundColor Gray
    }
    
    # Kiem tra databases
    $dbCommand = New-Object System.Data.SqlClient.SqlCommand("SELECT name FROM sys.databases ORDER BY name", $connection)
    $databases = $dbCommand.ExecuteReader()
    Write-Host "`n   Databases co san:" -ForegroundColor Gray
    while ($databases.Read()) {
        $dbName = $databases["name"]
        $icon = if ($dbName -eq "PriceArbitrageDB") { "[OK]" } else { "   " }
        Write-Host "      $icon $dbName" -ForegroundColor Gray
    }
    $databases.Close()
    
    # Kiem tra database PriceArbitrageDB
    Write-Host "`n4. Kiem tra Database PriceArbitrageDB..." -ForegroundColor Yellow
    $checkDbCommand = New-Object System.Data.SqlClient.SqlCommand("SELECT name FROM sys.databases WHERE name = 'PriceArbitrageDB'", $connection)
    $dbExists = $checkDbCommand.ExecuteScalar()
    
    if ($dbExists) {
        Write-Host "   [OK] Database 'PriceArbitrageDB' da ton tai" -ForegroundColor Green
        
        # Kiem tra ket noi den database cu the
        try {
            $dbConnection = New-Object System.Data.SqlClient.SqlConnection($dbConnectionString)
            $dbConnection.Open()
            Write-Host "   [OK] Ket noi den 'PriceArbitrageDB' thanh cong!" -ForegroundColor Green
            
            # Kiem tra tables
            $tablesCommand = New-Object System.Data.SqlClient.SqlCommand("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'", $dbConnection)
            $tableCount = $tablesCommand.ExecuteScalar()
            Write-Host "   So luong tables: $tableCount" -ForegroundColor Gray
            
            $dbConnection.Close()
        } catch {
            Write-Host "   [WARN] Khong the ket noi den 'PriceArbitrageDB': $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   [ERROR] Database 'PriceArbitrageDB' chua ton tai" -ForegroundColor Red
        Write-Host "      Tao database bang lenh:" -ForegroundColor Yellow
        Write-Host "      sqlcmd -S localhost,1433 -U sa -P $password -Q 'CREATE DATABASE PriceArbitrageDB'" -ForegroundColor Gray
    }
    
    $connection.Close()
} catch {
    Write-Host "   [ERROR] Loi ket noi: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n   Khac phuc:" -ForegroundColor Yellow
    Write-Host "      1. Kiem tra SQL Server dang chay:" -ForegroundColor Gray
    Write-Host "         - Docker: docker ps --filter 'name=sql'" -ForegroundColor Gray
    Write-Host "         - Windows Service: Get-Service -Name 'MSSQL*'" -ForegroundColor Gray
    Write-Host "      2. Kiem tra username/password dung" -ForegroundColor Gray
    Write-Host "      3. Kiem tra SQL Server cho phep SQL Authentication" -ForegroundColor Gray
    Write-Host "      4. Kiem tra firewall khong chan port 1433" -ForegroundColor Gray
    Write-Host "      5. Neu chay Docker, kiem tra container: docker logs sqlserver" -ForegroundColor Gray
    exit 1
}

# 5. Kiem tra bang sqlcmd (neu co)
Write-Host "`n5. Kiem tra bang sqlcmd..." -ForegroundColor Yellow
$sqlcmdPath = Get-Command sqlcmd -ErrorAction SilentlyContinue
if ($sqlcmdPath) {
    try {
        $sqlcmdResult = sqlcmd -S localhost,1433 -U sa -P $password -Q "SELECT @@VERSION" -h -1 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [OK] sqlcmd ket noi thanh cong" -ForegroundColor Green
        } else {
            Write-Host "   [WARN] sqlcmd khong the ket noi" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   [WARN] sqlcmd khong the ket noi: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [WARN] sqlcmd khong duoc tim thay (co the chua cai SQL Server Command Line Tools)" -ForegroundColor Yellow
}

Write-Host "`n=== Hoan tat kiem tra! ===`n" -ForegroundColor Cyan
