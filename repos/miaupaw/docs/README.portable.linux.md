# Instant Eyedropper Reborn (IE-R) — Portable Bundle

**A high-performance, system-wide color picker for Linux (Wayland & X11).**  
Click → Color → Done. Zero latency, pixel-perfect precision.

This bundle is self-contained — it ships its own libraries and runs on any x86_64 Linux without installation.

---

## Quick Start

```bash
unzip ie-r-v*.zip
cd ie-r
./postinstall.sh
ie-r
```

`postinstall.sh` installs the `.desktop` file and icon into `~/.local/share/`, offers to add IE-R to autostart, and prints a hotkey setup tip.

---

## How it works

Press your hotkey (or click the tray icon). A magnifier appears over your screen. Point at a pixel, click — the color is in your clipboard in whatever format you need. The overlay closes. You paste.

- **Serial picks** — `middle-click` or `Space` to keep picking without closing. Colors stack up.
- **Precision** — `arrow keys` move 1px at a time. `Shift+arrows` jump to the next color boundary on screen.
- **Zoom** — `scroll wheel` changes magnification. `Alt+scroll` averages colors over a region.
- **Formats** — keys `1` through `0` switch between 10 formats instantly.
- **Resize on the fly** — `Shift+scroll` resizes the magnifier, `Ctrl+scroll` changes font size.
- **History** — last picked colors live in the tray context menu. Click to re-copy.

---

## Wayland hotkey integration

Wayland compositors block global input capture by design. Bind these commands in your compositor settings:

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

**KDE Plasma:** System Settings → Shortcuts → Custom Shortcuts → Add new → Command/URL.

> On X11, IE-R also supports a built-in hotkey (default `Alt+Shift+X`), configurable in `~/.config/ie-r/config.toml`.

---

## CLI

Beyond the daemon, `ie-r` exposes a CLI surface for scripting:

```bash
ie-r --pick                  # interactive: overlay → stdout
ie-r --pick -c               # → clipboard too
ie-r --pixel 320,180 -f hex  # sample one pixel → stdout
ie-r --help                  # colour-coded quick reference
```

Full reference: [github.com/miaupaw/ie-r/blob/master/docs/cli.md](https://github.com/miaupaw/ie-r/blob/master/docs/cli.md)

---

## Configuration

All settings live in `~/.config/ie-r/config.toml`. Created with defaults on first run. IE-R preserves your comments when updating the config.

---

## License

See `LICENSE` for the full text.

- **Individuals & small organizations** (<50 employees / <$1M revenue) — free to use.
- **Source code** — see [github.com/miaupaw/ie-r](https://github.com/miaupaw/ie-r)
- **Full license text:** [github.com/miaupaw/ie-r/blob/master/LICENSE](https://github.com/miaupaw/ie-r/blob/master/LICENSE)

**Author:** Konstantin Yagola — [instant-eyedropper.com](https://instant-eyedropper.com)
