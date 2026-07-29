# Vendored gpui 0.2.2 (Wayland touch)

Omnimux uses crates.io `gpui` 0.2.2 + `gpui-component` 0.5.1. Upstream GPUI on
Wayland ignores `wl_touch`, so touchscreen taps never become clicks. We cannot
`[patch]` to [robert7k/zed `feature/touch-events`](https://github.com/robert7k/zed/tree/feature/touch-events)
or [gpui-ce](https://github.com/gpui-ce/gpui-ce): those are workspace monorepos
(split `gpui_linux`, `*.workspace = true` deps) even when they still say
`version = "0.2.2"`, and gpui-ce has no `wl_touch` anyway. See also
[zed#40139](https://github.com/zed-industries/zed/pull/40139).

So we vendor the **published** crates.io tree and port a minimal touch patch
onto it. Cargo picks it up via `[patch.crates-io]` in
`by-name/om/omnimux/src/Cargo.toml`.

## Baseline

| | |
| --- | --- |
| Crate | `gpui` 0.2.2 |
| crates.io checksum | `979b45cfa6ec723b6f42330915a1b3769b930d02b2d505f9697f8ca602bee707` |
| License | Apache-2.0 (see `LICENSE-APACHE`) |

## How this tree was obtained

```bash
# 1. Download the exact crates.io release
curl -fsSL -o gpui-0.2.2.crate \
  https://static.crates.io/crates/gpui/0.2.2/download
tar xf gpui-0.2.2.crate

# 2. Copy into vendor/ (omit examples/tests/docs; strip [[example]]/[[test]]
#    from Cargo.toml so those missing dirs are fine)
rsync -a --exclude examples --exclude tests --exclude docs \
  gpui-0.2.2/ by-name/om/omnimux/src/vendor/gpui/

# 3. Apply local Wayland touch changes (see below), then:
#    - keep [patch.crates-io] gpui = { path = "vendor/gpui" } in Cargo.toml
#    - cargo check / nix build .#omnimux
```

To refresh against a newer crates.io `gpui` (only when `gpui-component` allows
it): repeat the download for that version, re-apply the touch edits (or rebase
them), update this file’s checksum/version, and regenerate `Cargo.lock`.

## Local changes (vs stock 0.2.2)

Source of the touch logic:
[zed#40139](https://github.com/zed-industries/zed/pull/40139) /
`robert7k` `feature/touch-events`, adapted to the monolithic
`src/platform/linux/wayland/` layout of crates.io 0.2.2.

- `serial.rs`: add `SerialKind::Touch`.
- `client.rs`: bind `wl_touch` from seat capabilities; map single-finger
  down/motion/up to mouse down/move/up; map two-finger pan to scroll.
- Pinch-to-zoom from upstream omitted (`KeyDownEvent` in 0.2.2 lacks fields
  that PR uses).
- On touch down, set `mouse_focused_window` from the touched surface so up/move
  reach the window even if the pointer never entered (gap in the upstream PR).
- Also keep `touch_window` + `touch_mouse_down_sent` so a later pointer Leave
  cannot orphan MouseUp, Cancel synthesizes MouseUp (not only MouseExited),
  and ending a two-finger scroll does not re-assert `button_pressed` (stuck
  tmux/local drag after lift).
- Pointer MouseDown similarly remembers `pointer_button_window` across
  `wl_pointer::Leave`, so Button release still delivers MouseUp (same orphan
  class as touch). Enter does not clear an in-flight press.
- Touch uses the same multi-click (`click_count`) tracking as `wl_pointer`, so
  title-bar double-tap can maximize like a mouse double-click.
- Added `GPUI_TOUCHSCREEN_DRAG_SCROLLS` environment variable logic. When enabled,
  a single-finger touch motion emulates a scroll wheel (if it exceeds a 8px threshold)
  instead of emulating a left-click drag, improving touch scrolling on Wayland.
- `Pixels`: use `f32::from(...)` instead of `.as_f32()` (not on 0.2.2).
- `platform/linux/text_system.rs`: extend cosmic-text's Unix font fallback list
  with `Symbols Nerd Font Mono` / `Symbols Nerd Font` (Omnimux ships them for
  Starship; GPUI's `Font.fallbacks` field is ignored on Linux). Put
  `Noto Color Emoji` before Noto Sans / DejaVu / Symbols2. Strip system
  `Noto Color Emoji` (often COLRv1 → blank glyphs under Swash) so bundled CBDT
  emoji from `add_fonts` wins. Allow loading symbol/emoji faces that lack ASCII `m`.
- Wayland/X11 XDP appearance handler: drop the client `RefCell` borrow before
  `set_appearance` (observers may call `Platform::window_appearance` →
  `with_common`). Also take-call-restore for the appearance callback.

## Why not git-only from Zed / gpui-ce

- Omnimux + `gpui-component` 0.5.1 expect the **published** 0.2.2 package graph.
- Monorepo `gpui` is not a drop-in path/git patch for that crate.
- Hosting this same patched tree on a separate git remote would only avoid
  committing files here; it would still be our patched crates.io 0.2.2, not
  upstream tip.

**Update (July 2026 — original):** We investigated upgrading `gpui-component` to its latest `main` commit. However, `gpui-component` has radically changed how it depends on GPUI. It now pulls directly from `zed-industries/zed` via git. Upstream Zed has completely restructured the GPUI codebase (e.g., splitting Wayland code into a separate `gpui_linux` crate) and still has not merged the `wl_touch` PR. Upgrading would require vendoring the entire Zed monorepo (or its GPUI crates) into a new `vendor/zed` directory and porting our ~900-line Wayland touch patch to the new crate architecture. Thus, we remain on `gpui-component` 0.5.1 and this patched crates.io 0.2.2 release for now.

**Update (July 2026 — gpui-ce / gpui-component latest research):** We re-investigated both `gpui-ce` and `gpui-component` latest commits:

### `gpui-ce` (community fork, commit `c1faa21`, 2026-07-28)

- **Repository**: [gpui-ce/gpui-ce](https://github.com/gpui-ce/gpui-ce)
- **Structure**: A workspace monorepo split into ~13 sub-crates:
  `gpui`, `gpui_linux`, `gpui_macos`, `gpui_windows`, `gpui_platform`,
  `gpui_elements`, `gpui_collections`, `gpui_scheduler`, `gpui_macros`, etc.
  All use `*.workspace = true` dependencies.
- **Blocker**: Cannot be used via `[patch.crates-io]` because it is not a
  self-contained crate — it is a workspace member that depends on its own
  sibling crates in the same monorepo. Patching would require restructuring
  omnimux itself to be a workspace member of the gpui-ce monorepo, or
  re-merging all sub-crates into one (undoing the split), both of which are
  impractical.
- **Wayland touch**: gpui-ce does **not** include Wayland `wl_touch` support.
  Upgrading would also lose our existing touch functionality.

### `gpui-component` latest main (commit `57a9903f`, 2026-07-28)

- **Repository**: [longbridge/gpui-component](https://github.com/longbridge/gpui-component)
- **Version**: `0.5.2` (workspace `Cargo.toml` bumped from 0.5.1)
- **Blocker**: Workspace `Cargo.toml` depends on gpui directly from the Zed
  monorepo: `gpui = { git = "https://github.com/zed-industries/zed" }`.
  This means it is incompatible with our vendored standalone `gpui` 0.2.2.
  Using this version would require pulling in the full Zed monorepo structure.

### Conclusion and path forward

Both upgrades are blocked by the same fundamental incompatibility: upstream has
migrated to a monorepo architecture that cannot be used with our single-crate
path-dependency vendoring strategy. The only realistic paths forward are:

1. **Wait for `gpui-ce` to publish standalone crates to crates.io** — then we
   can vendor that version the same way we did 0.2.2, re-apply our Wayland
   touch patch to the new architecture.
2. **Make omnimux a workspace member of the gpui-ce monorepo** — a large
   structural change that also requires porting the `wl_touch` patch to the
   new `gpui_linux` crate split.
3. **Contribute `wl_touch` to gpui-ce** — if upstreamed, we could use gpui-ce
   without carrying our own touch patch, but we'd still need option 1 or 2
   to actually use it.

For now we remain on **`gpui` 0.2.2** (this patched vendor tree) and
**`gpui-component` 0.5.1** (vendored at `vendor/gpui-component/`).

