use gpui::prelude::*;
use gpui::*;
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

impl TerminalTabs {
    fn new(cx: &mut Context<Self>) -> Self {
        let first_tab = cx.new(|cx| TerminalSession::new(None, cx));
        
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
                                    if this.tabs.len() > 1 {
                                        this.tabs.remove(i);
                                        this.active_tab = this.active_tab.min(this.tabs.len().saturating_sub(1));
                                    }
                                    needs_notify = true;
                                }
                            }
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
            tabs: vec![first_tab],
            prompt: None,
            ssh_hosts: get_ssh_hosts(),
            selected_host_index: 0,
            show_settings: false,
            keep_tab_after_exit: true,
            auto_reconnect: false,
        }
    }
}

impl Render for TerminalTabs {
    fn render(&mut self, _window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        let is_dark = cx.window_appearance() == WindowAppearance::Dark;
        let bg_color_bar = if is_dark { rgb(0x2d2d2d) } else { rgb(0xe0e0e0) };
        let bg_color_active = if is_dark { rgb(0x1e1e1e) } else { rgb(0xffffff) };
        let text_color = if is_dark { rgb(0xffffff) } else { rgb(0x000000) };
        let border_color = if is_dark { rgb(0x000000) } else { rgb(0xcccccc) };

        let mut tab_bar = div().flex().flex_row().bg(bg_color_bar).h(px(32.0)).items_center();
        
        for (i, _session) in self.tabs.iter().enumerate() {
            let bg_color = if i == self.active_tab { bg_color_active } else { bg_color_bar };
            
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
                .on_click(cx.listener(move |this, _, _, _| {
                    if i < this.tabs.len() {
                        this.active_tab = i;
                    }
                }))
                .child(div().child(format!("Tab {}", i + 1)).text_color(text_color).text_sm())
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

        let mut main_div = div()
            .flex()
            .flex_col()
            .size_full()
            .bg(bg_color_active)
            .on_key_down(cx.listener(move |this, ev: &gpui::KeyDownEvent, _window, cx| {
                if let Some(ref mut input) = this.prompt {
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
                        }
                        "escape" => {
                            this.prompt = None;
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
                list_div = list_div.child(
                    div()
                        .p_2()
                        .rounded_sm()
                        .bg(if is_selected { if is_dark { rgb(0x444444) } else { rgb(0xcccccc) } } else { rgba(0x00000000) })
                        .child(div().child(host.clone()).text_color(text_color))
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
                        .child(
                            div().flex().flex_row().items_center().mb_2().child(
                                div().child("Keep tab after exit?").text_color(text_color).w_48()
                            ).child(
                                div()
                                    .id("keep_tab_toggle")
                                    .cursor_pointer()
                                    .on_click(cx.listener(|this, _, _, _| { this.keep_tab_after_exit = !this.keep_tab_after_exit; }))
                                    .child(div().child(if self.keep_tab_after_exit { "[x]" } else { "[ ]" }).text_color(text_color))
                            )
                        )
                        .child(
                            div().flex().flex_row().items_center().mb_4().child(
                                div().child("Auto-reconnect on drop?").text_color(text_color).w_48()
                            ).child(
                                div()
                                    .id("auto_reconnect_toggle")
                                    .cursor_pointer()
                                    .on_click(cx.listener(|this, _, _, _| { this.auto_reconnect = !this.auto_reconnect; }))
                                    .child(div().child(if self.auto_reconnect { "[x]" } else { "[ ]" }).text_color(text_color))
                            )
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
