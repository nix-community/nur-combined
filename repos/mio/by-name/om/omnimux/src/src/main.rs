use gpui::*;
use gpui_terminal::{ColorPalette, TerminalConfig, TerminalView};
use portable_pty::{CommandBuilder, NativePtySystem, PtySize, PtySystem};

struct TerminalSession {
    terminal_view: Entity<TerminalView>,
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
        if let Some(h) = host {
            cmd.args(["-c", &format!("ssh {}", h)]);
        } else {
            cmd.args(["-c", "tmux attach || tmux new-session"]);
        }
        cmd.env("TERM", "xterm-256color");
        cmd.env("COLORTERM", "truecolor");
        let _child = pair.slave.spawn_command(cmd).unwrap();
        drop(pair.slave);

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

        Self { terminal_view }
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
}

impl TerminalTabs {
    fn new(cx: &mut Context<Self>) -> Self {
        let first_tab = cx.new(|cx| TerminalSession::new(None, cx));
        
        cx.spawn(async move |this, mut cx| {
            loop {
                gpui::Timer::after(std::time::Duration::from_millis(16)).await;
                let _ = gpui::AsyncApp::update(&mut cx, |cx| {
                    gpui::WeakEntity::<TerminalTabs>::update(&this, cx, |_, cx| cx.notify()).ok()
                });
            }
        }).detach();

        Self {
            active_tab: 0,
            tabs: vec![first_tab],
            prompt: None,
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
                        .child(div().child("x").text_color(if is_dark { rgb(0xcccccc) } else { rgb(0x555555) }).text_xs())
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
                }))
                .child(div().child("+").text_color(text_color))
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
                    match key {
                        "enter" => {
                            let host = input.clone();
                            this.prompt = None;
                            let host_opt = if host.trim().is_empty() { None } else { Some(host) };
                            let new_tab = cx.new(|cx| TerminalSession::new(host_opt, cx));
                            this.tabs.push(new_tab);
                            this.active_tab = this.tabs.len() - 1;
                        }
                        "escape" => {
                            this.prompt = None;
                        }
                        "backspace" => {
                            input.pop();
                        }
                        "space" => {
                            input.push(' ');
                        }
                        _ => {
                            if key.chars().count() == 1 {
                                input.push_str(key);
                            }
                        }
                    }
                    cx.notify();
                }
            }))
            .child(tab_bar)
            .child(div().flex_grow().child(active_session));

        if let Some(ref input) = self.prompt {
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
