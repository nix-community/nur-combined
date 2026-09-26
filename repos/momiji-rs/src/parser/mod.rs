//! The SCSS parser: a character-level recursive-descent parser.
//!
//! SCSS is context-sensitive — a leading `:` can begin a declaration
//! value or a pseudo-class selector — so statements are disambiguated by
//! a bounded lookahead ([`Parser::classify`]) that finds whether a
//! top-level `{` (a rule) or `;`/`}` (a declaration) comes first.

use std::rc::Rc;

use crate::ast::{
    BinOp, CallArg, Callable, ConfigEntry, Conjunction, CssCustomItem, CssCustomValue, CustomDecl,
    Declaration, Expr, ForwardMember, IfBranch, IfClause, IfCond, ImportArg, ImportModifier, MediaFeature,
    MediaInParens, MediaQuery, MediaQueryList, Param, ParamList, PropertySet, Rule, SrcLines, Stmt,
    Stylesheet, SupportsCondition, SupportsValue, TplPiece, UnOp, VarDecl,
};
use crate::error::Error;
use crate::scanner::{Mark, Pos, Scanner};
use crate::value::{named_color, Color, ListSep};

mod at_rules;
mod control_flow;
mod statements;
mod value;

enum NextKind {
    Rule,
    Declaration,
}

/// How [`Parser::parse_template_mode`] treats `/* */` (loud) and `//` (silent)
/// comments encountered while scanning a selector / prelude / property.
#[derive(Clone, Copy, PartialEq)]
enum CommentMode {
    /// Keep every comment verbatim in the literal (legacy behaviour: values
    /// and grammars that capture text exactly).
    Keep,
    /// Drop every comment, replacing it with a single space, at any nesting.
    /// dart-sass normalises selectors and structured grammars this way, so a
    /// comment behaves purely as whitespace (`a/**/b` → `a b`).
    Strip,
    /// Strip only *top-level* (outside `()`/`[]`) comments, replacing them with
    /// a single space; comments nested inside parentheses are kept verbatim.
    /// dart-sass parses `@supports` and `@-moz-document` preludes with a
    /// structured grammar that drops trivia comments between tokens while the
    /// parenthesised content is captured raw (`(a /**/ b)` is preserved).
    StripTopLevel,
    /// Unknown / interpolation-prelude directives (`@page`, `@font-face`,
    /// `@layer`, any unknown `@foo`, …): a `//` silent comment is dropped to
    /// end of line (it acts as whitespace); a `/* */` loud comment is *kept*
    /// verbatim. A leading comment is already removed by `skip_ws_inline`
    /// before the prelude template starts. Applied only at the top level;
    /// nested content is kept verbatim.
    UnknownPrelude,
    /// A declaration's property name: like `Strip`, except that ONE loud
    /// comment directly glued to the name (no whitespace between) joins it
    /// verbatim — dart `_declarationOrBuffer` appends `rawText(loudComment)`
    /// to the name buffer when `/*` immediately follows the identifier
    /// (issue_1422: `foo/*c*/: bar` keeps the comment, `foo /*c*/ : bar`
    /// drops it).
    DeclName,
}

enum MessageKind {
    Warn,
    Debug,
    Error,
}

/// `trim(piece)` as a new shared buffer, or `None` when the trim removed
/// nothing and the piece can be left alone. A literal's text is shared, so
/// copying it to say "unchanged" is pure waste.
fn trimmed_lit(piece: &Rc<str>, trim: fn(&str) -> &str) -> Option<Rc<str>> {
    let trimmed = trim(piece);
    (trimmed.len() != piece.len()).then(|| Rc::from(trimmed))
}

/// Trim leading/trailing whitespace from a parsed prelude template, dropping
/// any whitespace-only literals at the ends. Interior interpolation is kept.
fn trim_prelude(pieces: Vec<TplPiece>) -> Vec<TplPiece> {
    let mut pieces = pieces;
    if let Some(TplPiece::Lit(first)) = pieces.first_mut() {
        // A prelude written without leading padding — the usual one — has
        // nothing to trim, and keeps the buffer it was parsed into.
        if let Some(trimmed) = trimmed_lit(first, str::trim_start) {
            *first = trimmed;
        }
        if first.is_empty() {
            pieces.remove(0);
        }
    }
    if let Some(TplPiece::Lit(last)) = pieces.last_mut() {
        if let Some(trimmed) = trimmed_lit(last, str::trim_end) {
            *last = trimmed;
        }
        if last.is_empty() {
            pieces.pop();
        }
    }
    pieces
}

/// Whether a parsed media identifier template is exactly the plain keyword
/// `kw` (case-insensitively). Interpolation never matches a keyword.
fn media_ident_is(pieces: &[TplPiece], kw: &str) -> bool {
    match media_ident_plain(pieces) {
        Some(s) => s.eq_ignore_ascii_case(kw),
        None => false,
    }
}

/// The plain text of a media identifier template, or `None` if it contains
/// interpolation.
fn media_ident_plain(pieces: &[TplPiece]) -> Option<&str> {
    match pieces {
        [TplPiece::Lit(s)] => Some(s),
        [] => Some(""),
        _ => None,
    }
}

/// The plain (non-interpolated) text of a template, or `None` if it contains
/// any `#{…}` interpolation (dart-sass `Interpolation.asPlain`).
fn tpl_plain(pieces: &[TplPiece]) -> Option<String> {
    let mut s = String::new();
    for p in pieces {
        match p {
            TplPiece::Lit(t) => s.push_str(t),
            TplPiece::Interp(_) => return None,
        }
    }
    Some(s)
}

/// If `pieces` is exactly one `#{…}` interpolation (no surrounding literal),
/// return its expression; otherwise `None`.
fn tpl_single_interp(pieces: Vec<TplPiece>) -> Option<Expr> {
    if pieces.len() == 1 {
        if let Some(TplPiece::Interp(e)) = pieces.into_iter().next() {
            return Some(e);
        }
    }
    None
}

/// Whether a `@supports` declaration name is a CSS custom property: an unquoted
/// identifier whose plain text begins with `--` (dart-sass
/// `SupportsDeclaration.isCustomProperty`).
fn expr_is_custom_property(name: &Expr) -> bool {
    match name {
        Expr::Ident(pieces) => match pieces.first() {
            Some(TplPiece::Lit(s)) => s.starts_with("--"),
            _ => false,
        },
        _ => false,
    }
}

/// Whether two range comparison operators form a valid range: both must point
/// the same direction (`<`/`<=` then `<`/`<=`, or `>`/`>=` then `>`/`>=`), and
/// neither may be `=`.
fn range_ops_compatible(op1: &str, op2: &str) -> bool {
    let dir = |op: &str| match op {
        "<" | "<=" => Some(true),
        ">" | ">=" => Some(false),
        _ => None,
    };
    match (dir(op1), dir(op2)) {
        (Some(a), Some(b)) => a == b,
        _ => false,
    }
}

struct Parser {
    sc: Scanner,
    /// Interned unit names for numeric literals. A stylesheet spells a handful
    /// of distinct units — `px`, `rem`, `%`, and the empty one — hundreds of
    /// times each, and the AST hands its `Rc<str>` to every value the literal
    /// evaluates to, so one buffer per distinct name serves the whole file.
    /// Searched linearly: the list is a few entries long, never more.
    unit_names: Vec<Rc<str>>,
    /// Depth of enclosing `calc()`/math-function contexts. Inside one, `/`
    /// is always real division (never a slash separator) and `+`/`-` must be
    /// surrounded by whitespace.
    calc_depth: u32,
    /// Set by `parse_unicode_range` when a `?`-wildcard range token is
    /// immediately followed (no whitespace) by an identifier. dart-sass treats
    /// the wildcard as terminal and starts a new space-list element with an
    /// implicit separator (`U+A?BCDE` -> `U+A? BCDE`); `space_list` consumes
    /// the flag to continue without requiring whitespace.
    pending_unicode_split: bool,
    /// Depth of enclosing `{ … }` blocks. `@use`/`@forward` are only valid at
    /// the top level (depth 0); inside any block they are "This at-rule is not
    /// allowed here.".
    block_depth: u32,
    /// When set, `parse_template_mode` records each top-level `#{…}`
    /// interpolation's expression span (line, start col, col of `}`) here —
    /// used by rule selectors for the dual-span "error in interpolated
    /// output" diagnostic. Nested template parses (inside an interpolation's
    /// expression) suspend collection.
    collect_interp_spans: bool,
    interp_spans: Vec<(u32, u32, u32)>,
    /// Set once a top-level statement that is *not* a variable declaration,
    /// comment, `@charset`, `@use`, or `@forward` has been parsed. A later
    /// `@use`/`@forward` then errors ("@use rules must be written before any
    /// other rules.").
    seen_non_module_stmt: bool,
    /// Plain-CSS mode (a `.css` file loaded via `@use`/`@forward`). SassScript
    /// and Sass-only statements are rejected: this is the analogue of dart-sass's
    /// `CssParser`. Nesting is still parsed (CSS nesting is preserved in output);
    /// the difference is that Sass features become errors.
    plain_css: bool,
    /// Set once an interpolation body has been read in plain-CSS mode, where
    /// `#{…}` is an error wherever it stands. A backtracking attempt (the
    /// modern `if()` grammar) that read one therefore cannot be retried under
    /// another grammar — no grammar accepts that text — so it must propagate
    /// the error dart reports instead of the one the retry would raise.
    plain_css_interp: bool,
    /// Indented-syntax mode: the input is the position-preserving SCSS
    /// reconstruction of a `.sass` file (see `sass_parser`), and the few
    /// grammar liberties dart's `SassParser` takes over `ScssParser` apply —
    /// an `@import` URL may be an unquoted token.
    indented: bool,
}

/// Parse a complete stylesheet (SCSS).
pub(crate) fn parse(src: &str) -> Result<Stylesheet, Error> {
    parse_inner(src, false, false)
}

/// Parse a plain-CSS stylesheet (a loaded `.css` file): the same brace/semicolon
/// grammar, but Sass features are rejected.
pub(crate) fn parse_plain_css(src: &str) -> Result<Stylesheet, Error> {
    parse_inner(src, true, false)
}

/// Parse the SCSS reconstruction of an indented-syntax (`.sass`) stylesheet.
pub(crate) fn parse_indented(src: &str) -> Result<Stylesheet, Error> {
    parse_inner(src, false, true)
}

fn parse_inner(src: &str, plain_css: bool, indented: bool) -> Result<Stylesheet, Error> {
    let mut p = Parser {
        sc: Scanner::new(src),
        unit_names: Vec::new(),
        calc_depth: 0,
        pending_unicode_split: false,
        block_depth: 0,
        collect_interp_spans: false,
        interp_spans: Vec::new(),
        seen_non_module_stmt: false,
        plain_css,
        plain_css_interp: false,
        indented,
    };
    let stmts = p.parse_statements(true)?;
    Ok(Stylesheet { stmts })
}

fn is_ident_char(c: char) -> bool {
    // dart `isName`: any non-ASCII code point is a valid identifier char
    // (`$vär`, `föö` need no escaping).
    c.is_ascii_alphanumeric() || c == '-' || c == '_' || (c as u32) >= 0x80
}

/// Reject generic/unknown at-rules in a context that forbids them (function
/// bodies, nested property sets), recursing into control-flow bodies.
fn reject_at_rules_in(stmts: &[Stmt]) -> Result<(), Error> {
    for s in stmts {
        match s {
            Stmt::AtRule { .. } | Stmt::InterpAtRule { .. } => {
                return Err(Error::unpositioned("This at-rule is not allowed here."));
            }
            Stmt::If(branches) => {
                for b in branches {
                    reject_at_rules_in(&b.body)?;
                }
            }
            Stmt::For { body, .. } | Stmt::Each { body, .. } | Stmt::While { body, .. } => {
                reject_at_rules_in(body)?;
            }
            _ => {}
        }
    }
    Ok(())
}

/// Whether `name` is a global Sass function with no plain-CSS meaning, so a
/// `.css` file calling it is an error (the CSS color/math functions — `rgb`,
/// `hsl`, `grayscale`, `saturate`, `min`, `calc`, … — are deliberately absent,
/// since plain CSS preserves those verbatim).
fn is_sass_only_function(name: &str) -> bool {
    matches!(
        name,
        // list
        "index" | "nth" | "set-nth" | "join" | "append" | "zip" | "list-separator"
            | "is-bracketed" | "length"
            // map
            | "map-get" | "map-merge" | "map-remove" | "map-keys" | "map-values" | "map-has-key"
            // meta
            | "type-of" | "unit" | "unitless" | "comparable" | "inspect" | "keywords"
            | "feature-exists" | "variable-exists" | "global-variable-exists" | "function-exists"
            | "mixin-exists" | "content-exists" | "get-function" | "call" | "get-mixin"
            // string
            | "str-length" | "str-insert" | "str-index" | "str-slice" | "to-upper-case"
            | "to-lower-case" | "unique-id"
            // color (Sass-only adjusters / getters, not CSS functions)
            | "mix" | "adjust-hue" | "lighten" | "darken" | "desaturate" | "opacify"
            | "transparentize" | "fade-in" | "fade-out" | "scale-color" | "adjust-color"
            | "change-color" | "ie-hex-str"
            // selector
            | "selector-nest" | "selector-append" | "selector-replace" | "selector-unify"
            | "is-superselector" | "simple-selectors" | "selector-parse" | "selector-extend"
    )
}

/// Whether a top-level statement may legally appear *before* a `@use` rule.
/// dart-sass permits variable declarations, loud comments, `@charset`, `@use`,
/// and `@forward`; everything else means a following `@use` is too late.
fn stmt_allowed_before_use(stmt: &Stmt) -> bool {
    match stmt {
        Stmt::VarDecl(_) | Stmt::Comment(..) | Stmt::Use { .. } | Stmt::Forward { .. } => true,
        Stmt::AtRule { name, .. } => name.eq_ignore_ascii_case("charset"),
        _ => false,
    }
}

/// Whether `c` may begin a CSS identifier *without* escaping: an ASCII letter,
/// `_`, or any non-ASCII code point (matches dart-sass `isNameStart`).
fn is_name_start_codepoint(c: char) -> bool {
    c.is_ascii_alphabetic() || c == '_' || (c as u32) >= 0x80
}

/// Whether `c` may appear in an identifier body without escaping (matches
/// dart-sass `isName`): a name-start char, an ASCII digit, or `-`.
fn is_name_codepoint(c: char) -> bool {
    is_name_start_codepoint(c) || c.is_ascii_digit() || c == '-'
}

/// Append the canonical spelling of an *escaped* identifier code point to `out`,
/// matching dart-sass's `escape()`. `identifier_start` is true when this escape
/// is the first code point of the identifier (or the code point right after a
/// single leading `-`), in which case digits and `-` are escaped and only a
/// name-start char passes through literally.
fn push_ident_escape(out: &mut String, c: char, identifier_start: bool) {
    let cp = c as u32;
    let literal_ok = if identifier_start {
        is_name_start_codepoint(c)
    } else {
        is_name_codepoint(c)
    };
    if literal_ok {
        out.push(c);
    } else if cp <= 0x1F || cp == 0x7F || (identifier_start && c.is_ascii_digit()) {
        // Control characters (and a leading digit) serialize as a hex escape
        // with a trailing space, e.g. `\9 ` for a tab or `\30 ` for a leading 0.
        out.push('\\');
        out.push_str(&format!("{cp:x}"));
        out.push(' ');
    } else {
        // Other printable ASCII punctuation: a backslash followed by the literal
        // character (e.g. `\:`, `\@`, `\-`).
        out.push('\\');
        out.push(c);
    }
}

/// Classify a function name (the identifier immediately before a `(`) as a
/// "special" CSS function whose argument list must be preserved verbatim
/// rather than parsed as SassScript. Matching is case-insensitive and the
/// returned name is the dart-sass canonical (lower-cased) spelling that is
/// emitted.
///
/// `calc`, `element`, and `expression` are special with or without a single
/// vendor prefix (`-x-`). `type` is special only when *un*prefixed. `url`,
/// `var`, and `env` are handled separately (they have their own raw paths).
fn special_function_name(name: &str) -> Option<String> {
    let lower = name.to_ascii_lowercase();
    // Strip a single leading vendor prefix: `-<vendor>-`.
    let unprefixed = strip_vendor_prefix(&lower);
    match unprefixed {
        "calc" | "element" | "expression" => Some(lower),
        // `type` is special only with no vendor prefix.
        "type" if unprefixed == lower => Some(lower),
        _ => None,
    }
}

/// Strip a single leading `-<vendor>-` prefix from an already-lower-cased
/// identifier, returning the remainder. A vendor prefix is `-`, one or more
/// identifier characters, then `-` (e.g. `-webkit-`). If no such prefix is
/// present the whole string is returned unchanged.
fn strip_vendor_prefix(lower: &str) -> &str {
    let bytes = lower.as_bytes();
    if bytes.first() != Some(&b'-') {
        return lower;
    }
    // Find the second `-` after at least one inner character.
    if let Some(rel) = lower[1..].find('-') {
        if rel >= 1 {
            return &lower[1 + rel + 1..];
        }
    }
    lower
}

/// Decode the CSS identifier starting at `cs[i]`, resolving `\XXXXXX` hex and
/// `\c` literal escapes, and return it with the index just past its last
/// character. An empty name means there was no identifier there.
pub(crate) fn decode_ident(cs: &[char], mut i: usize) -> (String, usize) {
    let mut name = String::new();
    while let Some(&c) = cs.get(i) {
        if c == '\\' {
            i += 1;
            let mut hex = String::new();
            while hex.len() < 6 && cs.get(i).is_some_and(|c| c.is_ascii_hexdigit()) {
                hex.push(cs[i]);
                i += 1;
            }
            if hex.is_empty() {
                match cs.get(i) {
                    Some(&c) => {
                        name.push(c);
                        i += 1;
                    }
                    None => break,
                }
            } else {
                // One whitespace character may terminate a hex escape — dart's
                // `isWhitespace`, which is space, tab and the three CSS
                // newlines, NOT every Unicode space (a vertical tab ends the
                // identifier instead, as the parser reads it).
                if matches!(cs.get(i), Some(' ' | '\t' | '\n' | '\r' | '\u{c}')) {
                    i += 1;
                    if cs.get(i - 1) == Some(&'\r') && cs.get(i) == Some(&'\n') {
                        i += 1;
                    }
                }
                // A surrogate or out-of-range code point becomes the
                // replacement character, as `read_escape_char` resolves it —
                // stopping here instead would report the name's PREFIX
                // (`@import\D800` as `import`), and the line analysis would
                // then apply `@import`'s rules to a generic at-rule.
                let value = u32::from_str_radix(&hex, 16).unwrap_or(0xFFFD);
                name.push(if (0xD800..=0xDFFF).contains(&value) || value > 0x10FFFF {
                    '\u{FFFD}'
                } else {
                    char::from_u32(value).unwrap_or('\u{FFFD}')
                });
            }
            continue;
        }
        if is_ident_char(c) {
            name.push(c);
            i += 1;
            continue;
        }
        break;
    }
    (name, i)
}

/// Whether `name` is a `url(` function — `url` itself or any vendor-prefixed
/// `-x-url`, case-insensitively. dart-sass parses these with its special URL
/// grammar (a plain, unquoted URL is preserved verbatim and the call is
/// emitted as a bare `url(...)`).
pub(crate) fn is_url_function(name: &str) -> bool {
    let lower = name.to_ascii_lowercase();
    strip_vendor_prefix(&lower) == "url"
}

/// Whether `name` (the identifier immediately before a `:`) introduces an IE
/// `progid:` special function — `progid` itself or any vendor-prefixed
/// `-x-progid`, case-insensitively. dart-sass recognises a value-position
/// token of the form `[-vendor-]progid:Name(...)` and preserves its argument
/// list verbatim. The whole `[-vendor-]progid` prefix is lower-cased on emit
/// (the `Name` after the `:` keeps its original case).
fn is_progid_name(name: &str) -> bool {
    let lower = name.to_ascii_lowercase();
    strip_vendor_prefix(&lower) == "progid"
}

/// Validate a modern `if()` condition: an evaluated `sass()` may not coexist
/// in an `and`/`or` chain with an *unparenthesised* multi-token "arbitrary
/// substitution". Parenthesising the substitution shields it (a `sass()`
/// nested in parens is NOT shielded). Returns `(sass_anywhere, direct_multi)`
/// where `sass_anywhere` is true if any `sass()` exists in the subtree
/// (descending through parens), and `direct_multi` is true if an
/// unparenthesised multi-token raw exists at this boolean level.
fn validate_if_cond(cond: &IfCond) -> Result<(bool, bool), Error> {
    let (sass, multi) = match cond {
        IfCond::Sass(_) => (true, false),
        IfCond::Raw { multi, .. } => (false, *multi),
        IfCond::Not(inner) => validate_if_cond(inner)?,
        // A paren shields a multi-token substitution from the parent level,
        // but a `sass()` inside still propagates.
        IfCond::Paren(inner) => {
            let (s, _) = validate_if_cond(inner)?;
            (s, false)
        }
        IfCond::And(items) | IfCond::Or(items) => {
            let mut sass = false;
            let mut multi = false;
            for it in items {
                let (s, m) = validate_if_cond(it)?;
                sass |= s;
                multi |= m;
            }
            (sass, multi)
        }
    };
    if sass && multi {
        return Err(Error::unpositioned(
            "if() conditions with arbitrary substitutions may not contain sass() expressions.",
        ));
    }
    Ok((sass, multi))
}

/// Whether a quoted `@import` URL (parsed into template pieces) is a *plain
/// CSS* URL — one ending in `.css`, or beginning with a protocol/`//`. Such
/// URLs are emitted verbatim rather than inlined as Sass partials. Only the
/// leading/trailing literal text is inspected (interpolated URLs are dynamic
/// Sass paths and handled elsewhere).
fn import_url_is_css(pieces: &[TplPiece]) -> bool {
    let mut head = "";
    if let Some(TplPiece::Lit(s)) = pieces.first() {
        head = s;
    }
    let mut tail = "";
    if let Some(TplPiece::Lit(s)) = pieces.last() {
        tail = s;
    }
    tail.ends_with(".css")
        || head.starts_with("http://")
        || head.starts_with("https://")
        || head.starts_with("//")
}

/// Drop trailing whitespace-only literal pieces and trim the last literal.
/// Append a single literal character to a template, merging into a trailing
/// `Lit` piece when possible.
///
/// The merge is load-bearing, not an optimization: adjacent literals must stay
/// one piece, because [`import_url_is_css`] reads the first and last piece as
/// whole affixes, [`trim_prelude`] trims only the end pieces, and a template
/// that is a single literal is the one evaluation hands out without copying.
/// Rebuilding the piece is what an `Rc<str>` costs to extend, and this runs a
/// few times per `@import` that has modifiers at all — never in a loop.
fn push_lit(pieces: &mut Vec<TplPiece>, c: char) {
    if let Some(TplPiece::Lit(s)) = pieces.last_mut() {
        *s = Rc::from(format!("{s}{c}"));
    } else {
        pieces.push(TplPiece::Lit(c.to_string().into()));
    }
}

/// End the literal piece accumulated in `lit`, keeping its buffer for the next
/// one. A piece's text is shared from here on — a single-literal template hands
/// it straight to the string it evaluates to — so it is copied into its own
/// allocation exactly once, here.
fn take_lit(lit: &mut String) -> TplPiece {
    let piece = TplPiece::Lit(Rc::from(lit.as_str()));
    lit.clear();
    piece
}

/// Whether `expr` is eligible to keep the deprecated `/` slash spelling.
/// dart-sass keeps the slash only between number literals (including a
/// unary-signed literal) and chains of such slash divisions; variables,
/// function calls, parentheses, and other operations force real division.
fn is_slash_operand(expr: &Expr) -> bool {
    match expr {
        Expr::Number(_, _) => true,
        // dart-sass also keeps the slash spelling when an operand is a
        // `calc()` (and the math-function family parsed as calculations):
        // `calc(1)/2` -> `1/2`, `calc(2px)/calc(4px)` -> `2px/4px`. The calc
        // operand folds to a number at eval time, so the slash repr is its
        // serialized value.
        Expr::Calc { .. } => true,
        Expr::Div { slash, .. } => *slash,
        Expr::Unary {
            op: UnOp::Neg,
            operand,
        } => is_slash_operand(operand),
        _ => false,
    }
}

/// Whether `expr` is a bare quoted-string atom. dart-sass forms an implicit
/// space-separated list when a quoted string abuts an adjacent value atom with
/// no whitespace, so the space-list parser uses this to decide whether a
/// no-whitespace boundary continues the list (`"["'foo'"]"` -> a three-element
/// list) rather than ending it.
fn expr_is_quoted_string(expr: &Expr) -> bool {
    matches!(expr, Expr::QuotedString(_))
}

/// Strip a `-foo-` vendor prefix (a `-`, ASCII letters, then `-`). `--x`,
/// `-moz_x` (underscore), and an unprefixed name are returned unchanged.
fn unvendor(name: &str) -> &str {
    let bytes = name.as_bytes();
    if bytes.first() != Some(&b'-') || bytes.get(1) == Some(&b'-') {
        return name;
    }
    for (i, &c) in bytes.iter().enumerate().skip(1) {
        if c == b'-' {
            return &name[i + 1..];
        }
        if !c.is_ascii_alphabetic() {
            return name;
        }
    }
    name
}

/// Whether `name` is reserved and may not be a user `@function` name (dart-sass
/// "Invalid function name."). The SassScript operators and the raw-content CSS
/// functions `url`/`expression` match exactly (so `-a-and`, `AND`, `-a-url` are
/// allowed); `element` matches after stripping a vendor prefix; `type` matches
/// case-insensitively.
fn is_reserved_function_name(name: &str) -> bool {
    matches!(name, "and" | "or" | "not" | "url" | "expression")
        || unvendor(name) == "element"
        || name.eq_ignore_ascii_case("type")
}

/// Whether a property-name template begins, *literally*, with `--` (a custom
/// property). A name whose first piece is `#{…}` interpolation is not literal,
/// so `#{--b}` namespaces normally while a written `--b` is a custom property.
fn property_is_literal_custom(property: &[TplPiece]) -> bool {
    match property.first() {
        Some(TplPiece::Lit(s)) => s.trim_start().starts_with("--"),
        _ => false,
    }
}

/// Whether the span between a `property:` colon and the following `{` is empty
/// of any value — only whitespace and `/* */` / `//` comments. Such a span
/// makes `property: { … }` a bare nested property set (no leading value).
fn value_is_only_comments(span: &[char]) -> bool {
    let mut i = 0;
    while i < span.len() {
        let c = span[i];
        if c.is_whitespace() {
            i += 1;
        } else if c == '/' && span.get(i + 1) == Some(&'*') {
            i += 2;
            while i + 1 < span.len() && !(span[i] == '*' && span[i + 1] == '/') {
                i += 1;
            }
            i += 2;
        } else if c == '/' && span.get(i + 1) == Some(&'/') {
            while i < span.len() && span[i] != '\n' {
                i += 1;
            }
        } else {
            return false;
        }
    }
    true
}

impl Parser {
    /// Skip inline whitespace; report whether any was consumed.
    fn skip_ws_inline(&mut self) -> bool {
        let mut any = false;
        loop {
            match self.sc.peek() {
                Some(c) if c.is_whitespace() => {
                    self.sc.bump();
                    any = true;
                }
                // `/* ... */` loud and `// ...` silent comments act as
                // whitespace between value tokens (`c /* d */ e`, `c // d`).
                Some('/') if self.sc.peek_at(1) == Some('*') => {
                    self.sc.bump();
                    self.sc.bump();
                    while let Some(c) = self.sc.peek() {
                        if c == '*' && self.sc.peek_at(1) == Some('/') {
                            self.sc.bump();
                            self.sc.bump();
                            break;
                        }
                        self.sc.bump();
                    }
                    any = true;
                }
                // In plain CSS `//` is not a comment: each `/` is a value token
                // (`1///bar` round-trips), so it must not be skipped.
                Some('/') if self.sc.peek_at(1) == Some('/') && !self.plain_css => {
                    while let Some(c) = self.sc.peek() {
                        if c == '\n' {
                            break;
                        }
                        self.sc.bump();
                    }
                    any = true;
                }
                _ => break,
            }
        }
        any
    }

    /// Parse a `{ … }` statement block.
    fn parse_braced_body(&mut self) -> Result<Vec<Stmt>, Error> {
        Ok(self.parse_braced_body_lines()?.0)
    }

    /// Parse a `{ … }` statement block, also reporting the `{`/`}` source
    /// lines (for the serializer's trailing-comment rule; `file` stays 0).
    fn parse_braced_body_lines(&mut self) -> Result<(Vec<Stmt>, SrcLines), Error> {
        self.skip_ws_inline();
        let brace_line = self.sc.position().line as u32;
        if !self.sc.eat('{') {
            return Err(Error::at("expected \"{\".", self.sc.position()));
        }
        self.block_depth += 1;
        let body = self.parse_statements(false);
        self.block_depth -= 1;
        let body = body?;
        if !self.sc.eat('}') {
            return Err(Error::at("expected \"}\"", self.sc.position()));
        }
        let lines = SrcLines {
            file: 0,
            start: brace_line,
            end: self.sc.position().line as u32,
            col: 0,
            start_col: 0,
            map_file: 0,
            map_line: 0,
        };
        Ok((body, lines))
    }

    /// Parse an interpolated template (selector or property name) up to,
    /// but not including, one of `stops` at bracket depth 0.
    fn parse_template(&mut self, stops: &[char]) -> Result<Vec<TplPiece>, Error> {
        self.parse_template_mode(stops, CommentMode::Keep)
    }

    /// Consume the `/* ... */` loud comment at the cursor (the leading `/*`
    /// must already be confirmed by the caller) and return its inner text
    /// including the surrounding delimiters, i.e. the full `/* ... */`.
    fn consume_loud_comment(&mut self) -> String {
        let mut s = String::from("/*");
        self.sc.bump();
        self.sc.bump();
        loop {
            match self.sc.peek() {
                None => break,
                Some('*') if self.sc.peek_at(1) == Some('/') => {
                    self.sc.bump();
                    self.sc.bump();
                    s.push_str("*/");
                    break;
                }
                Some(c) => {
                    s.push(c);
                    self.sc.bump();
                }
            }
        }
        s
    }

    /// Consume the `// ...` silent comment at the cursor up to (but not
    /// including) the newline; the leading `//` must already be confirmed.
    fn consume_silent_comment(&mut self) {
        while let Some(c) = self.sc.peek() {
            if c == '\n' {
                break;
            }
            self.sc.bump();
        }
    }

    /// In plain-CSS mode, a `#{…}` interpolation is an error. dart-sass raises
    /// it at the END of `singleInterpolation`, once the body has parsed and the
    /// `}` is consumed, so a malformed expression inside reports itself first
    /// (`#{$x}` is "Sass variables aren't allowed in plain CSS", `#{ }` is
    /// "Expected expression") and the caret spans the whole `#{…}`. `mark` must
    /// be the cursor as it stood at the `#`.
    fn reject_plain_css_interp(&self, mark: Mark) -> Result<(), Error> {
        if self.plain_css {
            return Err(Error::at("Interpolation isn't allowed in plain CSS.", mark.pos())
                .with_length(self.sc.byte_len_from(mark)));
        }
        Ok(())
    }

    /// Parse the expression inside a `#{ … }` (cursor just past the `{`).
    ///
    /// Interpolation is a full SassScript context even when it sits inside a
    /// calculation: dart-sass evaluates `#{-$x}` in `calc(#{-$x} - 1px)` as an
    /// ordinary expression and splices the resulting text into the calc. So
    /// the calc-only grammar restrictions (no `-$x`, no `- 1px`, no `/`
    /// division) must not leak into the interpolated expression — suspend
    /// `calc_depth` for its duration.
    pub(super) fn parse_interp_value(&mut self) -> Result<Expr, Error> {
        self.plain_css_interp |= self.plain_css;
        let saved = std::mem::replace(&mut self.calc_depth, 0);
        let e = self.parse_value();
        self.calc_depth = saved;
        e
    }

    fn parse_template_mode(&mut self, stops: &[char], comments: CommentMode) -> Result<Vec<TplPiece>, Error> {
        let mut pieces = Vec::new();
        let mut lit = String::new();
        let mut paren = 0i32;
        let mut bracket = 0i32;
        // Whether a glued loud comment already joined a DeclName template
        // (dart appends at most ONE `rawText(loudComment)` to the name).
        let mut glued = false;
        while let Some(c) = self.sc.peek() {
            // A CSS escape makes the next character literal identifier text:
            // an escaped stop char (`.govuk-\!-font-size-19`) is part of the
            // selector, never a boundary (dart consumes `\X` in identifiers).
            // A NEWLINE is not a character it can escape — dart's `escape()`
            // fails there, so `.a,\` + `.b` is an error rather than a selector
            // containing an escaped line break.
            if c == '\\' {
                if matches!(self.sc.peek_at(1), Some('\n' | '\r' | '\u{c}')) {
                    self.sc.bump();
                    return Err(Error::at("Expected escape sequence.", self.sc.position()));
                }
                lit.push(c);
                self.sc.bump();
                if let Some(n) = self.sc.bump() {
                    lit.push(n);
                }
                continue;
            }
            if paren == 0 && bracket == 0 && stops.contains(&c) {
                break;
            }
            // Comment handling depends on the mode and nesting depth.
            if c == '/' && comments != CommentMode::Keep {
                let top = paren == 0 && bracket == 0;
                let strip_here = match comments {
                    CommentMode::Strip | CommentMode::DeclName => true,
                    CommentMode::StripTopLevel | CommentMode::UnknownPrelude => top,
                    CommentMode::Keep => false,
                };
                if strip_here {
                    match self.sc.peek_at(1) {
                        Some('*') => {
                            // A loud comment is kept verbatim for unknown
                            // preludes (dart-sass preserves it) and when glued
                            // directly to a declaration name (issue_1422);
                            // otherwise it collapses to whitespace.
                            let glue_to_name = comments == CommentMode::DeclName
                                && !glued
                                && lit
                                    .chars()
                                    .last()
                                    .map_or(!pieces.is_empty(), |p| !p.is_whitespace());
                            if comments == CommentMode::UnknownPrelude || glue_to_name {
                                let text = self.consume_loud_comment();
                                lit.push_str(&text);
                                glued = true;
                            } else {
                                let _ = self.consume_loud_comment();
                                lit.push(' ');
                            }
                            continue;
                        }
                        Some('/') => {
                            // A silent comment always acts as whitespace. For
                            // unknown preludes nothing is inserted (the trailing
                            // newline left in the source provides the gap and
                            // edges are trimmed); otherwise a single space.
                            self.consume_silent_comment();
                            if comments != CommentMode::UnknownPrelude {
                                lit.push(' ');
                            }
                            continue;
                        }
                        _ => {}
                    }
                }
            }
            // For unknown at-rule preludes dart collapses a whitespace run
            // WITHOUT a newline to one space and keeps a run WITH one from
            // its first newline (`@asdf a  b` → `a b`; `c \n   d` →
            // `c\n   d`). Comments terminate a run, so `foo //\n  bar`
            // keeps foo's trailing space AND the newline indent.
            if comments == CommentMode::UnknownPrelude && c.is_whitespace() {
                let mut run = String::new();
                while matches!(self.sc.peek(), Some(w) if w.is_whitespace()) {
                    if let Some(w) = self.sc.bump() {
                        run.push(w);
                    }
                }
                match run.find('\n') {
                    Some(nl) => lit.push_str(&run[nl..]),
                    None => lit.push(' '),
                }
                continue;
            }
            match c {
                '#' if self.sc.peek_at(1) == Some('{') => {
                    let interp_mark = self.sc.mark();
                    if !lit.is_empty() {
                        pieces.push(take_lit(&mut lit));
                    }
                    self.sc.bump();
                    self.sc.bump();
                    // Record the expression span for a rule selector's
                    // dual-span diagnostic; nested template parses inside the
                    // expression suspend collection.
                    let span_start = self.sc.position();
                    let collect = std::mem::replace(&mut self.collect_interp_spans, false);
                    let e = self.parse_value()?;
                    self.skip_ws_inline();
                    self.collect_interp_spans = collect;
                    if collect {
                        let end = self.sc.position();
                        self.interp_spans.push((
                            span_start.line as u32,
                            span_start.col as u32,
                            end.col as u32,
                        ));
                    }
                    if !self.sc.eat('}') {
                        return Err(Error::at("expected \"}\"", self.sc.position()));
                    }
                    self.reject_plain_css_interp(interp_mark)?;
                    pieces.push(TplPiece::Interp(e));
                }
                '"' | '\'' => {
                    // The quote characters are literal prelude text, but `#{…}`
                    // inside the string is still interpolation (dart-sass resolves
                    // `"foo#{x}baz"` in an at-rule prelude to `"foo<x>baz"`).
                    lit.push(c);
                    self.sc.bump();
                    while let Some(ch) = self.sc.peek() {
                        if ch == '\\' {
                            // A `\` before a newline is a CSS line continuation
                            // and the pair vanishes, as in any other string;
                            // copying it through left a raw line break in the
                            // selector text.
                            if matches!(self.sc.peek_at(1), Some('\n' | '\r' | '\u{c}')) {
                                self.sc.bump();
                                if self.sc.peek() == Some('\r') {
                                    self.sc.bump();
                                    self.sc.eat('\n');
                                } else {
                                    self.sc.bump();
                                }
                                continue;
                            }
                            lit.push(ch);
                            self.sc.bump();
                            if let Some(n) = self.sc.bump() {
                                lit.push(n);
                            }
                            continue;
                        }
                        if ch == '#' && self.sc.peek_at(1) == Some('{') {
                            let interp_mark = self.sc.mark();
                            if !lit.is_empty() {
                                pieces.push(take_lit(&mut lit));
                            }
                            self.sc.bump();
                            self.sc.bump();
                            let e = self.parse_value()?;
                            self.skip_ws_inline();
                            if !self.sc.eat('}') {
                                return Err(Error::at("expected \"}\"", self.sc.position()));
                            }
                            self.reject_plain_css_interp(interp_mark)?;
                            pieces.push(TplPiece::Interp(e));
                            continue;
                        }
                        lit.push(ch);
                        self.sc.bump();
                        if ch == c {
                            break;
                        }
                    }
                }
                '(' => {
                    paren += 1;
                    lit.push(c);
                    self.sc.bump();
                }
                ')' => {
                    paren -= 1;
                    lit.push(c);
                    self.sc.bump();
                }
                '[' => {
                    bracket += 1;
                    lit.push(c);
                    self.sc.bump();
                }
                ']' => {
                    bracket -= 1;
                    lit.push(c);
                    self.sc.bump();
                }
                _ => {
                    lit.push(c);
                    self.sc.bump();
                }
            }
        }
        if !lit.is_empty() {
            pieces.push(take_lit(&mut lit));
        }
        Ok(pieces)
    }

    /// Consume a CSS escape sequence and return the code point it stands for.
    /// The opening `\` must be the next character; it is consumed here. A
    /// backslash at end-of-input decodes to U+FFFD, matching dart-sass; a
    /// backslash before a NEWLINE is not an escape at all (dart's `escape()`
    /// fails there, and only its string reader drops the pair as a CSS line
    /// continuation before ever calling it). Errors on an out-of-range Unicode
    /// code point.
    fn consume_escape(&mut self) -> Result<char, Error> {
        let pos = self.sc.position();
        self.sc.bump(); // the leading backslash
        match self.sc.peek() {
            // A line continuation is legal only inside a quoted string, and the
            // string reader consumes it before this is reached.
            Some('\n' | '\r' | '\u{c}') => Err(Error::at("Expected escape sequence.", self.sc.position())),
            Some(c) if c.is_ascii_hexdigit() => {
                let mut value: u32 = 0;
                let mut digits = 0;
                while digits < 6 {
                    match self.sc.peek() {
                        Some(h) if h.is_ascii_hexdigit() => {
                            value = value * 16 + h.to_digit(16).unwrap_or(0);
                            self.sc.bump();
                            digits += 1;
                        }
                        _ => break,
                    }
                }
                // A single trailing whitespace character terminates the escape
                // and is consumed — one CHARACTER, so the `\n` of a CRLF is
                // left behind and still separates tokens: dart reads
                // `b: \61` + CRLF + `b` as the two identifiers `a b`.
                if matches!(self.sc.peek(), Some(' ' | '\t' | '\n' | '\r' | '\u{c}')) {
                    self.sc.bump();
                }
                if value > 0x10_FFFF {
                    return Err(Error::at("Invalid Unicode code point.", pos));
                }
                // Surrogate code points cannot be represented and become the
                // replacement char; NUL is kept (it serializes as `\0 `).
                Ok(char::from_u32(value).unwrap_or('\u{FFFD}'))
            }
            // Any other character escapes to itself literally.
            Some(c) => {
                self.sc.bump();
                Ok(c)
            }
            None => Ok('\u{FFFD}'),
        }
    }

    /// Read a variable name (after `$`), normalizing `_` to `-` like dart's
    /// `variableName()` — `$a_b` and `$a-b` are the SAME variable. Function /
    /// mixin and CSS identifiers keep their spelling (normalization for those
    /// happens at definition/lookup, so plain-CSS output preserves `_`).
    fn read_variable_name(&mut self) -> Result<String, Error> {
        let name = self.read_ident_name()?;
        if name.contains('_') {
            Ok(name.replace('_', "-"))
        } else {
            Ok(name)
        }
    }

    fn read_ident_name(&mut self) -> Result<String, Error> {
        let mut s = String::new();
        loop {
            match self.sc.peek() {
                Some(c) if is_ident_char(c) => {
                    self.sc.bump();
                    s.push(c);
                }
                // dart decodes identifier escapes at the lexer level —
                // `@w\61rn` IS `@warn` and `f\6Fo-bar` defines `foo-bar` —
                // so the stored name is the decoded spelling.
                Some('\\') => s.push(self.read_escape_char()?),
                _ => break,
            }
        }
        if s.is_empty() {
            return Err(Error::at("expected an identifier", self.sc.position()));
        }
        Ok(s)
    }

    /// Read a module namespace / forward prefix. dart-sass requires a real
    /// identifier here, so a digit-leading name (`@use "x" as 0`) is
    /// "Expected identifier." rather than a silently-accepted namespace.
    fn read_namespace_ident(&mut self) -> Result<String, Error> {
        if matches!(self.sc.peek(), Some(c) if c.is_ascii_digit()) {
            return Err(Error::at("Expected identifier.", self.sc.position()));
        }
        self.read_ident_name()
    }

    /// Decode a `\` escape inside an identifier (dart `escapeCharacter`):
    /// 1-6 hex digits (plus one optional trailing whitespace) become the
    /// code point — zero, surrogates, and out-of-range collapse to U+FFFD —
    /// and any other character is taken literally.
    fn read_escape_char(&mut self) -> Result<char, Error> {
        self.sc.bump(); // the backslash
        let first = match self.sc.peek() {
            // A form feed is a newline to dart (`isNewline`), so it is not a
            // character an escape can stand for either.
            None | Some('\n') | Some('\r') | Some('\u{c}') => {
                return Err(Error::at("Expected escape sequence.", self.sc.position()))
            }
            Some(c) => c,
        };
        if first.is_ascii_hexdigit() {
            let mut value: u32 = 0;
            for _ in 0..6 {
                match self.sc.peek() {
                    Some(c) if c.is_ascii_hexdigit() => {
                        value = (value << 4) + c.to_digit(16).unwrap();
                        self.sc.bump();
                    }
                    _ => break,
                }
            }
            // One optional whitespace terminator. A CRLF counts as ONE line
            // break here — `--x: \61` + CRLF + `b` is `ab` in dart, with no
            // line break left in the value.
            if matches!(self.sc.peek(), Some(' ' | '\t' | '\n' | '\r' | '\u{c}')) {
                let cr = self.sc.peek() == Some('\r');
                self.sc.bump();
                if cr {
                    self.sc.eat('\n');
                }
            }
            // NUL is KEPT (it re-serializes as `\0 `, dart's consume_escape);
            // surrogates and out-of-range code points become the replacement
            // character.
            if (0xD800..=0xDFFF).contains(&value) || value > 0x10FFFF {
                return Ok('\u{FFFD}');
            }
            Ok(char::from_u32(value).unwrap_or('\u{FFFD}'))
        } else {
            self.sc.bump();
            Ok(first)
        }
    }
}
