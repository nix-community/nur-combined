use super::TerminalTabs;
use gpui::prelude::*;
use gpui::*;

impl TerminalTabs {
    pub(crate) fn should_restore_terminal_focus(&self) -> bool {
        !self.show_host_prompt
            && !self.show_search
            && !self.show_settings
            && self.pending_open_url.is_none()
            && self.context_menu.is_none()
            && !self.tabs.is_empty()
    }

    pub(crate) fn restore_terminal_focus(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        if self.should_restore_terminal_focus() {
            self.focus_active_session(window, cx);
        }
    }

    pub(crate) fn activate_tab_at(
        &mut self,
        index: usize,
        window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        if index >= self.tabs.len() {
            return;
        }
        self.active_tab = index;
        self.focus_active_terminal = true;
        if let Some(session) = self.tabs.get(index).cloned() {
            session.update(cx, |session, cx| session.clear_bell(cx));
        }
        self.focus_active_session(window, cx);
        cx.notify();
    }

    pub(crate) fn focus_active_session(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        self.focus_active_terminal = false;
        let Some(session) = self.tabs.get(self.active_tab).cloned() else {
            return;
        };
        session.update(cx, |session, cx| session.clear_bell(cx));
        let tv = session.read(cx).terminal_view.clone();
        tv.read(cx).focus_handle().clone().focus(window);
        cx.on_next_frame(window, |this, window, cx| {
            if this.show_host_prompt
                || this.show_search
                || this.show_settings
                || this.pending_open_url.is_some()
                || this.context_menu.is_some()
            {
                return;
            }
            let Some(session) = this.tabs.get(this.active_tab) else {
                return;
            };
            session
                .read(cx)
                .terminal_view
                .read(cx)
                .focus_handle()
                .clone()
                .focus(window);
        });
    }

    pub(crate) fn focus_host_input(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        self.host_input
            .read(cx)
            .focus_handle(cx)
            .focus(window);
    }

    pub(crate) fn focus_search_input(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        self.search_input
            .read(cx)
            .focus_handle(cx)
            .focus(window);
    }

    pub(crate) fn apply_pending_focus(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        if self.focus_ui {
            self.focus_ui = false;
            if self.show_host_prompt {
                self.focus_host_input(window, cx);
            } else if self.show_search {
                self.focus_search_input(window, cx);
            } else if self.show_settings {
                self.focus_handle.focus(window);
            } else if self.pending_open_url.is_some() {
                self.focus_handle.focus(window);
            }
            return;
        }
        if self.focus_active_terminal
            && !self.show_host_prompt
            && !self.show_settings
            && !self.show_search
            && self.pending_open_url.is_none()
            && self.context_menu.is_none()
        {
            self.focus_active_session(window, cx);
        }
    }
}
