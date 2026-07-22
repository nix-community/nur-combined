use crate::palette::symbol_font_fallbacks;
use crate::tabs::TerminalTabs;
use gpui::prelude::*;
use gpui::*;
use gpui_terminal::{ColorPalette, Osc52Policy, TerminalConfig, TerminalView};
use portable_pty::{CommandBuilder, NativePtySystem, PtySize, PtySystem};
use std::time::Instant;

pub struct TerminalSession {
    pub terminal_view: Entity<TerminalView>,
    child: std::sync::Arc<std::sync::Mutex<Box<dyn portable_pty::Child + Send + Sync>>>,
    pub has_exited: bool,
    pub exit_status: Option<u32>,
    pub host: Option<String>,
    /// OSC 0/2 title from the remote (empty → fall back to host label).
    pub title: Option<String>,
    /// Visual bell until the tab is activated or receives focus.
    pub has_bell: bool,
    pub reconnect_streak: u32,
    pub pending_reconnect_at: Option<Instant>,
}

impl TerminalSession {
    pub fn new(
        host: Option<String>,
        colors: ColorPalette,
        font_size: Pixels,
        osc52: Osc52Policy,
        tabs: WeakEntity<TerminalTabs>,
        cx: &mut Context<Self>,
    ) -> Self {
        let session = cx.entity().downgrade();
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
                return Self::failed_session(
                    host,
                    colors,
                    font_size,
                    osc52,
                    tabs,
                    &format!("open PTY: {err}"),
                    cx,
                );
            }
        };

        // Prefer tmux when available; macOS GUI apps get a minimal PATH so include
        // Homebrew/MacPorts, and fall back to a login shell when tmux is missing.
        let tmux_cmd = r#"PATH="/opt/homebrew/bin:/usr/local/bin:/opt/local/bin:$PATH"
if command -v tmux >/dev/null 2>&1; then
  tmux -u has-session 2>/dev/null && exec tmux -u attach \; set -g mouse on || exec tmux -u new-session \; set -g mouse on
elif [ -n "${SHELL:-}" ] && [ -x "$SHELL" ]; then
  exec "$SHELL" -l
elif [ -x /bin/zsh ]; then
  exec /bin/zsh -l
elif [ -x /bin/bash ]; then
  exec /bin/bash -l
else
  exec /bin/sh
fi"#;

        let mut cmd = if let Some(ref h) = host {
            if !crate::hosts::is_safe_ssh_destination(h) {
                eprintln!("omnimux: rejected unsafe SSH destination: {h:?}");
                return Self::failed_session(
                    host,
                    colors,
                    font_size,
                    osc52,
                    tabs,
                    "unsafe SSH destination rejected",
                    cx,
                );
            }
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
                            osc52,
                            tabs,
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
                    osc52,
                    tabs,
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
                    osc52,
                    tabs,
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
            osc52,
        };

        let terminal_view = cx.new(|cx| {
            let master_clone = master.clone();
            let session = session.clone();
            let tabs = tabs.clone();
            Self::wire_view(
                TerminalView::new(writer, reader, config, cx).with_resize_callback(
                    move |cols, rows| {
                        if let Ok(master) = master_clone.lock() {
                            let _ = master.resize(PtySize {
                                cols: cols as u16,
                                rows: rows as u16,
                                pixel_width: 0,
                                pixel_height: 0,
                            });
                        }
                    },
                ),
                session,
                tabs,
            )
        });

        Self {
            terminal_view,
            child,
            has_exited: false,
            exit_status: None,
            host,
            title: None,
            has_bell: false,
            reconnect_streak: 0,
            pending_reconnect_at: None,
        }
    }

    fn wire_view(
        view: TerminalView,
        session: WeakEntity<Self>,
        tabs: WeakEntity<TerminalTabs>,
    ) -> TerminalView {
        let session_for_title = session.clone();
        let tabs_for_title = tabs.clone();
        let session_for_bell = session.clone();
        let tabs_for_bell = tabs.clone();
        let session_for_exit = session.clone();
        let tabs_for_exit = tabs.clone();
        let tabs_for_link = tabs.clone();
        let tabs_for_menu = tabs.clone();

        view.with_title_callback(move |_window, cx, title| {
            let title = title.to_string();
            let _ = session_for_title.update(cx, |session, cx| {
                session.title = if title.is_empty() {
                    None
                } else {
                    Some(title)
                };
                cx.notify();
            });
            let _ = tabs_for_title.update(cx, |_, cx| cx.notify());
        })
        .with_bell_callback(move |_window, cx| {
            let _ = session_for_bell.update(cx, |session, cx| {
                session.has_bell = true;
                cx.notify();
            });
            let _ = tabs_for_bell.update(cx, |_, cx| cx.notify());
        })
        .with_link_click_callback(move |window, cx, url| {
            let url = url.to_string();
            let _ = tabs_for_link.update(cx, |tabs, cx| {
                tabs.request_open_url(url, window, cx);
            });
        })
        .with_context_menu_callback(move |window, cx, position| {
            let _ = tabs_for_menu.update(cx, |tabs, cx| {
                tabs.show_terminal_context_menu(position, window, cx);
            });
        })
        .with_exit_callback(move |_window, cx| {
            let _ = session_for_exit.update(cx, |session, cx| {
                session.on_pty_exit(cx);
            });
            let _ = tabs_for_exit.update(cx, |tabs, cx| {
                tabs.on_session_exited(session.clone(), cx);
            });
        })
    }

    /// Label for the tab bar: optional bell + title or host.
    pub fn tab_label(&self) -> String {
        let base = self
            .title
            .as_deref()
            .map(str::trim)
            .filter(|t| !t.is_empty())
            .map(|t| truncate_chars(t, 28))
            .unwrap_or_else(|| {
                self.host
                    .clone()
                    .unwrap_or_else(|| "localhost".to_string())
            });
        if self.has_bell {
            format!("! {base}")
        } else {
            base
        }
    }

    pub fn clear_bell(&mut self, cx: &mut Context<Self>) {
        if self.has_bell {
            self.has_bell = false;
            cx.notify();
        }
    }

    fn failed_session(
        host: Option<String>,
        colors: ColorPalette,
        font_size: Pixels,
        osc52: Osc52Policy,
        tabs: WeakEntity<TerminalTabs>,
        message: &str,
        cx: &mut Context<Self>,
    ) -> Self {
        let session = cx.entity().downgrade();
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
            osc52,
        };

        let terminal_view = cx.new(|cx| {
            Self::wire_view(
                TerminalView::new(writer, reader, config, cx),
                session.clone(),
                tabs.clone(),
            )
        });

        Self {
            terminal_view,
            child,
            has_exited: false,
            exit_status: None,
            host,
            title: None,
            has_bell: false,
            reconnect_streak: 0,
            pending_reconnect_at: None,
        }
    }

    /// Kill the PTY child process (tab close, reconnect replacement).
    pub fn close(&mut self) {
        if let Ok(mut child) = self.child.lock() {
            let _ = child.kill();
        }
    }

    pub fn on_pty_exit(&mut self, cx: &mut Context<Self>) {
        if self.has_exited {
            return;
        }
        if let Ok(mut child) = self.child.lock() {
            match child.try_wait() {
                Ok(Some(status)) => {
                    self.has_exited = true;
                    self.exit_status = Some(status.exit_code() as u32);
                }
                Ok(None) => {
                    // PTY EOF can race slightly ahead of waitpid. Poll briefly
                    // without a blocking wait (must not stall the UI thread).
                    let mut code = None;
                    for _ in 0..20 {
                        std::thread::sleep(std::time::Duration::from_millis(1));
                        if let Ok(Some(status)) = child.try_wait() {
                            code = Some(status.exit_code() as u32);
                            break;
                        }
                    }
                    self.has_exited = true;
                    self.exit_status = Some(code.unwrap_or(255));
                }
                Err(_) => {
                    self.has_exited = true;
                    self.exit_status = Some(255);
                }
            }
        } else {
            self.has_exited = true;
            self.exit_status = Some(255);
        }
        if self.exit_status == Some(0) {
            self.reconnect_streak = 0;
            self.pending_reconnect_at = None;
        }
        cx.notify();
    }
}

impl Render for TerminalSession {
    fn render(&mut self, _window: &mut Window, _cx: &mut Context<Self>) -> impl IntoElement {
        div()
            .size_full()
            .key_context("omnimux_terminal")
            .child(self.terminal_view.clone())
    }
}

impl Drop for TerminalSession {
    fn drop(&mut self) {
        self.close();
    }
}

fn truncate_chars(s: &str, max: usize) -> String {
    let mut iter = s.chars();
    let truncated: String = iter.by_ref().take(max).collect();
    if iter.next().is_some() {
        format!("{truncated}…")
    } else {
        truncated
    }
}
