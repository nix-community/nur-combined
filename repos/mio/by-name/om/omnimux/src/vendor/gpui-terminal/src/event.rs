//! Event handling for the terminal emulator.
//!
//! Bridges alacritty's [`EventListener`] to a channel of [`TerminalEvent`]s consumed by
//! [`TerminalView`](crate::view::TerminalView). Host-bound replies (`PtyWrite`, color/size
//! queries, clipboard load) are forwarded so the UI can write them to the PTY.

use alacritty_terminal::event::{Event, EventListener, WindowSize};
use alacritty_terminal::vte::ansi::Rgb;
use std::fmt;
use std::sync::Arc;
use std::sync::mpsc::Sender;

/// Events emitted by the terminal that the GPUI application cares about.
#[derive(Clone)]
pub enum TerminalEvent {
    /// The terminal has new content to display and needs a redraw.
    Wakeup,

    /// The terminal bell was triggered (visual or audible alert).
    Bell,

    /// The terminal title has changed.
    Title(String),

    /// The terminal wants to store data to the clipboard (OSC 52).
    ClipboardStore(String),

    /// The terminal wants clipboard contents written back to the PTY (OSC 52).
    ClipboardLoad(Arc<dyn Fn(&str) -> String + Sync + Send + 'static>),

    /// Write an escape-sequence reply (DA, DSR, etc.) to the PTY.
    PtyWrite(String),

    /// Answer an OSC color query; formatter turns the resolved RGB into a reply.
    ColorRequest(usize, Arc<dyn Fn(Rgb) -> String + Sync + Send + 'static>),

    /// Answer a text-area size query.
    TextAreaSizeRequest(Arc<dyn Fn(WindowSize) -> String + Sync + Send + 'static>),

    /// The terminal process has exited.
    Exit,
}

impl fmt::Debug for TerminalEvent {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TerminalEvent::Wakeup => write!(f, "Wakeup"),
            TerminalEvent::Bell => write!(f, "Bell"),
            TerminalEvent::Title(t) => write!(f, "Title({t:?})"),
            TerminalEvent::ClipboardStore(t) => write!(f, "ClipboardStore({t:?})"),
            TerminalEvent::ClipboardLoad(_) => write!(f, "ClipboardLoad(..)"),
            TerminalEvent::PtyWrite(t) => write!(f, "PtyWrite({t:?})"),
            TerminalEvent::ColorRequest(i, _) => write!(f, "ColorRequest({i})"),
            TerminalEvent::TextAreaSizeRequest(_) => write!(f, "TextAreaSizeRequest(..)"),
            TerminalEvent::Exit => write!(f, "Exit"),
        }
    }
}

/// Forwards alacritty events to a channel consumed on the GPUI thread.
pub struct GpuiEventProxy {
    tx: Sender<TerminalEvent>,
}

impl GpuiEventProxy {
    pub fn new(tx: Sender<TerminalEvent>) -> Self {
        Self { tx }
    }

    fn send(&self, event: TerminalEvent) {
        let _ = self.tx.send(event);
    }
}

impl EventListener for GpuiEventProxy {
    fn send_event(&self, event: Event) {
        match event {
            Event::Wakeup => self.send(TerminalEvent::Wakeup),
            Event::Bell => self.send(TerminalEvent::Bell),
            Event::Title(title) => self.send(TerminalEvent::Title(title)),
            Event::ClipboardStore(_ty, data) => self.send(TerminalEvent::ClipboardStore(data)),
            Event::ClipboardLoad(_ty, format) => self.send(TerminalEvent::ClipboardLoad(format)),
            Event::PtyWrite(data) => self.send(TerminalEvent::PtyWrite(data)),
            Event::ColorRequest(index, format) => {
                self.send(TerminalEvent::ColorRequest(index, format))
            }
            Event::TextAreaSizeRequest(format) => {
                self.send(TerminalEvent::TextAreaSizeRequest(format))
            }
            Event::Exit | Event::ChildExit(_) => self.send(TerminalEvent::Exit),
            Event::ResetTitle => self.send(TerminalEvent::Title(String::new())),
            Event::MouseCursorDirty | Event::CursorBlinkingChange => {}
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::mpsc::channel;

    #[test]
    fn test_pty_write_forwarded() {
        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);
        proxy.send_event(Event::PtyWrite("\x1b[0c".into()));
        match rx.recv().unwrap() {
            TerminalEvent::PtyWrite(s) => assert_eq!(s, "\x1b[0c"),
            other => panic!("unexpected {other:?}"),
        }
    }

    #[test]
    fn test_ignored_events() {
        let (tx, rx) = channel();
        let proxy = GpuiEventProxy::new(tx);
        proxy.send_event(Event::MouseCursorDirty);
        proxy.send_event(Event::CursorBlinkingChange);
        assert!(rx.try_recv().is_err());
    }
}
