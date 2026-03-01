$bytes = [System.IO.File]::ReadAllBytes("upload-keystore.jks")
$base64 = [System.Convert]::ToBase64String($bytes)

# Write to file without line breaks
[System.IO.File]::WriteAllText("upload-keystore-base64.txt", $base64, [System.Text.Encoding]::ASCII)

Write-Host "Base64 conversion completed!"
Write-Host "Original size: $($bytes.Length) bytes"
Write-Host "Base64 size: $($base64.Length) characters"
Write-Host "Output file: upload-keystore-base64.txt"
Write-Host ""
Write-Host "File content preview:"
Write-Host "First 50 chars: $($base64.Substring(0, [Math]::Min(50, $base64.Length)))"
Write-Host "Last 50 chars: $($base64.Substring([Math]::Max(0, $base64.Length - 50)))"