$ErrorActionPreference = "Stop"

$keystorePath = "upload-keystore.jks"
$outputPath = "upload-keystore-base64.txt"

Write-Host "========================================"
Write-Host "Keystore to Base64 Converter"
Write-Host "========================================"
Write-Host ""

if (-not (Test-Path $keystorePath)) {
    Write-Host "Error: Keystore file not found: $keystorePath" -ForegroundColor Red
    Write-Host "Please ensure the keystore file exists in the current directory" -ForegroundColor Yellow
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host "Reading keystore file: $keystorePath" -ForegroundColor Cyan

try {
    $bytes = [System.IO.File]::ReadAllBytes($keystorePath)
    $base64 = [System.Convert]::ToBase64String($bytes)

    Write-Host "Converting to Base64..." -ForegroundColor Cyan
    Write-Host "Original size: $($bytes.Length) bytes" -ForegroundColor Cyan
    Write-Host "Base64 size: $($base64.Length) characters" -ForegroundColor Cyan
    Write-Host ""

    [System.IO.File]::WriteAllText($outputPath, $base64, [System.Text.Encoding]::ASCII)

    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Conversion completed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Output file: $outputPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Open $outputPath" -ForegroundColor White
    Write-Host "2. Copy the entire Base64 content" -ForegroundColor White
    Write-Host "3. Go to GitHub: Settings -> Secrets and variables -> Actions" -ForegroundColor White
    Write-Host "4. Create/Update secret: ANDROID_KEYSTORE_BASE64" -ForegroundColor White
    Write-Host "5. Paste the Base64 content" -ForegroundColor White
    Write-Host ""
    Write-Host "Important:" -ForegroundColor Yellow
    Write-Host "- Do not add or remove any characters" -ForegroundColor White
    Write-Host "- Do not add extra spaces or line breaks" -ForegroundColor White
    Write-Host "- Copy from the first character to the last character" -ForegroundColor White
    Write-Host ""
    Write-Host "Required GitHub Secrets:" -ForegroundColor Cyan
    Write-Host "- ANDROID_KEYSTORE_BASE64: (copy from $outputPath)" -ForegroundColor White
    Write-Host "- ANDROID_KEYSTORE_PASSWORD: yebeiying825" -ForegroundColor White
    Write-Host "- ANDROID_KEY_PASSWORD: yebeiying825" -ForegroundColor White
    Write-Host "- ANDROID_KEY_ALIAS: upload" -ForegroundColor White
    Write-Host ""

    $showContent = Read-Host "Do you want to display the Base64 content? (y/n)"
    if ($showContent -eq 'y' -or $showContent -eq 'Y') {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Base64 Content:" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host $base64
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
    }

} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Error occurred during conversion" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host ""
Read-Host "Press Enter to exit..."