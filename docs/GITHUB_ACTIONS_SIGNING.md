# GitHub Actions Android 签名配置

本指南帮助你在 GitHub Actions 上构建已签名的 Android APK。

## 快速开始

### Windows 用户

1. 运行脚本生成 keystore：
   ```bash
   scripts\generate-keystore.bat
   ```

2. 按照提示输入信息

3. 脚本会自动：
   - 生成 keystore 文件
   - 转换为 Base64 编码
   - 显示需要配置的 GitHub Secrets

### macOS/Linux 用户

1. 生成 keystore：
   ```bash
   keytool -genkey -v -keystore release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
   ```

2. 转换为 Base64：
   ```bash
   base64 -i release-keystore.jks | pbcopy
   ```

3. 复制 Base64 字符串

## 配置 GitHub Secrets

1. 进入 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**，添加以下 secrets：

| Secret 名称 | 描述 | 示例值 |
|------------|--------|---------|
| `ANDROID_KEYSTORE_BASE64` | Base64 编码的 keystore 文件 | `MIICeQIBADANBgkqhkiG9w0BAQEFAASCA...` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore 密码 | `your_strong_password` |
| `ANDROID_KEY_PASSWORD` | Key 密码 | `your_strong_password` |
| `ANDROID_KEY_ALIAS` | Key 别名 | `release` |

## 测试构建

配置完成后，测试构建：

1. 进入 **Actions** 标签页
2. 选择 **Build and Release** workflow
3. 点击 **Run workflow**
4. 填写版本号（如 `0.0.3`）
5. 填写标签（如 `v0.0.3`）
6. 勾选 **Create a GitHub Release**
7. 点击 **Run workflow**

## 验证签名

构建完成后，下载 APK 并验证：

```bash
# 使用 apksigner
apksigner verify --print-certs SecRandom_lutter_0.0.3_android.apk

# 输出应该显示：
# Verified using v1 scheme (JAR signing): true
# Verified using v2 scheme (APK Signature Scheme v2): true
# Number of signers: 1
```

## 工作流程说明

GitHub Actions 会自动执行以下步骤：

1. ✅ 检出代码
2. ✅ 设置 Java 17
3. ✅ 设置 Flutter
4. ✅ 安装依赖
5. ✅ 解码 keystore（从 GitHub Secrets）
6. ✅ 创建 key.properties
7. ✅ 构建签名的 APK
8. ✅ 上传构建产物

## 安全建议

⚠️ **重要提示**：

1. **不要提交 keystore 文件到代码仓库**
   - keystore 文件已在 `.gitignore` 中
   - 只通过 GitHub Secrets 传递

2. **使用强密码**
   - 至少 12 个字符
   - 包含大小写字母、数字和特殊字符

3. **备份 keystore**
   - 保存到安全位置
   - 如果丢失，无法更新应用

4. **定期更新密码**
   - 建议每年更新一次
   - 记得同时更新 GitHub Secrets

## 故障排除

### 构建失败：找不到 keystore

**错误信息**：
```
Execution failed for task ':app:packageRelease'.
> Keystore file 'release-keystore.jks' not found for signing config 'release'.
```

**解决方案**：
- 检查 `ANDROID_KEYSTORE_BASE64` 是否正确
- 确保 Base64 编码没有多余的空格或换行

### 构建失败：密码错误

**错误信息**：
```
Execution failed for task ':app:packageRelease'.
> Keystore was tampered with, or password was incorrect
```

**解决方案**：
- 检查 `ANDROID_KEYSTORE_PASSWORD` 是否正确
- 检查 `ANDROID_KEY_PASSWORD` 是否正确

### APK 无法安装

**可能原因**：
- 签名配置错误
- APK 损坏

**解决方案**：
- 重新构建 APK
- 验证签名：`apksigner verify your-app.apk`

## 详细文档

更多详细信息请参考：[ANDROID_SIGNING.md](./ANDROID_SIGNING.md)

## 相关链接

- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Flutter Android Release](https://flutter.dev/docs/deployment/android)