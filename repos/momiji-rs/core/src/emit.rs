//! Serialize the flattened output tree to CSS.

use crate::ast::SrcLines;
use crate::eval::{AtRuleKind, OutItem, OutNode, VarSpan};
use crate::sourcemap::SmCollector;
use crate::OutputStyle;

pub(crate) fn emit(nodes: &[OutNode], style: OutputStyle, charset: bool) -> String {
    // The default path collects nothing: `&mut None` makes every `record_*`
    // call inert, so the output is byte-for-byte the historical CSS.
    emit_inner(nodes, style, &mut None, charset).0
}

/// Like [`emit`], but also records a source map. Returns the final CSS, the
/// byte length of the `@charset`/BOM prefix that shifts every body offset, and
/// the populated collector (raw body offsets, not yet resolved to lines).
pub(crate) fn emit_with_map(
    nodes: &[OutNode],
    style: OutputStyle,
    charset: bool,
) -> (String, usize, SmCollector) {
    let mut collector = Some(SmCollector::new(matches!(style, OutputStyle::Compressed)));
    let (css, body_off) = emit_inner(nodes, style, &mut collector, charset);
    (css, body_off, collector.expect("collector present"))
}

/// Shared serializer. `collector = Some` records mapped-token body offsets;
/// `None` records nothing (the default path). Returns `(css, body_off)` where
/// `body_off` is the length of the prepended `@charset`/BOM prefix (0 when the
/// body is pure ASCII).
fn emit_inner(
    nodes: &[OutNode],
    style: OutputStyle,
    collector: &mut Option<SmCollector>,
    charset: bool,
) -> (String, usize) {
    let mut body = match style {
        OutputStyle::Expanded => emit_expanded(nodes, collector),
        OutputStyle::Compressed => emit_compressed(nodes, collector),
    };
    // The library API (`compile`/`compile_with_source_map`, and thus the wasm
    // `compileString().css` and the Ruby gem) returns the serialized stylesheet
    // with NO trailing newline — byte-for-byte what dart-sass's library API
    // returns. The expanded emitter terminates each statement with "\n", which
    // leaves exactly one trailing newline; drop it. (Compressed never emits a
    // trailing newline, so this is a no-op there.) The CLI front-ends
    // (src/main.rs, wasm cli.mjs) re-append the single newline dart-sass's CLI
    // adds. Stripping after emit keeps every recorded source-map offset valid:
    // nothing maps to the final newline.
    if body.ends_with('\n') {
        body.pop();
    }
    // dart-sass declares UTF-8 when the output contains any non-ASCII code
    // point: expanded output gets a leading `@charset "UTF-8";`, compressed
    // output gets a UTF-8 byte-order mark instead. The prefix shifts every
    // recorded body offset by its byte length (reported as `body_off`).
    // `charset: false` (dart-sass `--no-charset`) suppresses it entirely.
    if !charset || body.is_ascii() {
        return (body, 0);
    }
    match style {
        OutputStyle::Expanded => {
            const PREFIX: &str = "@charset \"UTF-8\";\n";
            (format!("{PREFIX}{body}"), PREFIX.len())
        }
        OutputStyle::Compressed => {
            let prefix = "\u{FEFF}";
            (format!("{prefix}{body}"), prefix.len())
        }
    }
}

/// Record a mapped token at the current end of `out` if collecting. Reads only
/// `out.len()` and the SrcLines — never mutates the output. Returns whether a
/// source position was known (so the caller may [`continue_span`] over it).
fn record(out: &str, lines: SrcLines, collector: &mut Option<SmCollector>) -> bool {
    if let Some(c) = collector {
        // A bubbled-selector wrapper carries its mapping in the source-map-only
        // override fields (so `file`/`start` stay 0 and the trailing-comment
        // heuristic stays disabled); everything else maps from `file`/`start`.
        let file = if lines.map_file != 0 {
            lines.map_file
        } else {
            lines.file
        };
        let line = lines.mapped_line();
        // `line` is the 1-based source line; 0 means "unknown" — skip it.
        if line == 0 || file == 0 {
            return false;
        }
        c.record(out, file, line - 1, lines.start_col);
        return true;
    }
    false
}

/// dart keeps a span OPEN while it writes a construct's text: a newline inside
/// it maps the new generated line back to the same source position (see
/// [`SmCollector::span_newlines`]). Call after appending the span's text that
/// began at body offset `from`; `mapped` is what [`record`]/[`record_span`]
/// returned for it, so an unmapped construct adds nothing.
fn continue_span(out: &str, from: usize, mapped: bool, collector: &mut Option<SmCollector>) {
    if let (true, Some(c)) = (mapped, collector) {
        c.span_newlines(out, from);
    }
}

/// Record a mapped token from an already-0-based [`VarSpan`] (a declaration
/// VALUE's span, resolved at eval time). `file == 0` means "unknown" and is
/// skipped. Like [`record`], reads the output but never mutates it.
fn record_span(out: &str, span: VarSpan, collector: &mut Option<SmCollector>) -> bool {
    if let Some(c) = collector {
        if span.file == 0 {
            return false;
        }
        c.record(out, span.file, span.line, span.col);
        return true;
    }
    false
}

fn emit_expanded(nodes: &[OutNode], collector: &mut Option<SmCollector>) -> String {
    let mut out = String::new();
    let mut prev = SrcLines::default();
    for node in nodes {
        emit_node_expanded(&mut out, node, 0, &mut prev, collector);
    }
    out
}

/// dart `_isTrailingComment` (expanded style only): a comment joins the
/// previous line when it starts on the line the previous construct ended —
/// or, for a block's first child, on the parent's opening-brace line — and
/// both come from the same source file. `prev.end` always holds the
/// comparison line; a zero file id disables the rule.
///
/// A `previous` whose span is IDENTICAL to the comment's is a clone of the
/// same comment (the same file imported twice): dart's span-containment
/// branch then walks back for a `{`, finds `searchFrom < 0`, and rejects it.
fn is_trailing(comment: SrcLines, prev: SrcLines) -> bool {
    comment.file != 0 && comment.file == prev.file && comment.start == prev.end && comment != prev
}

/// The previous-sibling seed for a block's children: the first child compares
/// against the block's opening-brace line (dart walks back to the `{`).
fn block_start(lines: SrcLines) -> SrcLines {
    SrcLines {
        file: lines.file,
        start: lines.start,
        end: lines.start,
        col: 0,
        start_col: 0,
        // The trailing-comment seed never feeds source-map output; map overrides
        // are irrelevant here.
        map_file: 0,
        map_line: 0,
    }
}

/// Append a trailing comment to the line already in `out`: drop the pending
/// newline(s) — at the root a group blank line may sit between — then write
/// ` /*…*/` with continuation lines at indentation 0 (dart saves and zeroes
/// `_indentation` for trailing comments).
fn push_trailing_comment(out: &mut String, text: &str, lines: SrcLines, collector: &mut Option<SmCollector>) {
    while out.ends_with('\n') {
        out.pop();
    }
    out.push(' ');
    // Source-map: the joined comment's `/*`.
    let mapped = record(out, lines, collector);
    let from = out.len();
    out.push_str("/*");
    push_comment_text(out, text, "", lines.start_col as usize);
    out.push_str("*/");
    continue_span(out, from, mapped, collector);
    out.push('\n');
}

/// Close an expanded block opened with `" {\n"`. When its only child was a
/// trailing comment the whole block stays on one line (dart: ` }`, e.g.
/// `@font-face { /**/ }`); otherwise the `}` gets its own indented line.
fn close_block(out: &mut String, indent: &str, children: usize, last_joined: bool) {
    if children == 1 && last_joined {
        out.pop(); // the trailing comment's newline
        out.push_str(" }\n");
    } else {
        out.push_str(indent);
        out.push_str("}\n");
    }
}

/// Indentation for a nesting depth (two spaces per level) without allocating:
/// `"  ".repeat(depth)` ran once per emitted node/item, which is tens of
/// thousands of short-lived Strings on a large output. Depths beyond the
/// precomputed pad (rare) fall back to an owned String.
fn indent_for(depth: usize) -> std::borrow::Cow<'static, str> {
    const PAD: &str = "                                                                "; // 32 levels
    match PAD.get(..depth * 2) {
        Some(s) => std::borrow::Cow::Borrowed(s),
        None => std::borrow::Cow::Owned("  ".repeat(depth)),
    }
}

/// Render one node at the given nesting `depth` (0 = document root). Each
/// extra level adds two spaces of indentation. `prev` carries the previous
/// sibling's source lines for the trailing-comment rule (its `end` is the
/// comparison line); returns whether THIS node was emitted as a trailing
/// comment joined onto the previous line.
fn emit_node_expanded(
    out: &mut String,
    node: &OutNode,
    depth: usize,
    prev: &mut SrcLines,
    collector: &mut Option<SmCollector>,
) -> bool {
    let indent = indent_for(depth);
    let indent = indent.as_ref();
    match node {
        // A module-scope wrapper is transparent: emit its contents in place
        // (the previous-sibling line state flows through the boundary).
        OutNode::ModuleScope { nodes, .. } => {
            let mut joined = false;
            for n in nodes {
                joined = emit_node_expanded(out, n, depth, prev, collector);
            }
            return joined;
        }
        OutNode::Rule {
            selectors,
            linebreaks,
            items,
            lines,
            ..
        } => {
            // `Parsed` selectors render to their final strings here (byte-
            // identical to the strings the extend engine used to materialize);
            // `Raw` selectors borrow directly.
            let selectors = selectors.to_strings();
            out.push_str(indent);
            // Source-map: the selector list's first character; a selector
            // list written over several lines maps each line (dart
            // `_for(node.selector, …)` spans the whole list).
            let mapped = record(out, *lines, collector);
            let from = out.len();
            write_selector_list(out, &selectors, linebreaks, indent);
            continue_span(out, from, mapped, collector);
            out.push_str(" {\n");
            let mut inner = block_start(*lines);
            let mut joined = false;
            for item in items {
                joined = emit_item_expanded(out, item, depth + 1, &mut inner, collector);
            }
            close_block(out, indent, items.len(), joined);
            *prev = *lines;
        }
        OutNode::Comment(text, lines) => {
            if is_trailing(*lines, *prev) {
                // Source-map: the joined `/*` (after the dropped newline + space).
                push_trailing_comment(out, text, *lines, collector);
                *prev = *lines;
                return true;
            }
            // Source-map: dart opens the comment's span BEFORE writing its
            // indentation (`visitCssComment` indents inside `_for(node, …)`),
            // so a nested comment maps from column 0 of its line; each further
            // line of a multi-line comment maps there too.
            let mapped = record(out, *lines, collector);
            let from = out.len();
            out.push_str(indent);
            out.push_str("/*");
            push_comment_text(out, text, indent, lines.start_col as usize);
            out.push_str("*/");
            continue_span(out, from, mapped, collector);
            out.push('\n');
            *prev = *lines;
        }
        OutNode::Raw(s, lines) => {
            out.push_str(indent);
            // Source-map: a passed-through `@import` maps to its URL token
            // (dart `visitCssImport`); other raw lines carry no position.
            record(out, *lines, collector);
            out.push_str(s);
            out.push('\n');
            *prev = SrcLines::default();
        }
        // Control-only hoist markers (consumed by the bubbling passes) never
        // reach the output and don't disturb the previous-sibling line state.
        OutNode::GroupEnd | OutNode::MediaHoist | OutNode::AtRootHoist { .. } | OutNode::AtRootPackTight => {
            return false;
        }
        OutNode::Blank => {
            // A synthetic group separator: dart has no such node, so it leaves
            // the previous-sibling line state alone (a trailing comment after
            // it joins across, swallowing the blank like dart does).
            out.push('\n');
        }
        OutNode::AtDecl {
            prop,
            value,
            important,
            custom,
            lines,
            value_span,
        } => {
            out.push_str(indent);
            // Source-map: the declaration property name.
            record(out, *lines, collector);
            out.push_str(prop);
            emit_decl_value_expanded(
                out,
                value,
                *important,
                *custom,
                lines.col as usize,
                indent,
                *value_span,
                collector,
            );
            out.push_str(";\n");
            *prev = *lines;
        }
        OutNode::AtRule {
            name,
            prelude,
            body,
            has_block,
            lines,
            ..
        } => {
            out.push_str(indent);
            // Source-map: the at-rule's `@` keyword; the span covers the
            // whole header (dart `_for(node, …)`), so a multi-line prelude
            // maps each of its lines.
            let mapped = record(out, *lines, collector);
            let from = out.len();
            out.push('@');
            out.push_str(name);
            if !prelude.is_empty() {
                out.push(' ');
                out.push_str(prelude);
            }
            continue_span(out, from, mapped, collector);
            *prev = *lines;
            if !has_block {
                out.push_str(";\n");
                return false;
            }
            if body.is_empty() {
                out.push_str(" {}\n");
                return false;
            }
            out.push_str(" {\n");
            let mut inner = block_start(*lines);
            let mut children = 0usize;
            let mut joined = false;
            for child in body {
                let before = out.len();
                let j = emit_node_expanded(out, child, depth + 1, &mut inner, collector);
                // Sentinels emit nothing and don't count as children.
                if out.len() > before {
                    children += 1;
                    joined = j;
                }
            }
            close_block(out, indent, children, joined);
        }
    }
    false
}

/// Render one rule-block item; same `prev`/return contract as
/// [`emit_node_expanded`].
fn emit_item_expanded(
    out: &mut String,
    item: &OutItem,
    depth: usize,
    prev: &mut SrcLines,
    collector: &mut Option<SmCollector>,
) -> bool {
    let indent = indent_for(depth);
    let indent = indent.as_ref();
    match item {
        OutItem::Decl {
            prop,
            value,
            important,
            custom,
            lines,
            value_span,
        } => {
            out.push_str(indent);
            // Source-map: the declaration property name.
            record(out, *lines, collector);
            out.push_str(prop);
            emit_decl_value_expanded(
                out,
                value,
                *important,
                *custom,
                lines.col as usize,
                indent,
                *value_span,
                collector,
            );
            out.push_str(";\n");
            *prev = *lines;
        }
        OutItem::Comment(text, lines) => {
            if is_trailing(*lines, *prev) {
                push_trailing_comment(out, text, *lines, collector);
                *prev = *lines;
                return true;
            }
            // Source-map: column 0 of the line, before the indentation (see
            // the `OutNode::Comment` arm), then every further line.
            let mapped = record(out, *lines, collector);
            let from = out.len();
            out.push_str(indent);
            out.push_str("/*");
            push_comment_text(out, text, indent, lines.start_col as usize);
            out.push_str("*/");
            continue_span(out, from, mapped, collector);
            out.push('\n');
            *prev = *lines;
        }
        OutItem::ChildlessAtRule {
            name, prelude, lines, ..
        } => {
            out.push_str(indent);
            // Source-map: the at-rule's `@` keyword, spanning the header.
            let mapped = record(out, *lines, collector);
            let from = out.len();
            out.push('@');
            out.push_str(name);
            if !prelude.is_empty() {
                out.push(' ');
                out.push_str(prelude);
            }
            continue_span(out, from, mapped, collector);
            out.push_str(";\n");
            *prev = *lines;
        }
        OutItem::NestedRule {
            selectors,
            linebreaks,
            items,
            lines,
        } => {
            out.push_str(indent);
            // Source-map: the selector list's first character, and each
            // further line of a multi-line list.
            let mapped = record(out, *lines, collector);
            let from = out.len();
            write_selector_list(out, selectors, linebreaks, indent);
            continue_span(out, from, mapped, collector);
            out.push_str(" {\n");
            let mut inner = SrcLines::default();
            let mut joined = false;
            for child in items {
                joined = emit_item_expanded(out, child, depth + 1, &mut inner, collector);
            }
            close_block(out, indent, items.len(), joined);
            *prev = SrcLines::default();
        }
        OutItem::NestedAtRule {
            name,
            prelude,
            items,
            lines,
            ..
        } => {
            out.push_str(indent);
            // Source-map: the at-rule's `@` keyword, spanning the header (so a
            // prelude written over several lines maps each of its lines).
            let mapped = record(out, *lines, collector);
            let from = out.len();
            out.push('@');
            out.push_str(name);
            if !prelude.is_empty() {
                out.push(' ');
                out.push_str(prelude);
            }
            continue_span(out, from, mapped, collector);
            // An empty block goes on one line, as a top-level at-rule's does.
            if items.is_empty() {
                out.push_str(" {}\n");
                *prev = SrcLines::default();
                return false;
            }
            out.push_str(" {\n");
            let mut inner = SrcLines::default();
            let mut joined = false;
            for child in items {
                joined = emit_item_expanded(out, child, depth + 1, &mut inner, collector);
            }
            close_block(out, indent, items.len(), joined);
            *prev = SrcLines::default();
        }
    }
    false
}

/// Append the `: value [!important]` portion of an expanded declaration. A
/// custom property emits its value verbatim right after the colon (its leading
/// whitespace is part of `value`, dart-sass adds no space) and never appends an
/// `!important` flag; a normal declaration uses the canonical `: ` separator.
/// A multi-line custom value is re-indented (dart `_writeReindentedValue`):
/// `name_col` is the declaration name's 0-based source column and `indent`
/// the current output indentation.
#[allow(clippy::too_many_arguments)]
fn emit_decl_value_expanded(
    out: &mut String,
    value: &str,
    important: bool,
    custom: bool,
    name_col: usize,
    indent: &str,
    value_span: VarSpan,
    collector: &mut Option<SmCollector>,
) {
    if custom {
        out.push(':');
        // dart wraps a custom property's value in `_for(node.value, …)`
        // (serialize.dart:379): the span opens at the value's own text, which
        // begins immediately after the colon, and stays open over a
        // re-indented multi-line value, mapping each of its lines.
        let mapped = record_span(out, value_span, collector);
        let from = out.len();
        match minimum_indentation(value) {
            MinIndent::SingleLine => out.push_str(value),
            MinIndent::Trailing => {
                out.push_str(trim_ascii_right_exclude_escape(value));
                out.push(' ');
            }
            MinIndent::Min(m) => write_with_indent(out, value, m.min(name_col), indent),
        }
        continue_span(out, from, mapped, collector);
        return;
    }
    out.push_str(": ");
    // dart wraps a SassScript value in `_buffer.forSpan(node.valueSpanForMap,
    // …)` (serialize.dart:389), so the mapping opens at the first byte of the
    // serialized value — after the `: `, not at the property name. For a bare
    // `$name` value this points at the variable's DEFINITION, which is the
    // whole reason this second entry is not redundant with the property one.
    record_span(out, value_span, collector);
    out.push_str(value);
    if important {
        out.push_str(" !important");
    }
}

/// dart `_minimumIndentation`: the minimum indentation of `text`'s
/// continuation lines, skipping blank lines.
enum MinIndent {
    /// `text` has no newline — emit verbatim.
    SingleLine,
    /// Every continuation line is blank (dart's `-1`) — trim right + space.
    Trailing,
    /// The least indented non-blank continuation line starts at this column.
    Min(usize),
}

fn minimum_indentation(text: &str) -> MinIndent {
    let bytes = text.as_bytes();
    let mut i = match text.find('\n') {
        None => return MinIndent::SingleLine,
        Some(p) => p + 1,
    };
    if i >= bytes.len() {
        return MinIndent::Trailing;
    }
    let mut min: Option<usize> = None;
    while i < bytes.len() {
        let start = i;
        while i < bytes.len() && (bytes[i] == b' ' || bytes[i] == b'\t') {
            i += 1;
        }
        if i >= bytes.len() {
            break; // a trailing all-whitespace line is not counted
        }
        if bytes[i] == b'\n' {
            i += 1; // blank line: not counted
            continue;
        }
        let col = i - start;
        min = Some(min.map_or(col, |m| m.min(col)));
        while i < bytes.len() && bytes[i] != b'\n' {
            i += 1;
        }
        i += 1;
    }
    match min {
        None => MinIndent::Trailing,
        Some(m) => MinIndent::Min(m),
    }
}

/// dart `trimAsciiRight(value, excludeEscape: true)`: strip trailing ASCII
/// whitespace, but keep one character after a terminating backslash so an
/// escaped trailing space survives.
fn trim_ascii_right_exclude_escape(s: &str) -> &str {
    let bytes = s.as_bytes();
    let mut end = bytes.len();
    while end > 0 && matches!(bytes[end - 1], b' ' | b'\t' | b'\n' | b'\r' | b'\x0c') {
        end -= 1;
    }
    if end != 0 && end != bytes.len() && bytes[end - 1] == b'\\' {
        end += 1;
    }
    &s[..end]
}

/// dart `_writeWithIndent`: write the first line verbatim, then each
/// continuation line stripped of `min_indent` characters and prefixed with
/// the current output indentation. Blank lines stay blank; a trailing
/// all-whitespace line folds to a single space.
fn write_with_indent(out: &mut String, text: &str, min_indent: usize, indent: &str) {
    let first_end = text.find('\n').unwrap_or(text.len());
    out.push_str(&text[..first_end]);
    if first_end == text.len() {
        return;
    }
    let mut i = first_end + 1;
    loop {
        let mut line_start = i;
        let mut newlines = 1usize;
        // Scan the whitespace run, counting blank lines; `i` settles on the
        // first non-whitespace character (the run's indentation is ASCII, so
        // byte stepping stays on char boundaries).
        loop {
            if i >= text.len() {
                out.push(' ');
                return;
            }
            match text.as_bytes()[i] {
                b' ' | b'\t' => i += 1,
                b'\n' => {
                    i += 1;
                    line_start = i;
                    newlines += 1;
                }
                _ => break,
            }
        }
        for _ in 0..newlines {
            out.push('\n');
        }
        out.push_str(indent);
        let line_end = text[i..].find('\n').map(|p| i + p).unwrap_or(text.len());
        out.push_str(&text[line_start + min_indent..line_end]);
        if line_end == text.len() {
            return;
        }
        i = line_end + 1;
    }
}

fn emit_compressed(nodes: &[OutNode], collector: &mut Option<SmCollector>) -> String {
    let mut out = String::new();
    let mut last: Option<&OutNode> = None;
    for node in nodes {
        let before = out.len();
        emit_node_compressed(&mut out, node, collector);
        if out.len() != before {
            last = Some(node);
        }
    }
    drop_trailing_semicolon(&mut out, last);
    out
}

/// dart writes a statement's `;` as a SEPARATOR, so compressed output never
/// ends with one — not at the end of the stylesheet and not before a `}`. Every
/// node here is separated that way except a verbatim line (a passed-through
/// `@import`), which carries its own `;`; that one is dropped when the line
/// comes last.
///
/// The test is which NODE wrote the final byte, never the byte itself: a
/// declaration's value is verbatim text and can end in a `;` of its own
/// (`--x: #{";"}`), which dart keeps.
fn drop_trailing_semicolon(out: &mut String, last: Option<&OutNode>) {
    if last.is_some_and(ends_with_own_semicolon) && out.ends_with(';') {
        out.pop();
    }
}

/// Whether this node's compressed output ends with a `;` the node itself wrote
/// — true for a verbatim line, and for a wrapper whose last VISIBLE child is
/// one.
fn ends_with_own_semicolon(node: &OutNode) -> bool {
    match node {
        OutNode::Raw(s, _) => s.ends_with(';'),
        // A childless at-rule (`@namespace "x";`) writes its own terminator.
        OutNode::AtRule { has_block, .. } => !has_block,
        OutNode::ModuleScope { nodes, .. } => nodes
            .iter()
            .rev()
            .find(|n| writes_compressed_output(n))
            .is_some_and(ends_with_own_semicolon),
        _ => false,
    }
}

/// Whether a node writes anything at all in compressed output. A blank, a
/// control-only marker, a comment that is not loud, a rule holding nothing but
/// dropped comments, and a module whose whole CSS is one of those all write
/// nothing — so none of them can be the node that wrote the last byte.
fn writes_compressed_output(node: &OutNode) -> bool {
    match node {
        OutNode::Blank => false,
        OutNode::Comment(text, _) => is_loud_comment(text),
        OutNode::Rule { items, .. } => items.iter().any(item_writes_compressed),
        // A module splices in transparently, so it is only as visible as its
        // contents — `meta.load-css` of a stylesheet that is all comments
        // writes nothing and must not hide the node before it.
        OutNode::ModuleScope { nodes, .. } => nodes.iter().any(writes_compressed_output),
        // A childless at-rule (`@namespace "x";`) is always written, and so is
        // a generic one with a block, empty or not; only the conditional group
        // rules are as visible as their contents.
        OutNode::AtRule {
            body,
            has_block,
            kind,
            ..
        } => !has_block || !at_rule_drops_when_empty(*kind) || body.iter().any(writes_compressed_output),
        n => !n.is_inert_marker(),
    }
}

/// Render `nodes` joined for compressed output. A declaration is terminated by
/// `;` before whatever follows it, but a preceding rule/at-rule `}` is its own
/// separator, so no `;` is inserted after it (matching dart-sass).
fn emit_compressed_body(out: &mut String, nodes: &[OutNode], collector: &mut Option<SmCollector>) {
    let mut prev_was_decl = false;
    let mut last: Option<&OutNode> = None;
    for node in nodes {
        // A blank, and a comment that is not LOUD, produce no compressed
        // output; don't let them reset the separator state. A loud comment is
        // written, takes the pending separator, and needs none of its own.
        if let OutNode::Comment(text, lines) = node {
            if is_loud_comment(text) {
                if prev_was_decl {
                    out.push(';');
                    prev_was_decl = false;
                }
                write_comment_compressed(out, text, *lines, collector);
                last = Some(node);
            }
            continue;
        }
        // A node that writes nothing neither emits nor takes the separator.
        if !writes_compressed_output(node) {
            continue;
        }
        if prev_was_decl {
            out.push(';');
        }
        let before = out.len();
        emit_node_compressed(out, node, collector);
        if out.len() != before {
            last = Some(node);
        }
        prev_was_decl = matches!(node, OutNode::AtDecl { .. });
    }
    drop_trailing_semicolon(out, last);
}

/// dart `_writeFoldedValue` (compressed custom properties): each newline
/// becomes a single space and the whitespace run following it is dropped.
/// Non-custom values pass through untouched.
fn fold_value_compressed<'v>(value: &'v str, custom: bool) -> std::borrow::Cow<'v, str> {
    if !custom || !value.contains('\n') {
        return std::borrow::Cow::Borrowed(value);
    }
    let mut out = String::with_capacity(value.len());
    let mut chars = value.chars().peekable();
    while let Some(c) = chars.next() {
        if c != '\n' {
            out.push(c);
            continue;
        }
        out.push(' ');
        while matches!(chars.peek(), Some(' ' | '\t' | '\n' | '\r' | '\x0c')) {
            chars.next();
        }
    }
    std::borrow::Cow::Owned(out)
}

/// dart-sass omits the space between the at-rule name and a prelude that begins
/// with `(` in compressed output, but ONLY in `visitCssMediaRule` and
/// `visitCssSupportsRule` — the serializers the two conditional group rules have
/// of their own. Every other at-rule keeps the space even before `(`, e.g.
/// `@container (min-width:1px)` and, because the class is what counts,
/// `@#{"media"} (a: 1)`.
fn compressed_at_rule_omits_space(kind: AtRuleKind, prelude: &str) -> bool {
    kind.is_conditional() && prelude.starts_with('(')
}

/// Write a rule block's items for compressed output, recording each item's
/// source-map entry.
///
/// dart `_visitChildren` separates two children with `;` only when the first
/// `_requiresSemicolon` — a childless node (a declaration, an `@import`). A
/// nested rule or at-rule ends in `}`, which is its own separator, so no `;`
/// follows it.
fn write_items_compressed(out: &mut String, items: &[OutItem], collector: &mut Option<SmCollector>) {
    let mut pending_semicolon = false;
    for item in items {
        // An item that writes nothing — a dropped comment, a rule or at-rule
        // holding only those — neither emits nor takes the pending separator.
        if !item_writes_compressed(item) {
            continue;
        }
        if let OutItem::Comment(text, lines) = item {
            // A LOUD comment is how a stylesheet keeps its licence header. It
            // takes the pending separator (`b:1;/*! c */`) but needs none of
            // its own.
            if pending_semicolon {
                out.push(';');
                pending_semicolon = false;
            }
            write_comment_compressed(out, text, *lines, collector);
            continue;
        }
        if pending_semicolon {
            out.push(';');
        }
        pending_semicolon = write_item_compressed(out, item, collector);
    }
}

/// Whether a comment survives compressed output: dart keeps the ones that open
/// `/*!`, the convention for "this is a licence, do not strip me".
fn is_loud_comment(text: &str) -> bool {
    text.starts_with('!')
}

/// Whether an item writes anything at all in compressed output. A dropped
/// comment writes nothing, and so does a nested RULE holding only such items —
/// however deep that goes, a plain-CSS `.a { .b { /* c */ } }` leaves dart with
/// nothing to print at either level. A nested at-rule follows
/// [`at_rule_drops_when_empty`].
fn item_writes_compressed(item: &OutItem) -> bool {
    match item {
        OutItem::Comment(text, _) => is_loud_comment(text),
        OutItem::NestedRule { items, .. } => items.iter().any(item_writes_compressed),
        OutItem::NestedAtRule { items, kind, .. } => {
            !at_rule_drops_when_empty(*kind) || items.iter().any(item_writes_compressed)
        }
        _ => true,
    }
}

/// Whether an at-rule goes away when its block writes nothing.
///
/// Only the two conditional group rules do. dart-sass keeps every other
/// at-rule, deliberately: `_isInvisible` short-circuits on `CssAtRule` with the
/// comment "an unknown at-rule is never invisible. Because we don't know the
/// semantics of unknown rules, we can't guarantee that (for example) `@foo {}`
/// isn't meaningful." `CssMediaRule` and `CssSupportsRule` fall through to
/// "invisible when every child is", which is why
/// `@media print { a { /* c */ } }` compresses to nothing while
/// `@keyframes k { 10% { /* c */ } }` compresses to `@keyframes k{}`.
///
/// `[measured]` against dart-sass 1.104.1, the test is the PARSED rule, not the
/// spelling: `@MEDIA screen { /* c */ }` and `@#{"media"} screen { /* c */ }`
/// are both generic at-rules there and both survive. That is what
/// [`AtRuleKind`] records, so both survive here too — in either style.
pub(crate) fn at_rule_drops_when_empty(kind: AtRuleKind) -> bool {
    kind.is_conditional()
}

/// Write a loud comment for compressed output — verbatim, newlines and all,
/// with no separator of its own.
fn write_comment_compressed(
    out: &mut String,
    text: &str,
    lines: SrcLines,
    collector: &mut Option<SmCollector>,
) {
    let mapped = record(out, lines, collector);
    let from = out.len();
    out.push_str("/*");
    out.push_str(text);
    out.push_str("*/");
    continue_span(out, from, mapped, collector);
}

/// Write one rule-block item for compressed output. Returns whether a `;` must
/// separate it from whatever follows (see [`write_items_compressed`]).
fn write_item_compressed(out: &mut String, item: &OutItem, collector: &mut Option<SmCollector>) -> bool {
    match item {
        OutItem::Decl {
            prop,
            value,
            important,
            custom,
            lines,
            value_span,
        } => {
            // A custom property emits its value verbatim (its leading
            // whitespace is part of `value`) and never gains an `!important`.
            let imp = if *important && !*custom { "!important" } else { "" };
            // Source-map: the declaration property name.
            record(out, *lines, collector);
            out.push_str(prop);
            out.push(':');
            // Source-map: the value, which for a bare `$name` points at the
            // variable's definition rather than at this line.
            record_span(out, *value_span, collector);
            out.push_str(&fold_value_compressed(value, *custom));
            out.push_str(imp);
            true
        }
        OutItem::Comment(..) => false,
        OutItem::ChildlessAtRule {
            name,
            prelude,
            css_import,
            lines,
        } => {
            // Source-map: the at-rule's `@` keyword.
            record(out, *lines, collector);
            out.push('@');
            out.push_str(name);
            if !prelude.is_empty() {
                // A CSS `@import` writes no space before its url when
                // compressing. That belongs to the IMPORT, not to the name: an
                // at-rule whose name is interpolated (`@#{"import"} "x"`) is
                // generic in dart and keeps its gap. Nothing else can drop it
                // here: a conditional group rule always has a block, so it is
                // never childless.
                if !*css_import {
                    out.push(' ');
                }
                out.push_str(prelude);
            }
            true
        }
        // A plain-CSS nested rule (a loaded `.css` file that uses CSS nesting):
        // dart visits its children like any other rule's, so they carry their
        // own mappings.
        OutItem::NestedRule {
            selectors,
            items,
            lines,
            ..
        } => {
            // Source-map: the nested selector list's first character.
            record(out, *lines, collector);
            write_selectors_compressed(out, selectors);
            out.push('{');
            write_items_compressed(out, items, collector);
            out.push('}');
            false
        }
        OutItem::NestedAtRule {
            name,
            prelude,
            items,
            kind,
            lines,
        } => {
            // Source-map: the at-rule's `@` keyword.
            record(out, *lines, collector);
            out.push('@');
            out.push_str(name);
            if !prelude.is_empty() {
                if !compressed_at_rule_omits_space(*kind, prelude) {
                    out.push(' ');
                }
                out.push_str(prelude);
            }
            out.push('{');
            write_items_compressed(out, items, collector);
            out.push('}');
            false
        }
    }
}

/// Write a selector list for compressed output: a bare comma between the
/// complexes, each one written the way dart compresses a selector (no space
/// around a combinator, none after a selector-list comma).
fn write_selectors_compressed(out: &mut String, selectors: &[String]) {
    for (i, sel) in selectors.iter().enumerate() {
        if i > 0 {
            out.push(',');
        }
        out.push_str(&crate::selector::compress_selector(sel));
    }
}

fn emit_node_compressed(out: &mut String, node: &OutNode, collector: &mut Option<SmCollector>) {
    match node {
        OutNode::ModuleScope { nodes, .. } => {
            for n in nodes {
                emit_node_compressed(out, n, collector);
            }
        }
        OutNode::Rule {
            selectors,
            linebreaks: _,
            items,
            lines,
            ..
        } => {
            // A rule that writes nothing produces nothing in compressed
            // output, so it is not emitted at all — a dropped comment writes
            // nothing, and neither does a nested rule holding only those.
            if !items.iter().any(item_writes_compressed) {
                return;
            }
            // Source-map: the selector list's first character.
            record(out, *lines, collector);
            write_selectors_compressed(out, &selectors.to_strings());
            out.push('{');
            write_items_compressed(out, items, collector);
            out.push('}');
        }
        OutNode::Comment(text, lines) => {
            if is_loud_comment(text) {
                write_comment_compressed(out, text, *lines, collector);
            }
        }
        OutNode::Raw(s, lines) => {
            // Source-map: a passed-through `@import` maps to its URL token.
            record(out, *lines, collector);
            out.push_str(s);
        }
        OutNode::Blank => {}
        // Control-only hoist markers never reach the output.
        OutNode::GroupEnd | OutNode::MediaHoist | OutNode::AtRootHoist { .. } | OutNode::AtRootPackTight => {}
        OutNode::AtDecl {
            prop,
            value,
            important,
            custom,
            lines,
            value_span,
        } => {
            let imp = if *important && !*custom { "!important" } else { "" };
            // Source-map: the declaration property name.
            record(out, *lines, collector);
            out.push_str(prop);
            out.push(':');
            // Source-map: the value (dart's `forSpan(valueSpanForMap)`).
            record_span(out, *value_span, collector);
            out.push_str(&fold_value_compressed(value, *custom));
            out.push_str(imp);
        }
        OutNode::AtRule {
            name,
            prelude,
            body,
            has_block,
            kind,
            lines,
        } => {
            // A `@media`/`@supports` block that writes nothing leaves dart
            // nothing to print: the at-rule goes with it, exactly as a rule of
            // dropped comments does. Every other at-rule stays — see
            // `at_rule_drops_when_empty`.
            if *has_block && at_rule_drops_when_empty(*kind) && !body.iter().any(writes_compressed_output) {
                return;
            }
            // Source-map: the at-rule's `@` keyword.
            record(out, *lines, collector);
            out.push('@');
            out.push_str(name);
            if !prelude.is_empty() {
                // Compressed `@media`/`@supports` omit the space before a prelude
                // that begins with `(` (dart `visitCssMediaRule`/`visitCssSupportsRule`).
                if !compressed_at_rule_omits_space(*kind, prelude) {
                    out.push(' ');
                }
                out.push_str(prelude);
            }
            if !has_block {
                out.push(';');
                return;
            }
            out.push('{');
            emit_compressed_body(out, body, collector);
            out.push('}');
        }
    }
}

/// Write a loud comment's text with dart's continuation-line handling
/// (`_minimumIndentation` + `_writeWithIndent`, run on the EVALUATED text so
/// interpolated comments dedent too): continuation lines lose
/// `min(<minimum indentation across them>, <the comment's own source start
/// column>)` leading whitespace and gain the CURRENT output indentation;
/// whitespace-only interior lines collapse to bare newlines. The final line
/// always counts as content — the `*/` closer follows this text.
fn push_comment_text(out: &mut String, text: &str, indent: &str, start_col: usize) {
    if !text.contains('\n') {
        out.push_str(text);
        return;
    }
    let lines: Vec<&str> = text.split('\n').collect();
    let mut min: Option<usize> = None;
    for (i, line) in lines.iter().enumerate().skip(1) {
        if i + 1 != lines.len() && line.trim().is_empty() {
            continue;
        }
        let ind = line.len() - line.trim_start_matches([' ', '\t']).len();
        min = Some(min.map_or(ind, |m| m.min(ind)));
    }
    let strip = min.map_or(0, |m| m.min(start_col));
    out.push_str(lines[0]);
    for (i, line) in lines.iter().enumerate().skip(1) {
        out.push('\n');
        if i + 1 != lines.len() && line.trim().is_empty() {
            continue;
        }
        let ind = line.len() - line.trim_start_matches([' ', '\t']).len();
        out.push_str(indent);
        out.push_str(&line[strip.min(ind)..]);
    }
}

/// Write a rule's selector list in expanded style: a complex selector flagged
/// with a source line break starts on its own line (aligned to the rule's
/// indent), the others are `, `-joined; a line break INSIDE a selector (a
/// pseudo arg's preserved source line) continues at the rule's indent, like
/// dart's `_writeIndentation` after every line feed.
fn write_selector_list(out: &mut String, selectors: &[String], linebreaks: &[bool], indent: &str) {
    for (i, sel) in selectors.iter().enumerate() {
        if i > 0 {
            out.push(',');
            if linebreaks.get(i).copied().unwrap_or(false) {
                out.push('\n');
                out.push_str(indent);
            } else {
                out.push(' ');
            }
        }
        if sel.contains('\n') && !indent.is_empty() {
            let mut first = true;
            for line in sel.split('\n') {
                if !first {
                    out.push('\n');
                    out.push_str(indent);
                }
                out.push_str(line);
                first = false;
            }
        } else {
            out.push_str(sel);
        }
    }
}
