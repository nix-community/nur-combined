use super::TerminalTabs;
use crate::actions::{
    CloseOverlay, CloseTab, Copy, FindInTerminal, HostListDown, HostListUp, NewTab, NextTab,
    PassthroughShiftTab, PassthroughTab, Paste, PrevTab, SearchNext, SearchPrev, ZoomIn, ZoomOut,
    ZoomReset,
};
use gpui::prelude::*;
use gpui::*;

impl TerminalTabs {
    /// Attach omnimux action handlers to the root element (method listeners, not render closures).
    pub(crate) fn attach_root_action_handlers(
        div: Div,
        cx: &mut Context<Self>,
    ) -> Div {
        div.on_action(cx.listener(Self::on_new_tab))
            .on_action(cx.listener(Self::on_close_tab))
            .on_action(cx.listener(Self::on_find_in_terminal))
            .on_action(cx.listener(Self::on_zoom_in))
            .on_action(cx.listener(Self::on_zoom_out))
            .on_action(cx.listener(Self::on_zoom_reset))
            .on_action(cx.listener(Self::on_copy))
            .on_action(cx.listener(Self::on_paste))
            .on_action(cx.listener(Self::on_close_overlay))
            .on_action(cx.listener(Self::on_next_tab))
            .on_action(cx.listener(Self::on_prev_tab))
            .on_action(cx.listener(Self::on_tab))
            .on_action(cx.listener(Self::on_shift_tab))
            .on_action(cx.listener(Self::on_host_list_up))
            .on_action(cx.listener(Self::on_host_list_down))
            .on_action(cx.listener(Self::on_search_next))
            .on_action(cx.listener(Self::on_search_prev))
    }

    fn on_new_tab(this: &mut Self, _: &NewTab, window: &mut Window, cx: &mut Context<Self>) {
        this.new_tab(window, cx);
    }

    fn on_close_tab(this: &mut Self, _: &CloseTab, _: &mut Window, cx: &mut Context<Self>) {
        this.close_tab(cx);
    }

    fn on_find_in_terminal(
        this: &mut Self,
        _: &FindInTerminal,
        window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        this.find(window, cx);
    }

    fn on_zoom_in(this: &mut Self, _: &ZoomIn, _: &mut Window, cx: &mut Context<Self>) {
        this.zoom_in(cx);
    }

    fn on_zoom_out(this: &mut Self, _: &ZoomOut, _: &mut Window, cx: &mut Context<Self>) {
        this.zoom_out(cx);
    }

    fn on_zoom_reset(this: &mut Self, _: &ZoomReset, _: &mut Window, cx: &mut Context<Self>) {
        this.zoom_reset(cx);
    }

    fn on_copy(this: &mut Self, _: &Copy, _: &mut Window, cx: &mut Context<Self>) {
        this.copy(cx);
    }

    fn on_paste(this: &mut Self, _: &Paste, _: &mut Window, cx: &mut Context<Self>) {
        this.paste(cx);
    }

    pub(crate) fn on_close_overlay(
        this: &mut Self,
        _: &CloseOverlay,
        window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        this.close_overlay(window, cx);
    }

    fn on_next_tab(this: &mut Self, _: &NextTab, window: &mut Window, cx: &mut Context<Self>) {
        this.next_tab(window, cx);
    }

    fn on_prev_tab(this: &mut Self, _: &PrevTab, window: &mut Window, cx: &mut Context<Self>) {
        this.prev_tab(window, cx);
    }

    /// Forward Tab to the active terminal (overrides gpui-component focus-cycle).
    fn on_tab(
        this: &mut Self,
        _: &PassthroughTab,
        _window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        if let Some(session) = this.tabs.get(this.active_tab) {
            session.read(cx).terminal_view.read(cx).write_raw_str("\t");
        }
    }

    /// Forward Shift+Tab to the active terminal (overrides gpui-component focus-cycle).
    fn on_shift_tab(
        this: &mut Self,
        _: &PassthroughShiftTab,
        _window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        if let Some(session) = this.tabs.get(this.active_tab) {
            session.read(cx).terminal_view.read(cx).write_raw_str("\x1b[Z");
        }
    }

    pub(crate) fn on_host_list_up(this: &mut Self, _: &HostListUp, _: &mut Window, cx: &mut Context<Self>) {
        this.host_list_up(cx);
    }

    pub(crate) fn on_host_list_down(
        this: &mut Self,
        _: &HostListDown,
        _: &mut Window,
        cx: &mut Context<Self>,
    ) {
        this.host_list_down(cx);
    }

    pub(crate) fn on_search_next(this: &mut Self, _: &SearchNext, _: &mut Window, cx: &mut Context<Self>) {
        this.run_search(true, cx);
    }

    pub(crate) fn on_search_prev(this: &mut Self, _: &SearchPrev, _: &mut Window, cx: &mut Context<Self>) {
        this.run_search(false, cx);
    }
}
