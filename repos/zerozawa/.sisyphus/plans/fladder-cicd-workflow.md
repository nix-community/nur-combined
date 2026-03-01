# Fladder CI/CD GitHub Actions Redesign

## TL;DR

> **Quick Summary**: Split the existing monolithic `build.yml` into two coordinated workflows: a `fladder-update.yml` that checks for new Fladder upstream releases, auto-updates `pubspec-lock.json` + `default.nix`, and commits via bot (then stops), and a refactored `build.yml` that only runs the NUR build/cache pipeline when no Fladder update was triggered.
>
> **Deliverables**:
> - `.github/workflows/fladder-update.yml` — new workflow: version check + auto-update bot commits
> - `.github/workflows/build.yml` — refactored to skip build when triggered by bot update commit

> **Estimated Effort**: Medium
> **Parallel Execution**: NO — sequential (update check must complete before build decision)
> **Critical Path**: fladder-update.yml triggers → if update: commits → new push triggers build.yml (no Fladder update needed, so build proceeds)

---

## Context

### Original Request
用户已将 `pkgs/Fladder/default.nix` 改为依赖本地 `pkgs/Fladder/pubspec-lock.json`，需要 GitHub Actions 自动处理 Fladder 的版本更新：
- 检测上游新版本
- 自动更新 `pubspec-lock.json` 和 `default.nix`（version + hash）
- 通过 bot 提交这些更改
- 触发了 lock 更新则不运行 build 流水线（等 bot 提交后的 push 再触发 build）

### Interview Summary
**Key Discussions**:
- `default.nix` 使用 `pubspecLock = lib.importJSON ./pubspec-lock.json;`（本地 JSON 文件）
- `passthru.pubspecLock2Json` 提供了 YAML→JSON 的转换脚本（需要 `yq-go`）
- Fladder 有 `preferLocalBuild = true`，CI 中会被排除在 cachix 构建之外
- 现有 `build.yml` 使用矩阵策略测试多个 nixpkgs channel

**Research Findings**:
- Fladder 上游: `https://github.com/DonutWare/Fladder/releases`
- Hash 获取: 在 CI 中用 `nix-prefetch-url --unpack <tarball_url>` 或 `nix store prefetch-file`
- pubspec.lock 转 JSON: 需要 `yq` 工具（CI 中通过 nix 安装）
- Bot 提交: 使用 `GITHUB_TOKEN` + `git config user` 设为 `github-actions[bot]`

### Metis Review
**Metis timed out — key gaps identified manually**:
- Gap 1: pubspec-lock.json 更新需要下载 Fladder 源码并运行 yq 转换，需要在 CI 中安装 yq（通过 nix shell）
- Gap 2: 需要明确 bot commit 如何避免触发循环（用 commit message 标记 + workflow 条件跳过）
- Gap 3: matrix 策略（多 nixpkgs channel）在 fladder-update 时不需要，只在 build 时需要
- Gap 4: 需要处理 nix-prefetch-url 可能需要 `--type sha256` 和 SRI 格式转换
- Gap 5: 新版 Fladder 可能有不同的 pubspec.lock 格式，需要验证转换
- Gap 6: GITHUB_TOKEN 默认权限需要 `contents: write` 才能 push

---

## Work Objectives

### Core Objective
在 GitHub Actions 中实现两个协作的 workflow：
1. **fladder-update**: 定时检测上游版本，发现新版本时自动更新文件并提交（然后停止，不继续 build）
2. **build**: 保留原有构建流水线，但需要跳过 bot update commit 触发的运行（避免循环）

### Concrete Deliverables
- `.github/workflows/fladder-update.yml` — 完整的更新检测+提交 workflow
- `.github/workflows/build.yml` — 在原 build.yml 基础上增加"跳过 bot commit"的逻辑

### Definition of Done
- [ ] `fladder-update.yml` 在 GitHub Actions 中语法验证通过
- [ ] `fladder-update.yml` 能正确检测 Fladder 上游最新版本
- [ ] `fladder-update.yml` 发现新版本时能成功更新 `default.nix` 和 `pubspec-lock.json`
- [ ] bot 提交后，`build.yml` 不会在同一版本更新提交上重复触发
- [ ] `build.yml` 在非 bot-update 的 push/PR/schedule 场景下正常运行

### Must Have
- fladder-update workflow 的版本比较逻辑准确（字符串或语义版本比较）
- pubspec-lock.json 的 YAML→JSON 转换使用 `yq`（与现有 `passthru.pubspecLock2Json` 逻辑一致）
- bot commit 的幂等性（重复触发不会造成多余提交）
- `build.yml` 对 bot-update commit 的识别和跳过逻辑
- 新的 workflow 文件需要合理的权限声明（`permissions: contents: write`）

### Must NOT Have (Guardrails)
- **不能**在 fladder-update 触发了更新提交后仍然运行 build 流水线（避免用错误的 hash/lock 构建）
- **不能**在 bot commit 上无限循环触发 fladder-update（需要跳过条件）
- **不能**修改现有 build.yml 的 matrix 策略（多 nixpkgs channel 测试是必要的）
- **不能**删除现有的 cachix 上传、NUR update ping 等步骤

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO（NUR 项目无单元测试框架）
- **Automated tests**: None（workflow 文件通过 GitHub Actions 自身验证）
- **Agent-Executed QA**: 通过 bash 脚本逻辑验证 + `act` 或 `actionlint` 静态检查

### QA Policy
通过 `actionlint` 静态分析验证 workflow YAML 语法和逻辑，通过手动分析验证关键路径。

---

## Execution Strategy

### Workflow Design: Two-Workflow Architecture

```
                    ┌─────────────────────────────────────┐
                    │  Trigger: schedule (daily) / push    │
                    │         / workflow_dispatch          │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │   fladder-update.yml                 │
                    │                                      │
                    │  1. Skip if triggered by bot commit  │
                    │  2. Get current version from         │
                    │     pkgs/Fladder/default.nix         │
                    │  3. Get latest upstream version      │
                    │     (GitHub API)                     │
                    │  4. Compare versions                 │
                    │     ┌──────────────────────────┐    │
                    │     │ versions match? → EXIT 0  │    │
                    │     └──────────────────────────┘    │
                    │     ┌──────────────────────────┐    │
                    │     │ new version found?        │    │
                    │     │  → update default.nix     │    │
                    │     │  → update pubspec-lock.json│   │
                    │     │  → bot commit + push      │    │
                    │     │  → EXIT (no build)        │    │
                    │     └──────────────────────────┘    │
                    └─────────────────────────────────────┘

                    ┌─────────────────────────────────────┐
                    │  build.yml                           │
                    │                                      │
                    │  Trigger: push/PR/schedule           │
                    │                                      │
                    │  Step 1: Check if this is a bot      │
                    │  update commit → if yes, SKIP ALL    │
                    │                                      │
                    │  Step 2 (normal flow):               │
                    │  nix-eval → nix-build-uncached       │
                    │  → cachix → NUR ping                 │
                    └─────────────────────────────────────┘
```

### Key Design Decisions

#### Decision 1: Separate Workflow vs. Integrated
**Choice**: Separate `fladder-update.yml` workflow file.
**Rationale**: 
- Cleaner separation of concerns
- Can be triggered/cancelled independently
- Easier to debug and monitor in GitHub Actions UI
- Build.yml matrix strategy doesn't need to change

#### Decision 2: Bot Commit Loop Prevention
**Strategy**: Two-layer protection:
1. `fladder-update.yml` trigger condition: skip if `github.actor == 'github-actions[bot]'` AND commit message matches `chore(fladder): update to v*`
2. `build.yml`: Add a job condition to check if the commit message is a bot update commit

**Implementation**:
```yaml
# In fladder-update.yml
if: |
  github.event_name != 'push' ||
  !startsWith(github.event.head_commit.message, 'chore(fladder): update to v')
```

#### Decision 3: pubspec-lock.json Update Approach
**Strategy**: In CI, download new Fladder source tarball, use `nix shell nixpkgs#yq-go` to convert `pubspec.lock` → JSON.
**Steps**:
1. `curl -L https://github.com/DonutWare/Fladder/archive/refs/tags/v{VERSION}.tar.gz | tar xz`
2. `nix shell nixpkgs#yq-go -c yq -e -o=json . Fladder-{VERSION}/pubspec.lock > pkgs/Fladder/pubspec-lock.json`

#### Decision 4: Hash Acquisition
**Strategy**: Use `nix store prefetch-file --json --hash-type sha256` or `nix-prefetch-url --unpack --type sha256` to get the SRI hash.
**Implementation**:
```bash
HASH=$(nix-prefetch-url --unpack --type sha256 "https://github.com/DonutWare/Fladder/archive/refs/tags/v${NEW_VERSION}.tar.gz" 2>/dev/null)
# Convert to SRI format: sha256-<base64>
SRI_HASH=$(nix hash convert --hash-algo sha256 --to sri "$HASH" 2>/dev/null || \
           nix hash to-sri --type sha256 "$HASH")
```

#### Decision 5: default.nix Version/Hash Update
**Strategy**: Use `sed` for surgical in-place replacement (no extra tools needed):
```bash
sed -i "s/version = \".*\";/version = \"${NEW_VERSION}\";/" pkgs/Fladder/default.nix
sed -i "s|hash = \"sha256-.*\";|hash = \"${SRI_HASH}\";|" pkgs/Fladder/default.nix
```

### Parallel Execution Waves

```
Wave 1 (fladder-update workflow):
└── Job: check-and-update (single job, sequential steps)

Wave 2 (build workflow, independent):
└── Job: tests (existing matrix strategy, runs in parallel per nixPath)
    ├── nixpkgs-unstable channel
    ├── nixos-unstable channel
    └── nixos-25.11 channel
```

---

## TODOs

- [ ] 1. Create `fladder-update.yml` — version check and auto-update workflow

  **What to do**:
  - Create `.github/workflows/fladder-update.yml`
  - Triggers: `schedule` (daily at a different time than build.yml, e.g., 3:00 UTC), `workflow_dispatch`
  - Add condition to skip if triggered by a bot-update commit (check `github.actor` and commit message)
  - Steps:
    1. `actions/checkout@v4` with `token: ${{ secrets.GITHUB_TOKEN }}`
    2. Install Nix (`cachix/install-nix-action@v31`) — needed for `nix-prefetch-url` and `yq-go`
    3. **Get current version**: `grep 'version = ' pkgs/Fladder/default.nix | head -1 | grep -oP '"[^"]+"' | tr -d '"'`
    4. **Get upstream version**: `gh api repos/DonutWare/Fladder/releases/latest --jq .tag_name | sed 's/^v//'`
    5. **Compare**: if `CURRENT_VERSION == LATEST_VERSION`, echo "No update needed" and exit 0
    6. **Download source and extract pubspec.lock**:
       - Download tarball: `curl -fsSL "https://github.com/DonutWare/Fladder/archive/refs/tags/v${LATEST}.tar.gz" -o /tmp/fladder.tar.gz`
       - Extract: `tar xzf /tmp/fladder.tar.gz -C /tmp/`
       - Convert YAML→JSON: `nix shell nixpkgs#yq-go -c yq -e -o=json . /tmp/Fladder-${LATEST}/pubspec.lock > pkgs/Fladder/pubspec-lock.json`
    7. **Get new hash**:
       - `HASH=$(nix-prefetch-url --unpack --type sha256 "https://github.com/DonutWare/Fladder/archive/refs/tags/v${LATEST}.tar.gz")`
       - Convert to SRI: `SRI=$(nix hash to-sri --type sha256 "$HASH")`
    8. **Update default.nix**:
       - `sed -i "s/version = \"[^\"]*\";/version = \"${LATEST}\";/" pkgs/Fladder/default.nix`
       - `sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"${SRI}\";|" pkgs/Fladder/default.nix`
    9. **Bot commit and push**:
       - `git config user.name "github-actions[bot]"`
       - `git config user.email "github-actions[bot]@users.noreply.github.com"`
       - `git add pkgs/Fladder/default.nix pkgs/Fladder/pubspec-lock.json`
       - `git commit -m "chore(fladder): update to v${LATEST}"`
       - `git push`
  - Permissions block: `permissions: contents: write`
  - Add `GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` to env for `gh` CLI

  **Must NOT do**:
  - Don't run nix-build or CI build steps in this workflow
  - Don't modify any other packages
  - Don't change the matrix strategy
  - Don't use a PAT — use GITHUB_TOKEN with `contents: write` permission

  **Recommended Agent Profile**:
  > Writing GitHub Actions YAML — quick, well-understood domain.
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 2 (build.yml update depends on understanding skip logic)
  - **Blocked By**: None (can start immediately)

  **References**:
  - Pattern References:
    - `.github/workflows/build.yml` — existing workflow structure to follow for Nix setup steps
    - `pkgs/Fladder/default.nix:26,31,44` — exact lines to target with sed: `version`, `hash`, `pubspecLock`
  - External References:
    - `https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token` — GITHUB_TOKEN write permissions
    - `https://github.com/cachix/install-nix-action` — Nix installation action
    - `https://cli.github.com/manual/gh_api` — GitHub CLI API call syntax

  **Acceptance Criteria**:
  - [ ] File `.github/workflows/fladder-update.yml` exists and is valid YAML
  - [ ] Workflow has correct `permissions: contents: write`
  - [ ] Version comparison logic handles semver strings (e.g., "0.10.1" vs "0.11.0")
  - [ ] Skip condition correctly identifies bot-update commits
  - [ ] All 9 steps listed above are present and correctly sequenced

  **QA Scenarios**:

  ```
  Scenario: Validate YAML syntax
    Tool: Bash
    Preconditions: .github/workflows/fladder-update.yml exists
    Steps:
      1. Run: python3 -c "import yaml; yaml.safe_load(open('.github/workflows/fladder-update.yml'))"
         Expected: exits 0 with no error
      2. Run: nix shell nixpkgs#actionlint -c actionlint .github/workflows/fladder-update.yml
         Expected: exits 0, no errors reported
    Expected Result: YAML is syntactically valid and follows Actions schema
    Evidence: .sisyphus/evidence/task-1-yaml-validate.txt

  Scenario: Version comparison logic
    Tool: Bash
    Preconditions: Extract the comparison logic to a test script
    Steps:
      1. Set CURRENT=0.10.1, LATEST=0.10.1
         Run the compare step logic
         Expected: outputs "No update needed", exits 0
      2. Set CURRENT=0.10.1, LATEST=0.11.0
         Run the compare step logic
         Expected: does NOT output "No update needed", continues to update steps
    Expected Result: Correct comparison for equal and unequal versions
    Evidence: .sisyphus/evidence/task-1-version-compare.txt
  ```

  **Evidence to Capture**:
  - [ ] task-1-yaml-validate.txt — output of YAML/actionlint validation
  - [ ] task-1-version-compare.txt — output of version comparison logic test

  **Commit**: YES
  - Message: `feat(ci): add fladder-update workflow for auto version tracking`
  - Files: `.github/workflows/fladder-update.yml`
  - Pre-commit: `actionlint .github/workflows/fladder-update.yml || true`

---

- [ ] 2. Update `build.yml` — add skip condition for bot-update commits

  **What to do**:
  - Edit `.github/workflows/build.yml`
  - Add a job-level condition to the `tests` job to skip when the triggering commit is a bot Fladder update:
    ```yaml
    jobs:
      tests:
        if: |
          github.actor != 'github-actions[bot]' ||
          !startsWith(github.event.head_commit.message, 'chore(fladder): update to v')
    ```
  - Alternative approach (if the above is insufficient): Add a dedicated `check` job first:
    ```yaml
    jobs:
      check-skip:
        runs-on: ubuntu-latest
        outputs:
          should_skip: ${{ steps.check.outputs.should_skip }}
        steps:
          - id: check
            run: |
              if [[ "${{ github.actor }}" == "github-actions[bot]" ]] && \
                 [[ "${{ github.event.head_commit.message }}" == chore\(fladder\):\ update\ to\ v* ]]; then
                echo "should_skip=true" >> "$GITHUB_OUTPUT"
              else
                echo "should_skip=false" >> "$GITHUB_OUTPUT"
              fi
      tests:
        needs: check-skip
        if: needs.check-skip.outputs.should_skip != 'true'
        # ... rest of existing job
    ```
  - Preserve ALL existing steps, matrix strategy, and environment variables exactly as-is
  - Only add the skip condition — no other modifications

  **Must NOT do**:
  - Don't change the matrix strategy (nixPath values)
  - Don't remove or reorder any existing steps
  - Don't change cachix configuration
  - Don't change the NUR update ping step

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (can be done after understanding Task 1's commit message convention)
  - **Parallel Group**: Wave 1 (independent of Task 1 implementation)
  - **Blocks**: None
  - **Blocked By**: Task 1's commit message format must be known first (it is: `chore(fladder): update to v*`)

  **References**:
  - Pattern References:
    - `.github/workflows/build.yml:14-76` — full existing workflow to modify minimally
  - External References:
    - `https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/using-conditions-to-control-job-execution` — job conditions

  **Acceptance Criteria**:
  - [ ] `build.yml` still valid YAML after modification
  - [ ] Existing matrix strategy (3 nixPath values) unchanged
  - [ ] New condition correctly identifies bot-update commits
  - [ ] `if` condition on `tests` job is syntactically correct
  - [ ] All existing steps from line 42 onwards remain unchanged

  **QA Scenarios**:

  ```
  Scenario: YAML validation after modification
    Tool: Bash
    Preconditions: build.yml modified
    Steps:
      1. Run: python3 -c "import yaml; yaml.safe_load(open('.github/workflows/build.yml'))"
         Expected: exits 0 with no error
      2. Run: nix shell nixpkgs#actionlint -c actionlint .github/workflows/build.yml
         Expected: exits 0, no errors
    Expected Result: Modified build.yml is valid
    Evidence: .sisyphus/evidence/task-2-yaml-validate.txt

  Scenario: Skip condition logic verification
    Tool: Bash
    Preconditions: Extract the condition expression to test
    Steps:
      1. Simulate: actor=github-actions[bot], commit_msg="chore(fladder): update to v0.11.0"
         Expected: condition evaluates to false (job should be skipped)
      2. Simulate: actor=github-actions[bot], commit_msg="feat: something else"
         Expected: condition evaluates to true (job runs normally)
      3. Simulate: actor=lz37, commit_msg="chore(fladder): update to v0.11.0"
         Expected: condition evaluates to true (job runs normally — human commit)
    Expected Result: Only bot Fladder-update commits trigger the skip
    Evidence: .sisyphus/evidence/task-2-skip-logic.txt
  ```

  **Evidence to Capture**:
  - [ ] task-2-yaml-validate.txt — validation output
  - [ ] task-2-skip-logic.txt — condition logic analysis

  **Commit**: YES (group with Task 1 or separate)
  - Message: `feat(ci): skip build pipeline on fladder bot-update commits`
  - Files: `.github/workflows/build.yml`
  - Pre-commit: `actionlint .github/workflows/build.yml || true`

---

## Final Verification Wave

- [ ] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. Verify:
  - Task 1 workflow covers all 9 update steps
  - Task 2 preserves existing build.yml functionality
  - Bot loop prevention is implemented at BOTH workflow level (fladder-update skip) AND build.yml level (tests job skip)
  - `permissions: contents: write` is explicitly declared in fladder-update.yml
  - Commit message convention is consistent between Task 1 (producer) and Task 2 (consumer)
  Output: `Must Have [N/N] | Must NOT Have [N/N] | VERDICT: APPROVE/REJECT`

- [ ] F2. **YAML/Actions Syntax Review** — `unspecified-high`
  - Validate both workflow files with `actionlint`
  - Check GitHub Actions expression syntax (`${{ ... }}`)
  - Verify `on:` trigger conditions won't cause accidental loops
  - Check that `nix shell nixpkgs#yq-go -c yq ...` syntax is correct for the installed Nix version
  - Verify SRI hash format: `sha256-<base64>` (44 chars)
  Output: `Files [N/N valid] | Expressions [N/N correct] | VERDICT`

---

## Commit Strategy

- **Task 1**: `feat(ci): add fladder-update workflow for auto version tracking`
- **Task 2**: `feat(ci): skip build pipeline on fladder bot-update commits`

---

## Success Criteria

### Final Checklist
- [ ] `.github/workflows/fladder-update.yml` created with complete update logic
- [ ] `.github/workflows/build.yml` updated with bot-commit skip condition
- [ ] Loop prevention: fladder-update skips on bot commits, build skips on bot-update commits
- [ ] Hash format: SRI (`sha256-...`) consistent with existing `default.nix` format
- [ ] pubspec-lock.json update uses `yq-go` for YAML→JSON (consistent with passthru script)
- [ ] No matrix strategy changes in build.yml

---

## Appendix: Key File Locations

| File | Purpose |
|------|---------|
| `.github/workflows/fladder-update.yml` | NEW: Fladder version check + auto-update workflow |
| `.github/workflows/build.yml` | MODIFY: Add skip condition for bot-update commits |
| `pkgs/Fladder/default.nix` | Updated by bot: `version` (line ~26) and `hash` (line ~31) |
| `pkgs/Fladder/pubspec-lock.json` | Updated by bot: converted from upstream `pubspec.lock` |

## Appendix: Complete `fladder-update.yml` Template

```yaml
name: "Fladder: Check and Update"

on:
  schedule:
    - cron: '30 3 * * *'  # 3:30 UTC daily (offset from build.yml's 5:55 UTC)
  workflow_dispatch:

permissions:
  contents: write

jobs:
  check-and-update:
    runs-on: ubuntu-latest
    # Skip if this push was triggered by the bot itself (loop prevention)
    if: |
      github.event_name != 'push' ||
      !startsWith(github.event.head_commit.message, 'chore(fladder): update to v')
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Install nix
        uses: cachix/install-nix-action@v31
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes
            access-tokens = github.com=${{ secrets.GITHUB_TOKEN }}

      - name: Check Fladder version
        id: version-check
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          CURRENT=$(grep 'version = ' pkgs/Fladder/default.nix | head -1 | grep -oP '"[^"]+"' | tr -d '"')
          LATEST=$(gh api repos/DonutWare/Fladder/releases/latest --jq .tag_name | sed 's/^v//')
          echo "current=$CURRENT" >> "$GITHUB_OUTPUT"
          echo "latest=$LATEST" >> "$GITHUB_OUTPUT"
          if [ "$(printf '%s\n' "$CURRENT" "$LATEST" | sort -V | head -n1)" = "$LATEST" ] && [ "$CURRENT" = "$LATEST" ]; then
            echo "needs_update=false" >> "$GITHUB_OUTPUT"
          else
            echo "needs_update=true" >> "$GITHUB_OUTPUT"
          fi

      - name: Update pubspec-lock.json
        if: steps.version-check.outputs.needs_update == 'true'
        env:
          LATEST: ${{ steps.version-check.outputs.latest }}
        run: |
          curl -fsSL "https://github.com/DonutWare/Fladder/archive/refs/tags/v${LATEST}.tar.gz" \
            -o /tmp/fladder.tar.gz
          tar xzf /tmp/fladder.tar.gz -C /tmp/
          nix run nixpkgs#yq-go -- -e -o=json . "/tmp/Fladder-${LATEST}/pubspec.lock" \
            > pkgs/Fladder/pubspec-lock.json

      - name: Get new source hash
        if: steps.version-check.outputs.needs_update == 'true'
        id: hash
        env:
          LATEST: ${{ steps.version-check.outputs.latest }}
        run: |
          RAW_HASH=$(nix-prefetch-url --unpack --type sha256 \
            "https://github.com/DonutWare/Fladder/archive/refs/tags/v${LATEST}.tar.gz")
          SRI_HASH=$(nix hash to-sri --type sha256 "$RAW_HASH")
          echo "sri=$SRI_HASH" >> "$GITHUB_OUTPUT"

      - name: Update default.nix
        if: steps.version-check.outputs.needs_update == 'true'
        env:
          LATEST: ${{ steps.version-check.outputs.latest }}
          SRI_HASH: ${{ steps.hash.outputs.sri }}
        run: |
          sed -i "s/version = \"[^\"]*\";/version = \"${LATEST}\";/" pkgs/Fladder/default.nix
          sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"${SRI_HASH}\";|" pkgs/Fladder/default.nix

      - name: Commit and push updates
        if: steps.version-check.outputs.needs_update == 'true'
        env:
          LATEST: ${{ steps.version-check.outputs.latest }}
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add pkgs/Fladder/default.nix pkgs/Fladder/pubspec-lock.json
          git commit -m "chore(fladder): update to v${LATEST}"
          git push
```

## Appendix: build.yml Skip Condition Addition

Add to the `tests` job (after `strategy:` block):

```yaml
    if: |
      github.actor != 'github-actions[bot]' ||
      !startsWith(github.event.head_commit.message, 'chore(fladder): update to v')

Or as a separate check job approach for cleaner reporting:

```yaml
  check-not-bot-update:
    runs-on: ubuntu-latest
    outputs:
      should_build: ${{ steps.check.outputs.should_build }}
    steps:
      - id: check
        run: |
          if [[ "${{ github.actor }}" == "github-actions[bot]" && \
                "${{ github.event.head_commit.message }}" == "chore(fladder): update to v"* ]]; then
            echo "should_build=false" >> "$GITHUB_OUTPUT"
            echo "Skipping build: this is a Fladder bot-update commit"
          else
            echo "should_build=true" >> "$GITHUB_OUTPUT"
          fi
  tests:
    needs: check-not-bot-update
    if: needs.check-not-bot-update.outputs.should_build == 'true'
    strategy:
      # ... existing matrix ...
```
