//! IME (Input Method Editor) support for CJK and other composing input.
//!
//! Follows the pattern from Zed's `TerminalInputHandler` in `terminal_element.rs`:
//! register an [`InputHandler`] during paint so Wayland `zwp_text_input_v3` / macOS IME
//! can position the candidate window at the terminal cursor and commit composed text
//! to the PTY.

use crate::view::TerminalView;
use alacritty_terminal::term::Term;
use gpui::*;
use std::ops::Range;

/// Pre-edit (composing) text shown while the IME is active.
#[derive(Clone, Debug, Default)]
pub(crate) struct ImeState {
    pub marked_text: String,
}

/// Compute screen bounds for the IME candidate window at the terminal cursor.
pub(crate) fn ime_cursor_bounds(
    bounds: Bounds<Pixels>,
    padding: Edges<Pixels>,
    cell_width: Pixels,
    cell_height: Pixels,
    term: &Term<crate::event::GpuiEventProxy>,
) -> Option<Bounds<Pixels>> {
    let display_offset = term.grid().display_offset();
    let cursor = term.renderable_content().cursor;
    // Even when the hardware cursor is hidden (vim, tmux status), IME still needs
    // a position — use the logical cursor point (Zed does the same).
    let vp = alacritty_terminal::term::point_to_viewport(display_offset, cursor.point)?;
    let origin_x = bounds.origin.x + padding.left + cell_width * (vp.column.0 as f32);
    let origin_y = bounds.origin.y + padding.top + cell_height * (vp.line as f32);
    Some(Bounds {
        origin: Point::new(origin_x, origin_y),
        size: Size::new(cell_width, cell_height),
    })
}

/// Paint IME pre-edit text with an underline at the cursor cell.
pub(crate) fn paint_marked_text(
    marked_text: &str,
    cursor_bounds: Bounds<Pixels>,
    bg: Hsla,
    fg: Hsla,
    font_family: &str,
    font_size: Pixels,
    line_height: Pixels,
    window: &mut Window,
    cx: &mut App,
) {
    if marked_text.is_empty() {
        return;
    }

    let ime_position = cursor_bounds.origin;

    let shaped_line = window.text_system().shape_line(
        marked_text.to_string().into(),
        font_size,
        &[TextRun {
            len: marked_text.len(),
            font: Font {
                family: font_family.to_string().into(),
                features: Default::default(),
                weight: Default::default(),
                style: Default::default(),
                fallbacks: None,
            },
            color: fg,
            background_color: None,
            underline: Some(UnderlineStyle {
                color: Some(fg),
                thickness: px(1.0),
                wavy: false,
            }),
            strikethrough: None,
        }],
        None,
    );

    let ime_background_bounds = Bounds::new(
        ime_position,
        size(shaped_line.width, line_height),
    );
    window.paint_quad(fill(ime_background_bounds, bg));

    let _ = shaped_line.paint(ime_position, line_height, window, cx);
}

pub(crate) struct TerminalInputHandler {
    pub terminal_view: Entity<TerminalView>,
    pub cursor_bounds: Option<Bounds<Pixels>>,
}

impl InputHandler for TerminalInputHandler {
    fn selected_text_range(
        &mut self,
        _ignore_disabled_input: bool,
        _: &mut Window,
        _cx: &mut App,
    ) -> Option<UTF16Selection> {
        // Always return a valid (empty) selection so IME can position the candidate
        // window, including in alternate-screen TUIs (vim, neovim, etc.).
        Some(UTF16Selection {
            range: 0..0,
            reversed: false,
        })
    }

    fn marked_text_range(&mut self, _: &mut Window, cx: &mut App) -> Option<Range<usize>> {
        self.terminal_view.read(cx).marked_text_range()
    }

    fn text_for_range(
        &mut self,
        _: Range<usize>,
        _: &mut Option<Range<usize>>,
        _: &mut Window,
        _: &mut App,
    ) -> Option<String> {
        None
    }

    fn replace_text_in_range(
        &mut self,
        _replacement_range: Option<Range<usize>>,
        text: &str,
        window: &mut Window,
        cx: &mut App,
    ) {
        self.terminal_view.update(cx, |view, view_cx| {
            view.clear_marked_text(view_cx);
            view.commit_ime_text(text);
        });
        window.invalidate_character_coordinates();
    }

    fn replace_and_mark_text_in_range(
        &mut self,
        _range_utf16: Option<Range<usize>>,
        new_text: &str,
        _new_selected_range: Option<Range<usize>>,
        _: &mut Window,
        cx: &mut App,
    ) {
        self.terminal_view.update(cx, |view, view_cx| {
            view.set_marked_text(new_text.to_string(), view_cx);
        });
    }

    fn unmark_text(&mut self, _: &mut Window, cx: &mut App) {
        self.terminal_view.update(cx, |view, view_cx| {
            view.clear_marked_text(view_cx);
        });
    }

    fn bounds_for_range(
        &mut self,
        range_utf16: Range<usize>,
        _: &mut Window,
        cx: &mut App,
    ) -> Option<Bounds<Pixels>> {
        let mut bounds = self.cursor_bounds?;
        let cell_width = self.terminal_view.read(cx).cell_width();
        let offset = cell_width * range_utf16.start as f32;
        bounds.origin.x += offset;
        Some(bounds)
    }

    fn apple_press_and_hold_enabled(&mut self) -> bool {
        false
    }

    fn character_index_for_point(
        &mut self,
        _: Point<Pixels>,
        _: &mut Window,
        _cx: &mut App,
    ) -> Option<usize> {
        None
    }
}
