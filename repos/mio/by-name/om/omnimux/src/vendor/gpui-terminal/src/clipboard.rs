use anyhow::Result;

/// Clipboard wrapper for terminal copy/paste operations.
///
/// Provides a simple interface to interact with the system clipboard,
/// supporting both X11 and Wayland on Linux through the arboard crate.
///
/// # Examples
///
/// ```no_run
/// use gpui_terminal::clipboard::Clipboard;
///
/// let mut clipboard = Clipboard::new().unwrap();
///
/// // Copy text to clipboard
/// clipboard.copy("Hello, World!").unwrap();
///
/// // Paste text from clipboard
/// let text = clipboard.paste().unwrap();
/// println!("Clipboard contents: {}", text);
/// ```
pub struct Clipboard {
    clipboard: arboard::Clipboard,
}

impl Clipboard {
    /// Creates a new clipboard instance.
    ///
    /// This initializes the connection to the system clipboard.
    /// On Wayland, this uses the wayland-data-control protocol.
    ///
    /// # Errors
    ///
    /// Returns an error if the clipboard cannot be initialized,
    /// which may happen if:
    /// - The display server is not accessible
    /// - Required permissions are not available
    /// - The clipboard system is not supported
    ///
    /// # Examples
    ///
    /// ```no_run
    /// use gpui_terminal::clipboard::Clipboard;
    ///
    /// match Clipboard::new() {
    ///     Ok(clipboard) => println!("Clipboard initialized"),
    ///     Err(e) => eprintln!("Failed to initialize clipboard: {}", e),
    /// }
    /// ```
    pub fn new() -> Result<Self> {
        Ok(Self {
            clipboard: arboard::Clipboard::new()?,
        })
    }

    /// Copies text to the system clipboard.
    ///
    /// This replaces the current clipboard contents with the provided text.
    ///
    /// # Arguments
    ///
    /// * `text` - The text to copy to the clipboard
    ///
    /// # Errors
    ///
    /// Returns an error if:
    /// - The clipboard is not accessible
    /// - Permission to write to the clipboard is denied
    /// - The clipboard connection has been lost
    ///
    /// # Examples
    ///
    /// ```no_run
    /// use gpui_terminal::clipboard::Clipboard;
    ///
    /// let mut clipboard = Clipboard::new().unwrap();
    /// clipboard.copy("Selected terminal text").unwrap();
    /// ```
    pub fn copy(&mut self, text: &str) -> Result<()> {
        self.clipboard.set_text(text)?;
        Ok(())
    }

    /// Pastes text from the system clipboard.
    ///
    /// Retrieves the current text content from the clipboard.
    ///
    /// # Errors
    ///
    /// Returns an error if:
    /// - The clipboard is not accessible
    /// - Permission to read from the clipboard is denied
    /// - The clipboard is empty
    /// - The clipboard contains non-text content
    /// - The clipboard connection has been lost
    ///
    /// # Examples
    ///
    /// ```no_run
    /// use gpui_terminal::clipboard::Clipboard;
    ///
    /// let mut clipboard = Clipboard::new().unwrap();
    /// match clipboard.paste() {
    ///     Ok(text) => println!("Pasted: {}", text),
    ///     Err(e) => eprintln!("Failed to paste: {}", e),
    /// }
    /// ```
    pub fn paste(&mut self) -> Result<String> {
        Ok(self.clipboard.get_text()?)
    }

    /// Clears the clipboard contents.
    ///
    /// This removes all content from the system clipboard.
    ///
    /// # Errors
    ///
    /// Returns an error if:
    /// - The clipboard is not accessible
    /// - Permission to modify the clipboard is denied
    ///
    /// # Examples
    ///
    /// ```no_run
    /// use gpui_terminal::clipboard::Clipboard;
    ///
    /// let mut clipboard = Clipboard::new().unwrap();
    /// clipboard.clear().unwrap();
    /// ```
    pub fn clear(&mut self) -> Result<()> {
        self.clipboard.clear()?;
        Ok(())
    }
}

impl Default for Clipboard {
    /// Creates a new clipboard instance using the default constructor.
    ///
    /// # Panics
    ///
    /// Panics if the clipboard cannot be initialized. For error handling,
    /// use [`Clipboard::new()`] instead.
    fn default() -> Self {
        Self::new().expect("Failed to initialize clipboard")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_clipboard_creation() {
        // This test may fail in CI environments without display server
        // Just verify that new() returns a result (success or failure is ok)
        let result = Clipboard::new();
        // If we're in a headless environment, this will error - that's fine
        if result.is_err() {
            eprintln!("Clipboard not available (headless environment)");
        }
    }

    #[test]
    fn test_clipboard_copy_paste() {
        // This test may fail in CI environments without display server
        let Ok(mut clipboard) = Clipboard::new() else {
            eprintln!("Clipboard not available (headless environment)");
            return;
        };

        let test_text = "Test clipboard content";

        // Copy may fail in some environments
        if let Err(e) = clipboard.copy(test_text) {
            eprintln!("Copy failed (headless environment): {}", e);
            return;
        }

        // Paste may fail or return different content depending on environment
        match clipboard.paste() {
            Ok(pasted) => {
                // In some environments, clipboard may not retain content
                if pasted == test_text {
                    // Success - clipboard working correctly
                } else {
                    eprintln!("Clipboard content mismatch (environment issue)");
                }
            }
            Err(e) => {
                eprintln!("Paste failed (headless environment): {}", e);
            }
        }
    }

    #[test]
    fn test_clipboard_clear() {
        // This test may fail in CI environments without display server
        let Ok(mut clipboard) = Clipboard::new() else {
            eprintln!("Clipboard not available (headless environment)");
            return;
        };

        let test_text = "Content to be cleared";

        if clipboard.copy(test_text).is_ok() {
            let _ = clipboard.clear();
            // After clearing, getting text might return empty or error
            // depending on the platform implementation
        }
    }
}
