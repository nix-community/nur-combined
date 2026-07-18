//! Mouse event handling for the terminal emulator.
//!
//! This module provides utilities for mouse interaction with the terminal:
//!
//! - [`pixel_to_cell`]: Convert pixel coordinates to grid coordinates
//! - [`mouse_button_report`]: Generate SGR mouse report sequences
//! - [`scroll_report`]: Handle scroll wheel events
//! - [`Selection`]: Text selection data structure
//!
//! # Mouse Reporting (SGR 1006)
//!
//! When mouse tracking is enabled, the terminal sends escape sequences to
//! the application. This module uses the SGR (1006) format:
//!
//! ```text
//! ESC [ < button ; column ; row M   (button press)
//! ESC [ < button ; column ; row m   (button release)
//! ```
//!
//! ## Button Encoding
//!
//! | Button | Code | With Modifiers |
//! |--------|------|----------------|
//! | Left | 0 | + modifier bits |
//! | Middle | 1 | + modifier bits |
//! | Right | 2 | + modifier bits |
//! | Wheel Up | 64 | + modifier bits |
//! | Wheel Down | 65 | + modifier bits |
//!
//! ## Modifier Bits
//!
//! | Modifier | Bit | Value |
//! |----------|-----|-------|
//! | Shift | 2 | 4 |
//! | Alt/Meta | 3 | 8 |
//! | Control | 4 | 16 |
//!
//! # Terminal Modes
//!
//! Mouse reporting depends on terminal mode flags:
//!
//! | Mode | Description |
//! |------|-------------|
//! | `MOUSE_REPORT_CLICK` | Report button press/release |
//! | `MOUSE_MOTION` | Report motion while buttons held |
//! | `MOUSE_DRAG` | Report motion during drag |
//! | `ALT_SCREEN` | Alternate screen (vim, less, etc.) |
//!
//! # Scroll Behavior
//!
//! Scroll handling depends on the terminal mode:
//!
//! 1. **Mouse mode enabled**: Send wheel events (codes 64/65)
//! 2. **Alternate screen, no mouse**: Convert to arrow keys
//! 3. **Normal screen, no mouse**: Return None (handle as scrollback)
//!
//! # Example
//!
//! ```
//! use gpui::{point, px, MouseButton};
//! use alacritty_terminal::term::TermMode;
//! use alacritty_terminal::index::{Point, Line, Column};
//! use gpui_terminal::mouse::{pixel_to_cell, mouse_button_report};
//!
//! // Convert pixel position to cell
//! let position = point(px(100.0), px(50.0));
//! let origin = point(px(10.0), px(10.0));
//! let cell = pixel_to_cell(position, origin, px(10.0), px(20.0));
//!
//! // Generate mouse report for left click
//! let point = Point::new(Line(5), Column(10));
//! let mode = TermMode::MOUSE_REPORT_CLICK;
//! let bytes = mouse_button_report(MouseButton::Left, true, point, 0, mode);
//! ```

use alacritty_terminal::index::{Column, Line, Point as AlacPoint};
use alacritty_terminal::term::TermMode;
use gpui::{MouseButton, Pixels, Point};

/// Type of text selection in the terminal.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SelectionType {
    /// Character-by-character selection (single click).
    Simple,
    /// Word-based selection (double click).
    Word,
    /// Line-based selection (triple click).
    Line,
}

/// Represents a text selection in the terminal.
///
/// A selection has a start and end point in the terminal grid.
/// The selection is inclusive of both endpoints.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Selection {
    /// The starting point of the selection.
    pub start: AlacPoint,
    /// The ending point of the selection.
    pub end: AlacPoint,
    /// The type of selection (character, word, or line).
    pub selection_type: SelectionType,
}

impl Selection {
    /// Create a new selection.
    ///
    /// # Arguments
    ///
    /// * `start` - The starting point of the selection
    /// * `end` - The ending point of the selection
    /// * `selection_type` - The type of selection
    ///
    /// # Returns
    ///
    /// A new `Selection` instance.
    pub fn new(start: AlacPoint, end: AlacPoint, selection_type: SelectionType) -> Self {
        Self {
            start,
            end,
            selection_type,
        }
    }

    /// Check if a point is within the selection.
    ///
    /// # Arguments
    ///
    /// * `point` - The point to check
    ///
    /// # Returns
    ///
    /// `true` if the point is within the selection, `false` otherwise.
    pub fn contains(&self, point: AlacPoint) -> bool {
        let (start, end) = if self.start < self.end {
            (self.start, self.end)
        } else {
            (self.end, self.start)
        };

        point >= start && point <= end
    }
}

/// Convert pixel position to terminal grid coordinates.
///
/// This function transforms a pixel coordinate (e.g., from a mouse event) into
/// the corresponding cell position in the terminal grid.
///
/// # Arguments
///
/// * `position` - The pixel position to convert
/// * `origin` - The top-left origin of the terminal grid in pixels
/// * `cell_width` - The width of a single character cell in pixels
/// * `cell_height` - The height of a single character cell in pixels
///
/// # Returns
///
/// The terminal grid coordinates corresponding to the pixel position.
///
/// # Examples
///
/// ```
/// use gpui::{Point, Pixels, point, px};
/// use gpui_terminal::mouse::pixel_to_cell;
///
/// let position = point(px(100.0), px(50.0));
/// let origin = point(px(10.0), px(10.0));
/// let cell_width = px(10.0);
/// let cell_height = px(20.0);
///
/// let point = pixel_to_cell(position, origin, cell_width, cell_height);
/// // Point will be at column 9, line 2
/// ```
pub fn pixel_to_cell(
    position: Point<Pixels>,
    origin: Point<Pixels>,
    cell_width: Pixels,
    cell_height: Pixels,
) -> AlacPoint {
    // Calculate the column (x-coordinate)
    let col = ((position.x - origin.x) / cell_width).floor();
    let col = col.max(0.0) as usize;

    // Calculate the row (y-coordinate)
    let row = ((position.y - origin.y) / cell_height).floor();
    let row = row.max(0.0) as i32;

    AlacPoint::new(Line(row), Column(col))
}

/// Determine the selection type based on the number of clicks.
///
/// # Arguments
///
/// * `click_count` - The number of consecutive clicks
///
/// # Returns
///
/// The corresponding `SelectionType`:
/// - 1 click: `SelectionType::Simple`
/// - 2 clicks: `SelectionType::Word`
/// - 3 or more clicks: `SelectionType::Line`
///
/// # Examples
///
/// ```
/// use gpui_terminal::mouse::{selection_type_from_clicks, SelectionType};
///
/// assert_eq!(selection_type_from_clicks(1), SelectionType::Simple);
/// assert_eq!(selection_type_from_clicks(2), SelectionType::Word);
/// assert_eq!(selection_type_from_clicks(3), SelectionType::Line);
/// assert_eq!(selection_type_from_clicks(4), SelectionType::Line);
/// ```
pub fn selection_type_from_clicks(click_count: usize) -> SelectionType {
    match click_count {
        1 => SelectionType::Simple,
        2 => SelectionType::Word,
        _ => SelectionType::Line,
    }
}

/// Generate mouse button report escape sequence for SGR mode.
///
/// This function generates the escape sequence that should be sent to the
/// terminal application when mouse reporting is enabled. The sequence follows
/// the SGR (1006) mouse tracking format.
///
/// # Arguments
///
/// * `button` - The mouse button that was pressed/released
/// * `pressed` - `true` if the button was pressed, `false` if released
/// * `point` - The terminal grid coordinates where the event occurred
/// * `modifiers` - Modifier keys held during the event (shift, alt, ctrl)
/// * `mode` - The current terminal mode flags
///
/// # Returns
///
/// An optional vector of bytes representing the mouse report escape sequence.
/// Returns `None` if mouse reporting is not enabled in the terminal mode.
///
/// # Mouse Report Format
///
/// The SGR format is: `ESC [ < button ; col ; row M` (pressed) or `m` (released)
/// where:
/// - button is a number encoding the button and modifiers
/// - col is the column number (1-based)
/// - row is the row number (1-based)
///
/// # Examples
///
/// ```
/// use gpui::MouseButton;
/// use alacritty_terminal::term::TermMode;
/// use alacritty_terminal::index::{Point, Line, Column};
/// use gpui_terminal::mouse::mouse_button_report;
///
/// let point = Point::new(Line(5), Column(10));
/// let mode = TermMode::MOUSE_REPORT_CLICK;
///
/// let bytes = mouse_button_report(MouseButton::Left, true, point, 0, mode);
/// assert!(bytes.is_some());
/// ```
pub fn mouse_button_report(
    button: MouseButton,
    pressed: bool,
    point: AlacPoint,
    modifiers: u8,
    mode: TermMode,
) -> Option<Vec<u8>> {
    // Check if mouse reporting is enabled
    if !mode
        .intersects(TermMode::MOUSE_REPORT_CLICK | TermMode::MOUSE_MOTION | TermMode::MOUSE_DRAG)
    {
        return None;
    }

    // Encode button number
    let button_code = match button {
        MouseButton::Left => 0,
        MouseButton::Middle => 1,
        MouseButton::Right => 2,
        _ => return None, // Ignore other buttons
    };

    // Add modifier bits
    // Bit 2: Shift, Bit 3: Alt, Bit 4: Control
    let button_value = button_code | modifiers;

    // SGR format uses 1-based indexing
    let col = point.column.0 + 1;
    let row = point.line.0 + 1;

    // SGR format: ESC [ < button ; col ; row M/m
    // M for press, m for release
    let action = if pressed { b'M' } else { b'm' };

    let sequence = format!("\x1b[<{};{};{}{}", button_value, col, row, action as char);
    Some(sequence.into_bytes())
}

/// Generate scroll wheel report escape sequence.
///
/// This function generates the escape sequence for scroll wheel events.
/// The behavior depends on the terminal mode:
/// - In mouse mode: sends a mouse wheel report
/// - In alternate screen without mouse mode: sends arrow key sequences
/// - In normal screen: returns None (let the terminal handle scrollback)
///
/// # Arguments
///
/// * `delta` - The scroll delta (positive = up, negative = down)
/// * `point` - The terminal grid coordinates where the scroll occurred
/// * `modifiers` - Modifier keys held during the scroll
/// * `mode` - The current terminal mode flags
///
/// # Returns
///
/// An optional vector of bytes representing the scroll report.
/// Returns `None` if scrolling should be handled locally (scrollback).
///
/// # Examples
///
/// ```
/// use alacritty_terminal::term::TermMode;
/// use alacritty_terminal::index::{Point, Line, Column};
/// use gpui_terminal::mouse::scroll_report;
///
/// let point = Point::new(Line(5), Column(10));
/// let mode = TermMode::MOUSE_REPORT_CLICK;
///
/// let bytes = scroll_report(3, point, 0, mode);
/// assert!(bytes.is_some());
/// ```
pub fn scroll_report(
    delta: i32,
    point: AlacPoint,
    modifiers: u8,
    mode: TermMode,
) -> Option<Vec<u8>> {
    // If mouse reporting is enabled, send mouse wheel events
    if mode.intersects(TermMode::MOUSE_REPORT_CLICK | TermMode::MOUSE_MOTION | TermMode::MOUSE_DRAG)
    {
        // Button codes for scroll: 64 = wheel up, 65 = wheel down
        let button_code = if delta > 0 { 64 } else { 65 };
        let button_value = button_code | modifiers;

        // SGR format uses 1-based indexing
        let col = point.column.0 + 1;
        let row = point.line.0 + 1;

        // Mouse wheel events are always "pressed" (M), never released
        let sequence = format!("\x1b[<{};{};{}M", button_value, col, row);
        return Some(sequence.into_bytes());
    }

    // If in alternate screen mode but no mouse reporting, send arrow keys
    if mode.contains(TermMode::ALT_SCREEN) {
        return Some(scroll_to_arrow_keys(delta, mode));
    }

    // In normal screen mode without mouse reporting, let the terminal handle scrollback
    None
}

/// Convert scroll delta to arrow key sequences.
///
/// This is used when an application is in alternate screen mode (like vim or less)
/// but doesn't have mouse reporting enabled. The scroll wheel is translated to
/// arrow key presses to allow navigation.
///
/// # Arguments
///
/// * `delta` - The scroll delta (positive = up, negative = down)
/// * `mode` - The current terminal mode (affects arrow key format)
///
/// # Returns
///
/// A byte sequence containing the appropriate arrow key escape sequences.
fn scroll_to_arrow_keys(delta: i32, mode: TermMode) -> Vec<u8> {
    let count = delta.abs().min(5) as usize; // Limit to 5 lines per scroll

    // Determine arrow key sequence based on mode
    let arrow_seq = if delta > 0 {
        // Scroll up = arrow up
        if mode.contains(TermMode::APP_CURSOR) {
            b"\x1bOA"
        } else {
            b"\x1b[A"
        }
    } else {
        // Scroll down = arrow down
        if mode.contains(TermMode::APP_CURSOR) {
            b"\x1bOB"
        } else {
            b"\x1b[B"
        }
    };

    // Repeat the arrow key sequence
    let mut result = Vec::with_capacity(arrow_seq.len() * count);
    for _ in 0..count {
        result.extend_from_slice(arrow_seq);
    }
    result
}

/// Encode modifier keys as a bitmask for mouse reporting.
///
/// # Arguments
///
/// * `shift` - Whether Shift is pressed
/// * `alt` - Whether Alt is pressed
/// * `control` - Whether Control is pressed
///
/// # Returns
///
/// A bitmask encoding the modifiers:
/// - Bit 2 (4): Shift
/// - Bit 3 (8): Alt/Meta
/// - Bit 4 (16): Control
///
/// # Examples
///
/// ```
/// use gpui_terminal::mouse::encode_modifiers;
///
/// assert_eq!(encode_modifiers(false, false, false), 0);
/// assert_eq!(encode_modifiers(true, false, false), 4);
/// assert_eq!(encode_modifiers(false, true, false), 8);
/// assert_eq!(encode_modifiers(false, false, true), 16);
/// assert_eq!(encode_modifiers(true, true, true), 28);
/// ```
pub fn encode_modifiers(shift: bool, alt: bool, control: bool) -> u8 {
    let mut modifiers = 0;
    if shift {
        modifiers |= 4;
    }
    if alt {
        modifiers |= 8;
    }
    if control {
        modifiers |= 16;
    }
    modifiers
}

/// Calculate the number of lines to scroll based on pixel delta.
///
/// This converts a pixel-based scroll delta (from a scroll wheel or trackpad)
/// into a number of terminal lines to scroll.
///
/// # Arguments
///
/// * `pixel_delta` - The scroll delta in pixels (positive = up)
/// * `cell_height` - The height of a character cell in pixels
///
/// # Returns
///
/// The number of lines to scroll (positive = up, negative = down).
/// The result is clamped to a reasonable range.
///
/// # Examples
///
/// ```
/// use gpui::px;
/// use gpui_terminal::mouse::pixels_to_scroll_lines;
///
/// let cell_height = px(20.0);
/// assert_eq!(pixels_to_scroll_lines(px(60.0), cell_height), 3);
/// assert_eq!(pixels_to_scroll_lines(px(-40.0), cell_height), -2);
/// ```
pub fn pixels_to_scroll_lines(pixel_delta: Pixels, cell_height: Pixels) -> i32 {
    let lines = (pixel_delta / cell_height).round();
    // Clamp to reasonable range (-10 to 10 lines per scroll event)
    lines.clamp(-10.0, 10.0) as i32
}

#[cfg(test)]
mod tests {
    use super::*;
    use gpui::{point, px};

    #[test]
    fn test_pixel_to_cell() {
        let position = point(px(100.0), px(50.0));
        let origin = point(px(10.0), px(10.0));
        let cell_width = px(10.0);
        let cell_height = px(20.0);

        let point = pixel_to_cell(position, origin, cell_width, cell_height);
        assert_eq!(point.column.0, 9);
        assert_eq!(point.line.0, 2);
    }

    #[test]
    fn test_pixel_to_cell_at_origin() {
        let position = point(px(10.0), px(10.0));
        let origin = point(px(10.0), px(10.0));
        let cell_width = px(10.0);
        let cell_height = px(20.0);

        let point = pixel_to_cell(position, origin, cell_width, cell_height);
        assert_eq!(point.column.0, 0);
        assert_eq!(point.line.0, 0);
    }

    #[test]
    fn test_pixel_to_cell_negative_coordinates() {
        // Coordinates before origin should clamp to 0
        let position = point(px(5.0), px(5.0));
        let origin = point(px(10.0), px(10.0));
        let cell_width = px(10.0);
        let cell_height = px(20.0);

        let point = pixel_to_cell(position, origin, cell_width, cell_height);
        assert_eq!(point.column.0, 0);
        assert_eq!(point.line.0, 0);
    }

    #[test]
    fn test_selection_type_from_clicks() {
        assert_eq!(selection_type_from_clicks(1), SelectionType::Simple);
        assert_eq!(selection_type_from_clicks(2), SelectionType::Word);
        assert_eq!(selection_type_from_clicks(3), SelectionType::Line);
        assert_eq!(selection_type_from_clicks(4), SelectionType::Line);
        assert_eq!(selection_type_from_clicks(10), SelectionType::Line);
    }

    #[test]
    fn test_selection_contains() {
        let selection = Selection::new(
            AlacPoint::new(Line(5), Column(10)),
            AlacPoint::new(Line(7), Column(20)),
            SelectionType::Simple,
        );

        // Point within selection
        assert!(selection.contains(AlacPoint::new(Line(6), Column(15))));

        // Start and end points
        assert!(selection.contains(AlacPoint::new(Line(5), Column(10))));
        assert!(selection.contains(AlacPoint::new(Line(7), Column(20))));

        // Points outside selection
        assert!(!selection.contains(AlacPoint::new(Line(4), Column(15))));
        assert!(!selection.contains(AlacPoint::new(Line(8), Column(15))));
    }

    #[test]
    fn test_selection_contains_reverse() {
        // Test with end < start (reversed selection)
        let selection = Selection::new(
            AlacPoint::new(Line(7), Column(20)),
            AlacPoint::new(Line(5), Column(10)),
            SelectionType::Simple,
        );

        // Should still work correctly
        assert!(selection.contains(AlacPoint::new(Line(6), Column(15))));
        assert!(selection.contains(AlacPoint::new(Line(5), Column(10))));
        assert!(selection.contains(AlacPoint::new(Line(7), Column(20))));
    }

    #[test]
    fn test_mouse_button_report_left_click() {
        let point = AlacPoint::new(Line(5), Column(10));
        let mode = TermMode::MOUSE_REPORT_CLICK;

        let bytes = mouse_button_report(MouseButton::Left, true, point, 0, mode);
        assert!(bytes.is_some());

        let sequence = String::from_utf8(bytes.unwrap()).unwrap();
        // SGR format: ESC[<button;col;row M
        // Line 5 (0-indexed) = row 6 (1-indexed)
        // Column 10 (0-indexed) = col 11 (1-indexed)
        assert_eq!(sequence, "\x1b[<0;11;6M");
    }

    #[test]
    fn test_mouse_button_report_right_release() {
        let point = AlacPoint::new(Line(0), Column(0));
        let mode = TermMode::MOUSE_REPORT_CLICK;

        let bytes = mouse_button_report(MouseButton::Right, false, point, 0, mode);
        assert!(bytes.is_some());

        let sequence = String::from_utf8(bytes.unwrap()).unwrap();
        // Right button = 2, released = 'm'
        assert_eq!(sequence, "\x1b[<2;1;1m");
    }

    #[test]
    fn test_mouse_button_report_with_modifiers() {
        let point = AlacPoint::new(Line(0), Column(0));
        let mode = TermMode::MOUSE_REPORT_CLICK;
        let modifiers = encode_modifiers(true, true, true); // Shift + Alt + Ctrl = 28

        let bytes = mouse_button_report(MouseButton::Left, true, point, modifiers, mode);
        assert!(bytes.is_some());

        let sequence = String::from_utf8(bytes.unwrap()).unwrap();
        // Button 0 + modifiers 28 = 28
        assert_eq!(sequence, "\x1b[<28;1;1M");
    }

    #[test]
    fn test_mouse_button_report_disabled() {
        let point = AlacPoint::new(Line(0), Column(0));
        let mode = TermMode::empty();

        let bytes = mouse_button_report(MouseButton::Left, true, point, 0, mode);
        assert!(bytes.is_none());
    }

    #[test]
    fn test_scroll_report_mouse_mode() {
        let point = AlacPoint::new(Line(5), Column(10));
        let mode = TermMode::MOUSE_REPORT_CLICK;

        // Scroll up
        let bytes = scroll_report(3, point, 0, mode);
        assert!(bytes.is_some());
        let sequence = String::from_utf8(bytes.unwrap()).unwrap();
        // Wheel up = button 64
        assert_eq!(sequence, "\x1b[<64;11;6M");

        // Scroll down
        let bytes = scroll_report(-2, point, 0, mode);
        assert!(bytes.is_some());
        let sequence = String::from_utf8(bytes.unwrap()).unwrap();
        // Wheel down = button 65
        assert_eq!(sequence, "\x1b[<65;11;6M");
    }

    #[test]
    fn test_scroll_report_alternate_screen() {
        let point = AlacPoint::new(Line(0), Column(0));
        let mode = TermMode::ALT_SCREEN;

        // Scroll up in alternate screen = arrow up keys
        let bytes = scroll_report(3, point, 0, mode);
        assert!(bytes.is_some());
        let sequence = bytes.unwrap();
        // Should be 3 arrow up sequences
        assert_eq!(sequence, b"\x1b[A\x1b[A\x1b[A");
    }

    #[test]
    fn test_scroll_report_alternate_screen_app_cursor() {
        let point = AlacPoint::new(Line(0), Column(0));
        let mode = TermMode::ALT_SCREEN | TermMode::APP_CURSOR;

        // Scroll down with app cursor mode
        let bytes = scroll_report(-2, point, 0, mode);
        assert!(bytes.is_some());
        let sequence = bytes.unwrap();
        // Should be 2 arrow down sequences in app cursor format
        assert_eq!(sequence, b"\x1bOB\x1bOB");
    }

    #[test]
    fn test_scroll_report_normal_screen() {
        let point = AlacPoint::new(Line(0), Column(0));
        let mode = TermMode::empty();

        // In normal screen mode, scrolling should be handled locally
        let bytes = scroll_report(3, point, 0, mode);
        assert!(bytes.is_none());
    }

    #[test]
    fn test_encode_modifiers() {
        assert_eq!(encode_modifiers(false, false, false), 0);
        assert_eq!(encode_modifiers(true, false, false), 4);
        assert_eq!(encode_modifiers(false, true, false), 8);
        assert_eq!(encode_modifiers(false, false, true), 16);
        assert_eq!(encode_modifiers(true, true, false), 12);
        assert_eq!(encode_modifiers(true, false, true), 20);
        assert_eq!(encode_modifiers(false, true, true), 24);
        assert_eq!(encode_modifiers(true, true, true), 28);
    }

    #[test]
    fn test_pixels_to_scroll_lines() {
        let cell_height = px(20.0);

        assert_eq!(pixels_to_scroll_lines(px(60.0), cell_height), 3);
        assert_eq!(pixels_to_scroll_lines(px(-40.0), cell_height), -2);
        assert_eq!(pixels_to_scroll_lines(px(10.0), cell_height), 1);
        assert_eq!(pixels_to_scroll_lines(px(-10.0), cell_height), -1);

        // Test clamping
        assert_eq!(pixels_to_scroll_lines(px(300.0), cell_height), 10);
        assert_eq!(pixels_to_scroll_lines(px(-300.0), cell_height), -10);
    }

    #[test]
    fn test_scroll_to_arrow_keys_limit() {
        let mode = TermMode::empty();

        // Very large scroll should be limited to 5 lines
        let bytes = scroll_to_arrow_keys(100, mode);
        let expected = b"\x1b[A\x1b[A\x1b[A\x1b[A\x1b[A";
        assert_eq!(bytes, expected);

        let bytes = scroll_to_arrow_keys(-100, mode);
        let expected = b"\x1b[B\x1b[B\x1b[B\x1b[B\x1b[B";
        assert_eq!(bytes, expected);
    }
}
