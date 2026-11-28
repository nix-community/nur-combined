---
name: fix-github-actions-failure
description: Locate failed GitHub Actions runs for the nur-packages auto-update workflow (xddxdd/nur-packages), pull the full log, map each failure marker back to its package and update mechanism, and start triage before touching any file. Use when asked why auto-update failed, to find or inspect a GitHub Actions run log, to work out which packages a failed nightly round broke, or to start investigating an `auto: update packages` failure.
---

# 定位 GitHub Actions 失败日志并开始调查

在 Pi 中用 `/skill:fix-github-actions-failure` 调用；新增或修改本技能后用 `/reload` 重新加载。

本技能只负责「找到日志、读对日志、定位到包」。修复与验证流程见 `fix-hydra-build-failure`，打包与更新脚本规则以仓库根 `AGENTS.md` 为准。

## 取得 run 和完整日志

```bash
gh run list --repo xddxdd/nur-packages --workflow auto-update.yml --limit 20 \
  --json databaseId,conclusion,headSha,createdAt,displayTitle
```

对结论不是 `success` 的 run：

```bash
mkdir -p .scratch
gh run view <id> --repo xddxdd/nur-packages --log-failed > .scratch/run-<id>.log
gh run view <id> --repo xddxdd/nur-packages --json jobs      # 哪些步骤执行、哪些 skipped
```

- `--log-failed` 只给失败步骤，auto-update 的失败步骤固定是 `Update packages`，够用；要看失败前的上下文才用 `--log`（几十万行，先落盘再反复 grep，别重复拉取）。
- 日志每行是 `job<TAB>step<TAB>timestamp<TAB>content`，grep 时用 `cut -f4-` 去掉前缀。
- 日志落 `.scratch/run-<id>.log`，不写 `/tmp`。
- 不用 `api.github.com`（匿名限流 60 req/h）；`gh` 走已认证 API。

## 读日志的锚点

按顺序 grep，先拿清单再读细节：

| 锚点 | 含义 |
| --- | --- |
| `Finished with failures:` | 唯一的权威失败清单，非允许失败 |
| `Allowed failures:` | 命中 `tools/auto-update-allowed-failures.txt` 的包 |
| `All update scripts finished successfully.` | 整轮全绿 |
| `>>> .*: FAILED` | 单包失败 |
| `>>> .*: updating (` | 该包探测到的新版本 |
| `Executing pkgs/` | 独立 `update-standalone.*` 脚本开始 |

三行汇总都没有，说明流程在中途异常退出（`nix flake update`、README 生成等），单独看尾部。

两类入口的日志结构不同：

- `helpers/update.nix`（`passthru.updateScript` 包）并发跑（`UPDATE_PACKAGE_JOBS`，默认 `nproc`），每个包的输出缓冲后整块 `cat` 出来，紧接着同一子 shell 打印 `>>> <attr>: done|FAILED`。所以**失败输出在该包 FAILED 行的上方**，从 FAILED 行向上读到上一个 `>>> …: done|FAILED` 就是完整块；按 `updating (` 行往下找会读到别的包。
- `commands.nix` 的 find 循环（`update-standalone.*`）顺序执行、不缓冲，块紧跟在 `Executing pkgs/…` 下面，下一条 `Executing` 之前没有 `>>> …: FAILED` 就是成功。注意 `Executing npmConfigHook` 这类是 stdenv 钩子输出，不是脚本，按 `Executing pkgs/` 过滤。

同一行头可能装两种形态：`uncategorized.cleanuparr`（attr 路径）或 `pkgs/…/update-standalone.sh`（脚本路径）。

## 映射到包和更新机制

attr 前缀到目录一一对应：`uncategorized.` → `pkgs/uncategorized/`，`nginx-modules.` → `pkgs/nginx-modules/`，`kernel-modules.` → `pkgs/kernel-modules/`，`python3Packages.` → `pkgs/python-packages/`，`lantianCustomized.` → `pkgs/lantian-customized/`，`asteriskDigiumCodecs.<ver>.` → `pkgs/asterisk-digium-codecs/<ver>/`。深一层的包要逐级引用，别猜属性名。

然后确认它靠什么更新，三者修法不同：`passthru.updateScript`（`nix-update-script` / `unstableGitUpdater`）、包内 `update-standalone.*`、生成式 lockfile 的自定义 `update.sh`。先读包文件，再判断失败落在哪一步。

## 先确认没有半截提交

commit 步骤是 `if: success()`，run 失败就不提交，master 停在旧状态：失败的版本推进只存在于 CI 内存里，本地 `git log` 不会有，也不该手工把 CI 报出的版本/哈希抄进文件。用 `gh run view <id> --json headSha` 与 `git log --oneline -1` 对齐基线，再看该包目录的提交历史确认上次成功更新到哪。

rerun 或 dispatch workflow 不是修复手段，只能用于修复后在 master 上确认。

## 本地复现

```bash
./tools/update-package <attr>          # passthru 包，与 CI 同一条代码路径
bash -c <包内 update-standalone 脚本>   # 直接执行脚本本体，才能走 nix-shell shebang
```

两者都把 `NIX_PATH` 钉到 flake.lock 的 nixpkgs，与 CI 求值一致。

## 失败类型与签名

- **上游消失或改名**：`Repository not found`、`fatal: repository … not found`、`could not read Username`。脚本在 `set -euo pipefail` 下探测第一步就 die。修法是让「仓库不可达」这一种情况带诊断 `exit 0`，而不是进允许失败清单。
- **nix-update 拿不到哈希**：`UpdateError`、`failed to retrieve hash`、`Could not find attribute`，stderr 里没有 `got:` 行。常见于上游要求更新的工具链（`go.mod` 要求的 Go 补丁版本高于 nixpkgs），或依赖树 FOD 先失败导致哈希抓错。
- **源码/patch 在预取阶段就挂**：`substituteStream() in derivation <pkg>: ERROR: pattern … doesn't match`、`Hunk #N FAILED`、`patch unexpectedly ends in middle of line`。`fetchNpmDeps`、dotnet fetch-deps 会套用 `patches`/`postPatch`，补丁失效在这里先暴露，比完整构建便宜。
- **允许清单**：`>>> …: FAILED (allowed)` 是设计行为，不要「修」。
- `WARN:` 后跟 `exit 0` 是更新脚本的主动跳过，不是失败。

## 调查完再动手

把 run ID、head SHA、失败步骤、`Finished with failures:` 清单、每个包的失败签名和对应文件记下来，再改代码。改完至少做到：本地复现命令退出码为 0，真实构建通过，`./tools/update-package <attr>` 不再改写文件或写出正确值。
