---
name: Nix Packaging
description: Package new software or update existing packages using Nix
---

# Overview

Create new Nix packages or update existing ones, with language-specific examples and guidance.

## Workflow: Creating a New Package

1. Identify the software source: internal to this repo or external (e.g., a GitHub repository).
2. Determine the programming language(s) used.
3. Analyze the software structure (build system, dependencies, configuration files).
4. Create the package following language-specific guidance below.
5. Optionally, integrate the package into the current project (e.g., add to overlay and expose via `packages` in `flake.nix`).
6. Test iteratively: run `nix build .#<package-name>`, read errors, fix issues, and rebuild until successful.

## Workflow: Updating an Existing Package

Typically, update the `version` and source fetching attributes (e.g., `fetchFromGitHub`). The `hash` field must also be updated using one of these methods:

**Method 1: Calculate the new hash directly**
```bash
# Get the hash
nix-prefetch-url --type sha256 --unpack https://github.com/owner/repo/archive/refs/tags/v<NEW_VERSION>.tar.gz
# Convert to SRI format
nix hash convert --hash-algo sha256 <old-hash>
```

**Method 2: Let Nix tell you the hash**
Set `hash = "";` and run the build. The error message will display the correct hash.

For language-specific update steps, see the references below.

# Language-Specific Packaging Skills

- [Python](./python/python.md) - Packaging Python modules
- [Rust](./rust/rust.md) - Packaging Rust applications
- [JavaScript/TypeScript](./js/js.md) - Packaging npm applications
