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

Avalonia stays on **X11/XWayland**. `LayoutTransform` only stretches a 1× Skia buffer (blurry, easy to clip). The patch instead sets `AVALONIA_GLOBAL_SCALE_FACTOR` in `Program.Main` **before** the X11 backend starts, and sets `AVALONIA_SCREEN_SCALE_IGNORE_QT=1` so Plasma’s `QT_SCREEN_SCALE_FACTORS=1` does not pin scale to 1×.

**KDE Plasma Wayland — Legacy X11 apps:**

- *Apply scaling themselves* (`XwaylandClientsScale=true`): set scale from `kwinoutputconfig.json` if present, else **1.5×** on typical HiDPI (Framework 13). Rendering stays sharp.
- *Scaled by the system* (`false`): leave Avalonia at 1×; KWin magnifies (blurry by design).

Override: `DISCORDCHATEXPORTER_SCALE`.

### Darwin

nixpkgs `meta.platforms` is Linux-only. We add `x86_64-darwin` / `aarch64-darwin`, `desktopToDarwinBundle`, Linux-only X11 `runtimeDeps`, and the csharpier MSBuild flag used by `discordchatexporter-cli`.

### Other packaging

- `pname` is `discordchatexporter-desktop_patched`
- Desktop item for the launcher / Darwin `.app`
- `XDG_CONFIG_HOME` only on Linux
