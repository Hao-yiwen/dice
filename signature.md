# 签名与发布

## macOS (Developer ID + 公证)

### 首次准备

1. 创建 Developer ID Application 证书：
   - 打开钥匙串访问 → 证书助理 → 从证书颁发机构请求证书 → 存储到磁盘
   - 登录 developer.apple.com → Certificates → + → Developer ID Application → 上传 CSR
   - 下载 .cer 文件，双击安装到钥匙串

2. 生成 App 专用密码：
   - 登录 account.apple.com → 登录与安全 → App 专用密码

3. 存储公证凭据到 Keychain：

```bash
xcrun notarytool store-credentials "dice-notarize" \
    --apple-id "your-apple-id@example.com" \
    --team-id "84F8R9TAQN" \
    --password "app-specific-password"
```

### 打包

```bash
export NOTARY_KEYCHAIN_PROFILE="dice-notarize"
./scripts/build-macos-dmg.sh
```

产物：`build/DiceGenerator.dmg`（已签名 + 公证），手动上传到 GitHub Releases。

---

## iOS (App Store)

1. 打开 Xcode → 选择 dice_ios scheme
2. Product → Archive
3. Distribute App → App Store Connect
