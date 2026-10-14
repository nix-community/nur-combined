---
name: fix-hydra-build-failure
description: Fix Hydra build failures and evaluation errors in this NUR repository. Use when asked to fix Hydra failures, inspect failed jobs, or repair packages from the latest lantian/nur-packages evaluation.
---

# 修复 Hydra 构建失败

在 Pi 中用 `/skill:fix-hydra-build-failure` 调用；新增或修改本技能后用 `/reload` 重新加载。

## 先确认现场

1. 先完整读取仓库根目录的 `AGENTS.md`；输出截断时继续读取直到文件结束。遵守其中的包规则、构建属性分组，并检查本技能「已知易错点：fetchPnpmDeps 哈希在 GitHub Actions 上不可复现」中的警告，不复制历史测量作为当前结论。
2. 执行 `pwd`、`git rev-parse --show-toplevel`、`git status --short`，检查实际源码和配置，不凭记忆规划。记录并保留用户已有改动；未经要求，不批量更新 `flake.lock`，不提交或推送。

## 取得完整失败清单

1. 新访问 <https://hydra.lantian.pub/jobset/lantian/nur-packages>，从 `latest-eval` 取得最新 eval ID。记录 ID 和来源链接，后续清单固定使用该 eval，不用历史结果代替。
2. 同时检查以下地址；请求跟随重定向（如 `curl -fSL`），如有分页则读完所有页：
   - `https://hydra.lantian.pub/eval/<id>/errors?full=1`：评估错误，包括未进入 build 列表的 job。求值阶段失败（如引用已删除/改名的 nixpkgs 属性、`throw` 等）的 job 在 job 列表里可能根本不出现或只显示为空，只会出现在 jobset 的 Errors 标签页；这类错误不会出现在构建失败列表里，容易漏修。
   - `https://hydra.lantian.pub/eval/<id>/builds`：设置 `Accept: application/json`，取得全部构建及其状态。
3. 区分完成和未完成的构建：已完成的 `buildstatus = 0` 为成功，非零状态按 Hydra 含义分类（1 为 Failed，2 为 Dependency failed）；未完成、排队或运行中的构建标为 pending，不当成已证实失败。清单包括别名 job（如 `uncategorized-`），不能只看 Jobs 标签页，因为其默认只列 canonical 名。评估错误与求值成功后的构建失败（`Failed` / `Dependency failed`）都要逐个修复。
4. 对依赖失败（如 `it-tools: Dependency failed`）打开 `https://hydra.lantian.pub/build/<id>/nixlog/<n>`，跟随重定向读到真正失败的依赖日志，记录最终链接和错误。按根因归并重复 job，但保留所有受影响 job、平台与 build ID。
5. 读取仓库实际 Hydra/flake 配置、`pkgs/default.nix` 及相关映射，确认 job 对应的真实包属性和文件；不要靠删除 job 名字符串前缀猜属性。记录 Hydra 输入版本与当前工作区的差异。

## 分派、复现和修复

1. 将独立根因分派给 worker，明确各自互不重叠的允许编辑路径、受影响属性、日志、复现和验证命令。相关兄弟包归同一 lane；若新增范围与另一 lane 冲突，先由主代理重新分配，不跨范围改文件。
2. 遵守用户最新指定的 provider/model、并发数和分配方式。未指定模型时读取 `PI_PROVIDER`、`PI_MODEL`，每次分派显式设置 `model = "<PI_PROVIDER>/<PI_MODEL>"`；变量缺失时报告阻塞，不猜模型。额度或余额错误出现后停止相关分派并报告，等待用户指示，不重试耗尽模型或自行切换。
3. 每个 worker 先在未应用修复的相关基线上实际复现失败，记录命令、输入与输出，再做最小修复；基线不能复现时报告差异或阻塞，不声称已证明根因。检查全部同机制兄弟包，对证实受影响的包一起修复。
4. 遵守 `AGENTS.md` 的打包规则，不引入 import-from-derivation（IFD）。新增包所需文件用明确路径的 `git add` 暂存，使 Git flake 可见；不批量暂存用户改动。
5. worker 只改分配文件并返回证据。共享文档（包括 `AGENTS.md`）由主代理汇总后按需更新，不让多个 worker 同时编辑。

## 逐项验证

- 按仓库映射使用正确属性，对每个受影响包运行真实构建：`nix build '.#<实际属性>' --no-link`；分组包必须带正确前缀，并验证受影响平台/变体。等待命令结束并检查退出码和日志。
- 评估错误还需对原失败求值目标执行禁止 IFD 的检查，例如 `nix eval --option allow-import-from-derivation false --raw '.#<实际属性>.drvPath'`；必要时按仓库 Hydra 配置复查相关 job 的求值。不能用只求值未触发错误的字段代替。
- 失败涉及启动、运行时路径或设备功能时，实际运行构建产物并测试对应用户入口；需要 GUI/隔离环境时遵守项目环境规则。测试服务必须等待就绪、测试完成后检查结果并停止。
- 补丁 dry-run、源码 fetch、依赖预取或单独求值只证明各自步骤，不是完整构建成功。不可测试的平台、超时、网络/硬件限制和 pending 都保留为未完成项，不做替代性“通过”。
- 主代理检查所有 lane 的实际 diff、日志和范围，补做集成验证；最后复查 `git status --short`，确认未覆盖用户改动、无越界文件。

## 最终报告

列出 eval ID、jobset/errors/builds/根因日志来源链接、受影响 job 与真实属性、根因、修改路径；逐项列出检查命令、退出码及通过/失败结果，包含所有跳过、超时、pending 和阻塞。

明确区分“本地已验证”与“Hydra 尚未重跑”；未取得新 Hydra 结果不得声称 Hydra 已通过。只报告实际执行所得证据。

用户要求提交时，整仓库性修复可用描述性标题，如 `Fix Hydra build failures (eval <id>)`。

## 已知易错点：fetchPnpmDeps 哈希在 GitHub Actions 上不可复现

it-tools 的 `pnpmDeps` 哈希会被 auto-update 反复改错（`ba9c1129` 手工修正后 `6362f6d4` 又改回错误值）。已定位为 **GHA runner 环境导致的 pnpm store 生成竞态**，不是 nixpkgs 版本差异：

- 从 GHA auto-update run 日志（`gh run view <id> --repo xddxdd/nur-packages --log`）确认该 run 用 `NIX_PATH=nixpkgs=channel:nixos-unstable`，而 `channels.nixos.org/nixos-unstable/git-revision` 当时和现在都是 `a7868a7…`，即与 flake.lock 钉住的 nixpkgs 完全相同。
- 用 channel a7868a7（默认 config）和 flake（带 allowUnfree 等 config）分别求值 `it-tools.pnpmDeps.drvPath`，得到同一个 drv `42x3kyifb9ds…`。同一个 drv、同一个 pnpm 11.27.0 / node 24.21.0 / sqlite 3.53.3，GHA 算出 `sha256-qfoBr6…`，兰天构建机算出 `sha256-Qn2DCJ…`。
- 即纯粹是构建环境/时序差异（nixpkgs issue #422889、#484013），GHA 产物在 hash mismatch 后即被丢弃，不在任何 store/cache 里，无法事后 diff。

**实测只影响 `fetcherVersion = 4`（pnpm 11）：**

- it-tools 用 `pnpm_11` + `fetcherVersion = 4`，GHA 与兰天哈希不一致，已实测复现。改用 `pnpm_10` + `fetcherVersion = 3` 不可行：it-tools 的 lockfile（pnpm 11 生成）在 `patchedDependencies:` 里存的是 pnpm 11 的补丁哈希，pnpm 10.34.5 校验时报 `ERR_PNPM_LOCKFILE_CONFIG_MISMATCH`。因此 it-tools 保持 `nix-update-script { extraArgs = [ "--src-only" ]; }`，auto-update 只更新 version/src，**不写 GHA 上算出的 pnpmDeps 哈希**；版本升级后哈希变旧、Hydra 报 FOD hash mismatch，需在可信构建机上手工刷新。
- axonhub 用 `pnpm_10` + `fetcherVersion = 3`，不受影响：GHA 算出的 `sha256-Juge/qz…` 与本地/远程构建机一致（pnpm 10.34.5 已含 10.29.0 的 `initStore` 修复）。历史上 axonhub 出现过的 vendorHash 被污染是 `passthru.pnpmDeps` 缺失导致的字段错位（见 commit `0aa06b4a`，由 `75b86aff` 修复），与哈希不可复现无关。因此 axonhub 保持普通 `nix-update-script { extraArgs = [ "--version" "unstable" ]; }`。
