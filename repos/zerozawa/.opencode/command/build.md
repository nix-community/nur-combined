---
description: Build and test Nix packages
---

Build and test a Nix package from this NUR repository.

## Build Commands

Single package:
```bash
nix-build -A <package-name>
```

All CI outputs:
```bash
nix-build ci.nix -A cacheOutputs
```

Via flake:
```bash
nix build .#<package-name>
```

## Test Checklist

1. Package builds without errors
2. Binary runs correctly (if applicable)
3. `meta` block is complete (description, homepage, platforms, license, sourceProvenance)
4. No IFD issues in pure evaluation mode

## Common Fixes

- Missing hash: Use `lib.fakeHash`, build fails, copy real hash
- Platform issues: Check `meta.platforms` matches target
- License format: Use list form `license = with licenses; [mit];`

!`nix-build -A $ARGUMENTS`
