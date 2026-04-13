---
description: Build and test packages exported by this NUR repository
---

Build a package exported from `default.nix`.

## What to target

- Use **attribute names exported by `default.nix`**, not file paths.
- Reserved attrs `lib`, `modules`, and `overlays` are **not** package build targets.

Current examples:

- `JMComic-qt`
- `hyprland-mcp-server`
- `mcp-cli`
- `grub-theme-yorha`
- `waybar-vd`

## Build commands

Single package:

```bash
nix-build -A <package-name>
```

Build through flake output:

```bash
nix build .#<package-name>
```

Build what CI caches:

```bash
nix-build ci.nix -A cacheOutputs
```

## Build checklist

1. The target builds successfully.
2. Runtime wrapper behavior is correct for GUI/CLI packages.
3. `meta` is complete enough for CI filtering and flake export.
4. If the package is intended for binary cache, verify it does not rely on `preferLocalBuild = true`.

## Repo-specific reminders

- `Fladder` has extra Flutter-specific lockfile handling.
- `JMComic-qt` and `picacg-qt` expect the model-linked `sr-vulkan` composition.
- `hyprland-mcp-server` depends on runtime PATH wrapping for Hyprland tools.

!`nix-build -A "$ARGUMENTS"`
