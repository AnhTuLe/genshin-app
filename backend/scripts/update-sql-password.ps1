# Script cap nhat password cho SQL Server
# Chay: .\backend\scripts\update-sql-password.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$NewPassword,
    
    [string]$Server = "localhost,1433",
    [string]$User = "sa",
    [string]$CurrentPassword = "Kimchau@1997"
)

Write-Host "`n=== CAP NHAT PASSWORD SQL SERVER ===`n" -ForegroundColor Cyan

# Kiem tra SQL Server dang chay
Write-Host "1. Kiem tra SQL Server..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Data -ErrorAction Stop
    
    $testConnection = "Server=$Server;Database=master;User Id=$User;Password=$CurrentPassword;TrustServerCertificate=true;"
    $testConn = New-Object System.Data.SqlClient.SqlConnection($testConnection)
    $testConn.Open()
    $testConn.Close()
    Write-Host "   [OK] Ket noi thanh cong voi password hien tai" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] Khong the ket noi voi password hien tai: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "      Kiem tra:" -ForegroundColor Yellow
    Write-Host "      - SQL Server dang chay" -ForegroundColor Gray
    Write-Host "      - CurrentPassword dung: $CurrentPassword" -ForegroundColor Gray
    exit 1
}

# Cap nhat password
Write-Host "`n2. Cap nhat password..." -ForegroundColor Yellow
try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($testConnection)
    $connection.Open()
    
    # Thay doi password
    $changePasswordQuery = "ALTER LOGIN [$User] WITH PASSWORD = '$NewPassword'"
    $command = New-Object System.Data.SqlClient.SqlCommand($changePasswordQuery, $connection)
    $command.ExecuteNonQuery()
    
    Write-Host "   [OK] Password da duoc cap nhat!" -ForegroundColor Green
    
    $connection.Close()
} catch {
    Write-Host "   [ERROR] Loi khi cap nhat password: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test ket noi voi password moi
Write-Host "`n3. Kiem tra ket noi voi password moi..." -ForegroundColor Yellow
try {
    $newConnection = "Server=$Server;Database=master;User Id=$User;Password=$NewPassword;TrustServerCertificate=true;"
    $newConn = New-Object System.Data.SqlClient.SqlConnection($newConnection)
    $newConn.Open()
    $newConn.Close()
    Write-Host "   [OK] Ket noi thanh cong voi password moi!" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] Khong the ket noi voi password moi: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Cap nhat appsettings.json
Write-Host "`n4. Cap nhat appsettings.json..." -ForegroundColor Yellow
$appsettingsPath = "..\PriceArbitrage.API\appsettings.json"
if (Test-Path $appsettingsPath) {
    try {
        $appsettings = Get-Content $appsettingsPath -Raw | ConvertFrom-Json
        $oldConnection = $appsettings.ConnectionStrings.DefaultConnection
        
        # Thay doi password trong connection string
        $newConnectionString = $oldConnection -replace "Password=[^;]+", "Password=$NewPassword"
        $appsettings.ConnectionStrings.DefaultConnection = $newConnectionString
        
        # Luu lai
        $appsettings | ConvertTo-Json -Depth 10 | Set-Content $appsettingsPath -Encoding UTF8
        Write-Host "   [OK] appsettings.json da duoc cap nhat!" -ForegroundColor Green
        Write-Host "      Connection string: $newConnectionString" -ForegroundColor Gray
    } catch {
        Write-Host "   [WARN] Khong the cap nhat appsettings.json: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "      Ban can cap nhat thu cong:" -ForegroundColor Yellow
        Write-Host "      Password=$NewPassword" -ForegroundColor Gray
    }
} else {
    Write-Host "   [WARN] Khong tim thay appsettings.json" -ForegroundColor Yellow
}

Write-Host "`n=== Hoan tat! ===`n" -ForegroundColor Cyan
Write-Host "Password moi: $NewPassword" -ForegroundColor Green
Write-Host "Luu y: Giu password nay an toan!" -ForegroundColor Yellow
