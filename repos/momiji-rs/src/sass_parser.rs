//! The indented (`.sass`) syntax front-end.
//!
//! The indented syntax describes the *same* language as SCSS — the same
//! statements, the same SassScript value grammar, the same AST — but block
//! structure comes from indentation and statement boundaries from newlines,
//! rather than from `{ … }` and `;`. dart-sass parses `.sass` into the very
//! same tree as `.scss`, so the evaluator and emitter are shared verbatim.
//!
//! This module is a *front-end only*: it reads the indentation-structured
//! source, recovers the block tree (handling multiline continuations, the
//! `=`/`+` mixin shorthands, `//`/`/* */` comments and custom-property
//! values), and reconstructs an equivalent brace/semicolon SCSS source which
//! it hands to the SCSS parser ([`crate::parser::parse_indented`]). The whole
//! SassScript value/prelude/selector grammar is therefore reused unchanged.
//!
//! The reconstruction is POSITION-PRESERVING: every statement is emitted on
//! its own source line (blank lines pad the output up to it), with its source
//! indentation kept, and a block's closing `}` rides on the last line of the
//! block rather than on a line of its own. Every `Pos` the SCSS parser reports
//! for a STATEMENT — diagnostics, deprecation spans, source-map entries — is
//! therefore a position in the `.sass` file itself, as dart-sass reports them.
//!
//! One construct is deliberately excepted: a loud comment is SERIALIZED, not
//! copied. dart drops blank lines between a bare `/*` and the comment's first
//! text and renders that text on the `/*` line, so the reconstruction must do
//! the same to emit dart's CSS — and a diagnostic inside interpolated comment
//! text therefore reports against the rendered line rather than the `.sass`
//! one. Matching dart's output wins over matching its span there.
//!
//! Nothing on
//! a line is rewritten: the three constructs the SCSS grammar does not share —
//! the `=name`/`+name` mixin shorthands, the legacy `\:hover` escaped-selector
//! marker, and unquoted `@import` urls — are read by the parser itself in
//! indented mode ([`crate::parser::parse_indented`]), because expanding or
//! unquoting them would move every column after them.

use crate::ast::Stylesheet;
use crate::error::Error;
use crate::scanner::Pos;

/// Parse indented (`.sass`) source into the shared [`Stylesheet`] AST.
pub(crate) fn parse(src: &str) -> Result<Stylesheet, Error> {
    let scss = Transpiler::new(src).run()?;
    crate::parser::parse_indented(&scss)
}

/// One physical source line, split into its indentation and content.
struct Raw {
    /// 1-based line number (for error positions).
    line: usize,
    /// Indentation width in columns (tabs and spaces, with tab == 1 column —
    /// dart-sass measures indentation in characters, and forbids mixing).
    indent: usize,
    /// The raw indentation characters (to detect tab/space mixing).
    indent_str: String,
    /// The line content with the leading indentation removed (trailing
    /// whitespace kept; it matters for continuation detection only after trim).
    content: String,
}

struct Transpiler {
    lines: Vec<Raw>,
    /// Cursor into `lines`.
    idx: usize,
    /// The assembled SCSS output.
    out: String,
    /// Newlines already counted in `out[..scanned]` — the output line the end
    /// of `out` sits on is tracked incrementally by [`Transpiler::pad_to`].
    out_lines: usize,
    scanned: usize,
    /// Whether the current block is the body of a plain-CSS custom
    /// `@function --x()`/`@mixin --x()` (where a literal `result` declaration
    /// may not have an indented child block).
    in_css_callable: bool,
}

/// Whether `c` may appear in an identifier (mirrors the SCSS parser; any
/// non-ASCII code point is a valid identifier char like dart `isName`).
fn is_ident_char(c: char) -> bool {
    c.is_ascii_alphanumeric() || c == '-' || c == '_' || (c as u32) >= 0x80
}

impl Transpiler {
    fn new(src: &str) -> Self {
        // Normalise line endings the way dart-sass does (it treats CR, CRLF and
        // form-feed as newlines for line-splitting purposes).
        let normalized = src.replace("\r\n", "\n").replace(['\r', '\u{c}'], "\n");
        let mut lines = Vec::new();
        for (i, physical) in normalized.split('\n').enumerate() {
            let mut indent = 0usize;
            let mut indent_str = String::new();
            let mut rest = physical;
            for (b, ch) in physical.char_indices() {
                if ch == ' ' || ch == '\t' {
                    indent += 1;
                    indent_str.push(ch);
                } else {
                    rest = &physical[b..];
                    break;
                }
                rest = &physical[b + ch.len_utf8()..];
            }
            lines.push(Raw {
                line: i + 1,
                indent,
                indent_str,
                content: rest.to_string(),
            });
        }
        Transpiler {
            lines,
            idx: 0,
            out: String::new(),
            out_lines: 0,
            scanned: 0,
            in_css_callable: false,
        }
    }

    /// Pad the output with blank lines until its current line is source line
    /// `line_no` (1-based), so the statement emitted next sits on the line it
    /// came from. Consumed source lines (silent comments, joined
    /// continuations) leave gaps that this fills; nothing ever gets AHEAD of
    /// its source line because every construct emits at most as many lines
    /// as it consumed.
    fn pad_to(&mut self, line_no: usize) {
        self.out_lines += self.out[self.scanned..].bytes().filter(|&b| b == b'\n').count();
        self.scanned = self.out.len();
        while self.out_lines + 1 < line_no {
            self.out.push('\n');
            self.out_lines += 1;
        }
        self.scanned = self.out.len();
    }

    /// Whether the line at `i` is blank (only whitespace).
    fn is_blank(&self, i: usize) -> bool {
        self.lines
            .get(i)
            .map(|l| l.content.trim().is_empty())
            .unwrap_or(true)
    }

    fn run(mut self) -> Result<String, Error> {
        // The base indentation is whatever the first non-blank line uses.
        self.parse_block(0, 0)?;
        Ok(self.out)
    }

    /// Find the next non-blank line index at or after `from`.
    fn next_nonblank(&self, from: usize) -> Option<usize> {
        let mut i = from;
        while i < self.lines.len() {
            if !self.is_blank(i) {
                return Some(i);
            }
            i += 1;
        }
        None
    }

    /// Parse a block whose statements are indented at exactly `block_indent`
    /// (statements at a *greater* indent belong to a child block). `parent_indent`
    /// is the indentation of the line that opened this block (or 0 at the root),
    /// used only to validate that a deeper indent is consistent. Emits SCSS into
    /// `self.out`.
    fn parse_block(&mut self, block_indent: usize, _parent_indent: usize) -> Result<(), Error> {
        loop {
            // Skip blank lines.
            let Some(i) = self.next_nonblank(self.idx) else {
                self.idx = self.lines.len();
                break;
            };
            self.idx = i;
            let indent = self.lines[i].indent;
            if indent < block_indent {
                // Dedent: this line belongs to an outer block.
                break;
            }
            if indent > block_indent {
                // A deeper indent with no statement to attach to is an error.
                return Err(Error::at(
                    "This line was indented unexpectedly.".to_string(),
                    Pos {
                        line: self.lines[i].line,
                        col: indent + 1,
                    },
                ));
            }
            self.parse_statement(block_indent)?;
        }
        Ok(())
    }

    /// Parse one statement starting at `self.idx` (indented at `indent`),
    /// consuming any continuation lines and its child block.
    fn parse_statement(&mut self, indent: usize) -> Result<(), Error> {
        let start = self.idx;
        let line_no = self.lines[start].line;
        self.pad_to(line_no);

        // --- comments -----------------------------------------------------
        let trimmed = self.lines[start].content.trim_start().to_string();
        if trimmed.starts_with("//") {
            // Silent comment: drop it and any deeper-indented continuation
            // block (which is also silent).
            self.idx += 1;
            self.consume_child_block(indent);
            return Ok(());
        }
        if trimmed.starts_with("/*") {
            return self.parse_loud_comment(indent);
        }

        // A custom-property declaration (`--name: …`) takes its value verbatim
        // (a `//` is *not* a comment inside it), so handle it from the raw line
        // before the logical-line assembly strips silent comments.
        if trimmed.starts_with("--") {
            if let Some(()) = self.try_parse_custom_property_stmt(indent, line_no)? {
                return Ok(());
            }
        }

        // --- assemble the logical line (bracket / trailing-comma / `\`
        //     continuations) ---------------------------------------------
        let (mut logical, child_indent) = self.assemble_logical_line(indent)?;

        // (A leading `\` — the legacy `\:hover` form, which marks the line as a
        // SELECTOR rather than the old `:prop val` declaration syntax — stays
        // on the line for the parser to consume in indented mode, so the
        // selector keeps its own column. Dropping it here shifted every column
        // after it by one.)

        // The mixin shorthands (`=name` for `@mixin name`, `+name` for
        // `@include name`) are NOT rewritten: expanding them would shift every
        // column after the keyword, and the SCSS parser reads them directly in
        // indented mode. The line analysis below maps them to the directives
        // they stand for (see `directive_name`).

        // A directive whose prelude is grammatically incomplete at the end of
        // its line continues onto the next (deeper-indented) line(s) — the
        // newline acts as whitespace inside the prelude. The remaining
        // deeper-indented lines after the prelude completes are its body.
        self.extend_directive_prelude(&mut logical, line_no)?;

        // (Unquoted `@import` URLs — `@import foo, sub/bar` — are accepted by
        // the SCSS parser in indented mode, so the line stays as written and
        // the URL's diagnostic span is the bare token's.)

        // The statement keyword decides whether a `;` or a `{ … }` block is
        // appropriate, and handles custom props.
        self.emit_statement(&logical, child_indent, indent, line_no)
    }

    /// Consume (discard) a child block deeper than `indent` — used for silent
    /// comments, whose nested lines are also part of the comment.
    fn consume_child_block(&mut self, indent: usize) {
        while let Some(i) = self.next_nonblank(self.idx) {
            if self.lines[i].indent <= indent {
                break;
            }
            self.idx = i + 1;
        }
    }

    /// A loud `/* … */` comment statement. It may close on the same line, or
    /// span a deeper-indented block (whose lines become comment text). dart-sass
    /// collapses such a block to ` <text>` joined by spaces.
    fn parse_loud_comment(&mut self, indent: usize) -> Result<(), Error> {
        let start = self.idx;
        let line_no = self.lines[start].line;
        let mut content = self.lines[start].content.trim_start().to_string();
        // An open `#{` interpolation spans lines as expression whitespace, not
        // comment-line structure: join continuation lines verbatim until it
        // closes (`/* #{a` + `+ b} */` is one comment containing `#{a\n+ b}`).
        let mut first_line_end = start + 1;
        while interp_open_anywhere(&content) && first_line_end < self.lines.len() {
            content.push('\n');
            content.push_str(&self.lines[first_line_end].indent_str);
            content.push_str(&self.lines[first_line_end].content);
            first_line_end += 1;
        }
        // Does the comment terminate on the same line?
        if let Some(end) = content.find("*/") {
            // Anything after the close (besides whitespace / another comment) is
            // an error in `.sass`.
            let after = content[end + 2..].trim_start();
            if !after.is_empty() && !after.starts_with("//") && !after.starts_with("/*") {
                return Err(Error::at(
                    "expected expression.".to_string(),
                    Pos {
                        line: line_no,
                        col: indent + end + 3,
                    },
                ));
            }
            self.out.push_str(&self.lines[start].indent_str);
            self.out.push_str(&content[..end + 2]);
            self.out.push('\n');
            self.idx = first_line_end;
            // A deeper-indented block after a closed comment is an error.
            if let Some(i) = self.next_nonblank(self.idx) {
                if self.lines[i].indent > indent {
                    return Err(Error::at(
                        "This line was indented unexpectedly.".to_string(),
                        Pos {
                            line: self.lines[i].line,
                            col: self.lines[i].indent + 1,
                        },
                    ));
                }
            }
            return Ok(());
        }
        // Unterminated on this line: gather the deeper-indented block as
        // comment body. dart's `_loudComment` builds the text as `/*` + the
        // first content line (joined with one space, extra indentation beyond
        // `comment_col + 3` preserved), then `\n * ` per continuation line
        // with the same padding rule; its serializer then strips
        // `min(1, comment_col)` columns. The transform emits the
        // POST-STRIP form directly (the transformed SCSS places comments at
        // column 0, so the SCSS-side dedent is a no-op): gutter `* ` when the
        // comment was indented, ` * ` at the top level. Blank lines inside
        // the block become a bare gutter; trailing blanks after the block are
        // not part of it. Each entry is `(source_column, text)`; a blank line
        // has no entry text — modelled as None.
        let mut content_lines: Vec<Option<(usize, String)>> = Vec::new();
        // Line 0 content after the `/*` marker stays glued VERBATIM (dart
        // keeps `/**` and `/*  spaced` exactly as written); the sentinel
        // column marks it so the renderer skips the source-column padding.
        // Dropped if only whitespace.
        let first = content.strip_prefix("/*").unwrap_or(&content).to_string();
        if !first.trim().is_empty() {
            content_lines.push(Some((usize::MAX, first)));
        }
        self.idx = first_line_end;
        let mut closed = false;
        let mut pending_blanks = 0usize;
        while self.idx < self.lines.len() {
            let l = &self.lines[self.idx];
            if l.content.trim().is_empty() {
                pending_blanks += 1;
                self.idx += 1;
                continue;
            }
            if l.indent <= indent {
                break;
            }
            // Flush blanks only between block lines (a blank run *inside* the
            // comment renders as ` *` lines).
            for _ in 0..pending_blanks {
                content_lines.push(None);
            }
            pending_blanks = 0;
            // Keep the line's trailing whitespace: dart-sass preserves it inside
            // a loud comment body (`/* \n  a \n  */` -> `/* a \n * */`, the space
            // after `a` is retained). Only leading indentation is normalized,
            // via the source-column padding below.
            let body = l.content.to_string();
            content_lines.push(Some((l.indent, body.clone())));
            self.idx += 1;
            if body.contains("*/") {
                closed = true;
                break;
            }
        }
        // dart drops blank lines between a BARE `/*` and the comment's first
        // text (`/*` + blank + `  a` renders as `/* a */`), while a blank
        // BETWEEN two body lines is kept. Without this the renderer's first
        // entry was a blank, so the `/*` opener was never emitted at all and
        // the reconstruction was not valid SCSS.
        while matches!(content_lines.first(), Some(None)) {
            content_lines.remove(0);
        }
        if content_lines.is_empty() {
            content_lines.push(Some((3, String::new())));
        }
        if !closed {
            // dart-sass auto-closes an unterminated loud comment at the end of
            // its block, appending ` */` to the last line.
            if let Some(Some((_, last))) = content_lines.last_mut() {
                if last.is_empty() {
                    *last = "*/".to_string();
                } else {
                    last.push_str(" */");
                }
            }
        }
        // Post-strip gutter: dart's raw text always uses ` * `, and its
        // serializer strips `min(1, comment_col)` — so an indented comment
        // loses the gutter's leading space while a top-level one keeps it.
        let gutter = if indent == 0 { " * " } else { "* " };
        for (i, line) in content_lines.iter().enumerate() {
            if i == 0 {
                // The comment opens at its source column (the SCSS-side
                // dedent of `min(1, comment_col)` then matches dart's).
                self.out.push_str(&self.lines[start].indent_str);
            }
            match line {
                // The first-line remainder rides verbatim behind `/*`.
                Some((col, text)) if *col == usize::MAX => {
                    self.out.push_str("/*");
                    self.out.push_str(text);
                }
                Some((col, text)) => {
                    // Extra indentation beyond `comment_col + 3` is content
                    // (dart pads for `3 .. current - parent`).
                    let pad = col.saturating_sub(indent).saturating_sub(3);
                    if i == 0 {
                        self.out.push_str("/* ");
                    } else {
                        self.out.push_str(gutter);
                    }
                    for _ in 0..pad {
                        self.out.push(' ');
                    }
                    self.out.push_str(text);
                }
                None => self.out.push_str(gutter.trim_end()),
            }
            self.out.push('\n');
        }
        Ok(())
    }

    /// Assemble a logical line from `self.idx`, consuming bracket / trailing
    /// comma / backslash continuations. Returns the joined content and the
    /// indentation a child block (if any) must exceed (always the statement's
    /// own `indent`). Leaves `self.idx` past the last consumed continuation
    /// line. Errors on tab/space indentation mixing within the continuation.
    fn assemble_logical_line(&mut self, indent: usize) -> Result<(String, usize), Error> {
        let start = self.idx;
        let mut logical = strip_statement_comment(self.lines[start].content.trim_start());
        self.idx = start + 1;
        // A trailing `,` continues the line only in a selector context — a bare
        // declaration value (`b: c,`) does *not* wrap onto the next line in the
        // indented syntax. A directive prelude handles its own continuation
        // later, so a trailing comma there is also not consumed here.
        // A declaration colon is followed by whitespace; a selector pseudo's
        // colon is glued to its name — dart continues `&:active,`,
        // `a::-webkit-x,` and even `b:c,` as selector lists (quasar's
        // normalize.sass), so only a whitespace-followed colon blocks it.
        let comma_continues = !logical.starts_with('@')
            && !logical.starts_with('$')
            && match find_decl_colon(&logical) {
                None => true,
                Some(c) => !logical[c + 1..].starts_with(char::is_whitespace),
            };
        // A *declaration value* mid-expression continues on a trailing binary
        // operator (`b: 3 %` + `2` is the modulo `3 % 2`).
        let op_continues =
            !logical.starts_with('@') && !logical.starts_with('$') && find_decl_colon(&logical).is_some();
        loop {
            if continuation_pending(&logical, comma_continues)
                || (op_continues && ends_with_value_operator(&logical))
            {
                // Need a following line to continue. Continuations join the
                // *immediate next physical line* (dart-sass does not skip blanks
                // here).
                if self.idx >= self.lines.len() {
                    break;
                }
                let next_content = self.lines[self.idx].content.clone();
                let next_indent_str = self.lines[self.idx].indent_str.clone();
                let st = scan_state(&logical);
                // Inside an open interpolation, loud comment, string or
                // `url(…)`, the next line's text is captured verbatim (a `//`
                // there is not a comment).
                let verbatim = st.in_interp || st.in_loud_comment || st.in_string || st.in_url;
                if next_content.trim().is_empty() {
                    if st.bracket_depth > 0 || verbatim {
                        // A blank line inside brackets/interp/comment joins as a
                        // newline.
                        logical.push('\n');
                        self.idx += 1;
                        continue;
                    }
                    break;
                }
                let joined = if verbatim {
                    next_content.clone()
                } else {
                    strip_silent_comment(&next_content)
                };
                // A trailing backslash pulls the next line in, and the pair is
                // kept VERBATIM — backslash, line break and the next line's own
                // indentation. Inside a quoted string that is a CSS line
                // continuation, which means the same thing written either way
                // (both vanish, and the indentation stays content) while leaving
                // every token on the line it was written on. ANYWHERE ELSE dart
                // rejects it — `escape()` fails on a newline — so the pair has
                // to reach the parser for it to say so, at the column it is
                // written; collapsing the line into a space made `b: c\` +
                // `d` compile as `b: c d`.
                if logical.ends_with('\\') {
                    logical.push('\n');
                    logical.push_str(&next_indent_str);
                    logical.push_str(&joined);
                } else {
                    // Bracket / trailing-comma / interp / comment continuation:
                    // preserve the newline and the line's original indentation so
                    // the SCSS parser sees the same whitespace as dart-sass.
                    logical.push('\n');
                    logical.push_str(&next_indent_str);
                    logical.push_str(&joined);
                }
                self.idx += 1;
                continue;
            }
            break;
        }
        Ok((logical, indent))
    }

    /// While the directive prelude in `logical` is grammatically incomplete,
    /// pull in the next deeper-indented line(s) as prelude continuation. A
    /// newline acts as whitespace inside a directive prelude, so a directive may
    /// span several indented lines before its body block (which is whatever
    /// deeper-indented lines remain afterwards).
    fn extend_directive_prelude(&mut self, logical: &mut String, start_line: usize) -> Result<(), Error> {
        if !prelude_can_span(logical) {
            return Ok(());
        }
        while prelude_incomplete(logical) {
            // An incomplete prelude consumes the next non-blank line regardless
            // of its indentation: a newline acts as whitespace inside a prelude,
            // so the expression/clause grammar keeps reading until satisfied.
            let Some(i) = self.next_nonblank(self.idx) else {
                break;
            };
            let piece = strip_silent_comment(self.lines[i].content.trim_start());
            let (line, indent_str) = (self.lines[i].line, self.lines[i].indent_str.clone());
            self.idx = i + 1;
            if piece.is_empty() {
                continue;
            }
            join_continuation(logical, start_line, line, &indent_str, &piece);
            // Pull in any bracket continuations of this new line too (a
            // trailing comma only continues a `@use`/`@forward` member list).
            let comma_continues = matches!(directive_name(logical).as_deref(), Some("use" | "forward"));
            while continuation_pending(logical, comma_continues) {
                let Some(j) = self.next_nonblank(self.idx) else {
                    break;
                };
                let cont = strip_silent_comment(self.lines[j].content.trim_start());
                let (line, indent_str) = (self.lines[j].line, self.lines[j].indent_str.clone());
                self.idx = j + 1;
                join_continuation(logical, start_line, line, &indent_str, &cont);
            }
        }
        Ok(())
    }

    /// Parse the child block of the statement that begins at `self.idx`'s
    /// previous position; statements indented strictly deeper than `indent`
    /// form the block. Returns whether a block was found.
    fn parse_child_into_braces(&mut self, indent: usize) -> Result<bool, Error> {
        let Some(i) = self.next_nonblank(self.idx) else {
            return Ok(false);
        };
        let child_indent = self.lines[i].indent;
        if child_indent <= indent {
            return Ok(false);
        }
        self.out.push_str(" {\n");
        self.idx = i;
        self.parse_block(child_indent, indent)?;
        // The `}` rides on the block's last output line: a `.sass` block has
        // no closing line of its own, and dart's rule span ends with its last
        // child. (An all-silent block leaves ` {` alone: `a { }`.)
        if self.out.ends_with('\n') {
            self.out.pop();
            // That newline may already have been counted by `pad_to` — it is,
            // whenever the block's last statement emitted nothing (a silent
            // comment). Un-count it, or every following statement lands a line
            // early.
            if self.scanned > self.out.len() {
                self.out_lines -= 1;
                self.scanned = self.out.len();
            }
        }
        self.out.push_str(" }\n");
        Ok(true)
    }

    /// The indentation characters of source line `line_no` (1-based).
    fn indent_str_for(&self, line_no: usize) -> String {
        self.lines
            .get(line_no.saturating_sub(1))
            .map(|l| l.indent_str.clone())
            .unwrap_or_default()
    }

    /// Emit one statement (already assembled into `logical`), attaching its
    /// child block if present.
    fn emit_statement(
        &mut self,
        logical: &str,
        _child_indent: usize,
        indent: usize,
        line_no: usize,
    ) -> Result<(), Error> {
        let mut logical = logical.trim();

        // A single trailing `;` ends a statement and is tolerated; a `;` with
        // further (non-comment) content after it means two statements share a
        // line, which the indented syntax forbids. An explicit trailing `;`
        // also means "no block" — even an otherwise block-owning directive
        // (`@a b;`) is then a leaf statement.
        let mut explicit_semicolon = false;
        if let Some(semi) = find_top_level_semicolon(logical) {
            // A trailing loud comment after the `;` is tolerated and dropped
            // (`b: c; /* f */`); anything else is two statements on a line.
            let rest = &logical[semi + 1..];
            let after = trim_trailing_loud_comments(rest.trim());
            if !after.is_empty() {
                // dart carets the SECOND statement — the first character after
                // the `;` and the whitespace following it — not the `;` itself.
                // A logical line can span several source lines (a bracket
                // continuation keeps its line breaks), so the position is
                // counted from the last one, whose own indentation is already
                // part of `logical`.
                let skipped = rest.len() - rest.trim_start().len();
                let prefix = &logical[..semi + 1 + skipped];
                let (line, col) = match prefix.rfind('\n') {
                    Some(nl) => (
                        line_no + prefix.matches('\n').count(),
                        prefix[nl + 1..].chars().count() + 1,
                    ),
                    None => (line_no, indent + prefix.chars().count() + 1),
                };
                return Err(Error::at(
                    "multiple statements on one line are not supported in the indented syntax.".to_string(),
                    Pos { line, col },
                ));
            }
            // Drop the harmless trailing `;` (the transform re-adds the right
            // terminator).
            logical = logical[..semi].trim_end();
            explicit_semicolon = true;
        }

        // A leaf directive (e.g. `@import`, `@return`, `@extend`, `@charset`)
        // may not have anything indented beneath it.
        if let Some(name) = forbids_indented_child(logical) {
            if let Some(i) = self.next_nonblank(self.idx) {
                if self.lines[i].indent > indent {
                    return Err(Error::at(
                        format!("Nothing may be indented beneath a @{name} rule."),
                        Pos {
                            line: self.lines[i].line,
                            col: self.lines[i].indent + 1,
                        },
                    ));
                }
            }
        }

        // Whether this logical line wants a brace block (a rule / directive) or
        // a `;` terminator (a declaration / leaf directive) is decided after we
        // know whether a child block follows. We emit the prelude, then either a
        // block or — when no child block follows — the empty form appropriate to
        // the statement kind (an empty `{}` for block constructs, `;` otherwise).
        // A declaration WITH a value whose child block contains a line that
        // is not itself a `prop: value` declaration is dart-sass's
        // "expected \":\"." error (nested properties only) — e.g.
        // `b: c,` followed by a deeper-indented bare `d`.
        let is_decl_with_value = !logical.starts_with('@')
            && !logical.starts_with('$')
            && !logical.starts_with("--")
            && find_decl_colon(logical).is_some_and(|c| {
                let after = &logical[c + 1..];
                after.starts_with(char::is_whitespace) && !after.trim().is_empty()
            });
        if is_decl_with_value {
            if let Some(i) = self.next_nonblank(self.idx) {
                if self.lines[i].indent > indent {
                    let child_indent = self.lines[i].indent;
                    let mut j = i;
                    while j < self.lines.len() {
                        let l = &self.lines[j];
                        if l.content.trim().is_empty() {
                            j += 1;
                            continue;
                        }
                        if l.indent < child_indent {
                            break;
                        }
                        if l.indent == child_indent {
                            let t = l.content.trim_start();
                            if !t.starts_with("//") && !t.starts_with("/*") && find_decl_colon(t).is_none() {
                                return Err(Error::at(
                                    "expected \":\".".to_string(),
                                    Pos {
                                        line: l.line,
                                        col: l.content.trim_end().chars().count() + 1,
                                    },
                                ));
                            }
                        }
                        j += 1;
                    }
                }
            }
        }
        // Inside a plain-CSS custom callable body, a literal `result`
        // declaration may not have an indented child block (an interpolated
        // `#{result}:` follows the ordinary nested-property rules instead).
        if self.in_css_callable && !logical.contains("#{") {
            if let Some(colon) = find_decl_colon(logical) {
                if logical[..colon].trim().eq_ignore_ascii_case("result") {
                    if let Some(i) = self.next_nonblank(self.idx) {
                        if self.lines[i].indent > indent {
                            return Err(Error::at(
                                "Nothing may be indented beneath a @function result.".to_string(),
                                Pos {
                                    line: self.lines[i].line,
                                    col: self.lines[i].indent + 1,
                                },
                            ));
                        }
                    }
                }
            }
        }
        // Keep the source indentation so every column the SCSS parser
        // reports is the `.sass` column.
        self.out.push_str(&self.indent_str_for(line_no));
        self.out.push_str(logical);
        // A `@function --x()`/`@mixin --x()` body is a plain-CSS custom
        // callable; flag it for the `result` child check above.
        // The keyword may be escaped (`@fu\6e ction`), so the name after it is
        // found with the same decoder `directive_name` uses — a raw
        // identifier-character strip would stop at the backslash and miss the
        // `--`, letting a `result:` child through that dart rejects.
        let css_callable = matches!(directive_name(logical).as_deref(), Some("function" | "mixin")) && {
            let after_sigil: Vec<char> = logical
                .trim_start()
                .trim_start_matches(['@', '='])
                .chars()
                .collect();
            let (_, end) = crate::parser::decode_ident(&after_sigil, 0);
            after_sigil[end..]
                .iter()
                .collect::<String>()
                .trim_start()
                .starts_with("--")
        };
        let saved_callable = self.in_css_callable;
        if css_callable {
            self.in_css_callable = true;
        }
        let had_block = self.parse_child_into_braces(indent)?;
        self.in_css_callable = saved_callable;
        if !had_block {
            let form = if explicit_semicolon {
                EmptyForm::Semicolon
            } else {
                empty_form(logical)
            };
            match form {
                EmptyForm::Braces => self.out.push_str(" {}\n"),
                EmptyForm::Semicolon => self.out.push_str(";\n"),
            }
        }
        Ok(())
    }

    /// Parse a custom-property declaration (`--name: value`) from the raw lines
    /// starting at `self.idx`. The value is captured verbatim — a `//` is not a
    /// comment inside it, and a deeper-indented child block continues the value
    /// — and emitted as an SCSS custom declaration. Returns `Some(())` when the
    /// line really is a custom property; otherwise leaves `self.idx` untouched
    /// and returns `None` so normal statement handling proceeds.
    fn try_parse_custom_property_stmt(
        &mut self,
        indent: usize,
        _line_no: usize,
    ) -> Result<Option<()>, Error> {
        let start = self.idx;
        let raw = self.lines[start].content.trim_start().to_string();
        // Confirm a top-level colon follows the `--name` token.
        let Some(colon) = find_decl_colon(&raw) else {
            return Ok(None);
        };
        let name = raw[..colon].trim_end();
        if !name.starts_with("--") || name.len() < 2 || name.contains(char::is_whitespace) {
            return Ok(None);
        }
        self.idx = start + 1;
        // The text after the colon is kept VERBATIM, leading whitespace and
        // all: a custom property's value is not re-serialized, so `--v:1px`
        // must stay `--v:1px` (dart emits no space there, while it collapses a
        // run of them to one — the rule the shared parser already applies).
        let mut value = raw[colon + 1..].to_string();
        // Only an *open* bracket (`(`/`[`/`{`) or `#{` interpolation continues
        // the value onto following lines (verbatim, preserving each line's
        // source indentation); otherwise nothing may be indented beneath a
        // custom property (dart-sass error).
        while custom_value_open(&value) && self.idx < self.lines.len() {
            let l = &self.lines[self.idx];
            value.push('\n');
            value.push_str(&l.indent_str);
            value.push_str(&l.content);
            self.idx += 1;
        }
        if let Some(i) = self.next_nonblank(self.idx) {
            if self.lines[i].indent > indent {
                return Err(Error::at(
                    "Nothing may be indented beneath a custom property.".to_string(),
                    Pos {
                        line: self.lines[i].line,
                        col: self.lines[i].indent + 1,
                    },
                ));
            }
        }
        // Keep the original indentation in the transpiled line: the name's
        // source column caps the re-indentation strip of a multi-line value
        // (dart _writeReindentedValue), so it must survive the SCSS re-parse.
        self.out.push_str(&self.lines[start].indent_str);
        // Everything up to the colon is emitted as written — whitespace BEFORE
        // it included, or the value would start a column early (`--v : 1px`).
        self.out.push_str(&raw[..colon]);
        self.out.push(':');
        self.out.push_str(value.trim_end());
        self.out.push_str(";\n");
        Ok(Some(()))
    }
}

/// Append a prelude continuation line to `logical` at the position it occupies
/// in the source: one newline per source line crossed (so a blank line between
/// them survives), then the line's own indentation, then its text.
///
/// A newline is whitespace inside a directive prelude, so the grammar reads the
/// same text either way — but joining with a SPACE would put every token of the
/// continuation on the statement's first line, and an error in one
/// (`@each $a in` / `  $undef`) would be reported there rather than on its own
/// line, where dart reports it.
fn join_continuation(logical: &mut String, start_line: usize, line: usize, indent_str: &str, piece: &str) {
    let end_line = start_line + logical.bytes().filter(|&b| b == b'\n').count();
    if line > end_line {
        for _ in end_line..line {
            logical.push('\n');
        }
        logical.push_str(indent_str);
    } else if !logical.is_empty() && !logical.ends_with(char::is_whitespace) {
        // A continuation that does not advance a line (it never should) still
        // needs the whitespace the newline would have provided.
        logical.push(' ');
    }
    logical.push_str(piece);
}

/// The number of backslashes a line ends with: an odd count means the last one
/// escapes whatever comes next, which is the line break.
fn trailing_backslashes(s: &str) -> usize {
    s.chars().rev().take_while(|&c| c == '\\').count()
}

/// Whether an UNESCAPED identifier is a `url` function name — `url` itself or
/// a vendor-prefixed `-x-url` — compared in place, without building a `String`
/// (the allocation-free twin of [`crate::parser::is_url_function`], which the
/// escaped path still uses).
fn plain_name_is_url(cs: &[char]) -> bool {
    fn is_url(cs: &[char]) -> bool {
        cs.len() == 3
            && cs[0].eq_ignore_ascii_case(&'u')
            && cs[1].eq_ignore_ascii_case(&'r')
            && cs[2].eq_ignore_ascii_case(&'l')
    }
    if is_url(cs) {
        return true;
    }
    // `-x-url`: a leading `-`, at least one inner character, then a second `-`.
    if cs.first() == Some(&'-') {
        if let Some(rel) = cs[1..].iter().position(|&c| c == '-') {
            if rel >= 1 {
                return is_url(&cs[1 + rel + 1..]);
            }
        }
    }
    false
}

/// The lowercased directive keyword of a logical line (`@for` -> `"for"`), or
/// `None` if the line is not an at-rule.
///
/// The indented syntax's mixin shorthands answer with the directive they stand
/// for: `=name` is `@mixin name` and `+name` is `@include name`. They keep
/// their own spelling in the transpiled SCSS — rewriting them would shift the
/// columns of everything after the keyword, and a mixin's arguments must keep
/// their `.sass` positions — so this is where the rest of the line analysis
/// learns what they are. A bare `=` still reads as `@mixin` (it continues onto
/// the next line like the directive it stands for); a bare `+` does NOT, since
/// `+ a` is the next-sibling combinator, a selector.
fn directive_name(logical: &str) -> Option<String> {
    let t = logical.trim_start();
    if t.starts_with('=') {
        return Some("mixin".to_string());
    }
    if let Some(after) = t.strip_prefix('+') {
        return after
            .starts_with(|c: char| is_ident_char(c) || c == '#' || c == '\\')
            .then(|| "include".to_string());
    }
    let rest = t.strip_prefix('@')?;
    // The keyword may be spelled with CSS escapes — the parser decodes them
    // (`@im\70ort` IS `@import`), so the line analysis has to as well, or a
    // directive would be taken for an unknown at-rule.
    let cs: Vec<char> = rest.chars().collect();
    let (name, _) = crate::parser::decode_ident(&cs, 0);
    if name.is_empty() {
        None
    } else {
        Some(name.to_ascii_lowercase())
    }
}

/// Whether a statement's prelude may span multiple lines (the prelude is an
/// expression / structured clause that the indented parser reads with the real
/// grammar, treating newlines as whitespace). True for the expression-bearing
/// directives and for `$variable` declarations.
fn prelude_can_span(logical: &str) -> bool {
    if logical.trim_start().starts_with('$') {
        return true;
    }
    matches!(
        directive_name(logical).as_deref(),
        Some(
            "for"
                | "each"
                | "if"
                | "else"
                | "while"
                | "function"
                | "mixin"
                | "include"
                | "return"
                | "warn"
                | "debug"
                | "error"
                | "extend"
                | "use"
                | "forward"
                | "at-root"
                | "content",
        )
    )
}

/// If `logical` is a leaf directive that forbids anything indented beneath it,
/// return its keyword (without the `@`). dart-sass: `@import`, `@charset`,
/// `@return`, `@extend`, `@error`, `@warn`, `@debug` and `@content` take no
/// child block. (`@use`/`@forward` permit a continued prelude, handled
/// separately, but no body either.)
fn forbids_indented_child(logical: &str) -> Option<String> {
    match directive_name(logical).as_deref() {
        Some(
            name @ ("import" | "charset" | "return" | "extend" | "error" | "warn" | "debug" | "content"
            | "use" | "forward"),
        ) => Some(name.to_string()),
        _ => None,
    }
}

/// Whether `c` is an operator/structural character that, when it ends a prelude
/// line, demands a following operand (so the prelude continues).
fn ends_with_pending_operator(t: &str) -> bool {
    let t = t.trim_end();
    // A trailing comma does NOT continue a directive prelude or variable
    // declaration in the indented syntax (`@each $a in b,` iterates the
    // single-element list `(b,)`; `$a: 1,` + indented line is "Nothing may
    // be indented beneath a variable declaration."). Only selector lists
    // continue on a comma, handled in `assemble_logical_line`.
    if t.ends_with('\\') {
        return true;
    }
    // `@use "x" as *` / `@forward "x" as *`: the wildcard namespace ends the
    // directive — this `*` is not a pending multiplication (vuetify's
    // `@use '../settings' as *` must not swallow the next line).
    if t.ends_with("as *") {
        return false;
    }
    // Trailing binary/relational/arithmetic operators.
    for op in ["+", "-", "*", "/", "%", "<", ">", "=", ":"] {
        if t.ends_with(op) {
            return true;
        }
    }
    // Trailing keyword that requires more (case-insensitive whole word).
    let last_word: String = t
        .chars()
        .rev()
        .take_while(|c| is_ident_char(*c))
        .collect::<String>()
        .chars()
        .rev()
        .collect();
    matches!(
        last_word.to_ascii_lowercase().as_str(),
        "from"
            | "through"
            | "to"
            | "in"
            | "and"
            | "or"
            | "not"
            | "using"
            | "as"
            | "with"
            | "show"
            | "hide"
            | "if"
    )
}

/// Whether a directive prelude (the whole logical line so far) is grammatically
/// incomplete and therefore continues onto the next indented line.
fn prelude_incomplete(logical: &str) -> bool {
    // An unbalanced bracket always continues.
    if bracket_depth(logical) > 0 {
        return true;
    }
    // A `$variable` declaration continues until it has `$name: <value>` with a
    // non-empty value (`$a:` and `$a` both continue; `$a: b` is complete).
    let t = logical.trim_start();
    if t.starts_with('$') {
        if ends_with_pending_operator(t) {
            return true;
        }
        return match find_decl_colon(t) {
            Some(colon) => t[colon + 1..].trim().is_empty(),
            None => true,
        };
    }
    let Some(name) = directive_name(logical) else {
        return false;
    };
    // The prelude text after the directive keyword. A shorthand has no
    // keyword to strip — everything after `=`/`+` is the prelude, so a mixin
    // named `mixin` (`=mixin`) keeps its name rather than reading as empty.
    let t = logical.trim_start();
    let after_sigil = &t[1..]; // skip `@`, `=` or `+`
    let owned;
    let prelude = if t.starts_with(['=', '+']) {
        after_sigil.trim()
    } else {
        // The keyword may be ESCAPED, in which case the raw spelling does not
        // start with the decoded name — `@us\65` would leave `us\65` as the
        // prelude, so `@use` spanning lines (`@use` + an indented url, which
        // dart accepts) looked complete and the url was rejected as an
        // indented child. Take the text after the decoded identifier instead.
        let cs: Vec<char> = after_sigil.chars().collect();
        let (_, end) = crate::parser::decode_ident(&cs, 0);
        owned = cs[end..].iter().collect::<String>();
        owned.trim()
    };
    if ends_with_pending_operator(prelude) {
        return true;
    }
    // A prelude that spans lines carries newlines and indentation between its
    // tokens; the keyword tests below look for ` in `, ` from `, ` if ` with
    // single spaces, so compare against a whitespace-normalized copy.
    let prelude: String = if prelude.bytes().any(|b| b == b'\n') {
        prelude.split_whitespace().collect::<Vec<_>>().join(" ")
    } else {
        prelude.to_string()
    };
    let prelude = prelude.as_str();
    match name.as_str() {
        // `@for $i from <a> (through|to) <b>` — incomplete until both the
        // `from`/`through`/`to` keywords and operands are present.
        "for" => {
            let lower = prelude.to_ascii_lowercase();
            // Need the variable, `from`, an operand, `through`/`to`, an operand.
            if !lower.contains(" from ") && !lower.ends_with(" from") {
                // No `from` yet — but `@for $i` alone should continue.
                return !lower.contains("from");
            }
            // Have `from`; need `through`/`to` with an operand after it.
            let has_bound = lower.contains(" through ") || lower.contains(" to ");
            !has_bound
        }
        // `@each $v[, $k] in <list>` — incomplete until ` in ` appears.
        "each" => {
            let lower = prelude.to_ascii_lowercase();
            !(lower.contains(" in ") || lower.ends_with(" in"))
        }
        // `@if`/`@while`/`@else if` need a non-empty condition.
        "if" | "while" => prelude.is_empty(),
        "else" => {
            // `@else` is complete; `@else if` (no condition yet) needs more.
            let lower = prelude.to_ascii_lowercase();
            lower == "if" || lower.ends_with(" if")
        }
        // `@function`/`@mixin` need a name (and balanced parens if any).
        "function" | "mixin" => prelude.is_empty(),
        // `@return`/`@warn`/`@debug`/`@error`/`@extend` need an expression.
        "return" | "warn" | "debug" | "error" | "extend" => prelude.is_empty(),
        // `@include` needs a name.
        "include" => prelude.is_empty(),
        // `@use`/`@forward` member lists (`show a,`) continue on a comma —
        // their preludes treat newlines as whitespace throughout.
        "use" | "forward" if prelude.ends_with(',') => true,
        // `@use`/`@forward`/`@import` need a URL.
        "use" | "forward" | "import" => prelude.is_empty(),
        _ => false,
    }
}

/// Which empty form a child-less statement takes in the reconstructed SCSS.
enum EmptyForm {
    /// A block construct with no body: append ` {}` (style rules, `@function`,
    /// `@mixin`, `@if`/`@else`, `@each`/`@for`/`@while`, `@media`, `@supports`,
    /// `@at-root`, `@keyframes`, generic block at-rules).
    Braces,
    /// A leaf statement: append `;` (declarations, variables, `@return`,
    /// `@include` without content, `@import`/`@use`/`@forward`/`@extend`,
    /// `@content`, `@warn`/`@debug`/`@error`, `@charset`, …).
    Semicolon,
}

/// Classify the empty (child-less) form of a statement from its logical line.
///
/// dart-sass: directives that own a block always parse a block (even an empty
/// one) in `.sass`; leaf directives and declarations end at the newline. A line
/// without a directive keyword is a style rule (`{}`) unless it is a declaration
/// (`prop: value`), in which case it is a leaf (`;`).
fn empty_form(logical: &str) -> EmptyForm {
    let t = logical.trim_start();
    // An at-rule — or a mixin shorthand, which stands for one. An `@` whose
    // name is interpolated (`@#{$x} foo`) has no keyword and falls to the
    // generic arm, as before.
    if t.starts_with('@') || directive_name(t).is_some() {
        let name = directive_name(t).unwrap_or_default();
        return match name.as_str() {
            // Block-owning directives.
            "function" | "mixin" | "if" | "else" | "each" | "for" | "while" | "media" | "supports"
            | "at-root" | "keyframes" | "-webkit-keyframes" | "-moz-keyframes" | "-o-keyframes"
            | "-ms-keyframes" => EmptyForm::Braces,
            // Leaf directives. `@include` without a child content block ends at
            // the newline (a child block, if present, is its content) — unless
            // it carries a `using (…)` clause, which always takes a content
            // block (empty here), since SCSS `@include a() using ();` is
            // 'expected "{".'.
            "include" if has_top_level_using(t) => EmptyForm::Braces,
            "include" | "return" | "import" | "use" | "forward" | "extend" | "content" | "warn" | "debug"
            | "error" | "charset" => EmptyForm::Semicolon,
            // Unknown / generic at-rules (`@font-face`, `@page`, `@namespace`,
            // vendor `@-foo`, …) are statements when nothing is indented beneath
            // them (`@namespace url(x)` -> `@namespace url(x);`); a child block,
            // when present, is handled before this point.
            _ => EmptyForm::Semicolon,
        };
    }
    // A `$variable: …` declaration is a leaf.
    if t.starts_with('$') {
        return EmptyForm::Semicolon;
    }
    // Otherwise: a declaration (`prop: value`) is a leaf; a bare selector is a
    // style rule. A top-level `:` with a non-empty value -> declaration.
    if let Some(colon) = find_decl_colon(t) {
        let value = t[colon + 1..].trim();
        // `prop:` with empty value is a nested property set (a block); `prop: v`
        // is a declaration (leaf). `a:hover` (no whitespace, has a value) reads
        // as a selector in SCSS but here we have no child block, so it is a
        // child-less rule -> braces. Distinguish by whitespace after the colon.
        let after = &t[colon + 1..];
        let ws_after = after.starts_with(char::is_whitespace) || after.is_empty();
        if value.is_empty() {
            // `prop:` alone with no block is an empty declaration value.
            return EmptyForm::Semicolon;
        }
        if ws_after {
            return EmptyForm::Semicolon;
        }
        // `a:hover` style with no block -> style rule.
        return EmptyForm::Braces;
    }
    EmptyForm::Braces
}

/// Whether a logical line, as assembled so far, needs another physical line to
/// continue: an unbalanced bracket, an unterminated `#{…}` interpolation or
/// `/* … */` loud comment, or a trailing `,` or `\`.
fn continuation_pending(s: &str, comma_continues: bool) -> bool {
    let st = scan_state(s);
    if st.bracket_depth > 0 || st.in_interp || st.in_loud_comment {
        return true;
    }
    // Trailing complete loud comments are invisible to continuation
    // detection (`a, /* c */` still continues the selector list).
    let t = trim_trailing_loud_comments(s);
    if t.ends_with('\\') {
        return true;
    }
    // A trailing `!` awaits its `important` keyword on the next line
    // (`b: c!` + `important` joins; dart errors `Expected "important".`
    // when the next line is something else, which the joined SCSS parse
    // reproduces).
    if t.ends_with('!') {
        return true;
    }
    comma_continues && t.ends_with(',')
}

/// A single-pass cursor over a `.sass` logical line's chars.
///
/// The indented-syntax line analysis needs to scan a line while *skipping over*
/// quoted strings, `#{…}` interpolation and `/* … */` loud comments in eight
/// slightly different queries (top-level comma split, declaration `:`, statement
/// `;`, bracket depth, `@include … using`, …). The top-level dispatch differs
/// per query, but the three skip sub-loops — the byte-accounting,
/// escape-handling, brace-matching parts where bugs hide — are identical. This
/// cursor owns the one `Vec<char>` allocation and centralises those three
/// primitives. It tracks both a char index (`i`) and the matching byte offset
/// (`byte`) so byte-indexing callers (`find_decl_colon`,
/// `find_top_level_semicolon`, `strip_silent_comment`) and char-only callers
/// share one implementation.
struct LineScanner {
    cs: Vec<char>,
    /// Char index of the cursor.
    i: usize,
    /// Byte offset corresponding to `i` — maintained only for non-ASCII input
    /// (see [`LineScanner::offset`]); left at 0 on the common all-ASCII path,
    /// where the byte offset equals the char index.
    byte: usize,
    /// Whether the line is pure ASCII (byte offset == char index, so the
    /// per-char `len_utf8` bookkeeping in [`bump`](Self::bump) is skippable).
    ascii: bool,
}

impl LineScanner {
    fn new(s: &str) -> Self {
        LineScanner {
            cs: s.chars().collect(),
            i: 0,
            byte: 0,
            ascii: s.is_ascii(),
        }
    }

    #[inline]
    fn done(&self) -> bool {
        self.i >= self.cs.len()
    }

    /// The char under the cursor. Caller must ensure `!done()`.
    #[inline]
    fn cur(&self) -> char {
        self.cs[self.i]
    }

    /// The char `k` positions ahead, or `None` past the end.
    #[inline]
    fn peek(&self, k: usize) -> Option<char> {
        self.cs.get(self.i + k).copied()
    }

    /// The byte offset of the cursor into the original `&str`. On all-ASCII
    /// input this is just the char index; otherwise it is the tracked sum.
    #[inline]
    fn offset(&self) -> usize {
        if self.ascii {
            self.i
        } else {
            self.byte
        }
    }

    /// Advance one char, keeping the byte offset in step (skipped on the
    /// all-ASCII fast path, where `offset()` reads the char index directly).
    #[inline]
    fn bump(&mut self) {
        if !self.ascii {
            self.byte += self.cs[self.i].len_utf8();
        }
        self.i += 1;
    }

    /// At an opening quote: advance past the matching closing quote (honouring
    /// `\`-escapes), or to end-of-line if the string is unterminated. Returns
    /// `true` iff the string was terminated on this line.
    #[inline]
    fn skip_quoted(&mut self) -> bool {
        let q = self.cur();
        self.bump(); // opening quote
        while self.i < self.cs.len() && self.cs[self.i] != q {
            // A backslash escapes the next char (which may be the quote).
            if self.cs[self.i] == '\\' && self.i + 1 < self.cs.len() {
                self.bump();
            }
            self.bump();
        }
        if self.i < self.cs.len() {
            self.bump(); // closing quote
            true
        } else {
            false
        }
    }

    /// At `#{`: advance past the brace-matched closing `}` (or to end-of-line).
    #[inline]
    fn skip_interp(&mut self) {
        self.bump(); // '#'
        self.bump(); // '{'
        let mut depth = 1;
        while self.i < self.cs.len() && depth > 0 {
            match self.cs[self.i] {
                // A brace inside a STRING or behind an escape is not a
                // delimiter: `#{"} // not a comment"}` closes at its last
                // brace, and the `//` inside the string is value text. The
                // shared expression parser reads it that way, and so does dart.
                '"' | '\'' => {
                    self.skip_quoted();
                    continue;
                }
                '\\' => {
                    self.bump();
                    if !self.done() {
                        self.bump();
                    }
                    continue;
                }
                '{' => depth += 1,
                '}' => depth -= 1,
                _ => {}
            }
            self.bump();
        }
    }

    /// Whether a `url(` FUNCTION token's identifier covers the cursor, and if
    /// so how many characters from the cursor through its `(`.
    ///
    /// dart scans `url(` and its contents as one token, so `//` inside it is
    /// part of the url rather than a comment (`url(//cdn/x.png)`,
    /// `url(http://x/y)`). The name is matched the way the shared value parser
    /// matches it ([`crate::parser::is_url_function`]): `url` itself, a
    /// VENDOR-PREFIXED `-c-url`, and either spelled with CSS escapes
    /// (`u\72l(`) — but not `my-url(`, an ordinary function where the `//`
    /// really does start a comment.
    ///
    /// Called at every character, and cheap: it returns immediately unless the
    /// cursor is at the first character of an identifier, so each identifier on
    /// a line is scanned at most once.
    fn url_func_open(&self) -> Option<usize> {
        // Only at the START of an identifier, so each one is scanned once as
        // the cursor passes it and the walk stays linear in the line's length.
        let cur = *self.cs.get(self.i)?;
        if !(is_ident_char(cur) || cur == '\\') {
            return None;
        }
        if self.i > 0 && (is_ident_char(self.cs[self.i - 1]) || self.cs[self.i - 1] == '\\') {
            return None;
        }
        // Walk the identifier WITHOUT allocating first: most of them are
        // ordinary names, and one that is not followed by `(` cannot be a url
        // however it is spelled.
        let mut k = self.i;
        let mut escaped = false;
        while let Some(&c) = self.cs.get(k) {
            if c == '\\' {
                escaped = true;
                break;
            }
            if is_ident_char(c) {
                k += 1;
                continue;
            }
            break;
        }
        if !escaped {
            return (self.cs.get(k) == Some(&'(') && plain_name_is_url(&self.cs[self.i..k]))
                .then(|| k + 1 - self.i);
        }
        // Only an escaped name needs decoding.
        let (name, k) = crate::parser::decode_ident(&self.cs, self.i);
        if self.cs.get(k) != Some(&'(') {
            return None;
        }
        crate::parser::is_url_function(&name).then(|| k + 1 - self.i)
    }

    /// Consume a `url(...)` token, contents included, through its closing `)`.
    /// Quoted contents are skipped as strings, so `url("a)b")` ends at the
    /// right paren.
    ///
    /// Returns whether the token CLOSED on this line. An unclosed one — the
    /// indented syntax allows `b: url(` to continue onto the next line — leaves
    /// its open paren unaccounted for, so a caller that tracks bracket depth
    /// must count it, or the logical line would end here.
    fn skip_url(&mut self, open: usize) -> bool {
        for _ in 0..open {
            self.bump(); // through the `(`
        }
        let mut depth = 1i32;
        while !self.done() {
            match self.cur() {
                '"' | '\'' => {
                    self.skip_quoted();
                }
                // A CSS escape: the next character is url CONTENT, so an
                // escaped paren does not close the token (`url(foo\)//cdn)`),
                // as the shared value parser reads it.
                '\\' => {
                    self.bump();
                    if !self.done() {
                        self.bump();
                    }
                }
                '(' => {
                    depth += 1;
                    self.bump();
                }
                ')' => {
                    depth -= 1;
                    self.bump();
                    if depth == 0 {
                        return true;
                    }
                }
                _ => self.bump(),
            }
        }
        false
    }

    /// At `/*`: advance past the closing `*/` (or to end-of-line). Returns
    /// `true` iff the comment closed on this line.
    #[inline]
    fn skip_loud_comment(&mut self) -> bool {
        self.bump(); // '/'
        self.bump(); // '*'
        while self.i + 1 < self.cs.len() && !(self.cs[self.i] == '*' && self.cs[self.i + 1] == '/') {
            self.bump();
        }
        if self.i + 1 < self.cs.len() {
            self.bump(); // '*'
            self.bump(); // '/'
            true
        } else {
            false
        }
    }
}

/// Whether a declaration value ends mid-expression with a binary operator
/// awaiting its right operand on the next line (`3 %`, `3 +`, `true and`,
/// `3 /`, `c -`). A `-` directly attached to an identifier character is part
/// of the identifier (`c-` does not continue); `=` only continues as part of
/// a comparison (`==`, `<=`, `>=`, `!=`).
fn ends_with_value_operator(s: &str) -> bool {
    let t = trim_trailing_loud_comments(s);
    if t.ends_with("==") || t.ends_with("<=") || t.ends_with(">=") || t.ends_with("!=") {
        return true;
    }
    if let Some(rest) = t.strip_suffix('-') {
        let prev = rest.chars().next_back();
        return !matches!(prev, Some(p) if is_ident_char(p));
    }
    if let Some(rest) = t.strip_suffix('%') {
        // `3%` is a percent unit (complete); only a detached `%` is the
        // modulo operator awaiting its right operand.
        let prev = rest.chars().next_back();
        return matches!(prev, Some(p) if p.is_whitespace());
    }
    if let Some(c) = t.chars().next_back() {
        if matches!(c, '+' | '*' | '/' | '<' | '>') {
            return true;
        }
    }
    // Trailing keyword operator (whole word, case-insensitive).
    let last_word: String = t
        .chars()
        .rev()
        .take_while(|c| is_ident_char(*c))
        .collect::<String>()
        .chars()
        .rev()
        .collect();
    if last_word.len() < t.trim_end().len() {
        // Must be preceded by whitespace/boundary to be the operator word.
        let before = &t[..t.len() - last_word.len()];
        if !before.ends_with(char::is_whitespace) {
            return false;
        }
    }
    matches!(last_word.to_ascii_lowercase().as_str(), "and" | "or" | "not")
}

/// Strip any run of complete trailing `/* … */` comments (and the whitespace
/// before them) from `s`.
fn trim_trailing_loud_comments(s: &str) -> &str {
    let mut t = s.trim_end();
    while t.ends_with("*/") {
        let Some(open) = t.rfind("/*") else {
            break;
        };
        // Only a comment that closes at the very end qualifies (the `*/` we
        // saw must belong to this `/*`).
        //
        // The length check comes first and is load-bearing: in `/*/` the opening
        // `/*` and the closing `*/` OVERLAP on the shared `*`, so `open + 2`
        // runs past `t.len() - 2` and the interior slice panics with
        // "byte range starts at N but ends at N-1". An overlapping pair is not a
        // completed comment, so stop trimming and let the parser report on the
        // text as written (dart-sass emits a normal parse error here).
        if open + 2 > t.len() - 2 {
            break;
        }
        if !t[open..].ends_with("*/") || t[open + 2..t.len() - 2].contains("/*") {
            break;
        }
        t = t[..open].trim_end();
    }
    t
}

/// Strip a trailing `//` silent comment from a single line, respecting quoted
/// strings, `#{…}` interpolation and `/* */` loud comments (a `//` inside a
/// loud comment is not a silent comment). Returns the line with the comment (if
/// any) removed and trailing whitespace trimmed.
fn strip_silent_comment(s: &str) -> String {
    let mut sc = LineScanner::new(s);
    while !sc.done() {
        // `url(…)` is one token: `//` inside it is part of the url.
        if let Some(open) = sc.url_func_open() {
            let _closed = sc.skip_url(open);
            continue;
        }
        match sc.cur() {
            '"' | '\'' => {
                sc.skip_quoted();
            }
            // A loud comment: skip to its close (it may not close on this line,
            // in which case the rest is comment body — leave it).
            '/' if sc.peek(1) == Some('*') => {
                sc.skip_loud_comment();
            }
            '/' if sc.peek(1) == Some('/') => {
                return s[..sc.offset()].trim_end().to_string();
            }
            '#' if sc.peek(1) == Some('{') => {
                sc.skip_interp();
            }
            _ => sc.bump(),
        }
    }
    s.trim_end().to_string()
}

/// [`strip_silent_comment`] for a STATEMENT's first line, honouring the
/// indented syntax's unquoted `@import` urls.
///
/// dart's `SassParser.importArgument` reads an unquoted url with
/// `almostAnyValue`, so it runs to the next top-level comma and swallows
/// whatever is in the way: `@import foo // c` imports the url `foo // c`
/// (dart carets all eight characters), and `@import http://x/y.css` is one
/// protocol url, not `http:` followed by a comment. A QUOTED url ends at its
/// closing quote, so the `// c` after `@import "foo" // c` is an ordinary
/// comment, dropped as everywhere else.
fn strip_statement_comment(s: &str) -> String {
    if directive_name(s).as_deref() != Some("import") {
        return strip_silent_comment(s);
    }
    let mut sc = LineScanner::new(s);
    // Past `@import` itself — through the DECODED keyword, since it may be
    // escaped (`@im\70ort`). Advancing over raw identifier characters left the
    // cursor inside the escape, so the first argument was not seen as quoted
    // and a trailing comment was kept on the line.
    sc.bump();
    let (_, end) = crate::parser::decode_ident(&sc.cs, sc.i);
    while sc.i < end {
        sc.bump();
    }
    loop {
        while !sc.done() && sc.cur().is_whitespace() {
            sc.bump();
        }
        if sc.done() {
            break;
        }
        // A bare url is literal to the next top-level comma; after a quoted
        // one, the modifier region scans for comments as usual.
        let quoted = matches!(sc.cur(), '"' | '\'');
        if quoted {
            sc.skip_quoted();
        }
        let mut depth = 0i32;
        while !sc.done() {
            if let Some(open) = sc.url_func_open() {
                let _closed = sc.skip_url(open);
                continue;
            }
            match sc.cur() {
                '"' | '\'' => {
                    sc.skip_quoted();
                }
                '#' if sc.peek(1) == Some('{') => sc.skip_interp(),
                '/' if quoted && sc.peek(1) == Some('*') => {
                    sc.skip_loud_comment();
                }
                '/' if quoted && sc.peek(1) == Some('/') => {
                    return s[..sc.offset()].trim_end().to_string();
                }
                '(' | '[' => {
                    depth += 1;
                    sc.bump();
                }
                ')' | ']' => {
                    depth -= 1;
                    sc.bump();
                }
                // The STATEMENT ends here, so the url does: anything after it
                // is ordinary text, and a trailing `// t` is a comment (dart
                // imports `foo` from `@import foo; // t`).
                ';' if depth == 0 => {
                    let head = &s[..sc.offset()];
                    let tail = strip_silent_comment(&s[sc.offset()..]);
                    let mut out = String::with_capacity(head.len() + tail.len());
                    out.push_str(head);
                    out.push_str(&tail);
                    return out.trim_end().to_string();
                }
                ',' if depth == 0 => {
                    sc.bump();
                    break;
                }
                _ => sc.bump(),
            }
        }
    }
    s.trim_end().to_string()
}

/// Net bracket depth of `s` ignoring strings, `//`/`/* */` comments and `#{}`
/// interpolation.
fn bracket_depth(s: &str) -> i32 {
    scan_state(s).bracket_depth
}

/// The "openness" of a logical line: how many brackets remain open, whether the
/// line ends inside an unterminated `#{…}` interpolation, and whether it ends
/// inside an unterminated `/* … */` loud comment.
struct ScanState {
    bracket_depth: i32,
    in_interp: bool,
    in_loud_comment: bool,
    /// The line ends inside an unterminated quoted string.
    in_string: bool,
    /// The line ends inside an unterminated `url(…)` token. Its contents are
    /// not Sass: the continuation line joins VERBATIM, so a `//` in
    /// `url(` + `  http://x/y)` is part of the url, not a comment.
    in_url: bool,
}

/// Scan `s` once, tracking strings, `//`/`/* */` comments and `#{…}`
/// interpolation, to report its closing state.
/// Whether a custom-property value ends with an open `(`/`[`/`{` bracket or
/// `#{` interpolation (so the next line continues it verbatim). Quoted
/// strings are skipped; a custom value's braces count as brackets.
fn custom_value_open(s: &str) -> bool {
    // A line ending in an UNPAIRED backslash always continues: the escape
    // needs the next character, whether that makes a string continuation
    // (`--x: "a\` — legal, the pair vanishes) or the error dart reports for
    // one anywhere else (`--x: c\`). Either way the pair has to reach the
    // parser rather than being cut off at the line end.
    if trailing_backslashes(s) % 2 == 1 {
        return true;
    }
    let mut sc = LineScanner::new(s);
    let mut brackets: Vec<char> = Vec::new();
    while !sc.done() {
        match sc.cur() {
            '"' | '\'' => {
                sc.skip_quoted();
            }
            // An ESCAPED delimiter is literal text, not a bracket: `--x: \{`
            // is a complete value, and counting it left the value "open" so
            // every following line was swallowed into it.
            '\\' => {
                sc.bump();
                if !sc.done() {
                    sc.bump();
                }
            }
            // A custom value's braces count as brackets (so an `#{` is just an
            // open brace here, not interpolation).
            '(' | '[' | '{' => {
                brackets.push(match sc.cur() {
                    '(' => ')',
                    '[' => ']',
                    _ => '}',
                });
                sc.bump();
            }
            ')' | ']' | '}' => {
                match brackets.last().copied() {
                    // A closer with no opener ends the value, as it does in the
                    // shared parser.
                    None => return false,
                    // A MISMATCHED closer is an error there, so the value stays
                    // open and the next line joins it: the shared parser then
                    // reports dart's `expected ")".` at the closer, rather than
                    // the front-end reporting a stray indented child.
                    Some(expected) if expected != sc.cur() => return true,
                    Some(_) => {
                        brackets.pop();
                    }
                }
                sc.bump();
            }
            _ => sc.bump(),
        }
    }
    !brackets.is_empty()
}

/// Whether `s` ends inside an open `#{` interpolation, scanning *inside*
/// loud-comment text too (unlike [`scan_state`], which skips comment bodies):
/// a `#{` opens interpolation even within `/* … */`.
fn interp_open_anywhere(s: &str) -> bool {
    let mut sc = LineScanner::new(s);
    let mut interp = 0i32;
    while !sc.done() {
        match sc.cur() {
            // Quoted strings only have meaning inside interpolation here.
            '"' | '\'' if interp > 0 => {
                sc.skip_quoted();
            }
            // Counted (not skipped-to-close) so an *unclosed* `#{` is detected.
            '#' if sc.peek(1) == Some('{') => {
                interp += 1;
                sc.bump();
                sc.bump();
            }
            '{' if interp > 0 => {
                interp += 1;
                sc.bump();
            }
            '}' if interp > 0 => {
                interp -= 1;
                sc.bump();
            }
            _ => sc.bump(),
        }
    }
    interp > 0
}

fn scan_state(s: &str) -> ScanState {
    let mut sc = LineScanner::new(s);
    let mut depth = 0i32;
    // Stack of `#{` interpolation brace depths still open.
    let mut interp_depth = 0i32;
    while !sc.done() {
        // `url(…)` is one token (dart scans it whole), so neither the `//`
        // inside `url(http://x/y)` nor its parens are structure — unless the
        // token never closes on this line (`b: url(` + `    c)`), whose open
        // paren still continues the logical line.
        if let Some(open) = sc.url_func_open() {
            if !sc.skip_url(open) {
                // Unclosed on this line: its `(` is still open, and its
                // contents continue verbatim onto the next line.
                depth += 1;
                return ScanState {
                    bracket_depth: depth,
                    in_interp: interp_depth > 0,
                    in_loud_comment: false,
                    in_string: false,
                    in_url: true,
                };
            }
            continue;
        }
        match sc.cur() {
            '"' | '\'' => {
                if !sc.skip_quoted() {
                    // Unterminated quoted string at end of line.
                    return ScanState {
                        bracket_depth: depth,
                        in_interp: interp_depth > 0,
                        in_loud_comment: false,
                        in_string: true,
                        in_url: false,
                    };
                }
            }
            '/' if sc.peek(1) == Some('/') => break,
            '/' if sc.peek(1) == Some('*') => {
                if !sc.skip_loud_comment() {
                    // Reached end of line without closing the loud comment.
                    return ScanState {
                        bracket_depth: depth,
                        in_interp: interp_depth > 0,
                        in_loud_comment: true,
                        in_string: false,
                        in_url: false,
                    };
                }
            }
            // Counted (not skipped-to-close) so an *unclosed* `#{` is reported.
            '#' if sc.peek(1) == Some('{') => {
                interp_depth += 1;
                sc.bump();
                sc.bump();
            }
            '{' if interp_depth > 0 => {
                interp_depth += 1;
                sc.bump();
            }
            '}' if interp_depth > 0 => {
                interp_depth -= 1;
                sc.bump();
            }
            '(' | '[' => {
                depth += 1;
                sc.bump();
            }
            ')' | ']' => {
                depth -= 1;
                sc.bump();
            }
            _ => sc.bump(),
        }
    }
    ScanState {
        bracket_depth: depth,
        in_interp: interp_depth > 0,
        in_loud_comment: false,
        in_string: false,
        in_url: false,
    }
}

/// Find the byte index of the top-level declaration colon in `logical` (the
/// `:` separating a property/custom-property name from its value), skipping
/// strings, brackets, comments and interpolation. Returns `None` if absent.
fn find_decl_colon(logical: &str) -> Option<usize> {
    let mut sc = LineScanner::new(logical);
    let mut paren = 0i32;
    let mut bracket = 0i32;
    while !sc.done() {
        match sc.cur() {
            '"' | '\'' => {
                sc.skip_quoted();
            }
            '#' if sc.peek(1) == Some('{') => {
                sc.skip_interp();
            }
            '(' => {
                paren += 1;
                sc.bump();
            }
            ')' => {
                paren -= 1;
                sc.bump();
            }
            '[' => {
                bracket += 1;
                sc.bump();
            }
            ']' => {
                bracket -= 1;
                sc.bump();
            }
            ':' if paren == 0 && bracket == 0 => return Some(sc.offset()),
            _ => sc.bump(),
        }
    }
    None
}

/// Byte index of the first top-level `;` in `logical` (outside strings,
/// brackets, `#{…}` interpolation and `/* */` comments), or `None`. A single
/// trailing `;` ends a statement; a `;` with further content is "multiple
/// statements on one line", which the indented syntax forbids.
/// Whether an `@include` logical line carries a top-level `using` keyword
/// (outside brackets and strings) — i.e. a content-block parameter clause.
fn has_top_level_using(logical: &str) -> bool {
    let mut sc = LineScanner::new(logical);
    let mut depth = 0i32;
    while !sc.done() {
        match sc.cur() {
            '"' | '\'' => {
                sc.skip_quoted();
            }
            '(' | '[' => {
                depth += 1;
                sc.bump();
            }
            ')' | ']' => {
                depth -= 1;
                sc.bump();
            }
            'u' | 'U' if depth == 0 => {
                let prev_ident = sc.i > 0 && is_ident_char(sc.cs[sc.i - 1]);
                let word: String = sc.cs[sc.i..].iter().take_while(|c| is_ident_char(**c)).collect();
                if !prev_ident && word.eq_ignore_ascii_case("using") {
                    return true;
                }
                // Skip the whole identifier run (at least one char, since the
                // cursor is on `u`/`U`).
                for _ in 0..word.len().max(1) {
                    sc.bump();
                }
            }
            _ => sc.bump(),
        }
    }
    false
}

fn find_top_level_semicolon(logical: &str) -> Option<usize> {
    let mut sc = LineScanner::new(logical);
    let mut paren = 0i32;
    let mut bracket = 0i32;
    while !sc.done() {
        // `url(…)` is one token (dart scans it whole), so neither the `//`
        // inside `url(http://x/y)` nor its parens are structure. An unclosed
        // one runs to the end of the line, where this scan would stop anyway.
        if let Some(open) = sc.url_func_open() {
            let _closed = sc.skip_url(open);
            continue;
        }
        match sc.cur() {
            '"' | '\'' => {
                sc.skip_quoted();
            }
            '/' if sc.peek(1) == Some('/') => break,
            '/' if sc.peek(1) == Some('*') => {
                sc.skip_loud_comment();
            }
            '#' if sc.peek(1) == Some('{') => {
                sc.skip_interp();
            }
            '(' => {
                paren += 1;
                sc.bump();
            }
            ')' => {
                paren -= 1;
                sc.bump();
            }
            '[' => {
                bracket += 1;
                sc.bump();
            }
            ']' => {
                bracket -= 1;
                sc.bump();
            }
            ';' if paren == 0 && bracket == 0 => return Some(sc.offset()),
            _ => sc.bump(),
        }
    }
    None
}

#[cfg(test)]
mod line_scanner_parity {
    //! Parity oracle for the `LineScanner` refactor (refactor round-2 T1.1).
    //!
    //! Each of the eight `.sass` line-analysis queries used to hand-roll its own
    //! quote / `#{…}` / `/* */` skipping loop; they were collapsed onto the one
    //! [`super::LineScanner`] cursor. To guarantee that collapse is byte-exact,
    //! the pre-refactor implementations are preserved verbatim below (suffixed
    //! `_ref`) and a differential test asserts the live functions agree with
    //! them over a broad corpus of tricky inputs (escapes, unterminated strings
    //! and comments, nested interpolation, multibyte chars). If a future change
    //! to `LineScanner` diverges from the original semantics, this fails.

    fn strip_silent_comment_ref(s: &str) -> String {
        let cs: Vec<char> = s.chars().collect();
        let mut i = 0;
        let mut byte = 0usize;
        while i < cs.len() {
            let c = cs[i];
            match c {
                '"' | '\'' => {
                    let q = c;
                    byte += c.len_utf8();
                    i += 1;
                    while i < cs.len() && cs[i] != q {
                        if cs[i] == '\\' && i + 1 < cs.len() {
                            byte += cs[i].len_utf8();
                            i += 1;
                        }
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    if i < cs.len() {
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    continue;
                }
                '/' if cs.get(i + 1) == Some(&'*') => {
                    byte += 2;
                    i += 2;
                    while i + 1 < cs.len() && !(cs[i] == '*' && cs[i + 1] == '/') {
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    if i + 1 < cs.len() {
                        byte += 2;
                        i += 2;
                    }
                    continue;
                }
                '/' if cs.get(i + 1) == Some(&'/') => {
                    return s[..byte].trim_end().to_string();
                }
                '#' if cs.get(i + 1) == Some(&'{') => {
                    byte += c.len_utf8() + '{'.len_utf8();
                    i += 2;
                    let mut d = 1;
                    while i < cs.len() && d > 0 {
                        match cs[i] {
                            // A brace inside a string, or behind an escape, is
                            // text rather than a delimiter.
                            q @ ('"' | '\'') => {
                                byte += cs[i].len_utf8();
                                i += 1;
                                while i < cs.len() && cs[i] != q {
                                    if cs[i] == '\\' && i + 1 < cs.len() {
                                        byte += cs[i].len_utf8();
                                        i += 1;
                                    }
                                    byte += cs[i].len_utf8();
                                    i += 1;
                                }
                                if i < cs.len() {
                                    byte += cs[i].len_utf8();
                                    i += 1;
                                }
                                continue;
                            }
                            '\\' => {
                                byte += cs[i].len_utf8();
                                i += 1;
                                if i < cs.len() {
                                    byte += cs[i].len_utf8();
                                    i += 1;
                                }
                                continue;
                            }
                            '{' => d += 1,
                            '}' => d -= 1,
                            _ => {}
                        }
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    continue;
                }
                _ => {}
            }
            byte += c.len_utf8();
            i += 1;
        }
        s.trim_end().to_string()
    }

    fn custom_value_open_ref(s: &str) -> bool {
        let cs: Vec<char> = s.chars().collect();
        if cs.iter().rev().take_while(|&&c| c == '\\').count() % 2 == 1 {
            return true;
        }
        let mut brackets: Vec<char> = Vec::new();
        let mut i = 0;
        while i < cs.len() {
            match cs[i] {
                '"' | '\'' => {
                    let q = cs[i];
                    i += 1;
                    while i < cs.len() && cs[i] != q {
                        if cs[i] == '\\' {
                            i += 1;
                        }
                        i += 1;
                    }
                }
                '\\' => i += 1,
                '(' => brackets.push(')'),
                '[' => brackets.push(']'),
                '{' => brackets.push('}'),
                ')' | ']' | '}' => match brackets.last().copied() {
                    None => return false,
                    Some(expected) if expected != cs[i] => return true,
                    Some(_) => {
                        brackets.pop();
                    }
                },
                _ => {}
            }
            i += 1;
        }
        !brackets.is_empty()
    }

    fn interp_open_anywhere_ref(s: &str) -> bool {
        let cs: Vec<char> = s.chars().collect();
        let mut interp = 0i32;
        let mut i = 0;
        while i < cs.len() {
            match cs[i] {
                '"' | '\'' if interp > 0 => {
                    let q = cs[i];
                    i += 1;
                    while i < cs.len() && cs[i] != q {
                        if cs[i] == '\\' {
                            i += 1;
                        }
                        i += 1;
                    }
                }
                '#' if cs.get(i + 1) == Some(&'{') => {
                    interp += 1;
                    i += 2;
                    continue;
                }
                '{' if interp > 0 => interp += 1,
                '}' if interp > 0 => interp -= 1,
                _ => {}
            }
            i += 1;
        }
        interp > 0
    }

    /// Whether `cs[i..]` starts a `url(` FUNCTION token (the exact name, not
    /// preceded by an identifier character) — the reference twin of
    /// [`LineScanner::url_func_open`].
    fn at_url_func_ref(cs: &[char], i: usize) -> bool {
        let want = ['u', 'r', 'l', '('];
        if !(0..4).all(|k| cs.get(i + k).is_some_and(|c| c.eq_ignore_ascii_case(&want[k]))) {
            return false;
        }
        let mut start = i;
        while start > 0 && super::is_ident_char(cs[start - 1]) {
            start -= 1;
        }
        if start == i {
            return true;
        }
        let name: String = cs[start..i + 3].iter().collect();
        crate::parser::is_url_function(&name)
    }

    /// Skip a `url(…)` token from `i` (which must be at its `u`), returning the
    /// index just past its closing `)` — the reference twin of
    /// [`LineScanner::skip_url`].
    fn skip_url_ref(cs: &[char], mut i: usize) -> (usize, bool) {
        i += 4;
        let mut depth = 1i32;
        while i < cs.len() {
            match cs[i] {
                '"' | '\'' => {
                    let q = cs[i];
                    i += 1;
                    while i < cs.len() {
                        if cs[i] == '\\' {
                            i += 2;
                            continue;
                        }
                        if cs[i] == q {
                            i += 1;
                            break;
                        }
                        i += 1;
                    }
                }
                '\\' => i += 2,
                '(' => {
                    depth += 1;
                    i += 1;
                }
                ')' => {
                    depth -= 1;
                    i += 1;
                    if depth == 0 {
                        return (i, true);
                    }
                }
                _ => i += 1,
            }
        }
        (i, false)
    }

    fn scan_state_ref(s: &str) -> (i32, bool, bool, bool) {
        let cs: Vec<char> = s.chars().collect();
        let mut depth = 0i32;
        let mut interp_depth = 0i32;
        let mut i = 0;
        while i < cs.len() {
            let c = cs[i];
            if (c == 'u' || c == 'U') && at_url_func_ref(&cs, i) {
                let (next, closed) = skip_url_ref(&cs, i);
                i = next;
                if !closed {
                    depth += 1;
                }
                continue;
            }
            match c {
                '"' | '\'' => {
                    let q = c;
                    i += 1;
                    while i < cs.len() && cs[i] != q {
                        if cs[i] == '\\' {
                            i += 1;
                        }
                        i += 1;
                    }
                    if i >= cs.len() {
                        return (depth, interp_depth > 0, false, true);
                    }
                }
                '/' if cs.get(i + 1) == Some(&'/') => break,
                '/' if cs.get(i + 1) == Some(&'*') => {
                    i += 2;
                    while i + 1 < cs.len() && !(cs[i] == '*' && cs[i + 1] == '/') {
                        i += 1;
                    }
                    if i + 1 >= cs.len() && !(cs.get(i) == Some(&'*') && cs.get(i + 1) == Some(&'/')) {
                        return (depth, interp_depth > 0, true, false);
                    }
                    i += 2;
                    continue;
                }
                '#' if cs.get(i + 1) == Some(&'{') => {
                    i += 2;
                    interp_depth += 1;
                    continue;
                }
                '{' if interp_depth > 0 => interp_depth += 1,
                '}' if interp_depth > 0 => interp_depth -= 1,
                '(' | '[' => depth += 1,
                ')' | ']' => depth -= 1,
                _ => {}
            }
            i += 1;
        }
        (depth, interp_depth > 0, false, false)
    }

    fn find_decl_colon_ref(logical: &str) -> Option<usize> {
        let cs: Vec<char> = logical.chars().collect();
        let mut byte = 0usize;
        let mut paren = 0i32;
        let mut bracket = 0i32;
        let mut i = 0;
        while i < cs.len() {
            let c = cs[i];
            match c {
                '"' | '\'' => {
                    let q = c;
                    byte += c.len_utf8();
                    i += 1;
                    while i < cs.len() && cs[i] != q {
                        if cs[i] == '\\' {
                            byte += cs[i].len_utf8();
                            i += 1;
                        }
                        if i < cs.len() {
                            byte += cs[i].len_utf8();
                            i += 1;
                        }
                    }
                    if i < cs.len() {
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    continue;
                }
                '#' if cs.get(i + 1) == Some(&'{') => {
                    byte += c.len_utf8() + '{'.len_utf8();
                    i += 2;
                    let mut d = 1;
                    while i < cs.len() && d > 0 {
                        match cs[i] {
                            // A brace inside a string, or behind an escape, is
                            // text rather than a delimiter.
                            q @ ('"' | '\'') => {
                                byte += cs[i].len_utf8();
                                i += 1;
                                while i < cs.len() && cs[i] != q {
                                    if cs[i] == '\\' && i + 1 < cs.len() {
                                        byte += cs[i].len_utf8();
                                        i += 1;
                                    }
                                    byte += cs[i].len_utf8();
                                    i += 1;
                                }
                                if i < cs.len() {
                                    byte += cs[i].len_utf8();
                                    i += 1;
                                }
                                continue;
                            }
                            '\\' => {
                                byte += cs[i].len_utf8();
                                i += 1;
                                if i < cs.len() {
                                    byte += cs[i].len_utf8();
                                    i += 1;
                                }
                                continue;
                            }
                            '{' => d += 1,
                            '}' => d -= 1,
                            _ => {}
                        }
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    continue;
                }
                '(' => paren += 1,
                ')' => paren -= 1,
                '[' => bracket += 1,
                ']' => bracket -= 1,
                ':' if paren == 0 && bracket == 0 => return Some(byte),
                _ => {}
            }
            byte += c.len_utf8();
            i += 1;
        }
        None
    }

    fn has_top_level_using_ref(logical: &str) -> bool {
        let cs: Vec<char> = logical.chars().collect();
        let mut depth = 0i32;
        let mut i = 0;
        while i < cs.len() {
            match cs[i] {
                '"' | '\'' => {
                    let q = cs[i];
                    i += 1;
                    while i < cs.len() && cs[i] != q {
                        if cs[i] == '\\' {
                            i += 1;
                        }
                        i += 1;
                    }
                }
                '(' | '[' => depth += 1,
                ')' | ']' => depth -= 1,
                'u' | 'U' if depth == 0 => {
                    let prev_ident = i > 0 && super::is_ident_char(cs[i - 1]);
                    let word: String = cs[i..].iter().take_while(|c| super::is_ident_char(**c)).collect();
                    if !prev_ident && word.eq_ignore_ascii_case("using") {
                        return true;
                    }
                    i += word.len().max(1);
                    continue;
                }
                _ => {}
            }
            i += 1;
        }
        false
    }

    fn find_top_level_semicolon_ref(logical: &str) -> Option<usize> {
        let cs: Vec<char> = logical.chars().collect();
        let mut paren = 0i32;
        let mut bracket = 0i32;
        let mut byte = 0usize;
        let mut i = 0;
        while i < cs.len() {
            let c = cs[i];
            match c {
                '"' | '\'' => {
                    let q = c;
                    byte += c.len_utf8();
                    i += 1;
                    while i < cs.len() && cs[i] != q {
                        if cs[i] == '\\' && i + 1 < cs.len() {
                            byte += cs[i].len_utf8();
                            i += 1;
                        }
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    if i < cs.len() {
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    continue;
                }
                '/' if cs.get(i + 1) == Some(&'/') => break,
                '/' if cs.get(i + 1) == Some(&'*') => {
                    byte += 2;
                    i += 2;
                    while i + 1 < cs.len() && !(cs[i] == '*' && cs[i + 1] == '/') {
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    if i + 1 < cs.len() {
                        byte += 2;
                        i += 2;
                    }
                    continue;
                }
                '#' if cs.get(i + 1) == Some(&'{') => {
                    byte += c.len_utf8() + '{'.len_utf8();
                    i += 2;
                    let mut d = 1;
                    while i < cs.len() && d > 0 {
                        match cs[i] {
                            // A brace inside a string, or behind an escape, is
                            // text rather than a delimiter.
                            q @ ('"' | '\'') => {
                                byte += cs[i].len_utf8();
                                i += 1;
                                while i < cs.len() && cs[i] != q {
                                    if cs[i] == '\\' && i + 1 < cs.len() {
                                        byte += cs[i].len_utf8();
                                        i += 1;
                                    }
                                    byte += cs[i].len_utf8();
                                    i += 1;
                                }
                                if i < cs.len() {
                                    byte += cs[i].len_utf8();
                                    i += 1;
                                }
                                continue;
                            }
                            '\\' => {
                                byte += cs[i].len_utf8();
                                i += 1;
                                if i < cs.len() {
                                    byte += cs[i].len_utf8();
                                    i += 1;
                                }
                                continue;
                            }
                            '{' => d += 1,
                            '}' => d -= 1,
                            _ => {}
                        }
                        byte += cs[i].len_utf8();
                        i += 1;
                    }
                    continue;
                }
                '(' => paren += 1,
                ')' => paren -= 1,
                '[' => bracket += 1,
                ']' => bracket -= 1,
                ';' if paren == 0 && bracket == 0 => return Some(byte),
                _ => {}
            }
            byte += c.len_utf8();
            i += 1;
        }
        None
    }

    /// A broad corpus exercising every branch + edge case of the eight scanners.
    fn corpus() -> Vec<String> {
        let fragments = [
            "",
            "a, b, c",
            "color: red",
            "foo: bar; baz: qux",
            "@include thing($a, $b) using ($c)",
            "@include thing(using: 1)",
            "url(a, b)",
            "\"a, b\", c",
            "'a; b': c",
            "a: \"unterminated",
            "a: 'half \\' quote'",
            "a: \"esc \\\" still in\", b",
            "trailing backslash \\",
            "trailing backslash in str \"x\\",
            "map: (a: 1, b: 2)",
            "list: [1, 2, 3]",
            "nested: (a: (b: c), d: [e, f])",
            "interp: #{1 + 2}px",
            "interp colon #{$a: b}",
            "unclosed interp #{1 + 2",
            "nested interp #{ #{x} }",
            "interp with brace #{ {a} }",
            "interp with quoted brace #{ \"}\" }",
            "interp with quoted comment #{\"} // no\"}",
            "interp with quoted semicolon #{\"; \"}: v",
            "interp with escaped brace #{ \\} }",
            "custom escaped brace --x: \\{",
            "custom escaped quote --x: \\\"",
            "custom escaped semicolon --x: a\\;b",
            "interp in comment /* #{x} */",
            "// just a comment",
            "value // trailing comment",
            "value /* loud */ more",
            "value /* unclosed loud",
            "a: b /* c */ // d",
            "/* #{x} */ : y",
            "weird: a:b:c",
            "深: 値; другой: значение",
            "emoji 😀: 🎉, x",
            "multi 字\\符 byte",
            "semi inside (a; b); real",
            "colon inside [a:b]: outside",
            "@media screen",
            "$var: value",
            "url(\"x; y\")",
            "a\\:escaped colon: v",
            "#{} : after empty interp",
            "} stray close",
            ") stray paren",
            "using",
            "  using  ",
            "foousing: 1",
            "x using y",
            "\"\"",
            "''",
            "()",
            "#{",
            "/*",
            "*/",
            "//",
        ];
        fragments.iter().map(|s| s.to_string()).collect()
    }

    #[test]
    fn line_scanner_matches_reference_implementations() {
        for s in corpus() {
            let s = s.as_str();
            assert_eq!(
                super::strip_silent_comment(s),
                strip_silent_comment_ref(s),
                "strip_silent_comment diverged on {s:?}"
            );
            assert_eq!(
                super::custom_value_open(s),
                custom_value_open_ref(s),
                "custom_value_open diverged on {s:?}"
            );
            assert_eq!(
                super::interp_open_anywhere(s),
                interp_open_anywhere_ref(s),
                "interp_open_anywhere diverged on {s:?}"
            );
            let st = super::scan_state(s);
            assert_eq!(
                (st.bracket_depth, st.in_interp, st.in_loud_comment, st.in_string),
                scan_state_ref(s),
                "scan_state diverged on {s:?}"
            );
            assert_eq!(
                super::find_decl_colon(s),
                find_decl_colon_ref(s),
                "find_decl_colon diverged on {s:?}"
            );
            assert_eq!(
                super::has_top_level_using(s),
                has_top_level_using_ref(s),
                "has_top_level_using diverged on {s:?}"
            );
            assert_eq!(
                super::find_top_level_semicolon(s),
                find_top_level_semicolon_ref(s),
                "find_top_level_semicolon diverged on {s:?}"
            );
        }
    }

    /// Any byte offset the scanners return must land on a UTF-8 char boundary of
    /// the input (a guard against the byte/char-index bookkeeping drifting).
    #[test]
    fn returned_byte_offsets_are_char_boundaries() {
        for s in corpus() {
            let s = s.as_str();
            if let Some(b) = super::find_decl_colon(s) {
                assert!(
                    s.is_char_boundary(b),
                    "find_decl_colon offset {b} not a boundary in {s:?}"
                );
            }
            if let Some(b) = super::find_top_level_semicolon(s) {
                assert!(
                    s.is_char_boundary(b),
                    "find_top_level_semicolon offset {b} not a boundary in {s:?}"
                );
            }
        }
    }

    /// An overlapping `/*/` — where the opening `/*` and the closing `*/` share
    /// their `*` — is not a completed comment. It used to panic here
    /// ("byte range starts at 5 but ends at 4"), reachable from any malformed
    /// stylesheet: `Parser::parse` on `0"0/*/` aborted the process.
    #[test]
    fn overlapping_slash_star_slash_does_not_panic() {
        for s in [
            "/*/",
            "a /*/",
            "0\"0/*/",
            "\u{e9}__ '%/*/",
            ", in %+as *\t@\n'*/*/",
        ] {
            // The contract is only that this returns; the exact trim is
            // incidental for an unterminated comment.
            let _ = super::trim_trailing_loud_comments(s);
        }
    }

    /// The overlap guard must not stop a well-formed trailing comment from
    /// being trimmed.
    #[test]
    fn well_formed_trailing_comments_still_trim() {
        assert_eq!(super::trim_trailing_loud_comments("a /* c */"), "a");
        assert_eq!(super::trim_trailing_loud_comments("a /* c */ /* d */"), "a");
        assert_eq!(super::trim_trailing_loud_comments("a /**/"), "a");
        assert_eq!(super::trim_trailing_loud_comments("a"), "a");
        // Unterminated: nothing to trim.
        assert_eq!(super::trim_trailing_loud_comments("a /* c"), "a /* c");
        // Overlapping: left as written.
        assert_eq!(super::trim_trailing_loud_comments("a /*/"), "a /*/");
    }
}
