# discordchatexporter-desktop_patched

Thin wrapper around nixpkgs `discordchatexporter-desktop` via `overrideAttrs`, plus local HiDPI and Darwin packaging.

## Local changes

### Linux HiDPI (`hidpi-scale.patch`)

Avalonia stays on **X11/XWayland**. `LayoutTransform` only stretches a 1× Skia buffer (blurry, easy to clip). The patch sets `AVALONIA_SCREEN_SCALE_IGNORE_QT=1` so Plasma’s `QT_SCREEN_SCALE_FACTORS=1` does not pin scale to 1×, then sets **named** `AVALONIA_SCREEN_SCALE_FACTORS` (absolute). It does **not** set `AVALONIA_GLOBAL_SCALE_FACTOR`: that value is multiplied on top of `Xft.dpi/96`, which made a sharp but oversized UI (e.g. 1.5× × 144dpi → 2.25×).

**KDE Plasma Wayland — Legacy X11 apps:**

- *Apply scaling themselves* (`XwaylandClientsScale=true`): set scale from `kwinoutputconfig.json` if present, else **1.5×** on typical HiDPI (Framework 13). Rendering stays sharp.
- *Scaled by the system* (`false`): leave Avalonia at 1×; KWin magnifies (blurry by design).

Override: `DISCORDCHATEXPORTER_SCALE`.

### Darwin

nixpkgs `meta.platforms` is Linux-only. We add `x86_64-darwin` / `aarch64-darwin`, `desktopToDarwinBundle`, Linux-only X11 `runtimeDeps`, `executables = [ "DiscordChatExporter" ]` so Avalonia dylibs are not wrapped, and the csharpier MSBuild flag used by `discordchatexporter-cli`. The desktop `exec` is `DiscordChatExporter` so the Darwin `.app` stub matches the wrapped binary. The lowercase `discordchatexporter` symlink is Linux-only: a Darwin Nix store is case-insensitive, so that name is the same file as `DiscordChatExporter`.

### Other packaging

- `pname` is `discordchatexporter-desktop_patched`
- Desktop item for the launcher / Darwin `.app`
- `XDG_CONFIG_HOME` only on Linux
- Version bumps track nixpkgs `discordchatexporter-desktop` until upstream ships newer dotnet deps
