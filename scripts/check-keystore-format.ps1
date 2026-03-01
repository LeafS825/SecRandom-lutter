$ErrorActionPreference = "Stop"

$keystorePath = "upload-keystore.jks"
$password = "yebeiying825"

Write-Host "========================================"
Write-Host "Keystore Format Checker"
Write-Host "========================================"
Write-Host ""

if (-not (Test-Path $keystorePath)) {
    Write-Host "Error: Keystore file not found: $keystorePath" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host "Reading keystore file header..." -ForegroundColor Cyan

# Read first few bytes to detect format
$bytes = [System.IO.File]::ReadAllBytes($keystorePath)
$magic = [System.BitConverter]::ToString($bytes[0..3]).Replace("-", "")

Write-Host "File size: $($bytes.Length) bytes" -ForegroundColor White
Write-Host "Magic bytes: $magic" -ForegroundColor White
Write-Host ""

# Detect keystore format
if ($magic -eq "FEEDFEED") {
    Write-Host "Format: JKS (Java KeyStore)" -ForegroundColor Green
    $format = "JKS"
} elseif ($magic -eq "CECECECE") {
    Write-Host "Format: JCEKS (Java Cryptography Extension KeyStore)" -ForegroundColor Green
    $format = "JCEKS"
} elseif ($magic.Substring(0, 4) -eq "CECE") {
    Write-Host "Format: PKCS12 (likely)" -ForegroundColor Green
    $format = "PKCS12"
} else {
    Write-Host "Format: Unknown (magic bytes: $magic)" -ForegroundColor Yellow
    $format = "Unknown"
}

Write-Host ""
Write-Host "Testing with different formats..." -ForegroundColor Cyan

# Find Java installation
$javaPaths = @(
    "C:\Program Files\Java\jdk-25\bin\java.exe",
    "C:\Program Files\Eclipse Adoptium\jdk-17.0.12_7\bin\java.exe",
    "C:\Program Files\Microsoft\jdk-17.0.12_7\bin\java.exe"
)

$keytool = $null
foreach ($path in $javaPaths) {
    if (Test-Path $path) {
        $javaDir = Split-Path $path -Parent
        $keytool = Join-Path $javaDir "keytool.exe"
        Write-Host "Found keytool: $keytool" -ForegroundColor Green
        break
    }
}

if ($null -eq $keytool) {
    Write-Host "Error: keytool.exe not found" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""

# Test 1: Default (auto-detect)
Write-Host "Test 1: Default format (auto-detect)" -ForegroundColor Yellow
$output = & $keytool -list -keystore $keystorePath -storepass $password 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Default format works" -ForegroundColor Green
} else {
    Write-Host "Failed! Default format doesn't work" -ForegroundColor Red
    Write-Host $output
}

Write-Host ""

# Test 2: JKS format
Write-Host "Test 2: JKS format" -ForegroundColor Yellow
$output = & $keytool -list -keystore $keystorePath -storepass $password -storetype JKS 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! JKS format works" -ForegroundColor Green
    Write-Host ""
    Write-Host "Keystore contents:" -ForegroundColor Cyan
    Write-Host $output
} else {
    Write-Host "Failed! JKS format doesn't work" -ForegroundColor Red
    Write-Host $output
}

Write-Host ""

# Test 3: PKCS12 format
Write-Host "Test 3: PKCS12 format" -ForegroundColor Yellow
$output = & $keytool -list -keystore $keystorePath -storepass $password -storetype PKCS12 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! PKCS12 format works" -ForegroundColor Green
    Write-Host ""
    Write-Host "Keystore contents:" -ForegroundColor Cyan
    Write-Host $output
} else {
    Write-Host "Failed! PKCS12 format doesn't work" -ForegroundColor Red
    Write-Host $output
}

Write-Host ""
Write-Host "========================================"
Write-Host "Recommendation:" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host ""
Write-Host "Based on the tests above, update the GitHub Actions workflow to use the correct format." -ForegroundColor White
Write-Host ""
Write-Host "If JKS works, add '-storetype JKS' to the keytool command in GitHub Actions." -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit..."