//! # gpui-terminal
//!
//! A terminal emulator component for embedding in [GPUI](https://gpui.rs) applications.
//!
//! This library provides [`TerminalView`], a complete terminal emulator that can be
//! embedded in any GPUI application. It uses [alacritty_terminal](https://docs.rs/alacritty_terminal)
//! for VTE parsing and terminal state management, providing a production-ready terminal
//! with full ANSI escape sequence support.
//!
//! ## Features
//!
//! - **Full Terminal Emulation**: VTE-compliant terminal powered by alacritty_terminal
//! - **Color Support**: 16 ANSI colors, 256-color mode, and 24-bit true color (RGB)
//! - **GPUI Integration**: Implements GPUI's `Render` trait for seamless embedding
//! - **Flexible I/O**: Accepts arbitrary [`std::io::Read`]/[`std::io::Write`] streams
//!   (works with any PTY implementation)
//! - **Customizable Colors**: Builder pattern for configuring the full color palette
//! - **Event Callbacks**: Hooks for resize, exit, bell, title changes, and clipboard operations
//! - **Keyboard Input**: Full keyboard support including control sequences, function keys,
//!   and application cursor mode
//! - **Push-based I/O**: Efficient async architecture that only wakes when data arrives
//!
//! ## Quick Start
//!
//! The terminal view accepts I/O streams rather than spawning processes directly.
//! This gives you full control over the PTY lifecycle. Here's a complete example
//! using [portable-pty](https://docs.rs/portable-pty):
//!
//! ```ignore
//! use gpui::{Application, Edges, px};
//! use gpui_terminal::{ColorPalette, TerminalConfig, TerminalView};
//! use portable_pty::{native_pty_system, CommandBuilder, PtySize};
//! use std::sync::Arc;
//!
//! fn main() {
//!     let app = Application::new();
//!     app.run(|cx| {
//!         // 1. Create PTY with initial dimensions
//!         let pty_system = native_pty_system();
//!         let pair = pty_system.openpty(PtySize {
//!             rows: 24,
//!             cols: 80,
//!             pixel_width: 0,
//!             pixel_height: 0,
//!         }).expect("Failed to open PTY");
//!
//!         // 2. Spawn shell in the PTY
//!         let shell = std::env::var("SHELL").unwrap_or_else(|_| "/bin/sh".into());
//!         let mut cmd = CommandBuilder::new(&shell);
//!         cmd.env("TERM", "xterm-256color");
//!         cmd.env("COLORTERM", "truecolor");
//!         let _child = pair.slave.spawn_command(cmd).expect("Failed to spawn shell");
//!
//!         // 3. Get I/O handles from the PTY master
//!         let writer = pair.master.take_writer().expect("Failed to get writer");
//!         let reader = pair.master.try_clone_reader().expect("Failed to get reader");
//!         let pty_master = Arc::new(parking_lot::Mutex::new(pair.master));
//!
//!         // 4. Create terminal configuration
//!         let config = TerminalConfig {
//!             font_family: "monospace".into(),
//!             font_size: px(14.0),
//!             cols: 80,
//!             rows: 24,
//!             scrollback: 10000,
//!             line_height_multiplier: 1.2,
//!             padding: Edges::all(px(8.0)),
//!             colors: ColorPalette::default(),
//!         };
//!
//!         // 5. Create resize callback to sync PTY dimensions
//!         let pty_for_resize = pty_master.clone();
//!         let resize_callback = move |cols: usize, rows: usize| {
//!             let _ = pty_for_resize.lock().resize(PtySize {
//!                 cols: cols as u16,
//!                 rows: rows as u16,
//!                 pixel_width: 0,
//!                 pixel_height: 0,
//!             });
//!         };
//!
//!         // 6. Open window with terminal
//!         cx.spawn(async move |cx| {
//!             cx.open_window(Default::default(), |window, cx| {
//!                 let terminal = cx.new(|cx| {
//!                     TerminalView::new(writer, reader, config, cx)
//!                         .with_resize_callback(resize_callback)
//!                         .with_exit_callback(|_, cx| cx.quit())
//!                 });
//!                 terminal.read(cx).focus_handle().focus(window);
//!                 terminal
//!             })
//!         }).detach();
//!     });
//! }
//! ```
//!
//! ## Architecture
//!
//! The library is organized around a few key components:
//!
//! ```text
//! ┌─────────────────────────────────────────────────────────────────┐
//! │                      Your GPUI Application                      │
//! └─────────────────────────────────────────────────────────────────┘
//!                                  │
//!                                  ▼
//! ┌─────────────────────────────────────────────────────────────────┐
//! │  TerminalView (GPUI Entity, implements Render)                  │
//! │  ├─ Keyboard/mouse event handling                               │
//! │  ├─ Callback dispatch (resize, exit, bell, title, clipboard)    │
//! │  └─ Canvas-based rendering                                      │
//! └─────────────────────────────────────────────────────────────────┘
//!         │                    │                      │
//!         ▼                    ▼                      ▼
//! ┌───────────────┐   ┌──────────────────┐   ┌────────────────────────┐
//! │ TerminalState │   │ TerminalRenderer │   │ I/O Pipeline           │
//! │ ├─ Term<>     │   │ ├─ Font metrics  │   │ ├─ Background thread   │
//! │ │  (alacritty)│   │ ├─ ColorPalette  │   │ │   reads from PTY     │
//! │ └─ VTE Parser │   │ └─ Text layout   │   │ ├─ Flume channel       │
//! └───────────────┘   └──────────────────┘   │ └─ Async task notifies │
//!                                            └────────────────────────┘
//! ```
//!
//! ### Data Flow
//!
//! 1. **Output from PTY**: A background thread reads bytes from the PTY stdout,
//!    sends them through a [flume](https://docs.rs/flume) channel to an async task,
//!    which processes them through the VTE parser and notifies GPUI to repaint.
//!
//! 2. **Input to PTY**: Keyboard events are converted to terminal escape sequences
//!    by the [`input`] module and written directly to the PTY stdin.
//!
//! 3. **Rendering**: On each paint, [`TerminalRenderer`] reads the terminal grid,
//!    batches cells with identical styling, and draws backgrounds, text, and cursor.
//!
//! ## Configuration
//!
//! ### Terminal Dimensions and Font
//!
//! Configure the terminal through [`TerminalConfig`]:
//!
//! ```ignore
//! use gpui::{Edges, px};
//! use gpui_terminal::{ColorPalette, TerminalConfig};
//!
//! let config = TerminalConfig {
//!     // Grid dimensions (characters)
//!     cols: 120,
//!     rows: 40,
//!
//!     // Font settings
//!     font_family: "JetBrains Mono".into(),
//!     font_size: px(13.0),
//!
//!     // Line height multiplier for tall glyphs (nerd fonts)
//!     line_height_multiplier: 1.2,
//!
//!     // Scrollback history (lines)
//!     scrollback: 10000,
//!
//!     // Padding around terminal content
//!     padding: Edges {
//!         top: px(4.0),
//!         right: px(8.0),
//!         bottom: px(4.0),
//!         left: px(8.0),
//!     },
//!
//!     // Color scheme
//!     colors: ColorPalette::default(),
//! };
//! ```
//!
//! ### Custom Color Palette
//!
//! Use [`ColorPalette::builder()`] to customize the terminal colors:
//!
//! ```
//! use gpui_terminal::ColorPalette;
//!
//! // Create a custom color scheme (Gruvbox-like)
//! let colors = ColorPalette::builder()
//!     // Background and foreground
//!     .background(0x28, 0x28, 0x28)
//!     .foreground(0xeb, 0xdb, 0xb2)
//!     .cursor(0xeb, 0xdb, 0xb2)
//!
//!     // Normal colors (0-7)
//!     .black(0x28, 0x28, 0x28)
//!     .red(0xcc, 0x24, 0x1d)
//!     .green(0x98, 0x97, 0x1a)
//!     .yellow(0xd7, 0x99, 0x21)
//!     .blue(0x45, 0x85, 0x88)
//!     .magenta(0xb1, 0x62, 0x86)
//!     .cyan(0x68, 0x9d, 0x6a)
//!     .white(0xa8, 0x99, 0x84)
//!
//!     // Bright colors (8-15)
//!     .bright_black(0x92, 0x83, 0x74)
//!     .bright_red(0xfb, 0x49, 0x34)
//!     .bright_green(0xb8, 0xbb, 0x26)
//!     .bright_yellow(0xfa, 0xbd, 0x2f)
//!     .bright_blue(0x83, 0xa5, 0x98)
//!     .bright_magenta(0xd3, 0x86, 0x9b)
//!     .bright_cyan(0x8e, 0xc0, 0x7c)
//!     .bright_white(0xeb, 0xdb, 0xb2)
//!     .build();
//! ```
//!
//! ## Event Handling
//!
//! The terminal provides several callback hooks for integration:
//!
//! ### Resize Callback
//!
//! **Essential** for proper terminal operation. Called when the terminal grid
//! dimensions change (e.g., when the window is resized):
//!
//! ```ignore
//! terminal.with_resize_callback(move |cols, rows| {
//!     // Notify your PTY about the new size
//!     pty.lock().resize(PtySize {
//!         cols: cols as u16,
//!         rows: rows as u16,
//!         pixel_width: 0,
//!         pixel_height: 0,
//!     }).ok();
//! })
//! ```
//!
//! ### Exit Callback
//!
//! Called when the terminal process exits:
//!
//! ```ignore
//! terminal.with_exit_callback(|window, cx| {
//!     // Close the window or show an exit message
//!     cx.quit();
//! })
//! ```
//!
//! ### Key Handler
//!
//! Intercept key events before the terminal processes them. Return `true` to
//! consume the event:
//!
//! ```ignore
//! terminal.with_key_handler(|event| {
//!     // Handle Ctrl++ to increase font size
//!     if event.keystroke.modifiers.control && event.keystroke.key == "+" {
//!         // Your font size logic here
//!         return true; // Consume the event
//!     }
//!     false // Let terminal handle it
//! })
//! ```
//!
//! ### Other Callbacks
//!
//! - **Bell**: `with_bell_callback` - Terminal bell (BEL character)
//! - **Title**: `with_title_callback` - Window title changes (OSC 0/2)
//! - **Clipboard**: `with_clipboard_store_callback` - Clipboard write requests (OSC 52)
//!
//! ## Dynamic Configuration
//!
//! Update terminal settings at runtime with [`TerminalView::update_config`]:
//!
//! ```ignore
//! terminal.update(cx, |terminal, cx| {
//!     let mut config = terminal.config().clone();
//!     config.font_size += px(2.0);  // Increase font size
//!     terminal.update_config(config, cx);
//! });
//! ```
//!
//! ## Feature Matrix
//!
//! | Feature | Status |
//! |---------|--------|
//! | Text rendering | ✅ Full support |
//! | Bold/italic/underline | ✅ Full support |
//! | 16 ANSI colors | ✅ Full support |
//! | 256-color mode | ✅ Full support |
//! | True color (24-bit) | ✅ Full support |
//! | Keyboard input | ✅ Full support |
//! | Application cursor mode | ✅ Full support |
//! | Function keys (F1-F12) | ✅ Full support |
//! | Mouse click reporting | 🔄 Partial (framework ready) |
//! | Mouse selection | 🔄 Planned |
//! | Scrollback | 🔄 Planned |
//! | Clipboard (OSC 52) | ✅ Callback support |
//! | Title changes (OSC 0/2) | ✅ Callback support |
//! | Bell (BEL) | ✅ Callback support |
//!
//! ## Platform Support
//!
//! - **Linux**: X11 and Wayland via GPUI's platform support
//! - **Clipboard**: Uses [arboard](https://docs.rs/arboard) with Wayland data-control
//!
//! ## Modules
//!
//! | Module | Description |
//! |--------|-------------|
//! | [`view`] | Main terminal view component ([`TerminalView`], [`TerminalConfig`]) |
//! | [`terminal`] | Terminal state wrapper ([`TerminalState`]) |
//! | [`colors`] | Color palette ([`ColorPalette`], [`ColorPaletteBuilder`]) |
//! | [`render`] | Text and background rendering ([`TerminalRenderer`]) |
//! | [`event`] | Event bridge ([`TerminalEvent`], [`GpuiEventProxy`]) |
//! | [`input`] | Keyboard to escape sequence conversion |
//! | [`mouse`] | Mouse event handling and reporting |
//! | [`clipboard`] | System clipboard integration ([`Clipboard`]) |
//!
//! ## Troubleshooting
//!
//! ### Terminal shows garbled text
//!
//! Ensure you set the `TERM` environment variable when spawning the shell:
//! ```ignore
//! cmd.env("TERM", "xterm-256color");
//! cmd.env("COLORTERM", "truecolor");
//! ```
//!
//! ### Colors don't display correctly
//!
//! Some applications check `COLORTERM=truecolor` for 24-bit color support.
//! Set both `TERM` and `COLORTERM` for best compatibility.
//!
//! ### Arrow keys don't work in vim/less
//!
//! The terminal automatically handles application cursor mode. Ensure your
//! resize callback is correctly notifying the PTY, as some applications
//! query terminal dimensions on startup.
//!
//! ### Font doesn't render correctly
//!
//! Use a monospace font. Nerd fonts work well with `line_height_multiplier: 1.2`
//! to accommodate tall glyphs.

pub mod clipboard;
pub mod colors;
pub mod event;
pub mod input;
pub mod mouse;
pub mod render;
pub mod terminal;
pub mod view;

// Re-export main types for convenience
pub use clipboard::Clipboard;
pub use colors::{ColorPalette, ColorPaletteBuilder};
pub use event::{GpuiEventProxy, TerminalEvent};
pub use render::TerminalRenderer;
pub use terminal::TerminalState;
pub use view::{
    BellCallback, ClipboardStoreCallback, ExitCallback, KeyHandler, ResizeCallback, TerminalConfig,
    TerminalView, TitleCallback,
};
