# 幸运骰子

![macOS](https://img.shields.io/badge/macOS-13.0+-00979D?logo=apple&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-16.0+-000000?logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-0051C3?logo=swift&logoColor=white)

一个简单的幸运骰子应用，支持 macOS 状态栏和 iOS 设备。

## 下载安装

### macOS

[下载最新版本](https://github.com/Hao-yiwen/dice/releases/)

### iOS

目前 iOS 版本需要自行克隆代码并使用 Xcode 打包安装。

## 功能特点：

- 随机掷骰：快速生成随机幸运点数
- iOS 小组件支持：方便快捷掷骰

## 安装说明：

### macOS

- 下载 QRCodeGenerator.dmg
- 打开 DMG 文件
- 将应用拖入 Applications 文件夹
- 首次运行时右键点击应用选择"打开"

### iOS

1. 克隆项目代码
2. 使用 Xcode 打开项目
3. 选择开发者账号
4. 连接设备并构建运行

## 常见问题

如果在 macOS 上提示"无法打开应用程序"，请尝试：

1. 右键点击应用选择"打开"
2. 在系统设置的安全性与隐私中允许打开
3. 如果仍然无法打开，请在终端中运行：

```bash
xattr -cr /Applications/dice.app
```

## 系统要求：

- macOS 13.0 或更高版本
- ios 16.0 或更高版本

## 预览

<img src="showcase/dice.png" width="50%" style="display:inline-block;" />

<img src="showcase/dice_ios.png" width="30%" style="display:inline-block; margin-right: 20px;" /><img src="showcase/dice_ios_widget.png" width="30%" style="display:inline-block;" />

## 支持我的工作

如果这个项目对你有帮助，可以请我喝杯咖啡 ☕️

<details>
<summary>
  <img src="https://img.shields.io/badge/Buy_Me_A_Coffee-支付宝-blue?logo=alipay" alt="Buy Me A Coffee" style="cursor: pointer;">
</summary>
<br>
<img src="showcase/alipay_qr.jpg" alt="支付宝收款码" width="300">
</details>
