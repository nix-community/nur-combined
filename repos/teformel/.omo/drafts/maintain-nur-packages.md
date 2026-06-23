---
slug: maintain-nur-packages
status: drafting
intent: clear
pending-action: write .omo/plans/maintain-nur-packages.md
approach: 分四个阶段维护 NUR 仓库：1)清理非主分支+更新 flake.lock 2)修复已知问题（CI占位符、lingmo-statusbar浮动rev、lingmo-polkit-agent占位符hash、ww-manager版本更新）3)在VM上逐个构建测试所有16个包并修复失败 4)提交推送
---

# Draft: maintain-nur-packages

## Components (topology ledger)
| id | outcome | status | evidence path |
|----|---------|--------|---------------|
| C1 | 删除 GitHub 上 3 个非主分支 | active | git branch -a 输出 |
| C2 | 更新 flake.lock 到最新 nixpkgs | active | flake.lock 当前指向 2024-04-07 |
| C3 | 修复 CI workflow 占位符 | active | .github/workflows/build.yml:24,36 |
| C4 | 固定 lingmo-statusbar rev | active | pkgs/lingmo-statusbar/default.nix:10 |
| C5 | 修复 lingmo-polkit-agent 占位符 hash | active | pkgs/lingmo-polkit-agent/default.nix:12 |
| C6 | 更新 ww-manager 2.1.10→2.1.12 | active | pkgs/ww-manager/default.nix:5 |
| C7 | 构建测试所有 16 个包 | active | nix flake check --no-build 已通过 |
| C8 | 修复构建失败的包 | active | 需实际构建后确定 |
| C9 | 提交并推送所有更改 | active | — |

## Open assumptions (announced defaults)
| assumption | adopted default | rationale | reversible? |
|------------|----------------|-----------|-------------|
| CI nurRepo 名称 | teformel | 用户确认 | Yes |
| Cachix | 不配置 | 用户确认无 Cachix | Yes |
| 非 main 分支 | 全部删除 | 用户明确要求"直接删了" | No（删除后需重新创建） |
| flake.lock 更新 | 更新到最新 | "确保最新版"的意图 | Yes（可回退） |
| 构建失败修复 | 修复到能构建成功 | "每个包处于可用状态"的意图 | Yes |
| VM 构建 | 在 VM 上 nix build 逐个构建 | 用户无法在 Windows 上运行 nix | — |

## Findings (cited - path:lines)

**环境确认：**
- VM SSH: 192.168.70.128, 用户 maorila, 密钥 id_ed25519 — 连接成功
- VM Nix: 2.34.7, flakes 已启用, sandbox=true, 无 cachix
- VM 仓库: ~/nur-packages, 已 git pull 到 origin/main (7994f8c)
- VM 仓库有临时目录: tmp_lingmopolkitagent/, tmp_lingmoscreenlocker/, tmp_lingmosddmtheme/

**上游版本对比（全部已检查）：**
- clash-party: 当前 1.9.6 = 上游最新 v1.9.6（2026-06-21）→ 已最新
- ww-manager: 当前 2.1.10, 上游最新 v2.1.12 (commit bfaf560c0061) → 需更新
- lib_lingmo: 65138ba3... = 上游最新 → 已最新
- lingmoui: 87ed8ecd... = 上游最新 → 已最新
- lingmo-core: 50f42d6c... = 上游最新 → 已最新
- lingmo-settings: 78c6f148... = 上游最新 → 已最新
- lingmo-dock: 4f0f30a0... = 上游最新 → 已最新
- lingmo-launcher: eac296ec... = 上游最新 → 已最新
- lingmo-desktop: 0c2db3a0... = 上游最新 → 已最新
- lingmo-daemon: 61016244... = 上游最新 → 已最新
- lingmo-filemanager: c0ec3873... = 上游最新 → 已最新
- lingmo-kwin-plugins: 98869700... = 上游最新 → 已最新
- lingmo-screenlocker: d16aa1d2... = 上游最新 → 已最新
- lingmo-polkit-agent: 93b81233... = 上游最新（但 hash 是占位符 AAAA...）→ 需修复 hash
- lingmo-sddm-theme: 3b384083... = 上游最新 → 已最新
- lingmo-statusbar: rev="main"（浮动）→ 需固定到 ee5d766075b145fd46fdcdebd87121208251a8ae

**求值状态：** nix flake check --no-build 全部 16 包通过 ✓

**已知问题：**
- flake.lock:5 — lastModified 2024-04-07（非常旧）
- pkgs/lingmo-polkit-agent/default.nix:12 — hash="sha256-AAAA..."（占位符）
- pkgs/lingmo-statusbar/default.nix:10 — rev="main"（浮动，不固定）
- .github/workflows/build.yml:24,36 — nurRepo="<YOUR_REPO_NAME>", cachixName="<YOUR_CACHIX_NAME>"
- GitHub 上 3 个非主分支：dependabot/github_actions/actions/checkout-7, dependabot/github_actions/cachix/cachix-action-17, dependabot/nix/nixpkgs-3e41b24

## Decisions (with rationale)

1. **先修复已知问题再构建测试** — 避免在已知坏的包上浪费时间
2. **flake.lock 更新在构建测试之前** — 确保测试的是最新 nixpkgs 下的构建
3. **构建按依赖顺序** — 基础包优先，依赖包后续
4. **hash 修复用 nix-prefetch** — 比构建失败获取 hash 更快
5. **非主分支全部删除** — 用户明确要求

## Scope IN
- 删除 GitHub 上所有非 main 分支
- 更新 flake.lock 到最新 nixpkgs
- 修复 CI workflow（nurRepo=teformel, 移除 cachix 配置）
- 固定 lingmo-statusbar 的 rev
- 修复 lingmo-polkit-agent 的 hash
- 更新 ww-manager 到 2.1.12
- 在 VM 上构建测试所有 16 个包
- 修复构建失败的包
- 提交并推送所有更改

## Scope OUT (Must NOT have)
- 不添加新包
- 不删除现有包（包括 example-package）
- 不修改包的功能逻辑（只做版本更新和构建修复）
- 不配置 cachix
- 不修改 NixOS 系统配置

## Open questions
无 — 用户已确认所有决策点。

## Approval gate
status: awaiting-approval
