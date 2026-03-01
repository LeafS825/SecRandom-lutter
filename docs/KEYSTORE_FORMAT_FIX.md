# Keystore 格式问题解决方案

## 问题分析

错误信息显示：
```
keytool error: java.io.IOException: keystore password was incorrect
Caused by: java.security.UnrecoverableKeyException: failed to decrypt safe contents entry: javax.crypto.BadPaddingException: Given final block not properly padded.
```

这个错误表明 **keystore 格式不匹配**。Java 默认尝试使用 PKCS12 格式读取 keystore，但你的 keystore 可能是 JKS 格式，或者 keystore 文件本身有问题。

## 解决方案

### 方案 1: 重新生成 Keystore（推荐）

这是最简单和最可靠的解决方案。

#### 步骤 1: 生成新的 Keystore

运行以下命令：
```bash
scripts\generate-keystore.bat
```

这会：
1. 备份现有的 keystore 文件
2. 生成一个新的标准 JKS 格式 keystore
3. 使用密码 `yebeiying825` 和别名 `upload`

#### 步骤 2: 重新生成 Base64

```bash
powershell -ExecutionPolicy Bypass -File scripts\regenerate-base64.ps1
```

#### 步骤 3: 更新 GitHub Secrets

进入 GitHub 仓库：**Settings** → **Secrets and variables** → **Actions**

更新以下 Secret：
- `ANDROID_KEYSTORE_BASE64`: 从 `upload-keystore-base64.txt` 复制全部内容

其他 Secrets 保持不变：
- `ANDROID_KEYSTORE_PASSWORD`: `yebeiying825`
- `ANDROID_KEY_PASSWORD`: `yebeiying825`
- `ANDROID_KEY_ALIAS`: `upload`

#### 步骤 4: 提交并推送代码

```bash
git add .
git commit -m "Regenerate keystore and update GitHub Actions"
git push
```

#### 步骤 5: 重新运行 GitHub Actions

1. 进入 **Actions** 标签页
2. 选择 **Build and Release** workflow
3. 点击 **Run workflow**
4. 填写版本号和标签
5. 点击 **Run workflow**

### 方案 2: 转换现有 Keystore 格式

如果你想保留现有的 keystore，可以尝试转换格式。

#### 步骤 1: 转换为 PKCS12 格式

```bash
keytool -importkeystore -srckeystore upload-keystore.jks -destkeystore upload-keystore.p12 -deststoretype PKCS12 -srcstorepass yebeiying825 -deststorepass yebeiying825
```

#### 步骤 2: 转换回 JKS 格式

```bash
keytool -importkeystore -srckeystore upload-keystore.p12 -srcstoretype PKCS12 -destkeystore upload-keystore-new.jks -deststoretype JKS -srcstorepass yebeiying825 -deststorepass yebeiying825
```

#### 步骤 3: 替换旧文件

```bash
move upload-keystore.jks upload-keystore-old.jks
move upload-keystore-new.jks upload-keystore.jks
```

#### 步骤 4: 重新生成 Base64 并更新 GitHub Secrets

参考方案 1 的步骤 2-5。

### 方案 3: 修改 GitHub Actions 指定格式

我已经在 `.github/workflows/build.yml` 中添加了 `-storetype JKS` 参数。

如果重新生成 keystore 后仍然失败，可以尝试修改 Android 的 build.gradle.kts 文件。

#### 修改 build.gradle.kts

在 `android/app/build.gradle.kts` 文件中，找到 `signingConfigs` 部分，添加 storeType：

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String?
        keyPassword = keystoreProperties["keyPassword"] as String?
        storeFile = keystoreProperties["storeFile"]?.let { file(it.toString()) }
        storePassword = keystoreProperties["storePassword"] as String?
        storeType = "jks"  // 添加这一行
    }
}
```

## 验证 Keystore

生成新的 keystore 后，使用以下命令验证：

```bash
# 测试 keystore 文件
keytool -list -v -keystore upload-keystore.jks -storepass yebeiying825 -storetype JKS

# 测试特定别名
keytool -list -keystore upload-keystore.jks -storepass yebeiying825 -alias upload -storetype JKS
```

如果成功，会显示 keystore 的详细信息。

## 常见问题

### Q1: 为什么要重新生成 keystore？

A: 现有的 keystore 可能格式不正确或已损坏。重新生成可以确保使用标准的 JKS 格式，避免兼容性问题。

### Q2: 重新生成 keystore 会影响已发布的应用吗？

A: 不会影响已发布的应用。但如果你之前已经发布了使用旧 keystore 签名的应用，新版本必须使用相同的 keystore 才能覆盖安装。如果你没有发布过应用，重新生成是安全的。

### Q3: 如何备份旧的 keystore？

A: 运行 `scripts\generate-keystore.bat` 时会自动创建备份文件 `upload-keystore.jks.backup`。

### Q4: 如果重新生成后还是失败怎么办？

A:
1. 检查 GitHub Actions 日志中的调试步骤
2. 确认所有 GitHub Secrets 都正确配置
3. 尝试方案 3，修改 build.gradle.kts 指定 storeType
4. 如果仍然失败，提供完整的 GitHub Actions 日志以便进一步诊断

## 推荐流程

1. ✅ 运行 `scripts\generate-keystore.bat` 生成新的 keystore
2. ✅ 运行 `scripts\regenerate-base64.ps1` 生成 Base64
3. ✅ 更新 GitHub Secret `ANDROID_KEYSTORE_BASE64`
4. ✅ 提交并推送代码
5. ✅ 重新运行 GitHub Actions
6. ✅ 查看构建日志，确认成功

## 相关文件

- `scripts/generate-keystore.bat` - 生成新 keystore 的脚本
- `scripts/regenerate-base64.ps1` - 生成 Base64 的脚本
- `upload-keystore.jks` - keystore 文件
- `upload-keystore-base64.txt` - Base64 编码的 keystore
- `.github/workflows/build.yml` - GitHub Actions 构建配置
- `android/app/build.gradle.kts` - Android 构建配置
