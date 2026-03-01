$keystorePath = "upload-keystore.jks"

Write-Host "========================================"
Write-Host "Keystore Password Check Tool"
Write-Host "========================================"
Write-Host ""

$password = Read-Host "Please enter keystore password: " -AsSecureString

if ([string]::IsNullOrWhiteSpace($password)) {
    Write-Host "Error: Password cannot be empty" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""
Write-Host "Verifying keystore password..."
Write-Host ""

# Try different keytool paths
$keytoolPaths = @(
    "$env:JAVA_HOME\bin\keytool.exe",
    "C:\Program Files\Java\jdk-25\bin\keytool.exe",
    "C:\Program Files\Eclipse Adoptium\jdk-17.0.12_7\bin\keytool.exe",
    "C:\Program Files\Microsoft\jdk-17.0.12_7\bin\keytool.exe"
)

$keytool = $null
foreach ($path in $keytoolPaths) {
    if (Test-Path $path)) {
        $keytool = $path
        Write-Host "Found keytool: $path" -ForegroundColor Green
        break
    }
}

if ($null -eq $keytool) {
    Write-Host "Error: keytool.exe not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure Java JDK is installed"
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""

# Try to list keystore
$output = & $keytool -list -v -keystore $keystorePath -storepass $password 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Success! Password is correct" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Keystore information:"
    Write-Host $output
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "GitHub Secrets Configuration:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "ANDROID_KEYSTORE_PASSWORD: $password" -ForegroundColor Yellow
    Write-Host "ANDROID_KEY_ALIAS: release" -ForegroundColor Yellow
    Write-Host "ANDROID_KEY_PASSWORD: (usually same as keystore password)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please update these secrets in GitHub:" -ForegroundColor Green
    Write-Host "Settings -> Secrets and variables -> Actions" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Failed! Password is incorrect" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:"
    Write-Host $output -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check the password and try again" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit..."