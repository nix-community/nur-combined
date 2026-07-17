use gpui::*;
use portable_pty::{CommandBuilder, MasterPty, NativePtySystem, PtySize, PtySystem};
use std::io::{Read, Write};
use std::sync::mpsc;

struct TerminalSession {
    parser: vt100::Parser,
    master: Box<dyn MasterPty + Send>,
    _writer: std::thread::JoinHandle<()>,
    _reader: std::thread::JoinHandle<()>,
    write_tx: mpsc::Sender<Vec<u8>>,
    read_rx: async_channel::Receiver<Vec<u8>>,
    cols: u16,
    rows: u16,
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
            master: pair.master,
            _writer: writer_thread,
            _reader: reader_thread,
            write_tx,
            read_rx,
            cols: 80,
            rows: 24,
        }
    }

    fn resize(&mut self, new_rows: u16, new_cols: u16) {
        if self.rows == new_rows && self.cols == new_cols {
            return;
        }
        self.rows = new_rows;
        self.cols = new_cols;
        self.parser.screen_mut().set_size(new_rows, new_cols);
        let _ = self.master.resize(PtySize {
            rows: new_rows,
            cols: new_cols,
            pixel_width: 0,
            pixel_height: 0,
        });
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
        let session = self.session.clone();
        let session_clone = self.session.clone();
        
        let (rows, cols) = {
            let s = self.session.read(cx);
            (s.rows, s.cols)
        };
        
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
            .child(
                canvas(
                    move |bounds, _window, cx| {
                        // Approximate sizes for Monaco text_sm (approx 14px font size)
                        let cell_width = 8.4;
                        let cell_height = 16.0;
                        let w: f32 = bounds.size.width.into();
                        let h: f32 = bounds.size.height.into();
                        let new_cols = (w / cell_width).max(10.0) as u16;
                        let new_rows = (h / cell_height).max(5.0) as u16;
                        
                        cx.defer(move |cx| {
                            cx.update_entity(&session_clone, |session, _cx| {
                                session.resize(new_rows, new_cols);
                            });
                        });
                    },
                    |_, _, _, _| {}
                ).absolute().size_full()
            )
            .on_key_down(move |ev, _window, _cx| {
                let key = ev.keystroke.key.as_str();
                let mut bytes = Vec::new();
                
                if ev.keystroke.modifiers.control {
                    if key.len() == 1 {
                        let c = key.chars().next().unwrap();
                        if c >= 'a' && c <= 'z' {
                            bytes.push(c as u8 - b'a' + 1);
                        } else if c >= 'A' && c <= 'Z' {
                            bytes.push(c as u8 - b'A' + 1);
                        } else if c == ']' {
                            bytes.push(0x1d);
                        } else if c == '\\' {
                            bytes.push(0x1c);
                        }
                    }
                } else if ev.keystroke.modifiers.alt {
                    if key.len() == 1 {
                        bytes.push(0x1b);
                        bytes.push(key.as_bytes()[0]);
                    }
                } else {
                    match key {
                        "enter" => bytes.extend_from_slice(b"\r"),
                        "backspace" => bytes.extend_from_slice(b"\x7f"),
                        "tab" => bytes.extend_from_slice(b"\t"),
                        "escape" => bytes.extend_from_slice(b"\x1b"),
                        "up" => bytes.extend_from_slice(b"\x1b[A"),
                        "down" => bytes.extend_from_slice(b"\x1b[B"),
                        "right" => bytes.extend_from_slice(b"\x1b[C"),
                        "left" => bytes.extend_from_slice(b"\x1b[D"),
                        "home" => bytes.extend_from_slice(b"\x1b[H"),
                        "end" => bytes.extend_from_slice(b"\x1b[F"),
                        "pageup" => bytes.extend_from_slice(b"\x1b[5~"),
                        "pagedown" => bytes.extend_from_slice(b"\x1b[6~"),
                        _ => {
                            if let Some(text) = &ev.keystroke.key_char {
                                bytes.extend_from_slice(text.as_bytes());
                            }
                        }
                    }
                }
                
                if !bytes.is_empty() {
                    let _ = write_tx_keys.send(bytes);
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
        
        for r in 0..rows {
            let mut row_div = div().flex().flex_row().h(px(16.0));
            for c in 0..cols {
                if let Some(cell) = screen.cell(r, c) {
                    let mut cell_div = div().child(cell.contents().to_string()).w(px(8.4));
                    
                    // Apply styles
                    match cell.fgcolor() {
                        vt100::Color::Default => { cell_div = cell_div.text_color(rgb(0xcccccc)); },
                        vt100::Color::Idx(i) => {
                            // Basic 16-color ANSI mapping (approximate)
                            let c = match i {
                                0 => rgb(0x000000), 1 => rgb(0xcc0000), 2 => rgb(0x4e9a06), 3 => rgb(0xc4a000),
                                4 => rgb(0x3465a4), 5 => rgb(0x75507b), 6 => rgb(0x06989a), 7 => rgb(0xd3d7cf),
                                8 => rgb(0x555753), 9 => rgb(0xef2929), 10 => rgb(0x8ae234), 11 => rgb(0xfce94f),
                                12 => rgb(0x729fcf), 13 => rgb(0xad7fa8), 14 => rgb(0x34e2e2), 15 => rgb(0xeeeeec),
                                _ => rgb(0xcccccc), // Fallback for 256 colors
                            };
                            cell_div = cell_div.text_color(c);
                        },
                        vt100::Color::Rgb(r, g, b) => { cell_div = cell_div.text_color(rgb(((r as u32) << 16) | ((g as u32) << 8) | (b as u32))); },
                    }
                    
                    match cell.bgcolor() {
                        vt100::Color::Default => {},
                        vt100::Color::Idx(i) => {
                            let c = match i {
                                0 => rgb(0x000000), 1 => rgb(0xcc0000), 2 => rgb(0x4e9a06), 3 => rgb(0xc4a000),
                                4 => rgb(0x3465a4), 5 => rgb(0x75507b), 6 => rgb(0x06989a), 7 => rgb(0xd3d7cf),
                                8 => rgb(0x555753), 9 => rgb(0xef2929), 10 => rgb(0x8ae234), 11 => rgb(0xfce94f),
                                12 => rgb(0x729fcf), 13 => rgb(0xad7fa8), 14 => rgb(0x34e2e2), 15 => rgb(0xeeeeec),
                                _ => rgb(0x000000),
                            };
                            cell_div = cell_div.bg(c);
                        },
                        vt100::Color::Rgb(r, g, b) => { cell_div = cell_div.bg(rgb(((r as u32) << 16) | ((g as u32) << 8) | (b as u32))); },
                    }
                    
                    if cell.bold() {
                        cell_div = cell_div.font_weight(FontWeight::BOLD);
                    }
                    if cell.inverse() {
                        // Reverse video
                        cell_div = cell_div.bg(rgb(0xcccccc)).text_color(rgb(0x1e1e1e));
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
