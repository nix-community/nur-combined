use super::TerminalTabs;
use super::ChromeColors;
use gpui::prelude::*;
use gpui::*;

pub fn render_title_bar(
    _this: &TerminalTabs,
    colors: ChromeColors,
    window: &mut Window,
    cx: &mut Context<TerminalTabs>,
) -> impl IntoElement {
    // Use text-presentation symbols for broad cross-platform support:
    // avoid KDE color-emoji sizing while not relying on Nerd Font PUA coverage.
    let title_btn = |id: &'static str, label: SharedString| {
        let label_el = div()
            .child(label)
            .text_color(colors.text)
            // Slightly larger glyphs without changing the 32px button box height.
            .text_lg()
            .font_weight(FontWeight::MEDIUM);
        div()
            .id(id)
            .flex()
            .items_center()
            .justify_center()
            .h(px(32.0))
            .min_w(px(44.0))
            .px_3()
            .ml_1()
            .rounded_sm()
            .cursor_pointer()
            .hover(|style| style.bg(colors.hover))
            .child(label_el)
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
        .child(title_btn("new_tab_btn", "+".into()).on_click(cx.listener(
            |this, _, window, cx| {
                this.open_host_prompt(window, cx);
            },
        )))
        .child(title_btn("search_btn", "⌕".into()).on_click(cx.listener(
            |this, _, window, cx| {
                this.find(window, cx);
            },
        )))
        .child(title_btn("settings_btn", "⚙\u{FE0E}".into()).on_click(cx.listener(
            |this, _, _, cx| {
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
                .items_center()
                .justify_center()
                .min_w(px(40.0))
                .min_h(px(32.0))
                .w(px(40.0))
                .h(px(32.0))
                .ml_1()
                .rounded_sm()
                .cursor_pointer()
        };
        title_bar = title_bar
            .child(
                ctl("win_min")
                    .ml_2()
                    .hover(|s| s.bg(colors.hover))
                    .window_control_area(WindowControlArea::Min)
                    .on_click(|_, window, _| window.minimize_window())
                    .child(div().child("–").text_color(colors.text)),
            )
            .child(
                ctl("win_max")
                    .hover(|s| s.bg(colors.hover))
                    .window_control_area(WindowControlArea::Max)
                    .on_click(|_, window, _| window.zoom_window())
                    // □ = maximize; ❐ = restore (already maximized).
                    .child(
                        div()
                            .child(if window.is_maximized() { "❐" } else { "□" })
                            .text_color(colors.text),
                    ),
            )
            .child(
                ctl("win_close")
                    .hover(|s| s.bg(rgb(0xe81123)))
                    .window_control_area(WindowControlArea::Close)
                    .on_click(|_, window, _| window.remove_window())
                    .child(div().child("✕").text_color(colors.text)),
            );
    }

    title_bar
}
