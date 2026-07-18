use gpui::prelude::*;
use gpui::*;
use gpui_component::switch::Switch;
use gpui_terminal::{ColorPalette, TerminalConfig, TerminalView};
use portable_pty::{CommandBuilder, NativePtySystem, PtySize, PtySystem};

struct TerminalSession {
    terminal_view: Entity<TerminalView>,
    child: std::sync::Arc<std::sync::Mutex<Box<dyn portable_pty::Child + Send + Sync>>>,
    has_exited: bool,
    exit_status: Option<u32>,
    host: Option<String>,
    wants_search: bool,
}

fn is_dark_appearance(appearance: WindowAppearance) -> bool {
    matches!(
        appearance,
        WindowAppearance::Dark | WindowAppearance::VibrantDark
    )
}

fn palette_for_appearance(appearance: WindowAppearance) -> ColorPalette {
    if is_dark_appearance(appearance) {
        ColorPalette::default()
    } else {
        ColorPalette::builder()
            .background(0xff, 0xff, 0xff)
            .foreground(0x1e, 0x1e, 0x1e)
            .cursor(0x1e, 0x1e, 0x1e)
            .black(0x1e, 0x1e, 0x1e)
            .bright_black(0x55, 0x55, 0x55)
            .white(0xbb, 0xbb, 0xbb)
            .bright_white(0x88, 0x88, 0x88)
            .build()
    }
}

impl TerminalSession {
    fn new(host: Option<String>, colors: ColorPalette, cx: &mut Context<Self>) -> Self {
        let pty_system = NativePtySystem::default();
        let pair = pty_system
            .openpty(PtySize {
                rows: 24,
                cols: 80,
                pixel_width: 0,
                pixel_height: 0,
            })
            .unwrap();

        let mut cmd = CommandBuilder::new("sh");
        if let Some(ref h) = host {
            cmd.args(["-c", &format!("ssh {}", h)]);
        } else {
            // Enable tmux mouse so wheel events reach panes / copy-mode
            cmd.args([
                "-c",
                "tmux -u has-session 2>/dev/null && exec tmux -u attach \\; set -g mouse on || exec tmux -u new-session \\; set -g mouse on",
            ]);
        }
        cmd.env("TERM", "xterm-256color");
        cmd.env("COLORTERM", "truecolor");
        let child_proc = pair.slave.spawn_command(cmd).unwrap();
        drop(pair.slave);

        let child = std::sync::Arc::new(std::sync::Mutex::new(child_proc));

        let reader = pair.master.try_clone_reader().unwrap();
        let writer = pair.master.take_writer().unwrap();

        let master = std::sync::Arc::new(std::sync::Mutex::new(pair.master));

        let config = TerminalConfig {
            cols: 80,
            rows: 24,
            font_family: "Monaco".into(),
            font_size: px(14.0),
            line_height_multiplier: 1.14,
            scrollback: 10000,
            padding: Edges::default(),
            colors,
        };

        let terminal_view = cx.new(|cx| {
            let master_clone = master.clone();
            TerminalView::new(writer, reader, config, cx)
                .with_resize_callback(move |cols, rows| {
                    if let Ok(master) = master_clone.lock() {
                        let _ = master.resize(PtySize {
                            cols: cols as u16,
                            rows: rows as u16,
                            pixel_width: 0,
                            pixel_height: 0,
                        });
                    }
                })
                .with_key_handler(|ev| {
                    // Let omnimux handle zoom / copy shortcuts (Ctrl or Super/Cmd)
                    let mods = &ev.keystroke.modifiers;
                    if mods.platform || mods.control {
                        let key = ev.keystroke.key.as_str();
                        if key == "="
                            || key == "+"
                            || key == "-"
                            || key == "0"
                            || key == "c"
                            || key == "v"
                            || key == "f"
                        {
                            return true; // consume — parent handles zoom / search
                        }
                    }
                    false
                })
        });

        Self {
            terminal_view,
            child,
            has_exited: false,
            exit_status: None,
            host,
            wants_search: false,
        }
    }

    fn check_exit(&mut self) {
        if !self.has_exited {
            if let Ok(mut child) = self.child.lock() {
                if let Ok(Some(status)) = child.try_wait() {
                    self.has_exited = true;
                    self.exit_status = Some(if status.success() { 0 } else { 255 });
                }
            }
        }
    }
}

impl Render for TerminalSession {
    fn render(&mut self, _window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        let terminal_view = self.terminal_view.clone();
        div()
            .size_full()
            .on_key_down(cx.listener(move |this, ev: &gpui::KeyDownEvent, _window, cx| {
                let mods = &ev.keystroke.modifiers;
                if !(mods.platform || mods.control) {
                    return;
                }
                let key = ev.keystroke.key.as_str();
                if key == "f" {
                    cx.stop_propagation();
                    this.wants_search = true;
                    cx.notify();
                    return;
                }
                if key == "=" || key == "+" || key == "-" || key == "0" {
                    cx.stop_propagation();
                    terminal_view.update(cx, |tv, cx| {
                        let mut config = tv.config().clone();
                        if key == "=" || key == "+" {
                            config.font_size += px(1.0);
                        } else if key == "-" {
                            config.font_size -= px(1.0);
                        } else if key == "0" {
                            config.font_size = px(14.0);
                        }
                        config.font_size = config.font_size.clamp(px(6.0), px(72.0));
                        tv.update_config(config, cx);
                    });
                }
            }))
            .child(self.terminal_view.clone())
    }
}

struct TerminalTabs {
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

fn get_ssh_hosts() -> Vec<String> {
    let mut hosts = vec!["localhost".to_string()];
    let home = std::env::var("HOME").unwrap_or_default();
    if let Ok(contents) = std::fs::read_to_string(format!("{}/.ssh/config", home)) {
        for line in contents.lines() {
            let line = line.trim();
            if line.to_lowercase().starts_with("host ") {
                let parts: Vec<&str> = line.split_whitespace().collect();
                if parts.len() > 1 && !parts[1].contains('*') {
                    hosts.push(parts[1].to_string());
                }
            }
        }
    }
    hosts
}

fn config_dir() -> std::path::PathBuf {
    let home = std::env::var("HOME").unwrap_or_default();
    std::path::PathBuf::from(format!("{}/.config/omnimux", home))
}

#[derive(serde::Serialize, serde::Deserialize, Default)]
struct Settings {
    keep_tab_after_exit: Option<bool>,
    auto_reconnect: Option<bool>,
    remember_session: Option<bool>,
}

fn load_settings() -> Settings {
    let path = config_dir().join("settings.json");
    std::fs::read_to_string(path)
        .ok()
        .and_then(|s| serde_json::from_str(&s).ok())
        .unwrap_or_default()
}

fn save_settings(tabs: &TerminalTabs) {
    let dir = config_dir();
    let _ = std::fs::create_dir_all(&dir);
    let settings = Settings {
        keep_tab_after_exit: Some(tabs.keep_tab_after_exit),
        auto_reconnect: Some(tabs.auto_reconnect),
        remember_session: Some(tabs.remember_session),
    };
    if let Ok(json) = serde_json::to_string_pretty(&settings) {
        let _ = std::fs::write(dir.join("settings.json"), json);
    }
}

fn save_session(hosts: &[Option<String>]) {
    let dir = config_dir();
    let _ = std::fs::create_dir_all(&dir);
    let list: Vec<String> = hosts.iter().map(|h| h.clone().unwrap_or_else(|| "localhost".to_string())).collect();
    if let Ok(json) = serde_json::to_string_pretty(&list) {
        let _ = std::fs::write(dir.join("session.json"), json);
    }
}

fn load_session() -> Vec<Option<String>> {
    let path = config_dir().join("session.json");
    std::fs::read_to_string(path)
        .ok()
        .and_then(|s| serde_json::from_str::<Vec<String>>(&s).ok())
        .unwrap_or_default()
        .into_iter()
        .map(|h| if h == "localhost" { None } else { Some(h) })
        .collect()
}

impl TerminalTabs {
    fn new(cx: &mut Context<Self>) -> Self {
        let settings = load_settings();
        let keep_tab_after_exit = settings.keep_tab_after_exit.unwrap_or(true);
        let auto_reconnect = settings.auto_reconnect.unwrap_or(false);
        let remember_session = settings.remember_session.unwrap_or(false);

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
                        cx.new(|cx| TerminalSession::new(host, colors, cx))
                    })
                    .collect()
            }
        } else {
            vec![]
        };

        let start_prompt = initial_tabs.is_empty();
        let focus_handle = cx.focus_handle();

        cx.spawn(async move |this, mut cx| {
            loop {
                gpui::Timer::after(std::time::Duration::from_millis(16)).await;
                let _ = gpui::AsyncApp::update(&mut cx, |cx| {
                    gpui::WeakEntity::<TerminalTabs>::update(&this, cx, |this, cx| {
                        let mut needs_notify = false;
                        for i in (0..this.tabs.len()).rev() {
                            let mut has_exited = false;
                            let mut success = false;
                            this.tabs[i].update(cx, |session, _| {
                                if !session.has_exited {
                                    session.check_exit();
                                    if session.has_exited {
                                        has_exited = true;
                                        success = session.exit_status == Some(0);
                                    }
                                }
                            });

                            if has_exited {
                                if !success && this.auto_reconnect {
                                    let host = this.tabs[i].read(cx).host.clone();
                                    let colors = this.terminal_palette.clone();
                                    this.tabs[i] =
                                        cx.new(|cx| TerminalSession::new(host, colors, cx));
                                    needs_notify = true;
                                } else if !this.keep_tab_after_exit {
                                    this.tabs.remove(i);
                                    this.active_tab = this.active_tab.min(this.tabs.len().saturating_sub(1));
                                    needs_notify = true;
                                }
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

        // Keep terminal palette in sync with OS theme (and for any newly opened tabs).
        if self.last_appearance != Some(appearance) {
            self.last_appearance = Some(appearance);
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

        let mut tab_bar = div().flex().flex_row().bg(bg_color_bar).h(px(32.0)).items_center();
        
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
                        .on_click(cx.listener(move |this, _, _, _| {
                            if this.tabs.len() > 1 {
                                this.tabs.remove(i);
                                this.active_tab = this.active_tab.min(this.tabs.len().saturating_sub(1));
                                this.focus_active_terminal = true;
                            }
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

        let show_client_controls =
            matches!(window.window_decorations(), Decorations::Client { .. });

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
                    },
                )),
            );

        if show_client_controls {
            title_bar = title_bar
                .child(
                    div()
                        .id("win_min")
                        .flex()
                        .items_center()
                        .justify_center()
                        .size_6()
                        .ml_2()
                        .rounded_sm()
                        .cursor_pointer()
                        .hover(|s| s.bg(if is_dark { rgb(0x555555) } else { rgb(0xcccccc) }))
                        .window_control_area(WindowControlArea::Min)
                        .on_click(|_, window, _| window.minimize_window())
                        .child(div().child("–").text_color(text_color)),
                )
                .child(
                    div()
                        .id("win_max")
                        .flex()
                        .items_center()
                        .justify_center()
                        .size_6()
                        .ml_1()
                        .rounded_sm()
                        .cursor_pointer()
                        .hover(|s| s.bg(if is_dark { rgb(0x555555) } else { rgb(0xcccccc) }))
                        .window_control_area(WindowControlArea::Max)
                        .on_click(|_, window, _| window.zoom_window())
                        .child(div().child("□").text_color(text_color)),
                )
                .child(
                    div()
                        .id("win_close")
                        .flex()
                        .items_center()
                        .justify_center()
                        .size_6()
                        .ml_1()
                        .rounded_sm()
                        .cursor_pointer()
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

        // Host prompt / search must own keyboard focus; otherwise keys go to a
        // focused terminal (or nowhere) and the overlay only works with the mouse.
        if self.focus_ui && (self.prompt.is_some() || self.show_search) {
            self.focus_handle.focus(window);
            self.focus_ui = false;
        } else if self.focus_active_terminal
            && self.prompt.is_none()
            && !self.show_settings
            && !self.show_search
        {
            if let Some(ref session) = active_session {
                session
                    .read(cx)
                    .terminal_view
                    .read(cx)
                    .focus_handle()
                    .clone()
                    .focus(window);
            }
            self.focus_active_terminal = false;
        }

        let mut main_div = div()
            .flex()
            .flex_col()
            .size_full()
            .bg(bg_color_active)
            .track_focus(&self.focus_handle)
            // Capture so prompt/search keys win even if a terminal under the overlay is focused.
            .capture_key_down(cx.listener(move |this, ev: &gpui::KeyDownEvent, _window, cx| {
                let mods = &ev.keystroke.modifiers;

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
                            this.focus_active_terminal = true;
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
                            let new_tab = cx.new(|cx| TerminalSession::new(host_opt, colors, cx));
                            this.tabs.push(new_tab);
                            this.active_tab = this.tabs.len() - 1;
                            this.focus_active_terminal = true;
                            if this.remember_session {
                                let hosts: Vec<Option<String>> =
                                    this.tabs.iter().map(|t| t.read(cx).host.clone()).collect();
                                save_session(&hosts);
                            }
                        }
                        "escape" => {
                            if !this.tabs.is_empty() {
                                this.prompt = None;
                                this.focus_active_terminal = true;
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
                        .on_click(cx.listener(move |this, _, _, cx| {
                            let final_host = if host_for_click == "localhost" {
                                "localhost".to_string()
                            } else {
                                format!("{}{}", prefix, host_for_click)
                            };
                            this.prompt = None;
                            let host_opt = if final_host == "localhost" { None } else { Some(final_host) };
                            let colors = this.terminal_palette.clone();
                            let new_tab = cx.new(|cx| TerminalSession::new(host_opt, colors, cx));
                            this.tabs.push(new_tab);
                            this.active_tab = this.tabs.len() - 1;
                            this.focus_active_terminal = true;
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
                .child(
                    div()
                        .w_96()
                        .bg(if is_dark { rgb(0x2d2d2d) } else { rgb(0xf0f0f0) })
                        .rounded_lg()
                        .p_4()
                        .flex_col()
                        .child(div().child("New Session: Enter host (leave blank for localhost)").text_color(text_color).mb_2())
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
                .absolute()
                .inset_0()
                .bg(rgba(0x00000080))
                .flex()
                .justify_center()
                .items_center()
                .child(
                    div()
                        .w_96()
                        .bg(if is_dark { rgb(0x2d2d2d) } else { rgb(0xf0f0f0) })
                        .rounded_lg()
                        .p_4()
                        .flex_col()
                        .child(div().child("Settings").text_color(text_color).text_xl().mb_4())
                        .child({
                            let entity = entity.clone();
                            Switch::new("keep_tab_toggle")
                                .checked(self.keep_tab_after_exit)
                                .label("Keep tab after exit")
                                .mb_3()
                                .on_click(move |checked, _, app| {
                                    entity.update(app, |this, cx| {
                                        this.keep_tab_after_exit = *checked;
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
                                .mb_4()
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
                        .child(
                            div()
                                .id("close_settings")
                                .p_2()
                                .bg(if is_dark { rgb(0x444444) } else { rgb(0xcccccc) })
                                .rounded_sm()
                                .cursor_pointer()
                                .flex()
                                .justify_center()
                                .on_click(cx.listener(|this, _, _, _| { this.show_settings = false; }))
                                .child(div().child("Close").text_color(text_color))
                        )
                );
            main_div = main_div.child(overlay);
        }
        
        main_div
    }
}

fn main() {
    gpui::Application::new().run(|cx: &mut gpui::App| {
        gpui_component::init(cx);

        let bounds = Bounds::centered(None, size(px(800.0), px(600.0)), cx);
        cx.open_window(
            WindowOptions {
                window_bounds: Some(WindowBounds::Windowed(bounds)),
                titlebar: Some(TitlebarOptions {
                    title: Some("omnimux".into()),
                    appears_transparent: true,
                    traffic_light_position: Some(point(px(12.0), px(10.0))),
                }),
                window_decorations: Some(WindowDecorations::Client),
                app_id: Some("omnimux".into()),
                ..Default::default()
            },
            |_, cx| cx.new(|cx| TerminalTabs::new(cx))
        ).unwrap();
        cx.activate(true);
    });
}
