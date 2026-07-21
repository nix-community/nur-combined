use crate::palette::symbol_font_fallbacks;
use gpui::prelude::*;
use gpui::*;
use gpui_terminal::{Clipboard, ColorPalette, TerminalConfig, TerminalView};
use portable_pty::{CommandBuilder, NativePtySystem, PtySize, PtySystem};
use std::time::Instant;

pub struct TerminalSession {
    pub terminal_view: Entity<TerminalView>,
    pub child: std::sync::Arc<std::sync::Mutex<Box<dyn portable_pty::Child + Send + Sync>>>,
    pub has_exited: bool,
    pub exit_status: Option<u32>,
    pub host: Option<String>,
    pub wants_search: bool,
    /// Consecutive failed reconnects (for backoff).
    pub reconnect_streak: u32,
    /// When set, auto-reconnect waits until this instant.
    pub pending_reconnect_at: Option<Instant>,
}

impl TerminalSession {
    pub fn new(
        host: Option<String>,
        colors: ColorPalette,
        font_size: Pixels,
        cx: &mut Context<Self>,
    ) -> Self {
        let pty_system = NativePtySystem::default();
        let pair = match pty_system.openpty(PtySize {
            rows: 24,
            cols: 80,
            pixel_width: 0,
            pixel_height: 0,
        }) {
            Ok(pair) => pair,
            Err(err) => {
                eprintln!("omnimux: failed to open PTY: {err}");
                return Self::failed_session(host, colors, font_size, &format!("open PTY: {err}"), cx);
            }
        };

        let tmux_cmd = "tmux -u has-session 2>/dev/null && exec tmux -u attach \\; set -g mouse on || exec tmux -u new-session \\; set -g mouse on";

        let mut cmd = if let Some(ref h) = host {
            if h == "localhost" || h == "127.0.0.1" {
                let mut cmd = CommandBuilder::new("sh");
                cmd.args(["-c", tmux_cmd]);
                cmd
            } else {
                let mut cmd = CommandBuilder::new("ssh");
                cmd.arg("-t");
                cmd.arg("--");
                cmd.arg(h);
                cmd.arg(tmux_cmd);
                cmd
            }
        } else {
            let mut cmd = CommandBuilder::new("sh");
            cmd.args(["-c", tmux_cmd]);
            cmd
        };
        cmd.env("TERM", "xterm-256color");
        cmd.env("COLORTERM", "truecolor");

        let child_proc = match pair.slave.spawn_command(cmd) {
            Ok(child) => child,
            Err(err) => {
                eprintln!("omnimux: failed to spawn session: {err}");
                let msg = err.to_string().replace('\'', "");
                let mut fallback = CommandBuilder::new("sh");
                fallback.args([
                    "-c",
                    &format!("printf '%s\\n' 'omnimux: failed to start session: {msg}' >&2; exit 1"),
                ]);
                match pair.slave.spawn_command(fallback) {
                    Ok(child) => child,
                    Err(err2) => {
                        eprintln!("omnimux: fallback spawn also failed: {err2}");
                        return Self::failed_session(
                            host,
                            colors,
                            font_size,
                            &format!("spawn failed: {err2}"),
                            cx,
                        );
                    }
                }
            }
        };
        drop(pair.slave);

        let child = std::sync::Arc::new(std::sync::Mutex::new(child_proc));

        let reader = match pair.master.try_clone_reader() {
            Ok(reader) => reader,
            Err(err) => {
                eprintln!("omnimux: failed to clone PTY reader: {err}");
                return Self::failed_session(
                    host,
                    colors,
                    font_size,
                    &format!("PTY reader: {err}"),
                    cx,
                );
            }
        };
        let writer = match pair.master.take_writer() {
            Ok(writer) => writer,
            Err(err) => {
                eprintln!("omnimux: failed to take PTY writer: {err}");
                return Self::failed_session(
                    host,
                    colors,
                    font_size,
                    &format!("PTY writer: {err}"),
                    cx,
                );
            }
        };

        let master = std::sync::Arc::new(std::sync::Mutex::new(pair.master));

        let config = TerminalConfig {
            cols: 80,
            rows: 24,
            font_family: if cfg!(target_os = "macos") {
                "Menlo".into()
            } else {
                "monospace".into()
            },
            font_size,
            line_height_multiplier: 1.14,
            scrollback: 10000,
            padding: Edges::default(),
            colors,
            font_fallbacks: symbol_font_fallbacks(),
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
                    let mods = &ev.keystroke.modifiers;
                    let key = ev.keystroke.key.as_str();
                    if mods.platform {
                        return matches!(key, "=" | "+" | "-" | "0" | "c" | "v" | "f");
                    }
                    if mods.control {
                        if matches!(key, "=" | "+" | "-" | "0" | "f") {
                            return true;
                        }
                        if mods.shift && matches!(key, "c" | "v") && !cfg!(target_os = "macos") {
                            return true;
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
            reconnect_streak: 0,
            pending_reconnect_at: None,
        }
    }

    /// Session that shows an error message in the terminal instead of panicking.
    fn failed_session(
        host: Option<String>,
        colors: ColorPalette,
        font_size: Pixels,
        message: &str,
        cx: &mut Context<Self>,
    ) -> Self {
        let pty_system = NativePtySystem::default();
        let pair = pty_system
            .openpty(PtySize {
                rows: 24,
                cols: 80,
                pixel_width: 0,
                pixel_height: 0,
            })
            .expect("omnimux: cannot open fallback PTY");

        let msg = message.replace('\'', "");
        let mut cmd = CommandBuilder::new("sh");
        cmd.args([
            "-c",
            &format!("printf '%s\\n' 'omnimux: {msg}' >&2; sleep 1; exit 1"),
        ]);
        cmd.env("TERM", "xterm-256color");
        let child_proc = pair
            .slave
            .spawn_command(cmd)
            .expect("omnimux: cannot spawn fallback shell");

        drop(pair.slave);
        let child = std::sync::Arc::new(std::sync::Mutex::new(child_proc));
        let reader = pair.master.try_clone_reader().expect("fallback reader");
        let writer = pair.master.take_writer().expect("fallback writer");

        let config = TerminalConfig {
            cols: 80,
            rows: 24,
            font_family: "monospace".into(),
            font_size,
            line_height_multiplier: 1.14,
            scrollback: 1000,
            padding: Edges::default(),
            colors,
            font_fallbacks: symbol_font_fallbacks(),
        };

        let terminal_view =
            cx.new(|cx| TerminalView::new(writer, reader, config, cx));

        Self {
            terminal_view,
            child,
            has_exited: false,
            exit_status: None,
            host,
            wants_search: false,
            reconnect_streak: 0,
            pending_reconnect_at: None,
        }
    }

    pub fn check_exit(&mut self) {
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
                let paste = key == "v"
                    && (mods.platform || (mods.control && mods.shift && !cfg!(target_os = "macos")));
                if paste {
                    cx.stop_propagation();
                    if let Ok(mut clipboard) = Clipboard::new() {
                        if let Ok(text) = clipboard.paste() {
                            terminal_view.update(cx, |tv, _| {
                                tv.write_input(&text);
                            });
                        }
                    }
                    return;
                }
                let copy = key == "c"
                    && (mods.platform
                        || (mods.control && mods.shift && !cfg!(target_os = "macos")));
                if copy {
                    cx.stop_propagation();
                    terminal_view.update(cx, |tv, _| {
                        let _ = tv.copy_selection();
                    });
                    return;
                }
                if key == "=" || key == "+" || key == "-" || key == "0" {
                    cx.stop_propagation();
                }
            }))
            .child(self.terminal_view.clone())
    }
}
