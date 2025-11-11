# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NUR (Nix User Repository) package repository based on the nix-community template. NUR allows users to share Nix packages, NixOS modules, overlays, and library functions that aren't in the main nixpkgs repository.

## Core Architecture

### Entry Points

- **default.nix** - Main entry point that exports all packages, lib functions, modules, and overlays. Takes `pkgs` as argument (defaults to `<nixpkgs>`). Reserved attribute names: `lib`, `modules`, `overlays`.
- **flake.nix** - Flake-based entry point exposing `legacyPackages` and `packages` outputs for all systems.
- **ci.nix** - Defines buildable and cacheable packages for CI, filtering by meta.broken, license.free, and preferLocalBuild attributes.
- **overlay.nix** - Exposes all non-reserved packages as a nixpkgs overlay for users who don't want the full NUR namespace.

### Directory Structure

- **pkgs/** - Package derivations (e.g., `pkgs/example-package/default.nix`)
- **lib/** - Custom library functions exported via `lib` attribute
- **modules/** - NixOS modules exported via `modules` attribute
- **overlays/** - Nixpkgs overlays exported via `overlays` attribute

### Reserved Names

The names `lib`, `modules`, and `overlays` are special/reserved in default.nix and cannot be used as package names. These are filtered out by overlay.nix and ci.nix.

## Building and Testing

### Build packages locally
```bash
# Build a single package
nix-build -A example-package

# Build using flakes
nix build .#example-package

# Build all packages for CI
nix-build ci.nix -A cacheOutputs
```

### Evaluation check
```bash
# Check that all packages evaluate correctly
nix-env -f . -qa \* --meta --xml \
  --allowed-uris https://static.rust-lang.org \
  --option restrict-eval true \
  --option allow-import-from-derivation true \
  --drv-path --show-trace \
  -I nixpkgs=$(nix-instantiate --find-file nixpkgs) \
  -I $PWD
```

## Adding New Packages

1. Create package directory under `pkgs/` (e.g., `pkgs/mypackage/`)
2. Write derivation in `pkgs/mypackage/default.nix`
3. Add to default.nix exports: `mypackage = pkgs.callPackage ./pkgs/mypackage { };`
4. For Qt5 packages use: `pkgs.libsForQt5.callPackage`
5. Mark broken packages with `meta.broken = true;` to prevent CI failures

## CI System (ci.nix)

The CI build system filters packages based on:
- **isBuildable**: Excludes packages with `meta.broken = true` or non-free licenses
- **isCacheable**: Further excludes packages with `preferLocalBuild = true`

CI builds `cacheOutputs` which includes all outputs of cacheable packages. The system recursively flattens packages marked with `recurseForDerivations = true`.

## GitHub Actions Workflow

Located at `.github/workflows/build.yml`:
- Runs on PR, push to main/master, daily at 2:51, and manual dispatch
- Tests against multiple nixpkgs channels (unstable, nixos-unstable, nixos-25.05)
- Builds using `nix-build-uncached` to avoid rebuilding cached derivations
- Optionally pushes to Cachix (requires CACHIX_SIGNING_KEY or CACHIX_AUTH_TOKEN secret)
- Triggers NUR update webhook after successful build
