use gpui::*;
use portable_pty::{CommandBuilder, MasterPty, NativePtySystem, PtySize, PtySystem};
use std::io::{Read, Write};
use std::sync::mpsc;

struct TerminalSession {
    parser: vt100::Parser,
    _writer: std::thread::JoinHandle<()>,
    _reader: std::thread::JoinHandle<()>,
    write_tx: mpsc::Sender<Vec<u8>>,
    read_rx: async_channel::Receiver<Vec<u8>>,
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
        let _child = pair.slave.spawn_command(cmd).unwrap();
        drop(pair.slave);

        let mut reader = pair.master.try_clone_reader().unwrap();
        let mut writer = pair.master.take_writer().unwrap();

        let (write_tx, write_rx) = mpsc::channel::<Vec<u8>>();
        let writer_thread = std::thread::spawn(move || {
            while let Ok(data) = write_rx.recv() {
                let _ = writer.write_all(&data);
                let _ = writer.flush();
            }
        });

        let (read_tx, read_rx) = async_channel::unbounded::<Vec<u8>>();
        let reader_thread = std::thread::spawn(move || {
            let mut buf = [0; 8192];
            loop {
                match reader.read(&mut buf) {
                    Ok(0) => break,
                    Ok(n) => {
                        if read_tx.send_blocking(buf[..n].to_vec()).is_err() {
                            break;
                        }
                    }
                    Err(_) => break,
                }
            }
        });

        Self {
            parser: vt100::Parser::new(24, 80, 0),
            _writer: writer_thread,
            _reader: reader_thread,
            write_tx,
            read_rx,
        }
    }
}

struct TerminalView {
    session: Entity<TerminalSession>,
}

impl TerminalView {
    fn new(session: Entity<TerminalSession>, cx: &mut Context<Self>) -> Self {
        cx.spawn(async move |this, mut cx| {
            let rx = gpui::AsyncApp::update(&mut cx, |cx| {
                gpui::WeakEntity::<TerminalView>::update(&this, cx, |view, cx| {
                    view.session.read(cx).read_rx.clone()
                }).ok()
            }).ok().flatten();
            
            if let Some(rx) = rx {
                while let Ok(data) = rx.recv().await {
                    let _ = gpui::AsyncApp::update(&mut cx, |cx| {
                        gpui::WeakEntity::<TerminalView>::update(&this, cx, |view, cx| {
                            view.session.update(cx, |session, cx| {
                                session.parser.process(&data);
                                cx.notify();
                            });
                        }).ok()
                    });
                }
            }
        }).detach();

        Self { session }
    }
}

impl Render for TerminalView {
    fn render(&mut self, _window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        let parser = &self.session.read(cx).parser;
        let screen = parser.screen();
        let write_tx = self.session.read(cx).write_tx.clone();
        let write_tx_keys = write_tx.clone();
        let write_tx_scroll = write_tx.clone();
        
        let mut rows_container = div()
            .flex()
            .flex_col()
            .bg(rgb(0x1e1e1e))
            .size_full()
            .font_family("Monaco")
            .text_sm()
            .track_focus(&cx.focus_handle())
            .on_key_down(move |ev, _window, _cx| {
                if let Some(text) = &ev.keystroke.key_char {
                    let _ = write_tx_keys.send(text.as_bytes().to_vec());
                }
            })
            .on_scroll_wheel(move |ev, _window, _cx| {
                let delta = ev.delta.pixel_delta(px(20.0));
                if delta.y > px(0.0) {
                    // Scroll up
                    let _ = write_tx_scroll.send(b"\x1b[<64;1;1M".to_vec());
                } else if delta.y < px(0.0) {
                    // Scroll down
                    let _ = write_tx_scroll.send(b"\x1b[<65;1;1M".to_vec());
                }
            });
        
        for r in 0..24 {
            let mut row_div = div().flex().flex_row();
            for c in 0..80 {
                if let Some(cell) = screen.cell(r, c) {
                    let mut cell_div = div().child(cell.contents().to_string());
                    // Apply styles
                    let _fg = cell.fgcolor();
                    let _bg = cell.bgcolor();
                    // Just basic colors for now
                    if cell.bold() {
                        cell_div = cell_div.font_weight(FontWeight::BOLD);
                    }
                    row_div = row_div.child(cell_div);
                }
            }
            rows_container = rows_container.child(row_div);
        }
        rows_container
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
                // Background task to trigger repaints when any session updates
                // Ideally this would be driven by session events, but for simplicity we poll/wait.
                // GPUI will notify automatically when the active session updates because the child view updates it.
                // So we actually don't need a background loop here, TerminalSession's loop calls cx.notify().
                // But TerminalSession's loop calls `cx.notify()` on TerminalSession, we need it to bubble up.
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
                            // If we remove the active tab, adjust active_tab
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
        
        // Render the active terminal
        let terminal_view = cx.new(|cx| TerminalView::new(active_session, cx));

        div()
            .flex()
            .flex_col()
            .size_full()
            .child(tab_bar)
            .child(terminal_view)
    }
}

fn main() {
    gpui::Application::new().run(|cx: &mut App| {
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
