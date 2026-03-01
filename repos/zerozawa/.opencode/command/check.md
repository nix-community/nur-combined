---
description: Check package evaluation and build status
---

Check if packages can be evaluated and built.

## Evaluation Check

```bash
# Check if package evaluates
nix-instantiate -A <package-name>

# Check all packages evaluate
nix-instantiate ci.nix -A cacheOutputs --dry-run
```

## Build Check

```bash
# Dry run (shows what would be built)
nix-build -A <package-name> --dry-run

# Full build
nix-build -A <package-name>
```

## Flake Check

```bash
# Validate flake
nix flake check

# Show all outputs
nix flake show
```

## CI Simulation

```bash
# Build what CI builds
nix-build ci.nix -A cacheOutputs
```

## Arguments

$ARGUMENTS - Package name to check (optional, checks all if not provided)

!`nix-instantiate -A ${ARGUMENTS:-ci.nix}`
