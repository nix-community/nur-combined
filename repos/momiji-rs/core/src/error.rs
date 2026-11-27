//! The compiler error type.

use std::fmt;

use crate::scanner::Pos;

/// A compilation error, carrying a human-readable message and a 1-based
/// source position (`line`/`col` are `0` when the position is unknown).
///
/// Implements [`std::error::Error`], so it composes with `?` and the
/// wider error ecosystem.
///
/// For byte-exact dart-sass diagnostics the evaluator attaches a span
/// `length` (in source bytes) and a [`rendered`](Error::rendered) snippet
/// block at the AST-node boundary. When `rendered` is present, [`Display`]
/// emits it verbatim (the full `Error: …` + source-span snippet + stack
/// trace); otherwise it falls back to the legacy `Error: <msg> (line:col)`
/// one-liner.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Error {
    /// Human-readable description of what went wrong.
    pub message: String,
    /// 1-based line number, or `0` if unknown.
    pub line: usize,
    /// 1-based column number, or `0` if unknown.
    pub col: usize,
    /// Length of the offending span, in **bytes** of the source. `0` when the
    /// span length is unknown (the renderer still draws a single caret).
    pub(crate) length: usize,
    /// The fully rendered diagnostic block (header + snippet + frames), set by
    /// the evaluator once the source/url/glyph context is known. `None` until
    /// then; [`Display`] falls back to the legacy one-liner.
    pub(crate) rendered: Option<String>,
}

impl Error {
    pub(crate) fn at(message: impl Into<String>, pos: Pos) -> Self {
        Error {
            message: message.into(),
            line: pos.line,
            col: pos.col,
            length: 0,
            rendered: None,
        }
    }

    pub(crate) fn unpositioned(message: impl Into<String>) -> Self {
        Error {
            message: message.into(),
            line: 0,
            col: 0,
            length: 0,
            rendered: None,
        }
    }

    /// Attach a span length (in source bytes) if one is not already set. Used at
    /// AST-node boundaries to size the caret underline.
    pub(crate) fn with_length(mut self, length: usize) -> Self {
        if self.length == 0 {
            self.length = length;
        }
        self
    }

    /// Attach a span length to an error raised AT `pos` — a statement sizing
    /// the caret of a failure it reported itself, without touching one that
    /// came from somewhere else (a nested file, a member's own span).
    pub(crate) fn with_length_at(mut self, pos: Pos, length: usize) -> Self {
        if self.length == 0 && self.line == pos.line && self.col == pos.col {
            self.length = length;
        }
        self
    }

    /// Whether a primary `line`/`col` position has been recorded.
    pub(crate) fn has_position(&self) -> bool {
        self.line > 0
    }
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if let Some(r) = &self.rendered {
            return f.write_str(r);
        }
        if self.line > 0 {
            write!(f, "Error: {} ({}:{})", self.message, self.line, self.col)
        } else {
            write!(f, "Error: {}", self.message)
        }
    }
}

impl std::error::Error for Error {}
