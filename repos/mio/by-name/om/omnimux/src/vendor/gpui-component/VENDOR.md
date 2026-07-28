# gpui-component

This directory contains a vendored copy of `gpui-component` version 0.5.1 from crates.io.

## Why vendored?
`gpui-component` is vendored so we can apply a small local patch to prevent the mouse pointer from changing into a window resize icon when the application window is maximized. 

### Local Patches:
- **`src/window_border.rs`**: Modified `on_mouse_down` and the hover handler to return early if `window.is_maximized()`. This prevents the resize icon from appearing on the edges of the screen when the window is maximized, preventing unintentional resizing triggers.

We are blocked from upgrading to `gpui-component`'s latest `main` branch because that would require upgrading the `gpui` crate to a newer version that drops Wayland support for `gpui::WindowOptions::Client` decorations without vendoring the entire Zed monorepo (see `../gpui/VENDOR.md`). Thus, we vendor version 0.5.1 here.
