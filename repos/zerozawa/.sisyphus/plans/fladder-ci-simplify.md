# Fladder CI 简化 - pubspec-lock.json 同步检查

## TL;DR

> **Quick Summary**: 简化 CI 流程，删除 Fladder 自动版本更新功能，改为每次 commit 检查 `pubspec-lock.json` 是否需要同步。仅在 `pkgs/Fladder/` 目录有变更时触发检查。
>
> **Deliverables**:
> - 删除 `.github/workflows/fladder-update.yml`
> - 修改 `.github/workflows/build.yml` 添加 pubspec-lock.json 同步检查

> **Estimated Effort**: Quick
> **Parallel Execution**: NO — sequential (check → build decision)
> **Critical Path**: check sync → if mismatch: bot commit + exit → new CI run

---

## Context

### Original Request
用户要求简化 Fladder CI 流程：
- 不需要自动版本更新（删除 schedule）
- 每次 commit 检查 `pubspec-lock.json` 是否需要更新
- 仅在 `pkgs/Fladder/` 目录有变更时检查
- 使用 `nix run .#Fladder.pubspecLock2Json` 生成新 JSON 比较

### Flow Design

```
commit → build.yml 触发
    │
    ▼
检查 pkgs/Fladder/ 是否有变更？
    │
    ├─ 否 ──► 跳过检查，直接 build
    │
    └─ 是 ──► 检查 pubspec-lock.json 同步
              │
              ├─ JSON 相同 ──► 正常 build
              │
              └─ JSON 不同 ──► bot 更新 + 提交
                              │
                              └─ EXIT (等待新 commit 触发 build)
```

### Technical Details

**检查命令**:
```bash
# 生成新的 pubspec-lock.json
nix run .#Fladder.pubspecLock2Json pkgs/Fladder/pubspec-lock.json > /tmp/new-pubspec-lock.json

# 比较
diff pkgs/Fladder/pubspec-lock.json /tmp/new-pubspec-lock.json
```

**Bot commit**: `chore(fladder): sync pubspec-lock.json`

---

## Work Objectives

### Core Objective
简化 CI，移除自动版本更新，添加 pubspec-lock.json 同步检查。

### Concrete Deliverables
1. 删除 `.github/workflows/fladder-update.yml`
2. 修改 `.github/workflows/build.yml` 添加检查步骤

### Definition of Done
- [x] `fladder-update.yml` 已删除
- [x] `build.yml` 包含 pubspec-lock.json 检查逻辑
- [x] 仅在 `pkgs/Fladder/` 变更时触发检查
- [x] JSON 不同时 bot 能正确提交
- [x] bot commit 后不会循环触发检查

### Must Have
- 检查使用 `nix run .#Fladder.pubspecLock2Json`
- 仅 `pkgs/Fladder/` 变更时检查
- bot commit message 包含特定标识用于跳过

### Must NOT Have (Guardrails)
- 不检查 Fladder 上游版本
- 不自动更新 version/hash
- 不在 bot commit 上循环检查

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO
- **Automated tests**: None
- **Agent-Executed QA**: actionlint + 手动验证逻辑

---

## TODOs

- [x] 1. 删除 `fladder-update.yml`

  **What to do**:
  - 删除 `.github/workflows/fladder-update.yml` 文件

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Commit**: YES (group with Task 2)
  - Message: `refactor(ci): simplify fladder workflow - remove auto-update`

---

- [x] 2. 修改 `build.yml` 添加 pubspec-lock.json 同步检查

  **What to do**:
  - 在 `tests` job 开始前添加检查步骤
  - 使用 `dorny/paths-filter@v3` 检测 `pkgs/Fladder/` 变更
  - 如果有变更，运行检查：
    ```yaml
    - name: Check pubspec-lock.json sync
      id: pubspec-check
      if: steps.filter.outputs.fladder == 'true'
      run: |
        # pubspecLock2Json reads from embedded src and outputs to argument
        nix run .#Fladder.pubspecLock2Json /tmp/new-pubspec-lock.json
        if diff -q pkgs/Fladder/pubspec-lock.json /tmp/new-pubspec-lock.json > /dev/null; then
          echo "synced=true" >> "$GITHUB_OUTPUT"
        else
          echo "synced=false" >> "$GITHUB_OUTPUT"
          cp /tmp/new-pubspec-lock.json pkgs/Fladder/pubspec-lock.json
        fi
    ```
    ```yaml
    - name: Check pubspec-lock.json sync
      id: pubspec-check
      if: steps.filter.outputs.fladder == 'true'
      run: |
        nix run .#Fladder.pubspecLock2Json pkgs/Fladder/pubspec-lock.json > /tmp/new-pubspec-lock.json
        if diff -q pkgs/Fladder/pubspec-lock.json /tmp/new-pubspec-lock.json > /dev/null; then
          echo "synced=true" >> "$GITHUB_OUTPUT"
        else
          echo "synced=false" >> "$GITHUB_OUTPUT"
          cp /tmp/new-pubspec-lock.json pkgs/Fladder/pubspec-lock.json
        fi
    ```
  - 如果不同步，bot 提交并退出：
    ```yaml
    - name: Sync pubspec-lock.json
      if: steps.pubspec-check.outputs.synced == 'false'
      run: |
        git config user.name 'github-actions[bot]'
        git config user.email 'github-actions[bot]@users.noreply.github.com'
        git add pkgs/Fladder/pubspec-lock.json
        git commit -m "chore(fladder): sync pubspec-lock.json"
        git push
        exit 1  # Exit to let new commit trigger build
    ```
  - 修改 `tests` job 条件，跳过 bot sync commit：
    ```yaml
    if: |
      github.actor != 'github-actions[bot]' ||
      !(startsWith(github.event.head_commit.message, 'chore(fladder): update to v') ||
        startsWith(github.event.head_commit.message, 'chore(fladder): sync pubspec-lock.json'))
    ```

  **Must NOT do**:
  - 不改变 matrix 策略
  - 不删除现有 build 步骤

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **References**:
  - `pkgs/Fladder/default.nix:39-42` — `passthru.pubspecLock2Json` 定义
  - `dorny/paths-filter` action 文档

  **Acceptance Criteria**:
  - [x] 仅在 `pkgs/Fladder/` 变更时检查
  - [x] JSON 相同时正常 build
  - [x] JSON 不同时 bot 提交
  - [x] bot commit 后不循环

  **Commit**: YES
  - Message: `refactor(ci): add pubspec-lock.json sync check for Fladder`

---

- [x] F1. **Plan Compliance Audit**
  - Verify `fladder-update.yml` is deleted
  - Verify sync check uses correct nix command
  - Verify loop prevention works
  - Output: `VERDICT: APPROVE/REJECT`

---

## Commit Strategy

- **Combined**: `refactor(ci): simplify fladder workflow - add pubspec-lock sync check`

---

## Success Criteria

- [x] `fladder-update.yml` 已删除
- [x] `build.yml` 包含同步检查
- [x] 仅 Fladder 变更时检查
- [x] JSON 同步逻辑正确
- [x] 无循环触发问题
## Fix History

- **2026-03-01**: Removed incorrect `if` condition at job level that was incorrectly skipping bot commits. Bot commits should trigger normal build flow - the `exit 1` in sync step already handles stopping the workflow when json is updated.
- Fixed shellcheck warnings (SC2086, SC2046) for proper quoting in nix evaluation step.
  - The `exit 1` in sync step already handles stopping the workflow when json is updated
  - Correct flow: bot commit -> triggers new workflow -> normal build (no skip needed)
  - The if condition was wrong: bot commits should NOT be skipped at job level
  - Commit: `04e6ddf` fix(ci): remove incorrect bot skip condition from build workflow
- [x] **Fixed incorrect if condition** - Removed job-level `if` that incorrectly skipped bot commits
## Post-Completion Fix
- [x] **Fixed nix installation order** - Moved "Install nix" step before "Check paths" and "Check pubspec-lock.json sync" so nix is available when running `nix run .#Fladder.pubspecLock2Json`
  - Error was: `nix: command not found` in sync check step
  - Commit: `1a005f3` fix(ci): move nix installation before pubspec-lock sync check
---
