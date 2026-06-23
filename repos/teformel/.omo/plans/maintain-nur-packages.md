# maintain-nur-packages - Work Plan

## TL;DR (For humans)

**你将得到：** 一个完全最新且所有包都能成功构建的 NUR 仓库。具体包括：删除无关分支、更新过期依赖锁、修复 3 个有问题的包、在虚拟机上逐个构建验证全部 16 个包。

**为什么这样做：** 仓库中有 3 个包存在问题（一个版本过期、一个浮动引用、一个哈希占位符），依赖锁文件过期 2 年多，还有之前工具创建的多余分支。需要逐一修复并在虚拟机上验证构建。

**不会做的事情：** 不添加新包、不删除现有包、不修改包的功能逻辑、不配置 Cachix 缓存。

**Effort:** Large
**Risk:** Medium - flake.lock 更新可能导致部分包因 nixpkgs 版本变化而构建失败，需要调试修复
**Decisions to sanity-check:** flake.lock 更新后构建测试结果；lingmo-polkit-agent 是否能成功获取 hash 并构建

Your next move: **批准计划**，然后执行者将在虚拟机上逐步完成维护工作。详细执行计划见下。

---

> TL;DR (machine): Large | Medium | 删除分支+更新flake.lock+修复3个包+构建测试16个包+提交推送

## Scope
### Must have
- 删除 GitHub 上所有非 main 分支（3 个 dependabot 分支）
- 更新 flake.lock 到最新 nixpkgs
- 修复 CI workflow：nurRepo=teformel，移除 cachix 配置
- 固定 lingmo-statusbar 的 rev 到 ee5d766075b145fd46fdcdebd87121208251a8ae
- 修复 lingmo-polkit-agent 的占位符 hash
- 更新 ww-manager 从 2.1.10 到 2.1.12
- 在 VM (192.168.70.128) 上逐个构建测试所有 16 个包
- 修复所有构建失败的包
- 提交并推送所有更改

### Must NOT have (guardrails, anti-slop, scope boundaries)
- 不添加新包
- 不删除现有包（包括 example-package）
- 不修改包的功能逻辑（只做版本更新和构建修复）
- 不配置 cachix
- 不修改 NixOS 系统配置
- 不合并 dependabot PRs（直接删除分支）

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: tests-after — 在 VM 上逐个 `nix build .#<pkg>` 验证构建
- Evidence: .omo/evidence/task-<N>-maintain-nur-packages.<ext>（构建日志/结果）

## Execution strategy
### Parallel execution waves
- Wave 1（代码修改，可并行）：T1 删除分支, T2 修复 CI, T3 固定 statusbar rev, T4 修复 polkit-agent hash, T5 更新 ww-manager
- Wave 2（VM 同步+flake 更新）：T6 git pull + nix flake update
- Wave 3（构建测试，按依赖顺序）：T7-T10 分组构建
- Wave 4（提交）：T11 commit + push

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| T1 删除分支 | — | — | T2,T3,T4,T5 |
| T2 修复 CI | — | — | T1,T3,T4,T5 |
| T3 固定 statusbar rev | — | — | T1,T2,T4,T5 |
| T4 修复 polkit-agent hash | — | — | T1,T2,T3,T5 |
| T5 更新 ww-manager | — | — | T1,T2,T3,T4 |
| T6 git pull + flake update | T1-T5 | T7-T10 | — |
| T7 构建独立包 | T6 | T11 | T8 |
| T8 构建基础库 | T6 | T9 | T7 |
| T9 构建 lingmo-core | T8 | T10 | — |
| T10 构建依赖包 | T9 | T11 | — |
| T11 提交推送 | T7-T10 | — | — |

## Todos
> Implementation + Test = ONE todo. Never separate.
<!-- APPEND TASK BATCHES BELOW THIS LINE WITH edit/apply_patch - never rewrite the headers above. -->

- [ ] 1. 删除 GitHub 上所有非 main 分支
  What to do / Must NOT do: 在宿主机上用 git push origin --delete 删除 3 个远程分支：dependabot/github_actions/actions/checkout-7, dependabot/github_actions/cachix/cachix-action-17, dependabot/nix/nixpkgs-3e41b24。不删除 main 分支。
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References: 
  - 分支列表来自 VM 上 `git branch -a` 输出
  - 命令: `git push origin --delete <branch-name>`（需在宿主机仓库目录执行）
  - 宿主机仓库路径: C:\Users\maorila\nur-packages
  Acceptance criteria: `git branch -r` 只显示 origin/main 和 origin/HEAD
  QA scenarios: happy: 删除后 git branch -r 只剩 main | failure: 如果分支不存在则跳过, Evidence .omo/evidence/task-1-maintain-nur-packages.txt
  Commit: N | 无需提交（远程操作）

- [ ] 2. 修复 CI workflow 占位符
  What to do / Must NOT do: 编辑 .github/workflows/build.yml，将 nurRepo 的 `<YOUR_REPO_NAME>` 改为 `teformel`。移除 cachix 相关步骤（Setup cachix 和 cachixName 矩阵项），因为用户没有 cachix。保留 NUR update trigger 步骤（修改条件判断）。
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References:
  - .github/workflows/build.yml:23-24 — nurRepo: - <YOUR_REPO_NAME>
  - .github/workflows/build.yml:35-36 — cachixName: - <YOUR_CACHIX_NAME>
  - .github/workflows/build.yml:54-61 — Setup cachix 步骤
  - .github/workflows/build.yml:73-76 — Trigger NUR update 步骤（条件 if: ${{ matrix.nurRepo != '<YOUR_REPO_NAME>' }}）
  - 用户确认: nurRepo=teformel, 不用 cachix
  Acceptance criteria: build.yml 中无 `<YOUR_REPO_NAME>` 和 `<YOUR_CACHIX_NAME>` 字符串；nurRepo 设为 teformel
  QA scenarios: happy: grep 检查无占位符 | failure: 确认 cachix 步骤已移除, Evidence .omo/evidence/task-2-maintain-nur-packages.txt
  Commit: Y | `ci: set nurRepo to teformel and remove cachix`

- [ ] 3. 固定 lingmo-statusbar 的 rev
  What to do / Must NOT do: 编辑 pkgs/lingmo-statusbar/default.nix，将 `rev = "main"` 改为 `rev = "ee5d766075b145fd46fdcdebd87121208251a8ae"`。hash 可能也需要更新——先保持当前 hash，构建时如果失败再更新。
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References:
  - pkgs/lingmo-statusbar/default.nix:10-11 — rev = "main"; hash = "sha256-+nV+adCcjEElQuOXU1idUHCUf7qkSY4LF0B/MrpII2E="
  - 上游最新 commit: ee5d766075b145fd46fdcdebd87121208251a8ae（2025-04-03）
  - 当前 hash 可能适用于此 commit（因为之前 rev="main" 时就是这个 commit），但需构建验证
  Acceptance criteria: rev 值为完整 40 字符 commit hash
  QA scenarios: happy: 构建时 hash 匹配 | failure: 如果 hash 不匹配，用 nix-prefetch 获取新 hash, Evidence .omo/evidence/task-3-maintain-nur-packages.txt
  Commit: Y | `fix(lingmo-statusbar): pin rev to specific commit`

- [ ] 4. 修复 lingmo-polkit-agent 的占位符 hash
  What to do / Must NOT do: 编辑 pkgs/lingmo-polkit-agent/default.nix，将占位符 hash `sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=` 替换为真实 hash。获取真实 hash 的方法：在 VM 上运行 `nix-prefetch-url --unpack "https://github.com/LingmoOS/lingmo-polkit-agent/archive/93b81233a4f2816aec0d8d97345f285835906cd5.tar.gz"` 然后用 `nix hash to-sri --type sha256 <hash>` 转换为 SRI 格式。
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References:
  - pkgs/lingmo-polkit-agent/default.nix:12 — hash = "sha256-AAAA..."
  - 上游 commit: 93b81233a4f2816aec0d8d97345f285835906cd5
  - 获取 hash 命令: `nix-prefetch-url --unpack "https://github.com/LingmoOS/lingmo-polkit-agent/archive/93b81233a4f2816aec0d8d97345f285835906cd5.tar.gz"` 然后 `nix hash to-sri --type sha256 <result>`
  Acceptance criteria: hash 字段是有效的 SRI 格式 sha256，不是占位符
  QA scenarios: happy: nix-prefetch 成功返回 hash | failure: 如果仓库无法访问则报错, Evidence .omo/evidence/task-4-maintain-nur-packages.txt
  Commit: Y | `fix(lingmo-polkit-agent): set correct source hash`

- [ ] 5. 更新 ww-manager 从 2.1.10 到 2.1.12
  What to do / Must NOT do: 编辑 pkgs/ww-manager/default.nix，将 version 从 "2.1.10" 改为 "2.1.12"（rev 会自动变为 v2.1.12 因为用了 `rev = "v${version}"`）。hash 需要更新——先设为假 hash 然后在 VM 上构建获取真实 hash，或用 nix-prefetch 获取。
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References:
  - pkgs/ww-manager/default.nix:5 — version = "2.1.10"
  - pkgs/ww-manager/default.nix:7-12 — src fetchFromGitHub with rev = "v${version}", hash = "sha256-44nX20ZiGYwZMOiNRDyzLlP18QvZyX6lIMb4UQC9itQ="
  - 上游最新 tag: v2.1.12 (commit bfaf560c00611949a1df9e12a2c1e2479b41595c)
  - 获取 hash: `nix-prefetch-url --unpack "https://github.com/timetetng/wutheringwaves-cli-manager/archive/refs/tags/v2.1.12.tar.gz"` 然后 `nix hash to-sri --type sha256 <hash>`
  Acceptance criteria: version = "2.1.12", hash 是有效 SRI 格式
  QA scenarios: happy: 构建成功 | failure: hash 不匹配则用 nix-prefetch 获取, Evidence .omo/evidence/task-5-maintain-nur-packages.txt
  Commit: Y | `feat(ww-manager): update to 2.1.12`

- [ ] 6. 在 VM 上同步代码并更新 flake.lock
  What to do / Must NOT do: 在宿主机提交 T2-T5 的更改后，在 VM 上 git pull 拉取最新代码。然后运行 `nix flake update` 更新 flake.lock。注意：flake.lock 更新可能改变 nixpkgs 版本，导致部分包构建行为变化。
  Parallelization: Wave 2 | Blocked by: T1-T5 | Blocks: T7-T10
  References:
  - VM 路径: ~/nur-packages
  - VM SSH: ssh maorila@192.168.70.128
  - flake.lock 当前指向 nixpkgs 600b15aea1 (2024-04-07)
  - 命令: `cd ~/nur-packages && git pull origin main && nix flake update`
  - 注意: default.nix 中的 pkgsKF5 使用固定 tarball (builtins.fetchTarball)，不受 flake.lock 更新影响
  Acceptance criteria: flake.lock 中 nixpkgs 的 lastModified 是近期日期（不是 2024-04-07）
  QA scenarios: happy: flake update 成功, nix flake check --no-build 通过 | failure: 如果 flake update 后求值失败需要修复, Evidence .omo/evidence/task-6-maintain-nur-packages.txt
  Commit: Y | `chore: update flake.lock`

- [ ] 7. 在 VM 上构建独立包（无依赖）
  What to do / Must NOT do: 在 VM 上逐个构建不依赖其他 NUR 包的包：clash-party, ww-manager, lingmo-sddm-theme。同时构建 Qt5 基础包：lingmo-desktop, lingmo-daemon, lingmo-screenlocker（这些用 pkgsKF5.libsForQt5，互相独立）。用 `nix build .#<pkg>` 命令。如果构建失败，分析错误并修复 .nix 文件（在宿主机编辑，VM 上 git pull 重新构建）。
  Parallelization: Wave 3 | Blocked by: T6 | Blocks: T11 | Can parallelize with: T8
  References:
  - VM 构建命令: `nix build .#<pkg>` 或 `nix-build -A <pkg>`
  - 独立包: clash-party, ww-manager, lingmo-sddm-theme
  - Qt5 独立包: lingmo-desktop, lingmo-daemon, lingmo-screenlocker
  - 已知工作区: lingmo-daemon 有 QApt stub 和 Python shebang 修复 (pkgs/lingmo-daemon/default.nix:26-34)
  - lingmo-daemon postInstall 修复 python shebang (pkgs/lingmo-daemon/default.nix:37-42)
  Acceptance criteria: 上述 6 个包全部 `nix build .#<pkg>` 成功，result 符号链接存在
  QA scenarios: happy: 全部构建成功 | failure: 记录错误日志，修复后重新构建, Evidence .omo/evidence/task-7-maintain-nur-packages.txt
  Commit: Y（如果有修复）| `fix(<pkg>): <description>`

- [ ] 8. 在 VM 上构建基础库（lib_lingmo, lingmoui）
  What to do / Must NOT do: 在 VM 上构建 lib_lingmo 和 lingmoui（这两个是其他 Qt6 Lingmo 包的基础依赖）。用 `nix build .#lib_lingmo` 和 `nix build .#lingmoui`。如果构建失败，分析错误并修复。
  Parallelization: Wave 3 | Blocked by: T6 | Blocks: T9 | Can parallelize with: T7
  References:
  - lib_lingmo: pkgs/lib_lingmo/default.nix — 使用 C++20, 有 ecm_query_qt 补丁, 依赖 kdePackages
  - lingmoui: pkgs/lingmoui/default.nix — 有 QHotkey/GuiPrivate 补丁, fetchSubmodules=true
  - 这两个包是 lingmo-core 及其他 Qt6 包的依赖
  - lib_lingmo 已有 C++20 修复 (env.CXXFLAGS = "-std=c++20")
  - lingmoui 已有 GuiPrivate → Gui 替换补丁
  Acceptance criteria: lib_lingmo 和 lingmoui 构建成功
  QA scenarios: happy: 两个包都构建成功 | failure: 记录错误，修复后重新构建, Evidence .omo/evidence/task-8-maintain-nur-packages.txt
  Commit: Y（如果有修复）| `fix(<pkg>): <description>`

- [ ] 9. 在 VM 上构建 lingmo-core
  What to do / Must NOT do: 在 VM 上构建 lingmo-core（依赖 lingmoui）。用 `nix build .#lingmo-core`。lingmo-core 是大多数 Qt6 Lingmo 包的依赖，必须先构建成功。
  Parallelization: Wave 3 | Blocked by: T8 | Blocks: T10
  References:
  - lingmo-core: pkgs/lingmo-core/default.nix — 依赖 lingmoui, 有 passthru.providedSessions, postInstall 修复 python shebang
  - lingmo-core postInstall (pkgs/lingmo-core/default.nix:38-43): chmod +x 和 python shebang 修复
  - 依赖链: lingmoui → lingmo-core → (settings, dock, launcher, filemanager, kwin-plugins, polkit-agent, statusbar)
  Acceptance criteria: lingmo-core 构建成功
  QA scenarios: happy: 构建成功 | failure: 记录错误，修复后重新构建, Evidence .omo/evidence/task-9-maintain-nur-packages.txt
  Commit: Y（如果有修复）| `fix(lingmo-core): <description>`

- [ ] 10. 在 VM 上构建依赖 lingmo-core 的包
  What to do / Must NOT do: 在 VM 上逐个构建依赖 lingmo-core 的 7 个 Qt6 包：lingmo-settings, lingmo-dock, lingmo-launcher, lingmo-filemanager, lingmo-kwin-plugins, lingmo-polkit-agent, lingmo-statusbar。用 `nix build .#<pkg>`。如果构建失败，分析错误并修复。特别注意 lingmo-polkit-agent（之前 hash 是占位符，首次构建）和 lingmo-kwin-plugins（有 KDecoration3→2 补丁）。
  Parallelization: Wave 3 | Blocked by: T9 | Blocks: T11
  References:
  - 7 个包: lingmo-settings, lingmo-dock, lingmo-launcher, lingmo-filemanager, lingmo-kwin-plugins, lingmo-polkit-agent, lingmo-statusbar
  - lingmo-kwin-plugins: pkgs/lingmo-kwin-plugins/default.nix:16-22 — KDecoration3→KDecoration2 补丁
  - lingmo-polkit-agent: pkgs/lingmo-polkit-agent/default.nix — 之前 hash 是占位符，T4 已修复
  - lingmo-statusbar: pkgs/lingmo-statusbar/default.nix — T3 已固定 rev
  - 所有包都有 DESTINATION /usr/ → DESTINATION 补丁
  Acceptance criteria: 上述 7 个包全部构建成功
  QA scenarios: happy: 全部构建成功 | failure: 记录错误日志，修复后重新构建, Evidence .omo/evidence/task-10-maintain-nur-packages.txt
  Commit: Y（如果有修复）| `fix(<pkg>): <description>`

- [ ] 11. 提交并推送所有更改
  What to do / Must NOT do: 在宿主机上提交所有更改（包括 T2-T5 的代码修改、T6 的 flake.lock 更新、T7-T10 的构建修复），然后推送到 GitHub。确保提交消息清晰描述每个更改。在推送前确认 `nix flake check --no-build` 在 VM 上通过。
  Parallelization: Wave 4 | Blocked by: T7-T10 | Blocks: —
  References:
  - 宿主机仓库路径: C:\Users\maorila\nur-packages
  - 推送前验证: VM 上 `nix flake check --no-build` 全部通过
  - 提交策略: 如果 T2-T5 已分别提交，则只需提交构建修复和 flake.lock；否则统一提交
  - git push origin main
  Acceptance criteria: git log 显示所有更改已提交，git push 成功，GitHub 上 main 分支是最新的
  QA scenarios: happy: 推送成功, GitHub CI 触发 | failure: 如果 CI 失败需要检查, Evidence .omo/evidence/task-11-maintain-nur-packages.txt
  Commit: Y | `chore: maintain NUR packages - update versions, fix builds, clean up`

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [ ] F1. Plan compliance audit — 确认所有 Must have 项完成，Must NOT have 项未违反
- [ ] F2. Code quality review — 确认 .nix 文件修改符合 Nix 风格，无多余改动
- [ ] F3. Real manual QA — VM 上 `nix flake check --no-build` 通过，抽查 3 个包 `nix build` 成功
- [ ] F4. Scope fidelity — 确认未添加/删除包，未修改功能逻辑

## Commit strategy
- T2: `ci: set nurRepo to teformel and remove cachix`
- T3: `fix(lingmo-statusbar): pin rev to specific commit`
- T4: `fix(lingmo-polkit-agent): set correct source hash`
- T5: `feat(ww-manager): update to 2.1.12`
- T6: `chore: update flake.lock`
- T7-T10: `fix(<pkg>): <description>`（仅在有修复时）
- T11: 最终推送

## Success criteria
- GitHub 上只有 main 分支
- flake.lock 更新到最新 nixpkgs
- CI workflow 无占位符
- lingmo-statusbar 的 rev 是固定 commit
- lingmo-polkit-agent 的 hash 是真实的
- ww-manager 版本为 2.1.12
- 所有 16 个包在 VM 上 `nix build .#<pkg>` 成功
- 所有更改已提交并推送到 GitHub
