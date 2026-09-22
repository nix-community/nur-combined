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
| Key deps (upstream) | `gpui` (via gpui-pre), `alacritty_terminal` 0.26.0 (path-vendored; see below), `arboard`, `flume`, … |

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
- **Pinned selection**: Shift/Alt anchors are stored on `TerminalView` and re-applied after PTY output so alacritty does not drop the highlight mid-drag or while copying from a live-updating screen (`top`, log tail, etc.).
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
- **Wide-char slot centering** (`render.rs` paint loop): emoji and CJK glyphs are marked `WIDE_CHAR` by alacritty (2 grid columns) but NotoColorEmoji reports 1em advance per glyph. The paint loop now detects `Flags::WIDE_CHAR`, computes a 2-cell slot, and centres the shaped glyph within it — preventing the 1-cell visual gap that appeared after scroll/repaint (broken Starship `via 🐍` icon). Also handles terminal multiplexer wcwidth mismatches by falling back to 1-cell rendering if the expected wide char spacer is overwritten. `WIDE_CHAR_SPACER` cells are also explicitly skipped in the glyph paint pass (they were already filtered by the `ch==' '` guard, but the flag check makes intent clear). Also explicitly ignores standalone variation selectors and zero-width joiners/spaces stranded in cells by partial tmux redraws, preventing them from falling back to a `.notdef` square.
- **Zerowidth character rendering** (`render.rs`): Appends `cell.zerowidth()` sequences (like ZWJ, skin tone modifiers, and variation selectors) to the base character before text shaping to ensure multi-part emojis and ligatures render accurately.
- View background uses **`ColorPalette` background** (not a hard-coded dark `#1e1e1e`).
- Configurable **`scrollback`** via `TerminalState::new_with_scrollback` / `TerminalConfig.scrollback`.
- Optional **font fallbacks** list on `TerminalConfig`.

### Search

- In-grid search + highlight (`TerminalView::search` / `clear_search`).

### Hyperlinks

- `links.rs`: OSC 8 cell URI or plain `http(s)://` under the click point.
- `is_browser_url` loosened to allow custom URI schemas (e.g., `file://`, `urn:`) while blocking dangerous protocols like `javascript:`.
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

# Vendored `alacritty_terminal` 0.26.0

Path dep from `gpui-terminal` (`path = "../alacritty_terminal"`). Needed only so we can keep a tiny Linux grid patch; crates.io alone cannot carry that delta.

| Field | Value |
| --- | --- |
| Upstream | [alacritty/alacritty](https://github.com/alacritty/alacritty) `alacritty_terminal` |
| Version | `0.26.0` (crates.io newest) |
| crates.io baseline SHA | `.cargo_vcs_info.json` → `94e7c8874e526b1e67b349d9ba30ddf81669119e` |
| License | Apache-2.0 (`LICENSE-APACHE`) |

## Local patch (vs crates.io)

In `src/term/mod.rs` `write_at_cursor`, when overwriting a wide-char **spacer** cell:

- **non-Linux**: stock `clear_wide()` on the previous cell (clears `WIDE_CHAR` **and** replaces the glyph with `' '`).
- **Linux**: only `flags.remove(Flags::WIDE_CHAR)` — keep the emoji/CJK codepoint so mux/wcwidth mismatches do not blank the glyph (renderer then falls back via spacer checks in `gpui-terminal` `render.rs`).

No other source diffs vs crates.io 0.26.0.

## Tree hygiene

Keep `src/`, `Cargo.toml`, `LICENSE-APACHE`, `.cargo_vcs_info.json`. Do **not** re-vendor crates.io `tests/` (~3 MiB of ref recordings), `Cargo.lock`, README, or CHANGELOG — Omnimux does not run those tests.


---

# Vendored gpui-pre platform crates (0.3.5)

Omnimux depends on crates.io **`gpui-pre` 0.3.5** + **`gpui-pre-platform`** +
**`gpui-component` 0.6.4** (no longer vendors the monolithic `gpui-ce` tree).
Platform backends are split: we path-patch only the crates that carry Omnimux
deltas via `[patch.crates-io]` in `src/Cargo.toml`.

| Vendored crate | Upstream | Why patched |
| --- | --- | --- |
| `vendor/gpui-pre-linux` | `gpui-pre-linux` 0.3.5 (zed@d89e9c2) | Wayland `wl_touch`, pointer press orphan fix, XDP appearance RefCell, maximized resize guard |
| `vendor/gpui-pre-wgpu` | `gpui-pre-wgpu` 0.3.5 | cosmic-text emoji / Nerd fallback (Starship `🐍` tofu) |
| `vendor/gpui-pre-macos` | `gpui-pre-macos` 0.3.5 | `CTFontManagerRegisterGraphicsFont` + Nerd symbols `has_m_glyph` bypass |

App entry uses `gpui_platform::application()` (platforms no longer live inside `gpui`).

## Local changes (vs stock 0.3.5)

Touch source: [zed#40139](https://github.com/zed-industries/zed/pull/40139) /
`robert7k` `feature/touch-events` (still not in this gpui-pre snapshot). Pinch-to-zoom
from that PR omitted (`KeyDownEvent` lacks the fields it needs).

**`gpui-pre-linux`**

- `wayland/serial.rs`: `SerialKind::Touch`.
- `wayland/client.rs`: bind `wl_touch` from seat capabilities; single-finger → mouse
  down/move/up; two-finger pan → scroll. On touch down, set `mouse_focused_window`
  from the touched surface so up/move work without a prior pointer Enter. Keep
  `touch_window` + `touch_mouse_down_sent` so pointer Leave cannot orphan MouseUp;
  Cancel synthesizes MouseUp; ending two-finger scroll does not re-assert
  `button_pressed`. Same multi-click tracking as `wl_pointer` (title-bar double-tap).
  `pointer_button_window` across `wl_pointer::Leave` for the same orphan class.
  `GPUI_TOUCHSCREEN_DRAG_SCROLLS` (default on): single-finger motion past 8px becomes
  scroll instead of drag. XDP appearance: drop client `RefCell` before `set_appearance`.
- `wayland/window.rs`: skip `start_window_resize` when maximized.
- `x11/client.rs`: same XDP appearance borrow fix.

**`gpui-pre-wgpu`** (`cosmic_text_system.rs`)

- Custom `TerminalSymbolFallback`: put bundled CBDT **Noto Color Emoji** first, then
  Symbols Nerd Font Mono / Symbols Nerd Font; forbid Compat Test / outline Noto Emoji /
  Unifont* / Segoe emoji. Strip competing system faces so Starship bold `🐍` does not
  paint yellow tofu.
- `remove_competing_emoji_faces` before `FontSystem::new_with_locale_and_db_and_fallback`.

**`gpui-pre-macos`** (`text_system.rs`)

- Register bundled fonts with `CTFontManagerRegisterGraphicsFont`.
- Treat Symbols Nerd Font like Segoe Fluent Icons for the `m`-glyph load gate.

`gpui-component` 0.6.4 is used from crates.io (maximized window-border guard is upstream).
Default theme still ships a `drag_border` JSON key while schema expects `drag.border`;
serde ignores the typo and falls back to `primary` — acceptable, not worth re-vendoring
the whole crate for.

---
