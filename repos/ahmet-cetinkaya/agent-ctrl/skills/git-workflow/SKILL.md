---
name: git-workflow
description: Inspect status and history, create scoped commits, perform authorized history operations, or prepare a draft PR safely. Use for explicit Git or PR requests; do not commit, rewrite, push, or open a PR during ordinary implementation.
---

# Git Workflow

## Trigger

Use for `STATUS`, `HISTORY`, `COMMIT`, `REBASE`, or `PR` work explicitly requested by the user.

## Non-trigger

Do not activate to stage or deliver ordinary implementation implicitly. A request to edit code does not authorize commit, push, history rewrite, PR, merge, release, or deploy. The one standing exception is an approved plan whose `commits` strategy names local commits; the executor makes those with the COMMIT guidance and nothing beyond them.

## Modes

- **STATUS** — inspect branch, worktree, staged and unstaged changes, upstream, and conflicts without mutation.
- **HISTORY** — answer with log, show, blame, search, bisect, or reflog evidence.
- **COMMIT** — use [commit guidance](references/commit.md): inspect full diffs, preserve unrelated work, build atomic groups, stage specific paths or hunks, follow local message style, run relevant checks, and verify the resulting commit.
- **REBASE** — require explicit rewrite authorization, account for dirty and published work, define recovery, resolve by intent, and never bypass hooks or use plain force push.
- **PR** — use [PR guidance](references/pr.md) after readiness is proven.

Read [history guidance](references/history.md) for investigative or rewriting details. Never alter Git configuration, skip hooks, stage broad unknown changes, force-push a protected branch, or merge unless separately authorized.
