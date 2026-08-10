# zhyi-packages Agent 约束

## 仓库定位

本仓库只是“包补充”仓库，主战场是上级目录的
`../nixos-config`。学习文档统一放在 `nixos-config/docs/learning/`，
不要在本仓库维护学习文档。

本仓库的职责：

- 收录 nixpkgs 没有的自用包；
- 保持与上游 `xddxdd/nur-packages` 的结构和工作流对齐；
- 通过 NUR、Attic、GitHub Actions 完成构建、缓存和自动更新。

## 禁止事项

- 不要在这里写学习文档或复制 `nixos-config` 的文档；
- 不要手改 `_sources/generated.nix` / `generated.json`，由 nvfetcher 生成；
- 不要手改根 `README.md`，它由 `pkgs/_meta/readme` 生成；
- 不要修改 `xddxdd` 或 `nix-community` 的上游仓库；
- 不要在本地或远端手动重复跑 workflow 能完成的检查；
- 不要把上游源码、二进制、`node_modules` 等 vendored 进仓库；
- 不要用 `scp` 同步仓库，遵循“本地 push，远端 pull”。

## 必须遵守的规范

- NUR 注册要求：根目录有 `default.nix`，内容以 MIT 发布；
- 每个包要有 `meta.description`、`homepage`、`license`、`maintainers`；
- 可执行程序要有 `meta.mainProgram`；
- GitHub release 来源的包要有 `meta.changelog`；
- 预编译二进制包要有 `meta.sourceProvenance`；
- 修改前先读对应上游或 NUR 文档，再动手；
- 包源码来源写在 `nvfetcher.toml`，不要在 `default.nix` 里手写 URL/hash
  绕过 `_sources`。

## 验证方式

- 代码变更后提交并推送，让 GitHub Actions 的 `build.yml` 自动验证；
- 只读 workflow 日志判断失败原因；
- `check-package-meta` 失败按工具输出修 meta；
- `test-nur-eval` 失败先确认是否已注册进 `nix-community/NUR/repos.json`。

## 提交规范

- 保持上游 commit 风格：`fix(scope): ...` / `docs: ...`；
- 只提交相关文件，不夹带无关改动；
- 本地 push 失败时可改用 HTTPS + `gh` 凭据推送。
