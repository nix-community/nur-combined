//! Minimal terminal emulator application using gpui-terminal library.
//!
//! This example demonstrates how to embed a terminal in a GPUI application
//! using portable-pty for proper PTY support.

use anyhow::Result;
use gpui::{
    AppContext, Context, Edges, Entity, InteractiveElement, IntoElement, KeyDownEvent,
    ParentElement, Render, Styled, Window, div, px,
};
use gpui_terminal::{ColorPalette, TerminalConfig, TerminalView};
use portable_pty::{CommandBuilder, PtySize, native_pty_system};
use std::sync::Arc;

/// Wrapper view that holds the terminal and handles font size shortcuts.
struct TerminalApp {
    terminal: Entity<TerminalView>,
}

impl TerminalApp {
    fn new(terminal: Entity<TerminalView>) -> Self {
        Self { terminal }
    }

    fn on_key_down(&mut self, event: &KeyDownEvent, _window: &mut Window, cx: &mut Context<Self>) {
        let keystroke = &event.keystroke;

        // Check for Ctrl++ or Ctrl+= (increase font size)
        if keystroke.modifiers.control && (keystroke.key == "+" || keystroke.key == "=") {
            self.terminal.update(cx, |terminal, cx| {
                let mut config = terminal.config().clone();
                config.font_size += px(1.0);
                terminal.update_config(config, cx);
            });
            cx.stop_propagation();
        } else if keystroke.modifiers.control && keystroke.key == "-" {
            // Check for Ctrl+- (decrease font size)
            self.terminal.update(cx, |terminal, cx| {
                let mut config = terminal.config().clone();
                // Don't go below 6px font size
                if config.font_size > px(6.0) {
                    config.font_size -= px(1.0);
                    terminal.update_config(config, cx);
                }
            });
            cx.stop_propagation();
        }
    }
}

impl Render for TerminalApp {
    fn render(&mut self, _window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        div()
            .size_full()
            .on_key_down(cx.listener(Self::on_key_down))
            .child(self.terminal.clone())
    }
}

fn main() -> Result<()> {
    let app = gpui::Application::new();

    app.run(move |cx| {
        // Get shell from environment
        let shell = std::env::var("SHELL").unwrap_or_else(|_| "/bin/sh".to_string());

        // Create PTY system
        let pty_system = native_pty_system();

        // Open a PTY with initial size
        let pair = pty_system
            .openpty(PtySize {
                rows: 24,
                cols: 80,
                pixel_width: 0,
                pixel_height: 0,
            })
            .expect("Failed to open PTY");

        // Spawn shell in the PTY
        let mut cmd = CommandBuilder::new(&shell);
        cmd.env("TERM", "xterm-256color");
        cmd.env("COLORTERM", "truecolor");

        let _child = pair
            .slave
            .spawn_command(cmd)
            .expect("Failed to spawn shell");

        // Get the master PTY handles for I/O
        let writer = pair.master.take_writer().expect("Failed to get PTY writer");
        let reader = pair
            .master
            .try_clone_reader()
            .expect("Failed to get PTY reader");

        // Keep the master for resizing
        let pty_master = Arc::new(parking_lot::Mutex::new(pair.master));

        // Drop the slave - we don't need it anymore after spawning
        drop(pair.slave);

        // Spawn window creation on the main thread
        let pty_master_clone = pty_master.clone();
        cx.spawn(async move |cx| {
            let colors = ColorPalette::builder()
                .background(0x16, 0x16, 0x17)
                .foreground(0xC9, 0xC7, 0xCD)
                .cursor(0xC9, 0xC7, 0xCD)
                // Normal colors
                .black(0x10, 0x10, 0x10)
                .red(0xEF, 0xA6, 0xA2)
                .green(0x80, 0xC9, 0x90)
                .yellow(0xA6, 0x94, 0x60)
                .blue(0xA3, 0xB8, 0xEF)
                .magenta(0xE6, 0xA3, 0xDC)
                .cyan(0x50, 0xCA, 0xCD)
                .white(0x80, 0x80, 0x80)
                // Bright colors
                .bright_black(0x39, 0x41, 0x4E)
                .bright_red(0xE0, 0xAF, 0x85)
                .bright_green(0x5A, 0xCC, 0xAF)
                .bright_yellow(0xC8, 0xC8, 0x74)
                .bright_blue(0xCC, 0xAC, 0xED)
                .bright_magenta(0xF2, 0xA1, 0xC2)
                .bright_cyan(0x74, 0xC3, 0xE4)
                .bright_white(0xC0, 0xC0, 0xC0)
                .build();

            let config = TerminalConfig {
                font_family: "Mononoki Nerd Font".into(),
                font_size: px(14.0),
                cols: 80,
                rows: 24,
                scrollback: 10000,
                line_height_multiplier: 1.05,
                padding: Edges::all(px(8.0)),
                colors,
            };

            // Create resize callback that notifies the PTY
            let pty_for_resize = pty_master_clone.clone();
            let resize_callback = move |cols: usize, rows: usize| {
                if let Err(e) = pty_for_resize.lock().resize(PtySize {
                    cols: cols as u16,
                    rows: rows as u16,
                    pixel_width: 0,
                    pixel_height: 0,
                }) {
                    eprintln!("Failed to resize PTY: {}", e);
                }
            };

            cx.open_window(
                gpui::WindowOptions {
                    titlebar: Some(gpui::TitlebarOptions {
                        title: Some("gpui-terminal".into()),
                        ..Default::default()
                    }),
                    ..Default::default()
                },
                |window, cx| {
                    // Create the terminal view
                    let terminal = cx.new(|cx| {
                        TerminalView::new(writer, reader, config, cx)
                            .with_resize_callback(resize_callback)
                            .with_exit_callback(|_window, cx| {
                                cx.quit();
                            })
                    });

                    // Focus the terminal so it receives key events
                    terminal.read(cx).focus_handle().focus(window);

                    // Wrap in TerminalApp to handle font size shortcuts
                    cx.new(|_cx| TerminalApp::new(terminal))
                },
            )?;

            Ok::<_, anyhow::Error>(())
        })
        .detach();
    });

    Ok(())
}
