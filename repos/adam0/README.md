<div align="center">
  <img src="./assets/nix-logo.png" alt="Nix logo" width="112" />

  # adam0's NUR repository

  Personal [NUR](https://github.com/nix-community/NUR) repository with curated packages, plugin sets, and a Home Manager module for OpenCode plugins.

  [![CI](https://img.shields.io/github/actions/workflow/status/adam01110/nur/build.yml?branch=main&style=flat-square&label=CI&labelColor=504945&color=cc241d)](https://github.com/adam01110/nur/actions/workflows/build.yml)
  [![Repo Size](https://img.shields.io/github/repo-size/adam01110/nur?style=flat-square&label=repo%20size&labelColor=504945&color=3c3836)](https://github.com/adam01110/nur)
  [![Cachix](https://img.shields.io/badge/cachix-adam01110--nur-689d6a?style=flat-square&labelColor=504945&color=689d6a)](https://adam01110-nur.cachix.org)
  [![NUR](https://img.shields.io/badge/NUR-adam0-458588?style=flat-square&labelColor=504945&color=458588)](https://github.com/nix-community/NUR)
  [![Flakes](https://img.shields.io/badge/Nix-flakes-b16286?style=flat-square&labelColor=504945&color=b16286)](https://nixos.wiki/wiki/Flakes)

  [Overview](#overview) - [Development](#development) - [Automation](#automation) - [Layout](#layout) - [Notes](#notes)
</div>

This repository exports a small personal package collection with a few clear focus areas: OpenCode tooling, Yazi plugins, Spicetify extensions, Fish plugins, cursor and icon themes, and a handful of standalone CLI packages.

## Overview

- Flake-based NUR repository built with `flake-parts` and auto-discovered package trees.
- Currently contains 40+ package definitions, including OpenCode plugins, Yazi plugins, Spicetify extensions, and a Fish plugin set.
- And Home Manager module for enabling packaged OpenCode plugins declaratively.
- CI evaluates and builds the repository across multiple nixpkgs channels and pushes cacheable outputs to Cachix.

## Development

From the repository root:

```bash
# Inspect flake outputs
nix flake show

# Enter the dev shell
nix develop

# Format the repository
nix fmt

# Build a package
nix build .#modular-mcp
```

Formatting is configured through `treefmt-nix`.

## Automation

- `build.yml`: evaluates the repository and builds cacheable outputs against `nixpkgs-unstable`, `nixos-unstable`, and `nixos-stable`.
- `update-packages.yml`: runs `./scripts/update-all-packages.sh` and opens a signed pull request.
- `update-flake-lock.yml`: refreshes `flake.lock` weekly.

## Layout

| Path | Role |
| --- | --- |
| `flake.nix` | Flake entrypoint using `flake-parts` |
| `default.nix` | Classic NUR export surface |
| `ci.nix` | CI build/cache selection |
| `parts/` | Flake parts for packages, dev shell, and formatting |
| `pkgs/` | Package definitions and grouped package sets |
| `hm-modules/` | Exported Home Manager modules |
| `scripts/` | Maintenance helpers |

## Notes

- `modules/` and `overlays/` are currently present as export points, but the main content of the repository lives under `pkgs/` and `hm-modules/`.
- Package discovery is mostly automatic through recursive directory traversal, so adding a new package usually means adding a new `default.nix` in the right subtree.
