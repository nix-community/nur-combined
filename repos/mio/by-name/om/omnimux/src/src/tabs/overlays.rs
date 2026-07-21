use super::{ChromeColors, TerminalTabs};
use crate::hosts::{filter_hosts, host_option, host_prefix, host_query};
use gpui::prelude::*;
use gpui::*;
use gpui_component::input::Input;

pub fn render_host_prompt(
    this: &TerminalTabs,
    colors: ChromeColors,
    _window: &mut Window,
    cx: &mut Context<TerminalTabs>,
) -> impl IntoElement {
    let input = this.host_input.read(cx).value().to_string();
    let visible = filter_hosts(host_query(&input), &this.ssh_hosts);
    let prefix = host_prefix(&input);

    let mut list_div = div()
        .id("host_list")
        .flex_col()
        .mt_2()
        .max_h(px(300.0))
        .overflow_y_scroll();

    for (idx, host) in visible.iter().enumerate() {
        let is_selected =
            idx == this
                .selected_host_index
                .min(visible.len().saturating_sub(1));
        let host_clone = host.clone();
        let host_for_click = host.clone();
        let prefix = prefix.clone();
        list_div = list_div.child(
            div()
                .id(("host_item", idx))
                .p_2()
                .rounded_sm()
                .cursor_pointer()
                .bg(if is_selected {
                    colors.btn
                } else {
                    rgba(0x00000000)
                })
                .hover(|style| style.bg(if is_selected { colors.btn } else { colors.hover }))
                .on_click(cx.listener(move |this, _, window, cx| {
                    let final_host = if host_for_click == "localhost" {
                        "localhost".to_string()
                    } else {
                        format!("{prefix}{host_for_click}")
                    };
                    let host_opt = host_option(&final_host);
                    this.open_tab_for_host(host_opt, window, cx);
                }))
                .child(div().child(host_clone).text_color(colors.text)),
        );
    }

    div()
        .absolute()
        .inset_0()
        .bg(rgba(0x00000080))
        .flex()
        .justify_center()
        .items_center()
        .key_context("omnimux_prompt")
        .track_focus(&this.focus_handle)
        .on_action(cx.listener(|this, _: &crate::actions::HostListUp, _, cx| {
            this.host_list_up(cx);
        }))
        .on_action(cx.listener(|this, _: &crate::actions::HostListDown, _, cx| {
            this.host_list_down(cx);
        }))
        .on_action(cx.listener(|this, _: &crate::actions::CloseOverlay, window, cx| {
            this.close_overlay(window, cx);
        }))
        .when(!this.tabs.is_empty(), |overlay| {
            overlay.on_mouse_down(MouseButton::Left, cx.listener(|this, _, window, cx| {
                this.show_host_prompt = false;
                this.focus_active_session(window, cx);
                cx.notify();
            }))
        })
        .child(
            div()
                .w_96()
                .bg(colors.panel)
                .rounded_lg()
                .p_4()
                .flex_col()
                .on_mouse_down(MouseButton::Left, |_, _, cx| cx.stop_propagation())
                .child(
                    div()
                        .flex()
                        .flex_row()
                        .items_center()
                        .justify_between()
                        .mb_2()
                        .child(
                            div()
                                .child("New Session: Enter host (leave blank for localhost)")
                                .text_color(colors.text),
                        )
                        .when(!this.tabs.is_empty(), |row| {
                            row.child(
                                div()
                                    .id("new_session_close")
                                    .flex()
                                    .items_center()
                                    .justify_center()
                                    .min_w(px(40.0))
                                    .min_h(px(32.0))
                                    .w(px(40.0))
                                    .h(px(32.0))
                                    .rounded_sm()
                                    .cursor_pointer()
                                    .hover(|s| s.bg(colors.hover))
                                    .on_click(cx.listener(|this, _, window, cx| {
                                        this.show_host_prompt = false;
                                        this.focus_active_session(window, cx);
                                        cx.notify();
                                    }))
                                    .child(div().child("✕").text_color(colors.text)),
                            )
                        }),
                )
                .child(
                    div()
                        .mb_2()
                        .child(Input::new(&this.host_input).w_full()),
                )
                .child(list_div),
        )
}

pub fn render_search_bar(
    this: &TerminalTabs,
    colors: ChromeColors,
    cx: &mut Context<TerminalTabs>,
) -> impl IntoElement {
    let status_text = match this.search_status {
        Some(true) => "Match found",
        Some(false) => "No matches",
        None => "Enter to find · Shift+Enter previous · Esc close",
    };

    div()
        .absolute()
        .top_8()
        .right_4()
        .w(px(420.0))
        .bg(colors.panel)
        .rounded_lg()
        .p_3()
        .shadow_md()
        .flex_col()
        .key_context("omnimux_search")
        .track_focus(&this.focus_handle)
        .on_action(cx.listener(|this, _: &crate::actions::SearchNext, _, cx| {
            this.run_search(true, cx);
        }))
        .on_action(cx.listener(|this, _: &crate::actions::SearchPrev, _, cx| {
            this.run_search(false, cx);
        }))
        .on_action(cx.listener(|this, _: &crate::actions::CloseOverlay, window, cx| {
            this.close_overlay(window, cx);
        }))
        .child(
            div()
                .flex()
                .flex_row()
                .items_center()
                .gap_2()
                .child(div().flex_grow().child(Input::new(&this.search_input).w_full()))
                .child(
                    div()
                        .id("search_prev")
                        .px_2()
                        .py_1()
                        .rounded_sm()
                        .cursor_pointer()
                        .bg(colors.btn)
                        .on_click(cx.listener(|this, _, _, cx| {
                            this.run_search(false, cx);
                        }))
                        .child(div().child("↑").text_color(colors.text)),
                )
                .child(
                    div()
                        .id("search_next")
                        .px_2()
                        .py_1()
                        .rounded_sm()
                        .cursor_pointer()
                        .bg(colors.btn)
                        .on_click(cx.listener(|this, _, _, cx| {
                            this.run_search(true, cx);
                        }))
                        .child(div().child("↓").text_color(colors.text)),
                )
                .child(
                    div()
                        .id("search_close")
                        .px_2()
                        .py_1()
                        .rounded_sm()
                        .cursor_pointer()
                        .bg(colors.btn)
                        .on_click(cx.listener(|this, _, window, cx| {
                            this.close_search(window, cx);
                        }))
                        .child(div().child("✕").text_color(colors.text)),
                ),
        )
        .child(
            div()
                .mt_2()
                .text_xs()
                .text_color(colors.muted)
                .child(status_text),
        )
}
