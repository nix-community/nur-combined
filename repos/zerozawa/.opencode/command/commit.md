---
description: git commit with NUR-style message
---

Commit changes to the NUR repository.

## Commit Message Prefixes

Use these prefixes for commit messages:
- `pkg:` - New package or package updates
- `fix:` - Bug fixes in existing packages
- `meta:` - Metadata changes (license, description, platforms)
- `ci:` - CI/workflow changes
- `chore:` - Maintenance tasks (formatting, cleanup)
- `docs:` - Documentation updates

## Format

```
<prefix> <package-name>: <short description>
```

Examples:
- `pkg: add waybar-vd v0.1.1`
- `pkg: update mihomo-smart to 0-unstable-d45278b`
- `fix: JMComic-qt missing libxcrypt-legacy`
- `meta: fortune-mod-zh add sourceProvenance`

## Pre-commit Checks

1. Package builds: `nix-build -A <package>`
2. Hash is valid (not fakeHash)
3. License is accurate

## Git Commands

!`git diff`

!`git diff --cached`

!`git status --short`
