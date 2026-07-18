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
}

impl TerminalSession {
    fn new(host: Option<String>, cx: &mut Context<Self>) -> Self {
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
            cmd.args(["-c", "tmux attach || tmux new-session"]);
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
            colors: ColorPalette::default(), // GPUI-Terminal will pick up theme
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
                    if ev.keystroke.modifiers.platform {
                        let key = ev.keystroke.key.as_str();
                        if key == "=" || key == "-" || key == "0" || key == "c" || key == "v" {
                            return false;
                        }
                    }
                    false
                })
        });

        Self { terminal_view, child, has_exited: false, exit_status: None, host }
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
            .on_key_down(cx.listener(move |_this, ev: &gpui::KeyDownEvent, _window, cx| {
                if ev.keystroke.modifiers.platform {
                    let key = ev.keystroke.key.as_str();
                    if key == "=" || key == "-" || key == "0" {
                        terminal_view.update(cx, |tv, cx| {
                            let mut config = tv.config().clone();
                            if key == "=" {
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
    keep_tab_after_exit: bool,
    auto_reconnect: bool,
    remember_session: bool,
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
        let initial_tabs: Vec<Entity<TerminalSession>> = if remember_session {
            let saved = load_session();
            if saved.is_empty() {
                vec![]
            } else {
                saved.into_iter().map(|host| cx.new(|cx| TerminalSession::new(host, cx))).collect()
            }
        } else {
            vec![]
        };

        let start_prompt = initial_tabs.is_empty();

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
                                    this.tabs[i] = cx.new(|cx| TerminalSession::new(host, cx));
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
            keep_tab_after_exit,
            auto_reconnect,
            remember_session,
        }
    }
}

impl Render for TerminalTabs {
    fn render(&mut self, window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        let entity = cx.entity().clone();
        let is_dark = cx.window_appearance() == WindowAppearance::Dark;
        let bg_color_bar = if is_dark { rgb(0x2d2d2d) } else { rgb(0xe0e0e0) };
        let bg_color_active = if is_dark { rgb(0x1e1e1e) } else { rgb(0xffffff) };
        let text_color = if is_dark { rgb(0xffffff) } else { rgb(0x000000) };
        let border_color = if is_dark { rgb(0x000000) } else { rgb(0xcccccc) };

        // Build a palette that matches the OS theme
        let palette = if is_dark {
            ColorPalette::default() // dark: #1e1e1e bg, #d4d4d4 fg
        } else {
            ColorPalette::builder()
                .background(0xff, 0xff, 0xff) // white bg
                .foreground(0x1e, 0x1e, 0x1e) // near-black fg
                .cursor(0x1e, 0x1e, 0x1e)
                // Keep ANSI colours legible on white bg
                .black(0x1e, 0x1e, 0x1e)
                .bright_black(0x55, 0x55, 0x55)
                .white(0xbb, 0xbb, 0xbb)
                .bright_white(0x88, 0x88, 0x88)
                .build()
        };

        // Push palette to every tab so colour scheme tracks the OS theme live
        for tab in &self.tabs {
            let palette_clone = palette.clone();
            tab.update(cx, |session, cx| {
                session.terminal_view.update(cx, |tv, cx| {
                    let mut config = tv.config().clone();
                    config.colors = palette_clone;
                    tv.update_config(config, cx);
                });
            });
        }

        let mut tab_bar = div().flex().flex_row().bg(bg_color_bar).h(px(32.0)).items_center();
        
        for (i, session) in self.tabs.iter().enumerate() {
            let bg_color = if i == self.active_tab { bg_color_active } else { bg_color_bar };
            let tab_label = session.read(cx).host.clone().unwrap_or_else(|| "localhost".to_string());
            
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
                        // Move keyboard focus straight to the new terminal
                        let tv = this.tabs[i].read(cx).terminal_view.clone();
                        tv.read(cx).focus_handle().clone().focus(window);
                    }
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
                            }
                        }))
                );
                
            tab_bar = tab_bar.child(tab);
        }
        
        tab_bar = tab_bar.child(
            div()
                .id("new_tab_btn")
                .flex()
                .items_center()
                .justify_center()
                .size_6()
                .ml_2()
                .bg(if is_dark { rgb(0x3d3d3d) } else { rgb(0xcccccc) })
                .hover(|style| style.bg(if is_dark { rgb(0x555555) } else { rgb(0xaaaaaa) }))
                .rounded_sm()
                .cursor_pointer()
                .on_click(cx.listener(|this, _, _, _| {
                    this.prompt = Some(String::new());
                    this.selected_host_index = 0;
                    this.ssh_hosts = get_ssh_hosts();
                }))
                .child(div().child("+").text_color(text_color))
        );

        tab_bar = tab_bar.child(
            div()
                .id("settings_btn")
                .flex()
                .items_center()
                .justify_center()
                .size_6()
                .ml_2()
                .bg(if is_dark { rgb(0x3d3d3d) } else { rgb(0xcccccc) })
                .hover(|style| style.bg(if is_dark { rgb(0x555555) } else { rgb(0xaaaaaa) }))
                .rounded_sm()
                .cursor_pointer()
                .on_click(cx.listener(|this, _, _, _| {
                    this.show_settings = true;
                }))
                .child(div().child("⚙").text_color(text_color))
        );

        self.active_tab = self.active_tab.min(self.tabs.len().saturating_sub(1));
        let active_session = self.tabs[self.active_tab].clone();
        // Always keep focus on the active terminal so keypresses go straight to tmux
        if self.prompt.is_none() && self.show_settings == false {
            active_session.read(cx).terminal_view.read(cx).focus_handle().clone().focus(window);
        }

        let mut main_div = div()
            .flex()
            .flex_col()
            .size_full()
            .bg(bg_color_active)
            .on_key_down(cx.listener(move |this, ev: &gpui::KeyDownEvent, _window, cx| {
                if let Some(ref mut input) = this.prompt {
                    // Swallow the event — don't let it reach the terminal below
                    cx.stop_propagation();
                    let key = ev.keystroke.key.as_str();
                    
                    let host_query = if input.contains('@') {
                        input.split('@').last().unwrap_or("")
                    } else {
                        input.as_str()
                    };
                    
                    let visible_hosts: Vec<String> = this.ssh_hosts.iter()
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
                                let selected = &visible_hosts[this.selected_host_index.min(visible_hosts.len().saturating_sub(1))];
                                if selected == "localhost" {
                                    "localhost".to_string()
                                } else {
                                    format!("{}{}", prefix, selected)
                                }
                            } else {
                                input.clone()
                            };
                            
                            this.prompt = None;
                            let host_opt = if final_host.trim().is_empty() || final_host == "localhost" { None } else { Some(final_host) };
                            let new_tab = cx.new(|cx| TerminalSession::new(host_opt, cx));
                            this.tabs.push(new_tab);
                            this.active_tab = this.tabs.len() - 1;
                            // Persist session if enabled
                            if this.remember_session {
                                let hosts: Vec<Option<String>> = this.tabs.iter().map(|t| t.read(cx).host.clone()).collect();
                                save_session(&hosts);
                            }
                        }
                        "escape" => {
                            // Only allow closing the prompt if there are open tabs
                            if !this.tabs.is_empty() {
                                this.prompt = None;
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
                            if key.chars().count() == 1 {
                                input.push_str(key);
                                this.selected_host_index = 0;
                            }
                        }
                    }
                    cx.notify();
                }
            }))
            .child(tab_bar)
            .child(div().flex_grow().child(active_session));

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
                            let new_tab = cx.new(|cx| TerminalSession::new(host_opt, cx));
                            this.tabs.push(new_tab);
                            this.active_tab = this.tabs.len() - 1;
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
                ..Default::default()
            },
            |_, cx| cx.new(|cx| TerminalTabs::new(cx))
        ).unwrap();
        cx.activate(true);
    });
}
