# NUR Packages - Agent Instructions

## Pre-commit verification

Before committing and pushing, always run both of these checks and confirm they pass:

### 1. NUR restricted evaluation (simulates the NUR evaluator)

```sh
NIXPKGS=$(nix-instantiate --eval -E '<nixpkgs>' 2>/dev/null | tr -d '"') && \
NIXPKGS=$(readlink -f "$NIXPKGS") && \
nix-env -f ./default.nix -qa '*' --meta --xml \
  --option restrict-eval true \
  --option allow-import-from-derivation true \
  --drv-path \
  -I nixpkgs="$NIXPKGS" -I "$NIXPKGS" \
  -I "$PWD" -I "$PWD/default.nix" \
  2>&1 | grep -iE 'error|warning|deprecated'
```

This must produce **no output**. Any errors here mean the NUR evaluator will reject the repository.

### 2. Flake check

```sh
nix flake check --no-build
```

Only the dirty-tree warning and incompatible-systems notice are acceptable. No other warnings or errors.

## Triggering NUR re-evaluation

Use sparingly. After pushing a fix, you can manually trigger a re-evaluation:

```sh
curl -XPOST https://nur-update.nix-community.org/update?repo=ijohanne
```

## Key architecture notes

- `nix/sources.nix` resolves flake.lock inputs for non-flake consumers (NUR evaluator, ci.nix). It uses `pkgs.fetchFromGitHub` (not `builtins.fetchTarball`) so that source fetching happens at build time, not evaluation time. This is required because NUR evaluates with `--option restrict-eval true`.
- In flake context, sources come from flake inputs directly and `sources.nix` is not used.
- `overlay.nix` must use `final: prev:` argument names (not `self: super:`), as `nix flake check` enforces this.

## Issue Tracking

This project uses **vardrun** for issue tracking (not GitHub Issues).
When the user says "issue", they mean a vardrun issue.
Run `vardrun prime` for full workflow context — do this at the start of every session.

**Quick reference:**
- `vardrun ready` — find unblocked work
- `vardrun create "Title" --type task --priority 2` — create issue
- `vardrun update <id> --status in_progress` — **take/claim** an issue (auto-assigns you)
- `vardrun update <id> --description "Human-readable summary"` — what the issue is about (for non-developers)
- `vardrun update <id> --implementation @plan.md` — technical implementation details (markdown, for developers)
- `vardrun close <id>` — complete work
- `vardrun show <id> --json` — view issue details (JSON for agents)
- `vardrun list --json` — list all open issues (JSON for agents)
- `vardrun sync` — sync with remote (run after every mutation)

**Taking an issue** = `vardrun update <id> --status in_progress` then `vardrun sync`.
"Take", "claim", "work on", "pick up" all mean this. Always sync after so changes
are visible in the TUI and web interface.

**Completing work:** When committing after finishing an issue, also close it and sync:
```
vardrun close <id>
vardrun sync
git add <files> && git commit -m "..."
git push
```

**For agents:** Use `--json` on any command to discover field structure at runtime.
For full workflow details and all commands: `vardrun prime`
