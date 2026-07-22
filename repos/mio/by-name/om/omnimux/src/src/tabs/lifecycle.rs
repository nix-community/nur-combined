use super::TerminalTabs;
use crate::hosts::{host_option, resolve_host};
use crate::session::TerminalSession;
use crate::settings::save_session;
use crate::ssh_config::get_ssh_hosts;
use gpui::prelude::*;
use gpui::*;
use std::time::{Duration, Instant};

impl TerminalTabs {
    pub fn on_session_exited(
        &mut self,
        session: WeakEntity<TerminalSession>,
        cx: &mut Context<Self>,
    ) {
        let Some(index) = self.tab_index_for(&session) else {
            return;
        };

        let session_ref = self.tabs[index].read(cx);
        if !session_ref.has_exited {
            return;
        }
        let success = session_ref.exit_status == Some(0);

        if !success && self.auto_reconnect {
            self.schedule_reconnect(index, cx);
        } else if !self.keep_tab_after_exit
            && Self::should_close_exited_tab(Some(session_ref), self.auto_reconnect)
        {
            self.close_tab_at(index, cx);
        }

        cx.notify();
    }

    fn tab_index_for(&self, session: &WeakEntity<TerminalSession>) -> Option<usize> {
        let id = session.entity_id();
        self.tabs.iter().position(|t| t.entity_id() == id)
    }

    pub(crate) fn should_close_exited_tab(
        session: Option<&TerminalSession>,
        auto_reconnect: bool,
    ) -> bool {
        let Some(session) = session else {
            return false;
        };
        Self::session_exit_should_close(session.has_exited, session.exit_status, auto_reconnect)
    }

    pub(crate) fn session_exit_should_close(
        has_exited: bool,
        exit_status: Option<u32>,
        auto_reconnect: bool,
    ) -> bool {
        if !has_exited {
            return false;
        }
        let success = exit_status == Some(0);
        !(auto_reconnect && !success)
    }

    pub(crate) fn kill_all_sessions(&mut self, cx: &mut Context<Self>) {
        for tab in &self.tabs {
            tab.update(cx, |session, _| session.close());
        }
    }

    fn schedule_reconnect(&mut self, index: usize, cx: &mut Context<Self>) {
        let Some(session) = self.tabs.get(index).cloned() else {
            return;
        };
        let session_weak = session.downgrade();
        let (ready, host, streak, wait) = session.update(cx, |session, _| {
            if session.pending_reconnect_at.is_none() {
                let shift = session.reconnect_streak.min(6);
                let delay_ms = 250u64.saturating_mul(1u64 << shift);
                session.pending_reconnect_at =
                    Some(Instant::now() + Duration::from_millis(delay_ms));
                session.reconnect_streak = session.reconnect_streak.saturating_add(1);
            }
            let deadline = session.pending_reconnect_at.unwrap();
            let ready = Instant::now() >= deadline;
            let wait = if ready {
                Duration::ZERO
            } else {
                deadline.saturating_duration_since(Instant::now())
            };
            (
                ready,
                session.host.clone(),
                session.reconnect_streak,
                wait,
            )
        });

        // Resolve index by entity id — tabs may have closed/moved during the wait.
        let Some(index) = self.tab_index_for(&session_weak) else {
            return;
        };

        if ready {
            self.reconnect_tab_at(index, host, streak, cx);
            return;
        }

        let tabs = cx.entity().downgrade();
        cx.spawn(async move |_, cx| {
            gpui::Timer::after(wait).await;
            let _ = tabs.update(cx, |tabs, cx| {
                if let Some(index) = tabs.tab_index_for(&session_weak) {
                    tabs.schedule_reconnect(index, cx);
                }
            });
        })
        .detach();
    }

    fn reconnect_tab_at(
        &mut self,
        index: usize,
        host: Option<String>,
        streak: u32,
        cx: &mut Context<Self>,
    ) {
        if let Some(session) = self.tabs.get(index) {
            session.update(cx, |session, _| session.close());
        }
        let colors = self.terminal_palette.clone();
        let font_size = self.font_size;
        let osc52 = self.osc52.into();
        let tabs_weak = cx.entity().downgrade();
        self.tabs[index] = cx.new(|cx| {
            let mut session = TerminalSession::new(host, colors, font_size, osc52, tabs_weak, cx);
            session.reconnect_streak = streak;
            session
        });
        self.persist_sessions_if_enabled(cx);
        cx.notify();
    }

    pub(crate) fn close_tab_at(&mut self, index: usize, cx: &mut Context<Self>) {
        if index >= self.tabs.len() {
            return;
        }
        self.tabs[index].update(cx, |session, _| session.close());
        self.tabs.remove(index);
        if self.tabs.is_empty() {
            self.active_tab = 0;
            self.show_host_prompt = true;
            self.selected_host_index = 0;
            self.ssh_hosts = get_ssh_hosts();
            self.focus_ui = true;
        } else {
            self.active_tab = self.active_tab.min(self.tabs.len().saturating_sub(1));
            self.focus_active_terminal = true;
        }
        self.persist_sessions_if_enabled(cx);
        cx.notify();
    }

    pub(crate) fn open_host_prompt(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        self.show_host_prompt = true;
        self.selected_host_index = 0;
        self.ssh_hosts = get_ssh_hosts();
        self.host_input.update(cx, |input, cx| {
            input.set_value("", window, cx);
        });
        self.focus_ui = true;
        cx.notify();
    }

    pub(crate) fn open_tab_for_host(
        &mut self,
        host_opt: Option<String>,
        window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        let colors = self.terminal_palette.clone();
        let font_size = self.font_size;
        let osc52 = self.osc52.into();
        let tabs_weak = cx.entity().downgrade();
        let new_tab = cx.new(|cx| {
            TerminalSession::new(host_opt, colors, font_size, osc52, tabs_weak, cx)
        });
        self.tabs.push(new_tab);
        self.active_tab = self.tabs.len() - 1;
        self.show_host_prompt = false;
        self.focus_active_session(window, cx);
        self.persist_sessions_if_enabled(cx);
        cx.notify();
    }

    pub(crate) fn submit_host_prompt(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        let input = self.host_input.read(cx).value().to_string();
        let visible = crate::hosts::filter_hosts(crate::hosts::host_query(&input), &self.ssh_hosts);
        let selected = visible
            .get(self.selected_host_index.min(visible.len().saturating_sub(1)))
            .map(|s| s.as_str());
        let final_host = resolve_host(&input, selected);
        let host_opt = host_option(&final_host);
        self.open_tab_for_host(host_opt, window, cx);
    }

    pub(crate) fn persist_sessions_if_enabled(&self, cx: &App) {
        if self.remember_session {
            let hosts: Vec<Option<String>> =
                self.tabs.iter().map(|t| t.read(cx).host.clone()).collect();
            save_session(&hosts);
        }
    }

    pub(crate) fn remove_exited_tabs(&mut self, cx: &mut Context<Self>) {
        if self.keep_tab_after_exit {
            return;
        }
        let auto_reconnect = self.auto_reconnect;
        let mut to_close = Vec::new();
        for (i, tab) in self.tabs.iter().enumerate() {
            if Self::should_close_exited_tab(Some(tab.read(cx)), auto_reconnect) {
                to_close.push(i);
            }
        }
        for i in to_close.into_iter().rev() {
            self.close_tab_at(i, cx);
        }
    }

    pub(crate) fn sync_appearance(
        &mut self,
        appearance: WindowAppearance,
        window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        if self.last_appearance == Some(appearance) {
            return;
        }
        self.last_appearance = Some(appearance);
        gpui_component::theme::Theme::change(appearance, Some(window), cx);
        self.terminal_palette = crate::palette::palette_for_appearance(appearance);
        let palette_clone = self.terminal_palette.clone();
        for tab in &self.tabs {
            tab.update(cx, |session, cx| {
                session.terminal_view.update(cx, |tv, cx| {
                    let mut config = tv.config().clone();
                    config.colors = palette_clone.clone();
                    tv.update_config(config, cx);
                });
            });
        }
        cx.notify();
    }
}

#[cfg(test)]
mod tests {
    use super::TerminalTabs;

    #[test]
    fn should_close_exited_tab_when_not_keeping() {
        assert!(TerminalTabs::session_exit_should_close(true, Some(1), false));
    }

    #[test]
    fn should_close_successful_exit_with_auto_reconnect() {
        assert!(TerminalTabs::session_exit_should_close(true, Some(0), true));
    }

    #[test]
    fn should_not_close_failed_exit_with_auto_reconnect() {
        assert!(!TerminalTabs::session_exit_should_close(true, Some(1), true));
    }

    #[test]
    fn should_not_close_running_session() {
        assert!(!TerminalTabs::session_exit_should_close(false, None, false));
    }
}
