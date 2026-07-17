use gpui::*;
use gpui_terminal::{ColorPalette, TerminalConfig, TerminalView};
use portable_pty::{CommandBuilder, NativePtySystem, PtySize, PtySystem};

struct TerminalSession {
    terminal_view: Entity<TerminalView>,
}

impl TerminalSession {
    fn new(cx: &mut Context<Self>) -> Self {
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
        cmd.args(["-c", "tmux attach || tmux new-session"]);
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
            colors: ColorPalette::default(),
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
    fn render(&mut self, _window: &mut Window, _cx: &mut Context<Self>) -> impl IntoElement {
        div().size_full().child(self.terminal_view.clone())
    }
}

struct TerminalTabs {
    active_tab: usize,
    tabs: Vec<Entity<TerminalSession>>,
}

impl TerminalTabs {
    fn new(cx: &mut Context<Self>) -> Self {
        let first_tab = cx.new(|cx| TerminalSession::new(cx));
        
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
        }
    }
}

impl Render for TerminalTabs {
    fn render(&mut self, _window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        let mut tab_bar = div().flex().flex_row().bg(rgb(0x2d2d2d)).h(px(32.0)).items_center();
        
        for (i, _session) in self.tabs.iter().enumerate() {
            let bg_color = if i == self.active_tab { rgb(0x1e1e1e) } else { rgb(0x2d2d2d) };
            
            let tab = div()
                .id(("tab", i))
                .flex()
                .flex_row()
                .items_center()
                .px_4()
                .h_full()
                .bg(bg_color)
                .border_r_1()
                .border_color(rgb(0x000000))
                .cursor_pointer()
                .on_click(cx.listener(move |this, _, _, _| {
                    this.active_tab = i;
                }))
                .child(div().child(format!("Tab {}", i + 1)).text_color(rgb(0xffffff)).text_sm())
                .child(
                    div()
                        .id(("close_tab", i))
                        .ml_2()
                        .p_1()
                        .hover(|style| style.bg(rgb(0x555555)).rounded_sm())
                        .child(div().child("x").text_color(rgb(0xcccccc)).text_xs())
                        .on_click(cx.listener(move |this, _, _, _| {
                            if this.tabs.len() > 1 {
                                this.tabs.remove(i);
                                if this.active_tab >= i && this.active_tab > 0 {
                                    this.active_tab -= 1;
                                }
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
                .bg(rgb(0x3d3d3d))
                .hover(|style| style.bg(rgb(0x555555)))
                .rounded_sm()
                .cursor_pointer()
                .on_click(cx.listener(|this, _, _, cx| {
                    let new_tab = cx.new(|cx| TerminalSession::new(cx));
                    this.tabs.push(new_tab);
                    this.active_tab = this.tabs.len() - 1;
                }))
                .child(div().child("+").text_color(rgb(0xffffff)))
        );

        let active_session = self.tabs[self.active_tab].clone();

        div()
            .flex()
            .flex_col()
            .size_full()
            .child(tab_bar)
            .child(
                div().flex_grow().child(active_session)
            )
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
