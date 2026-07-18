# gpui-terminal

A terminal emulator component for [GPUI](https://gpui.rs) applications. Uses [alacritty_terminal](https://docs.rs/alacritty_terminal) for VTE parsing.

<img width="1763" alt="Image" src="https://github.com/user-attachments/assets/713ed2b3-e08d-4ff5-8aeb-2d02660ecf7d" />

## Features

- Full ANSI escape sequence support
- 16 ANSI colors, 256-color mode, and 24-bit true color
- Bold, italic, and underline text styles
- Keyboard input with application cursor mode (vim/tmux compatible)
- Clipboard integration via OSC 52
- Dynamic configuration (font size, colors)
- Push-based async I/O
- Accepts any `Read`/`Write` streams (not tied to a specific PTY library)

## Usage

```rust
use gpui_terminal::{TerminalConfig, TerminalView, ColorPalette};

// Create terminal with PTY reader/writer
let terminal = cx.new(|cx| {
    TerminalView::new(pty_writer, pty_reader, config, cx)
        .with_resize_callback(|cols, rows| {
            // Notify PTY of size change
        })
        .with_exit_callback(|_window, cx| {
            cx.quit();
        })
});
```

See `src/main.rs` for a complete example using `portable-pty`.

## Configuration

```rust
let colors = ColorPalette::builder()
    .background(0x16, 0x16, 0x17)
    .foreground(0xC9, 0xC7, 0xCD)
    .cursor(0xC9, 0xC7, 0xCD)
    .black(0x10, 0x10, 0x10)
    // ... other colors
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
```

## Current Limitations

- Mouse text selection not yet implemented
- No scrollback navigation

## License

MIT OR Apache-2.0
