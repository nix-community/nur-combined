# 仓库约定

这是独立 NUR 软件包仓库，不存放主机配置、凭据或个人运行数据。

仓库以 `nix-community/nur-packages-template` 为基础，保留其 `ci.nix`、
库/模块/overlay 入口和 CI 结构。创建 GitHub 仓库时使用该模板生成，不 fork。

- 用中文回复；版本管理优先使用 `jj`。
- `default.nix` 接受调用者提供的 `pkgs`，包定义放在 `pkgs/<name>/default.nix`。
- Flake 和传统 NUR 入口使用同一组包定义。
- 固定源码版本和下载哈希；DBX 使用官方预编译发布文件。
- 修改后先 `nix fmt` 和局部求值；构建、测试仅覆盖受影响的包。
- VType 的引擎、账户和个人词库留在用户目录；迁移包定义不运行初始化或重启输入法。
