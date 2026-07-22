# Omnimux

GPUI terminal multiplexer for local and SSH+tmux sessions.

Package entry: [`package.nix`](./package.nix). App sources: [`src/src/`](./src/src/).

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

TUIs such as Cursor CLI / Gemini CLI typically detect dark vs light by **querying OSC 11** (terminal background), not by reading OS APIs. Omnimux answers those queries via vendored `gpui-terminal` (`ColorRequest` → palette RGB).

| Mechanism | Mid-session after OS theme flip |
| --- | --- |
| Omnimux chrome + terminal palette | Updates |
| OSC 10/11/12 **query** (app polls) | Sees new colors |
| Unsolicited OSC 10/11/12 push | **Not** sent (non-standard; can leak into the shell prompt) |
| Contour/Ghostty **DEC mode 2031** (`CSI ? 997;Ps n`) | Not implemented yet |

## Local sessions

Localhost / empty host runs a shell script that prefers `tmux` (with Homebrew/MacPorts on `PATH` for macOS GUI apps) and falls back to a login shell if `tmux` is missing. The Nix package also prefixes `tmux` onto `PATH` via `wrapProgram`.

## Settings Omnimux owns

- **OSC 52** remote clipboard: default disabled; opt-in in Settings (policy passed into `TerminalConfig`).
- **Open links**: off by default; Cmd/Ctrl+click http(s) with confirm (uses vendor link callback).
- Font size sync / remember, auto-reconnect, remember sessions, window maximized, etc.

## Packaging

- Ships Symbols Nerd Font + Noto Color Emoji under `$out/share/omnimux/fonts` (`OMNIMUX_FONTS_DIR`).
- Desktop entry + icon; Darwin `.app` via `desktopToDarwinBundle`.
