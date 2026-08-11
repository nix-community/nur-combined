---
name: ac:pr-address
description: "Review and fix code review comments from the current branch's Pull Request."
category: workflow
complexity: standard
mcp-servers: []
personas: []
---

# `/ac:pr-address` - Address PR Review Comments

Fetch the code review comments on the Pull Request for the **current Git branch**, list them
newest-first, then plan and implement the fixes — one semantic commit per issue.

For general bugs, regressions, failing tests, build failures, or runtime errors, use
**`/ac:fix`** instead.

Applies the **`git-workflow`** skill for commit-message conventions when committing fixes.

## Usage

```bash
/ac:pr-address   # auto-detects the PR of the current branch
```

If `gh pr view` finds no PR for the current branch, **STOP** and report: "No open PR for the
current branch — push and open one with `/ac:pr` first."

## Fetch Comments

Detect the PR and fetch review summaries, review (diff) comments, and issue-level comments:

```bash
# Current PR info (number + repo)
pr_info=$(gh pr view --json number,headRepository --jq '{number: .number, repo: .headRepository.nameWithOwner}')
pr_number=$(echo "$pr_info" | jq -r '.number')
repo=$(echo "$pr_info" | jq -r '.repo')

# Review summaries (Approve / Request changes / Comment), newest first
gh api repos/$repo/pulls/$pr_number/reviews --jq 'sort_by(.submitted_at // .created_at) | reverse | .[] | {body, state, submitted_at, user}'
# Diff/review comments, newest first
gh api repos/$repo/pulls/$pr_number/comments --jq 'sort_by(.created_at) | reverse | .[] | {body, path, line, created_at, user}'
# Issue-level PR comments (general discussion), newest first
gh api repos/$repo/issues/$pr_number/comments --jq 'sort_by(.created_at) | reverse | .[] | {body, created_at, user}'
```

## Step 1: Analysis & Plan

- Identify the specific issues raised (bugs, style violations, performance concerns, or architectural suggestions).
- Summarize the key problems in a structured list.
- Develop an action plan: prioritized steps, required code changes/refactors, potential
  impacts on existing functionality, and any dependencies or follow-up reviews needed.
- Present this summary and plan in markdown before making changes.

## Step 2: Implementation

For each identified issue:
- Apply the fix in the codebase.
- Run tests and linters before committing.
- Commit with a semantic message including the module affected:
  `<type>(<module>): <description>`
  Examples:
  - `fix(auth): correct null pointer in login service`
  - `style(ui): format button component according to lint rules`
- Because an open PR normally means the branch is already published, default to a normal
  semantic follow-up commit. Use `--fixup` plus autosquash only when the target commit is
  provably unpushed, or when the user explicitly authorizes rewriting the remote branch and a
  later `git push --force-with-lease`; never use plain `--force`.

Ensure each commit addresses a single issue for clarity and traceability.

## Output

The markdown summary + action plan, followed by the applied fixes committed sequentially
(one commit per issue), with tests and linters passing before each commit.
