# GitHub Secrets 配置指南

## 问题分析

GitHub Actions 构建失败的原因是 keystore 密码不正确。

## 正确的配置信息

从 `android/app/key.properties` 文件中，我们找到了正确的配置：

```
storePassword=yebeiying825
keyAlias=upload
keyPassword=yebeiying825
```

## 需要配置的 GitHub Secrets

请进入 GitHub 仓库：**Settings** → **Secrets and variables** → **Actions**

### Secret 1: `ANDROID_KEYSTORE_BASE64`

**值**: 从 `upload-keystore-base64.txt` 文件复制

**获取方法**:
1. 运行转换脚本：`powershell -ExecutionPolicy Bypass -File scripts\convert-keystore.ps1`
2. 打开 `upload-keystore-base64.txt`
3. 复制全部内容（从 `MIIKpAIBAzCCCk4...` 开始，到 `...AgInEA==` 结束）
4. **不要**添加或删除任何字符
5. **不要**添加额外的空格或换行

### Secret 2: `ANDROID_KEYSTORE_PASSWORD`

**值**: `yebeiying825`

### Secret 3: `ANDROID_KEY_PASSWORD`

**值**: `yebeiying825`

### Secret 4: `ANDROID_KEY_ALIAS`

**值**: `upload`

⚠️ **重要**: 不是 `release`，而是 `upload`！

## 配置步骤

1. 进入 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 输入 Secret 名称和值
5. 点击 **Add secret**
6. 重复以上步骤，创建所有 4 个 Secrets

## 验证配置

配置完成后，重新运行 GitHub Actions 构建：

1. 进入 **Actions** 标签页
2. 选择 **Build and Release** workflow
3. 点击 **Run workflow**
4. 填写版本号（如 `0.0.3`）
5. 填写标签（如 `v0.0.3`）
6. 勾选 **Create a GitHub Release**
7. 点击 **Run workflow**

## 常见问题

### Q1: 为什么还是密码错误？

**A**: 请确保：
1. `ANDROID_KEYSTORE_PASSWORD` 的值是 `yebeiying825`
2. `ANDROID_KEY_PASSWORD` 的值是 `yebeiying825`
3. `ANDROID_KEY_ALIAS` 的值是 `upload`（不是 `release`）

### Q2: Base64 内容太长，复制不完整怎么办？

**A**:
1. 打开 `upload-keystore-base64.txt`
2. 使用 Ctrl+A 全选
3. 使用 Ctrl+C 复制
4. 粘贴到 GitHub Secret 中

### Q3: 如何确认配置正确？

**A**: 查看本地 `android/app/key.properties` 文件，确保 GitHub Secrets 中的值与该文件中的值一致。

## 本地测试

如果你想本地测试 keystore 是否可用：

```bash
keytool -list -v -keystore upload-keystore.jks -storepass yebeiying825
```

如果成功，会显示 keystore 的详细信息。

## 相关文件

- `android/app/key.properties` - 本地签名配置文件
- `upload-keystore.jks` - 本地 keystore 文件
- `upload-keystore-base64.txt` - Base64 编码的 keystore
- `scripts/convert-keystore.ps1` - Base64 转换脚本
- `.github/workflows/build.yml` - GitHub Actions 构建配置
