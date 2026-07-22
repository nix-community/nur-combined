use super::TerminalTabs;
use super::ChromeColors;
use crate::settings::{save_session, save_settings_from_tabs};
use gpui::prelude::*;
use gpui::*;
use gpui_component::switch::Switch;

pub fn render_settings_panel(
    this: &TerminalTabs,
    colors: ChromeColors,
    _window: &mut Window,
    cx: &mut Context<TerminalTabs>,
) -> impl IntoElement {
    let entity = cx.entity().clone();

    div()
        .id("settings_overlay")
        .absolute()
        .inset_0()
        .bg(rgba(0x00000080))
        .flex()
        .justify_center()
        .items_center()
        .track_focus(&this.focus_handle)
        .on_mouse_down(MouseButton::Left, cx.listener(|this, _, window, cx| {
            this.show_settings = false;
            this.focus_active_session(window, cx);
            cx.notify();
        }))
        .child(
            div()
                .id("settings_panel")
                .w_96()
                .bg(colors.panel)
                .text_color(colors.text)
                .rounded_lg()
                .p_4()
                .flex_col()
                .on_mouse_down(MouseButton::Left, |_, _, cx| cx.stop_propagation())
                .child(div().child("Settings").text_color(colors.text).text_xl().mb_4())
                .child({
                    let entity = entity.clone();
                    Switch::new("keep_tab_toggle")
                        .checked(this.keep_tab_after_exit)
                        .label("Keep tab after exit")
                        .mb_3()
                        .text_color(colors.text)
                        .on_click(move |checked, _, app| {
                            entity.update(app, |this, cx| {
                                this.keep_tab_after_exit = *checked;
                                if !*checked {
                                    this.remove_exited_tabs(cx);
                                }
                                save_settings_from_tabs(this);
                                cx.notify();
                            });
                        })
                })
                .child({
                    let entity = entity.clone();
                    Switch::new("auto_reconnect_toggle")
                        .checked(this.auto_reconnect)
                        .label("Auto-reconnect on drop")
                        .mb_3()
                        .text_color(colors.text)
                        .on_click(move |checked, _, app| {
                            entity.update(app, |this, cx| {
                                this.auto_reconnect = *checked;
                                save_settings_from_tabs(this);
                                cx.notify();
                            });
                        })
                })
                .child({
                    let entity = entity.clone();
                    Switch::new("remember_session_toggle")
                        .checked(this.remember_session)
                        .label("Remember & restore tabs on relaunch")
                        .mb_3()
                        .text_color(colors.text)
                        .on_click(move |checked, _, app| {
                            entity.update(app, |this, cx| {
                                this.remember_session = *checked;
                                save_settings_from_tabs(this);
                                if this.remember_session {
                                    let hosts: Vec<Option<String>> = this
                                        .tabs
                                        .iter()
                                        .map(|t| t.read(cx).host.clone())
                                        .collect();
                                    save_session(&hosts);
                                }
                                cx.notify();
                            });
                        })
                })
                .child({
                    let entity = entity.clone();
                    Switch::new("sync_font_size_toggle")
                        .checked(this.sync_font_size_across_tabs)
                        .label("Sync font size across tabs (Ctrl/Cmd +/-)")
                        .mb_3()
                        .text_color(colors.text)
                        .on_click(move |checked, _, app| {
                            entity.update(app, |this, cx| {
                                this.sync_font_size_across_tabs = *checked;
                                if *checked {
                                    let size = this.font_size;
                                    for tab in &this.tabs {
                                        tab.update(cx, |session, cx| {
                                            session.terminal_view.update(cx, |tv, cx| {
                                                let mut config = tv.config().clone();
                                                config.font_size = size;
                                                tv.update_config(config, cx);
                                            });
                                        });
                                    }
                                }
                                save_settings_from_tabs(this);
                                cx.notify();
                            });
                        })
                })
                .child({
                    let entity = entity.clone();
                    Switch::new("remember_font_size_toggle")
                        .checked(this.remember_font_size)
                        .label("Remember last font size on relaunch")
                        .mb_3()
                        .text_color(colors.text)
                        .on_click(move |checked, _, app| {
                            entity.update(app, |this, cx| {
                                this.remember_font_size = *checked;
                                save_settings_from_tabs(this);
                                cx.notify();
                            });
                        })
                })
                .child({
                    let entity = entity.clone();
                    Switch::new("open_links_toggle")
                        .checked(this.open_links)
                        .label("Open http(s) links (Cmd/Ctrl+click, confirm)")
                        .mb_1()
                        .text_color(colors.text)
                        .on_click(move |checked, _, app| {
                            entity.update(app, |this, cx| {
                                this.open_links = *checked;
                                save_settings_from_tabs(this);
                                cx.notify();
                            });
                        })
                })
                .child(
                    div()
                        .mb_3()
                        .text_xs()
                        .text_color(colors.muted)
                        .child(
                            "Off by default. A hostile remote can plant misleading URLs; confirmation is required before opening.",
                        ),
                )
                .child(
                    div()
                        .mb_1()
                        .child("Remote clipboard (OSC 52)")
                        .text_color(colors.text)
                        .font_weight(FontWeight::SEMIBOLD),
                )
                .child(
                    div()
                        .mb_2()
                        .text_xs()
                        .text_color(colors.muted)
                        .child(
                            "A hostile remote can abuse OSC 52 to overwrite or read your clipboard. Keep disabled unless you need remote nvim/tmux clipboard sync.",
                        ),
                )
                .child({
                    let mut radios = div().flex_col().mb_4().gap_1();
                    for (idx, option) in crate::settings::Osc52Setting::all().into_iter().enumerate()
                    {
                        let entity = entity.clone();
                        let selected = this.osc52 == option;
                        radios = radios.child(
                            gpui_component::radio::Radio::new(("osc52", idx))
                                .checked(selected)
                                .label(option.label())
                                .text_color(colors.text)
                                .on_click(move |checked, _, app| {
                                    // Radio toggles; only apply when selecting this option.
                                    if *checked {
                                        entity.update(app, |this, cx| {
                                            this.set_osc52(option, cx);
                                        });
                                    }
                                }),
                        );
                    }
                    radios
                })
                .child(
                    div()
                        .id("restore_defaults")
                        .p_2()
                        .mb_2()
                        .bg(colors.btn)
                        .rounded_sm()
                        .cursor_pointer()
                        .flex()
                        .justify_center()
                        .on_click(cx.listener(|this, _, _, cx| {
                            this.restore_defaults(cx);
                            cx.notify();
                        }))
                        .child(div().child("Restore defaults").text_color(colors.text)),
                )
                .child(
                    div()
                        .id("close_settings")
                        .p_2()
                        .bg(colors.btn)
                        .rounded_sm()
                        .cursor_pointer()
                        .flex()
                        .justify_center()
                        .on_click(cx.listener(|this, _, window, cx| {
                            this.show_settings = false;
                            this.focus_active_session(window, cx);
                            cx.notify();
                        }))
                        .child(div().child("Close").text_color(colors.text)),
                ),
        )
}
