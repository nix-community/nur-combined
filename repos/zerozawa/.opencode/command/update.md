---
description: Update package to new version
---

Update a package to a new version.

## Update Steps

1. **Find new version**: Check upstream repository for latest release
2. **Update version**: Change `version = "..."` in package file
3. **Update hash**: Use `lib.fakeHash`, build, copy real hash from error
4. **Test build**: `nix-build -A <package>`
5. **Commit**: `pkg: update <package> to <version>`

## Hash Update Methods

### Method 1: Build with fakeHash
```nix
hash = lib.fakeHash;
```
Build fails, copy real hash from error message.

### Method 2: nix-prefetch-url
```bash
nix-prefetch-url --unpack "https://github.com/<owner>/<repo>/archive/refs/tags/v<version>.tar.gz"
```

### Method 3: nix-prefetch-github
```bash
nix-prefetch-github <owner> <repo> --rev v<version>
```

## For Go/Rust Packages

Also update:
- `vendorHash` (Go)
- `cargoHash` or `cargoLock` (Rust)

Same fakeHash trick works for these.

## Arguments

$ARGUMENTS - Package name to update
