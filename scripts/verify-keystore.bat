@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Keystore Verification Tool
echo ========================================
echo.

set KEYSTORE=upload-keystore.jks
set PASSWORD=yebeiying825
set ALIAS=upload

echo Configuration:
echo Keystore: %KEYSTORE%
echo Password: %PASSWORD%
echo Alias: %ALIAS%
echo.

if not exist "%KEYSTORE%" (
    echo Error: Keystore file not found: %KEYSTORE%
    pause
    exit /b 1
)

echo Testing keystore...
echo.

REM Try to list keystore contents
"C:\Program Files\Java\jdk-25\bin\keytool.exe" -list -v -keystore %KEYSTORE% -storepass %PASSWORD%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Success! Password is correct
    echo ========================================
    echo.
    echo GitHub Secrets Configuration:
    echo ANDROID_KEYSTORE_PASSWORD: %PASSWORD%
    echo ANDROID_KEY_PASSWORD: %PASSWORD%
    echo ANDROID_KEY_ALIAS: %ALIAS%
    echo.
) else (
    echo.
    echo ========================================
    echo Failed! Password is incorrect
    echo ========================================
    echo.
    echo Please check the password and try again
    echo.
)

pause