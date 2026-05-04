# Instant Eyedropper Reborn (IE-R)

[![Built with Nix](https://img.shields.io/badge/Nix-Flake-blue.svg?logo=nixos&logoColor=white)](https://nixos.org)
[![Language: Rust](https://img.shields.io/badge/Language-Rust-orange.svg?logo=rust)](https://www.rust-lang.org)

**A high-performance, system-wide color picker for Linux (Wayland & X11).**
Click → Color → Done. Zero latency, pixel-perfect precision.

---

IE-R is a color picker and daemon for Linux. It lives in your system tray, listens for hotkeys, and puts the color under your cursor into your clipboard instantly.

This is the resurrection of the original "Instant Eyedropper" tool, which has served users for over 20 years. Now it's a native Wayland app written from scratch in Rust. Same idea — but with everything users asked for over two decades finally built in.

[![IE-R Demo](https://instant-eyedropper.com/linux/poster.png)](https://instant-eyedropper.com/linux/#demo)

## How it works

Press your hotkey (or click the tray icon). A magnifier appears over your screen. Point at a pixel, click — the color is in your clipboard in whatever format you need. The overlay closes. You paste.

That's the basic loop. But there's more:

- **Serial picks** — `middle-click` or press `Space` to keep picking without closing the overlay. Colors stack up.
- **Precision** — `arrow keys` move 1px at a time. `Shift+arrows` jump to the next color boundary on screen.
- **Zoom** — `scroll wheel` changes magnification. `Alt+scroll` changes the sampling area for averaging colors over a region.
- **Formats** — keys `1` through `0` switch between 10 formats. Format switches instantly in the overlay and in what gets copied.
- **Resize on the fly** — `Shift+scroll` resizes the magnifier, `Ctrl+scroll` changes font size. No restart, no config reload.
- **History** — last picked colors live in the tray context menu with color swatches. Click to re-copy.

## Features

1. **Multi-monitor:** Any number of screens, mixed resolutions, fractional scaling (1.25x, 1.5x, etc.)
2. **HiDPI:** Real physical pixels in the magnifier, not interpolated mush
3. **Stash deck:** Unlimited sequential picks, accumulated in a stack
4. **Precision Control:** `Arrow Keys` to move 1px at a time.
5. **Hyper Jump:** `Shift + Arrows` jumps the cursor to the next significant color change (threshold is configurable).
6. **Dynamic Aperture:** `Mouse Wheel` changes the magnifier's zoom level.
7. **Area Sampling:** `Alt + Scroll` changes the capture area to calculate the average color of a region.
8. **10 color formats:** HEX, RGB, HSL, HSV, CMYK, Delphi, VB Hex, Long, + **customizable templates**
9.  **Runtime UI Tweaks:** Adjust magnifier size (`Shift + Scroll`) and font size (`Ctrl + Scroll`) without opening settings.
10. **Hotkey:** Configurable global hotkey (default Alt+Shift+X for X11) + SIGUSR1 for Wayland compositors
11. **Config:** Single TOML file. Preserves your comments on save. Controls everything: colors, sizes, fonts, physics, effects
12. **Tray:** SNI system tray with color history, format selection, config access

## Architecture & Performance
IE-R is written in **Pure Rust** (Edition 2024) and talks directly to Wayland protocols. No Electron, no heavy frameworks, zero GPU overhead.

It uses a tiered capture chain to ensure you get your pixels as fast as the hardware allows:
1.  **Tier 1: WLR Screencopy** (~10-30ms) — Best for Hyprland, Sway, and wlroots-based compositors.
2.  **Tier 2: KWin ScreenShot2** (~30-50ms) — Native speed for KDE Plasma.
3.  **Tier 3: XDG Desktop Portal** (~500ms+) — Universal fallback for GNOME and other environments.

## Installation

### Nix (recommended)
If you have Nix installed with Flakes enabled:
```bash
nix run github:miaupaw/ie-r
```

To install it into your profile:
```bash
nix profile install github:miaupaw/ie-r
```

The Nix package handles everything automatically: binary, `.desktop` file, icon, and KWin authorization.

### Arch Linux (AUR)
```bash
yay -S ie-r
```

The PKGBUILD installs the binary, `.desktop` file, and icon to standard system paths. KWin authorization works out of the box.

### Portable bundle
Download the latest `ie-r-vX.X.X.zip` from Releases. Unpack anywhere and run the integration script:
```bash
unzip ie-r-v*.zip
cd ie-r
./postinstall.sh
```

`postinstall.sh` installs the `.desktop` file and icon into `~/.local/share/`, offers to add IE-R to autostart, and prints a hotkey setup tip. The bundle is self-contained — it ships its own libraries and runs on any x86_64 Linux.

### Build from source
Requires Rust 1.80+ and development libraries: `wayland-client`, `libxkbcommon`, `pipewire`, `dbus`, `fontconfig`, `libx11`.
```bash
git clone https://github.com/miaupaw/ie-r
cd ie-r
cargo build --release
./target/release/ie-r
```

If you build from source, you'll need to install the `.desktop` file and icon manually — see [Post-install](#post-install) below.

## Post-install

### KDE Plasma: enabling fast capture

KWin ScreenShot2 requires a `.desktop` file with a special key to authorize direct screen capture. Without it, IE-R falls back to XDG Portal (~500ms instead of ~30ms).

> Nix, AUR, and the portable bundle's `postinstall.sh` handle this automatically. The steps below are only needed for manual/source builds.

The file `assets/ie-r.desktop` already contains the necessary `X-KDE-DBUS-Restricted-Interfaces=org.kde.KWin.ScreenShot2` entry. Install it so KWin can find it:

```bash
sudo cp assets/ie-r.desktop /usr/share/applications/ie-r.desktop

# Fix Exec= to match your actual binary path
sudo sed -i 's|Exec=ie-r|Exec=/usr/bin/ie-r|' /usr/share/applications/ie-r.desktop
```

> **Important:** The `Exec=` path must resolve to the same file as `/proc/PID/exe` of the running process. KWin matches these paths to decide whether to authorize capture. If they don't match — you get `NoAuthorized` and fall back to the slow portal.

#### Icon

```bash
sudo cp assets/ie-r.svg /usr/share/icons/hicolor/scalable/apps/ie-r.svg
sudo cp assets/ie-r-64x64.png /usr/share/icons/hicolor/64x64/apps/ie-r.png
gtk-update-icon-cache /usr/share/icons/hicolor/ 2>/dev/null || true
```

### Wayland hotkey integration

Wayland compositors block global input capture by design. IE-R listens for UNIX signals as a workaround — bind these commands to your compositor's hotkey settings:

```bash
pkill -SIGUSR1 ie-r   # activate color picker
pkill -SIGUSR2 ie-r   # open color history menu
```

**Hyprland** (`~/.config/hypr/hyprland.conf`):
```
bind = ALT SHIFT, C, exec, pkill -SIGUSR1 ie-r
bind = ALT SHIFT, H, exec, pkill -SIGUSR2 ie-r
```

**Sway** (`~/.config/sway/config`):
```
bindsym Alt+Shift+x exec pkill -SIGUSR1 ie-r
bindsym Alt+Shift+h exec pkill -SIGUSR2 ie-r
```

**KDE Plasma:** System Settings → Shortcuts → Custom Shortcuts → Add new → Command/URL. Set the command to `pkill -SIGUSR1 ie-r` and assign your preferred key combo.

> On X11 sessions, IE-R also supports a built-in hotkey (default `Alt+Shift+X`), configurable in `~/.config/ie-r/config.toml`.

### Autostart

To launch IE-R automatically on login, copy the `.desktop` file to your autostart directory:
```bash
cp ~/.local/share/applications/ie-r.desktop ~/.config/autostart/
```

### Configuration

Settings live in `~/.config/ie-r/config.toml`. Picked color history lives in `~/.local/state/ie-r/history.toml`. Both files are created as needed on first run, and IE-R preserves your comments when updating the config.

---

## License

IE-R is source-available under a custom license. See [LICENSE](LICENSE) for the full text.

*   **Source code** — you may read and modify it for personal use. Public forks, redistribution of modified versions, and incorporation into other projects are not permitted.
*   **Individuals & small organizations**  — free to use.
*   **Business** — For business use, please [contact](mailto:info@spicebrains.com) the author .

**Author:** [Konstantin Yagola](mailto:info@spicebrains.com).

*Built with passion in Kyiv, Ukraine.* 🇺🇦
