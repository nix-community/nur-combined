# Vendored `gpui-terminal` — upstream baseline & local patches

Omnimux depends on this tree via a **path** dependency (`gpui-terminal = { path = "vendor/gpui-terminal" }` in `src/Cargo.toml`), not crates.io, so we can patch behavior for tmux/SSH tabs.

## Upstream

| Field | Value |
| --- | --- |
| Project | [zortax/gpui-terminal](https://github.com/zortax/gpui-terminal) |
| Author | Leonard Seibold (`git[@]zrtx.de`) |
| Upstream package version | `0.1.0` (as in vendored `Cargo.toml`) |
| Git commit we vendored | [`45c63e57181d27c260124a81c7e4b68a6b6e57b0`](https://github.com/zortax/gpui-terminal/commit/45c63e57181d27c260124a81c7e4b68a6b6e57b0) (“update Cargo.toml”) |
| Recorded in | `.cargo_vcs_info.json` (`git.sha1`) |
| First vendored in nurpkgs | commit `457e38f2` (*fix: scroll to tmux, cursor viewport, tab drag, Ctrl+/- zoom*) |
| License | MIT OR Apache-2.0 (see `LICENSE-*` in this directory) |
| Key deps (upstream) | `gpui` 0.2.2, `alacritty_terminal` 0.25.1, `arboard`, `flume`, … |

Upstream README still describes OSC 52 / mouse as partially planned; many of those gaps are what we patched locally.

## Local changes (vs that baseline)

Rough chronological / thematic summary of edits under this vendor tree for Omnimux:

### Input & mouse → PTY / tmux

- **Scroll wheel**: upstream `on_scroll` was effectively a no-op for apps; we forward SGR wheel reports when mouse mode is on, arrow keys on alt-screen without mouse mode, else local scrollback.
- **Scroll direction**: align GPUI wheel sign with alacritty (positive Y = up); do not double-negate.
- **Click / drag**: SGR button press/release and drag reports when mouse reporting is enabled (`mouse_button_report` / `mouse_drag_report`).
- **Shift exception**: with **Shift** held (or when mouse reporting is off), **do not** send mouse events to the PTY; start / extend a **local** selection instead. Shift+wheel always scrolls local history.
- **Padding-aware** / **paint-synced** cell hit-testing for mouse/scroll (store content origin + cell metrics from the last paint; use Zed-style `next_up` grid sizing so fractional Wayland scales like Plasma 225% don't miss rows).

### Selection & clipboard

- Local selection via alacritty `Term::selection` / `selection_to_string`, with selection highlight in `render.rs`.
- Selection anchors use **cell half** (`Side::Left` / `Side::Right`) so Shift-drag works from empty space (including right→left), matching GNOME Terminal / Alacritty. Copy still omits trailing unused cells via alacritty `line_length` (spaces after content are not pasted).
- Host **context menu** callback (`with_context_menu_callback`): right-click with Shift, no mouse mode, or a local selection opens Omnimux Copy/Paste instead of forwarding to tmux.
- `TerminalView::copy_selection()` for host shortcuts (⌘C / Ctrl+Shift+C handled in Omnimux).
- Forward OSC 52 **store** (and default `arboard` fallback) and **load** back to the PTY.
- Forward **`PtyWrite`**, **`ColorRequest`**, and **`TextAreaSizeRequest`** to the PTY (upstream event bridge dropped several of these).
- **OSC 10/11/12**: answer color queries from Omnimux's palette (not an empty alacritty color table), and push unsolicited OSC 10/11/12 when appearance/theme changes mid-session so TUIs that poll or listen can switch light/dark.
- **Security**: OSC 52 defaults to **`Disabled`** (`Osc52Policy` / alacritty `Config.osc52`) so a compromised remote cannot silently overwrite or exfiltrate the system clipboard. Omnimux sets this explicitly; store/load handlers are gated and size-capped. Paste uses **bracketed paste** when the app enables it.
- **PTY flood handling** (tmux attach/redraw / huge `cat`): bounded flume queue (~256 KiB) for backpressure + coalesce drain (up to 256 KiB per batch, yield between batches) so we paint near the latest grid instead of scrolling every intermediate line.

### Rendering / metrics

- Cursor painted with **`display_offset`** (viewport-correct), so the caret tracks content in scrollback / agent UIs inside tmux.
- **Reverse-video** cells painted so soft cursors stay visible.
- Cell **width** measured with ASCII `'M'` (avoid Nerd-font `│` advance skew); height still prefers box-drawing when available.
- View background uses **`ColorPalette` background** (not a hard-coded dark `#1e1e1e`).
- Configurable **`scrollback`** via `TerminalState::new_with_scrollback` / `TerminalConfig.scrollback`.
- Optional **font fallbacks** list on `TerminalConfig` (Omnimux ships Symbols Nerd Font names).

### Search

- In-grid search + highlight (`TerminalView::search` / `clear_search`) used by Omnimux’s search UI.

### Hyperlinks (Omnimux opt-in)

- `links.rs`: OSC 8 cell URI or plain `http(s)://` under the click point.
- `with_link_click_callback` + Cmd (macOS) / Ctrl (Linux) + left click in `on_mouse_down`.
- Omnimux gates this behind Settings → open links (default off) and a confirm overlay; only `http`/`https`.

### IME (CJK input)

- `ime.rs`: `TerminalInputHandler` registered during canvas paint via `window.handle_input`, following Zed’s `terminal_element` pattern.
- Pre-edit (composing) text painted with underline at the terminal cursor; committed text is written to the PTY.
- Works with Wayland `zwp_text_input_v3` and macOS IME through GPUI’s platform layer.
- **KeyDown must `stop_propagation`** after writing to the PTY (Zed `terminal_view` does the same). Otherwise Linux `handle_input` also feeds `key_char` through `InputHandler` and every character is typed twice (worse with Plasma Keyboard / text-input-v3).

### Misc API / robustness

- `write_input` for paste into the PTY.
- Safer mouse report row indexing; middle/right mouse buttons registered on the view.
- Event enum extended / cleaned so host-bound replies are first-class (`event.rs`).

## What Omnimux owns (not in this vendor)

Tab chrome, SSH+tmux spawn, settings (theme sync, font sync/remember), focus hacks, packaging, and shortcut routing live in `by-name/om/omnimux/src/src/tabs/` (and `package.nix`), not here.

## Refresh / rebase tips

1. Diff this tree against upstream commit `45c63e57…` (or a newer tag) before merging upstream.
2. Prefer small, documented patches; keep this file updated when behavior changes.
3. After updating vendor sources, `git add` them before `nix build` (flake eval ignores untracked files).
