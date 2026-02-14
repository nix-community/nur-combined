# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal NUR (Nix User Repository) for sharing Nix packages outside nixpkgs. Uses Nix Flakes with flake-parts. Packages are auto-discovered from `pkgs/` via `callDirPackageWithRecursive` in `lib/default.nix`. Pre-built binaries are available from `toyvo.cachix.org`.

## Common Commands

```bash
# Format all files (nixfmt, yamlfmt, mdformat via treefmt)
nix fmt

# Show all available packages and outputs
nix flake show

# Build a specific package
nix build ".#packageName"

# Build all checks for the current system
nix run nixpkgs#nix-fast-build -- --skip-cached --flake ".#checks.$(nix eval --raw --impure --expr builtins.currentSystem)"

# Evaluate all packages (NUR-style validation)
NIX_PAGER=cat nix-env -f . -qa \* --meta --xml \
  --allowed-uris https://static.rust-lang.org \
  --option allow-import-from-derivation true \
  --drv-path --show-trace -I $PWD

# Enter dev shell (or use direnv)
nix develop
```

## Architecture

### Flake Structure

`flake.nix` uses flake-parts with inputs: nixpkgs (unstable), devshell, flake-parts, treefmt-nix. Outputs include `lib`, `overlays`, `modules`, `packages`, `legacyPackages`, and `checks`. The `default.nix` and `overlay.nix` provide legacy (non-flake) entry points.

### Package Auto-Discovery

Packages are not registered manually. The `callDirPackageWithRecursive` function in `lib/default.nix` recursively scans `pkgs/` for `package.nix` files and makes them available. To add a package, create `pkgs/<name>/package.nix` — it will be picked up automatically.

The function uses a fixed-point combinator (`fix`) so packages within this repo can depend on each other.

### Library (`lib/default.nix`)

Key functions:

- `callDirPackageWithRecursive` — auto-discovers and builds all `package.nix` files in a directory tree
- `importDirRecursive` — imports all `.nix` files in a directory, used for overlays and modules
- `isBuildable` — checks a package isn't broken and has free licenses
- `isCacheable` — checks a package doesn't set `preferLocalBuild`
- `flakeChecks` / `flakePackages` — generates CI check and package attributes filtered by system

### Package Patterns

**Simple package** (`pkgs/libpcpnatpmp/package.nix`): A single `package.nix` with a standard derivation.

**Multi-version package** (Minecraft servers): Contains `package.nix` (version management, exports attrset with `recurseForDerivations`), `derivation.nix` (build logic), `versions.json` (version→hash mapping), and `update.py` (fetches new versions from upstream APIs).

**Flavor wrapper** (Catppuccin themes): `package.nix` calls existing nixpkgs packages with different parameter combinations.

### Git Hooks (via devshell)

- **Pre-commit**: Runs `nix fmt` on staged files
- **Pre-push**: Evaluates flake, builds all checks, validates NUR compatibility

### CI

`.github/workflows/build.yml` runs on PRs, pushes to main/master, and daily. It evaluates the flake, builds packages with nix-fast-build, uploads to Cachix, and tests against multiple nixpkgs branches (nixpkgs-unstable, nixos-unstable, nixos-25.05).
