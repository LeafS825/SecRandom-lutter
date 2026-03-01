$ErrorActionPreference = "Stop"

$keystorePath = "upload-keystore.jks"
$password = "yebeiying825"
$alias = "upload"

Write-Host "========================================"
Write-Host "Verify New Keystore"
Write-Host "========================================"
Write-Host ""

Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "Keystore: $keystorePath" -ForegroundColor White
Write-Host "Password: $password" -ForegroundColor White
Write-Host "Alias: $alias" -ForegroundColor White
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
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""
Write-Host "Testing keystore..." -ForegroundColor Cyan

# Test 1: List keystore with JKS format
Write-Host ""
Write-Host "Test 1: Listing keystore with JKS format..." -ForegroundColor Yellow
$output = & $keytool -list -v -keystore $keystorePath -storepass $password -storetype JKS 2>&1

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
    Read-Host "Press Enter to exit..."
    exit 1
}

# Test 2: Verify specific alias
Write-Host ""
Write-Host "Test 2: Verifying alias '$alias'..." -ForegroundColor Yellow
$output = & $keytool -list -keystore $keystorePath -storepass $password -alias $alias -storetype JKS 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! Alias '$alias' exists" -ForegroundColor Green
    Write-Host ""
    Write-Host "Alias details:" -ForegroundColor Cyan
    Write-Host $output
} else {
    Write-Host "Failed! Alias '$alias' not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Red
    Write-Host $output
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "All tests passed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "The keystore is ready to use with:" -ForegroundColor Cyan
Write-Host "  - Password: yebeiying825" -ForegroundColor White
Write-Host "  - Alias: upload" -ForegroundColor White
Write-Host "  - Format: JKS" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Copy Base64 from upload-keystore-base64.txt" -ForegroundColor White
Write-Host "2. Update GitHub Secret ANDROID_KEYSTORE_BASE64" -ForegroundColor White
Write-Host "3. Ensure other secrets are correct:" -ForegroundColor White
Write-Host "   - ANDROID_KEYSTORE_PASSWORD: yebeiying825" -ForegroundColor White
Write-Host "   - ANDROID_KEY_PASSWORD: yebeiying825" -ForegroundColor White
Write-Host "   - ANDROID_KEY_ALIAS: upload" -ForegroundColor White
Write-Host "4. Commit and push code" -ForegroundColor White
Write-Host "5. Re-run GitHub Actions" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit..."