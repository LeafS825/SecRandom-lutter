# Android 签名配置指南

## 概述

为了在 GitHub Actions 上构建已签名的 Android APK，需要配置以下 GitHub Secrets：

## 必需的 GitHub Secrets

在 GitHub 仓库的 Settings → Secrets and variables → Actions 中添加以下 secrets：

### 1. ANDROID_KEYSTORE_BASE64
- **描述**: Base64 编码的 Android Keystore 文件
- **获取方式**: 
  ```bash
  base64 -i your-keystore.jks | pbcopy
  ```
  或者在 Windows 上:
  ```powershell
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("your-keystore.jks"))
  ```

### 2. ANDROID_KEYSTORE_PASSWORD
- **描述**: Keystore 的密码
- **获取方式**: 创建 keystore 时设置的密码

### 3. ANDROID_KEY_PASSWORD
- **描述**: Key 的密码
- **获取方式**: 创建 keystore 时设置的密码（通常与 keystore 密码相同）

### 4. ANDROID_KEY_ALIAS
- **描述**: Key 的别名
- **获取方式**: 创建 keystore 时设置的别名

## 生成 Keystore

### 方法 1: 使用 keytool（推荐）

```bash
keytool -genkey -v -keystore release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

按照提示输入：
- **Keystore 密码**: 设置一个强密码（用于 `ANDROID_KEYSTORE_PASSWORD`）
- **Key 密码**: 设置一个强密码（用于 `ANDROID_KEY_PASSWORD`）
- **别名**: 输入 `release`（用于 `ANDROID_KEY_ALIAS`）
- **姓名、组织等信息**: 填写你的信息

### 方法 2: 使用 Android Studio

1. 打开 Android Studio
2. 选择 **Build → Generate Signed Bundle / APK**
3. 选择 **APK**，点击 **Next**
4. 选择 **Create new...**
5. 填写 Keystore 信息：
   - **Key store path**: 选择保存位置
   - **Password**: 设置密码
   - **Key alias**: 设置别名（如 `release`）
   - **Key password**: 设置密码
6. 点击 **OK** 生成 keystore

## 配置步骤

### 1. 生成 Keystore

```bash
# 生成 keystore
keytool -genkey -v -keystore release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

### 2. 转换为 Base64

```bash
# macOS/Linux
base64 -i release-keystore.jks | pbcopy

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("release-keystore.jks"))
```

### 3. 添加到 GitHub Secrets

1. 进入 GitHub 仓库页面
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 添加以下 secrets：
   - **Name**: `ANDROID_KEYSTORE_BASE64`
     - **Value**: 粘贴 Base64 编码的 keystore 内容
   - **Name**: `ANDROID_KEYSTORE_PASSWORD`
     - **Value**: 你的 keystore 密码
   - **Name**: `ANDROID_KEY_PASSWORD`
     - **Value**: 你的 key 密码
   - **Name**: `ANDROID_KEY_ALIAS`
     - **Value**: `release`

### 4. 测试构建

1. 进入 GitHub 仓库的 **Actions** 标签页
2. 选择 **Build and Release** workflow
3. 点击 **Run workflow**
4. 填写版本号和标签
5. 点击 **Run workflow** 开始构建

## 验证签名

构建完成后，下载 APK 并验证签名：

```bash
# 使用 apksigner 验证
apksigner verify --print-certs SecRandom_lutter_0.0.3_android.apk

# 或使用 jarsigner
jarsigner -verify -verbose -certs SecRandom_lutter_0.0.3_android.apk
```

## 注意事项

1. **安全提示**:
   - 不要将 keystore 文件提交到代码仓库
   - 使用强密码保护 keystore
   - 定期备份 keystore 文件
   - 不要泄露 GitHub Secrets

2. **有效期**:
   - 建议设置较长的有效期（如 10000 天）
   - 过期后需要重新生成 keystore

3. **别名**:
   - 使用简单易记的别名（如 `release`）
   - 别名在配置中必须一致

4. **密码管理**:
   - 建议使用密码管理器存储密码
   - 不要在代码中硬编码密码

## 故障排除

### 构建失败：签名错误

检查 GitHub Secrets 是否正确配置：
- `ANDROID_KEYSTORE_BASE64` 是否正确编码
- `ANDROID_KEYSTORE_PASSWORD` 是否正确
- `ANDROID_KEY_PASSWORD` 是否正确
- `ANDROID_KEY_ALIAS` 是否与 keystore 中的别名一致

### APK 无法安装

检查签名是否正确：
```bash
apksigner verify SecRandom_lutter_0.0.3_android.apk
```

### Base64 编码错误

确保使用正确的编码命令：
- macOS/Linux: `base64 -i`
- Windows: `[Convert]::ToBase64String(...)`

## 参考资料

- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Flutter Android Release](https://flutter.dev/docs/deployment/android)