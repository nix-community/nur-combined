# Omnimux

GPUI terminal multiplexer for local and SSH+tmux sessions.

Package entry: [`package.nix`](./package.nix). App sources: [`src/src/`](./src/src/).

**Download:** [rolling release](https://github.com/mio-19/omnimux/releases/tag/rolling) (also `meta.downloadPage` in `package.nix`).

## Vendored dependencies

| Tree | Notes |
| --- | --- |
| [`src/vendor/gpui-terminal/`](./src/vendor/gpui-terminal/) | Terminal emulator; see [`VENDOR.md`](./src/vendor/gpui-terminal/VENDOR.md) for upstream pin and local patches |
| [`src/vendor/gpui/`](./src/vendor/gpui/) | GPUI fork; see [`VENDOR.md`](./src/vendor/gpui/VENDOR.md) |

Omnimux owns tab chrome, SSH/tmux spawn, settings, focus, packaging, and shortcut routing under `src/src/` — not the vendor trees.

## Appearance / dark–light for apps in the terminal

Omnimux syncs the terminal palette from the OS/window appearance (`tabs/lifecycle.rs`, `palette.rs`):

- Sessions start with the **current** window appearance (so OSC color queries are correct from the first prompt).
- On appearance change, Omnimux updates each tab’s `TerminalConfig.colors` and repaints.
- New sessions also get `COLORFGBG` (`15;0` dark / `0;15` light) as a fallback documented by Cursor CLI when OSC probing fails.

TUIs such as Cursor CLI / Gemini CLI typically detect dark vs light by **querying OSC 11** (terminal background), not by reading OS APIs. Omnimux answers those queries via vendored `gpui-terminal` (`ColorRequest` → palette RGB), using the xterm `rgb:RRRR/GGGG/BBBB` reply form (alacritty formatter).

| Mechanism | Mid-session after OS theme flip |
| --- | --- |
| Omnimux chrome + terminal palette | Updates |
| Direct OSC 10/11/12 **query** to Omnimux | Sees new host palette (VT OSC overrides cleared on appearance change) |
| Contour/Ghostty **DEC mode 2031** (`CSI ? 2031 h`) | Unsolicited `CSI ? 997;1\|2 n` when Omnimux updates the host palette; apps (Neovim) then re-query OSC 11 |
| Synchronous scheme query | `CSI ? 996 n` → `CSI ? 997;Ps n` |
| OSC 11 **inside tmux** | tmux (≥3.4) may still cache client color until reattach or until tmux gains 2031 ([tmux#3582](https://github.com/tmux/tmux/issues/3582), [tmux#4269](https://github.com/tmux/tmux/issues/4269)) |
| Unsolicited OSC 10/11/12 push | **Not** sent (non-standard; dropped after Contour/Ghostty review — prefer 2031) |
| Cursor CLI mid-session | Cursor does not speak 2031; relies on OSC 11 (re)probe / spawn-time `COLORFGBG` |

References: [xterm OSC 10/11 query](https://ansicode.eversources.app/en/sequence/osc-color-query), [Contour DEC 2031](http://contour-terminal.org/vt-extensions/color-palette-update-notifications/), [Cursor terminal theme](https://cursor.com/docs/cli/reference/terminal-setup).

## Local sessions

Localhost / empty host runs a shell script that prefers `tmux` (with Homebrew/MacPorts on `PATH` for macOS GUI apps) and falls back to a login shell if `tmux` is missing. The Nix package also prefixes `tmux` onto `PATH` via `wrapProgram`.

## Settings Omnimux owns

- **OSC 52** remote clipboard: default disabled; opt-in in Settings (policy passed into `TerminalConfig`).
- **Open links**: off by default; Cmd/Ctrl+click http(s) with confirm (uses vendor link callback).
- Font size sync / remember, auto-reconnect, remember sessions, window maximized, etc.

## Packaging

- Ships Symbols Nerd Font + Noto Color Emoji under `$out/share/omnimux/fonts` (`OMNIMUX_FONTS_DIR`).
- Desktop entry + icon; Darwin `.app` via `desktopToDarwinBundle`.
