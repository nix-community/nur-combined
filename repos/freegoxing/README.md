# nur-packages

我的个人 [NUR](https://github.com/nix-community/NUR) 软件包仓库，支持通过 Nix Flake 使用。

## 软件包

| 包名 | 说明 | 平台 |
| --- | --- | --- |
| `baidunetdisk` | 百度网盘 Linux 客户端（非自由软件） | `x86_64-linux` |
| `lceda-pro` | 嘉立创EDA专业版 Linux 客户端（非自由软件） | `x86_64-linux` |
| `qq` | QQ 客户端（非自由软件） | `x86_64-linux` |


百度网盘使用上游的 Debian 安装包，通过 FHS 环境运行。启动脚本会传入 `--no-sandbox`。

嘉立创EDA专业版使用官方 Linux 客户端，保留上游的发行许可文件。首次使用可能需要导入官方激活文件。

QQ 基于 nixpkgs 的打包方式，构建时通过腾讯签名接口获取下载地址；版本和哈希由本仓库独立维护。腾讯可能下架旧版本，已安装的 Home Manager generation 会保留对应的本地 Nix store 闭包；清理旧 generation 后无法保证旧版本仍可重新下载。本仓库的公开 Cachix 构建流程排除非自由软件，不会缓存 QQ。

## 开发

```sh
nix develop                 # 进入开发环境并启用 Git hooks
nix fmt                     # 格式化 Nix 和 shell 文件
nix flake check             # 运行仓库检查
```

开发环境、格式化器和检查目前配置在 `x86_64-linux` 上。各包使用各自目录中的 `update.sh` 检查版本。GitHub Actions 每天北京时间 11:17 检查版本并为更新创建 PR，可以在 Actions 页面手动触发；更新工作流不执行完整构建。

自动创建 PR 需要在 GitHub 仓库的 **Settings → Actions → General → Workflow permissions** 中启用 **Allow GitHub Actions to create and approve pull requests**。QQ 更新会跳过比当前版本更旧的官方版本。

## 许可证

仓库代码采用 [MIT 许可证](./LICENSE)。各软件包的许可由其自身的 `meta.license` 指定；百度网盘、嘉立创EDA专业版和 QQ 为非自由软件。
