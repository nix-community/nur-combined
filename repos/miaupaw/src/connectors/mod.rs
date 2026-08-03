// Platform-neutral input policy — shared by every connector.
pub mod keymap;

#[cfg(unix)]
pub mod wayland;
#[cfg(windows)]
pub mod windows;
#[cfg(unix)]
pub mod x11;
