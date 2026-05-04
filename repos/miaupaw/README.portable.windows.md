# Instant Eyedropper Reborn (IE-R) — Portable Bundle for Windows

**A high-performance, system-wide color picker for Windows.**
Click → Color → Done. Zero latency, pixel-perfect precision.

This bundle is self-contained — just unzip and run, no installation required.

---

## Quick Start

1. Unzip the archive anywhere you like
2. Run `ie-r.exe`
3. IE-R appears in your system tray

To activate: press the hotkey (default `Alt+Shift+X`) or click the tray icon.

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

## Hotkey

The default hotkey is `Alt+Shift+X`, configurable in `config.toml`.

For scripting and automation (AutoHotkey, Task Scheduler, etc.), you can trigger IE-R from the command line:

```
ie-r.exe --pick    ; activate color picker
ie-r.exe --menu    ; open color history menu
```

**AutoHotkey example:**
```ahk
!+c::Run ie-r.exe --pick
!+h::Run ie-r.exe --menu
```

---

## Autostart

Right-click the tray icon → **Start with Windows** to toggle autostart.

---

## Configuration

On first run, IE-R creates `config.toml` in the same folder as `ie-r.exe` (portable mode).
IE-R preserves your comments when saving config changes.

---

## License

See `LICENSE` for the full text.

- **Individuals & small organizations** (<50 employees / <$1M revenue) — free to use.
- **Source code** — see [github.com/miaupaw/ie-r](https://github.com/miaupaw/ie-r)
- **Full license text:** [github.com/miaupaw/ie-r/blob/master/LICENSE](https://github.com/miaupaw/ie-r/blob/master/LICENSE)

This bundle includes JetBrains Mono font, distributed under the SIL Open Font License 1.1 — see `fonts/OFL.txt`.

**Author:** Konstantin Yagola — [instant-eyedropper.com](https://instant-eyedropper.com)
