//! A character cursor over the source with line/column tracking.
//!
//! SCSS's lexical grammar is context-sensitive (a `:` can begin a
//! declaration value or a pseudo-class selector), so the parser scans
//! characters directly rather than over a fixed token stream. This
//! cursor is the shared primitive it builds on.

/// A 1-based source position.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Pos {
    /// 1-based line.
    pub line: usize,
    /// 1-based column.
    pub col: usize,
}

impl Pos {
    /// The "no position" sentinel. `line == 0` can never be a real 1-based
    /// line, so it reads unambiguously as "unknown" (the source map drops it).
    pub(crate) const NONE: Pos = Pos { line: 0, col: 0 };

    /// Whether this is a real recorded position rather than [`Pos::NONE`].
    pub(crate) fn is_known(self) -> bool {
        self.line != 0
    }
}

/// An immutable snapshot of the cursor, used for backtracking lookahead.
#[derive(Debug, Clone, Copy)]
pub(crate) struct Mark {
    pos: usize,
    line: usize,
    col: usize,
}

impl Mark {
    /// The 1-based line/column the cursor stood at when the mark was taken —
    /// the start of a diagnostic span whose length is measured by
    /// [`Scanner::byte_len_from`].
    pub(crate) fn pos(&self) -> Pos {
        Pos {
            line: self.line,
            col: self.col,
        }
    }
}

pub(crate) struct Scanner {
    chars: Vec<char>,
    pos: usize,
    line: usize,
    col: usize,
}

impl Scanner {
    pub(crate) fn new(src: &str) -> Self {
        // A leading UTF-8 byte-order mark is part of the encoding, not the
        // document; dart-sass strips it before parsing so it never reaches the
        // output (and never triggers a spurious `@charset`).
        let src = src.strip_prefix('\u{FEFF}').unwrap_or(src);
        Scanner {
            chars: src.chars().collect(),
            pos: 0,
            line: 1,
            col: 1,
        }
    }

    pub(crate) fn position(&self) -> Pos {
        Pos {
            line: self.line,
            col: self.col,
        }
    }

    pub(crate) fn mark(&self) -> Mark {
        Mark {
            pos: self.pos,
            line: self.line,
            col: self.col,
        }
    }

    /// The number of source **bytes** (UTF-8) consumed since `m` was taken.
    /// Used to size a diagnostic span's caret underline (dart-sass measures
    /// span lengths in bytes).
    pub(crate) fn byte_len_from(&self, m: Mark) -> usize {
        let start = m.pos.min(self.chars.len());
        let end = self.pos.min(self.chars.len());
        self.chars[start..end].iter().map(|c| c.len_utf8()).sum()
    }

    pub(crate) fn reset(&mut self, m: Mark) {
        self.pos = m.pos;
        self.line = m.line;
        self.col = m.col;
    }

    pub(crate) fn peek(&self) -> Option<char> {
        self.chars.get(self.pos).copied()
    }

    pub(crate) fn peek_at(&self, offset: usize) -> Option<char> {
        self.chars.get(self.pos + offset).copied()
    }

    /// The remaining unconsumed characters, for non-consuming lookahead.
    pub(crate) fn rest(&self) -> &[char] {
        let start = self.pos.min(self.chars.len());
        &self.chars[start..]
    }

    pub(crate) fn bump(&mut self) -> Option<char> {
        let c = self.chars.get(self.pos).copied();
        if let Some(ch) = c {
            self.pos += 1;
            if ch == '\n' {
                self.line += 1;
                self.col = 1;
            } else {
                self.col += 1;
            }
        }
        c
    }

    /// The source text consumed since `m` was taken (for verbatim capture,
    /// e.g. a plain CSS `@import` URL emitted unchanged).
    pub(crate) fn slice_from(&self, m: Mark) -> String {
        let start = m.pos.min(self.chars.len());
        let end = self.pos.min(self.chars.len());
        self.chars[start..end].iter().collect()
    }

    /// Consume `c` if it is next; report whether it was consumed.
    pub(crate) fn eat(&mut self, c: char) -> bool {
        if self.peek() == Some(c) {
            self.bump();
            true
        } else {
            false
        }
    }
}
