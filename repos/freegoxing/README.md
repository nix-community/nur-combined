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

开发环境、格式化器和检查目前配置在 `x86_64-linux` 上。百度网盘、ChatGPT、嘉立创EDA专业版和 QQ 使用各自目录中的 `update.sh` 检查版本。GitHub Actions 每天北京时间 11:17 检查版本并为更新创建 PR，可以在 Actions 页面手动触发；更新工作流不执行完整构建。

自动创建 PR 需要在 GitHub 仓库的 **Settings → Actions → General → Workflow permissions** 中启用 **Allow GitHub Actions to create and approve pull requests**。QQ 更新会跳过比当前版本更旧的官方版本。

## 许可证

仓库代码采用 [MIT 许可证](./LICENSE)。各软件包的许可由其自身的 `meta.license` 指定；百度网盘、嘉立创EDA专业版、QQ 和 Z-Library 桌面客户端为非自由软件。
