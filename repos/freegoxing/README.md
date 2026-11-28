# nur-packages

我的个人 [NUR](https://github.com/nix-community/NUR) 软件包仓库，支持通过 Nix Flake 使用。

## 软件包

| 包名 | 说明 | 平台 |
| --- | --- | --- |
| `baidunetdisk` | 百度网盘 Linux 客户端（非自由软件） | `x86_64-linux` |
| `lceda-pro` | 嘉立创EDA专业版 Linux 客户端（非自由软件） | `x86_64-linux` |


百度网盘使用上游的 Debian 安装包，通过 FHS 环境运行。启动脚本会传入 `--no-sandbox`。

嘉立创EDA专业版使用官方 Linux 客户端，保留上游的发行许可文件。首次使用可能需要导入官方激活文件。


## 开发

```sh
nix develop                 # 进入开发环境并启用 Git hooks
nix fmt                     # 格式化 Nix 和 shell 文件
nix flake check             # 运行仓库检查
```

开发环境、格式化器和检查目前配置在 `x86_64-linux` 上。百度网盘和嘉立创EDA专业版使用各自目录中的 `update.sh` 检查版本和源码 SHA256。GitHub Actions 每天北京时间 11:17 检查并为更新创建 PR，可以在 Actions 页面手动触发；更新工作流不执行完整构建。

更新脚本会保存安装包的 ETag／Last-Modified 和实测 SHA256。缓存 hash 与包定义一致时，可用 HTTP 条件请求，服务器返回 304 则不下载安装包正文。首次运行、缓存失效或冲突、版本变化、距上次完整下载已满七天，以及服务器忽略条件请求时，都会完整下载；304 不会延后七天期限。

完整下载会检查文件长度、ZIP 完整性及 CRC，并在服务器提供 `x-obs-content-sha256` 时核对该值。DEB 仅检查文件头和下载长度。同版本 hash 变化时脚本会报错并保留原包定义和缓存，需人工核查下载来源、CDN 差异与安装包内容后更新 hash。版本升级则正常更新。响应头中的 SHA256 不是独立签名，不能证明不同 CDN 的内容一致。

GitHub Actions 会跨运行缓存这些元数据。手动触发时勾选 `force_hash` 可强制完整下载，但不能保证绕过 CDN；本地运行示例：

```sh
nix shell nixpkgs#python3 nixpkgs#curl nixpkgs#jq -c bash pkgs/lceda-pro/update.sh
nix shell nixpkgs#python3 nixpkgs#curl nixpkgs#jq -c env UPDATE_FORCE_HASH=1 bash pkgs/lceda-pro/update.sh
```

本地缓存默认为 `${XDG_CACHE_HOME:-$HOME/.cache}/nur-package-updates`，可用 `UPDATE_CACHE_DIR` 指定其他目录。仅在下载完整且文件格式符合预期后，才会一起写入 version 和 hash；网络失败不会留下仅更新版本号的包定义。运行 `python3 -m unittest discover -s tests -v` 可验证缓存、强制复核和失败处理逻辑。

自动创建 PR 需要在 GitHub 仓库的 **Settings → Actions → General → Workflow permissions** 中启用 **Allow GitHub Actions to create and approve pull requests**。更新脚本会拒绝降级到更旧的官方版本。

## 许可证

仓库代码采用 [MIT 许可证](./LICENSE)。各软件包的许可由其自身的 `meta.license` 指定；百度网盘、嘉立创EDA专业版、QQ 和 Z-Library 桌面客户端为非自由软件。
