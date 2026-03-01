# Android 构建失败诊断指南

## 问题现象

GitHub Actions 构建失败，错误信息：
```
com.android.ide.common.signing.KeytoolException: Failed to read key *** from store "/home/runner/work/SecRandom-lutter/SecRandom-lutter/android/app/release-keystore.jks": keystore password was incorrect
```

## 已添加的调试步骤

我已经在 `.github/workflows/build.yml` 中添加了以下调试步骤：

1. **Verify keystore file** - 检查 keystore 文件是否存在
2. **Verify key.properties** - 检查 key.properties 文件内容
3. **Test keystore with keytool** - 使用 keytool 验证 keystore

这些步骤会在构建 APK 之前执行，帮助我们诊断问题。

## 可能的原因和解决方案

### 原因 1: GitHub Secrets 中的 Base64 被截断

**症状**: Base64 内容不完整

**检查方法**:
1. 查看 GitHub Actions 日志中的 "Verify keystore file" 步骤
2. 检查文件大小是否正确（应该是 2728 字节）

**解决方案**:
1. 重新生成 Base64：
   ```bash
   powershell -ExecutionPolicy Bypass -File scripts\regenerate-base64.ps1
   ```
2. 打开 `upload-keystore-base64.txt`
3. 使用 Ctrl+A 全选，Ctrl+C 复制
4. 在 GitHub 中更新 `ANDROID_KEYSTORE_BASE64` secret
5. 粘贴时确保没有额外的空格或换行符

### 原因 2: GitHub Secrets 中包含额外的空格或换行符

**症状**: 密码或别名包含不可见字符

**检查方法**:
1. 查看 GitHub Actions 日志中的 "Verify key.properties" 步骤
2. 检查显示的配置是否正确

**解决方案**:
1. 在 GitHub 中删除并重新创建所有 4 个 secrets
2. 输入时确保：
   - `ANDROID_KEYSTORE_PASSWORD`: `yebeiying825`（无空格）
   - `ANDROID_KEY_PASSWORD`: `yebeiying825`（无空格）
   - `ANDROID_KEY_ALIAS`: `upload`（无空格）
   - `ANDROID_KEYSTORE_BASE64`: 从文件复制，无额外字符

### 原因 3: keystore 文件本身损坏

**症状**: keytool 无法读取 keystore

**检查方法**:
1. 查看 GitHub Actions 日志中的 "Test keystore with keytool" 步骤
2. 如果这一步失败，说明 keystore 文件有问题

**解决方案**:
1. 本地验证 keystore：
   ```bash
   keytool -list -v -keystore upload-keystore.jks -storepass yebeiying825
   ```
2. 如果本地也失败，需要重新生成 keystore：
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
3. 重新转换为 Base64 并更新 GitHub Secrets

### 原因 4: GitHub Actions 环境问题

**症状**: 本地可以正常使用，但 GitHub Actions 失败

**检查方法**:
1. 查看 GitHub Actions 日志中的所有调试步骤
2. 确认所有步骤都通过

**解决方案**:
1. 检查 GitHub Actions 的 Java 版本
2. 确认所有 secrets 都已正确设置
3. 重新运行 workflow

## 重新构建的步骤

1. **提交并推送代码**（包含调试步骤的 workflow）
   ```bash
   git add .github/workflows/build.yml
   git commit -m "Add debug steps for Android build"
   git push
   ```

2. **运行 GitHub Actions**
   - 进入 Actions 标签页
   - 选择 Build and Release workflow
   - 点击 Run workflow
   - 填写版本号和标签
   - 点击 Run workflow

3. **查看日志**
   - 等待构建完成
   - 点击失败的 job
   - 查看详细日志

4. **根据日志诊断问题**
   - 如果 "Verify keystore file" 失败：Base64 有问题
   - 如果 "Verify key.properties" 失败：Secrets 配置有问题
   - 如果 "Test keystore with keytool" 失败：密码或 keystore 有问题

## 本地测试命令

在本地测试 keystore 是否可用：

```bash
# 测试 keystore 文件
keytool -list -v -keystore upload-keystore.jks -storepass yebeiying825

# 测试特定别名
keytool -list -keystore upload-keystore.jks -storepass yebeiying825 -alias upload

# 查看 keystore 详细信息
keytool -list -v -keystore upload-keystore.jks -storepass yebeiying825
```

## 正确的 GitHub Secrets 配置

| Secret 名称 | 值 | 说明 |
|------------|-----|------|
| `ANDROID_KEYSTORE_BASE64` | 从 `upload-keystore-base64.txt` 复制 | Base64 编码的 keystore |
| `ANDROID_KEYSTORE_PASSWORD` | `yebeiying825` | Keystore 密码 |
| `ANDROID_KEY_PASSWORD` | `yebeiying825` | Key 密码 |
| `ANDROID_KEY_ALIAS` | `upload` | Key 别名 |

## 常见错误和解决方法

### 错误 1: "keystore password was incorrect"

**原因**: `ANDROID_KEYSTORE_PASSWORD` 的值不正确

**解决**: 确保值为 `yebeiying825`，无空格

### 错误 2: "key *** from store"

**原因**: `ANDROID_KEY_ALIAS` 的值不正确

**解决**: 确保值为 `upload`，不是 `release`

### 错误 3: "Failed to read key"

**原因**: keystore 文件损坏或 Base64 不完整

**解决**: 重新生成 keystore 并转换 Base64

## 联系支持

如果以上方法都无法解决问题，请提供以下信息：

1. GitHub Actions 日志（特别是调试步骤的输出）
2. 本地 `keytool -list -v -keystore upload-keystore.jks -storepass yebeiying825` 的输出
3. GitHub Secrets 的截图（隐藏敏感信息）
