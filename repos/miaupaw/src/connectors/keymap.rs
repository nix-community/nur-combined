//!
//!
//! Platform-neutral input policy: semantic key → UserAction.
//!
//! Connectors translate the OS event (keysym / PhysicalKey / VIRTUAL_KEY)
//! into semantics ("digit 7", "arrow left", "wheel −1") and ask the policy
//! here. The policy itself — what each modifier means, how the digit row is
//! encoded — lives in ONE place and cannot drift between backends (as it
//! already had: "0" reached the core as 0 from Wayland/X11 and as 10 from
//! Windows, converging only by accident of the core's formula).

use crate::core::overlay::UserAction;

/// Modifier snapshot at event time. Each connector tracks them its own way
/// (sctk Modifiers / hand-rolled booleans) — this is the digest.
#[derive(Clone, Copy, Default)]
pub struct Mods {
    pub shift: bool,
    pub ctrl: bool,
    pub alt: bool,
}

/// Mouse wheel. Modifier precedence (historical, on every backend):
/// Ctrl → font size · Shift → magnifier size · Alt → aim/averaging field ·
/// no modifiers → zoom (aperture).
pub fn wheel_action(mods: Mods, delta: i32) -> UserAction {
    if mods.ctrl {
        UserAction::ChangeFontSize(delta)
    } else if mods.shift {
        UserAction::ResizeMagnifier(delta)
    } else if mods.alt {
        UserAction::ChangeAimSize(delta)
    } else {
        UserAction::Zoom(delta)
    }
}

/// Arrows: Shift or Ctrl → Jump (hop to the next color boundary),
/// otherwise Nudge (move the aim 1px).
pub fn arrow_action(mods: Mods, dx: i32, dy: i32) -> UserAction {
    if mods.ctrl || mods.shift {
        UserAction::Jump(dx, dy)
    } else {
        UserAction::Nudge(dx, dy)
    }
}

/// Arrow release — stops the core's custom auto-repeat.
pub fn arrow_release(dx: i32, dy: i32) -> UserAction {
    UserAction::KeyRelease { dx, dy }
}

/// Digit row. SINGLE CONVENTION: pass the digit AS TYPED, 0..=9 (top row
/// and numpad are equivalent). The "1 → first format, 0 → tenth" layout is
/// the core's business (`SelectFormatDigit`), not the connectors'.
/// Values outside 0..=9 → None (guards against a bad mapping).
pub fn digit_action(digit: u8) -> Option<UserAction> {
    (digit <= 9).then_some(UserAction::SelectFormatDigit(digit as usize))
}

#[cfg(test)]
#[path = "keymap_tests.rs"]
mod tests;
