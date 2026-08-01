# Vendored `gpui-terminal` — upstream baseline & local patches

Omnimux depends on this tree via a **path** dependency (`gpui-terminal = { path = "vendor/gpui-terminal" }` in `src/Cargo.toml`), not crates.io, so we can patch behavior for tmux/SSH tabs.

App-level behavior (appearance sync, Settings, packaging) lives in Omnimux’s [`README.md`](../../../README.md), not here.

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

Rough chronological / thematic summary of edits under this vendor tree:

### Input & mouse → PTY / tmux

- **Scroll wheel**: upstream `on_scroll` was effectively a no-op for apps; we forward SGR wheel reports when mouse mode is on, arrow keys on alt-screen without mouse mode, else local scrollback.
- **Scroll direction**: align GPUI wheel sign with alacritty (positive Y = up); do not double-negate.
- **Click / drag**: SGR button press/release and drag reports when mouse reporting is enabled (`mouse_button_report` / `mouse_drag_report`).
- **Stuck-press recovery**: if MouseUp is lost (touch cancel, up outside hitbox, platform clears `pressed_button`), terminal ends local select / sends SGR release — `end_pointer_press`, `on_mouse_up_out`, move-time reconcile when `pressed_button` is `None`, window-blur `release_pointer_press`, and Zed-style drag continue while pressed even outside the terminal hitbox.
- **Shift/Alt exception**: with **Shift** or **Option/Alt** held (or when mouse reporting is off), **do not** send mouse events to the PTY; start / extend a **local** selection instead. Shift/Alt+wheel always scrolls local history.
- **Padding-aware** / **paint-synced** cell hit-testing for mouse/scroll (store content origin + cell metrics from the last paint; use Zed-style `next_up` grid sizing so fractional Wayland scales like Plasma 225% don't miss rows).

### Selection & clipboard

- Local selection via alacritty `Term::selection` / `selection_to_string`, with selection highlight in `render.rs`.
- Selection anchors use **cell half** (`Side::Left` / `Side::Right`) so Shift-drag works from empty space (including right→left), matching GNOME Terminal / Alacritty. Copy still omits trailing unused cells via alacritty `line_length` (spaces after content are not pasted).
- Host **context menu** callback (`with_context_menu_callback`): right-click with Shift, no mouse mode, or a local selection opens host Copy/Paste instead of forwarding to tmux.
- `TerminalView::copy_selection()` for host shortcuts.
- Forward OSC 52 **store** (and default `arboard` fallback) and **load** back to the PTY.
- Forward **`PtyWrite`**, **`ColorRequest`**, and **`TextAreaSizeRequest`** to the PTY (upstream event bridge dropped several of these).
- **OSC 10/11/12**: `ColorRequest` answers from `ColorPalette` RGB when alacritty’s color table has no override (exact fg/bg/cursor RGB stored on the palette). On **host** palette change, clear NamedColor fg/bg/cursor overrides so queries track OS appearance.
- **DEC mode 2031 / DSR 996–997** (Contour/Ghostty): side-channel CSI observer (`color_scheme.rs`) because alacritty ignores unknown mode 2031 and does not handle `CSI ? 996 n`. Supports enable/disable, synchronous query, DECRPM, and unsolicited `CSI ? 997;Ps n` when the **host** palette changes via `update_config` (not when apps set OSC 10/11).
- **Security**: OSC 52 defaults to **`Disabled`** (`Osc52Policy` / alacritty `Config.osc52`); store/load handlers are gated and size-capped. Paste uses **bracketed paste** when the app enables it.
- **PTY flood handling** (tmux attach/redraw / huge `cat`): bounded flume queue (~256 KiB) for backpressure + coalesce drain (up to 256 KiB per batch, yield between batches) so we paint near the latest grid instead of scrolling every intermediate line.

### Rendering / metrics

- Cursor painted with **`display_offset`** (viewport-correct), so the caret tracks content in scrollback / agent UIs inside tmux.
- **Reverse-video** cells painted so soft cursors stay visible.
- Cell **width** measured with ASCII `'M'` (avoid Nerd-font `│` advance skew); height still prefers box-drawing when available.
- View background uses **`ColorPalette` background** (not a hard-coded dark `#1e1e1e`).
- Configurable **`scrollback`** via `TerminalState::new_with_scrollback` / `TerminalConfig.scrollback`.
- Optional **font fallbacks** list on `TerminalConfig`.

### Search

- In-grid search + highlight (`TerminalView::search` / `clear_search`).

### Hyperlinks

- `links.rs`: OSC 8 cell URI or plain `http(s)://` under the click point.
- `with_link_click_callback` + Cmd (macOS) / Ctrl (Linux) + left click in `on_mouse_down`.
- Changes the cursor to a pointing hand when hovering over a valid link while holding Cmd/Ctrl.

### IME (CJK input)

- `ime.rs`: `TerminalInputHandler` registered during canvas paint via `window.handle_input`, following Zed’s `terminal_element` pattern.
- Pre-edit (composing) text painted with underline at the terminal cursor; committed text is written to the PTY.
- Works with Wayland `zwp_text_input_v3` and macOS IME through GPUI’s platform layer.
- **KeyDown must `stop_propagation`** after writing to the PTY (Zed `terminal_view` does the same). Otherwise Linux `handle_input` also feeds `key_char` through `InputHandler` and every character is typed twice (worse with Plasma Keyboard / text-input-v3).

### Misc API / robustness

- `write_input` for paste into the PTY.
- Safer mouse report row indexing; middle/right mouse buttons registered on the view.
- Event enum extended / cleaned so host-bound replies are first-class (`event.rs`).

## Refresh / rebase tips

1. Diff this tree against upstream commit `45c63e57…` (or a newer tag) before merging upstream.
2. Prefer small, documented patches; keep this file updated when vendor behavior changes.
3. After updating vendor sources, `git add` them before `nix build` (flake eval ignores untracked files).


---

# Vendored gpui-ce 0.3.3 (Wayland touch)

Omnimux uses the community fork `gpui-ce` 0.3.3 + `gpui-component` 0.5.1.
Upstream GPUI (and `gpui-ce`) on Wayland ignores `wl_touch`, so touchscreen
taps never become clicks. We vendor the published `gpui-ce` 0.3.3 crates.io
tree and port our Wayland touch and appearance observer patches onto it.

Cargo picks it up via `[patch.crates-io]` in `by-name/om/omnimux/src/Cargo.toml`.
Note that because `gpui-component` 0.5.1 expects a dependency named `gpui` version 0.2.2,
we rename `gpui-ce` to `gpui` in its `Cargo.toml` and trick the version resolution so
that `gpui-component` seamlessly builds against it.

## Baseline

| | |
| --- | --- |
| Crate | `gpui-ce` 0.3.3 |
| crates.io checksum | (Automatically handled by Cargo/Nix) |
| License | Apache-2.0 (see `LICENSE-APACHE`) |

## Local changes (vs stock gpui-ce 0.3.3)

Source of the touch logic:
[zed#40139](https://github.com/zed-industries/zed/pull/40139) /
`robert7k` `feature/touch-events`, adapted to the monolithic
layout of `gpui-ce`.

- `serial.rs`: add `SerialKind::Touch`.
- `client.rs`: bind `wl_touch` from seat capabilities; map single-finger
  down/motion/up to mouse down/move/up; map two-finger pan to scroll.
- Pinch-to-zoom from upstream omitted (`KeyDownEvent` in GPUI lacks fields that PR uses).
- On touch down, set `mouse_focused_window` from the touched surface so up/move
  reach the window even if the pointer never entered (gap in the upstream PR).
- Also keep `touch_window` + `touch_mouse_down_sent` so a later pointer Leave
  cannot orphan MouseUp, Cancel synthesizes MouseUp (not only MouseExited),
  and ending a two-finger scroll does not re-assert `button_pressed`.
- Pointer MouseDown similarly remembers `pointer_button_window` across
  `wl_pointer::Leave`, so Button release still delivers MouseUp (same orphan class as touch). Enter does not clear an in-flight press.
- Touch uses the same multi-click (`click_count`) tracking as `wl_pointer`, so
  title-bar double-tap can maximize like a mouse double-click.
- Added `GPUI_TOUCHSCREEN_DRAG_SCROLLS` environment variable logic. When enabled,
  a single-finger touch motion emulates a scroll wheel (if it exceeds an 8px threshold)
  instead of emulating a left-click drag, improving touch scrolling on Wayland.
- `Pixels`: use `f32::from(...)` instead of `.as_f32()` because Wayland coordinates are `f64`.
- `platform/linux/text_system.rs` and `platform/mac/text_system.rs`: extend cosmic-text's Unix font fallback list
  with `Symbols Nerd Font Mono` / `Symbols Nerd Font`. Put `Noto Color Emoji` before Noto Sans / DejaVu / Symbols2. Strip system
  `Noto Color Emoji` (often COLRv1 → blank glyphs under Swash) so bundled CBDT emoji from `add_fonts` wins.
  Restored `is_nerd_font_symbols` check to bypass `has_m_glyph` requirements for symbols fonts.
- `platform/mac/text_system.rs`: explicitly register graphics fonts (like bundled icons) via `CTFontManagerRegisterGraphicsFont` so that macOS `CoreText` fallback shaping correctly locates and renders them.
- Wayland/X11 XDP appearance handler: drop the client `RefCell` borrow before
  `set_appearance` (observers may call `Platform::window_appearance` →
  `with_common`). Also take-call-restore for the appearance callback.
- `window.rs` (Wayland): added `if state.maximized { return; }` to `start_window_resize` to prevent
  misbehaving window dragging when maximized.

---

# gpui-component

This directory contains a vendored copy of `gpui-component` version 0.5.1 from crates.io.

## Local Patches:
- **`src/window_border.rs`**: Modified `on_mouse_down` and the hover handler to return early if `window.is_maximized()`. This prevents the resize icon from appearing on the edges of the screen when the window is maximized.
- **`src/table/state.rs` & `src/tree.rs`**: Adjusted `track_scroll` to pass `&UniformListScrollHandle` instead of an owned `UniformListScrollHandle`, ensuring compatibility with the updated `gpui-ce` API.

We use this vendored version so we can use it with our custom `gpui-ce` base.
