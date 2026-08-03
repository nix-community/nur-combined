//! Input-policy tests — modifier precedence and the digit convention.

use super::*;

fn m(shift: bool, ctrl: bool, alt: bool) -> Mods {
    Mods { shift, ctrl, alt }
}

#[test]
fn test_wheel_modifier_precedence_ctrl_shift_alt_zoom() {
    // Historical precedence: Ctrl > Shift > Alt > Zoom.
    assert_eq!(wheel_action(m(true, true, true), 1), UserAction::ChangeFontSize(1));
    assert_eq!(wheel_action(m(true, false, true), 1), UserAction::ResizeMagnifier(1));
    assert_eq!(wheel_action(m(false, false, true), 1), UserAction::ChangeAimSize(1));
    assert_eq!(wheel_action(m(false, false, false), -1), UserAction::Zoom(-1));
}

#[test]
fn test_arrow_jump_on_shift_or_ctrl() {
    assert_eq!(arrow_action(m(true, false, false), -1, 0), UserAction::Jump(-1, 0));
    assert_eq!(arrow_action(m(false, true, false), 0, 1), UserAction::Jump(0, 1));
    assert_eq!(arrow_action(m(false, false, true), 1, 0), UserAction::Nudge(1, 0));
    assert_eq!(arrow_action(m(false, false, false), 0, -1), UserAction::Nudge(0, -1));
}

#[test]
fn test_arrow_release_maps_direction() {
    assert_eq!(arrow_release(1, 0), UserAction::KeyRelease { dx: 1, dy: 0 });
}

#[test]
fn test_digit_convention_as_typed() {
    // Single convention: the digit as typed, '0' = 0 (NOT 10, as Windows had it).
    assert_eq!(digit_action(1), Some(UserAction::SelectFormatDigit(1)));
    assert_eq!(digit_action(9), Some(UserAction::SelectFormatDigit(9)));
    assert_eq!(digit_action(0), Some(UserAction::SelectFormatDigit(0)));
    assert_eq!(digit_action(10), None);
    assert_eq!(digit_action(255), None);
}
