@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Keystore 信息检查工具
echo ========================================
echo.

set /p PASSWORD="请输入 keystore 密码: "

if "%PASSWORD%"=="" (
    echo 错误: 密码不能为空
    pause
    exit /b 1
)

echo.
echo 正在验证 keystore 密码...
echo.

REM 尝试使用不同的 keytool 路径
set KEYTOOL_FOUND=0

if exist "%JAVA_HOME%\bin\keytool.exe" (
    set KEYTOOL="%JAVA_HOME%\bin\keytool.exe"
    set KEYTOOL_FOUND=1
    echo 找到 keytool: %KEYTOOL%
)

if %KEYTOOL_FOUND%==0 (
    if exist "C:\Program Files\Java\jdk-25\bin\keytool.exe" (
        set KEYTOOL="C:\Program Files\Java\jdk-25\bin\keytool.exe"
        set KEYTOOL_FOUND=1
        echo 找到 keytool: %KEYTOOL%
    )
)

if %KEYTOOL_FOUND%==0 (
    if exist "C:\Program Files\Eclipse Adoptium\jdk-17.0.12_7\bin\keytool.exe" (
        set KEYTOOL="C:\Program Files\Eclipse Adoptium\jdk-17.0.12_7\bin\keytool.exe"
        set KEYTOOL_FOUND=1
        echo 找到 keytool: %KEYTOOL%
    )
)

if %KEYTOOL_FOUND%==0 (
    echo 错误: 未找到 keytool.exe
    echo.
    echo 请确保已安装 Java JDK
    pause
    exit /b 1
)

echo.
echo 使用 keytool: %KEYTOOL%
echo.

REM 尝试列出 keystore 中的密钥
"%KEYTOOL%" -list -v -keystore upload-keystore.jks -storepass %PASSWORD% > nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo 成功！密码正确
    echo ========================================
    echo.
    echo Keystore 信息:
    "%KEYTOOL%" -list -v -keystore upload-keystore.jks -storepass %PASSWORD%
    echo.
    echo ========================================
    echo.
    echo GitHub Secrets 配置:
    echo ========================================
    echo.
    echo ANDROID_KEYSTORE_PASSWORD: %PASSWORD%
    echo ANDROID_KEY_ALIAS: release
    echo ANDROID_KEY_PASSWORD: (通常与 keystore 密码相同)
    echo.
) else (
    echo.
    echo ========================================
    echo 失败！密码不正确
    echo ========================================
    echo.
    echo 请检查密码并重试
    echo.
)

pause