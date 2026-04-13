---
description: Check evaluation, flake exports, and CI-relevant build status
---

Check whether a package or the repository evaluates cleanly.

## What to target

- Use attribute names exported by `default.nix`.
- `lib`, `modules`, and `overlays` are reserved attrs, not package targets.

## Evaluation checks

Single exported package:

```bash
nix-instantiate -A <package-name>
```

CI output dry run:

```bash
nix-instantiate ci.nix -A cacheOutputs --dry-run
```

## Build checks

```bash
# Dry run
nix-build -A <package-name> --dry-run

# Real build
nix-build -A <package-name>
```

## Flake checks

```bash
nix flake show
nix flake check
```

## CI notes

`ci.nix` excludes reserved attrs and filters packages by:

- `meta.broken`
- license freedom
- `preferLocalBuild`

That means a package may exist in `default.nix` but still be excluded from `cacheOutputs`.

!`if [ -n "$ARGUMENTS" ]; then nix-instantiate -A "$ARGUMENTS"; else nix-instantiate ci.nix -A cacheOutputs --dry-run; fi`
