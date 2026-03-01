$ErrorActionPreference = "Stop"

$keystorePath = "upload-keystore.jks"
$password = "yebeiying825"
$alias = "upload"
$dname = "CN=SecRandom, OU=Development, O=Leafs825, L=City, ST=State, C=CN"

Write-Host "========================================"
Write-Host "Generate New Keystore"
Write-Host "========================================"
Write-Host ""

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "Keystore: $keystorePath" -ForegroundColor White
Write-Host "Password: $password" -ForegroundColor White
Write-Host "Alias: $alias" -ForegroundColor White
Write-Host "DName: $dname" -ForegroundColor White
Write-Host ""

# Find keytool
$keytoolPaths = @(
    "$env:JAVA_HOME\bin\keytool.exe",
    "C:\Program Files\Java\jdk-25.0.2\bin\keytool.exe",
    "C:\Program Files\Java\jdk-25\bin\keytool.exe",
    "C:\Program Files\Java\latest\bin\keytool.exe",
    "C:\Program Files\Eclipse Adoptium\jdk-17.0.12_7\bin\keytool.exe",
    "C:\Program Files\Microsoft\jdk-17.0.12_7\bin\keytool.exe"
)

$keytool = $null
foreach ($path in $keytoolPaths) {
    if (Test-Path $path) {
        $keytool = $path
        Write-Host "Found keytool: $path" -ForegroundColor Green
        break
    }
}

if ($null -eq $keytool) {
    Write-Host "Error: keytool.exe not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure Java JDK is installed" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Searching for Java installations..." -ForegroundColor Cyan
    
    $javaDirs = @(
        "C:\Program Files\Java",
        "C:\Program Files (x86)\Java"
    )
    
    foreach ($dir in $javaDirs) {
        if (Test-Path $dir) {
            Write-Host "Found Java directory: $dir" -ForegroundColor Yellow
            Get-ChildItem -Path $dir -Directory | ForEach-Object {
                Write-Host "  - $($_.Name)" -ForegroundColor Gray
            }
        }
    }
    
    Write-Host ""
    Write-Host "If Java is installed, please set JAVA_HOME environment variable" -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""

# Backup existing keystore
if (Test-Path $keystorePath) {
    Write-Host "Backing up existing keystore..." -ForegroundColor Cyan
    Copy-Item $keystorePath "$keystorePath.backup"
    Write-Host "Backup created: $keystorePath.backup" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Generating new keystore..." -ForegroundColor Cyan
Write-Host ""

# Generate keystore
$args = @(
    "-genkeypair",
    "-v",
    "-keystore", $keystorePath,
    "-storepass", $password,
    "-keypass", $password,
    "-alias", $alias,
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-dname", $dname
)

& $keytool @args

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Success! Keystore generated" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Keystore file: $keystorePath" -ForegroundColor White
    Write-Host "Password: $password" -ForegroundColor White
    Write-Host "Alias: $alias" -ForegroundColor White
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run: powershell -ExecutionPolicy Bypass -File scripts\regenerate-base64.ps1" -ForegroundColor White
    Write-Host "2. Update GitHub Secret ANDROID_KEYSTORE_BASE64" -ForegroundColor White
    Write-Host "3. Re-run GitHub Actions" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Failed! Keystore generation failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check the error above and try again" -ForegroundColor Yellow
    Write-Host ""
}

Read-Host "Press Enter to exit..."