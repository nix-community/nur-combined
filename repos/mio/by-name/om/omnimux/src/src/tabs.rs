use crate::palette::{is_dark_appearance, palette_for_appearance, DEFAULT_FONT_SIZE};
use crate::session::TerminalSession;
use crate::settings::{config_dir, load_session, load_settings, save_session};
use crate::ssh_config::get_ssh_hosts;
use gpui::prelude::*;
use gpui::*;
use gpui_component::switch::Switch;
use gpui_component::theme::Theme;
use gpui_terminal::{Clipboard, ColorPalette};
use std::time::{Duration, Instant};

fn save_settings(tabs: &TerminalTabs) {
    let dir = config_dir();
    let _ = std::fs::create_dir_all(&dir);
    let settings = crate::settings::Settings {
        keep_tab_after_exit: Some(tabs.keep_tab_after_exit),
        auto_reconnect: Some(tabs.auto_reconnect),
        remember_session: Some(tabs.remember_session),
        sync_font_size_across_tabs: Some(tabs.sync_font_size_across_tabs),
        remember_font_size: Some(tabs.remember_font_size),
        font_size: if tabs.remember_font_size {
            Some(f32::from(tabs.font_size))
        } else {
            None
        },
    };
    if let Ok(json) = serde_json::to_string_pretty(&settings) {
        let _ = std::fs::write(dir.join("settings.json"), json);
    }
}

pub struct TerminalTabs {
    active_tab: usize,
    tabs: Vec<Entity<TerminalSession>>,
    prompt: Option<String>,
    ssh_hosts: Vec<String>,
    selected_host_index: usize,
    show_settings: bool,
    show_search: bool,
    search_query: String,
    search_status: Option<bool>, // Some(true)=found, Some(false)=not found
    keep_tab_after_exit: bool,
    auto_reconnect: bool,
    remember_session: bool,
    /// When true, Ctrl/Cmd +/-/0 updates every tab (default).
    sync_font_size_across_tabs: bool,
    /// Persist last font size across relaunches.
    remember_font_size: bool,
    /// Shared / default font size for new tabs (and sync target).
    font_size: Pixels,
    last_appearance: Option<WindowAppearance>,
    focus_active_terminal: bool,
    /// Focus the chrome (host prompt / search) so typing isn't swallowed by a terminal.
    focus_ui: bool,
    focus_handle: FocusHandle,
    /// Palette applied to new tabs (kept in sync with OS appearance).
    terminal_palette: ColorPalette,
}

impl Focusable for TerminalTabs {
    fn focus_handle(&self, _: &App) -> FocusHandle {
        self.focus_handle.clone()
    }
}

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

impl TerminalTabs {
    /// Apply Ctrl/Cmd +/-/0 font zoom to the active tab, or all tabs when sync is on.
    fn apply_font_key(&mut self, key: &str, cx: &mut Context<Self>) {
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
            self.font_size = size; // still the default for newly opened tabs
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
            save_settings(self);
        }
    }

    /// Reset all settings toggles and font size to built-in defaults, persist, and
    /// apply the default font to every open tab. Does not close tabs or wipe session.json.
    fn restore_defaults(&mut self, cx: &mut Context<Self>) {
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
        save_settings(self);
    }

    /// Focus the active terminal, then again next frame once it is in the tree.
    /// (A single focus during/just after creating the first tab often does not stick.)
    fn focus_active_session(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        self.focus_active_terminal = false;
        let Some(session) = self.tabs.get(self.active_tab).cloned() else {
            return;
        };
        let tv = session.read(cx).terminal_view.clone();
        tv.read(cx).focus_handle().clone().focus(window);
        cx.on_next_frame(window, |this, window, cx| {
            if this.prompt.is_some() || this.show_search || this.show_settings {
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

    fn should_restore_terminal_focus(&self) -> bool {
        self.prompt.is_none()
            && !self.show_search
            && !self.show_settings
            && !self.tabs.is_empty()
    }

    /// Restore terminal focus when idle (no overlay). Used by window-level subscriptions.
    fn restore_terminal_focus(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        if self.should_restore_terminal_focus() {
            self.focus_active_session(window, cx);
        }
    }

    /// Whether an exited session should be closed (matches the poll-loop removal rule).
    fn should_close_exited_tab(session: &TerminalSession, auto_reconnect: bool) -> bool {
        if !session.has_exited {
            return false;
        }
        let success = session.exit_status == Some(0);
        !(auto_reconnect && !success)
    }

    /// Drop tabs whose PTY has already exited when keep-tab is off.
    fn remove_exited_tabs(&mut self, cx: &mut Context<Self>) {
        if self.keep_tab_after_exit {
            return;
        }
        let auto_reconnect = self.auto_reconnect;
        let mut removed = false;
        for i in (0..self.tabs.len()).rev() {
            let close = Self::should_close_exited_tab(self.tabs[i].read(cx), auto_reconnect);
            if close {
                self.tabs.remove(i);
                removed = true;
            }
        }
        if !removed {
            return;
        }
        self.active_tab = self.active_tab.min(self.tabs.len().saturating_sub(1));
        if self.tabs.is_empty() {
            self.prompt = Some(String::new());
            self.selected_host_index = 0;
            self.ssh_hosts = get_ssh_hosts();
            self.focus_ui = true;
        }
        if self.remember_session {
            let hosts: Vec<Option<String>> =
                self.tabs.iter().map(|t| t.read(cx).host.clone()).collect();
            save_session(&hosts);
        }
        cx.notify();
    }

    pub fn new(window: &mut Window, cx: &mut Context<Self>) -> Self {
        let settings = load_settings();
        let keep_tab_after_exit = settings.keep_tab_after_exit.unwrap_or(true);
        let auto_reconnect = settings.auto_reconnect.unwrap_or(false);
        let remember_session = settings.remember_session.unwrap_or(false);
        let sync_font_size_across_tabs = settings.sync_font_size_across_tabs.unwrap_or(true);
        let remember_font_size = settings.remember_font_size.unwrap_or(false);
        let font_size = if remember_font_size {
            px(settings
                .font_size
                .unwrap_or(DEFAULT_FONT_SIZE)
                .clamp(6.0, 72.0))
        } else {
            px(DEFAULT_FONT_SIZE)
        };

        // Restore saved session or start with prompt open
        // Use light as the pre-window default; first render syncs to real appearance.
        let terminal_palette = palette_for_appearance(WindowAppearance::Light);
        let initial_tabs: Vec<Entity<TerminalSession>> = if remember_session {
            let saved = load_session();
            if saved.is_empty() {
                vec![]
            } else {
                saved
                    .into_iter()
                    .map(|host| {
                        let colors = terminal_palette.clone();
                        cx.new(|cx| TerminalSession::new(host, colors, font_size, cx))
                    })
                    .collect()
            }
        } else {
            vec![]
        };

        let start_prompt = initial_tabs.is_empty();
        let focus_handle = cx.focus_handle();

        // Central focus recovery: WM maximize/resize (KDE Plasma), focus dropped to
        // nothing, or window re-activated after minimize. Chrome clicks no longer
        // need per-element refocus — track_focus lives on overlays only, not the root.
        cx.observe_window_bounds(window, |this, window, cx| {
            this.restore_terminal_focus(window, cx);
        })
        .detach();
        cx.on_focus_lost(window, |this, window, cx| {
            this.restore_terminal_focus(window, cx);
        })
        .detach();
        cx.observe_window_activation(window, |this, window, cx| {
            if window.is_window_active() {
                this.restore_terminal_focus(window, cx);
            }
        })
        .detach();

        cx.spawn(async move |this, mut cx| {
            loop {
                gpui::Timer::after(std::time::Duration::from_millis(16)).await;
                let _ = gpui::AsyncApp::update(&mut cx, |cx| {
                    gpui::WeakEntity::<TerminalTabs>::update(&this, cx, |this, cx| {
                        let mut needs_notify = false;
                        for i in (0..this.tabs.len()).rev() {
                            let auto_reconnect = this.auto_reconnect;
                            let keep_tab = this.keep_tab_after_exit;

                            let mut just_exited = false;
                            let mut success = false;
                            let mut reconnect_ready = false;
                            let mut host = None;
                            let mut streak = 0u32;

                            this.tabs[i].update(cx, |session, _| {
                                if !session.has_exited {
                                    session.check_exit();
                                    if session.has_exited {
                                        just_exited = true;
                                        if session.exit_status == Some(0) {
                                            session.reconnect_streak = 0;
                                            session.pending_reconnect_at = None;
                                        }
                                    }
                                }

                                success = session.has_exited && session.exit_status == Some(0);

                                if session.has_exited && !success && auto_reconnect {
                                    if session.pending_reconnect_at.is_none() {
                                        let shift = session.reconnect_streak.min(6);
                                        let delay_ms = 250u64.saturating_mul(1u64 << shift);
                                        session.pending_reconnect_at =
                                            Some(Instant::now() + Duration::from_millis(delay_ms));
                                        session.reconnect_streak =
                                            session.reconnect_streak.saturating_add(1);
                                    }
                                    if session
                                        .pending_reconnect_at
                                        .is_some_and(|t| Instant::now() >= t)
                                    {
                                        reconnect_ready = true;
                                        host = session.host.clone();
                                        streak = session.reconnect_streak;
                                    }
                                }
                            });

                            if reconnect_ready {
                                let colors = this.terminal_palette.clone();
                                let font_size = this.font_size;
                                this.tabs[i] = cx.new(|cx| {
                                    let mut session =
                                        TerminalSession::new(host, colors, font_size, cx);
                                    session.reconnect_streak = streak;
                                    session
                                });
                                needs_notify = true;
                            } else if just_exited
                                && !keep_tab
                                && Self::should_close_exited_tab(
                                    this.tabs[i].read(cx),
                                    auto_reconnect,
                                )
                            {
                                this.tabs.remove(i);
                                this.active_tab =
                                    this.active_tab.min(this.tabs.len().saturating_sub(1));
                                if this.tabs.is_empty() {
                                    this.prompt = Some(String::new());
                                    this.focus_ui = true;
                                }
                                needs_notify = true;
                            }
                        }
                        // Save session whenever tabs change
                        if needs_notify && this.remember_session {
                            let hosts: Vec<Option<String>> = this.tabs.iter().map(|t| t.read(cx).host.clone()).collect();
                            save_session(&hosts);
                        }
                        if needs_notify {
                            cx.notify();
                        }
                    }).ok()
                });
            }
        }).detach();

        Self {
            active_tab: 0,
            tabs: initial_tabs,
            prompt: if start_prompt { Some(String::new()) } else { None },
            ssh_hosts: get_ssh_hosts(),
            selected_host_index: 0,
            show_settings: false,
            show_search: false,
            search_query: String::new(),
            search_status: None,
            keep_tab_after_exit,
            auto_reconnect,
            remember_session,
            sync_font_size_across_tabs,
            remember_font_size,
            font_size,
            last_appearance: None,
            focus_active_terminal: !start_prompt,
            focus_ui: start_prompt,
            focus_handle,
            terminal_palette,
        }
    }
}

impl Render for TerminalTabs {
    fn render(&mut self, window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        let entity = cx.entity().clone();
        let appearance = cx.window_appearance();
        let is_dark = is_dark_appearance(appearance);
        let bg_color_bar = if is_dark { rgb(0x2d2d2d) } else { rgb(0xe0e0e0) };
        let bg_color_active = if is_dark { rgb(0x1e1e1e) } else { rgb(0xffffff) };
        let text_color = if is_dark { rgb(0xffffff) } else { rgb(0x000000) };
        let border_color = if is_dark { rgb(0x000000) } else { rgb(0xcccccc) };

        // Keep terminal palette + gpui-component theme in sync with OS appearance.
        // (Switch labels use Theme::foreground — without this they stay black in dark mode.)
        if self.last_appearance != Some(appearance) {
            self.last_appearance = Some(appearance);
            Theme::change(appearance, Some(window), cx);
            self.terminal_palette = palette_for_appearance(appearance);
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
        }

        let mut tab_bar = div()
            .id("tab_bar")
            .flex()
            .flex_row()
            .w_full()
            .bg(bg_color_bar)
            .h(px(32.0))
            .items_center();

        for (i, session) in self.tabs.iter().enumerate() {
            let bg_color = if i == self.active_tab { bg_color_active } else { bg_color_bar };
            let tab_label = session.read(cx).host.clone().unwrap_or_else(|| "localhost".to_string());
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
                .border_color(border_color)
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
                .child(div().child(tab_label).text_color(text_color).text_sm())
                .child(
                    div()
                        .id(("close_tab", i))
                        .ml_2()
                        .p_1()
                        .hover(|style| style.bg(if is_dark { rgb(0x555555) } else { rgb(0xcccccc) }).rounded_sm())
                        .child(div().child("✕").text_color(if is_dark { rgb(0xcccccc) } else { rgb(0x555555) }).text_xs())
                        .on_click(cx.listener(move |this, _, _, cx| {
                            this.tabs.remove(i);
                            if this.tabs.is_empty() {
                                this.active_tab = 0;
                                this.prompt = Some(String::new());
                                this.selected_host_index = 0;
                                this.ssh_hosts = get_ssh_hosts();
                                this.focus_ui = true;
                            } else {
                                this.active_tab =
                                    this.active_tab.min(this.tabs.len().saturating_sub(1));
                                this.focus_active_terminal = true;
                            }
                            if this.remember_session {
                                let hosts: Vec<Option<String>> =
                                    this.tabs.iter().map(|t| t.read(cx).host.clone()).collect();
                                save_session(&hosts);
                            }
                            cx.notify();
                        }))
                );
                
            tab_bar = tab_bar.child(tab);
        }

        // Title-bar action button style
        let title_btn = |id: &'static str, label: &'static str, is_dark: bool, text_color: Rgba| {
            div()
                .id(id)
                .flex()
                .items_center()
                .justify_center()
                .size_6()
                .ml_1()
                .rounded_sm()
                .cursor_pointer()
                .hover(|style| style.bg(if is_dark { rgb(0x555555) } else { rgb(0xcccccc) }))
                .child(div().child(label).text_color(text_color))
        };

        let show_client_controls = matches!(window.window_decorations(), Decorations::Client { .. })
            && !cfg!(target_os = "macos");

        // Custom title bar: app chrome + add / search / settings (not on the tab strip)
        let mut title_bar = div()
            .id("title_bar")
            .flex()
            .flex_row()
            .items_center()
            .h(px(36.0))
            .w_full()
            .px_2()
            .bg(bg_color_bar)
            .border_b_1()
            .border_color(border_color)
            // Leave room for macOS traffic lights when using a transparent titlebar
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
                            // macOS: respect System Settings → Dock → double-click title bar
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
                            .text_color(text_color)
                            .font_weight(FontWeight::SEMIBOLD)
                            .text_sm(),
                    ),
            )
            .child(
                title_btn("new_tab_btn", "+", is_dark, text_color).on_click(cx.listener(
                    |this, _, _, _| {
                        this.prompt = Some(String::new());
                        this.selected_host_index = 0;
                        this.ssh_hosts = get_ssh_hosts();
                        this.focus_ui = true;
                    },
                )),
            )
            .child(
                title_btn("search_btn", "⌕", is_dark, text_color).on_click(cx.listener(
                    |this, _, _, _| {
                        this.show_search = true;
                        this.search_status = None;
                        this.focus_ui = true;
                    },
                )),
            )
            .child(
                title_btn("settings_btn", "⚙", is_dark, text_color).on_click(cx.listener(
                    |this, _, _, _| {
                        this.show_settings = true;
                        this.focus_ui = true;
                    },
                )),
            );

        if show_client_controls {
            // Touch-friendly hit targets (~40×32). Tiny size_6 buttons are easy to
            // miss on Plasma touchscreens; gnome-terminal's chrome is much larger.
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
                        .hover(|s| s.bg(if is_dark { rgb(0x555555) } else { rgb(0xcccccc) }))
                        .window_control_area(WindowControlArea::Min)
                        .on_click(|_, window, _| window.minimize_window())
                        .child(div().child("–").text_color(text_color)),
                )
                .child(
                    ctl("win_max")
                        .hover(|s| s.bg(if is_dark { rgb(0x555555) } else { rgb(0xcccccc) }))
                        .window_control_area(WindowControlArea::Max)
                        .on_click(|_, window, _| window.zoom_window())
                        .child(div().child("□").text_color(text_color)),
                )
                .child(
                    ctl("win_close")
                        .hover(|s| s.bg(rgb(0xe81123)))
                        .window_control_area(WindowControlArea::Close)
                        .on_click(|_, window, _| window.remove_window())
                        .child(div().child("✕").text_color(text_color)),
                );
        }

        self.active_tab = self.active_tab.min(self.tabs.len().saturating_sub(1));
        let active_session = self.tabs.get(self.active_tab).cloned();

        // Session requested search (Ctrl/Cmd+F while terminal focused)
        if let Some(ref session) = active_session {
            if session.read(cx).wants_search {
                session.update(cx, |s, _| s.wants_search = false);
                self.show_search = true;
                self.search_status = None;
                self.focus_ui = true;
            }
        }

        // Host prompt / search / settings must own keyboard focus; otherwise keys go to a
        // focused terminal (or nowhere) and the overlay only works with the mouse.
        if self.focus_ui && (self.prompt.is_some() || self.show_search || self.show_settings) {
            self.focus_handle.focus(window);
            self.focus_ui = false;
        } else if self.focus_active_terminal
            && self.prompt.is_none()
            && !self.show_settings
            && !self.show_search
        {
            self.focus_active_session(window, cx);
        }

        // No track_focus on the root: a full-window hitbox steals focus from the
        // terminal when clicking title/tab chrome (GPUI focus-on-mouse-down).
        // Overlays attach track_focus when shown; global shortcuts use capture below.
        let mut main_div = div()
            .flex()
            .flex_col()
            .size_full()
            .bg(bg_color_active)
            .capture_key_down(cx.listener(move |this, ev: &gpui::KeyDownEvent, window, cx| {
                let mods = &ev.keystroke.modifiers;

                if this.show_settings {
                    cx.stop_propagation();
                    let key = ev.keystroke.key.as_str();
                    if key.eq_ignore_ascii_case("escape") {
                        this.show_settings = false;
                        this.focus_active_session(window, cx);
                        cx.notify();
                    }
                    return;
                }

                if this.show_search {
                    cx.stop_propagation();
                    let key = ev.keystroke.key.as_str();
                    match key {
                        "escape" => {
                            this.show_search = false;
                            this.search_status = None;
                            if let Some(session) = this.tabs.get(this.active_tab) {
                                session.update(cx, |s, cx| {
                                    s.terminal_view.update(cx, |tv, cx| tv.clear_search(cx));
                                });
                            }
                            this.focus_active_session(window, cx);
                        }
                        "enter" => {
                            let forward = !ev.keystroke.modifiers.shift;
                            let query = this.search_query.clone();
                            if let Some(session) = this.tabs.get(this.active_tab).cloned() {
                                let found = session.update(cx, |s, cx| {
                                    s.terminal_view.update(cx, |tv, cx| {
                                        tv.search(&query, forward, cx)
                                    })
                                });
                                this.search_status = Some(found);
                            }
                        }
                        "backspace" => {
                            this.search_query.pop();
                            this.search_status = None;
                        }
                        "space" => {
                            this.search_query.push(' ');
                            this.search_status = None;
                        }
                        _ => {
                            if !mods.control && !mods.platform {
                                if let Some(ch) = ev.keystroke.key_char.as_deref() {
                                    if ch != "\n" && ch != "\t" {
                                        this.search_query.push_str(ch);
                                        this.search_status = None;
                                    }
                                } else if key.chars().count() == 1 {
                                    this.search_query.push_str(key);
                                    this.search_status = None;
                                }
                            }
                        }
                    }
                    cx.notify();
                    return;
                }

                // Font zoom / copy / paste — capture so shortcuts work with terminal focus.
                if (mods.platform || mods.control)
                    && this.prompt.is_none()
                    && !this.show_search
                    && !this.show_settings
                    && !this.tabs.is_empty()
                {
                    let key = ev.keystroke.key.as_str();
                    if key == "=" || key == "+" || key == "-" || key == "0" {
                        cx.stop_propagation();
                        this.apply_font_key(key, cx);
                        cx.notify();
                        return;
                    }
                    let paste = key == "v"
                        && (mods.platform
                            || (mods.control && mods.shift && !cfg!(target_os = "macos")));
                    if paste {
                        cx.stop_propagation();
                        if let Ok(mut clipboard) = Clipboard::new() {
                            if let Ok(text) = clipboard.paste() {
                                if let Some(session) = this.tabs.get(this.active_tab) {
                                    session.update(cx, |s, cx| {
                                        s.terminal_view.update(cx, |tv, _| {
                                            tv.write_input(&text);
                                        });
                                    });
                                }
                            }
                        }
                        return;
                    }
                    let copy = key == "c"
                        && (mods.platform
                            || (mods.control && mods.shift && !cfg!(target_os = "macos")));
                    if copy {
                        cx.stop_propagation();
                        if let Some(session) = this.tabs.get(this.active_tab) {
                            session.update(cx, |s, cx| {
                                let _ = s.terminal_view.read(cx).copy_selection();
                            });
                        }
                        return;
                    }
                }

                if let Some(ref mut input) = this.prompt {
                    cx.stop_propagation();
                    let key = ev.keystroke.key.as_str();

                    let host_query = if input.contains('@') {
                        input.split('@').last().unwrap_or("")
                    } else {
                        input.as_str()
                    };

                    let visible_hosts: Vec<String> = this
                        .ssh_hosts
                        .iter()
                        .filter(|h| h.to_lowercase().contains(&host_query.to_lowercase()))
                        .cloned()
                        .collect();

                    match key {
                        "enter" => {
                            let prefix = if input.contains('@') {
                                format!("{}@", input.split('@').next().unwrap())
                            } else {
                                "".to_string()
                            };

                            let final_host = if !visible_hosts.is_empty() {
                                let selected = &visible_hosts[this
                                    .selected_host_index
                                    .min(visible_hosts.len().saturating_sub(1))];
                                if selected == "localhost" {
                                    "localhost".to_string()
                                } else {
                                    format!("{}{}", prefix, selected)
                                }
                            } else {
                                input.clone()
                            };

                            this.prompt = None;
                            let host_opt =
                                if final_host.trim().is_empty() || final_host == "localhost" {
                                    None
                                } else {
                                    Some(final_host)
                                };
                            let colors = this.terminal_palette.clone();
                            let font_size = this.font_size;
                            let new_tab =
                                cx.new(|cx| TerminalSession::new(host_opt, colors, font_size, cx));
                            this.tabs.push(new_tab);
                            this.active_tab = this.tabs.len() - 1;
                            this.focus_active_session(window, cx);
                            if this.remember_session {
                                let hosts: Vec<Option<String>> =
                                    this.tabs.iter().map(|t| t.read(cx).host.clone()).collect();
                                save_session(&hosts);
                            }
                        }
                        "escape" => {
                            if !this.tabs.is_empty() {
                                this.prompt = None;
                                this.focus_active_session(window, cx);
                            }
                        }
                        "backspace" => {
                            input.pop();
                            this.selected_host_index = 0;
                        }
                        "space" => {
                            input.push(' ');
                            this.selected_host_index = 0;
                        }
                        "up" => {
                            if this.selected_host_index > 0 {
                                this.selected_host_index -= 1;
                            }
                        }
                        "down" => {
                            if this.selected_host_index + 1 < visible_hosts.len() {
                                this.selected_host_index += 1;
                            }
                        }
                        _ => {
                            if !mods.control && !mods.platform {
                                if let Some(ch) = ev.keystroke.key_char.as_deref() {
                                    if ch != "\n" && ch != "\t" {
                                        input.push_str(ch);
                                        this.selected_host_index = 0;
                                    }
                                } else if key.chars().count() == 1 {
                                    input.push_str(key);
                                    this.selected_host_index = 0;
                                }
                            }
                        }
                    }
                    cx.notify();
                }
            }))
            .child(title_bar)
            .child(tab_bar)
            .when_some(active_session, |this, session| {
                this.child(div().flex_grow().child(session))
            });

        if let Some(ref input) = self.prompt {
            let host_query = if input.contains('@') {
                input.split('@').last().unwrap_or("")
            } else {
                input.as_str()
            };
            
            let visible_hosts: Vec<String> = self.ssh_hosts.iter()
                .filter(|h| h.to_lowercase().contains(&host_query.to_lowercase()))
                .cloned()
                .collect();
            
            let mut list_div = div().id("host_list").flex_col().mt_2().max_h(px(300.0)).overflow_y_scroll();
            
            for (idx, host) in visible_hosts.iter().enumerate() {
                let is_selected = idx == self.selected_host_index.min(visible_hosts.len().saturating_sub(1));
                let host_clone = host.clone();
                let host_for_click = host.clone();
                let prefix = {
                    let input = self.prompt.as_deref().unwrap_or("");
                    if input.contains('@') {
                        format!("{}@", input.split('@').next().unwrap())
                    } else {
                        "".to_string()
                    }
                };
                list_div = list_div.child(
                    div()
                        .id(("host_item", idx))
                        .p_2()
                        .rounded_sm()
                        .cursor_pointer()
                        .bg(if is_selected { if is_dark { rgb(0x444444) } else { rgb(0xcccccc) } } else { rgba(0x00000000) })
                        .hover(|style| style.bg(if is_dark { rgb(0x3a3a3a) } else { rgb(0xdddddd) }))
                        .on_click(cx.listener(move |this, _, window, cx| {
                            let final_host = if host_for_click == "localhost" {
                                "localhost".to_string()
                            } else {
                                format!("{}{}", prefix, host_for_click)
                            };
                            this.prompt = None;
                            let host_opt = if final_host == "localhost" {
                                None
                            } else {
                                Some(final_host)
                            };
                            let colors = this.terminal_palette.clone();
                            let font_size = this.font_size;
                            let new_tab =
                                cx.new(|cx| TerminalSession::new(host_opt, colors, font_size, cx));
                            this.tabs.push(new_tab);
                            this.active_tab = this.tabs.len() - 1;
                            this.focus_active_session(window, cx);
                            if this.remember_session {
                                let hosts: Vec<Option<String>> =
                                    this.tabs.iter().map(|t| t.read(cx).host.clone()).collect();
                                save_session(&hosts);
                            }
                            cx.notify();
                        }))
                        .child(div().child(host_clone).text_color(text_color))
                );
            }


            let overlay = div()
                .absolute()
                .inset_0()
                .bg(rgba(0x00000080))
                .flex()
                .justify_center()
                .items_center()
                .track_focus(&self.focus_handle)
                .when(!self.tabs.is_empty(), |overlay| {
                    overlay.on_mouse_down(MouseButton::Left, cx.listener(|this, _, window, cx| {
                        // Tap outside the panel to cancel (touch-friendly).
                        this.prompt = None;
                        this.focus_active_session(window, cx);
                        cx.notify();
                    }))
                })
                .child(
                    div()
                        .w_96()
                        .bg(if is_dark { rgb(0x2d2d2d) } else { rgb(0xf0f0f0) })
                        .rounded_lg()
                        .p_4()
                        .flex_col()
                        .on_mouse_down(MouseButton::Left, |_, _, cx| {
                            cx.stop_propagation();
                        })
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
                                        .text_color(text_color),
                                )
                                .when(!self.tabs.is_empty(), |row| {
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
                                            .hover(|s| {
                                                s.bg(if is_dark {
                                                    rgb(0x555555)
                                                } else {
                                                    rgb(0xcccccc)
                                                })
                                            })
                                            .on_click(cx.listener(|this, _, window, cx| {
                                                this.prompt = None;
                                                this.focus_active_session(window, cx);
                                                cx.notify();
                                            }))
                                            .child(div().child("✕").text_color(text_color)),
                                    )
                                }),
                        )
                        .child(
                            div()
                                .child(format!("{}█", input))
                                .font_family("monospace")
                                .text_color(text_color)
                                .bg(if is_dark { rgb(0x1e1e1e) } else { rgb(0xffffff) })
                                .p_2()
                        )
                        .child(list_div)
                );
            main_div = main_div.child(overlay);
        }
        
        if self.show_search {
            let status_text = match self.search_status {
                Some(true) => "Match found",
                Some(false) => "No matches",
                None => "Enter to find · Shift+Enter previous · Esc close",
            };
            let query = self.search_query.clone();
            let search_bar = div()
                .absolute()
                .top_8()
                .right_4()
                .w(px(420.0))
                .bg(if is_dark { rgb(0x2d2d2d) } else { rgb(0xf0f0f0) })
                .rounded_lg()
                .p_3()
                .shadow_md()
                .flex_col()
                .track_focus(&self.focus_handle)
                .child(
                    div()
                        .flex()
                        .flex_row()
                        .items_center()
                        .gap_2()
                        .child(
                            div()
                                .flex_grow()
                                .child(format!("{}█", query))
                                .font_family("monospace")
                                .text_color(text_color)
                                .bg(if is_dark { rgb(0x1e1e1e) } else { rgb(0xffffff) })
                                .p_2()
                                .rounded_sm(),
                        )
                        .child({
                            let q = query.clone();
                            div()
                                .id("search_prev")
                                .px_2()
                                .py_1()
                                .rounded_sm()
                                .cursor_pointer()
                                .bg(if is_dark { rgb(0x444444) } else { rgb(0xcccccc) })
                                .on_click(cx.listener(move |this, _, _, cx| {
                                    if let Some(session) = this.tabs.get(this.active_tab).cloned() {
                                        let found = session.update(cx, |s, cx| {
                                            s.terminal_view.update(cx, |tv, cx| {
                                                tv.search(&q, false, cx)
                                            })
                                        });
                                        this.search_status = Some(found);
                                        cx.notify();
                                    }
                                }))
                                .child(div().child("↑").text_color(text_color))
                        })
                        .child({
                            let q = query.clone();
                            div()
                                .id("search_next")
                                .px_2()
                                .py_1()
                                .rounded_sm()
                                .cursor_pointer()
                                .bg(if is_dark { rgb(0x444444) } else { rgb(0xcccccc) })
                                .on_click(cx.listener(move |this, _, _, cx| {
                                    if let Some(session) = this.tabs.get(this.active_tab).cloned() {
                                        let found = session.update(cx, |s, cx| {
                                            s.terminal_view.update(cx, |tv, cx| {
                                                tv.search(&q, true, cx)
                                            })
                                        });
                                        this.search_status = Some(found);
                                        cx.notify();
                                    }
                                }))
                                .child(div().child("↓").text_color(text_color))
                        })
                        .child(
                            div()
                                .id("search_close")
                                .px_2()
                                .py_1()
                                .rounded_sm()
                                .cursor_pointer()
                                .bg(if is_dark { rgb(0x444444) } else { rgb(0xcccccc) })
                                .on_click(cx.listener(|this, _, _, cx| {
                                    this.show_search = false;
                                    this.search_status = None;
                                    if let Some(session) = this.tabs.get(this.active_tab) {
                                        session.update(cx, |s, cx| {
                                            s.terminal_view.update(cx, |tv, cx| tv.clear_search(cx));
                                        });
                                    }
                                    this.focus_active_terminal = true;
                                    cx.notify();
                                }))
                                .child(div().child("✕").text_color(text_color)),
                        ),
                )
                .child(
                    div()
                        .mt_2()
                        .text_xs()
                        .text_color(if is_dark { rgb(0xaaaaaa) } else { rgb(0x555555) })
                        .child(status_text),
                );
            main_div = main_div.child(search_bar);
        }

        if self.show_settings {
            let overlay = div()
                .id("settings_overlay")
                .absolute()
                .inset_0()
                .bg(rgba(0x00000080))
                .flex()
                .justify_center()
                .items_center()
                .track_focus(&self.focus_handle)
                .on_mouse_down(MouseButton::Left, cx.listener(|this, _, window, cx| {
                    // Click outside the panel closes settings.
                    this.show_settings = false;
                    this.focus_active_session(window, cx);
                    cx.notify();
                }))
                .on_key_down(cx.listener(|this, ev: &KeyDownEvent, window, cx| {
                    if ev.keystroke.key.eq_ignore_ascii_case("escape") {
                        cx.stop_propagation();
                        this.show_settings = false;
                        this.focus_active_session(window, cx);
                        cx.notify();
                    }
                }))
                .child(
                    div()
                        .id("settings_panel")
                        .w_96()
                        .bg(if is_dark { rgb(0x2d2d2d) } else { rgb(0xf0f0f0) })
                        .text_color(text_color)
                        .rounded_lg()
                        .p_4()
                        .flex_col()
                        .on_mouse_down(MouseButton::Left, |_, _, cx| {
                            // Keep clicks on the panel from closing via the overlay.
                            cx.stop_propagation();
                        })
                        .child(div().child("Settings").text_color(text_color).text_xl().mb_4())
                        .child({
                            let entity = entity.clone();
                            Switch::new("keep_tab_toggle")
                                .checked(self.keep_tab_after_exit)
                                .label("Keep tab after exit")
                                .mb_3()
                                .text_color(text_color)
                                .on_click(move |checked, _, app| {
                                    entity.update(app, |this, cx| {
                                        this.keep_tab_after_exit = *checked;
                                        if !*checked {
                                            this.remove_exited_tabs(cx);
                                        }
                                        save_settings(this);
                                        cx.notify();
                                    });
                                })
                        })
                        .child({
                            let entity = entity.clone();
                            Switch::new("auto_reconnect_toggle")
                                .checked(self.auto_reconnect)
                                .label("Auto-reconnect on drop")
                                .mb_3()
                                .text_color(text_color)
                                .on_click(move |checked, _, app| {
                                    entity.update(app, |this, cx| {
                                        this.auto_reconnect = *checked;
                                        save_settings(this);
                                        cx.notify();
                                    });
                                })
                        })
                        .child({
                            let entity = entity.clone();
                            Switch::new("remember_session_toggle")
                                .checked(self.remember_session)
                                .label("Remember & restore tabs on relaunch")
                                .mb_3()
                                .text_color(text_color)
                                .on_click(move |checked, _, app| {
                                    entity.update(app, |this, cx| {
                                        this.remember_session = *checked;
                                        save_settings(this);
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
                                .checked(self.sync_font_size_across_tabs)
                                .label("Sync font size across tabs (Ctrl/Cmd +/-)")
                                .mb_3()
                                .text_color(text_color)
                                .on_click(move |checked, _, app| {
                                    entity.update(app, |this, cx| {
                                        this.sync_font_size_across_tabs = *checked;
                                        if *checked {
                                            // Align every open tab to the shared size.
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
                                        save_settings(this);
                                        cx.notify();
                                    });
                                })
                        })
                        .child({
                            let entity = entity.clone();
                            Switch::new("remember_font_size_toggle")
                                .checked(self.remember_font_size)
                                .label("Remember last font size on relaunch")
                                .mb_4()
                                .text_color(text_color)
                                .on_click(move |checked, _, app| {
                                    entity.update(app, |this, cx| {
                                        this.remember_font_size = *checked;
                                        save_settings(this);
                                        cx.notify();
                                    });
                                })
                        })
                        .child(
                            div()
                                .id("restore_defaults")
                                .p_2()
                                .mb_2()
                                .bg(if is_dark { rgb(0x555555) } else { rgb(0xdddddd) })
                                .rounded_sm()
                                .cursor_pointer()
                                .flex()
                                .justify_center()
                                .on_click(cx.listener(|this, _, _, cx| {
                                    this.restore_defaults(cx);
                                    cx.notify();
                                }))
                                .child(div().child("Restore defaults").text_color(text_color)),
                        )
                        .child(
                            div()
                                .id("close_settings")
                                .p_2()
                                .bg(if is_dark { rgb(0x444444) } else { rgb(0xcccccc) })
                                .rounded_sm()
                                .cursor_pointer()
                                .flex()
                                .justify_center()
                                .on_click(cx.listener(|this, _, window, cx| {
                                    this.show_settings = false;
                                    this.focus_active_session(window, cx);
                                    cx.notify();
                                }))
                                .child(div().child("Close").text_color(text_color))
                        )
                );
            main_div = main_div.child(overlay);
        }
        
        main_div
    }
}
