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
- `Pixels`: use `f32::from(...)` instead of `.as_f32()` (not on 0.2.2).
- `platform/linux/text_system.rs`: extend cosmic-text's Unix font fallback list
  with `Symbols Nerd Font Mono` / `Symbols Nerd Font` (Omnimux ships them for
  Starship; GPUI's `Font.fallbacks` field is ignored on Linux). Allow loading
  symbol-only faces that lack ASCII `m`.

## Why not git-only from Zed / gpui-ce

- Omnimux + `gpui-component` 0.5.1 expect the **published** 0.2.2 package graph.
- Monorepo `gpui` is not a drop-in path/git patch for that crate.
- Hosting this same patched tree on a separate git remote would only avoid
  committing files here; it would still be our patched crates.io 0.2.2, not
  upstream tip.
