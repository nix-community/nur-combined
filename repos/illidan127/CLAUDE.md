# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

This is a [NUR](https://github.com/nix-community/NUR) (Nix User Repository) for user **chap9**. It packages applications not yet in nixpkgs including aider-chat, dockerfmt, yapf, python-lsp-server, and cmake-language-server.

## Build & test commands

```bash
# Build all packages (evaluation check)
nix-env -f . -qa \* --meta --xml --option restrict-eval true --option allow-import-from-derivation true --drv-path --show-trace -I nixpkgs=$(nix-instantiate --find-file nixpkgs) -I $PWD

# Build a single package via default.nix (falls back to <nixpkgs>)
nix-build -A aider-chat

# Build via flake
nix build .#aider-chat

# Build cacheable outputs as CI does
nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached ci.nix -A cacheOutputs

# Check nixpkgs version
nix-instantiate --eval -E '(import <nixpkgs> {}).lib.version'
```

## Architecture

```
pkgs/<name>/default.nix   — individual package derivations
default.nix               — aggregates packages + lib, modules, overlays
overlay.nix               — overlay exposing packages into nixpkgs namespace
ci.nix                    — filters buildable/cacheable packages for CI
flake.nix                 — flake entrypoint (legacyPackages + packages)
lib/                      — shared library functions (currently empty)
modules/                  — NixOS modules (currently empty)
overlays/                 — nixpkgs overlays (currently empty)
```

**Key conventions:**
- Packages receive `pkgs` as an argument — never import `<nixpkgs>` inside package files.
- `default.nix` returns a set with packages plus the reserved `lib`, `modules`, `overlays` attributes.
- `ci.nix` uses `ci.nix`/`flattenPkgs` to walk the package tree and split derivations into `buildPkgs`/`cachePkgs` filtered by `meta.broken`, license freedom, and `preferLocalBuild`.
- Python packages use `buildPythonApplication` with pre-built wheels (`format = "wheel"`, `dontBuild = true`, `doCheck = false`).
- Go packages use `buildGo124Module` with vendored dependencies (`vendorHash`).
- Mark broken packages with `meta.broken = true` so CI skips them.

## CI

GitHub Actions in `.github/workflows/build.yml` triggers on PR, push to main/master, a daily cron (`51 2 * * *`), and manual dispatch. It tests against three nixpkgs channels (unstable, nixos-unstable, nixos-25.05). Build results are cached via Cachix (cache name: `chap9`). On success, it pings `nur-update.nix-community.org` to notify the NUR registry.
