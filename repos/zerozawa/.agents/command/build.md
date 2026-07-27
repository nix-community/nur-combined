---
description: Build and test packages exported by this NUR repository
---

Build a package exported from `default.nix`.

## What to target

- Use **attribute names exported by `default.nix`**, not file paths.
- Reserved attrs `lib`, `modules`, and `overlays` are **not** package build targets.

Current examples:

- `JMComic-qt`
- `LoveIwara`
- `deskbrid`
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

- `LoveIwara` has Flutter pub-lock, native-asset, SQLite, and libmpv runtime handling.
- `JMComic-qt` and `picacg-qt` expect the model-linked `sr-vulkan` composition.
- `deskbrid` resolves compositor helper tools (hyprctl, grim, wl-clipboard, ydotool, ...) from PATH at runtime; it is intentionally not wrapped.
- **`oh-my-pi`**: after building, verify ELF patching by checking all onnxruntime
  `.node` files have `self-dir` in RPATH and NEEDED matches the renamed
  `libonnxruntime.so.1.<cksum>` on disk. See `pkgs/oh-my-pi/AGENTS.md`.

!`nix-build -A "$ARGUMENTS"`
