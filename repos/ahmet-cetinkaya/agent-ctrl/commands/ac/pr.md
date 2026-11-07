---
name: ac:pr
description: "Pre-submission analysis + automated draft PR creation via GitHub CLI: validate (tests, conflicts, duplicate-PR), discover (template, artifacts), push, create, verify CI."
---

# `/ac:pr` — Create Pull Request

**Goal:** Run a comprehensive pre-submission analysis and create a **draft** Pull Request from the current branch to the target branch, using the GitHub CLI (`gh`).

Applies the **`git-workflow`** skill for branch-naming, commit, and PR-description conventions, **`technical-writing`** for the PR body text, and the shared safety rule before any push or force-update.

## Usage

```bash
/ac:pr [base-branch]   # base defaults to main; the PR is always a draft
```

Parse arguments: the first non-flag token is the **base branch** (default `main`).

---

## Phase 0 — ARCHIVE SWEEP

Run the [legacy check](../../skills/plan-execution/references/run-state.md#migrating-from-the-legacy-layout) first; if it stops, stop the command. Then apply the Archive section of the [run-state contract](../../skills/plan-execution/references/run-state.md) to the finished items in `.agents/work/`.

Use an item's `branch` value only if it matches `^[A-Za-z0-9._/-]+$`, and pass it single-quoted. Otherwise skip the item and report it as `unsafe branch name`. Make one standalone call per distinct `branch` of finished items:

```
gh pr list --head '<branch>' --author '@me' --state merged --json number,mergedAt
```

Each `gh` call runs alone, with no pipe, chain, redirect, or `$(...)`.

- Archive an item to `.agents/archive/<YYYY>/<id>/` only when a returned PR's `mergedAt` is later than the item's `updated_at`, compared as UTC instants.
- Report every item in `.agents/work/` that is not archived, with one reason: `not finished`, `no branch`, `unsafe branch name`, `no merged PR`, `merged before updated_at`, `archive not ignored`, or `archive exists`, using the first reason in this list that applies.
- If `gh` is unavailable or unauthenticated, skip and report the whole sweep; Phase 1 then stops as today.
- The sweep never writes to the remote.

---

## Phase 1 — VALIDATE (fail-fast)

Identify the **source branch** (current HEAD) and **base branch**. Then check, stopping on the first hard failure:

```bash
git branch --show-current
git status --short
git log origin/<base>..HEAD --oneline
git log --format='%h %s' origin/<base>..HEAD --extended-regexp --grep='^(fixup!|amend!)'
gh pr list --head <branch> --json number
```

| Check | Condition | Action if failed |
| --- | --- | --- |
| `gh` available & authed | `gh auth status` ok | **STOP**: install <https://cli.github.com/> / run `gh auth login`. |
| On a feature branch | current branch ≠ base | **STOP** if on base: "Switch to a feature branch first." |
| Clean working dir | no uncommitted changes | **STOP**: "Uncommitted changes — commit or stash first." |
| Has commits ahead | `git log origin/<base>..HEAD` not empty | **STOP**: "No commits ahead of `<base>`. Nothing to PR." |
| No pending fixups | no local `fixup!` or `amend!` commits | **STOP**: request confirmation to autosquash local fixups, rerun checks, then continue. |
| No existing PR | `gh pr list --head <branch>` empty | **STOP**: "PR already exists: #<n>. `gh pr view <n> --web`." |
| Test gate | repo test command passes (`npm test`, `pytest`, …) | **STOP** with the failure output. |
| No merge conflicts | `git merge-tree` dry-run vs `<base>` is clean | **STOP** and list conflicting paths. |

**Branch naming policy:** validate the source branch against `^(feat|fix|docs|style|refactor|perf|test|chore)\/[\w-]+$`. If it doesn't match, **WARN** but do not abort.

For a deeper readiness gate than the test command alone, run `/ac:verify` on the final committed state and stop on `NOT_READY` or `INCONCLUSIVE`.

---

## Phase 2 — DISCOVER

### PR template

Search in order; if found, use its structure for the PR body:

1. `.github/PULL_REQUEST_TEMPLATE/` (if multiple, list and let the user choose, else `default.md`)
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `.github/pull_request_template.md`
4. `docs/pull_request_template.md`

### Commit & file analysis

```bash
git log origin/<base>..HEAD --format="%h %s" --reverse
git diff origin/<base>..HEAD --stat
git diff origin/<base>..HEAD --name-only
```

- **Title**: Conventional Commit format (`feat: …`, `fix: …`). Single commit → use its message; multiple → dominant type. **Report any non-compliant commit messages** in the final feedback.
- **Change summary**: group commits by type/area; categorize files (source, tests, docs, config, migrations).

### Planning artifacts

Reference the plans of work items whose `state.json` `branch` equals the head branch (`.agents/work/<id>/plan.md`), summarized in the body because they are git-ignored, plus any repository-specific product or design documents the branch implements.

---

## Phase 3 — PUSH

> Need to stage/commit pending work or craft a Conventional-Commit message first? Use the `git-workflow` skill in `COMMIT` mode before this phase. `/ac:pr` assumes commits already exist.

Before the branch's first push, apply the `git-workflow` skill's commit policy. If local `fixup!`/`amend!` commits exist, autosquash them into their targets, inspect the rewritten history, and rerun relevant checks, but obtain explicit user confirmation before the rebase. Never autosquash a published branch without explicit authorization.

```bash
git push -u origin HEAD
```

If push fails due to divergence:

```bash
git fetch origin
git rebase origin/<base>
git push --force-with-lease -u origin HEAD   # never --force
```

If rebase conflicts occur, **STOP** and inform the user.

---

## Phase 4 — CREATE

**Body** — if a template was found, fill each section (keep all sections; mark "N/A" rather than deleting). Otherwise use the structure below.

Use GitHub alert blocks when they clarify skimmable PR context: `NOTE` for useful context, `TIP` for optional success guidance, `IMPORTANT` for required reviewer/user information, `WARNING` for immediate risk, and `CAUTION` for negative consequences. Use Mermaid diagrams when they make architecture, data flow, state transitions, or rollout sequencing easier to review than prose alone.

```markdown
### 🚀 Context

[Summarize the feature/fix/chore from the commit messages and branch name.]

#### 🔗 Related [optional]

Always a Markdown list — one reference per line, never inline prose or a comma-separated run. Use the closing keyword that matches the relationship, and keep one item per issue/PR even when several share a keyword.

- Closes #N
- Fixes #N
- Relates to #N
- Related PR: #N

Omit the whole section when there is nothing to link. Do not link this PR to itself.

---

### ⚙️ Implementation Details

[Technical approach, key changes, relevant considerations.]

---

### 📋 Checklist for Reviewer

- [ ] Tests passed locally.
- [ ] Commit history is clean and descriptive.
- [ ] Documentation updated (if applicable).
- [ ] Code quality standards met (e.g., linter passed).
```

**Create:**

```bash
gh pr create --base <base> --title "<title>" --body "<body>" --draft
```

- **Draft:** pass `--draft`; marking the PR ready is the user's own step (Phase 6).
- **Labels:** map branch prefix → label (`feat/`→`enhancement`, `fix/`→`bug`, …); apply if the label exists in the repo.
- **Assignee:** `--assignee @me`.
- **Reviewers:** if a `CODEOWNERS` file exists, assign the relevant owners; otherwise skip (do not invent a reviewer).

---

## Phase 5 — VERIFY

```bash
gh pr view --json number,url,title,state,baseRefName,headRefName,additions,deletions,changedFiles
gh pr checks --json name,status,conclusion
```

Run each call alone. A non-zero exit from `gh pr checks` (no checks yet, pending, or failing checks) does not fail this phase; report its output and exit status in Phase 6.

Once `gh pr view` confirms the draft PR, open it in the user's browser:

```bash
gh pr view <number> --web
```

Only after creation is confirmed, never for a PR that was not created. If it fails or the environment is headless, do not retry; print the URL in the report instead.

---

## Phase 6 — REPORT

```
PR #<number>: <title>   [draft]
URL: <url>
Branch: <head> → <base>
Changes: +<additions> -<deletions> across <changedFiles> files
CI Checks: <status summary | "pending" | "none configured">
Artifacts referenced: <any plans/specs linked in the body>
Non-compliant commits: <list, or "none">
Archived: <.agents/archive/<YYYY>/<id>/ paths, or "none">
Archive skipped: <items with reasons, or "none">

Next:
  gh pr view <number> --web   → reopen in browser (already opened once in Phase 5)
  /ac:review <number>         → review the PR
  /ac:pr-address              → address incoming review feedback
  gh pr ready <number>        → mark ready when checks pass
```

If aborted, state the specific reason (e.g., **Tests Failed**, **Merge Conflicts**, **PR Exists**) with the relevant output.

## Next Step

After the report block, close the turn by naming the single best next command:

- Draft PR created, checks pending or green → `/ac:review <number>` for an independent pass
- Reviewers left feedback → `/ac:pr-address`
- Validation aborted on a failing gate → `/ac:fix <failing check>`, then rerun `/ac:pr`
- Checks green and review clean → tell the user to run `gh pr ready <number>` themselves

Name exactly one recommendation. Never mark the PR ready, merge, or deploy.

---

## Edge Cases

- **Large PR (>20 files):** warn about size; suggest splitting if logically separable.
- **Multiple PR templates:** list them and ask the user to choose.
- **Force push:** only `--force-with-lease` after a clean rebase; never `--force`.

## Boundaries

- The command authorizes pushing the current branch and creating a **draft** PR. It does not authorize merge, release, deploy, marking ready, or rewriting published history.
- The archive sweep's move of finished, merged work items under `.agents/` is the command's only local file change outside its existing behavior; the sweep only reads merge state from the remote.
- Never bypass hooks, use plain `--force`, or push when validation or the readiness gate is not clean.
