@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Generate New Keystore
echo ========================================
echo.

set KEYSTORE=upload-keystore.jks
set PASSWORD=yebeiying825
set ALIAS=upload
set DNAME=CN=SecRandom, OU=Development, O=Leafs825, L=City, ST=State, C=CN

echo Configuration:
echo Keystore: %KEYSTORE%
echo Password: %PASSWORD%
echo Alias: %ALIAS%
echo DName: %DNAME%
echo.

REM Find keytool
set KEYTOOL=
if exist "%JAVA_HOME%\bin\keytool.exe" (
    set KEYTOOL=%JAVA_HOME%\bin\keytool.exe
    echo Found keytool: %KEYTOOL%
)

if "%KEYTOOL%"=="" (
    if exist "C:\Program Files\Java\jdk-25\bin\keytool.exe" (
        set KEYTOOL=C:\Program Files\Java\jdk-25\bin\keytool.exe
        echo Found keytool: %KEYTOOL%
    )
)

if "%KEYTOOL%"=="" (
    if exist "C:\Program Files\Eclipse Adoptium\jdk-17.0.12_7\bin\keytool.exe" (
        set KEYTOOL=C:\Program Files\Eclipse Adoptium\jdk-17.0.12_7\bin\keytool.exe
        echo Found keytool: %KEYTOOL%
    )
)

if "%KEYTOOL%"=="" (
    if exist "C:\Program Files\Microsoft\jdk-17.0.12_7\bin\keytool.exe" (
        set KEYTOOL=C:\Program Files\Microsoft\jdk-17.0.12_7\bin\keytool.exe
        echo Found keytool: %KEYTOOL%
    )
)

if "%KEYTOOL%"=="" (
    echo.
    echo Error: keytool.exe not found!
    echo.
    echo Please ensure Java JDK is installed and JAVA_HOME is set correctly.
    echo.
    pause
    exit /b 1
)

echo.

REM Backup existing keystore
if exist "%KEYSTORE%" (
    echo Backing up existing keystore...
    copy "%KEYSTORE%" "%KEYSTORE%.backup"
    echo Backup created: %KEYSTORE%.backup
    echo.
)

echo Generating new keystore...
echo.

"%KEYTOOL%" -genkeypair -v -keystore %KEYSTORE% -storepass %PASSWORD% -keypass %PASSWORD% -alias %ALIAS% -keyalg RSA -keysize 2048 -validity 10000 -dname "%DNAME%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Success! Keystore generated
    echo ========================================
    echo.
    echo Keystore file: %KEYSTORE%
    echo Password: %PASSWORD%
    echo Alias: %ALIAS%
    echo.
    echo Next steps:
    echo 1. Run: powershell -ExecutionPolicy Bypass -File scripts\regenerate-base64.ps1
    echo 2. Update GitHub Secret ANDROID_KEYSTORE_BASE64
    echo 3. Re-run GitHub Actions
    echo.
) else (
    echo.
    echo ========================================
    echo Failed! Keystore generation failed
    echo ========================================
    echo.
    echo Please check the error above and try again
    echo.
)

pause