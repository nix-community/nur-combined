use super::TerminalTabs;
use super::ChromeColors;
use crate::settings::save_session;
use gpui::prelude::*;
use gpui::*;

#[derive(Clone)]
struct TabDrag {
    index: usize,
    label: SharedString,
}

impl Render for TabDrag {
    fn render(&mut self, _: &mut Window, _: &mut Context<Self>) -> impl IntoElement {
        div()
            .px_3()
            .py_1()
            .rounded_sm()
            .bg(rgb(0x3b82f6))
            .text_color(rgb(0xffffff))
            .text_sm()
            .child(self.label.clone())
    }
}

pub fn render_tab_bar(
    this: &TerminalTabs,
    colors: ChromeColors,
    cx: &mut Context<TerminalTabs>,
) -> impl IntoElement {
    let mut tab_bar = div()
        .id("tab_bar")
        .flex()
        .flex_row()
        .w_full()
        .bg(colors.bar)
        .h(px(32.0))
        .items_center();

    for (i, session) in this.tabs.iter().enumerate() {
        let bg_color = if i == this.active_tab {
            colors.active
        } else {
            colors.bar
        };
        let tab_label = session
            .read(cx)
            .host
            .clone()
            .unwrap_or_else(|| "localhost".to_string());
        let drag = TabDrag {
            index: i,
            label: tab_label.clone().into(),
        };

        let tab = div()
            .id(("tab", i))
            .flex()
            .flex_row()
            .items_center()
            .px_4()
            .h_full()
            .bg(bg_color)
            .border_r_1()
            .border_color(colors.border)
            .cursor_pointer()
            .on_click(cx.listener(move |this, _, window, cx| {
                if i < this.tabs.len() {
                    this.active_tab = i;
                    this.focus_active_terminal = true;
                    let tv = this.tabs[i].read(cx).terminal_view.clone();
                    tv.read(cx).focus_handle().clone().focus(window);
                }
            }))
            .on_drag(drag, |drag, _, _, cx| cx.new(|_| drag.clone()))
            .on_drop(cx.listener(move |this, drag: &TabDrag, _, cx| {
                let from = drag.index;
                let to = i;
                if from == to || from >= this.tabs.len() || to >= this.tabs.len() {
                    return;
                }
                let tab = this.tabs.remove(from);
                let insert_at = if from < to { to - 1 } else { to };
                this.tabs.insert(insert_at, tab);
                this.active_tab = insert_at;
                this.focus_active_terminal = true;
                if this.remember_session {
                    let hosts: Vec<Option<String>> =
                        this.tabs.iter().map(|t| t.read(cx).host.clone()).collect();
                    save_session(&hosts);
                }
                cx.notify();
            }))
            .child(div().child(tab_label).text_color(colors.text).text_sm())
            .child(
                div()
                    .id(("close_tab", i))
                    .ml_2()
                    .p_1()
                    .hover(|style| style.bg(colors.hover).rounded_sm())
                    .child(
                        div()
                            .child("✕")
                            .text_color(colors.muted)
                            .text_xs(),
                    )
                    .on_click(cx.listener(move |this, _, _, cx| {
                        this.close_tab_at(i, cx);
                    })),
            );

        tab_bar = tab_bar.child(tab);
    }

    tab_bar
}
