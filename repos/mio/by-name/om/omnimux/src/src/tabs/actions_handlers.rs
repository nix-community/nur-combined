use super::TerminalTabs;
use crate::hosts::{filter_hosts, host_query};
use crate::palette::DEFAULT_FONT_SIZE;
use crate::settings::save_settings_from_tabs;
use gpui::prelude::*;
use gpui::*;
use gpui_component::menu::{PopupMenu, PopupMenuItem};
use gpui_terminal::Clipboard;

impl TerminalTabs {
    pub(crate) fn new_tab(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        self.open_host_prompt(window, cx);
    }

    pub(crate) fn close_tab(&mut self, cx: &mut Context<Self>) {
        if self.active_tab < self.tabs.len() {
            self.close_tab_at(self.active_tab, cx);
        }
    }

    pub(crate) fn find(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        self.show_search = true;
        self.search_status = None;
        self.search_input.update(cx, |input, cx| {
            input.set_value("", window, cx);
        });
        self.focus_ui = true;
        cx.notify();
    }

    pub(crate) fn zoom_in(&mut self, cx: &mut Context<Self>) {
        self.apply_font_zoom_delta(px(1.0), cx);
    }

    pub(crate) fn zoom_out(&mut self, cx: &mut Context<Self>) {
        self.apply_font_zoom_delta(px(-1.0), cx);
    }

    pub(crate) fn zoom_reset(&mut self, cx: &mut Context<Self>) {
        self.set_font_size(px(DEFAULT_FONT_SIZE), cx);
    }

    fn apply_font_zoom_delta(&mut self, delta: Pixels, cx: &mut Context<Self>) {
        let base = if self.sync_font_size_across_tabs {
            self.font_size
        } else if let Some(session) = self.tabs.get(self.active_tab) {
            session.read(cx).terminal_view.read(cx).config().font_size
        } else {
            self.font_size
        };
        let size = (base + delta).clamp(px(6.0), px(72.0));
        self.set_font_size(size, cx);
    }

    fn set_font_size(&mut self, size: Pixels, cx: &mut Context<Self>) {

        if self.sync_font_size_across_tabs {
            self.font_size = size;
            for tab in &self.tabs {
                tab.update(cx, |session, cx| {
                    session.terminal_view.update(cx, |tv, cx| {
                        let mut config = tv.config().clone();
                        config.font_size = size;
                        tv.update_config(config, cx);
                    });
                });
            }
        } else if let Some(session) = self.tabs.get(self.active_tab).cloned() {
            self.font_size = size;
            session.update(cx, |session, cx| {
                session.terminal_view.update(cx, |tv, cx| {
                    let mut config = tv.config().clone();
                    config.font_size = size;
                    tv.update_config(config, cx);
                });
            });
        } else {
            self.font_size = size;
        }

        if self.remember_font_size {
            save_settings_from_tabs(self);
        }
        cx.notify();
    }

    pub(crate) fn copy(&mut self, cx: &mut Context<Self>) {
        if let Some(session) = self.tabs.get(self.active_tab).cloned() {
            let _ = session.read(cx).terminal_view.read(cx).copy_selection();
        }
    }

    pub(crate) fn paste(&mut self, cx: &mut Context<Self>) {
        if let Ok(mut clipboard) = Clipboard::new() {
            if let Ok(text) = clipboard.paste() {
                if let Some(session) = self.tabs.get(self.active_tab) {
                    session.update(cx, |s, cx| {
                        s.terminal_view.update(cx, |tv, _| {
                            tv.write_input(&text);
                        });
                    });
                }
            }
        }
    }

    pub(crate) fn close_overlay(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        if self.context_menu.take().is_some() {
            self.focus_active_session(window, cx);
        } else if self.pending_open_url.take().is_some() {
            self.focus_active_session(window, cx);
        } else if self.show_settings {
            self.show_settings = false;
            self.focus_active_session(window, cx);
        } else if self.show_search {
            self.close_search(window, cx);
        } else if self.show_host_prompt && !self.tabs.is_empty() {
            self.show_host_prompt = false;
            self.focus_active_session(window, cx);
        }
        cx.notify();
    }

    pub(crate) fn request_open_url(
        &mut self,
        url: String,
        window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        if !self.open_links {
            return;
        }
        if !gpui_terminal::is_browser_url(&url) {
            return;
        }
        self.pending_open_url = Some(url);
        self.focus_ui = true;
        self.focus_handle.focus(window);
        cx.notify();
    }

    pub(crate) fn confirm_open_url(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        if let Some(url) = self.pending_open_url.take() {
            if gpui_terminal::is_browser_url(&url) {
                cx.open_url(&url);
            }
            self.focus_active_session(window, cx);
            cx.notify();
        }
    }

    pub(crate) fn show_terminal_context_menu(
        &mut self,
        position: Point<Pixels>,
        window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        // Replace any open menu (right-click again / new position).
        self.context_menu.take();

        let has_selection = self
            .tabs
            .get(self.active_tab)
            .is_some_and(|s| s.read(cx).terminal_view.read(cx).has_selection());
        let focus = self.focus_handle.clone();
        let tabs = cx.weak_entity();
        let menu = PopupMenu::build(window, cx, |menu, _, _| {
            let tabs_copy = tabs.clone();
            let tabs_paste = tabs.clone();
            menu.action_context(focus)
                .min_w(px(140.))
                .item(
                    PopupMenuItem::new("Copy")
                        .disabled(!has_selection)
                        .on_click(move |_, _, cx| {
                            let _ = tabs_copy.update(cx, |this, cx| this.copy(cx));
                        }),
                )
                .item(
                    PopupMenuItem::new("Paste").on_click(move |_, _, cx| {
                        let _ = tabs_paste.update(cx, |this, cx| this.paste(cx));
                    }),
                )
        });
        let menu_focus = menu.focus_handle(cx);
        let subscription = cx.subscribe_in(&menu, window, |this, _, _: &DismissEvent, window, cx| {
            this.context_menu.take();
            this.focus_active_session(window, cx);
            cx.notify();
        });
        // Set state before focusing so on_focus_lost → restore_terminal_focus
        // sees context_menu.is_some() and does not steal focus back.
        self.context_menu = Some((menu, position, subscription));
        window.focus(&menu_focus);
        cx.notify();
    }

    pub(crate) fn next_tab(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        if self.tabs.is_empty() {
            return;
        }
        let next = (self.active_tab + 1) % self.tabs.len();
        self.activate_tab_at(next, window, cx);
    }

    pub(crate) fn prev_tab(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        if self.tabs.is_empty() {
            return;
        }
        let prev = if self.active_tab == 0 {
            self.tabs.len() - 1
        } else {
            self.active_tab - 1
        };
        self.activate_tab_at(prev, window, cx);
    }

    pub(crate) fn host_list_up(&mut self, cx: &mut Context<Self>) {
        if self.selected_host_index > 0 {
            self.selected_host_index -= 1;
            cx.notify();
        }
    }

    pub(crate) fn host_list_down(&mut self, cx: &mut Context<Self>) {
        let input = self.host_input.read(cx).value().to_string();
        let visible = filter_hosts(host_query(&input), &self.ssh_hosts);
        if self.selected_host_index + 1 < visible.len() {
            self.selected_host_index += 1;
            cx.notify();
        }
    }

    pub(crate) fn run_search(&mut self, forward: bool, cx: &mut Context<Self>) {
        let query = self.search_input.read(cx).value().to_string();
        if let Some(session) = self.tabs.get(self.active_tab).cloned() {
            let found = session.update(cx, |s, cx| {
                s.terminal_view
                    .update(cx, |tv, cx| tv.search(&query, forward, cx))
            });
            self.search_status = Some(found);
        }
        cx.notify();
    }

    pub(crate) fn close_search(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        self.show_search = false;
        self.search_status = None;
        if let Some(session) = self.tabs.get(self.active_tab) {
            session.update(cx, |s, cx| {
                s.terminal_view
                    .update(cx, |tv, cx| tv.clear_search(cx));
            });
        }
        self.focus_active_terminal = true;
        self.focus_active_session(window, cx);
        cx.notify();
    }

    pub(crate) fn restore_defaults(&mut self, cx: &mut Context<Self>) {
        self.keep_tab_after_exit = true;
        self.auto_reconnect = false;
        self.remember_session = false;
        self.sync_font_size_across_tabs = true;
        self.remember_font_size = false;
        self.osc52 = crate::settings::Osc52Setting::Disabled;
        self.open_links = false;
        self.font_size = px(DEFAULT_FONT_SIZE);
        let size = self.font_size;
        let osc52 = self.osc52.into();
        for tab in &self.tabs {
            tab.update(cx, |session, cx| {
                session.terminal_view.update(cx, |tv, cx| {
                    let mut config = tv.config().clone();
                    config.font_size = size;
                    config.osc52 = osc52;
                    tv.update_config(config, cx);
                });
            });
        }
        save_settings_from_tabs(self);
    }

    pub(crate) fn set_osc52(
        &mut self,
        osc52: crate::settings::Osc52Setting,
        cx: &mut Context<Self>,
    ) {
        self.osc52 = osc52;
        let policy = osc52.into();
        for tab in &self.tabs {
            tab.update(cx, |session, cx| {
                session.terminal_view.update(cx, |tv, cx| {
                    let mut config = tv.config().clone();
                    config.osc52 = policy;
                    tv.update_config(config, cx);
                });
            });
        }
        save_settings_from_tabs(self);
        cx.notify();
    }
}
