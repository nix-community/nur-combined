//! Main terminal view component for GPUI.
//!
//! This module provides [`TerminalView`], the primary component for embedding terminals
//! in GPUI applications. It manages:
//!
//! - **I/O Streams**: Accepts arbitrary [`Read`]/[`Write`]
//!   streams, allowing integration with any PTY implementation
//! - **Event Handling**: Keyboard and mouse input, with configurable callbacks
//! - **Rendering**: Efficient canvas-based rendering via [`TerminalRenderer`]
//! - **Configuration**: Font, colors, dimensions, and padding via [`TerminalConfig`]
//!
//! # Architecture
//!
//! The terminal uses a push-based async I/O architecture:
//!
//! 1. A background thread reads bytes from the PTY stdout in 4KB chunks
//! 2. Bytes are sent through a [flume](https://docs.rs/flume) channel to an async task
//! 3. The async task processes bytes through the VTE parser and calls `cx.notify()`
//! 4. GPUI repaints the terminal with the updated grid
//!
//! This approach ensures the terminal only wakes when data arrives, avoiding polling.
//!
//! # Thread Safety
//!
//! - [`TerminalView`] itself is not `Send` (it contains GPUI handles)
//! - The stdin writer is wrapped in `Arc<parking_lot::Mutex<>>` for thread-safe writes
//! - Callbacks ([`ResizeCallback`], [`KeyHandler`]) must be `Send + Sync`
//!
//! # Example
//!
//! ```ignore
//! use gpui::{Context, Edges, px};
//! use gpui_terminal::{ColorPalette, TerminalConfig, TerminalView};
//!
//! // In a GPUI window context:
//! let terminal = cx.new(|cx| {
//!     TerminalView::new(pty_writer, pty_reader, TerminalConfig::default(), cx)
//!         .with_resize_callback(move |cols, rows| {
//!             // Notify PTY of new dimensions
//!         })
//!         .with_exit_callback(|_, cx| {
//!             cx.quit();
//!         })
//! });
//!
//! // Focus the terminal to receive keyboard input
//! terminal.read(cx).focus_handle().focus(window);
//! ```

use crate::clipboard::Clipboard;
use crate::colors::ColorPalette;
use crate::event::{GpuiEventProxy, TerminalEvent};
use crate::ime::{ime_cursor_bounds, paint_marked_text, TerminalInputHandler};
use crate::input::keystroke_to_bytes;
use crate::mouse::{
    encode_modifiers, mouse_button_report, mouse_drag_report, pixel_to_cell, pixels_to_scroll_lines,
    scroll_report,
};
use crate::render::TerminalRenderer;
use crate::terminal::TerminalState;
use alacritty_terminal::event::WindowSize;
use alacritty_terminal::grid::{Dimensions, Scroll};
use alacritty_terminal::index::{Column, Line, Point as AlacPoint, Side};
use alacritty_terminal::selection::{Selection as AlacSelection, SelectionType as AlacSelectionType};
use alacritty_terminal::term::TermMode;
use alacritty_terminal::vte::ansi::Rgb;
use gpui::{Edges, *};
use std::io::{Read, Write};
use std::sync::Arc;
use std::sync::mpsc;
use std::thread;

/// Configuration for terminal creation and runtime updates.
///
/// This struct defines the terminal's appearance and behavior, including
/// grid dimensions, font settings, scrollback buffer, and color scheme.
///
/// # Default Values
///
/// | Field | Default |
/// |-------|---------|
/// | `cols` | 80 |
/// | `rows` | 24 |
/// | `font_family` | "monospace" |
/// | `font_size` | 14px |
/// | `scrollback` | 10000 |
/// | `line_height_multiplier` | 1.2 |
/// | `padding` | 0px all sides |
/// | `colors` | Default palette |
///
/// # Example
///
/// ```ignore
/// use gpui::{Edges, px};
/// use gpui_terminal::{ColorPalette, TerminalConfig};
///
/// let config = TerminalConfig {
///     cols: 120,
///     rows: 40,
///     font_family: "JetBrains Mono".into(),
///     font_size: px(13.0),
///     scrollback: 50000,
///     line_height_multiplier: 1.1,
///     padding: Edges::all(px(10.0)),
///     colors: ColorPalette::builder()
///         .background(0x1a, 0x1a, 0x1a)
///         .foreground(0xe0, 0xe0, 0xe0)
///         .build(),
/// };
/// ```
///
/// # Runtime Updates
///
/// Configuration can be updated at runtime via [`TerminalView::update_config`].
/// This is useful for implementing features like dynamic font sizing:
///
/// ```ignore
/// terminal.update(cx, |terminal, cx| {
///     let mut config = terminal.config().clone();
///     config.font_size += px(1.0);
///     terminal.update_config(config, cx);
/// });
/// ```
#[derive(Clone, Debug)]
pub struct TerminalConfig {
    /// Number of columns (character width) in the terminal
    pub cols: usize,

    /// Number of rows (lines) in the terminal
    pub rows: usize,

    /// Font family name (e.g., "Fira Code", "JetBrains Mono")
    pub font_family: String,

    /// Font size in pixels
    pub font_size: Pixels,

    /// Maximum number of scrollback lines to keep in history
    pub scrollback: usize,

    /// Multiplier for line height to accommodate tall glyphs (e.g., nerd fonts)
    /// Default is 1.2 (20% extra height)
    pub line_height_multiplier: f32,

    /// Padding around the terminal content (top, right, bottom, left)
    /// The padding area renders with the terminal's background color
    pub padding: Edges<Pixels>,

    /// Color palette for terminal colors (16 ANSI colors, 256 extended colors,
    /// foreground, background, and cursor colors)
    pub colors: ColorPalette,

    /// Font families tried when a glyph is missing from [`Self::font_family`]
    /// (e.g. Starship / Nerd Font symbols).
    pub font_fallbacks: Vec<String>,

    /// OSC 52 remote clipboard policy. Default [`Osc52Policy::Disabled`] so a
    /// compromised remote cannot silently overwrite or read the system clipboard.
    pub osc52: crate::terminal::Osc52Policy,
}

impl Default for TerminalConfig {
    fn default() -> Self {
        Self {
            cols: 80,
            rows: 24,
            font_family: "monospace".into(),
            font_size: px(14.0),
            scrollback: 10000,
            line_height_multiplier: 1.2,
            padding: Edges::all(px(0.0)),
            colors: ColorPalette::default(),
            font_fallbacks: vec![
                "Symbols Nerd Font Mono".into(),
                "Symbols Nerd Font".into(),
            ],
            osc52: crate::terminal::Osc52Policy::Disabled,
        }
    }
}

/// Callback type for PTY resize notifications.
///
/// This callback is invoked when the terminal grid dimensions change,
/// typically due to window resizing. The callback receives the new
/// column and row counts.
///
/// # Arguments
///
/// * `cols` - New number of columns (characters wide)
/// * `rows` - New number of rows (lines tall)
///
/// # Thread Safety
///
/// This callback must be `Send + Sync` as it may be called from the render thread.
///
/// # Example
///
/// ```ignore
/// use portable_pty::PtySize;
///
/// let pty = Arc::new(Mutex::new(pty_master));
/// let pty_clone = pty.clone();
///
/// terminal.with_resize_callback(move |cols, rows| {
///     pty_clone.lock().resize(PtySize {
///         cols: cols as u16,
///         rows: rows as u16,
///         pixel_width: 0,
///         pixel_height: 0,
///     }).ok();
/// });
/// ```
pub type ResizeCallback = Box<dyn Fn(usize, usize) + Send + Sync>;

/// Callback type for key event interception.
///
/// This callback is invoked before the terminal processes a key event,
/// allowing you to intercept and handle specific key combinations.
///
/// # Arguments
///
/// * `event` - The key down event from GPUI
///
/// # Returns
///
/// * `true` - Consume the event (terminal will not process it)
/// * `false` - Let the terminal handle the event normally
///
/// # Thread Safety
///
/// This callback must be `Send + Sync`.
///
/// # Example
///
/// ```ignore
/// terminal.with_key_handler(|event| {
///     let keystroke = &event.keystroke;
///
///     // Intercept Ctrl++ for font size increase
///     if keystroke.modifiers.control && (keystroke.key == "+" || keystroke.key == "=") {
///         // Handle font size increase
///         return true; // Consume the event
///     }
///
///     // Intercept Ctrl+- for font size decrease
///     if keystroke.modifiers.control && keystroke.key == "-" {
///         // Handle font size decrease
///         return true;
///     }
///
///     false // Let terminal handle all other keys
/// });
/// ```
pub type KeyHandler = Box<dyn Fn(&KeyDownEvent) -> bool + Send + Sync>;

/// Callback for terminal bell events.
///
/// This callback is invoked when the terminal bell is triggered (BEL character,
/// ASCII 0x07), allowing you to play a sound or show a visual indicator.
///
/// # Arguments
///
/// * `window` - The GPUI window
/// * `cx` - The context for the TerminalView
///
/// # Example
///
/// ```ignore
/// terminal.with_bell_callback(|window, cx| {
///     // Option 1: Visual bell (flash the window or show an indicator)
///     // Option 2: Play a sound
///     // Option 3: Notify the user via system notification
/// });
/// ```
pub type BellCallback = Box<dyn Fn(&mut Window, &mut Context<TerminalView>)>;

/// Callback for terminal title changes.
///
/// This callback is invoked when the terminal title changes via escape sequences
/// (OSC 0, OSC 2), allowing you to update the window or tab title.
///
/// # Arguments
///
/// * `window` - The GPUI window
/// * `cx` - The context for the TerminalView
/// * `title` - The new title string
///
/// # Example
///
/// ```ignore
/// terminal.with_title_callback(|window, cx, title| {
///     // Update the window title
///     // Or update a tab label in a tabbed interface
///     println!("Terminal title changed to: {}", title);
/// });
/// ```
pub type TitleCallback = Box<dyn Fn(&mut Window, &mut Context<TerminalView>, &str)>;

/// Callback for clipboard store requests.
///
/// This callback is invoked when the terminal wants to store data to the clipboard
/// via OSC 52 escape sequence. Applications like tmux and vim can use this to
/// copy text to the system clipboard.
///
/// # Arguments
///
/// * `window` - The GPUI window
/// * `cx` - The context for the TerminalView
/// * `text` - The text to store in the clipboard
///
/// # Example
///
/// ```ignore
/// use gpui_terminal::Clipboard;
///
/// terminal.with_clipboard_store_callback(|window, cx, text| {
///     if let Ok(mut clipboard) = Clipboard::new() {
///         clipboard.copy(text).ok();
///     }
/// });
/// ```
pub type ClipboardStoreCallback = Box<dyn Fn(&mut Window, &mut Context<TerminalView>, &str)>;

/// Callback for Cmd/Ctrl+click on a URL (OSC 8 or plain `http(s)://` text).
pub type LinkClickCallback = Box<dyn Fn(&mut Window, &mut Context<TerminalView>, &str)>;

/// Callback for terminal exit events.
///
/// This callback is invoked when the terminal process exits (e.g., shell exits,
/// process terminates). This is detected when the PTY reader reaches EOF.
///
/// # Arguments
///
/// * `window` - The GPUI window
/// * `cx` - The context for the TerminalView
///
/// # Example
///
/// ```ignore
/// terminal.with_exit_callback(|window, cx| {
///     // Option 1: Quit the application
///     cx.quit();
///
///     // Option 2: Close this terminal tab/pane
///     // terminal_manager.close_terminal(terminal_id);
///
///     // Option 3: Show an exit message
///     // show_notification("Terminal exited");
/// });
/// ```
pub type ExitCallback = Box<dyn Fn(&mut Window, &mut Context<TerminalView>)>;

/// The main terminal view component for GPUI applications.
///
/// `TerminalView` is a GPUI entity that implements the [`Render`] trait,
/// providing a complete terminal emulator that can be embedded in any GPUI application.
///
/// # Responsibilities
///
/// - **Terminal State**: Manages the grid, cursor, and colors via [`TerminalState`]
/// - **I/O Streams**: Reads from PTY stdout and writes to PTY stdin
/// - **Event Handling**: Processes keyboard, mouse, and resize events
/// - **Rendering**: Paints text, backgrounds, and cursor via [`TerminalRenderer`]
/// - **Callbacks**: Dispatches events to user-provided callbacks
///
/// # Creating a Terminal
///
/// Use [`TerminalView::new`] within a GPUI entity context:
///
/// ```ignore
/// let terminal = cx.new(|cx| {
///     TerminalView::new(writer, reader, config, cx)
///         .with_resize_callback(resize_callback)
///         .with_exit_callback(|_, cx| cx.quit())
/// });
/// ```
///
/// # Focus
///
/// The terminal must be focused to receive keyboard input:
///
/// ```ignore
/// terminal.read(cx).focus_handle().focus(window);
/// ```
///
/// # Callbacks
///
/// Configure behavior through builder methods:
///
/// - [`with_resize_callback`](Self::with_resize_callback) - PTY size changes
/// - [`with_exit_callback`](Self::with_exit_callback) - Process exit
/// - [`with_key_handler`](Self::with_key_handler) - Key event interception
/// - [`with_bell_callback`](Self::with_bell_callback) - Terminal bell
/// - [`with_title_callback`](Self::with_title_callback) - Title changes
/// - [`with_clipboard_store_callback`](Self::with_clipboard_store_callback) - Clipboard writes
///
/// # Thread Safety
///
/// `TerminalView` is not `Send` as it contains GPUI handles. The stdin writer
/// is internally wrapped in `Arc<parking_lot::Mutex<>>` for safe concurrent access.
pub struct TerminalView {
    /// The terminal state managing the grid and VTE parser
    state: TerminalState,

    /// The renderer for drawing terminal content
    renderer: TerminalRenderer,

    /// Focus handle for keyboard event handling
    focus_handle: FocusHandle,

    /// Writer for sending input to the terminal process
    stdin_writer: Arc<parking_lot::Mutex<Box<dyn Write + Send>>>,

    /// Receiver for terminal events from the event proxy
    event_rx: mpsc::Receiver<TerminalEvent>,

    /// Configuration used to create this terminal
    config: TerminalConfig,

    /// Async task that reads bytes and notifies the view (push-based)
    #[allow(dead_code)]
    _reader_task: Task<()>,

    /// Callback to notify the PTY about size changes
    resize_callback: Option<Arc<ResizeCallback>>,

    /// Optional callback to intercept key events before terminal processing
    key_handler: Option<Arc<KeyHandler>>,

    /// Callback for terminal bell events
    bell_callback: Option<BellCallback>,

    /// Callback for terminal title changes
    title_callback: Option<TitleCallback>,

    /// Callback for clipboard store requests
    clipboard_store_callback: Option<ClipboardStoreCallback>,

    /// Callback for Cmd/Ctrl+click URLs
    link_click_callback: Option<LinkClickCallback>,

    /// Callback for terminal exit events
    exit_callback: Option<ExitCallback>,

    /// Inclusive start/end of the active search match (grid coordinates), if any
    search_highlight: Option<(alacritty_terminal::index::Point, alacritty_terminal::index::Point)>,

    /// Button currently held for mouse reporting / drag (viewport cell coords).
    mouse_pressed: Option<(MouseButton, AlacPoint)>,

    /// Last cell reported during drag (avoid flooding the PTY).
    last_mouse_cell: Option<AlacPoint>,

    /// True while Shift (or no mouse-mode) drag is building a local selection.
    selecting: bool,

    /// Last laid-out content hit-test geometry (window coords + cell metrics from paint).
    /// Kept in sync during canvas layout so mouse→cell mapping matches what was drawn —
    /// important under Wayland fractional scaling (e.g. Plasma 225%).
    hit_test: Arc<parking_lot::Mutex<TerminalHitTest>>,

    /// IME pre-edit (composing) state for CJK and similar input methods.
    ime_state: Option<crate::ime::ImeState>,
}

/// Geometry used to map window-space mouse positions to terminal cells.
#[derive(Clone, Copy, Debug)]
struct TerminalHitTest {
    /// Top-left of cell (0,0) in window coordinates (includes padding).
    content_origin: Point<Pixels>,
    cell_width: Pixels,
    cell_height: Pixels,
    cols: usize,
    rows: usize,
}

impl Default for TerminalHitTest {
    fn default() -> Self {
        Self {
            content_origin: Point::default(),
            cell_width: px(8.0),
            cell_height: px(16.0),
            cols: 1,
            rows: 1,
        }
    }
}

impl TerminalView {
    /// Create a new terminal with provided I/O streams.
    ///
    /// This method initializes a new terminal emulator with the given stdin writer
    /// and stdout reader. It spawns a background task to read from stdout and
    /// process incoming bytes through the VTE parser.
    ///
    /// # Arguments
    ///
    /// * `stdin_writer` - Writer for sending input bytes to the terminal process
    /// * `stdout_reader` - Reader for receiving output bytes from the terminal process
    /// * `config` - Terminal configuration (dimensions, font, etc.)
    /// * `cx` - GPUI context for this view
    ///
    /// # Returns
    ///
    /// A new `TerminalView` instance ready to be rendered.
    ///
    /// # Examples
    ///
    /// ```ignore
    /// // In a GPUI window context:
    /// let terminal = cx.new(|cx| {
    ///     TerminalView::new(stdin_writer, stdout_reader, TerminalConfig::default(), cx)
    /// });
    /// ```
    pub fn new<W, R>(
        stdin_writer: W,
        stdout_reader: R,
        config: TerminalConfig,
        cx: &mut Context<Self>,
    ) -> Self
    where
        W: Write + Send + 'static,
        R: Read + Send + 'static,
    {
        // Create event channel for terminal events
        let (event_tx, event_rx) = mpsc::channel();

        // Clone event_tx for the reader task to send Exit event when PTY closes
        let exit_event_tx = event_tx.clone();

        // Create event proxy for alacritty
        let event_proxy = GpuiEventProxy::new(event_tx);

        // Create terminal state with configured scrollback / OSC 52 policy
        let state = TerminalState::new_with_scrollback(
            config.cols,
            config.rows,
            config.scrollback,
            config.osc52,
            event_proxy,
        );

        // Create renderer with font settings and color palette
        let mut renderer = TerminalRenderer::new(
            config.font_family.clone(),
            config.font_size,
            config.line_height_multiplier,
            config.colors.clone(),
        );
        renderer.font_fallbacks = config.font_fallbacks.clone();

        // Create focus handle
        let focus_handle = cx.focus_handle();

        // Wrap stdin writer in Arc<Mutex> for thread-safe access
        let stdin_writer = Arc::new(parking_lot::Mutex::new(
            Box::new(stdin_writer) as Box<dyn Write + Send>
        ));

        // Create async channel for bytes (push-based notification)
        // Using flume instead of smol::channel because flume is executor-agnostic
        // and properly wakes GPUI's async executor when data arrives
        let (bytes_tx, bytes_rx) = flume::unbounded::<Vec<u8>>();

        // Spawn background thread to read from stdout
        // This thread sends bytes through the async channel
        thread::spawn(move || {
            Self::read_stdout_blocking(stdout_reader, bytes_tx);
        });

        // Spawn async task that awaits on the channel and notifies the view
        // This is push-based: the task blocks until bytes arrive, then immediately notifies
        let reader_task = cx.spawn(async move |this: WeakEntity<Self>, cx: &mut AsyncApp| {
            loop {
                // Wait for bytes from the background reader (blocks until data arrives)
                match bytes_rx.recv_async().await {
                    Ok(bytes) => {
                        // Process bytes and notify the view
                        let result = this.update(cx, |view: &mut Self, cx: &mut Context<Self>| {
                            view.state.process_bytes(&bytes);
                            cx.notify();
                        });
                        if result.is_err() {
                            // View was dropped, exit
                            break;
                        }
                    }
                    Err(_) => {
                        // Channel closed - PTY has finished, send Exit event
                        let _ = exit_event_tx.send(TerminalEvent::Exit);
                        // Notify view to process the Exit event
                        let _ = this.update(cx, |_view, cx: &mut Context<Self>| {
                            cx.notify();
                        });
                        break;
                    }
                }
            }
        });

        Self {
            state,
            renderer,
            focus_handle,
            stdin_writer,
            event_rx,
            config,
            _reader_task: reader_task,
            resize_callback: None,
            key_handler: None,
            bell_callback: None,
            title_callback: None,
            clipboard_store_callback: None,
            link_click_callback: None,
            exit_callback: None,
            search_highlight: None,
            mouse_pressed: None,
            last_mouse_cell: None,
            selecting: false,
            hit_test: Arc::new(parking_lot::Mutex::new(TerminalHitTest::default())),
            ime_state: None,
        }
    }

    /// Cell width in pixels (for IME candidate positioning).
    pub(crate) fn cell_width(&self) -> Pixels {
        self.renderer.cell_width
    }

    /// UTF-16 range of the marked text for the platform IME.
    pub(crate) fn marked_text_range(&self) -> Option<std::ops::Range<usize>> {
        self.ime_state.as_ref().map(|state| {
            0..state.marked_text.encode_utf16().count()
        })
    }

    /// Set IME pre-edit text (composing).
    pub(crate) fn set_marked_text(&mut self, text: String, cx: &mut Context<Self>) {
        if text.is_empty() {
            self.clear_marked_text(cx);
            return;
        }
        self.ime_state = Some(crate::ime::ImeState { marked_text: text });
        cx.notify();
    }

    /// Clear IME pre-edit state.
    pub(crate) fn clear_marked_text(&mut self, cx: &mut Context<Self>) {
        if self.ime_state.is_some() {
            self.ime_state = None;
            cx.notify();
        }
    }

    /// Commit composed IME text to the PTY.
    pub(crate) fn commit_ime_text(&mut self, text: &str) {
        if !text.is_empty() {
            self.write_pty_str(text);
        }
    }

    /// Set a callback to be invoked when the terminal is resized.
    ///
    /// This callback should resize the underlying PTY to match the new dimensions.
    /// The callback receives (cols, rows) as arguments.
    ///
    /// # Arguments
    ///
    /// * `callback` - A function that will be called with (cols, rows) on resize
    pub fn with_resize_callback(
        mut self,
        callback: impl Fn(usize, usize) + Send + Sync + 'static,
    ) -> Self {
        self.resize_callback = Some(Arc::new(Box::new(callback)));
        self
    }

    /// Set a callback to intercept key events before terminal processing.
    ///
    /// The callback receives the key event and should return `true` to consume
    /// the event (prevent the terminal from processing it), or `false` to allow
    /// normal terminal processing.
    ///
    /// # Arguments
    ///
    /// * `handler` - A function that receives key events and returns whether to consume them
    ///
    /// # Example
    ///
    /// ```ignore
    /// terminal.with_key_handler(|event| {
    ///     // Handle Ctrl++ to increase font size
    ///     if event.keystroke.modifiers.control && event.keystroke.key == "+" {
    ///         // Handle the event
    ///         return true; // Consume the event
    ///     }
    ///     false // Let terminal handle it
    /// })
    /// ```
    pub fn with_key_handler(
        mut self,
        handler: impl Fn(&KeyDownEvent) -> bool + Send + Sync + 'static,
    ) -> Self {
        self.key_handler = Some(Arc::new(Box::new(handler)));
        self
    }

    /// Set a callback to be invoked when the terminal bell is triggered.
    ///
    /// The callback receives a mutable reference to the window and context,
    /// allowing you to play a sound or show a visual indicator.
    ///
    /// # Arguments
    ///
    /// * `callback` - A function that will be called when the bell is triggered
    ///
    /// # Example
    ///
    /// ```ignore
    /// terminal.with_bell_callback(|window, cx| {
    ///     // Play a sound or flash the screen
    /// })
    /// ```
    pub fn with_bell_callback(
        mut self,
        callback: impl Fn(&mut Window, &mut Context<TerminalView>) + 'static,
    ) -> Self {
        self.bell_callback = Some(Box::new(callback));
        self
    }

    /// Set a callback to be invoked when the terminal title changes.
    ///
    /// The callback receives a mutable reference to the window and context,
    /// along with the new title string.
    ///
    /// # Arguments
    ///
    /// * `callback` - A function that will be called with the new title
    ///
    /// # Example
    ///
    /// ```ignore
    /// terminal.with_title_callback(|window, cx, title| {
    ///     // Update window title or tab title
    /// })
    /// ```
    pub fn with_title_callback(
        mut self,
        callback: impl Fn(&mut Window, &mut Context<TerminalView>, &str) + 'static,
    ) -> Self {
        self.title_callback = Some(Box::new(callback));
        self
    }

    /// Set a callback to be invoked when the terminal wants to store data to the clipboard.
    ///
    /// The callback receives a mutable reference to the window and context,
    /// along with the text to store. This is typically triggered by OSC 52 escape sequences.
    ///
    /// # Arguments
    ///
    /// * `callback` - A function that will be called with the text to store
    ///
    /// # Example
    ///
    /// ```ignore
    /// terminal.with_clipboard_store_callback(|window, cx, text| {
    ///     // Store text to system clipboard
    /// })
    /// ```
    pub fn with_clipboard_store_callback(
        mut self,
        callback: impl Fn(&mut Window, &mut Context<TerminalView>, &str) + 'static,
    ) -> Self {
        self.clipboard_store_callback = Some(Box::new(callback));
        self
    }

    /// Cmd/Ctrl+click URL handler (OSC 8 or plain http(s) text).
    pub fn with_link_click_callback(
        mut self,
        callback: impl Fn(&mut Window, &mut Context<TerminalView>, &str) + 'static,
    ) -> Self {
        self.link_click_callback = Some(Box::new(callback));
        self
    }

    /// Set a callback to be invoked when the terminal process exits.
    ///
    /// The callback receives a mutable reference to the window and context,
    /// allowing you to close the terminal view or show an exit message.
    ///
    /// # Arguments
    ///
    /// * `callback` - A function that will be called when the process exits
    ///
    /// # Example
    ///
    /// ```ignore
    /// terminal.with_exit_callback(|window, cx| {
    ///     // Close the terminal tab or show exit message
    /// })
    /// ```
    pub fn with_exit_callback(
        mut self,
        callback: impl Fn(&mut Window, &mut Context<TerminalView>) + 'static,
    ) -> Self {
        self.exit_callback = Some(Box::new(callback));
        self
    }

    /// Background thread that reads from stdout.
    ///
    /// This function runs in a background thread, continuously reading bytes
    /// from the stdout reader and sending them through the async channel.
    /// The async channel allows the main async task to be woken up immediately
    /// when data arrives (push-based).
    fn read_stdout_blocking<R: Read + Send + 'static>(
        mut stdout_reader: R,
        bytes_tx: flume::Sender<Vec<u8>>,
    ) {
        let mut buffer = [0u8; 4096];

        loop {
            match stdout_reader.read(&mut buffer) {
                Ok(0) => {
                    // EOF - channel will be dropped, signaling completion
                    break;
                }
                Ok(n) => {
                    // Send bytes to the async task
                    let bytes = buffer[..n].to_vec();
                    if bytes_tx.send(bytes).is_err() {
                        break; // Channel closed
                    }
                }
                Err(_) => {
                    // Read error
                    break;
                }
            }
        }
    }

    /// Handle keyboard input events.
    ///
    /// Converts GPUI keystrokes to terminal escape sequences and writes them
    /// to the stdin writer. If a key handler is set and returns true, the event
    /// is consumed and not sent to the terminal.
    fn on_key_down(&mut self, event: &KeyDownEvent, _window: &mut Window, cx: &mut Context<Self>) {
        // Check if key handler wants to consume this event
        if let Some(ref handler) = self.key_handler
            && handler(event)
        {
            // Match Zed terminal_view: stop so Wayland does not also deliver
            // key_char via InputHandler (would double-insert into the PTY).
            cx.stop_propagation();
            return;
        }

        if let Some(bytes) = keystroke_to_bytes(&event.keystroke, self.state.mode()) {
            let mut writer = self.stdin_writer.lock();
            let _ = writer.write_all(&bytes);
            let _ = writer.flush();
            cx.stop_propagation();
        }
    }

    /// Handle mouse down events — focus + SGR mouse reports when enabled.
    ///
    /// Holding Shift (or when the app has not enabled mouse reporting) selects
    /// text locally instead of forwarding to the PTY (e.g. tmux).
    fn on_mouse_down(
        &mut self,
        event: &MouseDownEvent,
        window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        window.focus(&self.focus_handle);

        // Cmd (macOS) / Ctrl (Linux) + left click → open URL when a handler is set.
        let link_modifier = if cfg!(target_os = "macos") {
            event.modifiers.platform
        } else {
            event.modifiers.control || event.modifiers.platform
        };
        if event.button == MouseButton::Left && link_modifier {
            if let Some(ref callback) = self.link_click_callback {
                let viewport = self.viewport_cell_at(event.position);
                let grid_point = self.viewport_to_grid(viewport);
                if let Some(url) = self.state.with_term(|term| {
                    crate::links::find_url_at_point(term, grid_point)
                }) {
                    if crate::links::is_browser_url(&url) {
                        callback(window, cx, &url);
                        cx.notify();
                        return;
                    }
                }
            }
        }

        let viewport = self.viewport_cell_at(event.position);
        let mode = self.state.mode();
        let mouse_reporting = mode.intersects(
            TermMode::MOUSE_REPORT_CLICK | TermMode::MOUSE_MOTION | TermMode::MOUSE_DRAG,
        );
        // Shift always selects locally; without mouse mode, clicks also select.
        let local_select = event.button == MouseButton::Left
            && (event.modifiers.shift || !mouse_reporting);

        if local_select {
            let grid_point = self.viewport_to_grid(viewport);
            let ty = match event.click_count {
                0 | 1 => AlacSelectionType::Simple,
                2 => AlacSelectionType::Semantic,
                _ => AlacSelectionType::Lines,
            };
            self.state.with_term_mut(|term| {
                let mut sel = AlacSelection::new(ty, grid_point, Side::Left);
                if matches!(ty, AlacSelectionType::Semantic | AlacSelectionType::Lines) {
                    sel.update(grid_point, Side::Right);
                    sel.include_all();
                }
                term.selection = Some(sel);
            });
            self.selecting = true;
            self.mouse_pressed = None;
            self.last_mouse_cell = None;
            cx.notify();
            return;
        }

        // Clear local selection when interacting with the app/mouse mode.
        if event.button == MouseButton::Left {
            self.state.with_term_mut(|term| term.selection = None);
            self.selecting = false;
        }

        // Never forward Shift+mouse to the PTY.
        if event.modifiers.shift {
            cx.notify();
            return;
        }

        let modifiers = encode_modifiers(
            false, // shift never reported (we gate above)
            event.modifiers.alt,
            event.modifiers.control,
        );

        if let Some(bytes) = mouse_button_report(event.button, true, viewport, modifiers, mode) {
            let mut writer = self.stdin_writer.lock();
            let _ = writer.write_all(&bytes);
            let _ = writer.flush();
            self.mouse_pressed = Some((event.button, viewport));
            self.last_mouse_cell = Some(viewport);
        }

        cx.notify();
    }

    /// Handle mouse up events — finish local selection or SGR release.
    fn on_mouse_up(
        &mut self,
        event: &MouseUpEvent,
        _window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        if self.selecting {
            let viewport = self.viewport_cell_at(event.position);
            let grid_point = self.viewport_to_grid(viewport);
            self.state.with_term_mut(|term| {
                if let Some(sel) = term.selection.as_mut() {
                    sel.update(grid_point, Side::Right);
                }
            });
            self.selecting = false;
            cx.notify();
            return;
        }

        if event.modifiers.shift {
            self.mouse_pressed = None;
            self.last_mouse_cell = None;
            return;
        }

        let point = self.viewport_cell_at(event.position);
        let mode = self.state.mode();
        let modifiers = encode_modifiers(
            false,
            event.modifiers.alt,
            event.modifiers.control,
        );

        if let Some(bytes) = mouse_button_report(event.button, false, point, modifiers, mode) {
            let mut writer = self.stdin_writer.lock();
            let _ = writer.write_all(&bytes);
            let _ = writer.flush();
        }
        self.mouse_pressed = None;
        self.last_mouse_cell = None;
    }

    /// Handle mouse move — extend local selection or SGR drag reports.
    fn on_mouse_move(
        &mut self,
        event: &MouseMoveEvent,
        _window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        let viewport = self.viewport_cell_at(event.position);

        if self.selecting {
            let grid_point = self.viewport_to_grid(viewport);
            self.state.with_term_mut(|term| {
                if let Some(sel) = term.selection.as_mut() {
                    sel.update(grid_point, Side::Right);
                }
            });
            cx.notify();
            return;
        }

        let Some((button, _)) = self.mouse_pressed else {
            return;
        };
        if event.modifiers.shift {
            return;
        }
        if self.last_mouse_cell == Some(viewport) {
            return;
        }
        let mode = self.state.mode();
        let modifiers = encode_modifiers(
            false,
            event.modifiers.alt,
            event.modifiers.control,
        );
        if let Some(bytes) = mouse_drag_report(button, viewport, modifiers, mode) {
            let mut writer = self.stdin_writer.lock();
            let _ = writer.write_all(&bytes);
            let _ = writer.flush();
            self.last_mouse_cell = Some(viewport);
        }
    }

    /// Convert a window-space mouse position to a clamped viewport cell.
    ///
    /// Uses the last paint-time [`TerminalHitTest`] so cell size / origin match
    /// what was drawn (critical on HiDPI / fractional Wayland scales).
    fn viewport_cell_at(&self, window_pos: Point<Pixels>) -> AlacPoint {
        let hit = *self.hit_test.lock();
        let raw = pixel_to_cell(
            window_pos,
            hit.content_origin,
            hit.cell_width,
            hit.cell_height,
        );
        let col = raw.column.0.min(hit.cols.saturating_sub(1));
        let row = raw.line.0.clamp(0, hit.rows.saturating_sub(1) as i32);
        AlacPoint::new(Line(row), Column(col))
    }

    /// Map a viewport cell (from [`pixel_to_cell`]) to an absolute grid point.
    fn viewport_to_grid(&self, viewport: AlacPoint) -> AlacPoint {
        self.state.with_term(|term| {
            let cols = term.columns().max(1);
            let rows = term.screen_lines().max(1);
            let col = Column(viewport.column.0.min(cols - 1));
            let row = (viewport.line.0.max(0) as usize).min(rows.saturating_sub(1));
            alacritty_terminal::term::viewport_to_point(
                term.grid().display_offset(),
                alacritty_terminal::index::Point::new(row, col),
            )
        })
    }

    fn write_pty_str(&self, data: &str) {
        let mut writer = self.stdin_writer.lock();
        let _ = writer.write_all(data.as_bytes());
        let _ = writer.flush();
    }

    /// Write raw text to the PTY (e.g. clipboard paste).
    ///
    /// When the application has bracketed paste enabled, wraps the payload in
    /// `\e[200~` … `\e[201~` and strips any embedded end-bracket sequences so a
    /// malicious clipboard cannot terminate the bracket early.
    pub fn write_input(&self, data: &str) {
        let bracketed = self
            .state
            .mode()
            .contains(alacritty_terminal::term::TermMode::BRACKETED_PASTE);
        if bracketed {
            let sanitized = data.replace("\x1b[201~", "");
            self.write_pty_str(&format!("\x1b[200~{sanitized}\x1b[201~"));
        } else {
            self.write_pty_str(data);
        }
    }

    /// Maximum decoded OSC 52 clipboard payload accepted when store is enabled.
    const OSC52_MAX_BYTES: usize = 1024 * 1024;

    /// Copy the current selection to the system clipboard.
    ///
    /// Returns `true` if there was a non-empty selection to copy.
    pub fn copy_selection(&self) -> bool {
        let text = self
            .state
            .with_term(|term| term.selection_to_string())
            .filter(|s| !s.is_empty());
        let Some(text) = text else {
            return false;
        };
        if let Ok(mut clipboard) = Clipboard::new() {
            return clipboard.copy(&text).is_ok();
        }
        false
    }

    /// Process pending terminal events.
    ///
    /// This method drains all available events from the event receiver
    /// and handles them appropriately. Note: bytes are processed in the
    /// async reader task, not here.
    fn process_events(&mut self, window: &mut Window, cx: &mut Context<Self>) {
        // Process terminal events (from alacritty event proxy)
        while let Ok(event) = self.event_rx.try_recv() {
            match event {
                TerminalEvent::Wakeup => {}
                TerminalEvent::Bell => {
                    if let Some(ref callback) = self.bell_callback {
                        callback(window, cx);
                    }
                }
                TerminalEvent::Title(title) => {
                    if let Some(ref callback) = self.title_callback {
                        callback(window, cx, &title);
                    }
                }
                TerminalEvent::ClipboardStore(text) => {
                    if text.len() > Self::OSC52_MAX_BYTES {
                        eprintln!(
                            "gpui-terminal: ignoring oversized OSC 52 store ({} bytes)",
                            text.len()
                        );
                        continue;
                    }
                    match self.config.osc52 {
                        crate::terminal::Osc52Policy::OnlyCopy
                        | crate::terminal::Osc52Policy::CopyPaste => {
                            if let Some(ref callback) = self.clipboard_store_callback {
                                callback(window, cx, &text);
                            } else if let Ok(mut clipboard) = Clipboard::new() {
                                let _ = clipboard.copy(&text);
                            }
                        }
                        crate::terminal::Osc52Policy::Disabled
                        | crate::terminal::Osc52Policy::OnlyPaste => {}
                    }
                }
                TerminalEvent::ClipboardLoad(format) => {
                    match self.config.osc52 {
                        crate::terminal::Osc52Policy::OnlyPaste
                        | crate::terminal::Osc52Policy::CopyPaste => {
                            if let Ok(mut clipboard) = Clipboard::new() {
                                if let Ok(text) = clipboard.paste() {
                                    let capped = if text.len() > Self::OSC52_MAX_BYTES {
                                        &text[..Self::OSC52_MAX_BYTES]
                                    } else {
                                        text.as_str()
                                    };
                                    self.write_pty_str(&format(capped));
                                }
                            }
                        }
                        crate::terminal::Osc52Policy::Disabled
                        | crate::terminal::Osc52Policy::OnlyCopy => {}
                    }
                }
                TerminalEvent::PtyWrite(data) => {
                    self.write_pty_str(&data);
                }
                TerminalEvent::ColorRequest(index, format) => {
                    let rgb = self.state.with_term(|term| {
                        term.colors()[index].unwrap_or(Rgb {
                            r: 0,
                            g: 0,
                            b: 0,
                        })
                    });
                    self.write_pty_str(&format(rgb));
                }
                TerminalEvent::TextAreaSizeRequest(format) => {
                    let cell_w: f32 = self.renderer.cell_width.into();
                    let cell_h: f32 = self.renderer.cell_height.into();
                    let size = WindowSize {
                        num_lines: self.state.rows() as u16,
                        num_cols: self.state.cols() as u16,
                        cell_width: cell_w.round().max(1.0) as u16,
                        cell_height: cell_h.round().max(1.0) as u16,
                    };
                    self.write_pty_str(&format(size));
                }
                TerminalEvent::Exit => {
                    if let Some(ref callback) = self.exit_callback {
                        callback(window, cx);
                    }
                }
            }
        }
    }

    /// Handle scroll events.
    ///
    /// When the application has mouse reporting enabled (e.g. tmux with
    /// `mouse on`), wheel events are forwarded as SGR mouse reports.
    /// On the alternate screen without mouse mode, they become arrow keys.
    /// Otherwise we scroll local scrollback.
    fn on_scroll(
        &mut self,
        event: &ScrollWheelEvent,
        _window: &mut Window,
        cx: &mut Context<Self>,
    ) {
        let cell_height = self.renderer.cell_height;
        let pixel_delta = match event.delta {
            ScrollDelta::Pixels(p) => p.y,
            ScrollDelta::Lines(l) => cell_height * l.y,
        };
        // GPUI (macOS NSEvent / X11 / Wayland): positive Y = scroll up.
        // alacritty Scroll::Delta and SGR wheel (64) also use positive = up.
        let lines = pixels_to_scroll_lines(pixel_delta, cell_height);
        if lines == 0 {
            return;
        }

        let point = self.viewport_cell_at(event.position);
        let mode = self.state.mode();
        let mouse_reporting = mode.intersects(
            TermMode::MOUSE_REPORT_CLICK | TermMode::MOUSE_MOTION | TermMode::MOUSE_DRAG,
        );

        // Shift+wheel: never forward to the app/tmux — scroll local history.
        if event.modifiers.shift {
            self.state.with_term_mut(|term| {
                term.scroll_display(Scroll::Delta(lines));
            });
            cx.notify();
            return;
        }

        if !mouse_reporting {
            if let Some(bytes) = scroll_report(lines, point, 0, mode) {
                let mut writer = self.stdin_writer.lock();
                let _ = writer.write_all(&bytes);
                let _ = writer.flush();
            } else {
                self.state.with_term_mut(|term| {
                    term.scroll_display(Scroll::Delta(lines));
                });
                cx.notify();
            }
            return;
        }

        let modifiers = encode_modifiers(
            false,
            event.modifiers.alt,
            event.modifiers.control,
        );

        // One SGR wheel event per line when mouse reporting is on
        let step = if lines > 0 { 1 } else { -1 };
        let mut writer = self.stdin_writer.lock();
        for _ in 0..lines.abs() {
            if let Some(bytes) = scroll_report(step, point, modifiers, mode) {
                let _ = writer.write_all(&bytes);
            }
        }
        let _ = writer.flush();
    }

    /// Get the current terminal dimensions.
    ///
    /// # Returns
    ///
    /// A tuple of (columns, rows).
    pub fn dimensions(&self) -> (usize, usize) {
        (self.state.cols(), self.state.rows())
    }

    /// Resize the terminal to new dimensions.
    ///
    /// This method should be called when the terminal view size changes.
    /// It updates the internal grid and notifies the terminal process of the new size.
    ///
    /// # Arguments
    ///
    /// * `cols` - New number of columns
    /// * `rows` - New number of rows
    pub fn resize(&mut self, cols: usize, rows: usize) {
        self.state.resize(cols, rows);
    }

    /// Get the current terminal configuration.
    ///
    /// # Returns
    ///
    /// A reference to the current configuration.
    pub fn config(&self) -> &TerminalConfig {
        &self.config
    }

    /// Get the focus handle for this terminal view.
    ///
    /// # Returns
    ///
    /// A reference to the focus handle.
    pub fn focus_handle(&self) -> &FocusHandle {
        &self.focus_handle
    }

    /// Clear the active search highlight.
    pub fn clear_search(&mut self, cx: &mut Context<Self>) {
        self.search_highlight = None;
        cx.notify();
    }

    /// Search for `query` in the terminal buffer.
    ///
    /// When `forward` is true, finds the next match after the current highlight
    /// (or from the cursor). When false, searches backward. Scrolls the match
    /// into view and highlights it.
    ///
    /// Returns `true` if a match was found.
    pub fn search(&mut self, query: &str, forward: bool, cx: &mut Context<Self>) -> bool {
        if query.is_empty() {
            self.search_highlight = None;
            cx.notify();
            return false;
        }

        let pattern = escape_regex_literal(query);
        let Ok(mut regex) = alacritty_terminal::term::search::RegexSearch::new(&pattern) else {
            self.search_highlight = None;
            cx.notify();
            return false;
        };

        use alacritty_terminal::index::{Direction, Point, Side};
        use alacritty_terminal::grid::Dimensions;

        let direction = if forward {
            Direction::Right
        } else {
            Direction::Left
        };
        let side = if forward {
            Side::Right
        } else {
            Side::Left
        };

        let origin = match self.search_highlight {
            Some((_, end)) if forward => end,
            Some((start, _)) if !forward => start,
            _ => self.state.with_term(|term| term.grid().cursor.point),
        };

        let found = self.state.with_term_mut(|term| {
            let m = term
                .search_next(&mut regex, origin, direction, side, None)
                .or_else(|| {
                    let wrap_origin = if forward {
                        Point::new(term.topmost_line(), alacritty_terminal::index::Column(0))
                    } else {
                        Point::new(term.bottommost_line(), term.last_column())
                    };
                    term.search_next(&mut regex, wrap_origin, direction, side, None)
                });

            if let Some(m) = m {
                let start = *m.start();
                let end = *m.end();
                term.scroll_to_point(start);
                Some((start, end))
            } else {
                None
            }
        });

        self.search_highlight = found;
        cx.notify();
        self.search_highlight.is_some()
    }

    /// Update the terminal configuration.
    ///
    /// This method updates the terminal's configuration, including font settings,
    /// padding, and color palette. Changes take effect on the next render.
    ///
    /// # Arguments
    ///
    /// * `config` - The new configuration to apply
    /// * `cx` - The context for triggering a repaint
    pub fn update_config(&mut self, config: TerminalConfig, cx: &mut Context<Self>) {
        // Only push OSC 52 / scrollback into alacritty when they change. Calling
        // `set_options` on every font/theme update would reset unrelated Term
        // options and re-emit title events.
        if config.osc52 != self.config.osc52 || config.scrollback != self.config.scrollback {
            let scrolling_history = config.scrollback;
            let osc52 = config.osc52;
            self.state.with_term_mut(|term| {
                term.set_options(alacritty_terminal::term::Config {
                    scrolling_history,
                    osc52: osc52.into(),
                    ..alacritty_terminal::term::Config::default()
                });
            });
        }

        // Update renderer with new font settings and palette
        self.renderer.font_family = config.font_family.clone();
        self.renderer.font_fallbacks = config.font_fallbacks.clone();
        self.renderer.font_size = config.font_size;
        self.renderer.line_height_multiplier = config.line_height_multiplier;
        self.renderer.palette = config.colors.clone();

        // Store the new config
        self.config = config;

        // Trigger a repaint - cell dimensions will be recalculated via measure_cell()
        cx.notify();
    }

    /// Calculate terminal dimensions from pixel bounds and cell size.
    ///
    /// Helper method to determine how many columns and rows fit in the given bounds.
    #[allow(dead_code)]
    fn calculate_dimensions(&self, bounds: Bounds<Pixels>) -> (usize, usize) {
        let width_f32: f32 = bounds.size.width.into();
        let height_f32: f32 = bounds.size.height.into();
        let cell_width_f32: f32 = self.renderer.cell_width.into();
        let cell_height_f32: f32 = self.renderer.cell_height.into();

        let cols = ((width_f32 / cell_width_f32) as usize).max(1);
        let rows = ((height_f32 / cell_height_f32) as usize).max(1);
        (cols, rows)
    }
}

impl Render for TerminalView {
    fn render(&mut self, window: &mut Window, cx: &mut Context<Self>) -> impl IntoElement {
        // Process any pending events
        self.process_events(window, cx);

        // Keep cell metrics in sync so scroll/mouse use the same sizes as paint
        self.renderer.measure_cell(window);

        // Get terminal state and renderer for rendering
        let state_arc = self.state.term_arc();
        let renderer = self.renderer.clone();
        let resize_callback = self.resize_callback.clone();
        let padding = self.config.padding;
        let search_highlight = self.search_highlight;
        let bg = self.config.colors.background();
        let hit_test = self.hit_test.clone();
        let view_entity = cx.entity().clone();
        let focus_handle = self.focus_handle.clone();
        let font_family = self.config.font_family.clone();
        let font_size = self.config.font_size;
        let line_height = self.renderer.cell_height;
        let fg = self.config.colors.foreground();
        let marked_text = self
            .ime_state
            .as_ref()
            .map(|s| s.marked_text.clone())
            .unwrap_or_default();

        div()
            .size_full()
            .bg(bg)
            .key_context("omnimux_terminal")
            .track_focus(&self.focus_handle)
            .on_key_down(cx.listener(Self::on_key_down))
            .on_mouse_down(MouseButton::Left, cx.listener(Self::on_mouse_down))
            .on_mouse_down(MouseButton::Middle, cx.listener(Self::on_mouse_down))
            .on_mouse_down(MouseButton::Right, cx.listener(Self::on_mouse_down))
            .on_mouse_up(MouseButton::Left, cx.listener(Self::on_mouse_up))
            .on_mouse_up(MouseButton::Middle, cx.listener(Self::on_mouse_up))
            .on_mouse_up(MouseButton::Right, cx.listener(Self::on_mouse_up))
            .on_mouse_move(cx.listener(Self::on_mouse_move))
            .on_scroll_wheel(cx.listener(Self::on_scroll))
            .child(
                canvas(
                    move |bounds, _window, _cx| bounds,
                    move |bounds, _, window, cx| {
                        use alacritty_terminal::grid::Dimensions;

                        // Measure actual cell dimensions from the font
                        let mut measured_renderer = renderer.clone();
                        measured_renderer.measure_cell(window);

                        // Calculate available space after padding
                        let available_width: f32 =
                            (bounds.size.width - padding.left - padding.right).into();
                        let available_height: f32 =
                            (bounds.size.height - padding.top - padding.bottom).into();
                        let cell_width_f32: f32 = measured_renderer.cell_width.into();
                        let cell_height_f32: f32 = measured_renderer.cell_height.into();

                        // Match Zed: next_up before floor so f32 noise under fractional
                        // scaling does not drop the last row/column.
                        let cols = if cell_width_f32 > 0.0 {
                            (available_width / cell_width_f32)
                                .next_up()
                                .floor()
                                .max(1.0) as usize
                        } else {
                            1
                        };
                        let rows = if cell_height_f32 > 0.0 {
                            (available_height / cell_height_f32)
                                .next_up()
                                .floor()
                                .max(1.0) as usize
                        } else {
                            1
                        };

                        // Publish hit-test geometry matching this paint.
                        *hit_test.lock() = TerminalHitTest {
                            content_origin: Point::new(
                                bounds.origin.x + padding.left,
                                bounds.origin.y + padding.top,
                            ),
                            cell_width: measured_renderer.cell_width,
                            cell_height: measured_renderer.cell_height,
                            cols,
                            rows,
                        };

                        // Helper struct implementing Dimensions for resize
                        struct TermSize {
                            cols: usize,
                            rows: usize,
                        }
                        impl Dimensions for TermSize {
                            fn total_lines(&self) -> usize {
                                self.rows
                            }
                            fn screen_lines(&self) -> usize {
                                self.rows
                            }
                            fn columns(&self) -> usize {
                                self.cols
                            }
                            fn last_column(&self) -> alacritty_terminal::index::Column {
                                alacritty_terminal::index::Column(self.cols.saturating_sub(1))
                            }
                            fn bottommost_line(&self) -> alacritty_terminal::index::Line {
                                alacritty_terminal::index::Line(self.rows as i32 - 1)
                            }
                            fn topmost_line(&self) -> alacritty_terminal::index::Line {
                                alacritty_terminal::index::Line(0)
                            }
                        }

                        // Resize terminal if dimensions changed
                        let mut term = state_arc.lock();
                        let current_cols = term.columns();
                        let current_rows = term.screen_lines();
                        if cols != current_cols || rows != current_rows {
                            // Notify the PTY about the resize
                            if let Some(ref callback) = resize_callback {
                                callback(cols, rows);
                            }
                            term.resize(TermSize { cols, rows });
                        }

                        // Paint the terminal with measured dimensions
                        measured_renderer.paint(
                            bounds,
                            padding,
                            &term,
                            search_highlight,
                            window,
                            cx,
                        );

                        // Register IME input handler at the cursor cell (CJK, compose, etc.)
                        let cursor_bounds = ime_cursor_bounds(
                            bounds,
                            padding,
                            measured_renderer.cell_width,
                            measured_renderer.cell_height,
                            &term,
                        );
                        window.handle_input(
                            &focus_handle,
                            TerminalInputHandler {
                                terminal_view: view_entity.clone(),
                                cursor_bounds,
                            },
                            cx,
                        );

                        // Draw IME pre-edit text over the terminal at the cursor
                        if !marked_text.is_empty() {
                            if let Some(cb) = ime_cursor_bounds(
                                bounds,
                                padding,
                                measured_renderer.cell_width,
                                measured_renderer.cell_height,
                                &term,
                            ) {
                                paint_marked_text(
                                    &marked_text,
                                    cb,
                                    bg,
                                    fg,
                                    &font_family,
                                    font_size,
                                    line_height,
                                    window,
                                    cx,
                                );
                            }
                        }
                    },
                )
                .size_full(),
            )
    }
}

/// Escape regex metacharacters so the user's query is treated as a literal.
fn escape_regex_literal(s: &str) -> String {
    let mut out = String::with_capacity(s.len() * 2);
    for c in s.chars() {
        if matches!(
            c,
            '\\' | '.' | '+' | '*' | '?' | '(' | ')' | '[' | ']' | '{' | '}' | '|' | '^' | '$'
        ) {
            out.push('\\');
        }
        out.push(c);
    }
    out
}

// Tests are omitted due to macro expansion issues with the test attribute
// in this configuration. Integration tests can be added separately.
