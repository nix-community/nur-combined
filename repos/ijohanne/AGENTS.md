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
