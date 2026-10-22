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

CI build set dry run:

```bash
nix build --dry-run .#ciJobs.x86_64-linux."<package-name>"
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

`ci.nix` (imported by the flake as `ciPackages` / `ciJobs`) excludes reserved attrs and filters packages by:

- `meta.broken`
- license freedom
- `preferLocalBuild`

That means a package may exist in `default.nix` but still be excluded from `ciPackages`/`ciJobs`.

!`if [ -n "$ARGUMENTS" ]; then nix-instantiate -A "$ARGUMENTS"; else nix eval --json .#ciJobs.x86_64-linux --apply builtins.attrNames; fi`
