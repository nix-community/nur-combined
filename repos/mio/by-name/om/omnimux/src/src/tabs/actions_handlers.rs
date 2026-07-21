use super::TerminalTabs;
use crate::hosts::{filter_hosts, host_query};
use crate::palette::DEFAULT_FONT_SIZE;
use crate::settings::save_settings_from_tabs;
use gpui::prelude::*;
use gpui::*;
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

    pub(crate) fn apply_font_zoom(&mut self, key: &str, cx: &mut Context<Self>) {
        let base = if self.sync_font_size_across_tabs {
            self.font_size
        } else if let Some(session) = self.tabs.get(self.active_tab) {
            session.read(cx).terminal_view.read(cx).config().font_size
        } else {
            self.font_size
        };

        let mut size = base;
        if key == "=" || key == "+" {
            size += px(1.0);
        } else if key == "-" {
            size -= px(1.0);
        } else if key == "0" {
            size = px(DEFAULT_FONT_SIZE);
        }
        size = size.clamp(px(6.0), px(72.0));

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
        if let Some(session) = self.tabs.get(self.active_tab) {
            session.update(cx, |s, cx| {
                let _ = s.terminal_view.read(cx).copy_selection();
            });
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
        if self.show_settings {
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

    pub(crate) fn next_tab(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        if self.tabs.is_empty() {
            return;
        }
        self.active_tab = (self.active_tab + 1) % self.tabs.len();
        self.focus_active_terminal = true;
        self.focus_active_session(window, cx);
        cx.notify();
    }

    pub(crate) fn prev_tab(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        if self.tabs.is_empty() {
            return;
        }
        self.active_tab = if self.active_tab == 0 {
            self.tabs.len() - 1
        } else {
            self.active_tab - 1
        };
        self.focus_active_terminal = true;
        self.focus_active_session(window, cx);
        cx.notify();
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
        self.font_size = px(DEFAULT_FONT_SIZE);
        let size = self.font_size;
        for tab in &self.tabs {
            tab.update(cx, |session, cx| {
                session.terminal_view.update(cx, |tv, cx| {
                    let mut config = tv.config().clone();
                    config.font_size = size;
                    tv.update_config(config, cx);
                });
            });
        }
        save_settings_from_tabs(self);
    }
}
