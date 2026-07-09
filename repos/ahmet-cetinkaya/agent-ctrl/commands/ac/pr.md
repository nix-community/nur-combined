---
name: ac:pr
description: "Pre-submission analysis + automated draft PR creation via GitHub CLI: validate (tests, conflicts, duplicate-PR), discover (template, artifacts), push, create, verify CI."
category: workflow
complexity: standard
mcp-servers: []
personas: []
---

# `/ac:pr` - Create Pull Request

**Goal:** Run a comprehensive pre-submission analysis and create a **draft** Pull Request
from the current branch to the target branch, using the GitHub CLI (`gh`).

## Usage

```bash
/ac:pr [base-branch] [--draft]   # base defaults to main; PRs are draft by default
```

Parse arguments: treat any non-flag token as the **base branch** (default `main`); flags
like `--draft` are recognized (draft is the default regardless — see Phase 4).

---

## Phase 1 — VALIDATE (fail-fast)

Identify the **source branch** (current HEAD) and **base branch**. Then check, stopping on
the first hard failure:

```bash
git branch --show-current
git status --short
git log origin/<base>..HEAD --oneline
gh pr list --head <branch> --json number
```

| Check | Condition | Action if failed |
|---|---|---|
| `gh` available & authed | `gh auth status` ok | **STOP**: install <https://cli.github.com/> / run `gh auth login`. |
| Not on base branch | current branch ≠ base | **STOP**: "Switch to a feature branch first." |
| Clean working dir | no uncommitted changes | **STOP**: "Uncommitted changes — commit or stash first." |
| Has commits ahead | `git log origin/<base>..HEAD` not empty | **STOP**: "No commits ahead of `<base>`. Nothing to PR." |
| No existing PR | `gh pr list --head <branch>` empty | **STOP**: "PR already exists: #<n>. `gh pr view <n> --web`." |
| Test gate | repo test command passes (`npm test`, `pytest`, …) | **STOP** with the failure output. |
| No merge conflicts | `git merge-tree` dry-run vs `<base>` is clean | **STOP** and list conflicting paths. |

**Branch naming policy:** validate the source branch against
`^(feat|fix|docs|style|refactor|perf|test|chore)\/[\w-]+\S$`. If it doesn't match, **WARN**
but do not abort.

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

- **Title**: Conventional Commit format (`feat: …`, `fix: …`). Single commit → use its
  message; multiple → dominant type. **Report any non-compliant commit messages** in the
  final feedback.
- **Change summary**: group commits by type/area; categorize files (source, tests, docs,
  config, migrations).

### Planning artifacts
Reference these in the PR body if present: `.claude/prds/`, `.claude/plans/`,
`.claude/PRPs/{prds,plans,reports}/` (legacy).

---

## Phase 3 — PUSH

> Need to stage/commit pending work or craft a Conventional-Commit message first? Use
> **`/sc:git`** before this phase. `/ac:pr` assumes commits already exist.

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

**Body** — if a template was found, fill each section (keep all sections; mark "N/A" rather
than deleting). Otherwise use:

```markdown
### 🚀 Motivation and Context

[Summarize the feature/fix/chore from the commit messages and branch name.]

### ⚙️ Implementation Details

[Technical approach, key changes, relevant considerations.]

### 📋 Checklist for Reviewer

- [ ] Tests passed locally.
- [ ] Commit history is clean and descriptive.
- [ ] Documentation updated (if applicable).
- [ ] Code quality standards met (e.g., linter passed).

### 🔗 Related [optional]

[Related issues/PRs with Closes/Fixes/Relates to #N. Do not link this PR to itself.]
```

**Create:**
```bash
gh pr create --base <base> --title "<title>" --body "<body>" --draft
```
- **Draft:** ALWAYS `--draft`. Never create a non-draft PR.
- **Labels:** map branch prefix → label (`feat/`→`enhancement`, `fix/`→`bug`, …); apply if
  the label exists in the repo.
- **Assignee:** `--assignee @me`.
- **Reviewers:** if a `CODEOWNERS` file exists, assign the relevant owners; otherwise skip
  (do not invent a reviewer).

---

## Phase 5 — VERIFY

```bash
gh pr view --json number,url,title,state,baseRefName,headRefName,additions,deletions,changedFiles
gh pr checks --json name,status,conclusion 2>/dev/null || true
```

---

## Phase 6 — REPORT

```
PR #<number>: <title>   [draft]
URL: <url>
Branch: <head> → <base>
Changes: +<additions> -<deletions> across <changedFiles> files
CI Checks: <status summary | "pending" | "none configured">
Artifacts referenced: <any PRDs/plans linked in the body>
Non-compliant commits: <list, or "none">

Next:
  gh pr view <number> --web   → open in browser
  /ac:review <number>         → review the PR
  gh pr ready <number>        → mark ready when checks pass
```

If aborted, state the specific reason (e.g., **Tests Failed**, **Merge Conflicts**,
**PR Exists**) with the relevant output.

---

## Edge Cases

- **Large PR (>20 files):** warn about size; suggest splitting if logically separable.
- **Multiple PR templates:** list them and ask the user to choose.
- **Force push:** only `--force-with-lease` after a clean rebase; never `--force`.
