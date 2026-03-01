$ErrorActionPreference = "Stop"

$keystorePath = "upload-keystore.jks"
$password = "yebeiying825"
$alias = "upload"

Write-Host "========================================"
Write-Host "Keystore Verification Tool"
Write-Host "========================================"
Write-Host ""

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "Keystore: $keystorePath" -ForegroundColor White
Write-Host "Password: $password" -ForegroundColor White
Write-Host "Alias: $alias" -ForegroundColor White
Write-Host ""

if (-not (Test-Path $keystorePath)) {
    Write-Host "Error: Keystore file not found: $keystorePath" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

# Find Java installation
$javaPaths = @(
    "C:\Program Files\Java\jdk-25\bin\java.exe",
    "C:\Program Files\Eclipse Adoptium\jdk-17.0.12_7\bin\java.exe",
    "C:\Program Files\Microsoft\jdk-17.0.12_7\bin\java.exe"
)

$java = $null
foreach ($path in $javaPaths) {
    if (Test-Path $path) {
        $java = $path
        $javaDir = Split-Path $path -Parent
        $keytool = Join-Path $javaDir "keytool.exe"
        Write-Host "Found Java: $path" -ForegroundColor Green
        Write-Host "Found keytool: $keytool" -ForegroundColor Green
        break
    }
}

if ($null -eq $java) {
    Write-Host "Error: Java not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure Java JDK is installed" -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""
Write-Host "Testing keystore with password..." -ForegroundColor Cyan

# Test 1: List keystore with password
Write-Host ""
Write-Host "Test 1: Listing keystore..." -ForegroundColor Yellow
$output = & $keytool -list -v -keystore $keystorePath -storepass $password 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Password is correct" -ForegroundColor Green
    Write-Host ""
    Write-Host "Keystore contents:" -ForegroundColor Cyan
    Write-Host $output
} else {
    Write-Host "Failed! Password is incorrect" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Red
    Write-Host $output
    Write-Host ""
    Write-Host "This means the password 'yebeiying825' is NOT correct!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible solutions:" -ForegroundColor Yellow
    Write-Host "1. Check the correct password in android/app/key.properties" -ForegroundColor White
    Write-Host "2. Update GitHub Secret ANDROID_KEYSTORE_PASSWORD with the correct password" -ForegroundColor White
    Write-Host "3. Update GitHub Secret ANDROID_KEY_PASSWORD with the correct password" -ForegroundColor White
    Read-Host "Press Enter to exit..."
    exit 1
}

# Test 2: Verify specific alias
Write-Host ""
Write-Host "Test 2: Verifying alias '$alias'..." -ForegroundColor Yellow
$output = & $keytool -list -keystore $keystorePath -storepass $password -alias $alias 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Alias '$alias' exists" -ForegroundColor Green
    Write-Host ""
    Write-Host "Alias details:" -ForegroundColor Cyan
    Write-Host $output
} else {
    Write-Host "Failed! Alias '$alias' not found or incorrect password" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Red
    Write-Host $output
    Write-Host ""
    Write-Host "This means the alias 'upload' is NOT correct!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible solutions:" -ForegroundColor Yellow
    Write-Host "1. Check the correct alias in android/app/key.properties" -ForegroundColor White
    Write-Host "2. Update GitHub Secret ANDROID_KEY_ALIAS with the correct alias" -ForegroundColor White
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "All tests passed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "The keystore can be used with:" -ForegroundColor Cyan
Write-Host "  - Password: yebeiying825" -ForegroundColor White
Write-Host "  - Alias: upload" -ForegroundColor White
Write-Host ""
Write-Host "Please ensure these values are set in GitHub Secrets:" -ForegroundColor Yellow
Write-Host "  - ANDROID_KEYSTORE_PASSWORD: yebeiying825" -ForegroundColor White
Write-Host "  - ANDROID_KEY_PASSWORD: yebeiying825" -ForegroundColor White
Write-Host "  - ANDROID_KEY_ALIAS: upload" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit..."