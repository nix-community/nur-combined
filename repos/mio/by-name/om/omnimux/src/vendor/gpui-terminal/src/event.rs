//! Event handling for the terminal emulator.
//!
//! This module bridges alacritty's event system with GPUI by providing
//! [`GpuiEventProxy`], which implements alacritty's [`EventListener`] trait
//! and forwards relevant events through a channel.
//!
//! # Event Flow
//!
//! ```text
//! alacritty Term → GpuiEventProxy → mpsc channel → TerminalView
//!                        │
//!                        └─ Translates Event enum to TerminalEvent
//! ```
//!
//! # Supported Events
//!
//! | Alacritty Event | TerminalEvent | Description |
//! |-----------------|---------------|-------------|
//! | `Event::Wakeup` | `Wakeup` | Terminal has new content |
//! | `Event::Bell` | `Bell` | BEL character received |
//! | `Event::Title(_)` | `Title(String)` | Title escape sequence (OSC 0/2) |
//! | `Event::ClipboardStore(_, _)` | `ClipboardStore(String)` | Copy request (OSC 52) |
//! | `Event::ClipboardLoad(_, _)` | `ClipboardLoad` | Paste request |
//! | `Event::Exit` | `Exit` | Terminal exited |
//! | `Event::ChildExit(_)` | `Exit` | Child process exited |
//! | `Event::ResetTitle` | `Title("")` | Reset to empty title |
//!
//! Events like `MouseCursorDirty`, `PtyWrite`, and `CursorBlinkingChange` are
//! ignored as they're handled internally or not needed for GPUI integration.
//!
//! # Example
//!
//! ```
//! use std::sync::mpsc::channel;
//! use gpui_terminal::event::{GpuiEventProxy, TerminalEvent};
//!
//! let (tx, rx) = channel();
//! let proxy = GpuiEventProxy::new(tx);
//!
//! // The proxy is passed to alacritty's Term and will forward events
//! // Events can be received on the other end of the channel
//! ```
//!
//! [`EventListener`]: alacritty_terminal::event::EventListener

use alacritty_terminal::event::{Event, EventListener};
use std::sync::mpsc::Sender;

/// Events emitted by the terminal that the GPUI application cares about.
///
/// This enum represents a subset of alacritty's events that are relevant
/// for the GPUI terminal emulator implementation.
#[derive(Debug, Clone)]
pub enum TerminalEvent {
    /// The terminal has new content to display and needs a redraw.
    Wakeup,

    /// The terminal bell was triggered (visual or audible alert).
    Bell,

    /// The terminal title has changed.
    Title(String),

    /// The terminal wants to store data to the clipboard.
    ClipboardStore(String),

    /// The terminal wants to load data from the clipboard.
    ClipboardLoad,

    /// The terminal process has exited.
    Exit,
}

/// An event proxy that implements alacritty's EventListener trait.
///
/// This struct forwards relevant terminal events to a channel that can be
/// consumed by the GPUI application on the main thread.
pub struct GpuiEventProxy {
    /// Channel sender for forwarding events to the GPUI application.
    tx: Sender<TerminalEvent>,
}

impl GpuiEventProxy {
    /// Creates a new event proxy with the given channel sender.
    ///
    /// # Arguments
    ///
    /// * `tx` - The channel sender to forward events through
    ///
    /// # Returns
    ///
    /// A new GpuiEventProxy instance
    ///
    /// # Examples
    ///
    /// ```
    /// use std::sync::mpsc::channel;
    /// use gpui_terminal::event::GpuiEventProxy;
    ///
    /// let (tx, rx) = channel();
    /// let proxy = GpuiEventProxy::new(tx);
    /// ```
    pub fn new(tx: Sender<TerminalEvent>) -> Self {
        Self { tx }
    }

    /// Sends a terminal event through the channel.
    ///
    /// If the channel is disconnected, this method will silently drop the event.
    /// This can happen if the GPUI application has been shut down.
    fn send(&self, event: TerminalEvent) {
        // Ignore send errors - they just mean the receiver has been dropped
        let _ = self.tx.send(event);
    }
}

impl EventListener for GpuiEventProxy {
    /// Handles events from the alacritty terminal.
    ///
    /// This method is called by alacritty when terminal events occur.
    /// It translates alacritty's Event enum to our TerminalEvent enum
    /// and forwards relevant events through the channel.
    fn send_event(&self, event: Event) {
        match event {
            Event::Wakeup => {
                self.send(TerminalEvent::Wakeup);
            }
            Event::Bell => {
                self.send(TerminalEvent::Bell);
            }
            Event::Title(title) => {
                self.send(TerminalEvent::Title(title));
            }
            Event::ClipboardStore(_clipboard_type, data) => {
                // For simplicity, we ignore the clipboard type and just store the data
                self.send(TerminalEvent::ClipboardStore(data));
            }
            Event::ClipboardLoad(_clipboard_type, _format) => {
                // For simplicity, we ignore the clipboard type and format
                self.send(TerminalEvent::ClipboardLoad);
            }
            Event::Exit => {
                self.send(TerminalEvent::Exit);
            }
            // Ignore events we don't care about
            Event::MouseCursorDirty => {}
            Event::PtyWrite(ref _data) => {
                // This is handled internally by alacritty
            }
            Event::ColorRequest(ref _index, ref _format) => {
                // Color requests are not commonly used
            }
            Event::TextAreaSizeRequest(ref _format) => {
                // Text area size requests are handled internally
            }
            Event::CursorBlinkingChange => {
                // Cursor blinking changes could be handled if needed
            }
            Event::ResetTitle => {
                // Reset title to default - we can treat this as an empty title
                self.send(TerminalEvent::Title(String::new()));
            }
            Event::ChildExit(_exit_code) => {
                // Child process exited - treat this as a terminal exit
                self.send(TerminalEvent::Exit);
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::mpsc::channel;

    #[test]
    fn test_event_proxy_creation() {
        let (tx, _rx) = channel();
        let _proxy = GpuiEventProxy::new(tx);
    }

    #[test]
    fn test_wakeup_event() {
        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);

        proxy.send_event(Event::Wakeup);

        let event = rx.recv().unwrap();
        assert!(matches!(event, TerminalEvent::Wakeup));
    }

    #[test]
    fn test_bell_event() {
        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);

        proxy.send_event(Event::Bell);

        let event = rx.recv().unwrap();
        assert!(matches!(event, TerminalEvent::Bell));
    }

    #[test]
    fn test_title_event() {
        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);

        proxy.send_event(Event::Title("Test Title".to_string()));

        let event = rx.recv().unwrap();
        match event {
            TerminalEvent::Title(title) => assert_eq!(title, "Test Title"),
            _ => panic!("Expected Title event"),
        }
    }

    #[test]
    fn test_clipboard_store_event() {
        use alacritty_terminal::term::ClipboardType;

        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);

        proxy.send_event(Event::ClipboardStore(
            ClipboardType::Clipboard,
            "clipboard data".to_string(),
        ));

        let event = rx.recv().unwrap();
        match event {
            TerminalEvent::ClipboardStore(data) => assert_eq!(data, "clipboard data"),
            _ => panic!("Expected ClipboardStore event"),
        }
    }

    #[test]
    fn test_clipboard_load_event() {
        use alacritty_terminal::term::ClipboardType;
        use std::sync::Arc;

        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);

        // ClipboardLoad requires a callback function
        let callback = Arc::new(|s: &str| s.to_string());
        proxy.send_event(Event::ClipboardLoad(ClipboardType::Clipboard, callback));

        let event = rx.recv().unwrap();
        assert!(matches!(event, TerminalEvent::ClipboardLoad));
    }

    #[test]
    fn test_exit_event() {
        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);

        proxy.send_event(Event::Exit);

        let event = rx.recv().unwrap();
        assert!(matches!(event, TerminalEvent::Exit));
    }

    #[test]
    fn test_reset_title_event() {
        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);

        proxy.send_event(Event::ResetTitle);

        let event = rx.recv().unwrap();
        match event {
            TerminalEvent::Title(title) => assert!(title.is_empty()),
            _ => panic!("Expected Title event"),
        }
    }

    #[test]
    fn test_ignored_events() {
        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);

        // These events should be ignored and not sent through the channel
        proxy.send_event(Event::MouseCursorDirty);
        proxy.send_event(Event::CursorBlinkingChange);

        // The channel should be empty
        assert!(rx.try_recv().is_err());
    }

    #[test]
    fn test_disconnected_channel() {
        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);

        // Drop the receiver to disconnect the channel
        drop(rx);

        // Sending should not panic even though the channel is disconnected
        proxy.send_event(Event::Wakeup);
    }
}
