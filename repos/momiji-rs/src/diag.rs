//! Source-span diagnostic rendering — a hand-rolled, dependency-free
//! re-implementation of dart-sass's `SourceSpanHighlighter` snippet block.
//!
//! This module is **pure**: every public entry point is a function over an
//! explicit `(source, line, col, length, …)` description and returns a
//! `String`. Nothing here touches the evaluator, the parser, or any global
//! state, and there is no I/O — the integration step (which wires real
//! [`crate::Error`] spans through here) lives elsewhere. Keeping it isolated
//! makes it trivial to test against the real `dart-sass` binary byte-for-byte.
//!
//! # What dart-sass renders
//!
//! For a single-line span (`a {\n  b: $undefined;\n}` → the `$undefined`
//! token), dart-sass emits this exact block to stderr (Unicode glyph set):
//!
//! ```text
//!   ╷
//! 2 │   b: $undefined;
//!   │      ^^^^^^^^^^
//!   ╵
//!   path/to/input.scss 2:6  root stylesheet
//! ```
//!
//! The structure is:
//!
//! * a *top* gutter line: right-aligned blank line-number column, a space, the
//!   top glyph `╷` (`U+2577`);
//! * one *source* line per spanned source line: the right-aligned line number,
//!   a space, the mid glyph `│` (`U+2502`), a space, then the source text with
//!   **every TAB expanded to exactly four spaces** (this is byte-load-bearing;
//!   dart-sass does *not* use tab stops, each `\t` becomes `"    "`);
//! * for a single-line span, a *caret* line: blank gutter, the mid glyph, a
//!   space, padding equal to the display-column offset of the span start, then
//!   `^` (`U+005E`) repeated for the display width of the spanned text (at
//!   least one caret, even for a zero-length span);
//! * a *bottom* gutter line: blank gutter, a space, the bottom glyph `╵`
//!   (`U+2575`);
//! * a *location* line: two spaces, the file URL, a space, `line:col`, two
//!   spaces, then the frame name (the outermost frame is literally
//!   `root stylesheet`).
//!
//! The line/column numbers in the location line are **1-based**, matching
//! dart-sass and [`crate::Error`].
//!
//! With `--no-unicode`, dart-sass swaps the glyph set: `╷│╵` → `,|'`, and for
//! a multi-line span `│─` → `|-`. Its two CORNERS have no single spelling:
//! `┌└` are `,'` on the arrow rows that reach in to a span starting or ending
//! mid-line, and `/\` where the arm begins or ends in the GUTTER instead.

/// The glyph set used to draw the gutter and span decorations.
///
/// dart-sass picks [`GlyphSet::Unicode`] by default and [`GlyphSet::Ascii`]
/// under `--no-unicode` (or a non-Unicode terminal). The two sets are
/// byte-for-byte what dart-sass writes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum GlyphSet {
    /// Box-drawing glyphs: `╷ │ ╵ ┌ └ ─` and the ASCII caret `^`.
    Unicode,
    /// Pure-ASCII fallback: `, | ' , ' / \ -` and the caret `^`.
    Ascii,
}

impl GlyphSet {
    /// Top of a single-column gutter (`╷` / `,`).
    const fn top(self) -> &'static str {
        match self {
            GlyphSet::Unicode => "\u{2577}",
            GlyphSet::Ascii => ",",
        }
    }

    /// Vertical bar of a gutter (`│` / `|`).
    const fn vertical(self) -> &'static str {
        match self {
            GlyphSet::Unicode => "\u{2502}",
            GlyphSet::Ascii => "|",
        }
    }

    /// Bottom of a single-column gutter (`╵` / `'`).
    const fn bottom(self) -> &'static str {
        match self {
            GlyphSet::Unicode => "\u{2575}",
            GlyphSet::Ascii => "'",
        }
    }

    /// Top-left corner that opens a multi-line span (`┌` / `,`).
    const fn top_left(self) -> &'static str {
        match self {
            GlyphSet::Unicode => "\u{250c}",
            GlyphSet::Ascii => ",",
        }
    }

    /// Bottom-left corner that closes a multi-line span (`└` / `'`).
    const fn bottom_left(self) -> &'static str {
        match self {
            GlyphSet::Unicode => "\u{2514}",
            GlyphSet::Ascii => "'",
        }
    }

    /// Underline of a SECONDARY span (`━` / `=`) — the heavy rule dart draws
    /// under the `declaration` a `Missing argument` is measured against, so it
    /// reads differently from the primary's carets.
    const fn secondary(self) -> char {
        match self {
            GlyphSet::Unicode => '\u{2501}',
            GlyphSet::Ascii => '=',
        }
    }

    /// The arm a multi-line span draws IN THE GUTTER when it starts at its
    /// line's first non-whitespace character (`┌` / `/`). dart's ASCII set
    /// spells this differently from the `,` that opens an arrow row, so the
    /// two corners cannot share a glyph.
    const fn arm_start(self) -> &'static str {
        match self {
            GlyphSet::Unicode => "\u{250c}",
            GlyphSet::Ascii => "/",
        }
    }

    /// The same for a span that ENDS at its line's last non-whitespace
    /// character (`└` / `\`).
    const fn arm_end(self) -> &'static str {
        match self {
            GlyphSet::Unicode => "\u{2514}",
            GlyphSet::Ascii => "\\",
        }
    }

    /// Horizontal rule used by the multi-line span arms (`─` / `-`).
    const fn horizontal(self) -> &'static str {
        match self {
            GlyphSet::Unicode => "\u{2500}",
            GlyphSet::Ascii => "-",
        }
    }
}

/// dart-sass expands a literal TAB to exactly this many spaces when rendering a
/// source line (it is **not** tab-stop alignment — every `\t` is four spaces,
/// wherever it sits on the line).
const TAB_WIDTH: usize = 4;

/// The caret glyph that underlines a span (`^`, `U+005E`) — identical in both
/// glyph sets.
const CARET: char = '^';

/// A located span to highlight, described in dart-sass / [`crate::Error`]
/// terms: 1-based `line`/`col` of the span start and a byte `length`.
///
/// `length` is measured in **bytes of the original source** (UTF-8); the
/// renderer slices the affected source text out and measures its *display*
/// width (with tabs expanded) to size the caret underline. A `length` of `0`
/// describes a point span and still draws a single caret, exactly as
/// dart-sass does.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Span {
    /// 1-based line of the span start.
    pub line: usize,
    /// 1-based column of the span start, counted in source characters (a TAB
    /// counts as one column, matching dart-sass's reported position).
    pub col: usize,
    /// Length of the span in **bytes** of the original source text.
    pub length: usize,
}

/// One frame of the rendered stack trace.
///
/// The location line under the snippet is a single [`Frame`]; deeper traces
/// (e.g. a function invocation) stack several, outermost last and literally
/// named `root stylesheet`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Frame<'a> {
    /// The file URL/path as dart-sass prints it (e.g. the absolute path, or
    /// `-` for stdin).
    pub url: &'a str,
    /// 1-based line of this frame's span.
    pub line: usize,
    /// 1-based column of this frame's span.
    pub col: usize,
    /// The member name for this frame, or `root stylesheet` for the outermost.
    pub name: &'a str,
}

impl Frame<'_> {
    /// Render a single frame line: `<url> <line>:<col>  <name>` (two spaces
    /// before the name), with no leading indentation. Callers that emit a full
    /// trace prepend two spaces per line; see [`render_frames`].
    fn render_inner(&self) -> String {
        format!("{} {}:{}  {}", self.url, self.line, self.col, self.name)
    }
}

/// Render a stack trace exactly as dart-sass appends it under the snippet:
/// each frame on its own line, prefixed with two spaces.
///
/// ```text
///   path 2:6  some-mixin
///   path 9:3  root stylesheet
/// ```
#[must_use]
pub fn render_frames(frames: &[Frame<'_>]) -> String {
    let mut out = String::new();
    for (i, f) in frames.iter().enumerate() {
        if i > 0 {
            out.push('\n');
        }
        out.push_str("  ");
        out.push_str(&f.render_inner());
    }
    out
}

/// Split `source` into lines the way dart-sass's `SourceFile` does: on `\n`,
/// `\r\n`, and bare `\r`, *dropping* the terminator. A trailing newline yields
/// a final empty line index that is simply never addressed by a 1-based line
/// number, so we do not special-case it.
fn split_lines(source: &str) -> Vec<&str> {
    let mut lines = Vec::new();
    let bytes = source.as_bytes();
    let mut start = 0usize;
    let mut i = 0usize;
    while i < bytes.len() {
        match bytes[i] {
            b'\n' => {
                lines.push(&source[start..i]);
                i += 1;
                start = i;
            }
            b'\r' => {
                lines.push(&source[start..i]);
                i += 1;
                if i < bytes.len() && bytes[i] == b'\n' {
                    i += 1;
                }
                start = i;
            }
            _ => i += 1,
        }
    }
    lines.push(&source[start..]);
    lines
}

/// Expand every TAB in `text` to [`TAB_WIDTH`] spaces. Returns the displayable
/// string. This is the exact transform dart-sass applies before measuring
/// column widths, so it is shared by both the source line and the caret math.
fn expand_tabs(text: &str) -> String {
    let mut out = String::with_capacity(text.len());
    for ch in text.chars() {
        if ch == '\t' {
            for _ in 0..TAB_WIDTH {
                out.push(' ');
            }
        } else {
            out.push(ch);
        }
    }
    out
}

/// Display width of the first `cols` *source columns* of `line`, where each TAB
/// counts as [`TAB_WIDTH`] and every other character counts as one. `cols` is a
/// 0-based character count from the start of the line.
fn display_width_of_prefix(line: &str, cols: usize) -> usize {
    let mut width = 0usize;
    for ch in line.chars().take(cols) {
        width += if ch == '\t' { TAB_WIDTH } else { 1 };
    }
    width
}

/// Number of decimal digits in `n` (at least 1, so `0` → 1).
fn digit_count(n: usize) -> usize {
    let mut n = n;
    let mut digits = 1;
    while n >= 10 {
        n /= 10;
        digits += 1;
    }
    digits
}

/// Build the blank gutter prefix used by decoration lines: `width` spaces (for
/// the line-number column) plus one trailing space, e.g. `"  "` for a
/// single-digit file or `"   "` once line numbers reach 10.
fn blank_gutter(width: usize) -> String {
    let mut s = String::with_capacity(width + 1);
    for _ in 0..width + 1 {
        s.push(' ');
    }
    s
}

/// Build the numbered gutter prefix for a source line: the right-aligned line
/// number padded to `width`, then a space, e.g. `"2 "` or `" 2 "`.
fn numbered_gutter(line_no: usize, width: usize) -> String {
    let digits = digit_count(line_no);
    let mut s = String::with_capacity(width + 1);
    for _ in 0..width.saturating_sub(digits) {
        s.push(' ');
    }
    push_usize(&mut s, line_no);
    s.push(' ');
    s
}

/// Append the decimal rendering of `n` to `out` without allocating.
fn push_usize(out: &mut String, n: usize) {
    if n >= 10 {
        push_usize(out, n / 10);
    }
    // 0..=9 always maps to a valid ASCII digit.
    let digit = (n % 10) as u8 + b'0';
    out.push(digit as char);
}

/// Render the snippet block (gutter + source + caret/arms + location frames)
/// for a span, byte-for-byte like dart-sass.
///
/// This does **not** emit the `Error: <message>` header — the caller owns the
/// message line — but it does emit everything from the top gutter glyph down to
/// (and including) the trailing frame lines, with no trailing newline.
///
/// `source` is the full text of the file the span points into; `span` is the
/// 1-based start position and byte length; `frames` is the stack trace to print
/// under the snippet (use a single [`Frame`] named `root stylesheet` for the
/// common case). `glyphs` selects the Unicode or ASCII decoration set.
///
/// The function is total: out-of-range line numbers, a `length` that runs past
/// the file, and empty sources all degrade gracefully (clamping rather than
/// panicking), so it satisfies the crate's panic-free discipline.
#[must_use]
/// Render dart-sass's dual-span "error in interpolated output" block: the
/// original line with the interpolation's expression underlined, then the
/// interpolated output with a marker at the failing column.
///
/// ```text
///   ,--> input.scss
/// 1 | .test31#{'\@baz'} { content: '3.1'; }
///   |          ^^^^^^^
///   '
///   ,
/// 1 | .test31@baz
///   |        = error in interpolated output
///   '
/// ```
#[allow(clippy::too_many_arguments)]
pub fn render_interp_error_snippet(
    source: &str,
    line: usize,
    col_start: usize,
    col_end: usize,
    resolved: &str,
    resolved_col: usize,
    url: &str,
    glyphs: GlyphSet,
) -> String {
    let lines = split_lines(source);
    let src_line = lines.get(line.saturating_sub(1)).copied().unwrap_or("");
    let width = digit_count(line);
    let pad = blank_gutter(width);
    let marker = match glyphs {
        GlyphSet::Unicode => "\u{2501}",
        GlyphSet::Ascii => "=",
    };
    let arrow = match glyphs {
        GlyphSet::Unicode => "\u{250c}\u{2500}\u{2500}>",
        GlyphSet::Ascii => ",-->",
    };
    let mut out = String::new();
    // First box: the original source with the interpolation underlined.
    out.push_str(&pad);
    out.push_str(arrow);
    out.push(' ');
    out.push_str(url);
    out.push('\n');
    out.push_str(&format!("{line:>width$} {} {src_line}\n", glyphs.vertical()));
    out.push_str(&pad);
    out.push_str(glyphs.vertical());
    out.push(' ');
    for _ in 1..col_start {
        out.push(' ');
    }
    for _ in col_start..col_end {
        out.push('^');
    }
    out.push_str(" \n");
    out.push_str(&pad);
    out.push_str(glyphs.bottom());
    out.push('\n');
    // Second box: the interpolated output (always line 1 of a virtual file).
    out.push_str(&pad);
    out.push_str(glyphs.top());
    out.push('\n');
    out.push_str(&format!("{:>width$} {} {resolved}\n", 1, glyphs.vertical()));
    out.push_str(&pad);
    out.push_str(glyphs.vertical());
    out.push(' ');
    for _ in 1..resolved_col {
        out.push(' ');
    }
    out.push_str(marker);
    out.push_str(" error in interpolated output\n");
    out.push_str(&pad);
    out.push_str(glyphs.bottom());
    out
}

/// Where dart-sass reports an EMPTY span that sits in a file's trailing
/// whitespace: at the end of the last line with content, not on the blank line
/// after it. dart's scanner never advances into that whitespace, so its
/// "expected …" at the end of a file points at the last thing the file says;
/// sasso's parsers do advance, so the position is walked back here — for the
/// snippet and for the frame line alike.
#[must_use]
pub fn trim_empty_span_to_content(source: &str, span: Span) -> Span {
    if span.length > 0 {
        return span;
    }
    let lines = split_lines(source);
    let base = source.as_ptr() as usize;
    let idx = span.line.saturating_sub(1).min(lines.len().saturating_sub(1));
    let line = lines[idx];
    let col0 = span.col.saturating_sub(1);
    // The byte offset of the span, and the text from there to the end.
    let line_start = line.as_ptr() as usize - base;
    let offset = line_start + line.char_indices().nth(col0).map_or(line.len(), |(b, _)| b);
    if offset > source.len() || !source[offset..].trim().is_empty() {
        return span;
    }
    // Land at the END of the last line that has content — trailing spaces on
    // that line included, which is where dart's scanner stopped (`.a { b: c; `
    // reports past the space, not after the `;`).
    let Some((i, l)) = lines.iter().enumerate().rev().find(|(_, l)| !l.trim().is_empty()) else {
        return span;
    };
    Span {
        line: i + 1,
        col: l.chars().count() + 1,
        length: 0,
    }
}

pub fn render_snippet(source: &str, span: Span, frames: &[Frame<'_>], glyphs: GlyphSet) -> String {
    let lines = split_lines(source);

    // Resolve the 0-based start line, clamped into range.
    let start_idx = span.line.saturating_sub(1).min(lines.len().saturating_sub(1));
    let start_col0 = span.col.saturating_sub(1);

    // Walk the byte length across lines to find the end line/col. dart-sass
    // counts the terminator between lines as one byte; we mirror that so a
    // span that crosses a newline lands on the right line.
    let (end_idx, end_col0) = resolve_end(source, &lines, start_idx, start_col0, span.length);

    // Gutter width is sized to the widest line number we will print.
    let max_line_no = end_idx + 1;
    let width = digit_count(max_line_no);

    let mut out = String::new();

    if start_idx == end_idx {
        render_single_line(&mut out, &lines, start_idx, start_col0, end_col0, width, glyphs);
    } else {
        render_multi_line(
            &mut out, &lines, start_idx, start_col0, end_idx, end_col0, width, glyphs,
        );
    }

    // Bottom gutter glyph.
    out.push('\n');
    out.push_str(&blank_gutter(width));
    out.push_str(glyphs.bottom());

    // Location / stack-trace lines.
    if !frames.is_empty() {
        out.push('\n');
        out.push_str(&render_frames(frames));
    }

    out
}

/// One span drawn alongside the primary one, with the label dart-sass writes
/// after its underline.
///
/// A secondary span can live in ANOTHER FILE — the `@mixin` a `Missing
/// argument` points back to, or `sass:color` for a built-in — so it carries
/// its own url and source text.
pub struct Secondary<'a> {
    /// The file the span is in, as the location line spells it.
    pub url: &'a str,
    /// That file's text. It is also half the identity of the block this span
    /// is drawn in: a display url is a NAME two files can share (see
    /// `MixinOrigin::source`), the canonical url is the identity — so spans
    /// join one block only when their TEXT matches too, or one of them would
    /// be rendered against the other's lines.
    pub source: &'a str,
    pub span: Span,
    /// The words after the underline (`declaration`, `includes mixin`, …).
    pub label: &'a str,
}

/// Render a snippet with LABELLED spans: the primary one underlined with
/// carets, each secondary with `━`, every underline followed by its label.
///
/// dart draws this whenever a diagnostic has something to point at besides the
/// place it failed — the parameter list behind `Missing argument $x.`, the
/// `@use` rules that both expose a mixin. The shapes it uses, all measured:
///
/// * spans in one file share a block; each printed line is followed by one
///   underline row per span on it, the primary first;
/// * a span that CROSSES LINES draws an arm down the left of every line it
///   covers, and the row that closes the arm carries the label;
/// * one such span anywhere indents EVERY block by the arm column, blank arm
///   included — dart sizes that column once for the whole diagnostic;
/// * lines that are not adjacent are ELIDED with a `... |` row — dart never
///   prints the lines in between — and the gutter then widens to at least
///   three columns with the numbers LEFT-aligned in it;
/// * spans in different files get one block each, introduced by `,--> <url>`
///   and closed by the usual bottom glyph, the primary's file first.
///
/// A span that stays within its line can sit INSIDE an arm's range — its row
/// is written under its own line, before the arm's, and carries the arm in the
/// column. Two spans that BOTH cross lines and overlap are the one shape this
/// cannot draw: dart nests a second arm column and crosses them with `+`.
/// Callers keep that pair apart — see `Evaluator::spans_share_a_block`.
pub fn render_labelled_snippet(
    url: &str,
    source: &str,
    span: Span,
    label: &str,
    secondaries: &[Secondary<'_>],
    frames: &[Frame<'_>],
    glyphs: GlyphSet,
) -> String {
    // Group by file, primary first, each file keeping first-appearance order.
    let mut groups: Vec<(&str, &str, Vec<Entry<'_>>)> = vec![(
        url,
        source,
        vec![Entry {
            span,
            label,
            primary: true,
        }],
    )];
    for sec in secondaries {
        let entry = Entry {
            span: sec.span,
            label: sec.label,
            primary: false,
        };
        // The TEXT is part of the key: a display url is a name two files can
        // share, so matching on it alone would draw one file's span against
        // the other's lines.
        match groups
            .iter_mut()
            .find(|(u, s, _)| *u == sec.url && *s == sec.source)
        {
            Some((_, _, entries)) => entries.push(entry),
            None => groups.push((sec.url, sec.source, vec![entry])),
        }
    }

    let multi_file = groups.len() > 1;
    // The arm column is sized ONCE for the whole diagnostic: a span crossing
    // lines in any block indents them all.
    let arm = groups
        .iter()
        .any(|(_, s, entries)| entries.iter().any(|e| span_crosses_lines(s, e.span)));
    let mut out = String::new();
    for (i, (group_url, group_source, entries)) in groups.iter_mut().enumerate() {
        if i > 0 {
            out.push('\n');
        }
        entries.sort_by_key(|e| (e.span.line, !e.primary));
        render_group(
            &mut out,
            multi_file.then_some(*group_url),
            group_source,
            entries,
            arm,
            glyphs,
        );
    }
    if !frames.is_empty() {
        out.push('\n');
        out.push_str(&render_frames(frames));
    }
    out
}

/// One labelled span inside a file's block.
struct Entry<'a> {
    span: Span,
    label: &'a str,
    primary: bool,
}

/// An [`Entry`] resolved to the lines and columns it actually covers.
struct Placed<'a> {
    label: &'a str,
    primary: bool,
    start_idx: usize,
    start_col0: usize,
    end_idx: usize,
    end_col0: usize,
    /// Whether the span starts at its line's first non-whitespace character,
    /// which decides whether an arm opens in the gutter or behind an arrow row.
    starts_at_edge: bool,
}

impl Placed<'_> {
    fn crosses_lines(&self) -> bool {
        self.start_idx != self.end_idx
    }
}

fn render_group(
    out: &mut String,
    url: Option<&str>,
    source: &str,
    entries: &[Entry<'_>],
    arm: bool,
    glyphs: GlyphSet,
) {
    let lines = split_lines(source);
    let v = glyphs.vertical();
    let h = glyphs.horizontal();
    let last_line = lines.len().saturating_sub(1);
    let placed: Vec<Placed<'_>> = entries
        .iter()
        .map(|e| {
            let start_idx = e.span.line.saturating_sub(1).min(last_line);
            let start_col0 = e.span.col.saturating_sub(1);
            let (end_idx, end_col0) = resolve_end(source, &lines, start_idx, start_col0, e.span.length);
            let first = lines.get(start_idx).copied().unwrap_or("");
            Placed {
                label: e.label,
                primary: e.primary,
                start_idx,
                start_col0,
                end_idx,
                end_col0,
                starts_at_edge: first.chars().take(start_col0).all(char::is_whitespace),
            }
        })
        .collect();

    // Every line any span touches, each printed once, in order.
    let mut line_nos: Vec<usize> = Vec::with_capacity(placed.len());
    for p in &placed {
        for li in p.start_idx..=p.end_idx {
            if !line_nos.contains(&li) {
                line_nos.push(li);
            }
        }
    }
    line_nos.sort_unstable();

    let max_line_no = line_nos.last().copied().unwrap_or(0) + 1;
    // A gap between printed lines is elided, never filled in — and the `...`
    // row is three columns wide, which widens the gutter and left-aligns the
    // numbers in it.
    let elides = line_nos.windows(2).any(|w| w[1] > w[0] + 1);
    let width = if elides {
        digit_count(max_line_no).max(3)
    } else {
        digit_count(max_line_no)
    };

    out.push_str(&blank_gutter(width));
    // A block introduced by its file name opens with the CORNER glyph the
    // arrow grows out of, not the plain gutter tick.
    out.push_str(if url.is_some() {
        glyphs.top_left()
    } else {
        glyphs.top()
    });
    if let Some(u) = url {
        out.push_str(h);
        out.push_str(h);
        out.push('>');
        out.push(' ');
        out.push_str(u);
    }

    let mut prev: Option<usize> = None;
    for &li in &line_nos {
        if let Some(p) = prev {
            if li > p + 1 {
                out.push('\n');
                out.push_str(&elision_gutter(width));
                out.push_str(v);
            }
        }
        prev = Some(li);
        // Spans that cross lines never overlap each other here (the caller
        // keeps that pair apart), so at most one arm reaches this line, and
        // every row on it — the source line and the underlines under it —
        // carries that arm in the column.
        let armed = placed
            .iter()
            .find(|p| p.crosses_lines() && p.start_idx <= li && li <= p.end_idx);
        let slot = match armed {
            // The arm opens IN THE GUTTER on the line it starts, when the span
            // starts that line; otherwise the `,-…-^` row below reaches in for
            // it and the column stays blank until then.
            Some(a) if a.start_idx == li => {
                if a.starts_at_edge {
                    glyphs.arm_start()
                } else {
                    " "
                }
            }
            Some(_) => v,
            None => " ",
        };
        push_source_line(out, &lines, li, width, elides, arm.then_some(slot), glyphs);
        // The underline rows of the spans that stay WITHIN this line, in the
        // order the entries were sorted into: the primary first.
        for p in placed.iter().filter(|p| !p.crosses_lines() && p.start_idx == li) {
            let line = lines.get(li).copied().unwrap_or("");
            out.push('\n');
            out.push_str(&blank_gutter(width));
            out.push_str(v);
            out.push(' ');
            // The arm is only OPEN below this row once it has reached in:
            // on the line where it starts mid-line, the `,-…-^` row comes
            // after this one, so the column is still blank here.
            let row_slot = match armed {
                Some(a) if a.start_idx == li && !a.starts_at_edge => " ",
                Some(_) => v,
                None => " ",
            };
            push_arm(out, arm.then_some(row_slot));
            for _ in 0..display_width_of_prefix(line, p.start_col0) {
                out.push(' ');
            }
            let mark = if p.primary { CARET } else { glyphs.secondary() };
            for _ in 0..display_width_of_prefix_range(line, p.start_col0, p.end_col0) {
                out.push(mark);
            }
            push_label(out, p.label);
        }
        let Some(a) = armed else { continue };
        // Then the arm's own rows: the `,-…-^` that reaches in to a span
        // starting mid-line, and the row that closes the arm and carries the
        // label.
        if a.start_idx == li && !a.starts_at_edge {
            let first = lines.get(li).copied().unwrap_or("");
            out.push('\n');
            out.push_str(&blank_gutter(width));
            out.push_str(v);
            out.push(' ');
            out.push_str(glyphs.top_left());
            for _ in 0..display_width_of_prefix(first, a.start_col0) + 1 {
                out.push_str(h);
            }
            out.push(CARET);
        }
        if a.end_idx == li {
            // The closing row points at the last spanned character — unless the
            // span runs to the end of its line, where dart has nothing to point
            // at and draws a flat three-rule arm instead.
            let last = lines.get(li).copied().unwrap_or("");
            out.push('\n');
            out.push_str(&blank_gutter(width));
            out.push_str(v);
            out.push(' ');
            out.push_str(glyphs.bottom_left());
            if last.chars().skip(a.end_col0).all(char::is_whitespace) {
                for _ in 0..3 {
                    out.push_str(h);
                }
            } else {
                for _ in 0..display_width_of_prefix(last, a.end_col0) {
                    out.push_str(h);
                }
                out.push(CARET);
            }
            push_label(out, a.label);
        }
    }

    out.push('\n');
    out.push_str(&blank_gutter(width));
    out.push_str(glyphs.bottom());
}

/// Write one numbered source line of a labelled block: gutter, `│`, the arm
/// column when the diagnostic has one (`Some(slot)`), then the text.
fn push_source_line(
    out: &mut String,
    lines: &[&str],
    idx: usize,
    width: usize,
    elides: bool,
    slot: Option<&str>,
    glyphs: GlyphSet,
) {
    out.push('\n');
    out.push_str(&aligned_gutter(idx + 1, width, elides));
    out.push_str(glyphs.vertical());
    out.push(' ');
    push_arm(out, slot);
    out.push_str(&expand_tabs(lines.get(idx).copied().unwrap_or("")));
}

/// The arm column: one glyph and a space, or nothing when the diagnostic has
/// no multi-line span to draw an arm for.
fn push_arm(out: &mut String, slot: Option<&str>) {
    if let Some(slot) = slot {
        out.push_str(slot);
        out.push(' ');
    }
}

/// The words dart writes after an underline, when there are any.
fn push_label(out: &mut String, label: &str) {
    if !label.is_empty() {
        out.push(' ');
        out.push_str(label);
    }
}

/// The gutter for a numbered source line: right-aligned normally, LEFT-aligned
/// once an elision row is in play (dart pads them all to the `...` column).
fn aligned_gutter(line_no: usize, width: usize, elides: bool) -> String {
    if !elides {
        return numbered_gutter(line_no, width);
    }
    let mut s = line_no.to_string();
    while s.len() < width {
        s.push(' ');
    }
    s.push(' ');
    s
}

/// The `... ` gutter of an elision row.
fn elision_gutter(width: usize) -> String {
    let mut s = String::from("...");
    while s.len() < width {
        s.push(' ');
    }
    s.push(' ');
    s
}

/// The 1-based line range a span covers, both ends inclusive.
#[must_use]
pub fn span_line_range(source: &str, span: Span) -> (usize, usize) {
    let lines = split_lines(source);
    let start_idx = span.line.saturating_sub(1).min(lines.len().saturating_sub(1));
    let (end_idx, _) = resolve_end(source, &lines, start_idx, span.col.saturating_sub(1), span.length);
    (start_idx + 1, end_idx + 1)
}

/// Whether a span reaches past the end of the line it starts on.
pub fn span_crosses_lines(source: &str, span: Span) -> bool {
    let lines = split_lines(source);
    let start_idx = span.line.saturating_sub(1).min(lines.len().saturating_sub(1));
    let start_col0 = span.col.saturating_sub(1);
    let (end_idx, _) = resolve_end(source, &lines, start_idx, start_col0, span.length);
    end_idx != start_idx
}

/// The byte width of the terminator after `lines[idx]` — 1 for `\n` or a lone
/// `\r`, 2 for a `\r\n`. The lines are slices of `source`, so the gap between
/// one line's end and the next line's start IS the terminator.
fn terminator_len(source: &str, lines: &[&str], idx: usize) -> usize {
    let base = source.as_ptr() as usize;
    match (lines.get(idx), lines.get(idx + 1)) {
        (Some(cur), Some(next)) => {
            let cur_end = cur.as_ptr() as usize - base + cur.len();
            (next.as_ptr() as usize - base).saturating_sub(cur_end).max(1)
        }
        _ => 1,
    }
}

/// Resolve the (0-based line, 0-based col) just past the end of a byte span,
/// starting from `(start_idx, start_col0)`. Tabs and multibyte characters are
/// handled by walking characters and decrementing the remaining byte budget by
/// each character's UTF-8 length; the inter-line terminator costs one byte.
fn resolve_end(
    source: &str,
    lines: &[&str],
    start_idx: usize,
    start_col0: usize,
    length: usize,
) -> (usize, usize) {
    let mut idx = start_idx;
    let mut col = start_col0;
    let mut remaining = length;

    loop {
        let line = lines.get(idx).copied().unwrap_or("");
        // Characters available from `col` to end of this line.
        let mut consumed_cols = 0usize;
        for ch in line.chars().skip(col) {
            let blen = ch.len_utf8();
            if remaining < blen {
                return (idx, col + consumed_cols);
            }
            remaining -= blen;
            consumed_cols += 1;
        }
        // Reached end of this line. The terminator costs one byte if there is
        // a following line.
        if remaining == 0 || idx + 1 >= lines.len() {
            return (idx, col + consumed_cols);
        }
        // Spend the terminator and move on — TWO bytes for a CRLF, which the
        // line list has already stripped.
        remaining = remaining.saturating_sub(terminator_len(source, lines, idx));
        idx += 1;
        col = 0;
        if remaining == 0 {
            return (idx, 0);
        }
    }
}

/// Render the top gutter line and the (single) source + caret lines.
fn render_single_line(
    out: &mut String,
    lines: &[&str],
    idx: usize,
    start_col0: usize,
    end_col0: usize,
    width: usize,
    glyphs: GlyphSet,
) {
    let line = lines.get(idx).copied().unwrap_or("");
    let v = glyphs.vertical();

    // Top gutter glyph.
    out.push_str(&blank_gutter(width));
    out.push_str(glyphs.top());

    // Source line.
    out.push('\n');
    out.push_str(&numbered_gutter(idx + 1, width));
    out.push_str(v);
    out.push(' ');
    out.push_str(&expand_tabs(line));

    // Caret line.
    out.push('\n');
    out.push_str(&blank_gutter(width));
    out.push_str(v);
    out.push(' ');
    let pad = display_width_of_prefix(line, start_col0);
    for _ in 0..pad {
        out.push(' ');
    }
    // At least one caret, even for a zero-length (point) span — matching
    // dart-sass; `display_width_of_prefix_range` already clamps to >= 1.
    let caret_w = display_width_of_prefix_range(line, start_col0, end_col0);
    for _ in 0..caret_w {
        out.push(CARET);
    }
}

/// Display width of the characters in `line` from 0-based column `from` up to
/// (not including) 0-based column `to`. Used to size a single-line caret run.
fn display_width_of_prefix_range(line: &str, from: usize, to: usize) -> usize {
    if to <= from {
        return 1;
    }
    let mut width = 0usize;
    for ch in line.chars().skip(from).take(to - from) {
        width += if ch == '\t' { TAB_WIDTH } else { 1 };
    }
    width.max(1)
}

/// Render a multi-line span: the opening arm under the first line, each
/// intermediate source line prefixed with the vertical arm, and the closing arm
/// under the last line. Mirrors dart-sass's `┌─…^` / `│` / `└─^` decorations.
#[allow(clippy::too_many_arguments)]
fn render_multi_line(
    out: &mut String,
    lines: &[&str],
    start_idx: usize,
    start_col0: usize,
    end_idx: usize,
    end_col0: usize,
    width: usize,
    glyphs: GlyphSet,
) {
    let v = glyphs.vertical();
    let h = glyphs.horizontal();
    let first = lines.get(start_idx).copied().unwrap_or("");
    let last = lines.get(end_idx).copied().unwrap_or("");
    // dart-sass (source_span) writes the arm glyph in the GUTTER when the span
    // begins at its line's first non-whitespace character, and likewise when it
    // ends at its line's last; it draws an `┌─…─^` / `└─…─^` arrow row only for
    // an end that starts or stops mid-line. The two ends are decided
    // separately: `.a { @include m {` … `  }` opens with an arrow and closes in
    // the gutter.
    let start_at_edge = first.chars().take(start_col0).all(char::is_whitespace);
    let end_at_edge = last.chars().skip(end_col0).all(char::is_whitespace);

    // Top gutter glyph.
    out.push_str(&blank_gutter(width));
    out.push_str(glyphs.top());

    // First source line: the arm slot holds `┌` when the span starts the line,
    // and is blank when an arrow row follows. The layout after the gutter `│`
    // is `<space><arm-slot><space><content>`.
    out.push('\n');
    out.push_str(&numbered_gutter(start_idx + 1, width));
    out.push_str(v);
    out.push(' ');
    if start_at_edge {
        out.push_str(glyphs.arm_start());
    } else {
        out.push(' ');
    }
    out.push(' ');
    out.push_str(&expand_tabs(first));

    // Opening arm: `┌─…─^` whose caret sits under the span start. The `┌`
    // occupies the arm slot; the content baseline is two columns to its right,
    // so the caret offset is the span-start display column + 1.
    if !start_at_edge {
        out.push('\n');
        out.push_str(&blank_gutter(width));
        out.push_str(v);
        out.push(' ');
        out.push_str(glyphs.top_left());
        let lead = display_width_of_prefix(first, start_col0) + 1;
        for _ in 0..lead {
            out.push_str(h);
        }
        out.push(CARET);
    }

    // Intermediate + final source lines, each carrying a `│` arm — except the
    // last, which carries `└` when the span ends the line.
    for li in (start_idx + 1)..=end_idx {
        let text = lines.get(li).copied().unwrap_or("");
        out.push('\n');
        out.push_str(&numbered_gutter(li + 1, width));
        out.push_str(v);
        out.push(' ');
        if li == end_idx && end_at_edge {
            out.push_str(glyphs.arm_end());
        } else {
            out.push_str(v);
        }
        out.push(' ');
        out.push_str(&expand_tabs(text));
    }

    // Closing arm: `└─…─^` whose caret sits under the last spanned character
    // (one column left of the span end), with the same +1 arm offset.
    if !end_at_edge {
        out.push('\n');
        out.push_str(&blank_gutter(width));
        out.push_str(v);
        out.push(' ');
        out.push_str(glyphs.bottom_left());
        let tail = display_width_of_prefix(last, end_col0);
        for _ in 0..tail {
            out.push_str(h);
        }
        out.push(CARET);
    }
}

/// Convenience: render a full diagnostic (`Error:` header + snippet) for the
/// common single-frame `root stylesheet` case. Returns the complete block with
/// no trailing newline, exactly as dart-sass would write it to stderr.
///
/// The evaluator renders its own header + column-aligned frame trace for
/// runtime/`@error` diagnostics (multi-frame stacks); this single-frame
/// convenience renders parse errors (always a lone `root stylesheet` frame).
#[must_use]
pub fn render_error(message: &str, source: &str, url: &str, span: Span, glyphs: GlyphSet) -> String {
    let frame = Frame {
        url,
        line: span.line,
        col: span.col,
        name: "root stylesheet",
    };
    let mut out = format!("Error: {message}\n");
    out.push_str(&render_snippet(source, span, &[frame], glyphs));
    out
}

#[cfg(test)]
mod tests {
    /// Every block below is dart-sass 1.103.1's own output, captured with
    /// `--no-unicode` (scratch `dartref/ds1..ds4.sh`).
    #[test]
    fn labelled_spans_match_dart() {
        let ascii = GlyphSet::Ascii;

        // Adjacent lines: one block, one underline row each.
        let src = "@mixin m($x) { a: $x; }\n.a { @include m; }\n";
        let got = render_labelled_snippet(
            "t.scss",
            src,
            Span {
                line: 2,
                col: 6,
                length: 10,
            },
            "invocation",
            &[Secondary {
                url: "t.scss",
                source: src,
                span: Span {
                    line: 1,
                    col: 8,
                    length: 5,
                },
                label: "declaration",
            }],
            &[],
            ascii,
        );
        assert_eq!(
            got,
            "  ,\n\
             1 | @mixin m($x) { a: $x; }\n\
             \x20 |        ===== declaration\n\
             2 | .a { @include m; }\n\
             \x20 |      ^^^^^^^^^^ invocation\n\
             \x20 '"
        );

        // Non-adjacent lines are elided, never filled in, and the gutter
        // widens to the `...` column with the numbers left-aligned in it.
        let mut far = String::from("@mixin m($x) { a: $x; }\n");
        for i in 0..8 {
            far.push_str(&format!("// {i}\n"));
        }
        far.push_str(".a { @include m; }\n");
        let got = render_labelled_snippet(
            "t.scss",
            &far,
            Span {
                line: 10,
                col: 6,
                length: 10,
            },
            "invocation",
            &[Secondary {
                url: "t.scss",
                source: &far,
                span: Span {
                    line: 1,
                    col: 8,
                    length: 5,
                },
                label: "declaration",
            }],
            &[],
            ascii,
        );
        assert_eq!(
            got,
            "    ,\n\
             1   | @mixin m($x) { a: $x; }\n\
             \x20   |        ===== declaration\n\
             ... |\n\
             10  | .a { @include m; }\n\
             \x20   |      ^^^^^^^^^^ invocation\n\
             \x20   '"
        );

        // Several secondaries: one row each, in line order.
        let src = "@use \"_a\" as *;\n@use \"_b\" as *;\n.x { @include m; }\n";
        let secs: Vec<Secondary<'_>> = (1..=2)
            .map(|line| Secondary {
                url: "t.scss",
                source: src,
                span: Span {
                    line,
                    col: 1,
                    length: 14,
                },
                label: "includes mixin",
            })
            .collect();
        let got = render_labelled_snippet(
            "t.scss",
            src,
            Span {
                line: 3,
                col: 6,
                length: 10,
            },
            "mixin use",
            &secs,
            &[],
            ascii,
        );
        assert_eq!(
            got,
            "  ,\n\
             1 | @use \"_a\" as *;\n\
             \x20 | ============== includes mixin\n\
             2 | @use \"_b\" as *;\n\
             \x20 | ============== includes mixin\n\
             3 | .x { @include m; }\n\
             \x20 |      ^^^^^^^^^^ mixin use\n\
             \x20 '"
        );

        // Another file gets its own block, introduced by its url.
        let entry = ".a { b: red(#abc, 1); }\n";
        let builtin = "@function red($color) {\n";
        let got = render_labelled_snippet(
            "t.scss",
            entry,
            Span {
                line: 1,
                col: 9,
                length: 12,
            },
            "invocation",
            &[Secondary {
                url: "sass:color",
                source: builtin,
                span: Span {
                    line: 1,
                    col: 11,
                    length: 11,
                },
                label: "declaration",
            }],
            &[],
            ascii,
        );
        assert_eq!(
            got,
            "  ,--> t.scss\n\
             1 | .a { b: red(#abc, 1); }\n\
             \x20 |         ^^^^^^^^^^^^ invocation\n\
             \x20 '\n\
             \x20 ,--> sass:color\n\
             1 | @function red($color) {\n\
             \x20 |           =========== declaration\n\
             \x20 '"
        );

        // Two spans on ONE line: the line once, then both rows, primary first.
        let src = ".a { b: get_((x: 1), x); }\n";
        let got = render_labelled_snippet(
            "t.scss",
            src,
            Span {
                line: 1,
                col: 14,
                length: 6,
            },
            "value",
            &[Secondary {
                url: "t.scss",
                source: src,
                span: Span {
                    line: 1,
                    col: 9,
                    length: 15,
                },
                label: "unknown function treated as plain CSS",
            }],
            &[],
            ascii,
        );
        assert_eq!(
            got,
            "  ,\n\
             1 | .a { b: get_((x: 1), x); }\n\
             \x20 |              ^^^^^^ value\n\
             \x20 |         =============== unknown function treated as plain CSS\n\
             \x20 '"
        );
    }

    use super::*;

    // ----- Offline, hard-coded expectations (always run) -----

    #[test]
    fn split_lines_handles_all_terminators() {
        assert_eq!(split_lines("a\nb\r\nc\rd"), vec!["a", "b", "c", "d"]);
        assert_eq!(split_lines(""), vec![""]);
        assert_eq!(split_lines("a\n"), vec!["a", ""]);
    }

    #[test]
    fn tabs_expand_to_four_spaces_everywhere() {
        assert_eq!(expand_tabs("\tb"), "    b");
        assert_eq!(expand_tabs("a\tb"), "a    b");
        assert_eq!(expand_tabs("\t\tb"), "        b");
        assert_eq!(expand_tabs(" \tb"), "     b");
    }

    #[test]
    fn digit_count_basic() {
        assert_eq!(digit_count(0), 1);
        assert_eq!(digit_count(9), 1);
        assert_eq!(digit_count(10), 2);
        assert_eq!(digit_count(123), 3);
    }

    /// dart-sass 1.100.0, `a {\n  b: $undefined;\n}\n`, span at 2:6 len 10.
    #[test]
    fn undefined_variable_unicode() {
        let src = "a {\n  b: $undefined;\n}\n";
        let span = Span {
            line: 2,
            col: 6,
            length: "$undefined".len(),
        };
        let got = render_error(
            "Undefined variable.",
            src,
            "/tmp/input.scss",
            span,
            GlyphSet::Unicode,
        );
        let expected = "\
Error: Undefined variable.
  \u{2577}
2 \u{2502}   b: $undefined;
  \u{2502}      ^^^^^^^^^^
  \u{2575}
  /tmp/input.scss 2:6  root stylesheet";
        assert_eq!(got, expected);
    }

    /// Same input, ASCII glyph set (dart-sass `--no-unicode`).
    #[test]
    fn undefined_variable_ascii() {
        let src = "a {\n  b: $undefined;\n}\n";
        let span = Span {
            line: 2,
            col: 6,
            length: "$undefined".len(),
        };
        let got = render_error(
            "Undefined variable.",
            src,
            "/tmp/input.scss",
            span,
            GlyphSet::Ascii,
        );
        let expected = "\
Error: Undefined variable.
  ,
2 |   b: $undefined;
  |      ^^^^^^^^^^
  '
  /tmp/input.scss 2:6  root stylesheet";
        assert_eq!(got, expected);
    }

    /// dart-sass `@error "boom #{1 + 1}";` → message `"boom 2"`, span 1:1 len 22.
    #[test]
    fn at_error_span_at_line_one() {
        let src = "@error \"boom #{1 + 1}\";\n";
        let span = Span {
            line: 1,
            col: 1,
            length: "@error \"boom #{1 + 1}\"".len(),
        };
        let got = render_error("\"boom 2\"", src, "/tmp/input.scss", span, GlyphSet::Unicode);
        let expected = "\
Error: \"boom 2\"
  \u{2577}
1 \u{2502} @error \"boom #{1 + 1}\";
  \u{2502} ^^^^^^^^^^^^^^^^^^^^^^
  \u{2575}
  /tmp/input.scss 1:1  root stylesheet";
        assert_eq!(got, expected);
    }

    /// Gutter widens once the line number reaches double digits (dart-sass:
    /// 11 blank lines then `a { b: $x; }`, span 12:8 len 2).
    #[test]
    fn wide_gutter_double_digit_line() {
        let mut src = String::new();
        for _ in 0..11 {
            src.push('\n');
        }
        src.push_str("a { b: $x; }\n");
        let span = Span {
            line: 12,
            col: 8,
            length: "$x".len(),
        };
        let got = render_error(
            "Undefined variable.",
            &src,
            "/tmp/input.scss",
            span,
            GlyphSet::Unicode,
        );
        let expected = "\
Error: Undefined variable.
   \u{2577}
12 \u{2502} a { b: $x; }
   \u{2502}        ^^
   \u{2575}
  /tmp/input.scss 12:8  root stylesheet";
        assert_eq!(got, expected);
    }

    /// TAB expansion is byte-load-bearing: dart-sass renders `a {\n\tb: $x;\n}`
    /// with the leading tab as four spaces, span at 2:5 len 2.
    #[test]
    fn tab_indent_expands_in_source_and_caret() {
        let src = "a {\n\tb: $x;\n}\n";
        let span = Span {
            line: 2,
            col: 5,
            length: "$x".len(),
        };
        let got = render_error(
            "Undefined variable.",
            src,
            "/tmp/input.scss",
            span,
            GlyphSet::Unicode,
        );
        // Source: `\tb: $x;` → `    b: $x;`. `$` is source col 5 → display col 8
        // (4 for the tab + `b`,`:`,` ` = 3 → 7? dart reports col 5, display pad 7).
        let expected = "\
Error: Undefined variable.
  \u{2577}
2 \u{2502}     b: $x;
  \u{2502}        ^^
  \u{2575}
  /tmp/input.scss 2:5  root stylesheet";
        assert_eq!(got, expected);
    }

    /// Multi-line single span (dart-sass `a{b: (1px +\n2s)}` →
    /// "incompatible units", span 1:7 across two lines). This is a clean
    /// single span (no secondary labels), captured verbatim from dart-sass
    /// 1.100.0:
    /// ```text
    ///   ╷
    /// 1 │   a{b: (1px +
    ///   │ ┌───────^
    /// 2 │ │ 2s)}
    ///   │ └──^
    ///   ╵
    /// ```
    #[test]
    fn multi_line_span_unicode_arms() {
        let src = "a{b: (1px +\n2s)}\n";
        // Span starts at the `1` of `1px` (1:7) and runs through `2s` on line 2.
        let start_byte = byte_index(src, 1, 7);
        let end_byte = byte_index(src, 2, 3); // just past `2s`
        let span = Span {
            line: 1,
            col: 7,
            length: end_byte - start_byte,
        };
        let frame = Frame {
            url: "/tmp/input.scss",
            line: 1,
            col: 7,
            name: "root stylesheet",
        };
        let got = render_snippet(src, span, &[frame], GlyphSet::Unicode);
        let expected = concat!(
            "  \u{2577}\n",
            "1 \u{2502}   a{b: (1px +\n",
            "  \u{2502} \u{250c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}^\n",
            "2 \u{2502} \u{2502} 2s)}\n",
            "  \u{2502} \u{2514}\u{2500}\u{2500}^\n",
            "  \u{2575}\n",
            "  /tmp/input.scss 1:7  root stylesheet",
        );
        assert_eq!(got, expected);
    }

    /// ASCII multi-line arms (`--no-unicode`), same `1px + 2s` input.
    #[test]
    fn multi_line_span_ascii_arms() {
        let src = "a{b: (1px +\n2s)}\n";
        let start_byte = byte_index(src, 1, 7);
        let end_byte = byte_index(src, 2, 3);
        let span = Span {
            line: 1,
            col: 7,
            length: end_byte - start_byte,
        };
        let frame = Frame {
            url: "/tmp/input.scss",
            line: 1,
            col: 7,
            name: "root stylesheet",
        };
        let got = render_snippet(src, span, &[frame], GlyphSet::Ascii);
        let expected = concat!(
            "  ,\n",
            "1 |   a{b: (1px +\n",
            "  | ,-------^\n",
            "2 | | 2s)}\n",
            "  | '--^\n",
            "  '\n",
            "  /tmp/input.scss 1:7  root stylesheet",
        );
        assert_eq!(got, expected);
    }

    /// A point (zero-length) span still draws exactly one caret.
    #[test]
    fn zero_length_span_one_caret() {
        let src = "a {\n  b: 1 +\n";
        let span = Span {
            line: 2,
            col: 9,
            length: 0,
        };
        let got = render_error(
            "Expected expression.",
            src,
            "/tmp/input.scss",
            span,
            GlyphSet::Unicode,
        );
        let expected = "\
Error: Expected expression.
  \u{2577}
2 \u{2502}   b: 1 +
  \u{2502}         ^
  \u{2575}
  /tmp/input.scss 2:9  root stylesheet";
        assert_eq!(got, expected);
    }

    #[test]
    fn frames_stack_outermost_root() {
        let frames = [
            Frame {
                url: "/tmp/input.scss",
                line: 2,
                col: 7,
                name: "f()",
            },
            Frame {
                url: "/tmp/input.scss",
                line: 2,
                col: 7,
                name: "root stylesheet",
            },
        ];
        let got = render_frames(&frames);
        let expected = "  /tmp/input.scss 2:7  f()\n  /tmp/input.scss 2:7  root stylesheet";
        assert_eq!(got, expected);
    }

    #[test]
    fn out_of_range_does_not_panic() {
        let src = "a {}\n";
        let span = Span {
            line: 99,
            col: 99,
            length: 99,
        };
        // Just assert it produces *something* without panicking.
        let got = render_error("x", src, "-", span, GlyphSet::Unicode);
        assert!(got.starts_with("Error: x"));
    }

    /// Test-only: byte offset of 1-based (line, col) in `src`.
    fn byte_index(src: &str, line: usize, col: usize) -> usize {
        let mut cur_line = 1usize;
        let mut cur_col = 1usize;
        for (i, ch) in src.char_indices() {
            if cur_line == line && cur_col == col {
                return i;
            }
            if ch == '\n' {
                cur_line += 1;
                cur_col = 1;
            } else {
                cur_col += 1;
            }
        }
        src.len()
    }

    // ----- Live dart-sass parity (gated behind SASSO_DIAG_LIVE) -----

    /// When `SASSO_DIAG_LIVE=1` and a `sass` binary is reachable
    /// (`SASS_BIN=/path/to/sass`, else `sass` on PATH), drive the real
    /// compiler and assert our snippet block is byte-identical to dart's.
    #[test]
    fn live_dart_parity() {
        if std::env::var("SASSO_DIAG_LIVE").as_deref() != Ok("1") {
            return;
        }
        let bin = std::env::var("SASS_BIN").unwrap_or_else(|_| "sass".to_string());

        // (source, message, span, glyphs, no_unicode_flag). The `length` for
        // the multi-line case is computed from `byte_index` so the fixture
        // stays readable.
        let ml_src = "a{b: (1px +\n2s)}\n";
        let ml_len = byte_index(ml_src, 2, 3) - byte_index(ml_src, 1, 7);
        let cases: &[(&str, &str, Span, GlyphSet, bool)] = &[
            (
                "a {\n  b: $undefined;\n}\n",
                "Undefined variable.",
                Span {
                    line: 2,
                    col: 6,
                    length: 10,
                },
                GlyphSet::Unicode,
                false,
            ),
            (
                "a {\n  b: $undefined;\n}\n",
                "Undefined variable.",
                Span {
                    line: 2,
                    col: 6,
                    length: 10,
                },
                GlyphSet::Ascii,
                true,
            ),
            (
                "@error \"x\";\n",
                "\"x\"",
                Span {
                    line: 1,
                    col: 1,
                    length: 10,
                },
                GlyphSet::Unicode,
                false,
            ),
            (
                "a {\n\tb: $x;\n}\n",
                "Undefined variable.",
                Span {
                    line: 2,
                    col: 5,
                    length: 2,
                },
                GlyphSet::Unicode,
                false,
            ),
            (
                ml_src,
                "1px and 2s have incompatible units.",
                Span {
                    line: 1,
                    col: 7,
                    length: ml_len,
                },
                GlyphSet::Unicode,
                false,
            ),
            (
                ml_src,
                "1px and 2s have incompatible units.",
                Span {
                    line: 1,
                    col: 7,
                    length: ml_len,
                },
                GlyphSet::Ascii,
                true,
            ),
        ];

        for (i, (src, msg, span, glyphs, no_unicode)) in cases.iter().enumerate() {
            let dir = std::env::temp_dir().join(format!("sasso-diag-{}-{}", std::process::id(), i));
            let _ = std::fs::create_dir_all(&dir);
            let path = dir.join("input.scss");
            std::fs::write(&path, src).expect("write fixture");

            let mut cmd = std::process::Command::new(&bin);
            cmd.arg(&path).arg("--no-color");
            if *no_unicode {
                cmd.arg("--no-unicode");
            }
            let output = match cmd.output() {
                Ok(o) => o,
                Err(_) => return, // sass not runnable; skip silently.
            };
            let stderr = String::from_utf8_lossy(&output.stderr);
            let path_str = path.to_string_lossy().to_string();

            let ours = render_error(msg, src, &path_str, *span, *glyphs);

            // Compare the snippet block: from `Error:` through the location line.
            // dart-sass appends a trailing newline; trim a single one.
            let dart = stderr.trim_end_matches('\n');
            assert_eq!(ours, dart, "\n--- ours ---\n{ours}\n--- dart ---\n{dart}\n");
        }
    }
}
