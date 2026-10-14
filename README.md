# 夸克链接转换 iOS App

这是一个纯 SwiftUI 工程，功能是：粘贴一段带文案和夸克网盘链接的内容，自动识别一个或多个分享链接，将域名替换成 `pan.xiaozyi.xyz`，其余文案、换行、提取码参数保持不变，然后复制完整结果。

## 使用 GitHub Actions 构建 IPA

工程已包含 `QuarkLinkConverter.xcodeproj` 和 `.github/workflows/build-ipa.yml`。GitHub 的 macOS runner 会自动安装 Xcode、归档并上传未签名 IPA，适合导入 TrollStore。

1. 在 GitHub 新建一个空仓库。
2. 将本目录中的**所有内容**上传到仓库根目录，确保 `QuarkLinkConverter.xcodeproj` 和 `.github` 位于根目录。
3. 打开仓库的 `Actions` 页面，选择 `Build unsigned TrollStore IPA`。
4. 点击 `Run workflow`，等待任务完成。
5. 打开完成的任务，在底部 `Artifacts` 下载 `QuarkLinkConverter-unsigned-ipa`。
6. 解压得到 `QuarkLinkConverter-unsigned.ipa`，通过 TrollStore 安装。

工作流也会在推送到 `main` 分支时自动运行。此工程不需要 Apple 开发者证书，生成的是未签名包；普通 App Store 安装不适用，TrollStore 可使用该包。

## 使用

输入可以是普通文案、多个链接、带 `?pwd=` 的链接或混合内容。App 会保留原始文案，只把符合 `/s/分享码` 格式的夸克链接改成：

```text
https://pan.xiaozyi.xyz/s/分享码
```

`pan.xiaozyi.xyz` 可以在 App 的域名输入框中改成其他已部署的 Worker 域名。
