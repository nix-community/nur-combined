---
description: Create commits that match this repo's current git style
---

Commit changes using the semantic style already present in this repository.

## Preferred message style

Current history trends strongly toward semantic messages such as:

- `feat(pkgs): add hyprland-mcp-server package`
- `fix(pkgs): correct grub-theme-yorha license metadata`
- `docs(readme): add hyprland-mcp-server package entry`
- `feat(lib): add configurable fetchPixiv helper`

## Common prefixes in this repo

- `feat(pkgs): ...`
- `fix(pkgs): ...`
- `chore(pkgs): ...`
- `feat(lib): ...`
- `refactor(default): ...`
- `docs(readme): ...`
- `docs(opencode): ...`

## Before committing

1. Build or evaluate the affected package(s) or docs target.
2. Ensure attr names and package references match `default.nix`.
3. Keep docs changes aligned with current repo reality, not stale package lists.

## Examples

- `feat(lib): add configurable fetchPixiv helper`
- `docs(readme): refresh package inventory and usage`
- `docs(opencode): align command docs with current exports`

!`git diff && printf '\n---STAGED---\n' && git diff --cached && printf '\n---STATUS---\n' && git status --short`
