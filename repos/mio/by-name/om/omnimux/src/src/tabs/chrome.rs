use super::TerminalTabs;
use super::ChromeColors;
use gpui::prelude::*;
use gpui::*;

/// Bundled Symbols Nerd Font (see `fonts.rs` / `OMNIMUX_FONTS_DIR`).
/// Prefer this over Unicode emoji/`✕` so Plasma never picks Noto Color Emoji
/// (huge colorful glyphs that break title-bar layout and steal clicks).
const CHROME_ICON_FONT: &str = "Symbols Nerd Font Mono";

// Font Awesome PUA in Symbols Nerd Font Mono (verified present in shipped TTF).
const ICON_PLUS: &str = "\u{f067}";
const ICON_SEARCH: &str = "\u{f002}";
const ICON_COG: &str = "\u{f013}";
const ICON_TIMES: &str = "\u{f00d}";
const ICON_MINUS: &str = "\u{f068}";
const ICON_WINDOW_MAXIMIZE: &str = "\u{f2d0}";
const ICON_WINDOW_RESTORE: &str = "\u{f2d2}";

fn chrome_glyph(glyph: &'static str, color: impl Into<Hsla>) -> Div {
    div()
        .child(glyph)
        .text_color(color)
        .font_family(CHROME_ICON_FONT)
        .text_lg()
        .font_weight(FontWeight::MEDIUM)
}

pub fn render_title_bar(
    _this: &TerminalTabs,
    colors: ChromeColors,
    window: &mut Window,
    cx: &mut Context<TerminalTabs>,
) -> impl IntoElement {
    let title_btn = |id: &'static str, glyph: &'static str| {
        div()
            .id(id)
            .flex()
            .flex_shrink_0()
            .items_center()
            .justify_center()
            .h(px(32.0))
            .w(px(44.0))
            .overflow_hidden()
            .ml_1()
            .rounded_sm()
            .cursor_pointer()
            .hover(|style| style.bg(colors.hover))
            // Linux: stop mouse-down from falling through to the terminal (tmux
            // mouse mode would otherwise start a drag) and from title-bar move.
            .on_mouse_down(MouseButton::Left, |_, window, cx| {
                window.prevent_default();
                cx.stop_propagation();
            })
            .child(chrome_glyph(glyph, colors.text))
    };

    let show_client_controls = matches!(window.window_decorations(), Decorations::Client { .. })
        && !cfg!(target_os = "macos");

    let mut title_bar = div()
        .id("title_bar")
        .flex()
        .flex_row()
        .items_center()
        .h(px(36.0))
        .w_full()
        .px_2()
        .bg(colors.bar)
        .border_b_1()
        .border_color(colors.border)
        // Block the terminal (and anything else) under the chrome from seeing
        // title-bar clicks — overlapping flex/`size_full` hitboxes otherwise
        // forward presses into tmux mouse mode.
        .occlude()
        .when(cfg!(target_os = "macos"), |d| d.pl(px(78.0)))
        .child(
            div()
                .id("title_bar_drag")
                .flex()
                .flex_row()
                .items_center()
                .flex_grow()
                .h_full()
                .window_control_area(WindowControlArea::Drag)
                // Wayland/X11 ignore WindowControlArea hit-tests; start a move
                // on drag ourselves (gpui-component TitleBar does the same).
                .on_mouse_down(MouseButton::Left, |_, _, cx| {
                    cx.stop_propagation();
                })
                .on_mouse_move(|ev, window, _| {
                    if ev.pressed_button == Some(MouseButton::Left) {
                        window.start_window_move();
                    }
                })
                .on_click(|ev, window, _| {
                    if ev.click_count() == 2 {
                        if cfg!(target_os = "macos") {
                            window.titlebar_double_click();
                        } else {
                            window.zoom_window();
                        }
                    }
                })
                .child(
                    div()
                        .child("omnimux")
                        .text_color(colors.text)
                        .font_weight(FontWeight::SEMIBOLD)
                        .text_sm(),
                ),
        )
        .child(title_btn("new_tab_btn", ICON_PLUS).on_click(cx.listener(
            |this, _, window, cx| {
                cx.stop_propagation();
                this.open_host_prompt(window, cx);
            },
        )))
        .child(title_btn("search_btn", ICON_SEARCH).on_click(cx.listener(
            |this, _, window, cx| {
                cx.stop_propagation();
                this.find(window, cx);
            },
        )))
        .child(title_btn("settings_btn", ICON_COG).on_click(cx.listener(
            |this, _, _, cx| {
                cx.stop_propagation();
                this.show_settings = true;
                this.focus_ui = true;
                cx.notify();
            },
        )));

    if show_client_controls {
        let ctl = |id: &'static str| {
            div()
                .id(id)
                .flex()
                .flex_shrink_0()
                .items_center()
                .justify_center()
                .w(px(40.0))
                .h(px(32.0))
                .overflow_hidden()
                .ml_1()
                .rounded_sm()
                .cursor_pointer()
                .on_mouse_down(MouseButton::Left, |_, window, cx| {
                    window.prevent_default();
                    cx.stop_propagation();
                })
        };
        title_bar = title_bar
            .child(
                ctl("win_min")
                    .ml_2()
                    .hover(|s| s.bg(colors.hover))
                    .window_control_area(WindowControlArea::Min)
                    .on_click(|_, window, cx| {
                        cx.stop_propagation();
                        window.minimize_window();
                    })
                    .child(chrome_glyph(ICON_MINUS, colors.text)),
            )
            .child(
                ctl("win_max")
                    .hover(|s| s.bg(colors.hover))
                    .window_control_area(WindowControlArea::Max)
                    .on_click(|_, window, cx| {
                        cx.stop_propagation();
                        window.zoom_window();
                    })
                    .child(chrome_glyph(
                        if window.is_maximized() {
                            ICON_WINDOW_RESTORE
                        } else {
                            ICON_WINDOW_MAXIMIZE
                        },
                        colors.text,
                    )),
            )
            .child(
                ctl("win_close")
                    .hover(|s| s.bg(rgb(0xe81123)))
                    .window_control_area(WindowControlArea::Close)
                    .on_click(|_, window, cx| {
                        cx.stop_propagation();
                        window.remove_window();
                    })
                    .child(chrome_glyph(ICON_TIMES, colors.text)),
            );
    }

    title_bar
}
