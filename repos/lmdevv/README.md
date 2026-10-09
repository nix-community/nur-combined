# NUR Packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/lmdevv/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

<!-- [![Cachix Cache](https://img.shields.io/badge/cachix-<YOUR_CACHIX_CACHE_NAME>-blue.svg)](https://<YOUR_CACHIX_CACHE_NAME>.cachix.org) -->

## Packages

### codexbar-cli

CodexBar's CLI for AI coding-provider usage, quotas, and spending. Packaged from
the official static musl releases for x86_64 and ARM64 Linux, with the provider
resource bundle preserved beside the executable.

Use `nix run github:lmdevv/nur-packages#codexbar-cli -- --version` or install
`pkgs.nur.repos.lmdevv.codexbar-cli` through the NUR overlay. A daily GitHub
Actions workflow updates the version and both hashes, validates the package,
and notifies NUR. Run `bash scripts/update-codexbar-cli.sh` manually, or use
`FORCE_VERSION=0.73.0 bash scripts/update-codexbar-cli.sh` to refresh a release.

### cursor-agent (unfree)

The `cursor-agent` CLI is distributed as a prebuilt binary bundle by Cursor
(license: unfree). This package mirrors the upstream tarball and installs a
`cursor-agent` executable.

### code-cursor (unfree)

Fast-moving, personally maintained build of the Cursor editor. The official
nixpkgs is slower but more stable, you should opt for that one if you want
stability, if you need latest releases more quickly, you can use this nur
version.

### commiter

Ultra-fast, minimal AI commit helper I made specifically for own workflow, it is
quite simple. Nixpkgs hosts richer alternatives (opencommit, geminicommit, etc.)
if you need more features.

### paper-design (unfree)

Official Paper desktop app, a connected design canvas with local MCP integration.
Packaged from the upstream x86_64 Linux AppImage and Apple-silicon macOS DMG.
