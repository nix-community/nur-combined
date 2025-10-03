# NUR Packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/lmdevv/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

<!-- [![Cachix Cache](https://img.shields.io/badge/cachix-<YOUR_CACHIX_CACHE_NAME>-blue.svg)](https://<YOUR_CACHIX_CACHE_NAME>.cachix.org) -->

## Packages

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
