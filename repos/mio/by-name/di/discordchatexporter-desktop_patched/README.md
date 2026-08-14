# discordchatexporter-desktop_patched

Vendored copy of nixpkgs `discordchatexporter-desktop`, plus local HiDPI and Darwin patches.

## Upstream (nixpkgs)

Copied on **2026-08-14** from this flake’s `nixpkgs` lock:

| Field | Value |
| --- | --- |
| nixpkgs rev | [`044bfe75bfe4c7bbe043dc17b5e42ea823b84a09`](https://github.com/NixOS/nixpkgs/commit/044bfe75bfe4c7bbe043dc17b5e42ea823b84a09) |
| Channel snapshot | `nixpkgs-26.11pre1052792.044bfe75bfe4` |
| Upstream path | `pkgs/by-name/di/discordchatexporter-desktop/` |
| Package version | `2.47.3` |

Files taken as-is from that commit:

- `deps.json`
- `settings-path.patch`
- `updater.sh`

`package.nix` started from the same file, then the local changes below were applied.

To refresh: copy those four files from a newer nixpkgs commit, update this table, then re-apply the local changes.

## Local changes

### Linux HiDPI (`hidpi-scale.patch`)

Avalonia on X11/XWayland often keeps `RenderScaling = 1` on HiDPI (e.g. Framework 13 2880×1920). `AVALONIA_GLOBAL_SCALE_FACTOR` / `AVALONIA_SCREEN_SCALE_FACTORS` did not take effect here.

On window open, if Linux scale is still ~1×, wrap the window content in `LayoutTransformControl` (detach `Content` first so Avalonia does not throw “The Control already has a parent”). Scale is guessed as `screenWidth / 1920` snapped to 1.25 steps (2880 → 1.5×).

Do **not** read `AVALONIA_GLOBAL_SCALE_FACTOR` here: that is a session-wide Avalonia/X11 knob for other apps. Using it as a layout multiplier stacked on the guessed scale made the window huge. Override only with `DISCORDCHATEXPORTER_SCALE`.

### Darwin

nixpkgs `meta.platforms` is Linux-only. We add `x86_64-darwin` / `aarch64-darwin`, `desktopToDarwinBundle`, Linux-only X11 `runtimeDeps`, and the csharpier MSBuild flag used by `discordchatexporter-cli`.

### Other packaging

- `pname` is `discordchatexporter-desktop_patched`
- Desktop item for the launcher / Darwin `.app`
- `XDG_CONFIG_HOME` only on Linux
