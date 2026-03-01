---
description: Update all packages to their latest versions
---

批量更新所有包到最新版本。

## 更新流程

对于 `default.nix` 中的每个包，依次执行：

1. **检查上游** - 访问 `meta.homepage` 或源码仓库，查找最新 release/tag
2. **对比版本** - 如果有新版本，继续；否则跳过
3. **更新版本号** - 修改 `version = "..."`
4. **更新 hash** - 使用 `lib.fakeHash` 占位，构建获取真实 hash
5. **测试构建** - `nix-build -A <package>`
6. **记录结果** - 成功/失败/跳过

## 包列表

从 `default.nix` 获取所有包：
- fortune-mod-zh
- fortune-mod-hitokoto
- JMComic-qt
- picacg-qt
- mikusays
- sddm-eucalyptus-drop
- wechat-web-devtools-linux
- zsh-url-highlighter
- waybar-vd
- mihomo-smart
- Fladder
- StartLive
- bilibili_live_tui

## 执行策略

1. 先检查所有包的上游版本（并行）
2. 列出有更新的包，等待确认
3. 逐个更新并测试
4. 最后汇总报告

## 输出格式

```
| 包名 | 当前版本 | 最新版本 | 状态 |
|------|----------|----------|------|
| waybar-vd | 0.1.1 | 0.2.0 | 已更新 |
| mihomo-smart | d45278b | a1b2c3d | 已更新 |
| JMComic-qt | 1.3.0 | 1.3.0 | 无更新 |
| Fladder | 0.8.1 | 0.9.0 | 构建失败 |
```

## 注意事项

- 某些包使用 git commit hash 而非版本号（如 mihomo-smart）
- AppImage 包需要检查 GitHub Releases
- Flutter 包可能需要同时更新 `gitHashes`
- 构建失败的包标记但不阻塞其他包

## 开始更新

读取 `default.nix` 和各包文件，检查上游版本，然后逐个更新。
