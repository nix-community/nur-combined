mod action_dispatch;
mod actions_handlers;
mod chrome;
mod colors;
mod focus;
mod lifecycle;
mod overlays;
mod settings_panel;
mod tab_bar;

pub use colors::ChromeColors;

use crate::palette::{is_dark_appearance, palette_for_appearance, DEFAULT_FONT_SIZE};
use crate::session::TerminalSession;
use crate::settings::{load_session, load_settings, Osc52Setting};
use crate::ssh_config::get_ssh_hosts;
use gpui::prelude::*;
use gpui::*;
use gpui_component::input::{InputEvent, InputState};
use gpui_component::menu::PopupMenu;
use gpui_terminal::ColorPalette;

pub struct TerminalTabs {
    pub(crate) active_tab: usize,
    pub(crate) tabs: Vec<Entity<TerminalSession>>,
    pub(crate) show_host_prompt: bool,
    pub(crate) ssh_hosts: Vec<String>,
    pub(crate) selected_host_index: usize,
    pub(crate) show_settings: bool,
    pub(crate) show_search: bool,
    pub(crate) search_status: Option<bool>,
    pub(crate) host_input: Entity<InputState>,
    pub(crate) search_input: Entity<InputState>,
    pub(crate) keep_tab_after_exit: bool,
    pub(crate) auto_reconnect: bool,
    pub(crate) remember_session: bool,
    pub(crate) sync_font_size_across_tabs: bool,
    pub(crate) remember_font_size: bool,
    pub(crate) osc52: Osc52Setting,
    /// Opt-in Cmd/Ctrl+click http(s) links with confirm (default off).
    pub(crate) open_links: bool,
    /// Pending URL awaiting confirm before `cx.open_url`.
    pub(crate) pending_open_url: Option<String>,
    /// Right-click terminal context menu (Copy/Paste).
    pub(crate) context_menu: Option<(Entity<PopupMenu>, Point<Pixels>, Subscription)>,
    pub(crate) font_size: Pixels,
    pub(crate) last_appearance: Option<WindowAppearance>,
    pub(crate) focus_active_terminal: bool,
    pub(crate) focus_ui: bool,
    pub(crate) focus_handle: FocusHandle,
    pub(crate) terminal_palette: ColorPalette,
    _subscriptions: Vec<Subscription>,
}

impl Focusable for TerminalTabs {
    fn focus_handle(&self, _: &App) -> FocusHandle {
        self.focus_handle.clone()
    }
}

impl TerminalTabs {
    pub fn new(window: &mut Window, cx: &mut Context<Self>) -> Self {
        let settings = load_settings();
        let keep_tab_after_exit = settings.keep_tab_after_exit.unwrap_or(true);
        let auto_reconnect = settings.auto_reconnect.unwrap_or(false);
        let remember_session = settings.remember_session.unwrap_or(false);
        let sync_font_size_across_tabs = settings.sync_font_size_across_tabs.unwrap_or(true);
        let remember_font_size = settings.remember_font_size.unwrap_or(false);
        let osc52 = settings.osc52.unwrap_or_default();
        let open_links = settings.open_links.unwrap_or(false);
        let font_size = if remember_font_size {
            px(
                settings
                    .font_size
                    .unwrap_or(DEFAULT_FONT_SIZE)
                    .clamp(6.0, 72.0),
            )
        } else {
            px(DEFAULT_FONT_SIZE)
        };

        // Seed sessions with the current window appearance so OSC color queries
        // (e.g. OSC 11 background) are correct from the first prompt.
        let terminal_palette = palette_for_appearance(window.appearance());
        let tabs_weak = cx.entity().downgrade();
        let osc52_policy = osc52.into();

        let initial_tabs: Vec<Entity<TerminalSession>> = if remember_session {
            let saved = load_session();
            if saved.is_empty() {
                vec![]
            } else {
                saved
                    .into_iter()
                    .map(|host| {
                        let colors = terminal_palette.clone();
                        cx.new(|cx| {
                            TerminalSession::new(
                                host,
                                colors,
                                font_size,
                                osc52_policy,
                                tabs_weak.clone(),
                                cx,
                            )
                        })
                    })
                    .collect()
            }
        } else {
            vec![]
        };

        let start_prompt = initial_tabs.is_empty();
        let focus_handle = cx.focus_handle();
        let window_handle = window.window_handle();

        let host_input = cx.new(|cx| InputState::new(window, cx));
        let search_input = cx.new(|cx| InputState::new(window, cx));

        let subscriptions = vec![
            // Use App::subscribe + defer — Context::subscribe would re-lease
            // TerminalTabs while open_host_prompt is still updating it (set_value
            // emits InputEvent::Change → double-lease panic).
            App::subscribe(cx, &host_input, {
                let window_handle = window_handle;
                let tabs_weak = tabs_weak.clone();
                move |_, event, cx| match event {
                    InputEvent::PressEnter { .. } => {
                        let tabs_weak = tabs_weak.clone();
                        let window_handle = window_handle;
                        cx.defer(move |cx| {
                            let _ = window_handle.update(cx, |_, window, cx| {
                                let _ = tabs_weak.update(cx, |this, cx| {
                                    this.submit_host_prompt(window, cx);
                                });
                            });
                        });
                    }
                    InputEvent::Change => {
                        let tabs_weak = tabs_weak.clone();
                        cx.defer(move |cx| {
                            let _ = tabs_weak.update(cx, |this, cx| {
                                this.selected_host_index = 0;
                                cx.notify();
                            });
                        });
                    }
                    _ => {}
                }
            }),
            cx.subscribe_in(&search_input, window, move |this, _, event, _, cx| {
                if let InputEvent::PressEnter { secondary } = event {
                    this.run_search(!secondary, cx);
                }
            }),
            cx.observe_window_appearance(window, |this, window, cx| {
                // Prefer window.appearance() over cx.window_appearance(): the
                // latter re-borrows the Wayland client RefCell while XDP still
                // holds it (gpui-component Theme::sync_system_appearance note).
                let appearance = window.appearance();
                this.sync_appearance(appearance, window, cx);
            }),
            cx.observe_window_bounds(window, |this, window, cx| {
                crate::settings::save_window_maximized(window.is_maximized());
                this.restore_terminal_focus(window, cx);
                cx.notify();
            }),
            cx.on_focus_lost(window, |this, window, cx| {
                this.restore_terminal_focus(window, cx);
            }),
            cx.observe_window_activation(window, |this, window, cx| {
                if window.is_window_active() {
                    this.restore_terminal_focus(window, cx);
                }
            }),
            cx.on_app_quit(|this, cx| {
                this.kill_all_sessions(cx);
                async {}
            }),
        ];

        let tabs_for_close = cx.entity().downgrade();
        window.on_window_should_close(cx, move |_, cx| {
            let _ = tabs_for_close.update(cx, |tabs, cx| {
                tabs.kill_all_sessions(cx);
            });
            true
        });

        Self {
            active_tab: 0,
            tabs: initial_tabs,
            show_host_prompt: start_prompt,
            ssh_hosts: get_ssh_hosts(),
            selected_host_index: 0,
            show_settings: false,
            show_search: false,
            search_status: None,
            host_input,
            search_input,
            keep_tab_after_exit,
            auto_reconnect,
            remember_session,
            sync_font_size_across_tabs,
            remember_font_size,
            osc52,
            open_links,
            pending_open_url: None,
            context_menu: None,
            font_size,
            last_appearance: None,
            focus_active_terminal: !start_prompt,
            focus_ui: start_prompt,
            focus_handle,
            terminal_palette,
            _subscriptions: subscriptions,
        }
    }
}

impl Render for TerminalTabs {
    fn render(&mut self, window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        self.active_tab = self.active_tab.min(self.tabs.len().saturating_sub(1));
        self.apply_pending_focus(window, cx);

        let appearance = cx.window_appearance();
        let is_dark = is_dark_appearance(appearance);
        let colors = colors::chrome_colors(is_dark);
        let active_session = self.tabs.get(self.active_tab).cloned();

        let mut main_div = Self::attach_root_action_handlers(
            div()
                .flex()
                .flex_col()
                .size_full()
                .bg(colors.active)
                .key_context("omnimux"),
            cx,
        )
            .child(chrome::render_title_bar(self, colors, window, cx))
            .child(tab_bar::render_tab_bar(self, colors, cx))
            .when_some(active_session, |this, session| {
                // flex_1 + min_h(0) + overflow_hidden: avoid the terminal's
                // size_full hitbox growing under the title/tab bar (chrome
                // clicks were leaking into tmux mouse mode).
                this.child(
                    div()
                        .flex_1()
                        .min_h(px(0.0))
                        .w_full()
                        .overflow_hidden()
                        .child(session),
                )
            });

        if self.show_host_prompt {
            main_div = main_div.child(overlays::render_host_prompt(
                self, colors, window, cx,
            ));
        }
        if self.show_search {
            main_div = main_div.child(overlays::render_search_bar(self, colors, cx));
        }
        if self.show_settings {
            main_div =
                main_div.child(settings_panel::render_settings_panel(self, colors, window, cx));
        }
        if self.pending_open_url.is_some() {
            main_div = main_div.child(overlays::render_open_url_confirm(self, colors, cx));
        }
        if let Some((menu, position, _)) = &self.context_menu {
            main_div = main_div.child(
                deferred(
                    anchored()
                        .position(*position)
                        .anchor(Corner::TopLeft)
                        .snap_to_window_with_margin(Edges::all(px(8.)))
                        .child(menu.clone()),
                )
                .with_priority(1),
            );
        }

        main_div
    }
}
