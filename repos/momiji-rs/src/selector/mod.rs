//! A structured CSS selector model plus the `@extend` engine.
//!
//! Selectors are parsed from their already-resolved string form (after `&`
//! and interpolation have been substituted by the evaluator) into a small
//! tree — [`ComplexSelector`] → [`ComplexComponent`] → [`CompoundSelector`]
//! → [`SimpleSelector`] — that mirrors dart-sass's model closely enough to
//! port its `@extend` algorithm (extension, unification, transitive chains,
//! and placeholder-rule dropping).

use crate::fxhash::{FxHashMap, FxHashSet};
use std::hash::{Hash, Hasher};

/// A value paired with its precomputed FxHash, so a map keyed by `Hashed<T>`
/// hashes the (already-walked) inner `T` exactly ONCE — at construction — and
/// every subsequent map probe just re-mixes the cached `u64`. `Eq` still
/// compares the inner `value` structurally, so the map partitions IDENTICALLY
/// to one keyed by the bare `T` (byte-exact: these maps are only probed for
/// membership/lookup, never iterated for output order). Used for the `@extend`
/// engine's per-batch `Complex`-keyed maps, whose derived `Hash` otherwise
/// re-walks the whole components→compounds→simples→`String` tree on every probe.
struct Hashed<T> {
    hash: u64,
    value: T,
}

impl<T: Hash> Hashed<T> {
    #[inline]
    fn new(value: T) -> Self {
        let mut h = crate::fxhash::FxHasher::default();
        value.hash(&mut h);
        Hashed {
            hash: h.finish(),
            value,
        }
    }
}

impl<T> Hash for Hashed<T> {
    #[inline]
    fn hash<H: Hasher>(&self, state: &mut H) {
        state.write_u64(self.hash);
    }
}

impl<T: PartialEq> PartialEq for Hashed<T> {
    #[inline]
    fn eq(&self, other: &Self) -> bool {
        // The cached hash is a cheap discriminator before the structural compare.
        self.hash == other.hash && self.value == other.value
    }
}

impl<T: Eq> Eq for Hashed<T> {}

/// A combinator joining two compound selectors.
#[derive(Clone, Copy, PartialEq, Eq, Hash, Debug)]
pub(crate) enum Combinator {
    Child,            // >
    NextSibling,      // +
    FollowingSibling, // ~
}

impl Combinator {
    pub(crate) fn as_str(self) -> &'static str {
        match self {
            Combinator::Child => ">",
            Combinator::NextSibling => "+",
            Combinator::FollowingSibling => "~",
        }
    }
}

/// One simple selector: the atoms of a compound selector.
#[derive(Clone, PartialEq, Eq, Hash, Debug)]
pub(crate) enum Simple {
    /// `*` or `ns|*`. Stores the optional namespace prefix verbatim.
    Universal { ns: Option<String> },
    /// A type/element selector, e.g. `div`, `svg|rect`. Stored verbatim.
    Type(String),
    /// `.foo`
    Class(String),
    /// `#foo`
    Id(String),
    /// `%foo`
    Placeholder(String),
    /// `[attr=val i]` etc. — the whole bracketed text including `[` `]`.
    Attribute(String),
    /// A pseudo class/element. Stored verbatim text including leading colon(s),
    /// e.g. `:hover`, `::before`, `:not(.x)`.
    Pseudo(String),
}

impl Simple {
    pub(crate) fn render(&self) -> String {
        match self {
            Simple::Universal { ns: None } => "*".to_string(),
            Simple::Universal { ns: Some(n) } => format!("{n}|*"),
            Simple::Type(s) => s.clone(),
            Simple::Class(s) => format!(".{s}"),
            Simple::Id(s) => format!("#{s}"),
            Simple::Placeholder(s) => format!("%{s}"),
            Simple::Attribute(s) => s.clone(),
            Simple::Pseudo(s) => s.clone(),
        }
    }

    fn is_placeholder(&self) -> bool {
        matches!(self, Simple::Placeholder(_))
    }
}

/// A resolved selector as dart-sass writes it in COMPRESSED style.
///
/// Two kinds of whitespace go, and no others:
///
/// * the space on either side of a COMBINATOR — `.a > .b` is `.a>.b`, and a
///   combinator that opens a relative selector loses its trailing space too
///   (`:has(+ .b)` is `:has(+.b)`);
/// * the space after the comma of a SELECTOR LIST — the list a `:not()`,
///   `:is()`, `:where()`, `:has()` … carries, or the `of` tail of an
///   `:nth-child()`.
///
/// Every other space is structure (`.a .b` IS the descendant combinator) and
/// every other comma is opaque: `:lang(en, fr)` keeps its space, because its
/// argument is an identifier list and not a selector list. Attribute values and
/// quoted strings are copied through untouched.
///
/// The top-level list's own commas never reach here — emit joins the complexes
/// with `,` itself.
pub(crate) fn compress_selector(sel: &str) -> std::borrow::Cow<'_, str> {
    // Nothing to do unless the selector has a combinator or a pseudo argument.
    if !sel.bytes().any(|b| matches!(b, b'>' | b'+' | b'~' | b'(')) {
        return std::borrow::Cow::Borrowed(sel);
    }
    let chars: Vec<char> = sel.chars().collect();
    let mut out = String::with_capacity(sel.len());
    compress_into(&mut out, &chars);
    std::borrow::Cow::Owned(out)
}

/// Append `chars` — one complex selector, or one component of a selector list
/// argument — to `out` in compressed form.
fn compress_into(out: &mut String, chars: &[char]) {
    let mut i = 0usize;
    while i < chars.len() {
        match chars[i] {
            '\\' => {
                let end = escape_end(chars, i);
                out.extend(&chars[i..end]);
                i = end;
            }
            '"' | '\'' => {
                let end = skip_quoted(chars, i);
                out.extend(&chars[i..end.min(chars.len())]);
                i = end;
            }
            '[' => {
                // An attribute selector: its insides are not selector structure.
                let end = skip_attribute(chars, i);
                out.extend(&chars[i..end.min(chars.len())]);
                i = end;
            }
            ' ' | '\t' | '\n' | '\r' => {
                let mut j = i;
                while j < chars.len() && chars[j].is_whitespace() {
                    j += 1;
                }
                // A run of whitespace IS the descendant combinator — unless
                // what follows is a combinator of its own, which eats it.
                if !matches!(chars.get(j), Some('>' | '+' | '~')) && j < chars.len() {
                    out.push(' ');
                }
                i = j;
            }
            '>' | '+' | '~' => {
                out.push(chars[i]);
                i += 1;
                while i < chars.len() && chars[i].is_whitespace() {
                    i += 1;
                }
            }
            ':' => {
                let name_start = i + 1 + usize::from(chars.get(i + 1) == Some(&':'));
                let mut j = name_start;
                while j < chars.len()
                    && (chars[j].is_ascii_alphanumeric()
                        || chars[j] == '-'
                        || chars[j] == '_'
                        || (chars[j] as u32) >= 0x80)
                {
                    j += 1;
                }
                if chars.get(j) != Some(&'(') {
                    out.extend(&chars[i..j]);
                    i = j;
                    continue;
                }
                let close = matching_paren(chars, j);
                let name: String = chars[name_start..j].iter().collect();
                out.extend(&chars[i..=j]);
                compress_pseudo_arg(out, &name, &chars[j + 1..close.min(chars.len())]);
                if close < chars.len() {
                    out.push(')');
                    i = close + 1;
                } else {
                    i = chars.len();
                }
            }
            c => {
                out.push(c);
                i += 1;
            }
        }
    }
}

/// Append one pseudo's argument, compressed according to what that pseudo
/// takes: a selector list, an An+B (with an optional `of` list), or an opaque
/// run copied verbatim.
fn compress_pseudo_arg(out: &mut String, name: &str, inner: &[char]) {
    let unv = unvendor(name);
    if unv == "nth-child" || unv == "nth-last-child" {
        // The An+B itself is already normalised; only the `of` tail is a
        // selector list.
        let arg: String = inner.iter().collect();
        match arg.find(" of ") {
            Some(at) => {
                out.push_str(&arg[..at + 4]);
                compress_selector_list(out, &arg[at + 4..]);
            }
            None => out.push_str(&arg),
        }
        return;
    }
    let is_selector_pseudo = matches!(
        unv,
        "not" | "is" | "where" | "has" | "matches" | "any" | "host" | "host-context" | "current" | "slotted"
    ) || unv.ends_with("-any");
    if is_selector_pseudo {
        let arg: String = inner.iter().collect();
        compress_selector_list(out, &arg);
    } else {
        out.extend(inner);
    }
}

/// The index just past the CSS escape starting at `start` (which holds a `\`):
/// up to six hex digits and the single whitespace character that terminates
/// them, or the one character that follows a non-hex escape. The terminator is
/// part of the TOKEN — `.\31  .b` is the class `1` and then a descendant
/// combinator, and losing either space changes which.
fn escape_end(chars: &[char], start: usize) -> usize {
    let mut i = start + 1;
    if !chars.get(i).is_some_and(char::is_ascii_hexdigit) {
        // `\,`, `\ `, `\+` … — exactly one character, whatever it is.
        return (i + 1).min(chars.len());
    }
    let hex_start = i;
    while i < chars.len() && i - hex_start < 6 && chars[i].is_ascii_hexdigit() {
        i += 1;
    }
    // One whitespace character closes the run (and CRLF counts as one).
    match chars.get(i) {
        Some('\r') if chars.get(i + 1) == Some(&'\n') => i + 2,
        Some(c) if c.is_whitespace() => i + 1,
        _ => i,
    }
}

/// Append a selector-list argument: each component compressed, joined by a bare
/// comma.
fn compress_selector_list(out: &mut String, arg: &str) {
    for (i, part) in parse::split_top(arg, ',').iter().enumerate() {
        if i > 0 {
            out.push(',');
        }
        let cs: Vec<char> = part.trim_start().chars().collect();
        compress_into(out, &cs);
    }
}

/// Validate the arguments of every grammar-typed pseudo in a resolved selector
/// string the way dart-sass does, returning the exact dart error message on a
/// malformed one. Two pseudo families carry a strict grammar. The An+B pseudos
/// `:nth-child` / `:nth-last-child` (see [`validate_nth`]) — including a vendor
/// prefix (`unvendor(name)` must equal the bare name) — take an An+B argument.
/// The selector-argument pseudos `:not` / `:is` / `:where` / `:has` / `:matches`
/// / `:any` / `:-*-any` / `:host` / `:host-context` / `:current` take a non-empty
/// selector list (an empty leading or trailing component is dart's
/// `expected selector.`), recursively validated. Every OTHER pseudo (`:lang`,
/// `:dir`, custom `:--foo`, unknown `:foo`) takes an opaque argument and is left
/// untouched. The input is already interpolation-resolved, so this matches dart
/// validating the resolved text.
pub(crate) fn validate_pseudo_args(sel: &str) -> Result<(), &'static str> {
    let chars: Vec<char> = sel.chars().collect();
    validate_pseudo_args_inner(&chars)
}

fn validate_pseudo_args_inner(chars: &[char]) -> Result<(), &'static str> {
    let mut i = 0usize;
    while i < chars.len() {
        match chars[i] {
            '\\' => {
                i += 2;
                continue;
            }
            '"' | '\'' => {
                i = skip_quoted(chars, i);
                continue;
            }
            '[' => {
                // Skip a whole attribute selector; commas/parens inside it are
                // not selector structure.
                i = skip_attribute(chars, i);
                continue;
            }
            ':' => {
                // A pseudo: read the name, then (if present) its `(...)` arg.
                let name_start = i + 1 + usize::from(chars.get(i + 1) == Some(&':'));
                let mut j = name_start;
                while j < chars.len()
                    && (chars[j].is_ascii_alphanumeric()
                        || chars[j] == '-'
                        || chars[j] == '_'
                        || (chars[j] as u32) >= 0x80)
                {
                    j += 1;
                }
                if j < chars.len() && chars[j] == '(' {
                    let close = matching_paren(chars, j);
                    let name: String = chars[name_start..j].iter().collect();
                    let inner = &chars[j + 1..close.min(chars.len())];
                    validate_one_pseudo_arg(&name, inner)?;
                    i = if close < chars.len() {
                        close + 1
                    } else {
                        chars.len()
                    };
                    continue;
                }
                i = j;
                continue;
            }
            _ => i += 1,
        }
    }
    Ok(())
}

/// Validate one pseudo's `(...)` argument (`inner`, without the parens) given
/// its `name` (without the leading colon). Dispatches on the unvendored
/// lowercase name; opaque pseudos return `Ok` untouched.
fn validate_one_pseudo_arg(name: &str, inner: &[char]) -> Result<(), &'static str> {
    let unv = unvendor(name);
    // An+B pseudos.
    if unv == "nth-child" || unv == "nth-last-child" {
        let arg: String = inner.iter().collect();
        validate_nth(&arg)?;
        // Recurse into the `of <selector>` tail's selector list (validated
        // non-empty by `validate_nth`; here its nested pseudos are checked).
        if let Some(of_sel) = nth_of_selector(inner) {
            validate_selector_list_arg(&of_sel)?;
        }
        return Ok(());
    }
    // Selector-argument pseudos.
    let is_selector_pseudo = matches!(
        unv,
        "not" | "is" | "where" | "has" | "matches" | "any" | "host" | "host-context" | "current"
    ) || unv.ends_with("-any");
    if is_selector_pseudo {
        let arg: String = inner.iter().collect();
        return validate_selector_list_arg(&arg);
    }
    // Any other pseudo carries an opaque argument.
    Ok(())
}

/// Validate a selector-list argument (the inside of a `:not(...)` etc., or an
/// `of` tail): split on top-level commas; the FIRST and LAST components must be
/// non-empty (dart reads complexes around comma runs and errors on an empty
/// leading/trailing one — `:not(, .a)`, `:not(.a, )`, `:not()` all
/// `expected selector.`; an empty MIDDLE part `:not(.a,, .b)` is tolerated).
/// Each non-empty component is recursively scanned for nested pseudo grammar.
fn validate_selector_list_arg(arg: &str) -> Result<(), &'static str> {
    let parts = split_top(arg, ',');
    // An all-empty argument (`()`, `( )`) has no first complex.
    if parts.iter().all(|p| p.trim().is_empty()) {
        return Err("expected selector.");
    }
    if parts.first().is_some_and(|p| p.trim().is_empty()) || parts.last().is_some_and(|p| p.trim().is_empty())
    {
        return Err("expected selector.");
    }
    for part in &parts {
        if part.trim().is_empty() {
            continue;
        }
        let cs: Vec<char> = part.chars().collect();
        validate_pseudo_args_inner(&cs)?;
    }
    Ok(())
}

/// Index of the `)` matching the `(` at `open`, honouring strings/escapes and
/// nested parens. Returns `chars.len()` when unmatched.
fn matching_paren(chars: &[char], open: usize) -> usize {
    let mut depth = 0i32;
    let mut i = open;
    while i < chars.len() {
        match chars[i] {
            '\\' => i += 2,
            '"' | '\'' => i = skip_quoted(chars, i),
            '(' => {
                depth += 1;
                i += 1;
            }
            ')' => {
                depth -= 1;
                if depth == 0 {
                    return i;
                }
                i += 1;
            }
            _ => i += 1,
        }
    }
    chars.len()
}

/// Index just past a quoted string starting at `start`, honouring `\` escapes;
/// `chars.len()` for an unterminated string.
fn skip_quoted(chars: &[char], start: usize) -> usize {
    let q = chars[start];
    let mut i = start + 1;
    while i < chars.len() {
        match chars[i] {
            '\\' => i += 2,
            c if c == q => return i + 1,
            _ => i += 1,
        }
    }
    chars.len()
}

/// Index just past a `[...]` attribute selector starting at `start`, honouring
/// strings/escapes; `chars.len()` for an unterminated one.
fn skip_attribute(chars: &[char], start: usize) -> usize {
    let mut i = start + 1;
    while i < chars.len() {
        match chars[i] {
            '\\' => i += 2,
            '"' | '\'' => i = skip_quoted(chars, i),
            ']' => return i + 1,
            _ => i += 1,
        }
    }
    chars.len()
}

/// Normalize a `:nth-child(…)` / `:nth-last-child(…)` pseudo's An+B argument
/// (`2n + 1` → `2n+1`, `2N + 1` → `2n+1`, `3n - 2` → `3n-2`), preserving an
/// `of <selector>` tail. Only the lowercase `nth-child`/`nth-last-child`
/// pseudos are normalized (dart-sass keeps any other pseudo — including an
/// uppercased name or `:nth-of-type` — verbatim). Returns `None` when the text
/// is not such a pseudo, leaving it unchanged.
pub(crate) fn normalize_nth(text: &str) -> Option<String> {
    let open = text.find('(')?;
    if !text.ends_with(')') {
        return None;
    }
    let name = &text[..open];
    if name != ":nth-child" && name != ":nth-last-child" {
        return None;
    }
    let arg = &text[open + 1..text.len() - 1];
    // Split off an `of <selector>` tail at a whitespace-bounded `of` keyword.
    let lower = arg.to_ascii_lowercase();
    let (anb, of_sel) = match find_of_keyword(&lower) {
        Some(pos) => (&arg[..pos], Some(arg[pos + 2..].trim())),
        None => (arg, None),
    };
    // The An+B canonical form has no internal whitespace and a lowercase `n`.
    let anb_norm: String = anb.chars().filter(|c| !c.is_whitespace()).collect::<String>();
    if anb_norm.is_empty() {
        return None;
    }
    let anb_norm = anb_norm.to_ascii_lowercase();
    Some(match of_sel {
        Some(sel) => format!("{name}({anb_norm} of {sel})"),
        None => format!("{name}({anb_norm})"),
    })
}

/// Validate an `:nth-child` / `:nth-last-child` An+B argument the way dart-sass's
/// `_aNPlusB` (plus the surrounding `of <selector>` handling) does, returning the
/// exact dart error message on a malformed argument. `arg` is the raw text BETWEEN
/// the parentheses (interpolation already resolved). Only the `:nth-child` and
/// `:nth-last-child` pseudos are validated; dart leaves `:nth-of-type` and
/// `:nth-last-of-type` permissive, so their callers never reach here.
///
/// Grammar (dart `_aNPlusB`, scanner-based, derived empirically):
///   leading whitespace is skipped, then one of:
///     - `even` / `odd` (case-insensitive, a whole-identifier match), OR
///     - an optional `+`/`-` sign, optional run of digits, then either:
///         * `n`/`N` (only after the optional sign+digits, with NO whitespace
///           skipped before it UNLESS digits were consumed), followed by an
///           optional ` [+-] <digits>` tail; OR
///         * nothing more (a pure integer — requires at least one digit).
///   After the An+B, an optional ` of <selector>` tail (whitespace-introduced)
///   is allowed; any other trailing content is rejected.
pub(crate) fn validate_nth(arg: &str) -> Result<(), &'static str> {
    let chars: Vec<char> = arg.chars().collect();
    let mut i = 0usize;
    let skip_ws = |i: &mut usize| {
        while *i < chars.len() && chars[*i].is_whitespace() {
            *i += 1;
        }
    };
    skip_ws(&mut i);
    // `even` / `odd` — a whole keyword, case-insensitive.
    match chars.get(i).map(|c| c.to_ascii_lowercase()) {
        Some('e') => return finish_nth(&chars, scan_keyword(&chars, &mut i, "even")?),
        Some('o') => return finish_nth(&chars, scan_keyword(&chars, &mut i, "odd")?),
        _ => {}
    }
    // Optional sign.
    if matches!(chars.get(i), Some('+' | '-')) {
        i += 1;
    }
    // Optional run of digits.
    let digits_start = i;
    while matches!(chars.get(i), Some(c) if c.is_ascii_digit()) {
        i += 1;
    }
    let saw_digit = i > digits_start;
    // Position right after the An+B body so far (before any speculative ws skip),
    // so `finish_nth` can tell whether whitespace separated trailing content.
    let mut body_end = i;
    // dart skips whitespace before `n` ONLY when digits were consumed (`5 n`
    // is `5n`, but `+ n` errors). With no digits, `n` must follow immediately.
    if saw_digit {
        skip_ws(&mut i);
    }
    if matches!(chars.get(i), Some('n' | 'N')) {
        i += 1;
        body_end = i;
        // Optional ` [+-] <digits>` tail.
        skip_ws(&mut i);
        if matches!(chars.get(i), Some('+' | '-')) {
            i += 1;
            skip_ws(&mut i);
            if !matches!(chars.get(i), Some(c) if c.is_ascii_digit()) {
                return Err("Expected a number.");
            }
            while matches!(chars.get(i), Some(c) if c.is_ascii_digit()) {
                i += 1;
            }
            body_end = i;
        }
        return finish_nth(&chars, body_end);
    }
    // No `n`: a pure integer needs at least one digit; otherwise dart expects `n`.
    if !saw_digit {
        return Err("Expected \"n\".");
    }
    finish_nth(&chars, body_end)
}

/// After the An+B is consumed at `i`, validate the remaining text: either
/// nothing (modulo trailing whitespace before the close — dart's caller is at
/// `)`), or a whitespace-introduced ` of <selector>` tail whose selector list
/// is non-empty. Trailing junk with no `of` is dart's `Expected "of".`; junk
/// glued with no whitespace before it is the caller's `expected ")".`.
fn finish_nth(chars: &[char], mut i: usize) -> Result<(), &'static str> {
    // dart only treats trailing content as an `of` clause when whitespace
    // separates it from the An+B; glued junk (`n1`, `2n+1of`) is left for the
    // caller, which then reports `expected ")".`.
    let had_ws = i < chars.len() && chars[i].is_whitespace();
    while i < chars.len() && chars[i].is_whitespace() {
        i += 1;
    }
    if i >= chars.len() {
        return Ok(());
    }
    if !had_ws {
        return Err("expected \")\".");
    }
    // Must be `of` (a complete, case-insensitive identifier) before the
    // selector. dart's `scanIdentifier("of")` distinguishes a mid-scan mismatch
    // (`Expected "of".` WITH a period — wrong char where `o`/`f` was expected)
    // from a fully-matched `of` glued to an extra identifier char (`ofx`,
    // `of-x`, `of9` → `Expected "of"` WITHOUT one). `of.a`/`of#x`/`of:hover` are
    // a complete `of` with the selector glued on (the next char isn't an ident
    // char), so they're accepted.
    if !(matches!(chars.get(i), Some('o' | 'O')) && matches!(chars.get(i + 1), Some('f' | 'F'))) {
        return Err("Expected \"of\".");
    }
    let of_complete = match chars.get(i + 2) {
        None => true,
        Some(c) => !(c.is_ascii_alphanumeric() || *c == '-' || *c == '_' || (*c as u32) >= 0x80),
    };
    if !of_complete {
        return Err("Expected \"of\"");
    }
    i += 2;
    while i < chars.len() && chars[i].is_whitespace() {
        i += 1;
    }
    let rest: String = chars[i..].iter().collect();
    if rest.trim().is_empty() {
        return Err("expected selector.");
    }
    // The `of` selector list is validated by the caller's recursive selector
    // validation; non-empty is the only check made here.
    Ok(())
}

/// Extract the `of <selector>` tail's selector text from an already-validated
/// `:nth-child` argument (the part after a whitespace-introduced, complete-
/// identifier `of` keyword), or `None` when there is no `of` clause.
fn nth_of_selector(inner: &[char]) -> Option<String> {
    let mut i = 0usize;
    // Find a whitespace-bounded `of` that is a complete identifier.
    while i + 1 < inner.len() {
        let before_ws = i > 0 && inner[i - 1].is_whitespace();
        let of_complete = match inner.get(i + 2) {
            None => true,
            Some(c) => !(c.is_ascii_alphanumeric() || *c == '-' || *c == '_' || (*c as u32) >= 0x80),
        };
        if before_ws && matches!(inner[i], 'o' | 'O') && matches!(inner[i + 1], 'f' | 'F') && of_complete {
            let mut j = i + 2;
            while j < inner.len() && inner[j].is_whitespace() {
                j += 1;
            }
            return Some(inner[j..].iter().collect());
        }
        i += 1;
    }
    None
}

/// Scan a whole keyword (`even`/`odd`) case-insensitively starting at `*i`,
/// returning the index past it. dart's `scanIdentifier` distinguishes two
/// failures with DIFFERENT messages: a char that doesn't match the keyword
/// mid-scan (or a too-short input) is `Expected "<kw>".` WITH a period; a full
/// keyword followed by an extra identifier-continuation char (`oddx`, `even1`)
/// is `Expected "<kw>"` WITHOUT one.
fn scan_keyword(chars: &[char], i: &mut usize, kw: &str) -> Result<usize, &'static str> {
    let (mismatch, trailing): (&'static str, &'static str) = match kw {
        "even" => ("Expected \"even\".", "Expected \"even\""),
        _ => ("Expected \"odd\".", "Expected \"odd\""),
    };
    for k in kw.chars() {
        match chars.get(*i) {
            Some(c) if c.to_ascii_lowercase() == k => *i += 1,
            _ => return Err(mismatch),
        }
    }
    // No identifier character may immediately follow the keyword (`oddx`,
    // `even1` are dart errors), but a sign/digit-less boundary is fine.
    if matches!(chars.get(*i), Some(c) if c.is_ascii_alphanumeric() || *c == '-' || *c == '_') {
        return Err(trailing);
    }
    Ok(*i)
}

/// If `text` is a `:nth-child`/`:nth-last-child` with an `of <selector>` tail,
/// return `(name, anb, selector)` — the pseudo name (with colon), the canonical
/// An+B, and the `of` selector list. The selectors compare by `(name, anb)` so
/// a nested same-An+B nth pseudo can be merged and a different one dropped.
fn nth_of_parts(text: &str) -> Option<(&str, &str, &str)> {
    let open = text.find('(')?;
    if !text.ends_with(')') {
        return None;
    }
    let name = &text[..open];
    if name != ":nth-child" && name != ":nth-last-child" {
        return None;
    }
    let arg = &text[open + 1..text.len() - 1];
    let pos = find_of_keyword(&arg.to_ascii_lowercase())?;
    Some((name, arg[..pos].trim(), arg[pos + 2..].trim()))
}

/// The byte index of a whitespace-bounded `of` keyword in an already-lowercased
/// `:nth-child` argument (the boundary between the An+B and the `of <selector>`
/// tail), or `None` if there is no `of` clause.
fn find_of_keyword(lower: &str) -> Option<usize> {
    let bytes = lower.as_bytes();
    let mut i = 0;
    while let Some(rel) = lower[i..].find("of") {
        let pos = i + rel;
        let before_ws = pos == 0 || bytes[pos - 1].is_ascii_whitespace();
        let after = pos + 2;
        let after_ws = after < bytes.len() && bytes[after].is_ascii_whitespace();
        if before_ws && after_ws {
            return Some(pos);
        }
        i = pos + 2;
    }
    None
}

/// A compound selector: a non-empty run of simple selectors with no
/// combinator between them, e.g. `.foo.bar:hover`.
#[derive(Clone, PartialEq, Eq, Hash, Debug)]
pub(crate) struct Compound {
    pub simples: Vec<Simple>,
}

impl Compound {
    pub(crate) fn render(&self) -> String {
        self.simples.iter().map(Simple::render).collect()
    }

    fn has_placeholder(&self) -> bool {
        self.simples.iter().any(Simple::is_placeholder)
    }
}

/// One component of a complex selector: a compound preceded by the (usually
/// empty or single) run of combinators that joins it to the previous component.
/// A run of more than one combinator (`c > > d`) or a leading run (`~ ~ c`) is a
/// "bogus" but parseable selector dart-sass preserves.
#[derive(Clone, PartialEq, Eq, Hash, Debug)]
pub(crate) struct ComplexComponent {
    pub combinators: Vec<Combinator>,
    pub compound: Compound,
}

impl ComplexComponent {
    /// The leading combinator when there is exactly one (the common case);
    /// `None` for a descendant join or a multi-combinator run.
    pub(crate) fn combinator(&self) -> Option<Combinator> {
        match self.combinators.as_slice() {
            [c] => Some(*c),
            _ => None,
        }
    }
}

/// A complex selector: a sequence of compound selectors joined by descendant
/// (whitespace) or explicit combinators, e.g. `.a > .b .c`. `trailing` holds a
/// "bogus" trailing combinator run (`c >`, `c + >`) — or, when `components` is
/// empty, a combinator-only selector (`>`) — that dart-sass preserves.
#[derive(Clone, PartialEq, Eq, Hash, Debug, Default)]
pub(crate) struct Complex {
    pub components: Vec<ComplexComponent>,
    pub trailing: Vec<Combinator>,
}

impl Complex {
    pub(crate) fn render(&self) -> String {
        let mut out = String::new();
        for (i, comp) in self.components.iter().enumerate() {
            if i > 0 {
                out.push(' ');
            }
            for c in &comp.combinators {
                out.push_str(c.as_str());
                out.push(' ');
            }
            out.push_str(&comp.compound.render());
        }
        for (j, c) in self.trailing.iter().enumerate() {
            if j > 0 || !self.components.is_empty() {
                out.push(' ');
            }
            out.push_str(c.as_str());
        }
        out
    }

    fn has_placeholder(&self) -> bool {
        self.components.iter().any(|c| c.compound.has_placeholder())
    }
}

/// Whether a complex selector still contains a placeholder simple (`%foo`).
/// Lets the extend pass test a `Parsed` rule's placeholder fast-path condition
/// on the typed model, with no render.
pub(crate) fn complex_has_placeholder(c: &Complex) -> bool {
    c.has_placeholder()
}

// ---- Phase 1a parity proof: render() injectivity over the typed model ----

/// Debug-only guard for the selector campaign's core invariant: typed
/// `Eq`/`Hash` on [`Complex`] partitions selectors **identically** to their
/// `render()` strings, so the `@extend` engine can migrate its ~28 map/set keys
/// from `render()` `String`s to typed `Complex` keys (Phase 1c/1d) with zero
/// behaviour change. The converse direction is free — `render()` is a pure
/// function (equal structures render equally) and a *derived* `Hash` agrees
/// with `Eq` — so the only non-trivial property is that `render()` is
/// INJECTIVE: no two structurally-distinct selectors share a render string.
/// This guard, called at the engine's key sites, accumulates every keyed
/// `Complex` and panics on the first collision with the offending pair. Proven
/// never to fire across the full sass-spec suite in a debug build (see the
/// `selector_render_injective` parity test).
#[cfg(debug_assertions)]
pub(crate) fn assert_render_injective(c: &Complex) {
    thread_local! {
        static SEEN: std::cell::RefCell<FxHashMap<String, Complex>> =
            std::cell::RefCell::new(FxHashMap::default());
    }
    SEEN.with(|seen| {
        let key = c.render();
        let mut seen = seen.borrow_mut();
        match seen.get(&key) {
            Some(prev) if prev != c => panic!(
                "Phase-1a parity violation (Complex): two structurally distinct \
                 selectors share render {key:?}\n  a = {prev:?}\n  b = {c:?}"
            ),
            Some(_) => {}
            None => {
                seen.insert(key, c.clone());
            }
        }
    });
}

/// As [`assert_render_injective`], for `Simple` keys (the `by_extender` map
/// keys simple selectors by `render()`).
#[cfg(debug_assertions)]
pub(crate) fn assert_simple_render_injective(s: &Simple) {
    thread_local! {
        static SEEN: std::cell::RefCell<FxHashMap<String, Simple>> =
            std::cell::RefCell::new(FxHashMap::default());
    }
    SEEN.with(|seen| {
        let key = s.render();
        let mut seen = seen.borrow_mut();
        match seen.get(&key) {
            Some(prev) if prev != s => panic!(
                "Phase-1a parity violation (Simple): two structurally distinct \
                 simples share render {key:?}\n  a = {prev:?}\n  b = {s:?}"
            ),
            Some(_) => {}
            None => {
                seen.insert(key, s.clone());
            }
        }
    });
}

#[cfg(not(debug_assertions))]
#[inline(always)]
pub(crate) fn assert_render_injective(_c: &Complex) {}

#[cfg(not(debug_assertions))]
#[inline(always)]
pub(crate) fn assert_simple_render_injective(_s: &Simple) {}

mod parse;
pub(crate) use parse::{canonicalize_ident, normalize_attribute, parse_complex_one, parse_list};
use parse::{parse_complex, parse_compound, skip_ws, split_top};

// ---- the extend engine -------------------------------------------------

/// One registered extension: `extender` selectors should be added wherever
/// `target` (a single simple selector) is matched. `target` is `None` when the
/// extend target couldn't be parsed as a single simple selector (it then never
/// matches, but still records "not found" for the !optional check).
#[derive(Clone)]
pub(crate) struct Extension {
    pub target: Option<Simple>,
    /// The extending selector list (the rule body containing `@extend`).
    pub extenders: Vec<Complex>,
    /// Source line-break flags parallel to `extenders`: an extend product
    /// that IS an extender complex inherits its flag (dart's
    /// ComplexSelector.lineBreak travels with the selector object).
    pub extender_breaks: Vec<bool>,
    pub optional: bool,
    /// Whether this extension's target was ever found in the stylesheet.
    /// Shared so scoped clones report back to the original.
    pub matched: std::rc::Rc<std::cell::Cell<bool>>,
    /// The module keys this extension's origin can see (its own key plus its
    /// transitive upstreams). A chained extension (an extender that is itself
    /// extended) only links when the outer extension can see the inner one's
    /// origin (dart-sass per-module stores).
    pub origin: String,
    /// Global registration index (position in the evaluator's `@extend`
    /// sequence). A rule's `extend_base` splits this sequence: extensions
    /// registered before the rule apply one-shot (dart `addSelector`),
    /// later ones incrementally.
    pub reg_idx: usize,
    /// A transitively-derived entry (dart creates these while merging a
    /// downstream store into `origin`'s): it applies only STRICTLY upstream
    /// of `origin`, and sorts after `origin`'s own raw extenders.
    pub derived: bool,
    /// For a derived entry, the origin of the TRIGGERING extension (the
    /// downstream store whose absorption created it) — within a home store,
    /// derived entries follow the absorption order of their trigger.
    pub via_origin: Option<String>,
    // Module-origin set, built in eval (`closure_cache`); kept on std `HashSet`
    // so the FxHash migration stays scoped to this file's selector maps.
    pub origin_closure: std::rc::Rc<std::collections::HashSet<String>>,
}

/// Whether any compound in any complex selector of `list` contains `target`.
pub(crate) fn list_contains_simple(list: &[Complex], target: &Simple) -> bool {
    list.iter().any(|c| {
        c.components
            .iter()
            .any(|comp| comp.compound.simples.contains(target))
    })
}

/// How an `@extend` target string classifies.
pub(crate) enum TargetClass {
    /// A valid single-simple-selector target.
    Simple(Simple),
    /// `@extend a b` — complex selectors may not be extended.
    Complex,
    /// `@extend a.b` / `a:hover` — compound (multi-simple) selectors may no
    /// longer be extended.
    Compound,
    /// Unparseable.
    Invalid,
}

/// Classify an `@extend` target string (already interpolation-resolved).
pub(crate) fn classify_target(s: &str) -> TargetClass {
    let s = s.trim();
    if s.is_empty() {
        return TargetClass::Invalid;
    }
    let Some(complex) = parse_complex(s) else {
        return TargetClass::Invalid;
    };
    if complex.components.len() != 1 || complex.components[0].combinator().is_some() {
        return TargetClass::Complex;
    }
    let simples = &complex.components[0].compound.simples;
    if simples.len() != 1 {
        return TargetClass::Compound;
    }
    TargetClass::Simple(simples[0].clone())
}

/// The result of running the extend engine on a selector list.
pub(crate) struct ExtendResult {
    /// The rewritten selector list, typed. The caller (`OutNode::Rule`) carries
    /// these `Complex` values through to emit, which renders them via
    /// `Complex::render()` — byte-identical to rendering them here (Phase 1d:
    /// no string round trip between the engine and the serializer).
    pub selectors: Vec<Complex>,
    /// Source line-break flags parallel to `selectors`: an original keeps its
    /// input flag, a product that IS an extender complex takes the extender's
    /// flag, and woven products fall back to `false`.
    pub breaks: Vec<bool>,
    /// True if every component still contains a placeholder (rule should drop).
    pub all_placeholders: bool,
}

/// The scope-fixed derivation shared by every rule in one module `scope` with
/// one fixed `extensions` list. Building this is the expensive part — it folds
/// the whole `ExtensionStore` transitive closure (dart's `_extensions` /
/// `_extensionsByExtender` / `_sourceSpecificity`) — and the result depends ONLY
/// on `(extensions, scope)`, NOT on the per-rule selector list. dart builds its
/// store ONCE and then incrementally extends each rule's selector against it; we
/// reproduce that by computing this plan ONCE per scope (in `rewrite_nodes`) and
/// reusing it across every rule, instead of re-deriving the closure per rule
/// (the old O(rules × extensions) blow-up).
pub(crate) struct ExtendPlan {
    /// dart `newExtensionsByTarget` per registration — the per-`@extend` batches
    /// applied by the registration-order fold.
    batches: Vec<Vec<Extension>>,
    /// The full flat extension registry incl. the transitive closure (dart
    /// `_extensions`), driving the one-shot / pseudo-self-ref worklist.
    registry: Vec<Extension>,
    /// Registry length after each input `@extend` was processed: entry `i`
    /// bounds the store visible to a rule created after registration `i`
    /// (dart `addSelector` extends a new rule by the store SO FAR).
    batch_registry_marks: Vec<usize>,
    /// Each input batch's global registration index (ascending — the
    /// visible-subset filter preserves the evaluator's order).
    batch_reg_idx: Vec<usize>,
    /// Each input batch's origin module key.
    batch_origin: Vec<String>,
    /// Per-origin rank in this scope's downstream store-merge flatten
    /// (dart `addExtensions` order): smaller = earlier in the merged map.
    origin_rank: std::collections::HashMap<String, usize>,
    /// Legacy fold order for @import-mixed compiles: no foreign one-shot,
    /// pre-rule split ignores origins (the pre-store-merge model).
    legacy_order: bool,
    /// Store-wide source specificities (dart `_sourceSpecificity`) for `trim`.
    source_spec: FxHashMap<Simple, u64>,
    /// The visible extension count (`extensions.len()`), against which the
    /// per-rule `extend_base` is compared to choose the one-shot path. Stored so
    /// the comparison stays exactly the old `extend_base >= extensions.len()`.
    n_extensions: usize,
    /// dart `single-module` flag: every extension's origin is this scope.
    single_module: bool,
    /// A self-referential pseudo chain is present (issue_2055) — routes to the
    /// single-pass batch fold rather than the registration fixpoint.
    pseudo_self_ref: bool,
    /// How many units of the shared work budget `expand_extensions` consumes
    /// while deriving the closure. The old per-rule path reset the budget then
    /// ran `expand_extensions`, so each rule's fold saw `BUDGET − this`; with
    /// the plan computed once, we replay this deduction per rule to keep the
    /// budget state — and therefore the output — byte-identical.
    expand_budget_cost: usize,
}

impl ExtendPlan {
    /// True when no extensions are visible in this scope (the caller's fast
    /// path: a rule with no `@extend` and no placeholder is untouched).
    pub(crate) fn is_empty(&self) -> bool {
        self.n_extensions == 0
    }
}

/// Build the scope-fixed [`ExtendPlan`] for one module `scope` and its fixed
/// `extensions` list. Call ONCE per scope; reuse across every rule.
pub(crate) fn build_extend_plan(
    extensions: &[Extension],
    scope: &str,
    origin_rank: std::collections::HashMap<String, usize>,
    legacy_order: bool,
) -> ExtendPlan {
    let source_spec = source_specificity_map(extensions);
    // Run the closure derivation under a fresh budget and record exactly how
    // much it consumed, so the per-rule path can replay the same deduction.
    reset_extend_budget();
    let budget_before = EXTEND_WORK.with(|w| w.get());
    let (raw_batches, registry, raw_marks) = expand_extensions(extensions);
    // dart applies a DOWNSTREAM module's whole store in ONE extendList
    // (`addExtensions` accumulates every store's extensions and makes a
    // single `_extendExistingSelectors` call), so same-target extenders from
    // one foreign module land in registration order (bulma's
    // `.fixed-grid`/`.grid` from grid.scss). Merge consecutive same-origin
    // FOREIGN batches into one multi-extension batch; own-scope batches stay
    // per-`@extend` (dart's incremental addExtension). A merged batch keeps
    // its FIRST member's registration index and its LAST member's registry
    // mark, so the pre-rule split and registry segments stay consistent.
    let mut batches: Vec<Vec<Extension>> = Vec::new();
    let mut batch_registry_marks: Vec<usize> = Vec::new();
    let mut batch_reg_idx: Vec<usize> = Vec::new();
    let mut batch_origin: Vec<String> = Vec::new();
    let mut last_origin: Option<&str> = None;
    for (i, batch) in raw_batches.into_iter().enumerate() {
        let origin = extensions[i].origin.as_str();
        if origin != scope && last_origin == Some(origin) {
            let last = batches.last_mut().expect("non-empty on merge");
            last.extend(batch);
            *batch_registry_marks.last_mut().expect("mark") = raw_marks[i];
        } else {
            batches.push(batch);
            batch_registry_marks.push(raw_marks[i]);
            batch_reg_idx.push(extensions[i].reg_idx);
            batch_origin.push(extensions[i].origin.clone());
            last_origin = Some(origin);
        }
    }
    let budget_after = EXTEND_WORK.with(|w| w.get());
    let expand_budget_cost = budget_before.saturating_sub(budget_after);
    let single_module = extensions.iter().all(|e| e.origin == scope);
    let targets: FxHashSet<Simple> = extensions.iter().filter_map(|e| e.target.clone()).collect();
    let pseudo_self_ref = single_module
        && registry.iter().any(|e| {
            e.extenders
                .iter()
                .any(|c| pseudo_arg_has_target(c, &targets, false))
        });
    ExtendPlan {
        batches,
        registry,
        batch_registry_marks,
        batch_reg_idx,
        batch_origin,
        origin_rank,
        legacy_order,
        source_spec,
        n_extensions: extensions.len(),
        single_module,
        pseudo_self_ref,
        expand_budget_cost,
    }
}

/// Apply `extensions` to the parsed selector list `original`, returning the
/// extended selector list (original selectors first, then generated ones, in
/// dart-sass order). Placeholder-only complex selectors are dropped from the
/// output.
pub(crate) fn extend_selectors(
    original: &[Complex],
    original_breaks: &[bool],
    plan: &ExtendPlan,
    scope: &str,
    extend_base: usize,
) -> ExtendResult {
    // Reset the shared work budget for this rule, then replay the deduction the
    // closure derivation would have taken if it ran here (it now ran ONCE in
    // `build_extend_plan`). This keeps the budget state — and therefore the
    // fold's truncation behaviour and output — byte-identical to the old
    // per-rule path that called `expand_extensions` after `reset_extend_budget`.
    reset_extend_budget();
    EXTEND_WORK.with(|w| w.set(w.get().saturating_sub(plan.expand_budget_cost)));
    let batches = &plan.batches;
    let registry = &plan.registry;
    let source_spec = &plan.source_spec;
    // The set of "original" rendered selectors — the unextended input. Original
    // selectors are never trimmed (dart-sass keeps them so the rule still
    // matches what it always matched). Start from the scope-wide store originals
    // (dart `_originals` — every extender written in this module, protected from
    // a broader generated one trimming it) and add the rule's own selectors.
    // dart's `_originals` is an IDENTITY set: original status travels with
    // the INSTANCE, not the value. The pipeline threads a per-entry flag
    // instead (seeded true for the rule's own selectors; the first product of
    // each original round-trip inherits it), so a product VALUE-equal to an
    // original is still coverage-trimmed in the original's favor.
    for complex in original {
        assert_render_injective(complex);
    }

    // dart `addSelector` ONE-SHOT vs `_extendExistingSelectors` INCREMENTAL.
    // When a rule's selector was established AFTER every applicable `@extend`
    // (`extend_base >= extensions.len()`), dart extends it by the whole store at
    // ONCE — `_extendComplex`'s `paths` unification order (LAST choice slowest)
    // and the `:not`/`:is` merge applied simultaneously. When it was established
    // before/among its `@extend`s, dart re-extends it incrementally in
    // registration order (the opposite cartesian order, and each `:not` inserted
    // right after the target so later extends sort first). The one-shot path
    // runs the worklist over the full `registry` (transitive closure incl.
    // dart#1297 derived extensions) with the `paths`-order cartesian; the
    // incremental path is the registration-order FOLD (per-origin gating intact).
    // Gated to single-module: there the closure-size sort is stable so the index
    // equals registration order; multi-module keeps the fold. `extend_base`
    // is the GLOBAL registration counter, so "after every applicable
    // @extend" must compare against the visible extensions' own global
    // indices — not their count (a late-loaded module's rule has a large
    // base while its scope sees only a couple of extensions; bulma's
    // `.input`/`.textarea` register AFTER their placeholder rule and must
    // fold incrementally).
    let single_module = plan.single_module;
    let order = if single_module
        && extend_base != usize::MAX
        && plan.batch_reg_idx.iter().all(|&r| r < extend_base)
    {
        CartesianOrder::OneShot
    } else {
        CartesianOrder::Fold
    };
    // A SELF-REFERENTIAL pseudo chain (issue_2055) — precomputed in the plan.
    let pseudo_self_ref = plan.pseudo_self_ref;
    let result: Vec<(Complex, bool)> = if pseudo_self_ref && order == CartesianOrder::Fold {
        // A self-referential pseudo chain (`:not(.thing[disabled])` extending
        // `.thing`, issue_2055). dart applies each `@extend`'s
        // `newExtensionsByTarget` (its single extension PLUS the
        // `additionalExtensions` derived by `_extendExistingExtensions`) to the
        // selector list EXACTLY ONCE, in registration order — the nesting depth
        // comes from `_extendPseudo` recursing into `_extendList`, NOT from
        // re-applying the whole store. Re-applying the registry as a worklist
        // over-generates (the full set cross-products every `.thing` against
        // every derived extender), and re-folding the batches to a fixpoint
        // blows up combinatorially. So: fold the batches once each, faithful to
        // dart's single registration-order pass.
        let mut current: Vec<(Complex, bool, bool, String)> = original
            .iter()
            .enumerate()
            .map(|(i, c)| {
                (
                    c.clone(),
                    original_breaks.get(i).copied().unwrap_or(false),
                    true,
                    scope.to_string(),
                )
            })
            .collect();
        // OPT 1 (single registration-order pass): skip a batch none of whose
        // targets the running list can match — a no-op, budget-neutral batch.
        let mut current_simples: FxHashSet<Simple> = FxHashSet::default();
        for (c, _, _, _) in &current {
            collect_match_simples(c, &mut current_simples);
        }
        for batch in batches.iter() {
            let mut any = false;
            for e in batch.iter() {
                if let Some(t) = &e.target {
                    if current_simples.contains(t) {
                        any = true;
                        break;
                    }
                }
            }
            if !any {
                continue;
            }
            current = extend_list_batch(&current, batch, Some(scope), source_spec);
            for (c, _, _, _) in &current {
                collect_match_simples(c, &mut current_simples);
            }
        }
        current.into_iter().map(|(c, f, _, _)| (c, f)).collect()
    } else if order == CartesianOrder::OneShot {
        let all_orig: Vec<bool> = vec![true; original.len()];
        let (result, changed) =
            extend_to_fixpoint_breaks(original, original_breaks, &all_orig, Some(scope), registry, order);
        if changed {
            trim_breaks(result, source_spec)
                .into_iter()
                .map(|(c, f, _)| (c, f))
                .collect()
        } else {
            original
                .iter()
                .enumerate()
                .map(|(i, c)| (c.clone(), original_breaks.get(i).copied().unwrap_or(false)))
                .collect()
        }
    } else {
        // Faithful dart registration-order: apply the batch sequence (one
        // `@extend` worth of new extensions per batch) to a FIXPOINT. One pass
        // establishes dart's order; later passes pick up transitive products a
        // single pass can't reach (extend cycles `.foo→.bar→.baz→.foo`). Each
        // selector carries the module origin that owns it, and a batch only
        // extends a selector it can SEE (per-module gating blocks cross-sibling
        // diamond leaks). New products append after the established order and
        // `trim` drops any a kept selector covers, so order is preserved and
        // spurious blow-ups are pruned; the shared work budget bounds growth.
        // dart `addSelector`: extensions registered BEFORE this rule was
        // created apply as ONE `extendList` over the store-so-far (their
        // products in extension-registration order — govuk's
        // `.govuk-body-l, .govuk-body-lead` aliases); only LATER
        // registrations re-extend the rule incrementally. Gated to a single
        // module, where `extend_base` indexes the registration sequence.
        // The batch list is ordered downstream-first (not registration
        // order), so the pre-rule set is NOT a prefix: collect the batches
        // whose registration index precedes the rule, in registration order,
        // and splice their registry segments for the one-shot store.
        // Foreign (downstream-module) stores never fold incrementally: dart
        // merges every downstream store transitively and applies the result
        // in ONE `extendList` per upstream module at combine time. Entry
        // order mirrors the merged map: each origin at its rank in the
        // scope's store-merge flatten (plan.origin_rank), raw extenders
        // before that origin's DERIVED entries, registration order within.
        // A derived entry created AT this scope is excluded (it exists for
        // strictly-upstream merges; the chain resolves here through the
        // already-extended selector list instead).
        let foreign: Vec<usize> = if plan.legacy_order {
            Vec::new()
        } else {
            (0..batches.len())
                .filter(|&i| plan.batch_origin.get(i).is_some_and(|o| o != scope))
                .collect()
        };
        let pre_batches: Vec<usize> = if extend_base != usize::MAX && extend_base > 0 {
            let mut v: Vec<usize> = (0..batches.len())
                .filter(|&i| {
                    (plan.legacy_order || plan.batch_origin.get(i).is_some_and(|o| o == scope))
                        && plan.batch_reg_idx.get(i).copied().unwrap_or(usize::MAX) < extend_base
                })
                .collect();
            v.sort_by_key(|&i| plan.batch_reg_idx[i]);
            v
        } else {
            Vec::new()
        };
        let mut pre_set: FxHashSet<usize> = pre_batches.iter().copied().collect();
        pre_set.extend(foreign.iter().copied());
        let seed: Vec<(Complex, bool, bool)> = if !pre_batches.is_empty() {
            // The one-shot store is the concatenation of these batches' registry
            // slices. `pre_batches` is sorted by registry position, so those
            // slices are usually adjacent, and then the concatenation *is* a
            // subslice of `registry` -- borrow it rather than cloning every
            // `Extension` in it. Cloning unconditionally is a copy of the whole
            // registry prefix per extending rule, which is where an
            // `@extend`-heavy sheet's allocation went.
            let batch_range = |i: usize| {
                let start = if i == 0 {
                    0
                } else {
                    plan.batch_registry_marks[i - 1]
                };
                start..plan.batch_registry_marks[i]
            };
            let mut lo = 0usize;
            let mut hi = 0usize;
            let mut contiguous = true;
            for (k, &i) in pre_batches.iter().enumerate() {
                let range = batch_range(i);
                if k == 0 {
                    lo = range.start;
                } else if range.start != hi {
                    // A gap, or out of order: the union is not itself a slice.
                    contiguous = false;
                    break;
                }
                hi = range.end;
            }
            let one_shot_store: std::borrow::Cow<'_, [Extension]> = if contiguous {
                std::borrow::Cow::Borrowed(&registry[lo..hi])
            } else {
                std::borrow::Cow::Owned(
                    pre_batches
                        .iter()
                        .flat_map(|&i| registry[batch_range(i)].iter().cloned())
                        .collect(),
                )
            };
            let all_orig: Vec<bool> = vec![true; original.len()];
            let (res, changed) = extend_to_fixpoint_breaks(
                original,
                original_breaks,
                &all_orig,
                Some(scope),
                &one_shot_store,
                CartesianOrder::OneShot,
            );
            if changed {
                trim_breaks(res, source_spec)
            } else {
                original
                    .iter()
                    .enumerate()
                    .map(|(i, c)| (c.clone(), original_breaks.get(i).copied().unwrap_or(false), true))
                    .collect()
            }
        } else {
            original
                .iter()
                .enumerate()
                .map(|(i, c)| (c.clone(), original_breaks.get(i).copied().unwrap_or(false), true))
                .collect()
        };
        let mut current: Vec<(Complex, bool, bool, String)> = seed
            .into_iter()
            .map(|(c, f, o)| (c, f, o, scope.to_string()))
            .collect();
        // OPT 1: the set `S` of simples the running list can match against —
        // exactly those `s` for which some complex `complex_may_match_targets`
        // `{s}`. A batch ALL of whose targets are absent from `S` changes
        // nothing AND consumes zero budget (the `can_match` gate fires before
        // `consume_extend_work`), so it can be skipped entirely — byte-exact.
        // Maintained INCREMENTALLY: only an applied batch mutates `current`, so
        // its products' simples are unioned in; skipped batches leave `S` alone.
        let mut current_simples: FxHashSet<Simple> = FxHashSet::default();
        for (c, _, _, _) in &current {
            collect_match_simples(c, &mut current_simples);
        }
        // dart's incremental path is ONE `_extendList` per registration —
        // never a fixpoint. Chains across registrations are precomputed as
        // DERIVED extensions (including the live-list self-derivation above),
        // so re-running the batches would only conjure products dart never
        // emits (tabler: `body[data-bs-theme=dark] [data-bs-theme=light]`
        // chained through its sibling extender of the SAME rule).
        {
            for (bi, batch) in batches.iter().enumerate() {
                if pre_set.contains(&bi) {
                    continue;
                }
                // Skip a batch none of whose targets the running list can match.
                let mut any = false;
                for e in batch.iter() {
                    if let Some(t) = &e.target {
                        if current_simples.contains(t) {
                            any = true;
                            break;
                        }
                    }
                }
                if !any {
                    continue;
                }
                let next = extend_list_batch(&current, batch, Some(scope), source_spec);
                // Union the (possibly new) products' simples into `S`. Only an
                // applied batch reaches here; recomputing from scratch per batch
                // would defeat the win, so fold incrementally.
                for (c, _, _, _) in &next {
                    collect_match_simples(c, &mut current_simples);
                }
                current = next;
            }
        }
        // Satisfaction snapshot (dart's `originalSelectors`): a foreign
        // extension counts as matched only against selectors present BEFORE
        // this merge — a product added by a SIBLING store in the same merge
        // must not satisfy it (use/error/extend scope/diamond).
        let pre_foreign_snapshot: Vec<Complex> = if foreign.is_empty() {
            Vec::new()
        } else {
            current.iter().map(|(c, _, _, _)| c.clone()).collect()
        };
        if !foreign.is_empty() {
            let mut foreign_entries: Vec<&Extension> =
                registry.iter().filter(|e| e.origin != scope).collect();
            foreign_entries.sort_by(|a, b| {
                let rank = |e: &Extension| plan.origin_rank.get(&e.origin).copied().unwrap_or(usize::MAX);
                // Within a home store, derived entries follow the absorption
                // order of their TRIGGERING store (the via origin's rank),
                // not registration order.
                let via_rank = |e: &Extension| {
                    e.via_origin
                        .as_ref()
                        .and_then(|o| plan.origin_rank.get(o).copied())
                        .unwrap_or(usize::MAX)
                };
                rank(a)
                    .cmp(&rank(b))
                    .then(a.derived.cmp(&b.derived))
                    .then(via_rank(a).cmp(&via_rank(b)))
                    .then(a.reg_idx.cmp(&b.reg_idx))
            });
            let foreign_store: Vec<Extension> = foreign_entries.into_iter().cloned().collect();
            let complexes: Vec<Complex> = current.iter().map(|(c, _, _, _)| c.clone()).collect();
            let breaks: Vec<bool> = current.iter().map(|(_, f, _, _)| *f).collect();
            let origs: Vec<bool> = current.iter().map(|(_, _, o, _)| *o).collect();
            let (res, changed) = extend_to_fixpoint_breaks(
                &complexes,
                &breaks,
                &origs,
                Some(scope),
                &foreign_store,
                CartesianOrder::OneShot,
            );
            if changed {
                current = trim_breaks(res, source_spec)
                    .into_iter()
                    .map(|(c, f, o)| (c, f, o, scope.to_string()))
                    .collect();
            }
        }
        // Mandatory-extend accounting for batches the fold never runs (the
        // pre-rule one-shot and the foreign one-shot use registry segments,
        // so a target-only MARKER — or an extension merged into an earlier
        // identical registration — never reaches collect_extenders): flip
        // its matched cell whenever the target appears in this rule's list
        // (dart tracks "found" via _selectors[target], independent of
        // application).
        for (&i, snapshot) in pre_batches
            .iter()
            .map(|i| (i, original))
            .chain(foreign.iter().map(|i| (i, pre_foreign_snapshot.as_slice())))
        {
            for e in &batches[i] {
                if e.matched.get() {
                    continue;
                }
                if let Some(t) = &e.target {
                    if list_contains_simple(snapshot, t) {
                        e.matched.set(true);
                    }
                }
            }
        }
        current.into_iter().map(|(c, f, _, _)| (c, f)).collect()
    };

    // Simplify placeholders inside `:is()/:where()/:not()`-style pseudo
    // arguments, dropping selectors whose pseudo can never match.
    let mut simplified: Vec<(Complex, bool)> = Vec::new();
    for (c, f) in result {
        if let Some(c) = simplify_pseudo_placeholders(&c) {
            simplified.push((c, f));
        }
    }

    // Drop complex selectors that still contain a (top-level) placeholder.
    // Each product's line-break flag traveled through the pipeline (dart's
    // `complex.lineBreak || path.any((c) => c.lineBreak)`).
    let all_placeholders = simplified.iter().all(|(c, _)| c.has_placeholder());
    let mut selectors: Vec<Complex> = Vec::new();
    let mut breaks: Vec<bool> = Vec::new();
    for (c, f) in simplified {
        if !c.has_placeholder() {
            selectors.push(c);
            breaks.push(f);
        }
    }
    ExtendResult {
        selectors,
        breaks,
        all_placeholders,
    }
}

/// Simplify placeholder selectors inside pseudo-class arguments
/// (`:is()`/`:where()`/`:matches()`/`:not()` etc.): remove placeholder complex
/// selectors from the argument list. For "matches-any" pseudos an empty
/// argument means the whole compound matches nothing (return `None` to drop the
/// selector); for `:not()` an empty argument means the pseudo excludes nothing
/// and is removed (a now-empty compound becomes `*`). Returns the rewritten
/// complex selector, or `None` if it can never match.
fn simplify_pseudo_placeholders(complex: &Complex) -> Option<Complex> {
    let mut components = Vec::new();
    for comp in &complex.components {
        let mut simples: Vec<Simple> = Vec::new();
        for s in &comp.compound.simples {
            match s {
                Simple::Pseudo(text) if text.contains('%') => {
                    match simplify_one_pseudo(text) {
                        PseudoResult::Keep(new) => simples.push(Simple::Pseudo(new)),
                        PseudoResult::Remove => { /* `:not()` with empty arg */ }
                        PseudoResult::NeverMatches => return None,
                    }
                }
                other => simples.push(other.clone()),
            }
        }
        // A compound emptied by removing a `:not()` becomes the universal `*`.
        if simples.is_empty() {
            simples.push(Simple::Universal { ns: None });
        }
        components.push(ComplexComponent {
            combinators: comp.combinators.clone(),
            compound: Compound { simples },
        });
    }
    Some(Complex {
        components,
        trailing: Vec::new(),
    })
}

enum PseudoResult {
    /// Keep the pseudo, rewritten to this text.
    Keep(String),
    /// Remove the pseudo entirely (e.g. `:not()` with no remaining args).
    Remove,
    /// The pseudo can never match — drop the whole selector.
    NeverMatches,
}

/// Simplify a single pseudo selector text whose argument contains a
/// `%placeholder`. Only `:is/:where/:matches/:any/:-*-any/:not` take a selector
/// argument we process; others are kept verbatim.
fn simplify_one_pseudo(text: &str) -> PseudoResult {
    // Split into `:name(` ... `)`.
    let Some(open) = text.find('(') else {
        return PseudoResult::Keep(text.to_string());
    };
    if !text.ends_with(')') {
        return PseudoResult::Keep(text.to_string());
    }
    let head = &text[..open]; // e.g. `:not`
    let arg = &text[open + 1..text.len() - 1];
    let name = head.trim_start_matches(':').to_ascii_lowercase();
    // `:has()` joins the matches-any set: dart's serializer drops invisible
    // (placeholder) complexes from EVERY pseudo's argument list, and a
    // fully-invisible argument makes the pseudo — and its compound — never
    // match (issue_1797 `div:has(%not)` extends to `div:has(.not)`).
    let is_matchish =
        matches!(unvendor(&name), "is" | "where" | "matches" | "any" | "has") || name.ends_with("-any");
    let is_not = unvendor(&name) == "not";
    if !is_matchish && !is_not {
        return PseudoResult::Keep(text.to_string());
    }
    // Parse the argument selector list and drop placeholder-bearing complexes.
    let Some(list) = parse_list(arg) else {
        return PseudoResult::Keep(text.to_string());
    };
    let kept: Vec<&Complex> = list.iter().filter(|c| !c.has_placeholder()).collect();
    if kept.is_empty() {
        return if is_not {
            PseudoResult::Remove
        } else {
            PseudoResult::NeverMatches
        };
    }
    let inner = kept.iter().map(|c| c.render()).collect::<Vec<_>>().join(", ");
    PseudoResult::Keep(format!("{head}({inner})"))
}

/// `_trim`'s "originals are never trimmed" membership WITHOUT cloning the
/// Remove complex selectors that are subselectors of another in the list,
/// preserving original selectors. Mirrors dart-sass `ExtensionStore._trim`:
/// iterate last-to-first, dropping a selector when an already-kept (or
/// later-in-input) selector is its superselector. Originals are always kept.
/// [`trim_breaks`] over bare complexes tagged with per-entry ORIGINAL flags.
fn trim(selectors: Vec<(Complex, bool)>, source_spec: &FxHashMap<Simple, u64>) -> Vec<Complex> {
    trim_breaks(
        selectors.into_iter().map(|(c, o)| (c, false, o)).collect(),
        source_spec,
    )
    .into_iter()
    .map(|(c, _, _)| c)
    .collect()
}

/// Like [`trim`], preserving each selector's line-break flag. Entries carry
/// (complex, line-break, is-original-INSTANCE): dart's `_originals` is a
/// `Set.identity()`, so an extension product that is VALUE-equal to one of
/// the rule's original selectors is NOT an original — it falls through to
/// the superselector coverage check, is covered by the original instance,
/// and drops, leaving the original at its own position with its own
/// line-break flag (tabler `.btn-sm,\n.btn-group-sm > .btn`).
fn trim_breaks(
    selectors: Vec<(Complex, bool, bool)>,
    source_spec: &FxHashMap<Simple, u64>,
) -> Vec<(Complex, bool, bool)> {
    // Quadratic; dart-sass bails above 100 to avoid pathological cost.
    if selectors.len() > 100 {
        return selectors;
    }
    // dart `_sourceSpecificityFor`: a compound's source specificity is the
    // max recorded for any of its simples (0 when none was an extender).
    let source_spec_for = |c: &Complex| -> u64 {
        c.components
            .iter()
            .map(|comp| {
                comp.compound
                    .simples
                    .iter()
                    .map(|s| source_spec.get(s).copied().unwrap_or(0))
                    .max()
                    .unwrap_or(0)
            })
            .max()
            .unwrap_or(0)
    };
    let mut result: Vec<(Complex, bool, bool)> = Vec::new();
    let mut num_originals = 0usize;
    let n = selectors.len();
    'outer: for i in (0..n).rev() {
        let (c1, f1, o1) = &selectors[i];
        if *o1 {
            // A duplicate original rotates to the front (dart `rotateSlice`),
            // preserving the EARLIEST source position's precedence.
            for j in 0..num_originals {
                if result[j].0 == *c1 {
                    let c = result.remove(j);
                    result.insert(0, c);
                    continue 'outer;
                }
            }
            num_originals += 1;
            result.insert(0, (c1.clone(), *f1, true));
            continue;
        }
        // Drop c1 only when a superselector ALSO has at least the max source
        // specificity of c1's extenders (dart `_trim`): `.test-case` (1000)
        // may not trim `.test-case:active` whose source weighs 2000.
        let max_spec = source_spec_for(c1);
        let covers = |c2: &Complex| complex_specificity(c2) >= max_spec && complex_is_superselector(c2, c1);
        if result.iter().any(|(c2, _, _)| covers(c2)) || selectors[..i].iter().any(|(c2, _, _)| covers(c2)) {
            continue;
        }
        result.insert(0, (c1.clone(), *f1, false));
    }
    result
}

// ---- superselector checks ---------------------------------------------

/// Whether `c1` is a superselector of `c2` (matches every element `c2` does).
/// dart-sass `ComplexSelector.isSuperselector`: selectors with leading
/// combinators are neither super- nor subselectors; trailing runs are handled
/// inside [`complex_is_superselector_trailing`].
fn complex_is_superselector(c1: &Complex, c2: &Complex) -> bool {
    let d1 = to_dart(c1);
    let d2 = to_dart(c2);
    d1.leading.is_empty() && d2.leading.is_empty() && complex_is_superselector_trailing(&d1.comps, &d2.comps)
}

/// dart-sass `complexIsSuperselector` over trailing-combinator component lists.
fn complex_is_superselector_trailing(complex1: &[TComp], complex2: &[TComp]) -> bool {
    // Selectors with trailing operators are neither super- nor subselectors.
    if complex1.last().map(|c| !c.combinators.is_empty()).unwrap_or(true) {
        return false;
    }
    if complex2.last().map(|c| !c.combinators.is_empty()).unwrap_or(true) {
        return false;
    }

    let mut i1 = 0usize;
    let mut i2 = 0usize;
    let mut previous_combinator: Option<Combinator> = None;
    loop {
        let remaining1 = complex1.len() - i1;
        let remaining2 = complex2.len() - i2;
        if remaining1 == 0 || remaining2 == 0 {
            return false;
        }
        if remaining1 > remaining2 {
            return false;
        }
        let component1 = &complex1[i1];
        if component1.combinators.len() > 1 {
            return false;
        }
        if remaining1 == 1 {
            let parents = &complex2[i2..complex2.len() - 1];
            if parents.iter().any(|p| p.combinators.len() > 1) {
                return false;
            }
            let Some(last2) = complex2.last() else {
                return false;
            };
            return compound_is_superselector(&component1.compound, &last2.compound, parents);
        }

        // Find the first index `end` in complex2 whose compound is a subselector
        // of component1's compound.
        let mut end = i2;
        loop {
            let component2 = &complex2[end];
            if component2.combinators.len() > 1 {
                return false;
            }
            if compound_is_superselector(&component1.compound, &component2.compound, &[]) {
                break;
            }
            end += 1;
            if end == complex2.len() - 1 {
                return false;
            }
        }

        // Intervening components (between i2 and end) must be compatible with the
        // previous combinator.
        if !compatible_with_previous_combinator(previous_combinator, &complex2[i2..end]) {
            return false;
        }

        let component2 = &complex2[end];
        let combinator1 = component1.combinators.first().copied();
        let combinator2 = component2.combinators.first().copied();
        if !is_supercombinator(combinator1, combinator2) {
            return false;
        }

        i1 += 1;
        i2 = end + 1;
        previous_combinator = combinator1;

        if complex1.len() - i1 == 1 {
            match combinator1 {
                Some(Combinator::FollowingSibling) => {
                    // `.foo ~ .bar` only supersedes selectors whose intervening
                    // combinators are all subcombinators of `~`.
                    let upto = complex2.len() - 1;
                    if !complex2[i2..upto]
                        .iter()
                        .all(|c| is_supercombinator(combinator1, c.combinators.first().copied()))
                    {
                        return false;
                    }
                }
                Some(_) if complex2.len() - i2 > 1 => return false,
                _ => {}
            }
        }
    }
}

fn compatible_with_previous_combinator(previous: Option<Combinator>, parents: &[TComp]) -> bool {
    if parents.is_empty() {
        return true;
    }
    let Some(prev) = previous else {
        return true;
    };
    // The child and next-sibling combinators require the *immediate* following
    // component be a superselector.
    if prev != Combinator::FollowingSibling {
        return false;
    }
    // The following-sibling combinator allows intermediate components, but only
    // if they're all siblings.
    parents.iter().all(|c| {
        matches!(
            c.combinators.first().copied(),
            Some(Combinator::FollowingSibling) | Some(Combinator::NextSibling)
        )
    })
}

/// Whether `combinator1` is a supercombinator of `combinator2`.
fn is_supercombinator(c1: Option<Combinator>, c2: Option<Combinator>) -> bool {
    c1 == c2
        || (c1.is_none() && c2 == Some(Combinator::Child))
        || (c1 == Some(Combinator::FollowingSibling) && c2 == Some(Combinator::NextSibling))
}

/// Parse a selector pseudo `:name(<selectors>)` of the `:is`/`:matches`/`:any`/
/// `:where`/`:-*-any`/`:has`/`:host`/`:host-context` family into its normalized
/// name and argument selector list. `None` for any other (or non-selector) pseudo.
/// Canonicalize the selector argument of a `:not`/`:is`/`:where`/`:matches`/
/// `:any`/`:has` pseudo by re-parsing and re-rendering it (recursively
/// normalizing nested attributes and pseudos). `None` leaves it verbatim.
pub(crate) fn normalize_pseudo_arg(text: &str) -> Option<String> {
    let open = text.find('(')?;
    if !text.ends_with(')') {
        return None;
    }
    let head = &text[..open];
    let name_l = head.trim_start_matches(':').to_ascii_lowercase();
    let known = matches!(
        unvendor(&name_l),
        "not" | "is" | "where" | "matches" | "any" | "has"
    ) || name_l.ends_with("-any");
    if !known {
        return None;
    }
    let raw = &text[open + 1..text.len() - 1];
    let list = parse_list(raw)?;
    // Keep the source's per-arg line structure: an arg that began on its own
    // line (dart: the arg complex's lineBreak) re-joins with ",\n" — the
    // serializer honors line breaks inside pseudo args too (quasar's
    // `:is(:-webkit-autofill,\n[type=color], …)`).
    let mut part_breaks: Vec<bool> = Vec::new();
    {
        let mut paren = 0i32;
        let mut bracket = 0i32;
        let mut leading = true;
        let mut brk = false;
        for ch in raw.chars() {
            match ch {
                '(' => paren += 1,
                ')' => paren -= 1,
                '[' => bracket += 1,
                ']' => bracket -= 1,
                ',' if paren == 0 && bracket == 0 => {
                    part_breaks.push(brk);
                    leading = true;
                    brk = false;
                    continue;
                }
                _ => {}
            }
            if leading {
                if ch == '\n' {
                    brk = true;
                } else if !ch.is_whitespace() {
                    leading = false;
                }
            }
        }
        part_breaks.push(brk);
    }
    let mut inner = String::new();
    for (i, c) in list.iter().enumerate() {
        if i > 0 {
            inner.push(',');
            inner.push(if part_breaks.get(i).copied().unwrap_or(false) {
                '\n'
            } else {
                ' '
            });
        }
        inner.push_str(&c.render());
    }
    Some(format!("{head}({inner})"))
}

fn parse_selector_pseudo(text: &str) -> Option<(String, Vec<Complex>)> {
    let open = text.find('(')?;
    if !text.ends_with(')') {
        return None;
    }
    let name = text[..open].trim_start_matches(':').to_ascii_lowercase();
    let known = matches!(
        unvendor(&name),
        "is" | "where" | "matches" | "any" | "has" | "host" | "host-context"
    ) || name.ends_with("-any");
    if !known {
        return None;
    }
    let list = parse_list(&text[open + 1..text.len() - 1])?;
    Some((name, list))
}

/// dart-sass `_selectorPseudoIsSuperselector`. A selector pseudo on the super
/// side matches if `compound2` carries a same-name selector pseudo whose
/// argument our list supersedes, OR (for the `:is`/`:matches`/`:any`/`:where`/
/// `:-*-any` family) one of our argument complexes is a superselector of
/// `parents` followed by `compound2`. The relational `:has`/`:host`/
/// `:host-context` use only the same-name rule.
fn selector_pseudo_is_super(name: &str, branches: &[Complex], b: &Compound, parents: &[TComp]) -> bool {
    for s in &b.simples {
        if let Simple::Pseudo(t) = s {
            if let Some((n2, b_branches)) = parse_selector_pseudo(t) {
                // Our list must supersede EVERY branch of `b`'s same-name pseudo:
                // `:is(c)` is NOT a superselector of `:is(c, d)` (it can't match
                // the `d` branch), but `:is(c, d)` IS of `:is(c)`.
                if n2 == name
                    && !b_branches.is_empty()
                    && b_branches
                        .iter()
                        .all(|s2| list_is_superselector(branches, std::slice::from_ref(s2)))
                {
                    return true;
                }
            }
        }
    }
    let matchish = matches!(unvendor(name), "is" | "where" | "matches" | "any") || name.ends_with("-any");
    if !matchish {
        return false;
    }
    branches.iter().any(|branch| {
        // dart-sass: a branch with leading combinators is never a superselector.
        let bd = to_dart(branch);
        if !bd.leading.is_empty() {
            return false;
        }
        let mut target: Vec<TComp> = parents.to_vec();
        target.push(TComp {
            compound: b.clone(),
            combinators: Vec::new(),
        });
        complex_is_superselector_trailing(&bd.comps, &target)
    })
}

/// Parse a `:not(...)` (or vendor-prefixed `:-pfx-not(...)`) selector pseudo
/// into its (full) name and argument list.
fn parse_not_pseudo(text: &str) -> Option<(String, Vec<Complex>)> {
    let open = text.find('(')?;
    if !text.ends_with(')') {
        return None;
    }
    let name = text[..open].trim_start_matches(':').to_ascii_lowercase();
    if unvendor(&name) != "not" {
        return None;
    }
    let list = parse_list(&text[open + 1..text.len() - 1])?;
    Some((name, list))
}

/// dart-sass `:not(S1)` superselector rule (contravariant): `:not(S1)` is a
/// superselector of compound `b` iff every complex in `S1` is *excluded* by
/// some simple of `b` — a type/id with a different name (so `b` can never match
/// that complex), or a same-(full-)name `:not(S2)` whose `S2` supersedes the
/// complex.
fn not_pseudo_is_super(name: &str, branches: &[Complex], b: &Compound) -> bool {
    branches.iter().all(|complex1| {
        b.simples
            .iter()
            .any(|simple2| not_excludes(complex1, simple2, name))
    })
}

fn not_excludes(complex1: &Complex, simple2: &Simple, not_name: &str) -> bool {
    let last = complex1.components.last();
    let last_simples = || last.map(|c| c.compound.simples.as_slice()).unwrap_or(&[]);
    match simple2 {
        Simple::Type(t2) => {
            let n2 = type_local_name(t2);
            last_simples()
                .iter()
                .any(|s| matches!(s, Simple::Type(t1) if type_local_name(t1) != n2))
        }
        Simple::Id(id2) => last_simples()
            .iter()
            .any(|s| matches!(s, Simple::Id(id1) if id1 != id2)),
        Simple::Pseudo(t2) => match parse_not_pseudo(t2) {
            Some((n2, s2_branches)) => {
                n2 == not_name && list_is_superselector(&s2_branches, std::slice::from_ref(complex1))
            }
            None => false,
        },
        _ => false,
    }
}

/// The local (namespace-stripped) name of a type selector string.
fn type_local_name(t: &str) -> &str {
    t.rsplit('|').next().unwrap_or(t)
}

/// Whether compound `a` is a superselector of compound `b` (dart-sass
/// `compoundIsSuperselector`). A pseudo-element effectively changes the target
/// of a compound rather than narrowing it, so if either compound has a
/// pseudo-element they must both have the *same* one (with matching simples on
/// each side of it). `parents` are the components of `b`'s complex that precede
/// its final compound, used by the `:is`-family selector-pseudo rule.
fn compound_is_superselector(a: &Compound, b: &Compound, parents: &[TComp]) -> bool {
    match (find_pseudo_element(a), find_pseudo_element(b)) {
        (Some((pe1, i1)), Some((pe2, i2))) => {
            pseudo_element_is_superselector(pe1, pe2)
                && compound_components_is_superselector(&a.simples[..i1], &b.simples[..i2])
                && compound_components_is_superselector(&a.simples[i1 + 1..], &b.simples[i2 + 1..])
        }
        // Exactly one side has a pseudo-element: never a superselector.
        (Some(_), None) | (None, Some(_)) => false,
        (None, None) => a.simples.iter().all(|s1| {
            // A selector pseudo (`:is(...)` etc.) follows the dart-sass pseudo
            // rule; every other simple must match some simple of `b`.
            if let Simple::Pseudo(text) = s1 {
                if let Some((name, branches)) = parse_selector_pseudo(text) {
                    return selector_pseudo_is_super(&name, &branches, b, parents);
                }
                // `:not(S1)` uses its own contravariant superselector rule.
                if let Some((name, branches)) = parse_not_pseudo(text) {
                    return not_pseudo_is_super(&name, &branches, b);
                }
                // `:nth-child(An+B of S1)`/`:nth-last-child(...)` (possibly
                // vendor-prefixed) match a same-named pseudo in `b` with the
                // same An+B whose `of` list is a subselector (dart-sass
                // `_selectorPseudoIsSuperselector`).
                if let Some((head, anb, of_sel)) = nth_selector_parts(text) {
                    return nth_pseudo_is_super(head, anb, of_sel, b);
                }
            }
            b.simples.iter().any(|s2| simple_is_superselector(s1, s2))
        }),
    }
}

/// Whether pseudo-element `pe1` is a superselector of pseudo-element `pe2`
/// (dart-sass `PseudoSelector.isSuperselector`): they are equal, or both are a
/// same-named `::slotted(...)` whose selector arguments compare as lists.
fn pseudo_element_is_superselector(pe1: &Simple, pe2: &Simple) -> bool {
    if pe1 == pe2 {
        return true;
    }
    let (Simple::Pseudo(t1), Simple::Pseudo(t2)) = (pe1, pe2) else {
        return false;
    };
    let (Some(p1), Some(p2)) = (parse_pseudo_parts(t1), parse_pseudo_parts(t2)) else {
        return false;
    };
    if unvendor(&p1.name) != "slotted" || p1.head != p2.head {
        return false;
    }
    match (parse_list(&p1.arg), parse_list(&p2.arg)) {
        (Some(l1), Some(l2)) => list_is_superselector(&l1, &l2),
        _ => false,
    }
}

/// Parse a (possibly vendor-prefixed) `:nth-child`/`:nth-last-child` pseudo
/// with an `of <selector>` clause into `(head, anb, of_selector)`, where `head`
/// is the verbatim name including the colon.
fn nth_selector_parts(text: &str) -> Option<(&str, &str, &str)> {
    let open = text.find('(')?;
    if !text.ends_with(')') || text.starts_with("::") {
        return None;
    }
    let head = &text[..open];
    let name = head.trim_start_matches(':').to_ascii_lowercase();
    if !matches!(unvendor(&name), "nth-child" | "nth-last-child") {
        return None;
    }
    let arg = &text[open + 1..text.len() - 1];
    let pos = find_of_keyword(&arg.to_ascii_lowercase())?;
    Some((head, arg[..pos].trim(), arg[pos + 2..].trim()))
}

/// The selector branches of a subselector-pseudo *class* (dart-sass
/// `SimpleSelector._subselectorPseudos`): the argument list of
/// `:is`/`:matches`/`:any`/`:where`, or the `of` list of
/// `:nth-child`/`:nth-last-child`. Vendor prefixes are allowed.
fn subselector_pseudo_branches(text: &str) -> Option<Vec<Complex>> {
    if let Some((_, _, of_sel)) = nth_selector_parts(text) {
        return parse_list(of_sel);
    }
    let parts = parse_pseudo_parts(text)?;
    if parts.head.starts_with("::") {
        return None;
    }
    if !matches!(unvendor(&parts.name), "is" | "matches" | "any" | "where") {
        return None;
    }
    parse_list(&parts.arg)
}

/// dart-sass `_selectorPseudoIsSuperselector` for `nth-child`/`nth-last-child`:
/// some simple of `b` is a same-named pseudo with an identical An+B argument
/// whose `of` selector list is a subselector of `pseudo1`'s.
fn nth_pseudo_is_super(head1: &str, anb1: &str, of1: &str, b: &Compound) -> bool {
    let Some(list1) = parse_list(of1) else {
        return false;
    };
    b.simples.iter().any(|s2| {
        let Simple::Pseudo(t2) = s2 else {
            return false;
        };
        let Some((head2, anb2, of2)) = nth_selector_parts(t2) else {
            return false;
        };
        head2 == head1
            && anb2 == anb1
            && parse_list(of2).is_some_and(|list2| list_is_superselector(&list1, &list2))
    })
}

/// Like [`compound_is_superselector`] over raw simple-selector slices, treating
/// an empty `b` as the universal selector (dart-sass
/// `_compoundComponentsIsSuperselector`).
fn compound_components_is_superselector(a: &[Simple], b: &[Simple]) -> bool {
    if a.is_empty() {
        return true;
    }
    let universal = [Simple::Universal { ns: None }];
    let b = if b.is_empty() { &universal[..] } else { b };
    compound_is_superselector(
        &Compound { simples: a.to_vec() },
        &Compound { simples: b.to_vec() },
        &[],
    )
}

/// If `compound` contains a pseudo-element, return it and its index.
fn find_pseudo_element(compound: &Compound) -> Option<(&Simple, usize)> {
    compound
        .simples
        .iter()
        .enumerate()
        .find(|(_, s)| is_pseudo_element(s))
        .map(|(i, s)| (s, i))
}

/// Whether simple `a` is a superselector of simple `b`.
fn simple_is_superselector(a: &Simple, b: &Simple) -> bool {
    if a == b {
        return true;
    }
    // dart-sass `SimpleSelector.isSuperselector`: any simple is a superselector
    // of a subselector-pseudo (`:is`/`:matches`/`:any`/`:where` or
    // `:nth-child(... of S)`/`:nth-last-child(... of S)`) when every branch's
    // final compound contains a subselector of it.
    if let Simple::Pseudo(text) = b {
        if let Some(branches) = subselector_pseudo_branches(text) {
            return branches.iter().all(|complex| {
                to_dart(complex).comps.last().is_some_and(|last| {
                    last.compound
                        .simples
                        .iter()
                        .any(|s| simple_is_superselector(a, s))
                })
            });
        }
    }
    match a {
        // `*` (no namespace) matches everything.
        Simple::Universal { ns: None } => true,
        // `*|*` matches everything.
        Simple::Universal { ns: Some(n) } if n == "*" => true,
        // `ns|*` matches `ns|type` and `ns|*` (same namespace).
        Simple::Universal { ns: Some(n) } => match b {
            Simple::Type(t) => type_namespace(t).as_deref() == Some(n.as_str()),
            Simple::Universal { ns: Some(m) } => n == m,
            _ => false,
        },
        // A type selector `t` supersedes a matching type selector, honoring
        // a `*` namespace wildcard.
        Simple::Type(t) => match b {
            Simple::Type(u) => {
                let (n1, name1) = split_type(t);
                let (n2, name2) = split_type(u);
                name1 == name2 && (n1.as_deref() == Some("*") || n1 == n2)
            }
            _ => false,
        },
        _ => false,
    }
}

/// Split a (possibly namespaced) type name into `(namespace, local)`.
fn split_type(t: &str) -> (Option<String>, String) {
    match t.split_once('|') {
        Some((ns, name)) => (Some(ns.to_string()), name.to_string()),
        None => (None, t.to_string()),
    }
}

/// The namespace component of a type selector string, if any.
fn type_namespace(t: &str) -> Option<String> {
    t.split_once('|').map(|(ns, _)| ns.to_string())
}

/// Extend a single complex selector: compute, for each component, the list of
/// possible replacements (each a sequence of components), then take the
/// Cartesian product and weave them into complete complex selectors. The first
/// option of every component is the original, so the unextended selector comes
/// out first. (dart-sass `Extender._extendComplex`.)
fn extend_complex(complex: &Complex, extensions: &[Extension]) -> Vec<Complex> {
    let empty: FxHashSet<Complex> = FxHashSet::default();
    extend_complex_breaks(
        complex,
        false,
        true,
        None,
        extensions,
        &empty,
        CartesianOrder::Fold,
    )
    .into_iter()
    .map(|(c, _, _)| c)
    .collect()
}

/// Which cartesian-product ITERATION ORDER the `@extend` engine uses when
/// crossing per-component / per-simple option lists. dart-sass has two:
/// `OneShot` is the literal `paths(...)` order (the LAST component/simple
/// varies SLOWEST) used by the single-shot transitive-closure path; `Fold`
/// is the registration-order incremental fold (the FIRST component/simple
/// varies slowest). This only selects which nested loop is outer — it never
/// changes WHICH products are generated, only their byte order, which dart
/// pins exactly. See the call sites at `extend_complex_breaks` /
/// `extend_component` for the two loop forms.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum CartesianOrder {
    OneShot,
    Fold,
}

/// Like [`extend_complex`], but every product carries its line-break flag:
/// the input's flag OR any contributing extender's (dart's
/// `complex.lineBreak || path.any((c) => c.lineBreak)`).
fn extend_complex_breaks(
    complex: &Complex,
    in_break: bool,
    in_orig: bool,
    orig_scope: Option<&str>,
    extensions: &[Extension],
    ext_breaks: &FxHashSet<Complex>,
    order: CartesianOrder,
) -> Vec<(Complex, bool, bool)> {
    let d = to_dart(complex);
    // dart-sass: a complex selector with more than one leading combinator is
    // never extended (the caller keeps the original).
    if d.leading.len() > 1 {
        return vec![(complex.clone(), in_break, in_orig)];
    }

    // For each component, the complex selectors it can expand to (the original
    // first, followed by any extension replacements, transitively resolved).
    let mut per_component: Vec<Vec<(DComplex, bool)>> = Vec::new();
    let mut any_extended = false;
    for (i, comp) in d.comps.iter().enumerate() {
        match extend_component(comp, extensions, ext_breaks, order) {
            // dart-sass folds unextended leading components into a prefix
            // complex carrying the selector's leading run; keeping the run on
            // the first component's sole option is equivalent.
            None => per_component.push(vec![(
                DComplex {
                    leading: if i == 0 { d.leading.clone() } else { Vec::new() },
                    comps: vec![comp.clone()],
                },
                false,
            )]),
            Some(extended) => {
                any_extended = true;
                if i == 0 && !d.leading.is_empty() {
                    // dart-sass: a first-component extension must have no
                    // leading combinators (or the same ones); the complex's own
                    // leading run is then re-attached.
                    per_component.push(
                        extended
                            .into_iter()
                            .filter(|(n, _)| n.leading.is_empty() || n.leading == d.leading)
                            .map(|(n, f)| {
                                (
                                    DComplex {
                                        leading: d.leading.clone(),
                                        comps: n.comps,
                                    },
                                    f,
                                )
                            })
                            .collect(),
                    );
                } else {
                    per_component.push(extended);
                }
            }
        }
    }
    if !any_extended {
        return vec![(complex.clone(), in_break, in_orig)];
    }

    // Take the Cartesian product across components and `weave` each path into
    // one or more complete complex selectors (dart-sass `paths` + `weave`). The
    // iteration order sets which component varies fastest: dart's one-shot
    // `_extendComplex` uses literal `paths` (the LAST component varies SLOWEST,
    // its option the outer loop), while the incremental registration-order fold
    // varies the FIRST component slowest (its product interleaved per step). See
    // nested-compound-unification: rule-after-extends -> one_shot paths order.
    let mut combos: Vec<(Vec<DComplex>, bool)> = vec![(Vec::new(), false)];
    for opts in &per_component {
        let mut next: Vec<(Vec<DComplex>, bool)> = Vec::new();
        // The COMPONENT axis always uses dart's literal `paths` order (the
        // newest component's option is the outer loop, so the FIRST component
        // varies fastest): dart runs ONE `_extendComplex` per selector even on
        // the incremental fold path, and `paths` is the only order it has.
        // `CartesianOrder` still swaps the per-SIMPLE loops inside
        // `extend_component` (forem `.crayons-btn + .crayons-btn` both-ends
        // extension vs the `:not` insertion order).
        for (opt, oflag) in opts {
            for (combo, cflag) in &combos {
                let mut c = combo.clone();
                c.push(opt.clone());
                next.push((c, *cflag || *oflag));
            }
        }
        combos = next;
        if combos.len() > 100_000 {
            break;
        }
    }

    // dart's fast path (`options case [var extenders]` over a bare single
    // compound) returns the EXTENDER's own `ComplexSelector` object, and an
    // extender is a rule selector already living in the identity `_originals`
    // — so a full-compound replacement product carries original status. Any
    // weave/unification builds NEW objects and does not.
    let input_is_bare = d.leading.is_empty()
        && d.comps.len() == 1
        && d.comps[0].combinators.is_empty()
        && d.comps[0].compound.simples.len() == 1;
    // Identity-original status is PER STORE: `addExtensions` (the cross-
    // module merge) never adds a downstream store's originals, so a foreign
    // extender's bare product is NOT protected in this scope and a broader
    // sibling product replaces it (midstream_extend_within_pseudoselector),
    // while the same shape within one module keeps both (dart#1297).
    let bare_extenders: FxHashSet<&Complex> = match (input_is_bare, orig_scope) {
        (true, Some(scope)) => extensions
            .iter()
            .filter(|e| !e.derived && e.origin == scope)
            .flat_map(|e| e.extenders.iter())
            .collect(),
        _ => FxHashSet::default(),
    };
    let mut out: Vec<(Complex, bool, bool)> = Vec::new();
    let mut seen = FxHashSet::default();
    for (path, pflag) in combos {
        for woven in weave(&path) {
            let c = from_dart(&woven);
            let r = c.render();
            if seen.insert(r) {
                // dart marks the FIRST product of an original complex as an
                // original itself (`_originals.add(outputComplex)`) — it is
                // the reconstructed original, value-equal by construction.
                let orig = (in_orig && out.is_empty()) || (input_is_bare && bare_extenders.contains(&c));
                out.push((c, in_break || pflag, orig));
            }
        }
    }
    out
}

/// A complex selector in dart-sass's internal model: a leading combinator run
/// (e.g. `> .c`; more than one is invalid-but-preserved CSS) plus components
/// each carrying its *trailing* combinator run. The public [`Complex`] stores
/// the joining run on the *following* component instead; [`to_dart`]/
/// [`from_dart`] convert losslessly at the boundary. The weave/unify/extend
/// pipeline operates entirely on this model so combinator runs survive intact.
#[derive(Clone, PartialEq, Eq, Debug, Default)]
struct DComplex {
    leading: Vec<Combinator>,
    comps: Vec<TComp>,
}

impl DComplex {
    /// dart-sass `Selector.isUseless` (combinator part): a leading run or any
    /// component run of more than one combinator can never match anything.
    fn is_useless(&self) -> bool {
        self.leading.len() > 1 || self.comps.iter().any(|c| c.combinators.len() > 1)
    }

    /// dart-sass `ComplexSelector.withAdditionalCombinators`: append
    /// `combinators` to the final component's trailing run (or to the leading
    /// run when there are no components).
    fn with_additional_combinators(mut self, combinators: &[Combinator]) -> DComplex {
        if combinators.is_empty() {
            return self;
        }
        match self.comps.last_mut() {
            Some(last) => last.combinators.extend_from_slice(combinators),
            None => self.leading.extend_from_slice(combinators),
        }
        self
    }

    /// dart-sass `ComplexSelector.concatenate`: append `child`'s components,
    /// folding its leading run onto our final component's trailing run.
    fn concatenate(&self, child: &DComplex) -> DComplex {
        if child.leading.is_empty() {
            let mut comps = self.comps.clone();
            comps.extend(child.comps.iter().cloned());
            DComplex {
                leading: self.leading.clone(),
                comps,
            }
        } else if !self.comps.is_empty() {
            let mut comps = self.comps.clone();
            comps
                .last_mut()
                .expect("non-empty")
                .combinators
                .extend(child.leading.iter().copied());
            comps.extend(child.comps.iter().cloned());
            DComplex {
                leading: self.leading.clone(),
                comps,
            }
        } else {
            let mut leading = self.leading.clone();
            leading.extend(child.leading.iter().copied());
            DComplex {
                leading,
                comps: child.comps.clone(),
            }
        }
    }
}

/// Convert the public leading-combinator model into the dart model. The first
/// component's run becomes the complex's leading run; each later component's
/// run moves onto the previous component's trailing position; `trailing` lands
/// on the last component. A combinator-only selector (`>`) becomes a leading
/// run with no components. Lossless.
fn to_dart(c: &Complex) -> DComplex {
    let Some(first) = c.components.first() else {
        return DComplex {
            leading: c.trailing.clone(),
            comps: Vec::new(),
        };
    };
    let n = c.components.len();
    let comps = (0..n)
        .map(|i| TComp {
            compound: c.components[i].compound.clone(),
            combinators: if i + 1 < n {
                c.components[i + 1].combinators.clone()
            } else {
                c.trailing.clone()
            },
        })
        .collect();
    DComplex {
        leading: first.combinators.clone(),
        comps,
    }
}

/// Convert back from the dart model into the public model (inverse of
/// [`to_dart`]; lossless).
fn from_dart(d: &DComplex) -> Complex {
    if d.comps.is_empty() {
        return Complex {
            components: Vec::new(),
            trailing: d.leading.clone(),
        };
    }
    let components = d
        .comps
        .iter()
        .enumerate()
        .map(|(i, t)| ComplexComponent {
            combinators: if i == 0 {
                d.leading.clone()
            } else {
                d.comps[i - 1].combinators.clone()
            },
            compound: t.compound.clone(),
        })
        .collect();
    Complex {
        components,
        trailing: d.comps.last().expect("non-empty").combinators.clone(),
    }
}

/// dart-sass `weave`: expand "parenthesized selectors". Single-component path
/// elements are concatenated onto every prefix; multi-component ones have
/// their parent components interwoven with each prefix via [`weave_parents`].
fn weave(complexes: &[DComplex]) -> Vec<DComplex> {
    if complexes.len() <= 1 {
        return complexes.to_vec();
    }
    let mut prefixes: Vec<DComplex> = vec![complexes[0].clone()];
    for complex in &complexes[1..] {
        if complex.comps.len() == 1 {
            for prefix in prefixes.iter_mut() {
                *prefix = prefix.concatenate(complex);
            }
            continue;
        }
        let Some(last) = complex.comps.last() else {
            continue;
        };
        let mut next: Vec<DComplex> = Vec::new();
        for prefix in &prefixes {
            for parent_prefix in weave_parents(prefix, complex).unwrap_or_default() {
                let mut woven = parent_prefix;
                woven.comps.push(last.clone());
                next.push(woven);
            }
        }
        prefixes = next;
        if prefixes.len() > 100_000 {
            break;
        }
    }
    prefixes
}

/// dart-sass `_mergeLeadingCombinators`: a leading run compatible with both, or
/// `None` if they can't be unified (either run longer than one, or two
/// different single combinators).
fn merge_leading_combinators(a: &[Combinator], b: &[Combinator]) -> Option<Vec<Combinator>> {
    if a.len() > 1 || b.len() > 1 {
        return None;
    }
    if a.is_empty() {
        return Some(b.to_vec());
    }
    if b.is_empty() || a == b {
        return Some(a.to_vec());
    }
    None
}

/// A complex-selector component in the *trailing-combinator* representation
/// dart-sass uses for weaving: a compound followed by zero or more combinators
/// that join it to the *next* component. (The current public model attaches a
/// single combinator to the *following* compound; we convert at the boundary.)
#[derive(Clone, PartialEq, Eq, Debug)]
struct TComp {
    compound: Compound,
    combinators: Vec<Combinator>,
}

/// Interweave `prefix`'s components with `base`'s components *other than the
/// last*, returning all order-preserving interleavings (with unification of
/// equal/superselector groups and leading/trailing combinator merging). A
/// faithful port of dart-sass `_weaveParents`. Returns `None` when the two
/// can't be woven.
fn weave_parents(prefix: &DComplex, base: &DComplex) -> Option<Vec<DComplex>> {
    let leading = merge_leading_combinators(&prefix.leading, &base.leading)?;

    // Queues of _only_ the parent selectors: the prefix only contains parents,
    // but `base` has a target component we don't weave in.
    let mut queue1: std::collections::VecDeque<TComp> = prefix.comps.iter().cloned().collect();
    let mut queue2: std::collections::VecDeque<TComp> =
        base.comps[..base.comps.len() - 1].iter().cloned().collect();

    let trailing_combinators = merge_trailing_combinators(&mut queue1, &mut queue2)?;

    // `_firstIfRootish`: ensure rootish selectors (`:root` etc.) are unified and
    // pinned to the front.
    let rootish1 = first_if_rootish(&mut queue1);
    let rootish2 = first_if_rootish(&mut queue2);
    match (rootish1, rootish2) {
        (Some(r1), Some(r2)) => {
            let rootish = unify_compounds(&r1.compound.simples, &r2.compound.simples)?;
            let comp = Compound { simples: rootish };
            queue1.push_front(TComp {
                compound: comp.clone(),
                combinators: r1.combinators,
            });
            queue2.push_front(TComp {
                compound: comp,
                combinators: r2.combinators,
            });
        }
        (Some(r), None) | (None, Some(r)) => {
            queue1.push_front(r.clone());
            queue2.push_front(r);
        }
        (None, None) => {}
    }

    let mut groups1 = group_selectors(queue1.iter().cloned());
    let mut groups2 = group_selectors(queue2.iter().cloned());

    // LCS of the two group lists (dart-sass passes groups2, groups1).
    let groups1_vec: Vec<Vec<TComp>> = groups1.iter().cloned().collect();
    let groups2_vec: Vec<Vec<TComp>> = groups2.iter().cloned().collect();
    let lcs = lcs_groups(&groups2_vec, &groups1_vec);

    let mut choices: Vec<Vec<Vec<TComp>>> = Vec::new();
    for group in &lcs {
        let chunk = chunks_groups(&mut groups1, &mut groups2, |seq| {
            seq.front()
                .map(|g| complex_is_parent_superselector(g, group))
                .unwrap_or(false)
        });
        // Flatten each chunk (a list of groups) into a flat component list.
        let flattened: Vec<Vec<TComp>> = chunk.into_iter().map(flatten_groups).collect();
        choices.push(flattened);
        choices.push(vec![group.clone()]);
        groups1.pop_front();
        groups2.pop_front();
    }
    let tail = chunks_groups(&mut groups1, &mut groups2, |seq| seq.is_empty());
    choices.push(tail.into_iter().map(flatten_groups).collect());
    for tc in trailing_combinators {
        choices.push(tc);
    }

    // Cartesian product of the non-empty choices, flattening each path. The
    // iteration order matches dart-sass `paths`: for each choice, the option is
    // the outer loop and the accumulated paths the inner loop.
    let mut results: Vec<Vec<TComp>> = vec![Vec::new()];
    for choice in choices.iter().filter(|c| !c.is_empty()) {
        let mut next = Vec::new();
        for option in choice {
            for path in &results {
                let mut p = path.clone();
                p.extend(option.iter().cloned());
                next.push(p);
            }
        }
        results = next;
        if results.len() > 100_000 {
            break;
        }
    }
    Some(
        results
            .into_iter()
            .map(|comps| DComplex {
                leading: leading.clone(),
                comps,
            })
            .collect(),
    )
}

/// Flatten a list of groups (each itself a component list) into a single
/// component list.
fn flatten_groups(groups: Vec<Vec<TComp>>) -> Vec<TComp> {
    groups.into_iter().flatten().collect()
}

/// dart-sass `_firstIfRootish`: if the first queue element's compound contains a
/// rootish pseudo-class (`:root`/`:scope`/`:host`/`:host-context`), remove and
/// return it.
fn first_if_rootish(queue: &mut std::collections::VecDeque<TComp>) -> Option<TComp> {
    let first = queue.front()?;
    let is_rootish = first.compound.simples.iter().any(|s| {
        if let Simple::Pseudo(text) = s {
            is_rootish_pseudo_class(text)
        } else {
            false
        }
    });
    if is_rootish {
        queue.pop_front()
    } else {
        None
    }
}

/// Whether a pseudo text is a rootish *class* (single colon) named one of
/// `root`/`scope`/`host`/`host-context`.
fn is_rootish_pseudo_class(text: &str) -> bool {
    if text.starts_with("::") {
        return false;
    }
    let name = text.trim_start_matches(':');
    let base = name.split(['(', ' ']).next().unwrap_or(name).to_ascii_lowercase();
    matches!(base.as_str(), "root" | "scope" | "host" | "host-context")
}

/// dart-sass `_mergeTrailingCombinators`: extract trailing combinators from the
/// ends of `components1`/`components2` and merge them into a list of choice
/// groups (each a list of component lists). Returns `None` if they can't be
/// merged. Iterative port of the recursive Dart original.
#[allow(clippy::type_complexity)]
fn merge_trailing_combinators(
    components1: &mut std::collections::VecDeque<TComp>,
    components2: &mut std::collections::VecDeque<TComp>,
) -> Option<Vec<Vec<Vec<TComp>>>> {
    let mut result: std::collections::VecDeque<Vec<Vec<TComp>>> = std::collections::VecDeque::new();
    loop {
        let combinators1 = components1
            .back()
            .map(|c| c.combinators.clone())
            .unwrap_or_default();
        let combinators2 = components2
            .back()
            .map(|c| c.combinators.clone())
            .unwrap_or_default();
        if combinators1.is_empty() && combinators2.is_empty() {
            return Some(result.into_iter().collect());
        }
        if combinators1.len() > 1 || combinators2.len() > 1 {
            return None;
        }
        let c1 = combinators1.first().copied();
        let c2 = combinators2.first().copied();
        // Each popped component retains its trailing combinators (mirroring
        // dart-sass `removeLast()`), so a sibling/child combinator that "wins" a
        // case is preserved on the resulting component.
        match (c1, c2) {
            (Some(Combinator::FollowingSibling), Some(Combinator::FollowingSibling)) => {
                let component1 = components1.pop_back()?;
                let component2 = components2.pop_back()?;
                if compound_is_superselector(&component1.compound, &component2.compound, &[]) {
                    result.push_front(vec![vec![component2]]);
                } else if compound_is_superselector(&component2.compound, &component1.compound, &[]) {
                    result.push_front(vec![vec![component1]]);
                } else {
                    let mut choices = vec![
                        vec![component1.clone(), component2.clone()],
                        vec![component2.clone(), component1.clone()],
                    ];
                    if let Some(unified) =
                        unify_compounds(&component1.compound.simples, &component2.compound.simples)
                    {
                        choices.push(vec![TComp {
                            compound: Compound { simples: unified },
                            combinators: vec![Combinator::FollowingSibling],
                        }]);
                    }
                    result.push_front(choices);
                }
            }
            (Some(Combinator::FollowingSibling), Some(Combinator::NextSibling))
            | (Some(Combinator::NextSibling), Some(Combinator::FollowingSibling)) => {
                // Identify which side is `+` (next) and which is `~` (following).
                let following_first = c1 == Some(Combinator::FollowingSibling);
                let following = if following_first {
                    components1.pop_back()?
                } else {
                    components2.pop_back()?
                };
                let next = if following_first {
                    components2.pop_back()?
                } else {
                    components1.pop_back()?
                };
                if compound_is_superselector(&following.compound, &next.compound, &[]) {
                    result.push_front(vec![vec![next]]);
                } else {
                    let mut choices = vec![vec![following.clone(), next.clone()]];
                    if let Some(unified) =
                        unify_compounds(&following.compound.simples, &next.compound.simples)
                    {
                        choices.push(vec![TComp {
                            compound: Compound { simples: unified },
                            combinators: next.combinators.clone(),
                        }]);
                    }
                    result.push_front(choices);
                }
            }
            (Some(Combinator::Child), Some(Combinator::NextSibling))
            | (Some(Combinator::Child), Some(Combinator::FollowingSibling)) => {
                // The sibling component wins (kept with its combinator); the
                // child component is dropped.
                let sibling = components2.pop_back()?;
                result.push_front(vec![vec![sibling]]);
            }
            (Some(Combinator::NextSibling), Some(Combinator::Child))
            | (Some(Combinator::FollowingSibling), Some(Combinator::Child)) => {
                let sibling = components1.pop_back()?;
                result.push_front(vec![vec![sibling]]);
            }
            (Some(comb1), Some(comb2)) if comb1 == comb2 => {
                let comp1 = components1.pop_back()?;
                let comp2 = components2.pop_back()?;
                let unified = unify_compounds(&comp1.compound.simples, &comp2.compound.simples)?;
                result.push_front(vec![vec![TComp {
                    compound: Compound { simples: unified },
                    combinators: vec![comb1],
                }]]);
            }
            (Some(combinator), None) => {
                if combinator == Combinator::Child
                    && components2
                        .back()
                        .map(|d| {
                            components1
                                .back()
                                .map(|c| compound_is_superselector(&d.compound, &c.compound, &[]))
                                .unwrap_or(false)
                        })
                        .unwrap_or(false)
                {
                    components2.pop_back();
                }
                let comp = components1.pop_back()?;
                result.push_front(vec![vec![comp]]);
            }
            (None, Some(combinator)) => {
                if combinator == Combinator::Child
                    && components1
                        .back()
                        .map(|d| {
                            components2
                                .back()
                                .map(|c| compound_is_superselector(&d.compound, &c.compound, &[]))
                                .unwrap_or(false)
                        })
                        .unwrap_or(false)
                {
                    components1.pop_back();
                }
                let comp = components2.pop_back()?;
                result.push_front(vec![vec![comp]]);
            }
            _ => return None,
        }
    }
}

/// dart-sass `_groupSelectors`: group components into the longest possible
/// sub-lists such that components without trailing combinators only appear at
/// the end of a sub-list. E.g. `A B > C D + E ~ G` → `[(A) (B > C) (D + E ~ G)]`.
fn group_selectors<I: IntoIterator<Item = TComp>>(components: I) -> std::collections::VecDeque<Vec<TComp>> {
    let mut groups: std::collections::VecDeque<Vec<TComp>> = std::collections::VecDeque::new();
    let mut group: Vec<TComp> = Vec::new();
    for component in components {
        let ends_group = component.combinators.is_empty();
        group.push(component);
        if ends_group {
            groups.push_back(std::mem::take(&mut group));
        }
    }
    if !group.is_empty() {
        groups.push_back(group);
    }
    groups
}

/// dart-sass `_mustUnify`: whether two component lists share a unique simple
/// selector (an id or pseudo-element) and so must be unified.
fn must_unify(complex1: &[TComp], complex2: &[TComp]) -> bool {
    let mut unique: Vec<&Simple> = Vec::new();
    for component in complex1 {
        for simple in &component.compound.simples {
            if is_unique_simple(simple) && !unique.contains(&simple) {
                unique.push(simple);
            }
        }
    }
    if unique.is_empty() {
        return false;
    }
    complex2.iter().any(|component| {
        component
            .compound
            .simples
            .iter()
            .any(|simple| is_unique_simple(simple) && unique.contains(&simple))
    })
}

/// dart-sass `_isUnique`: a compound may contain only one of these per type — an
/// id selector or a pseudo-element.
fn is_unique_simple(simple: &Simple) -> bool {
    matches!(simple, Simple::Id(_)) || is_pseudo_element(simple)
}

/// dart-sass `_chunks` over group lists: drain the leading subsequence of each
/// queue (up to where `done` first holds) and return the two orderings of the
/// combined drained groups, or a single ordering when one side is empty.
fn chunks_groups<F>(
    q1: &mut std::collections::VecDeque<Vec<TComp>>,
    q2: &mut std::collections::VecDeque<Vec<TComp>>,
    done: F,
) -> Vec<Vec<Vec<TComp>>>
where
    F: Fn(&std::collections::VecDeque<Vec<TComp>>) -> bool,
{
    let mut chunk1: Vec<Vec<TComp>> = Vec::new();
    while !done(q1) {
        match q1.pop_front() {
            Some(g) => chunk1.push(g),
            None => break,
        }
    }
    let mut chunk2: Vec<Vec<TComp>> = Vec::new();
    while !done(q2) {
        match q2.pop_front() {
            Some(g) => chunk2.push(g),
            None => break,
        }
    }
    match (chunk1.is_empty(), chunk2.is_empty()) {
        (true, true) => Vec::new(),
        (true, false) => vec![chunk2],
        (false, true) => vec![chunk1],
        (false, false) => {
            let mut a = chunk1.clone();
            a.extend(chunk2.clone());
            let mut b = chunk2;
            b.extend(chunk1);
            vec![a, b]
        }
    }
}

/// LCS over group lists with dart-sass's `select`: two groups match if they're
/// equal, one is a parent-superselector of the other (then the more specific is
/// chosen), or they must-unify and unify to a single complex.
fn lcs_groups(list1: &[Vec<TComp>], list2: &[Vec<TComp>]) -> Vec<Vec<TComp>> {
    let n = list1.len();
    let m = list2.len();
    let mut lengths = vec![vec![0usize; m + 1]; n + 1];
    let mut selections: Vec<Vec<Option<Vec<TComp>>>> = vec![vec![None; m]; n];
    for i in 0..n {
        for j in 0..m {
            let sel = lcs_select_groups(&list1[i], &list2[j]);
            let has = sel.is_some();
            selections[i][j] = sel;
            lengths[i + 1][j + 1] = if has {
                lengths[i][j] + 1
            } else {
                lengths[i + 1][j].max(lengths[i][j + 1])
            };
        }
    }
    let mut out = Vec::new();
    backtrack_groups(n as isize - 1, m as isize - 1, &lengths, &selections, &mut out);
    out
}

fn backtrack_groups(
    i: isize,
    j: isize,
    lengths: &[Vec<usize>],
    selections: &[Vec<Option<Vec<TComp>>>],
    out: &mut Vec<Vec<TComp>>,
) {
    if i == -1 || j == -1 {
        return;
    }
    let (ui, uj) = (i as usize, j as usize);
    if let Some(sel) = &selections[ui][uj] {
        backtrack_groups(i - 1, j - 1, lengths, selections, out);
        out.push(sel.clone());
        return;
    }
    if lengths[ui + 1][uj] > lengths[ui][uj + 1] {
        backtrack_groups(i, j - 1, lengths, selections, out);
    } else {
        backtrack_groups(i - 1, j, lengths, selections, out);
    }
}

/// The LCS selection for two groups (component lists), per dart-sass.
fn lcs_select_groups(group1: &[TComp], group2: &[TComp]) -> Option<Vec<TComp>> {
    if group1 == group2 {
        return Some(group1.to_vec());
    }
    if complex_is_parent_superselector(group1, group2) {
        return Some(group2.to_vec());
    }
    if complex_is_parent_superselector(group2, group1) {
        return Some(group1.to_vec());
    }
    if !must_unify(group1, group2) {
        return None;
    }
    // Unify the two groups as complete complex selectors; keep only if the
    // unification yields a single complex selector (dart-sass
    // `unified?.singleOrNull?.components`).
    let c1 = DComplex {
        leading: Vec::new(),
        comps: group1.to_vec(),
    };
    let c2 = DComplex {
        leading: Vec::new(),
        comps: group2.to_vec(),
    };
    let unified = unify_complex_list(&[c1, c2])?;
    match unified.as_slice() {
        [single] => Some(single.comps.clone()),
        _ => None,
    }
}

/// dart-sass `_complexIsParentSuperselector`: like `complexIsSuperselector` but
/// as though both shared an implicit trailing base compound. Implemented by
/// appending a shared placeholder component to each and testing superselection.
fn complex_is_parent_superselector(complex1: &[TComp], complex2: &[TComp]) -> bool {
    if complex1.len() > complex2.len() {
        return false;
    }
    let base = TComp {
        compound: Compound {
            simples: vec![Simple::Placeholder("<temp>".to_string())],
        },
        combinators: Vec::new(),
    };
    let mut c1 = complex1.to_vec();
    c1.push(base.clone());
    let mut c2 = complex2.to_vec();
    c2.push(base);
    complex_is_superselector_trailing(&c1, &c2)
}

/// Compute the replacement options for one component. The first option is the
/// original component (as a one-element sequence). For a compound with multiple
/// simple selectors, each simple is extended independently and the
/// within-compound Cartesian product is taken (so `.a.b` with `.a`→`.x` and
/// `.b`→`.y` yields `.a.b`, `.a.y`, `.b.x`, `.x.y`), then unified. Chains
/// (`.a` → `.b` → `.c`) expand transitively: each extender is fully extended in
/// isolation first, so the per-simple option set already contains the whole
/// chain. The within-compound product is then computed once (no re-extension of
/// the original simples, which would spuriously double-count combinations).
/// A parsed selector-bearing pseudo: `:name(arg)`.
struct PseudoParts {
    /// The verbatim head including the leading colon(s), e.g. `:not` or `::is`.
    head: String,
    /// The lowercased name without colons, e.g. `not`, `is`.
    name: String,
    /// The raw argument text inside the parentheses.
    arg: String,
}

/// Parse a pseudo simple's text into its head/name/argument if it carries a
/// selector argument. Returns `None` for argument-less pseudos or non-pseudos.
fn parse_pseudo_parts(text: &str) -> Option<PseudoParts> {
    let open = text.find('(')?;
    if !text.ends_with(')') {
        return None;
    }
    let head = text[..open].to_string();
    let name = head.trim_start_matches(':').to_ascii_lowercase();
    let arg = text[open + 1..text.len() - 1].to_string();
    Some(PseudoParts { head, name, arg })
}

/// Whether any simple in `complex` is a selector-bearing pseudo (`:not(...)`,
/// `:is(...)`, etc.) whose argument we might further extend on a later pass.
fn complex_has_selector_pseudo(complex: &Complex) -> bool {
    complex.components.iter().any(|comp| {
        comp.compound.simples.iter().any(|s| {
            let Simple::Pseudo(text) = s else { return false };
            parse_pseudo_parts(text).is_some_and(|p| is_selector_pseudo(&p.name))
        })
    })
}

/// Whether `complex` contains a selector pseudo (`:not`/`:is`/`::slotted`/…)
/// whose ARGUMENT mentions one of the extension `targets`. When `only_not`, only
/// `:not` counts. Used to route extension to the legacy one-shot worklist: when
/// a target lives inside a pseudo argument, dart rewrites the compound in place
/// and applies such extensions simultaneously, which the sequential per-batch
/// fold mishandles. A pseudo whose argument is NOT a target (`:not(:first-child)`
/// in 086.1) is ignored, so those stay on the fold.
fn pseudo_arg_has_target(complex: &Complex, targets: &FxHashSet<Simple>, only_not: bool) -> bool {
    complex.components.iter().any(|comp| {
        comp.compound.simples.iter().any(|s| {
            let Simple::Pseudo(text) = s else { return false };
            let Some(parts) = parse_pseudo_parts(text) else {
                return false;
            };
            if !is_selector_pseudo(&parts.name) || (only_not && unvendor(&parts.name) != "not") {
                return false;
            }
            parse_list(&parts.arg).is_some_and(|list| {
                list.iter().any(|c| {
                    c.components
                        .iter()
                        .any(|cc| cc.compound.simples.iter().any(|inner| targets.contains(inner)))
                })
            })
        })
    })
}

/// Whether `complex` mentions one of `targets` inside a selector-pseudo's
/// argument at ANY nesting depth (`:has(:not(.thing[disabled]))` reaches the
/// `.thing` target two pseudos deep). The shallow [`pseudo_arg_has_target`] only
/// inspects the immediate argument, so it misses a target buried under an outer
/// pseudo; this recursion is what flags issue_2055's `:has(:not(...))` extender
/// as self-referential so the `addSelector` pre-extension and the self-inclusive
/// `_extendExistingExtensions` re-extension apply to it.
fn pseudo_arg_has_target_deep(complex: &Complex, targets: &FxHashSet<Simple>) -> bool {
    complex.components.iter().any(|comp| {
        comp.compound.simples.iter().any(|s| {
            let Simple::Pseudo(text) = s else { return false };
            let Some(parts) = parse_pseudo_parts(text) else {
                return false;
            };
            if !is_selector_pseudo(&parts.name) {
                return false;
            }
            parse_list(&parts.arg).is_some_and(|list| {
                list.iter().any(|c| {
                    c.components
                        .iter()
                        .any(|cc| cc.compound.simples.iter().any(|inner| targets.contains(inner)))
                        || pseudo_arg_has_target_deep(c, targets)
                })
            })
        })
    })
}

/// Sound over-approximation of "can this batch's extensions possibly change
/// `complex`?". A `@extend` only rewrites a complex when one of its target
/// simples appears either DIRECTLY in a compound (matched by `collect_extenders`
/// via `Simple` equality) OR inside a selector-pseudo's argument at any depth
/// (rewritten in place by `expand_pseudos_in_compound`/`extend_pseudo`, which
/// only descend into [`is_selector_pseudo`] arguments). If NONE of `targets`
/// appears in either position, `extend_complex_breaks` is GUARANTEED to return
/// the complex unchanged — so the heavy `to_dart` + per-component scan can be
/// skipped. The match is exactly the union of the two sound sub-checks, so this
/// only returns `false` when the complex DEFINITELY cannot match (the byte-exact
/// ratchet and the Phase-1a guard catch any unsoundness immediately).
fn complex_may_match_targets(complex: &Complex, targets: &FxHashSet<Simple>) -> bool {
    if targets.is_empty() {
        return false;
    }
    complex
        .components
        .iter()
        .any(|comp| comp.compound.simples.iter().any(|s| targets.contains(s)))
        || pseudo_arg_has_target_deep(complex, targets)
}

/// Collect the EXACT set `S` of simples such that
/// `complex_may_match_targets(complex, {s})` is true: every `Simple` appearing
/// DIRECTLY in a compound, PLUS every `Simple` appearing inside a selector-pseudo
/// argument at ANY nesting depth. Mirrors [`complex_may_match_targets`] /
/// [`pseudo_arg_has_target_deep`] inverted (the membership predicate built into
/// an enumeration), so for any non-empty `targets`:
/// `complex_may_match_targets(complex, targets)` ==
/// `targets.iter().any(|t| collect_match_simples(complex).contains(t))`.
/// Used by the per-rule fold to skip a batch ALL of whose targets are absent from
/// the running selector list — a provably no-op (output- and budget-neutral)
/// batch, since `extend_list_batch` gates each complex by `can_match` BEFORE it
/// consumes any work budget.
fn collect_match_simples(complex: &Complex, out: &mut FxHashSet<Simple>) {
    for comp in &complex.components {
        for s in &comp.compound.simples {
            // Direct compound membership.
            out.insert(s.clone());
            // Recurse into selector-pseudo arguments at any depth.
            let Simple::Pseudo(text) = s else { continue };
            let Some(parts) = parse_pseudo_parts(text) else {
                continue;
            };
            if !is_selector_pseudo(&parts.name) {
                continue;
            }
            if let Some(list) = parse_list(&parts.arg) {
                for c in &list {
                    collect_match_simples(c, out);
                }
            }
        }
    }
}

/// Whether a pseudo name takes a selector list we should extend. `slotted` is
/// the selector-bearing pseudo-*element* (dart-sass `_selectorPseudoElements`).
fn is_selector_pseudo(name: &str) -> bool {
    matches!(
        unvendor(name),
        "not" | "is" | "matches" | "where" | "any" | "current" | "has" | "host" | "host-context" | "slotted"
    ) || name.ends_with("-any")
}

/// Strip a CSS vendor prefix (`-pfx-is` → `is`), matching dart-sass `unvendor`,
/// so a vendor-prefixed selector pseudo is recognized. A `--custom` name or a
/// bare `-name` (no closing prefix dash) is returned unchanged.
fn unvendor(name: &str) -> &str {
    let bytes = name.as_bytes();
    if bytes.len() < 2 || bytes[0] != b'-' || bytes[1] == b'-' {
        return name;
    }
    for i in 2..bytes.len() {
        if bytes[i] == b'-' {
            return &name[i + 1..];
        }
    }
    name
}

/// dart-sass `_extendList`: recursively extend a list of complex selectors,
/// dedup, and trim redundant superselectors. Used for pseudo arguments.
fn extend_list(list: &[Complex], extensions: &[Extension]) -> Vec<Complex> {
    let all_orig: Vec<bool> = vec![true; list.len()];
    let (result, changed) = extend_to_fixpoint_inner(
        list,
        &[],
        &all_orig,
        None,
        extensions,
        CartesianOrder::Fold,
        false,
    );
    // dart `_extendList`: when no complex was changed the ORIGINAL list is
    // returned untouched — no trim, duplicates preserved.
    if !changed {
        return list.to_vec();
    }
    let source_spec = source_specificity_map(extensions);
    trim(result.into_iter().map(|(c, _, o)| (c, o)).collect(), &source_spec)
}

/// Build a single-extender [`Extension`] cloning `src`'s metadata. The `matched`
/// cell is SHARED (`Rc::clone`) so the `!optional` "not found" check still flips
/// when this split extension is applied to a selector.
fn single_extension(src: &Extension, target: Simple, extender: Complex, break_flag: bool) -> Extension {
    Extension {
        target: Some(target),
        extenders: vec![extender],
        extender_breaks: vec![break_flag],
        optional: src.optional,
        matched: std::rc::Rc::clone(&src.matched),
        origin: src.origin.clone(),
        reg_idx: src.reg_idx,
        derived: false,
        via_origin: None,
        origin_closure: std::rc::Rc::clone(&src.origin_closure),
    }
}

/// Register a transitively-derived extension (dart `extension.withExtender`):
/// `complex` becomes a new extender for `old`'s target unless already present
/// (then only the optional flag merges, mandatory winning). It is ALWAYS indexed
/// in the store (`sources`/`by_extender`) so a later `@extend` can chain onto it,
/// but only joins the current `batch` — dart's `additionalExtensions`, which
/// extend selectors in the SAME pass as the triggering extension — when its
/// target equals the triggering @extend's target (`batch_target_key`), per
/// dart's `if (newExtensions.containsKey(extension.target))`. In case 229 the
/// derived `b ← d c` (target `b`) must NOT extend `a b` alongside `a ← d`
/// (target `a`), or it would re-emit `d c` early and reorder the output.
#[allow(clippy::too_many_arguments)]
fn register_derived(
    registry: &mut Vec<Extension>,
    sources: &mut FxHashMap<Simple, FxHashMap<(Complex, String), usize>>,
    by_extender: &mut FxHashMap<Simple, Vec<usize>>,
    batch: &mut Vec<Extension>,
    batch_target: &Simple,
    old: &Extension,
    old_target: &Simple,
    via: &Extension,
    complex: Complex,
) {
    assert_render_injective(&complex);
    let target_sources = sources.entry(old_target.clone()).or_default();
    let source_key = (complex.clone(), old.origin.clone());
    if let Some(&idx) = target_sources.get(&source_key) {
        if !old.optional {
            registry[idx].optional = false;
        }
        return;
    }
    let idx = registry.len();
    let mut simples = Vec::new();
    all_simples_of(&complex, &mut simples);
    target_sources.insert(source_key, idx);
    // Woven/derived products carry no source line break (dart's lineBreak only
    // travels with the original extender object); the fold's flag plumbing keeps
    // an original's own flag separately.
    let mut derived = single_extension(old, old_target.clone(), complex, false);
    derived.derived = true;
    derived.via_origin = Some(via.origin.clone());
    derived.reg_idx = via.reg_idx;
    registry.push(derived.clone());
    if old_target == batch_target {
        batch.push(derived);
    }
    for s in simples {
        assert_simple_render_injective(&s);
        by_extender.entry(s).or_default().push(idx);
    }
}

/// Faithful port of dart `ExtensionStore.addExtension` + `_extendExistingExtensions`
/// (extension_store.dart 242-399), grouped into BATCHES for sasso's 2-phase model.
///
/// dart registers `@extend`s one at a time in document order; each `addExtension`
/// (a) records the new `target ← extender` extension, (b) re-extends every
/// already-registered extension whose extender contains `target` by the new one
/// (registering those transitively-derived extensions too), then (c) extends all
/// matching selectors by the WHOLE new set — the triggering extension PLUS its
/// derived ones — in ONE `_extendList` pass (`mapAddAll2` +
/// `_extendExistingSelectors`). Applying the derived extensions in the same pass
/// (not as a separate later step) is what keeps the output order: a derived
/// `b ← d c` must extend `a b` together with `a ← d`, not after it.
///
/// So this returns one BATCH per input `@extend`: the new extensions it
/// registers (triggering + transitively-derived). A per-rule fold then applies
/// each batch as one multi-extension `_extendList`, reproducing dart's
/// registration-order output. The store (`sources`/`by_extender`) accumulates
/// across batches so a later `@extend` chains onto earlier derived extensions.
fn expand_extensions(input: &[Extension]) -> (Vec<Vec<Extension>>, Vec<Extension>, Vec<usize>) {
    // Flat registry of every registered single-extender extension, indexed by
    // `by_extender`/`sources` (dart `_extensions`/`_extensionsByExtender`). Also
    // returned for the pseudo path's legacy worklist, which needs the full set
    // (incl. derived extensions whose target differs from their trigger's, so no
    // batch applies them — e.g. `upstream <- :is(midstream, downstream)` for
    // dart#1297).
    let mut registry: Vec<Extension> = Vec::new();
    let mut sources: FxHashMap<Simple, FxHashMap<(Complex, String), usize>> = FxHashMap::default();
    let mut by_extender: FxHashMap<Simple, Vec<usize>> = FxHashMap::default();
    let mut batches: Vec<Vec<Extension>> = Vec::new();
    let mut registry_marks: Vec<usize> = Vec::new();
    // Store-wide source specificity (dart `_sourceSpecificity`, from the
    // original extenders) used to TRIM each transitively-derived extender just
    // as dart's `_extendCompound` does — without it a self-overlapping extender
    // (`.a` extended by `.a.mod1`) derives `.a.mod1.mod3`, `.a.mod1.mod3.mod5`,
    // … in a combinatorial blow-up (after_target:multiple_recursive). dart trims
    // each `.a.mod1.modN` away (covered by `.a.mod1` at equal specificity) before
    // it can become a registered extender, so the derivation terminates.
    let source_spec = source_specificity_map(input);
    // Every `@extend` target, for detecting a self-referential pseudo extender
    // (one whose `:not(...)`/`:has(...)` argument names a target — issue_2055).
    let all_targets: FxHashSet<Simple> = input.iter().filter_map(|e| e.target.clone()).collect();

    for ext in input {
        let Some(target) = ext.target.clone() else {
            continue;
        };
        // dart reads `_extensionsByExtender[target]` at the TOP of addExtension,
        // BEFORE this @extend's own extenders are registered, so it can never
        // re-extend itself. Snapshot it now.
        let existing: Vec<usize> = by_extender.get(&target).cloned().unwrap_or_default();
        // dart `ExtensionStore.addSelector`: BEFORE this rule's `@extend` runs,
        // dart added the rule's own selector to the store, extending it by every
        // extension registered SO FAR (`selector = _extendList(selector,
        // _extensions)`). The extender passed to `addExtension` is therefore the
        // ALREADY-EXTENDED rule selector, not the raw one. sasso keeps the raw
        // extender per `@extend`, so reproduce `addSelector` here: pre-extend each
        // extender by the registry accumulated from earlier `@extend`s. This is
        // what gives issue_2055 its extra nesting — rule3's `:has(:not(.thing
        // [disabled]))` is registered as `:has(:not(.thing[disabled]):not(
        // [disabled]:not(.thing[disabled])))` because the earlier `:not(.thing
        // [disabled])` extension already extended its `.thing`. The pre-extension
        // is a no-op for the first `@extend` (empty registry) and for extenders
        // with no extendable simple — so issue_2399 (a single first `@extend`)
        // is untouched and stays shallow.
        // The `addSelector` pre-extension only changes the outcome for a
        // SELF-REFERENTIAL pseudo extender — one whose `:not(...)`/`:has(...)`
        // argument names a target (issue_2055). For a plain extender
        // (`.a.mod1`), the existing `_extendExistingExtensions` + application
        // fold already reproduce dart, and pre-extending there double-counts the
        // self-overlapping chains (`after_target:multiple_recursive` blows up).
        // So gate the pre-extension (and the self-inclusion below) to that case,
        // and trim like dart's `_extendList` so a derived super-broad extender
        // can't snowball.
        let self_ref_extender = ext
            .extenders
            .iter()
            .any(|c| pseudo_arg_has_target_deep(c, &all_targets));
        // Extensions the pre-extension below may apply: the store so far,
        // visibility-gated to what this `@extend`'s module can see (dart's
        // per-module stores).
        //
        // The gate usually drops nothing -- a sheet whose `@extend`s all come
        // from one module has one origin -- so check for that before cloning the
        // store. The block is what ends the borrow: the registration below
        // pushes to `registry`.
        let pre_extended: Vec<(Complex, bool)> = {
            let visible_registry: std::borrow::Cow<'_, [Extension]> =
                if registry.iter().all(|r| ext.origin_closure.contains(&r.origin)) {
                    std::borrow::Cow::Borrowed(&registry[..])
                } else {
                    std::borrow::Cow::Owned(
                        registry
                            .iter()
                            .filter(|r| ext.origin_closure.contains(&r.origin))
                            .cloned()
                            .collect(),
                    )
                };
            let mut out: Vec<(Complex, bool)> = Vec::new();
            let mut seen: FxHashSet<Complex> = FxHashSet::default();
            for (j, extender) in ext.extenders.iter().enumerate() {
                let flag = ext.extender_breaks.get(j).copied().unwrap_or(false);
                let products = if registry.is_empty() {
                    vec![extender.clone()]
                } else if self_ref_extender {
                    // dart `addSelector` = `_extendList(selector, _extensions)`.
                    // For a self-referential pseudo extender the extension is an
                    // in-place pseudo-argument rewrite (`:has(:not(.thing[…]))`
                    // becomes `:has(:not(.thing[…]):not([disabled]:not(…)))`), so
                    // it REPLACES the bare extender rather than coexisting — no
                    // top-level trim is needed and the `:not`/`:has` dedup inside
                    // `extend_complex` already bounds the recursion.
                    extend_complex(extender, &registry)
                } else if visible_registry.is_empty() {
                    vec![extender.clone()]
                } else {
                    // dart `addSelector`: the rule's selector was ALREADY
                    // extended by every extension registered so far when its
                    // `@extend` runs, so the extender list arrives
                    // pre-extended in registration order — this is where
                    // chained extends get dart's FORWARD product order
                    // (bootstrap's navbar containers). Trim like `_extendList`
                    // so a product the original covers drops.
                    let empty: FxHashSet<Complex> = FxHashSet::default();
                    trim(
                        extend_complex_breaks(
                            extender,
                            false,
                            true,
                            Some(&ext.origin),
                            &visible_registry,
                            &empty,
                            CartesianOrder::Fold,
                        )
                        .into_iter()
                        .map(|(c, _, o)| (c, o))
                        .collect(),
                        &source_spec,
                    )
                };
                for c in products {
                    if seen.insert(c.clone()) {
                        out.push((c, flag));
                    }
                }
            }
            out
        };
        // This @extend's new extensions (dart `newExtensionsByTarget`): the
        // triggering single-extender splits, then the derived ones below.
        let mut batch: Vec<Extension> = Vec::new();
        let mut new_slice: Vec<Extension> = Vec::new();
        for (extender, flag) in pre_extended.iter().map(|(c, f)| (c, *f)) {
            // Useless (multi-combinator) extenders are kept registered so the
            // extension is still applied — which marks the target "found" (so a
            // mandatory `@extend` doesn't wrongly error) — while the per-product
            // `is_useless` filter downstream drops what they'd generate. dart
            // tracks "found" via `_selectors[target]` independently; sasso flips
            // the shared `matched` cell during application, so the extension must
            // run. A single leading combinator (`> d`) is NOT useless and emits.
            assert_render_injective(extender);
            let target_sources = sources.entry(target.clone()).or_default();
            let source_key = (extender.clone(), ext.origin.clone());
            if let Some(&idx) = target_sources.get(&source_key) {
                // dart MergedExtension.merge: only the optional flag is
                // observable in this model — a mandatory extension wins.
                // Merging is PER-STORE (same origin); an identical extend
                // from another module keeps its own entry and rank.
                if !ext.optional {
                    registry[idx].optional = false;
                }
                continue;
            }
            let idx = registry.len();
            target_sources.insert(source_key, idx);
            let single = single_extension(ext, target.clone(), extender.clone(), flag);
            new_slice.push(single.clone());
            batch.push(single.clone());
            registry.push(single);
            let mut simples = Vec::new();
            all_simples_of(extender, &mut simples);
            for s in simples {
                assert_simple_render_injective(&s);
                by_extender.entry(s).or_default().push(idx);
            }
        }
        // dart `_extendExistingExtensions`: re-extend each existing extender
        // (one whose extender contained `target`) by the new extension(s).
        //
        // dart snapshots `existingExtensions = _extensionsByExtender[target]` at
        // the TOP of `addExtension` and only enters this block when it was
        // NON-NULL (so the very first `@extend` for a target never re-extends —
        // issue_2399 stays shallow). But the snapshot is the LIVE list object,
        // and this `@extend`'s OWN extenders were appended to it (line above)
        // before `_extendExistingExtensions` reads `.toList()`. So when the block
        // runs, it iterates the EXISTING extenders PLUS this `@extend`'s own
        // extenders that contain `target`. That self-inclusion is what derives
        // issue_2055's deeper `:has(...)` (extender `[1]` re-extends its own
        // `.thing` by `[1]`). Derived extensions registered DURING the loop are
        // NOT re-processed (dart's `.toList()` is a one-time snapshot), so the
        // chain still terminates. dart gates the whole block on the TOP
        // snapshot being non-null, but `existingExtensions` is the LIVE
        // `_extensionsByExtender[target]` list and `.toList()` runs AFTER the
        // registration loop appended this @extend's own extenders — so an
        // extender that itself CONTAINS the target (`.z.x.y.c` extending
        // `.c`, extend-loop) is re-extended within its own registration, and
        // its derived products land in `additionalExtensions` (target ==
        // this batch's target) and apply in the same pass.
        let process: Vec<usize> = if existing.is_empty() {
            Vec::new()
        } else {
            by_extender.get(&target).cloned().unwrap_or_default()
        };
        if !new_slice.is_empty() && !process.is_empty() {
            for old_idx in process {
                if !consume_extend_work() {
                    break;
                }
                let old = registry[old_idx].clone();
                // Module visibility (dart per-module stores): a chain links only
                // when the NEW extension's origin is reachable from the OLD
                // extension's origin — the same `origin_closure.contains(origin)`
                // rule the old inline `collect_extenders` chaining used. Without
                // it, a sibling module's `@extend` would leak transitively
                // (directives/use/extend/*).
                if !ext.origin_closure.contains(&old.origin) {
                    continue;
                }
                let Some(old_target) = old.target.clone() else {
                    continue;
                };
                let old_extender = old.extenders[0].clone();
                // dart `_extendComplex` trims its products (per `_extendCompound`),
                // so a derived extender covered by the original at equal-or-greater
                // specificity is dropped before registration — the bound that keeps
                // self-overlapping chains finite.
                let empty: FxHashSet<Complex> = FxHashSet::default();
                let extended = trim(
                    extend_complex_breaks(
                        &old_extender,
                        false,
                        true,
                        Some(&old.origin),
                        &new_slice,
                        &empty,
                        CartesianOrder::Fold,
                    )
                    .into_iter()
                    .map(|(c, _, o)| (c, o))
                    .collect(),
                    &source_spec,
                );
                // dart: skip the first product when it's the unchanged extender.
                let mut iter = extended.into_iter().peekable();
                if iter.peek() == Some(&old_extender) {
                    iter.next();
                }
                for complex in iter {
                    register_derived(
                        &mut registry,
                        &mut sources,
                        &mut by_extender,
                        &mut batch,
                        &target,
                        &old,
                        &old_target,
                        ext,
                        complex,
                    );
                }
            }
        }
        if batch.is_empty() {
            // Every extender was dropped (trailing combinator) or this @extend
            // registered nothing new, yet the target must still be marked
            // "found" so a mandatory `@extend` doesn't wrongly error. Apply a
            // target-only marker: `collect_extenders` flips the shared `matched`
            // cell wherever the target appears, and emits no product. (dart
            // tracks "found" via `_selectors[target]`, independent of extenders.)
            batch.push(Extension {
                target: Some(target.clone()),
                extenders: Vec::new(),
                extender_breaks: Vec::new(),
                optional: ext.optional,
                matched: std::rc::Rc::clone(&ext.matched),
                origin: ext.origin.clone(),
                reg_idx: ext.reg_idx,
                derived: false,
                via_origin: None,
                origin_closure: std::rc::Rc::clone(&ext.origin_closure),
            });
        }
        batches.push(batch);
        registry_marks.push(registry.len());
    }
    (batches, registry, registry_marks)
}

/// One fold step = dart `_extendList` against ONE registration's new extensions
/// (the `batch`): re-extend every selector in `list` by all of `batch` at once
/// (reusing the per-component cartesian/weave pipeline), then `_trim` with the
/// store-wide `source_spec`. When nothing changed the ORIGINAL list is returned
/// untouched (no trim, duplicates preserved — dart's `_extendList` returns its
/// input unchanged, keeping issue_2291 reparses).
///
/// Each selector carries the module ORIGIN that owns it (dart's per-module
/// extension stores): the batch — represented by its triggering `@extend`'s
/// origin/closure — only extends a selector whose origin it can SEE
/// (`closure.contains(origin)`), and a product brought in by the batch takes the
/// batch's origin. This blocks transitive cross-sibling leaks in a module
/// diamond: `left-extendee` (origin `left`) is not extended by a `right` module
/// `@extend`, since `right` doesn't use `left` (directives/use/extend/scope:*).
fn extend_list_batch(
    list: &[(Complex, bool, bool, String)],
    batch: &[Extension],
    orig_scope: Option<&str>,
    source_spec: &FxHashMap<Simple, u64>,
) -> Vec<(Complex, bool, bool, String)> {
    // Representative origin of the batch (its triggering `@extend`). Every
    // single-extender split shares it; the rare derived entry keeps its source
    // module, but the batch as a whole is gated by the trigger's reach.
    let Some(rep) = batch.first() else {
        return list.to_vec();
    };
    let batch_origin = rep.origin.clone();
    let batch_closure = std::rc::Rc::clone(&rep.origin_closure);
    // Which extenders carry a source line break (dart's
    // `ComplexSelector.lineBreak`), as a set of the flagged ones only. The
    // lookup at the point of use is a yes/no question, so a map from every
    // extender to a `bool` clones a `Complex` key to record `false` almost every
    // time; the flag is rare, and an absent key answers the question.
    //
    // It has to be built per store, from the entries that store holds. Building
    // one plan-level map instead is unsound: an extender registered twice with
    // different flags reads back the OR, so a store that holds only the
    // unflagged registration would see `true` -- and that flag decides a newline
    // in expanded output.
    let mut ext_breaks: FxHashSet<Complex> = FxHashSet::default();
    for ext in batch {
        for (j, c) in ext.extenders.iter().enumerate() {
            if ext.extender_breaks.get(j).copied().unwrap_or(false) {
                ext_breaks.insert(c.clone());
            }
        }
    }
    // The batch's target simples, computed ONCE. A complex that mentions none of
    // them (directly or inside a selector-pseudo argument) cannot be changed by
    // this batch, so the per-complex `render()` + `to_dart`/`extend_complex_breaks`
    // is skipped entirely — this is the cut to the extend-heavy O(n^2) malloc.
    let batch_targets: FxHashSet<Simple> = batch.iter().filter_map(|e| e.target.clone()).collect();
    let mut out: Vec<(Complex, bool, bool)> = Vec::new();
    // complex -> owning origin, also serving as the `seen` set (a key's presence
    // marks it emitted). Keyed by `Hashed<Complex>` so each product's `Complex`
    // tree is walked ONCE (at `Hashed::new`) and reused for the entry probe AND
    // the post-trim origin lookup, instead of the derived `Complex` `Hash`
    // re-walking components→compounds→simples→`String` on every map operation.
    // (Phase-1a proved typed `Complex` keys partition identically to `render()`;
    // `Hashed` keeps `Eq` structural so the partition is byte-identical.)
    let mut origin_of: FxHashMap<Hashed<Complex>, String> = FxHashMap::default();
    let mut changed = false;
    for (complex, in_break, c_orig, c_origin) in list {
        let visible = batch_closure.contains(c_origin);
        // Cheap sound pre-filter: a complex containing none of the batch's
        // targets is GUARANTEED unchanged, so pass it through without `render()`,
        // `to_dart`, or `extend_complex_breaks`.
        let can_match = visible && complex_may_match_targets(complex, &batch_targets);
        let products = if can_match && consume_extend_work() && out.len() <= 100_000 {
            extend_complex_breaks(
                complex,
                *in_break,
                *c_orig,
                orig_scope,
                batch,
                &ext_breaks,
                CartesianOrder::Fold,
            )
        } else {
            vec![(complex.clone(), *in_break, *c_orig)]
        };
        if can_match && !(products.len() == 1 && products[0].0 == *complex) {
            changed = true;
        }
        for (c, f, o_flag) in products {
            // The unchanged self-copy keeps its origin; a genuinely new product
            // takes the batch's origin so further batches gate against it. An
            // ORIGINAL instance always joins `out` even when a value-equal
            // product came first (dart's identity `_originals`; the coverage
            // trim resolves the pair in the original's favor).
            use std::collections::hash_map::Entry;
            let key = Hashed::new(c.clone());
            match origin_of.entry(key) {
                Entry::Vacant(slot) => {
                    let o = if c == *complex {
                        c_origin.clone()
                    } else {
                        batch_origin.clone()
                    };
                    slot.insert(o);
                    out.push((c, f, o_flag));
                }
                Entry::Occupied(_) => {
                    if o_flag {
                        out.push((c, f, o_flag));
                    }
                }
            }
        }
    }
    if !changed {
        return list.to_vec();
    }
    trim_breaks(out, source_spec)
        .into_iter()
        .map(|(c, f, o_flag)| {
            let key = Hashed::new(c);
            let o = origin_of.remove(&key).unwrap_or_else(|| batch_origin.clone());
            (key.value, f, o_flag, o)
        })
        .collect()
}

/// Run the extension to a fixpoint: extend each selector, then feed every
/// newly-produced selector back through extension until nothing new appears.
/// This realizes dart-sass's extension-graph behavior where an extender produced
/// by one `@extend` can itself be extended by another (transitively, including
/// targets buried in pseudo arguments). Bounded to guarantee termination.
/// Threads per-selector line-break flags (each product carries its input's
/// flag OR any contributing extender's) and reports whether ANY input complex
/// was changed by an extension — dart `_extendList` returns the original list
/// untouched when nothing changed.
fn extend_to_fixpoint_breaks(
    list: &[Complex],
    list_breaks: &[bool],
    list_origs: &[bool],
    orig_scope: Option<&str>,
    extensions: &[Extension],
    order: CartesianOrder,
) -> (Vec<(Complex, bool, bool)>, bool) {
    extend_to_fixpoint_inner(list, list_breaks, list_origs, orig_scope, extensions, order, true)
}

/// As [`extend_to_fixpoint_breaks`], with explicit control over re-feeding a
/// freshly-produced pseudo-bearing selector. dart's `_extendList` is a SINGLE
/// pass over the components; ALL nested extension comes from `_extendPseudo`
/// recursing back into `_extendList` on a pseudo's argument. A pseudo ARGUMENT
/// therefore must NOT also re-feed at the list level: doing so runs a redundant
/// extra fixpoint at every recursion level, multiplying the work geometrically
/// with depth (the self-referential `:not`/`:has` blowup that exhausted the
/// budget in issue_2055). The top-level selector list keeps the re-feed, which
/// resolves a few plain transitive chains a lone pass misses.
fn extend_to_fixpoint_inner(
    list: &[Complex],
    list_breaks: &[bool],
    list_origs: &[bool],
    orig_scope: Option<&str>,
    extensions: &[Extension],
    order: CartesianOrder,
    refeed: bool,
) -> (Vec<(Complex, bool, bool)>, bool) {
    // Extender flags by extender selector, for the per-option lookup: the
    // flagged extenders only, and built from this store rather than hoisted (see
    // the same set in `extend_list_batch`).
    let mut ext_breaks: FxHashSet<Complex> = FxHashSet::default();
    for ext in extensions {
        for (j, c) in ext.extenders.iter().enumerate() {
            if ext.extender_breaks.get(j).copied().unwrap_or(false) {
                ext_breaks.insert(c.clone());
            }
        }
    }
    let mut result: Vec<(Complex, bool, bool)> = Vec::new();
    let mut seen: FxHashSet<String> = FxHashSet::default();
    let mut changed = false;
    // Worklist of selectors still to extend. `is_input` marks a caller-seeded
    // entry (its unchanged round-trip doesn't count as a change); `is_orig`
    // is the ORIGINAL-INSTANCE flag (dart's identity `_originals`), carried
    // through to the first product of each round-trip.
    let mut queue: std::collections::VecDeque<(Complex, bool, bool, bool)> = list
        .iter()
        .enumerate()
        .map(|(i, c)| {
            (
                c.clone(),
                list_breaks.get(i).copied().unwrap_or(false),
                true,
                list_origs.get(i).copied().unwrap_or(true),
            )
        })
        .collect();
    while let Some((complex, in_break, is_input, is_orig)) = queue.pop_front() {
        if !consume_extend_work() || result.len() > 100_000 {
            break;
        }
        let products = extend_complex_breaks(
            &complex,
            in_break,
            is_orig,
            orig_scope,
            extensions,
            &ext_breaks,
            order,
        );
        if is_input && !(products.len() == 1 && products[0].0.render() == complex.render()) {
            changed = true;
        }
        for (c, flag, orig) in products {
            let rendered = c.render();
            let len = rendered.len();
            // An ORIGINAL instance always joins the result even when a
            // value-equal PRODUCT came first: dart's identity `_originals`
            // keeps both until `_trim`, where the product (not identity-
            // original) is coverage-dropped and the original survives at its
            // own position with its own line break.
            if seen.insert(rendered) || orig {
                // Re-extend a freshly-produced selector only when it carries a
                // selector-bearing pseudo: that's the sole case where a second
                // pass can reveal *more* extensions (a target buried in a
                // pseudo argument that became extendable, or an extender pseudo
                // that is itself a target). Plain class/placeholder/type chains
                // are resolved transitively in a single pass by
                // `collect_extenders` (including multi-component extenders via
                // the visible-store re-extension), so re-feeding them would
                // only risk re-deriving cyclic self-extends without producing
                // anything new. An over-long selector (a self-referential
                // blowup) is emitted but not re-fed.
                if refeed && complex_has_selector_pseudo(&c) && len <= EXTEND_REFEED_MAX_LEN {
                    queue.push_back((c.clone(), flag, false, false));
                }
                result.push((c, flag, orig));
            }
        }
    }
    (result, changed)
}

/// dart-sass `_extendPseudo`: extend the selector argument of a selector-bearing
/// pseudo. Returns the replacement simple selectors for this pseudo position, or
/// `None` if nothing changed (keep the original simple unchanged).
///
/// For `:not()` with a single-complex original argument, the result is the set of
/// `:not()` simples to merge into the surrounding compound (older browsers can't
/// parse a complex/compound inside `:not`, so each becomes its own `:not`). For
/// every other pseudo (and `:not` whose argument was already a list), the result
/// is a single rewritten pseudo carrying the extended argument list.
// Recursion guard for nested pseudo-argument extension. A target that is itself
// a selector-pseudo containing the extended selector (`:not(.c) {@extend .c}`)
// would otherwise recurse without bound through `extend_pseudo` → `extend_list`
// → ... → `extend_pseudo`. dart-sass bounds this implicitly via its
// target-tracking; a small fixed depth covers every real case while keeping the
// engine total.
const MAX_PSEUDO_DEPTH: usize = 8;
thread_local! {
    static PSEUDO_DEPTH: std::cell::Cell<usize> = const { std::cell::Cell::new(0) };
}

// Global work budget for one top-level extend operation, shared by every
// recursion level (pseudo arguments re-enter the fixpoint via `extend_pseudo*`).
// The per-level iteration caps alone don't bound the COMBINED work: a
// self-referential extension (`:not(.c) {@extend .c}`, issue 2055/2399) makes
// each of the 8 pseudo levels run its own near-full fixpoint over selectors
// whose rendered length doubles every generation — astronomically slow even
// though technically finite. Legitimate stylesheets use a few hundred units at
// most, so exhaustion only truncates pathological self-referential output.
const EXTEND_WORK_BUDGET: usize = 20_000;
/// A produced selector longer than this is still emitted but not re-fed for
/// further extension (real transitive outputs stay around ~2 KB; unbounded
/// re-feeding doubles the length every generation).
const EXTEND_REFEED_MAX_LEN: usize = 8_192;
thread_local! {
    static EXTEND_WORK: std::cell::Cell<usize> = const { std::cell::Cell::new(EXTEND_WORK_BUDGET) };
}

/// Refill the work budget when entering extension at the top level (recursive
/// pseudo-argument entries run under `PSEUDO_DEPTH > 0` and share the budget).
fn reset_extend_budget() {
    if PSEUDO_DEPTH.with(|d| d.get()) == 0 {
        EXTEND_WORK.with(|w| w.set(EXTEND_WORK_BUDGET));
    }
}

/// Consume one unit of extension work; `false` once the budget is exhausted
/// (callers stop draining their worklist, keeping the results produced so far).
fn consume_extend_work() -> bool {
    EXTEND_WORK.with(|w| {
        let left = w.get();
        if left == 0 {
            return false;
        }
        w.set(left - 1);
        true
    })
}

fn extend_pseudo(text: &str, extensions: &[Extension]) -> Option<Vec<Simple>> {
    let parts = parse_pseudo_parts(text)?;
    if !is_selector_pseudo(&parts.name) {
        return None;
    }
    if PSEUDO_DEPTH.with(|d| d.get()) >= MAX_PSEUDO_DEPTH {
        return None;
    }
    let original = parse_list(&parts.arg)?;
    PSEUDO_DEPTH.with(|d| d.set(d.get() + 1));
    let extended = extend_list(&original, extensions);
    PSEUDO_DEPTH.with(|d| d.set(d.get() - 1));
    finish_extend_pseudo(&parts, &original, extended)
}

/// The `selector.extend`/`selector.replace` compound-target counterpart of
/// [`extend_pseudo`]: recursively extend a selector-pseudo's argument list in
/// the compound-target model so `extend(":is(.c)", ".c", ".d")` -> `:is(.c,
/// .d)`.
fn extend_pseudo_compound_target(
    text: &str,
    targets: &[Compound],
    extenders: &[Complex],
    replace: bool,
) -> Option<Vec<Simple>> {
    if PSEUDO_DEPTH.with(|d| d.get()) >= MAX_PSEUDO_DEPTH {
        return None;
    }
    // `:nth-child(An+B of <selector>)` extends only its `of` selector.
    if let Some((name, anb, sel)) = nth_of_parts(text) {
        let original = parse_list(sel)?;
        PSEUDO_DEPTH.with(|d| d.set(d.get() + 1));
        let extended = extend_compound_target(&original, targets, extenders, replace);
        PSEUDO_DEPTH.with(|d| d.set(d.get() - 1));
        return finish_nth_of(name, anb, &original, extended);
    }
    let parts = parse_pseudo_parts(text)?;
    if !is_selector_pseudo(&parts.name) {
        return None;
    }
    let original = parse_list(&parts.arg)?;
    PSEUDO_DEPTH.with(|d| d.set(d.get() + 1));
    let extended = extend_compound_target(&original, targets, extenders, replace);
    PSEUDO_DEPTH.with(|d| d.set(d.get() - 1));
    finish_extend_pseudo(&parts, &original, extended)
}

/// Re-wrap an extended `:nth-child(An+B of …)` selector list, or `None` when the
/// `of` selector was unchanged. A nested same-`(name, An+B)` nth pseudo produced
/// by the extension is unwrapped to its own `of` selectors (dart-sass merges
/// them); a different-`(name, An+B)` one is dropped (it can't be combined).
fn finish_nth_of(name: &str, anb: &str, original: &[Complex], extended: Vec<Complex>) -> Option<Vec<Simple>> {
    let mut flattened: Vec<Complex> = Vec::new();
    let mut seen: FxHashSet<String> = FxHashSet::default();
    let mut push = |c: Complex, flattened: &mut Vec<Complex>| {
        if seen.insert(c.render()) {
            flattened.push(c);
        }
    };
    for c in extended {
        match single_pseudo(&c).and_then(|t| nth_of_parts(t)) {
            Some((n, a, inner_sel)) if n == name && a == anb => {
                // Merge a nested same-`(name, An+B)` nth pseudo's own `of`
                // selectors (deduping so a self-referential extension settles).
                if let Some(list) = parse_list(inner_sel) {
                    for inner in list {
                        push(inner, &mut flattened);
                    }
                }
            }
            // A nested nth pseudo with a different name or An+B can't merge.
            Some(_) => {}
            None => push(c, &mut flattened),
        }
    }
    if flattened.len() == original.len()
        && flattened
            .iter()
            .zip(original.iter())
            .all(|(a, b)| a.render() == b.render())
    {
        return None;
    }
    let inner = flattened
        .iter()
        .map(|c| c.render())
        .collect::<Vec<_>>()
        .join(", ");
    if inner.is_empty() {
        return None;
    }
    Some(vec![Simple::Pseudo(format!("{name}({anb} of {inner})"))])
}

/// The verbatim pseudo text when `complex` is a single component holding a
/// single pseudo simple (`:nth-child(…)`), else `None`.
fn single_pseudo(complex: &Complex) -> Option<&str> {
    let [comp] = complex.components.as_slice() else {
        return None;
    };
    let [Simple::Pseudo(text)] = comp.compound.simples.as_slice() else {
        return None;
    };
    Some(text)
}

/// Selector-pseudo extension of every pseudo in `compound` in the
/// compound-target model (the `selector.extend`/`replace` counterpart of
/// [`expand_pseudos_in_compound`]).
fn expand_pseudos_compound_target(
    compound: &Compound,
    targets: &[Compound],
    extenders: &[Complex],
    replace: bool,
) -> Compound {
    let mut simples: Vec<Simple> = Vec::new();
    for s in &compound.simples {
        match s {
            Simple::Pseudo(text) => {
                // An UNCHANGED pseudo keeps duplicates (`:baz:baz` is valid
                // CSS). A replacement's products dedup against what's already
                // pushed AND against the other ORIGINAL simples (which the
                // unchanged path will keep verbatim later).
                match extend_pseudo_compound_target(text, targets, extenders, replace) {
                    None => simples.push(s.clone()),
                    Some(replacement) => {
                        for r in replacement {
                            let dup_of_other_original =
                                r != *s && compound.simples.iter().any(|o| o != s && *o == r);
                            if dup_of_other_original || simples.contains(&r) {
                                continue;
                            }
                            simples.push(r);
                        }
                    }
                }
            }
            other => simples.push(other.clone()),
        }
    }
    Compound { simples }
}

/// Shared post-processing for [`extend_pseudo`] and
/// [`extend_pseudo_compound_target`]: given the original and extended argument
/// lists, build the replacement simple selector(s) (the `:not` split, nested
/// pseudo unwrap, and matchish-pseudo re-wrap).
fn finish_extend_pseudo(
    parts: &PseudoParts,
    original: &[Complex],
    extended: Vec<Complex>,
) -> Option<Vec<Simple>> {
    // Nothing changed.
    if extended.len() == original.len()
        && extended
            .iter()
            .zip(original.iter())
            .all(|(a, b)| a.render() == b.render())
    {
        return None;
    }

    // For `:not`, drop complex selectors from the extension result unless the
    // original argument itself contained a complex selector (otherwise we'd
    // produce a `:not()` no browser can parse). We can keep them if every
    // extension result is complex, since then nothing already-working breaks.
    let original_has_complex = original.iter().any(|c| c.components.len() > 1);
    let mut complexes: Vec<Complex> =
        if parts.name == "not" && !original_has_complex && extended.iter().any(|c| c.components.len() == 1) {
            extended.into_iter().filter(|c| c.components.len() <= 1).collect()
        } else {
            extended
        };

    // Unwrap nested matching pseudos in single-compound results, mirroring
    // dart-sass: e.g. for `:not`, a result `:is(...)`/`:matches`/`:where` is
    // unwrapped to its inner selectors; for matchish pseudos, a result of the
    // same name+argument is likewise unwrapped.
    let mut unwrapped: Vec<Complex> = Vec::new();
    for complex in complexes.drain(..) {
        let inner = single_pseudo_inner(&complex, &parts.name);
        match inner {
            PseudoUnwrap::Keep => unwrapped.push(complex),
            PseudoUnwrap::Drop => {}
            PseudoUnwrap::Replace(list) => unwrapped.extend(list),
        }
    }
    let complexes = unwrapped;

    // `:not` with a single-complex original argument splits into separate
    // `:not()` simples merged into the surrounding compound.
    if parts.name == "not" && original.len() == 1 {
        let result: Vec<Simple> = complexes
            .into_iter()
            .map(|c| Simple::Pseudo(format!("{}({})", parts.head, c.render())))
            .collect();
        if result.is_empty() {
            return None;
        }
        return Some(result);
    }

    if complexes.is_empty() {
        return None;
    }
    // Dedup the rewritten argument list so a second extension pass (our
    // worklist re-feed; dart-sass extends in a single simultaneous pass)
    // settles instead of appending the same selectors again.
    let mut seen: FxHashSet<String> = FxHashSet::default();
    let rendered: Vec<String> = complexes
        .iter()
        .map(|c| c.render())
        .filter(|r| seen.insert(r.clone()))
        .collect();
    if rendered.len() == original.len()
        && rendered
            .iter()
            .zip(original.iter())
            .all(|(a, b)| *a == b.render())
    {
        return None;
    }
    Some(vec![Simple::Pseudo(format!(
        "{}({})",
        parts.head,
        rendered.join(", ")
    ))])
}

enum PseudoUnwrap {
    /// Keep the complex as-is.
    Keep,
    /// Drop the complex (nested pseudo we can't safely unwrap).
    Drop,
    /// Replace with these inner complex selectors.
    Replace(Vec<Complex>),
}

/// For a single-compound complex whose sole simple is a nested selector-pseudo,
/// decide how `_extendPseudo` should treat it relative to the outer pseudo
/// `outer_name`.
fn single_pseudo_inner(complex: &Complex, outer_name: &str) -> PseudoUnwrap {
    if complex.components.len() != 1 {
        return PseudoUnwrap::Keep;
    }
    let compound = &complex.components[0].compound;
    if compound.simples.len() != 1 {
        return PseudoUnwrap::Keep;
    }
    let Simple::Pseudo(text) = &compound.simples[0] else {
        return PseudoUnwrap::Keep;
    };
    let Some(inner) = parse_pseudo_parts(text) else {
        return PseudoUnwrap::Keep;
    };
    let Some(inner_list) = parse_list(&inner.arg) else {
        return PseudoUnwrap::Keep;
    };
    match unvendor(outer_name) {
        "not" => {
            // `:not(:is(...))` etc. unwraps; other nested pseudos can't be
            // expanded (each layer adds semantics) so the selector is dropped.
            if matches!(unvendor(&inner.name), "is" | "matches" | "where") {
                PseudoUnwrap::Replace(inner_list)
            } else {
                PseudoUnwrap::Drop
            }
        }
        "is" | "matches" | "where" | "any" | "current" | "nth-child" | "nth-last-child" => {
            // The names must match *including* any vendor prefix to merge
            // (`:-ms-matches` and `:-moz-matches` don't combine).
            if inner.name == outer_name {
                PseudoUnwrap::Replace(inner_list)
            } else {
                PseudoUnwrap::Drop
            }
        }
        _ => PseudoUnwrap::Keep,
    }
}

/// Expand selector-pseudo arguments inside a compound in place, returning the
/// effective compound. `:not()` (single-complex arg) contributes extra `:not()`
/// simples merged at the pseudo's position; other matchish pseudos rewrite their
/// argument list. Non-pseudo simples and argument-less pseudos pass through.
fn expand_pseudos_in_compound(compound: &Compound, extensions: &[Extension]) -> Compound {
    let mut simples: Vec<Simple> = Vec::new();
    // A `:not()` expanded from one simple may collide with another `:not()`
    // already present in the compound (e.g. `:not(.c)` extends `.c`→`.b` while a
    // sibling `:not(.b)` is also present). Dedup pseudo simples so the expansion
    // is idempotent and the fixpoint terminates.
    for s in &compound.simples {
        match s {
            Simple::Pseudo(text) => {
                // An UNCHANGED pseudo keeps duplicates (`:baz:baz` is valid
                // CSS). A replacement's products dedup against what's already
                // pushed AND against the other ORIGINAL simples (which the
                // unchanged path will keep verbatim later).
                match extend_pseudo(text, extensions) {
                    None => simples.push(s.clone()),
                    Some(replacement) => {
                        for r in replacement {
                            let dup_of_other_original =
                                r != *s && compound.simples.iter().any(|o| o != s && *o == r);
                            if dup_of_other_original || simples.contains(&r) {
                                continue;
                            }
                            simples.push(r);
                        }
                    }
                }
            }
            other => simples.push(other.clone()),
        }
    }
    Compound { simples }
}

fn extend_component(
    comp: &TComp,
    extensions: &[Extension],
    ext_breaks: &FxHashSet<Complex>,
    order: CartesianOrder,
) -> Option<Vec<(DComplex, bool)>> {
    // First, extend any selector-pseudo arguments (`:not(...)`, `:is(...)`,
    // etc.) in place, producing an "effective" compound. For `:not()` with a
    // single-complex argument this *adds* simples to the compound (dart-sass
    // `_extendPseudo` merges them rather than creating an alternative);
    // matchish pseudos (`:is`/`:matches`/`:where`/...) rewrite their argument
    // list in place. The resulting compound is then run through the normal
    // per-simple extension below.
    let effective = expand_pseudos_in_compound(&comp.compound, extensions);
    // The component changed if a pseudo argument was extended in place (e.g.
    // `:not(.c)` → `:not(.c):not(.a)`) even when no simple has an extender.
    let pseudo_changed = effective.simples != comp.compound.simples;
    let comp = TComp {
        compound: effective,
        combinators: comp.combinators.clone(),
    };
    let comp = &comp;
    let simples = &comp.compound.simples;
    // Per-simple option list: index 0 is "keep self" (None); the rest are
    // (transitively expanded) extender complex selectors targeting this simple.
    let mut per_simple: Vec<Vec<Option<(Complex, bool)>>> = Vec::new();
    let mut any = false;
    for s in simples {
        let mut opts: Vec<Option<(Complex, bool)>> = vec![None];
        let mut seen: FxHashSet<Complex> = FxHashSet::default();
        for extender in collect_extenders(s, extensions, &mut Vec::new()) {
            if seen.contains(&extender) {
                continue;
            }
            // The extender's source line-break flag travels with the option
            // (dart's ComplexSelector.lineBreak).
            let flag = ext_breaks.contains(&extender);
            seen.insert(extender.clone());
            opts.push(Some((extender, flag)));
            any = true;
        }
        per_simple.push(opts);
    }
    // The original component is always the first option (dart-sass keeps it so
    // the rule still matches what it always matched; `_trim` may drop it later
    // for non-originals).
    let options_first = DComplex {
        leading: Vec::new(),
        comps: vec![comp.clone()],
    };
    if !any {
        // No simple has an extender; the component only "changed" if a pseudo
        // argument was rewritten in place.
        return pseudo_changed.then_some(vec![(options_first, false)]);
    }
    let mut options: Vec<(DComplex, bool)> = vec![(options_first, false)];

    // Cartesian product of per-simple choices. The incremental (registration-
    // order) fold varies the FIRST simple slowest (path outer, option inner) —
    // `.foo.bar` + two extends -> `.foo.bar, .foo.bang, .bar.baz, .baz.bang`.
    // dart's one-shot `_extendCompound` uses literal `paths(options)`: the LAST
    // simple varies SLOWEST (option outer, path inner) — the order that unifies
    // `:not(c):not(d)`/`.e.f` rule-after-extends to match dart.
    let mut paths: Vec<Vec<&Option<(Complex, bool)>>> = vec![Vec::new()];
    for opts in &per_simple {
        let mut next = Vec::new();
        if order == CartesianOrder::OneShot {
            for opt in opts {
                for path in &paths {
                    let mut p = path.clone();
                    p.push(opt);
                    next.push(p);
                }
            }
        } else {
            for path in &paths {
                for opt in opts {
                    let mut p = path.clone();
                    p.push(opt);
                    next.push(p);
                }
            }
        }
        paths = next;
        if paths.len() > 100_000 {
            break;
        }
    }

    let mut seen: FxHashSet<String> = FxHashSet::default();
    seen.insert(render_dcomplex(&options[0].0));
    for path in &paths {
        // Skip the all-self path (the original compound, already option 0).
        if path.iter().all(|o| o.is_none()) {
            continue;
        }
        // The option's flag is the OR of the contributing extenders' flags.
        let flag = path.iter().any(|o| matches!(o, Some((_, true))));
        let plain: Vec<Option<Complex>> = path.iter().map(|o| o.as_ref().map(|(c, _)| c.clone())).collect();
        let refs: Vec<&Option<Complex>> = plain.iter().collect();
        for d in build_extended_compound(comp, simples, &refs) {
            let key = render_dcomplex(&d);
            if seen.insert(key) {
                options.push((d, flag));
            }
        }
    }
    Some(options)
}

/// Collect every extender complex selector for `target`, transitively: a direct
/// extender that is itself a target of another extension is expanded into its
/// own extenders too. `stack` guards against extension cycles.
/// Collect the direct extenders registered for `target`, in registration
/// order (dart-sass `_extendSimple` iterates `extensions[simple].values`). This
/// is now a DIRECT lookup: transitivity (an extender that is itself a target)
/// is precomputed by [`expand_extensions`] into the batch the caller passes, so
/// chasing chains here would double-expand. `stack` is unused (kept for the call
/// signature) now that recursion is gone.
fn collect_extenders(target: &Simple, extensions: &[Extension], _stack: &mut Vec<Simple>) -> Vec<Complex> {
    let mut out: Vec<Complex> = Vec::new();
    for ext in extensions {
        let Some(t) = &ext.target else { continue };
        if t != target {
            continue;
        }
        ext.matched.set(true);
        for extender in &ext.extenders {
            out.push(extender.clone());
        }
    }
    out
}

/// Build the extended component sequences for one within-compound product path.
/// `path[i]` is `None` to keep `simples[i]`, or `Some(extender)` to replace it.
/// The self-kept simples form an "original" compound that is unified together
/// with every chosen extender via dart-sass `_unifyExtenders`/`unifyComplex`,
/// which weaves any multi-component extenders (including several at once). The
/// original component's incoming combinator is attached to each result's first
/// component. May return several sequences (one per woven unification).
fn build_extended_compound(comp: &TComp, simples: &[Simple], path: &[&Option<Complex>]) -> Vec<DComplex> {
    // Self-kept simples (originals not being extended) and the chosen extenders.
    let mut base: Vec<Simple> = Vec::new();
    let mut extenders: Vec<&Complex> = Vec::new();
    for (i, choice) in path.iter().enumerate() {
        match choice {
            None => base.push(simples[i].clone()),
            Some(ext) => extenders.push(ext),
        }
    }

    // `_unifyExtenders`: the self-kept base compound (if any) is an "original"
    // selector unified first, then each extender complex.
    let mut to_unify: Vec<DComplex> = Vec::new();
    if !base.is_empty() {
        to_unify.push(DComplex {
            leading: Vec::new(),
            comps: vec![TComp {
                compound: Compound { simples: base },
                combinators: Vec::new(),
            }],
        });
    }
    for ext in &extenders {
        let d = to_dart(ext);
        // dart-sass `_unifyExtenders`: a useless extender fails the whole path.
        if d.is_useless() {
            return Vec::new();
        }
        to_unify.push(d);
    }

    let Some(unified) = unify_complex_list(&to_unify) else {
        return Vec::new();
    };

    // dart-sass: each unified result gets the original component's trailing
    // combinator run appended (`withAdditionalCombinators`); results that
    // become useless are dropped.
    unified
        .into_iter()
        .map(|complex| complex.with_additional_combinators(&comp.combinators))
        .filter(|complex| !complex.is_useless())
        .collect()
}

/// Render a dart-model complex selector to a stable string key (for dedup).
fn render_dcomplex(d: &DComplex) -> String {
    from_dart(d).render()
}

/// Unify a `base` compound with `extra` (the extender's trailing compound),
/// returning the combined compound or `None` if they can't unify. A faithful
/// port of dart-sass `unifyCompound`: start from `base`, then fold each `extra`
/// simple in via `simple_unify`, keeping pseudo-classes after a pseudo-element
/// in `pseudo_result` to preserve their relative order.
fn unify_compounds(base: &[Simple], extra: &[Simple]) -> Option<Vec<Simple>> {
    // A `:host`/`:host-context` pseudo can't share its compound with an
    // incompatible simple (a class, type, universal, ordinary pseudo-class, …),
    // so such a pair can't unify (dart-sass).
    if host_unify_invalid(base, extra) {
        return None;
    }
    let mut result: Vec<Simple> = base.to_vec();
    let mut pseudo_result: Vec<Simple> = Vec::new();
    let mut pseudo_element_found = false;
    for simple in extra {
        if pseudo_element_found && matches!(simple, Simple::Pseudo(_)) {
            pseudo_result = simple_unify(simple, &pseudo_result)?;
        } else {
            if is_pseudo_element(simple) {
                pseudo_element_found = true;
            }
            result = simple_unify(simple, &result)?;
        }
    }
    result.extend(pseudo_result);
    if result.is_empty() {
        return None;
    }
    Some(result)
}

/// Unify a single simple selector into a compound (`SimpleSelector.unify`).
fn simple_unify(this: &Simple, compound: &[Simple]) -> Option<Vec<Simple>> {
    match this {
        Simple::Universal { .. } => match compound.split_first() {
            Some((first @ (Simple::Universal { .. } | Simple::Type(_)), rest)) => {
                let unified = unify_universal_and_element(this, first)?;
                let mut out = vec![unified];
                out.extend_from_slice(rest);
                Some(out)
            }
            None => Some(vec![this.clone()]),
            Some(_) => {
                // A `null` or `*` namespace adds nothing; drop the universal.
                if universal_ns_droppable(this) {
                    Some(compound.to_vec())
                } else {
                    let mut out = vec![this.clone()];
                    out.extend_from_slice(compound);
                    Some(out)
                }
            }
        },
        Simple::Type(_) => match compound.first() {
            Some(first @ (Simple::Universal { .. } | Simple::Type(_))) => {
                let unified = unify_universal_and_element(this, first)?;
                let mut out = vec![unified];
                out.extend_from_slice(&compound[1..]);
                Some(out)
            }
            _ => {
                let mut out = vec![this.clone()];
                out.extend_from_slice(compound);
                Some(out)
            }
        },
        // A pseudo selector inserts before the first pseudo-ELEMENT (so pseudo
        // classes stay ahead of pseudo elements); two distinct pseudo elements
        // can't share a compound.
        Simple::Pseudo(_) => {
            if compound.len() == 1 && matches!(compound[0], Simple::Universal { .. }) {
                return simple_unify(&compound[0], std::slice::from_ref(this));
            }
            if compound.contains(this) {
                return Some(compound.to_vec());
            }
            // A selector-list pseudo (`:is`/`:where`) folding into an all-host
            // compound goes BEFORE the host (`:is(.d):host(.c)`); dart-sass
            // orders `:host`/`:host-context` after the first such wrapper.
            if is_selector_list_pseudo(this) && !compound.is_empty() && compound.iter().all(is_host_pseudo) {
                let mut out = vec![this.clone()];
                out.extend_from_slice(compound);
                return Some(out);
            }
            let this_is_element = is_pseudo_element(this);
            let mut out = Vec::new();
            let mut added = false;
            for s in compound {
                if !added && is_pseudo_element(s) {
                    if this_is_element {
                        // The same pseudo-element (e.g. legacy `:after` ≡
                        // `::after`) already present is kept as-is; two
                        // *different* pseudo-elements can't share a compound.
                        if pseudo_elements_equal(this, s) {
                            return Some(compound.to_vec());
                        }
                        return None;
                    }
                    out.push(this.clone());
                    added = true;
                }
                out.push(s.clone());
            }
            if !added {
                out.push(this.clone());
            }
            Some(out)
        }
        // Class / id / attribute / placeholder: insert before the first pseudo.
        _ => {
            // Two distinct ids can never share a compound: an id won't unify
            // into a compound that already holds a different id (dart-sass
            // IDSelector.unify), so the whole unification fails.
            if let Simple::Id(id) = this {
                if compound
                    .iter()
                    .any(|s| matches!(s, Simple::Id(other) if other != id))
                {
                    return None;
                }
            }
            if compound.len() == 1 && matches!(compound[0], Simple::Universal { .. }) {
                // `other.unify([this])` where other is the universal.
                return simple_unify(&compound[0], std::slice::from_ref(this));
            }
            if compound.contains(this) {
                return Some(compound.to_vec());
            }
            // Insert `this` before the first pseudo selector.
            let mut out = Vec::new();
            let mut added = false;
            for s in compound {
                if !added && matches!(s, Simple::Pseudo(_)) {
                    out.push(this.clone());
                    added = true;
                }
                out.push(s.clone());
            }
            if !added {
                out.push(this.clone());
            }
            Some(out)
        }
    }
}

/// Whether a universal selector contributes nothing to a compound that already
/// has other simples (namespace `null` or `*`).
fn universal_ns_droppable(s: &Simple) -> bool {
    matches!(s, Simple::Universal { ns } if ns.is_none() || ns.as_deref() == Some("*"))
}

/// Unify two universal/type selectors (`unifyUniversalAndElement`). Each is a
/// `(namespace, name)` pair where a universal has `name == None`.
fn unify_universal_and_element(a: &Simple, b: &Simple) -> Option<Simple> {
    let (ns1, name1) = namespace_and_name(a)?;
    let (ns2, name2) = namespace_and_name(b)?;

    let namespace = if ns1 == ns2 || ns2.as_deref() == Some("*") {
        ns1.clone()
    } else if ns1.as_deref() == Some("*") {
        ns2.clone()
    } else {
        return None;
    };

    let name = if name1 == name2 || name2.is_none() {
        name1.clone()
    } else if name1.is_none() || name1.as_deref() == Some("*") {
        name2.clone()
    } else {
        return None;
    };

    Some(match name {
        None => Simple::Universal { ns: namespace },
        Some(n) => match namespace {
            Some(ns) => Simple::Type(format!("{ns}|{n}")),
            None => Simple::Type(n),
        },
    })
}

/// Decompose a universal/type selector into `(namespace, name)`.
fn namespace_and_name(s: &Simple) -> Option<(Option<String>, Option<String>)> {
    match s {
        Simple::Universal { ns } => Some((ns.clone(), None)),
        Simple::Type(t) => {
            let (ns, name) = split_type(t);
            Some((ns, Some(name)))
        }
        _ => None,
    }
}

/// Whether a pseudo selector is a pseudo-element (`::name` or a legacy
/// single-colon pseudo-element).
/// The lowercased base name of a pseudo selector (`:host(.c)` → `"host"`), or
/// `None` for a non-pseudo simple.
fn pseudo_base(s: &Simple) -> Option<String> {
    let Simple::Pseudo(text) = s else {
        return None;
    };
    let name = text.trim_start_matches(':');
    Some(name.split(['(', ' ']).next().unwrap_or(name).to_ascii_lowercase())
}

/// Whether two pseudo-elements are the same selector, treating a legacy
/// single-colon form as equal to its double-colon form (`:after` ≡ `::after`).
fn pseudo_elements_equal(a: &Simple, b: &Simple) -> bool {
    match (a, b) {
        (Simple::Pseudo(ta), Simple::Pseudo(tb)) => {
            let norm = |t: &str| format!("::{}", t.trim_start_matches(':'));
            norm(ta) == norm(tb)
        }
        _ => false,
    }
}

/// Whether `s` is a `:host` / `:host-context` pseudo.
fn is_host_pseudo(s: &Simple) -> bool {
    matches!(pseudo_base(s).as_deref(), Some("host" | "host-context"))
}

/// Whether `s` is a selector-list pseudo (`:is`/`:where`/`:matches`/`:any`/
/// `:-*-any`) that wraps a selector list.
fn is_selector_list_pseudo(s: &Simple) -> bool {
    matches!(
        pseudo_base(s).as_deref(),
        Some("is" | "where" | "matches" | "any" | "-moz-any" | "-webkit-any")
    )
}

/// Whether a simple selector may share a compound with a `:host` /
/// `:host-context` pseudo: only other host pseudos, the selector-list pseudos
/// (`:is`/`:where`/`:matches`/`:any`/`:-*-any`), or pseudo-elements — never a
/// type/class/id/universal/attribute or an ordinary pseudo-class.
fn host_compatible(s: &Simple) -> bool {
    is_host_pseudo(s) || is_pseudo_element(s) || is_selector_list_pseudo(s)
}

/// Whether unifying `base` and `extra` would put a `:host`/`:host-context`
/// pseudo in a compound with a simple it can't combine with (checked across
/// both inputs, before a universal selector is dropped).
fn host_unify_invalid(base: &[Simple], extra: &[Simple]) -> bool {
    let all = || base.iter().chain(extra);
    all().any(is_host_pseudo) && all().any(|s| !host_compatible(s))
}

fn is_pseudo_element(s: &Simple) -> bool {
    let Simple::Pseudo(text) = s else {
        return false;
    };
    if text.starts_with("::") {
        return true;
    }
    // Legacy single-colon pseudo-elements.
    let name = text.trim_start_matches(':');
    let base = name.split(['(', ' ']).next().unwrap_or(name).to_ascii_lowercase();
    matches!(base.as_str(), "before" | "after" | "first-line" | "first-letter")
}

// ---- public helpers for the `sass:selector` builtin family -------------
//
// These are thin, additive re-exports of the engine internals above. They add
// no new behavior to the `@extend` directive path; they only expose the
// algorithms (superselector test, compound/complex unification, parent
// weaving) to `crate::builtins::selector`.

/// Whether selector list `sup` is a superselector of `sub`: every complex in
/// `sub` must be matched by some complex in `sup` (dart-sass `listIsSuperselector`).
pub(crate) fn list_is_superselector(sup: &[Complex], sub: &[Complex]) -> bool {
    sub.iter()
        .all(|c2| sup.iter().any(|c1| complex_is_superselector(c1, c2)))
}

/// Unify two complex selectors into the (possibly several) complex selectors
/// they jointly match, or `None` if they can't unify (dart-sass `unifyComplex`
/// for the two-selector case).
pub(crate) fn unify_complex(c1: &Complex, c2: &Complex) -> Option<Vec<Complex>> {
    let unified = unify_complex_list(&[to_dart(c1), to_dart(c2)])?;
    let mut out = Vec::new();
    let mut seen = FxHashSet::default();
    for d in unified {
        let complex = from_dart(&d);
        if seen.insert(complex.render()) {
            out.push(complex);
        }
    }
    if out.is_empty() {
        return None;
    }
    Some(out)
}

/// A faithful port of dart-sass `unifyComplex`: the contents of a selector list
/// matching only elements matched by every complex in `complexes`, or `None`
/// if no such list can be produced. All final compounds are unified into a
/// single base (with at most one shared leading and trailing combinator); the
/// remaining parent components are woven together.
fn unify_complex_list(complexes: &[DComplex]) -> Option<Vec<DComplex>> {
    if complexes.is_empty() {
        return None;
    }
    if complexes.len() == 1 {
        return Some(complexes.to_vec());
    }

    let mut unified_base: Option<Vec<Simple>> = None;
    let mut leading_combinator: Option<Combinator> = None;
    let mut trailing_combinator: Option<Combinator> = None;
    for complex in complexes {
        if complex.is_useless() {
            return None;
        }

        // A single-component complex with exactly one leading combinator
        // contributes it to the unified base; two different ones can't unify.
        if complex.comps.len() == 1 {
            if let [new_leading] = complex.leading.as_slice() {
                match leading_combinator {
                    None => leading_combinator = Some(*new_leading),
                    Some(lc) if lc != *new_leading => return None,
                    _ => {}
                }
            }
        }

        let base = complex.comps.last()?;
        if let [new_trailing] = base.combinators.as_slice() {
            if trailing_combinator.is_some_and(|tc| tc != *new_trailing) {
                return None;
            }
            trailing_combinator = Some(*new_trailing);
        }

        match &mut unified_base {
            None => unified_base = Some(base.compound.simples.clone()),
            Some(acc) => *acc = unify_compounds(acc, &base.compound.simples)?,
        }
    }

    // Each multi-component complex minus its base, keeping its own leading run
    // and the combinator that joined the (removed) base.
    let without_bases: Vec<DComplex> = complexes
        .iter()
        .filter(|c| c.comps.len() > 1)
        .map(|c| DComplex {
            leading: c.leading.clone(),
            comps: c.comps[..c.comps.len() - 1].to_vec(),
        })
        .collect();

    let base = DComplex {
        leading: leading_combinator.into_iter().collect(),
        comps: vec![TComp {
            compound: Compound {
                simples: unified_base?,
            },
            combinators: trailing_combinator.into_iter().collect(),
        }],
    };

    let path: Vec<DComplex> = match without_bases.split_last() {
        None => vec![base],
        Some((last, init)) => {
            let mut path = init.to_vec();
            path.push(last.concatenate(&base));
            path
        }
    };

    let woven = weave(&path);
    if woven.is_empty() {
        None
    } else {
        Some(woven)
    }
}

/// Unify two selector lists: the cartesian product of `unify_complex` over each
/// pair of complex selectors, dropping pairs that don't unify (dart-sass
/// `SelectorList.unify`). Returns `None` if nothing unifies.
pub(crate) fn unify_lists(list1: &[Complex], list2: &[Complex]) -> Option<Vec<Complex>> {
    let mut out = Vec::new();
    let mut seen = FxHashSet::default();
    for c1 in list1 {
        for c2 in list2 {
            if let Some(unified) = unify_complex(c1, c2) {
                for c in unified {
                    if seen.insert(c.render()) {
                        out.push(c);
                    }
                }
            }
        }
    }
    if out.is_empty() {
        return None;
    }
    Some(out)
}

/// Render a complex selector as the items of a Sass space-separated list:
/// compound strings interleaved with combinator strings (`>`/`+`/`~`), matching
/// dart-sass's `ComplexSelector.asSassList`.
pub(crate) fn complex_to_list_parts(c: &Complex) -> Vec<String> {
    let mut parts = Vec::new();
    for comp in &c.components {
        for comb in &comp.combinators {
            parts.push(comb.as_str().to_string());
        }
        parts.push(comp.compound.render());
    }
    for comb in &c.trailing {
        parts.push(comb.as_str().to_string());
    }
    parts
}

/// Parse a single compound selector (no combinators, no commas). Returns the
/// list of simple-selector strings, or `None` if the text isn't a single valid
/// compound (dart-sass `simple-selectors` parses a `CompoundSelector`).
pub(crate) fn parse_compound_simples(s: &str) -> Option<Vec<String>> {
    let chars: Vec<char> = s.trim().chars().collect();
    let mut i = 0;
    let compound = parse_compound(&chars, &mut i)?;
    skip_ws(&chars, &mut i);
    if i != chars.len() {
        return None; // trailing combinator / second compound / garbage
    }
    Some(compound.simples.iter().map(Simple::render).collect())
}

/// Extend a selector list against one or more *compound* targets (used by the
/// `selector-extend` / `selector-replace` builtins, which — unlike the
/// `@extend` directive — allow a multi-simple compound extendee, and also a
/// list of such compounds). Wherever a `target` compound is a subselector of a
/// component's compound, the `extender` selectors are woven in. With `replace`
/// true the matched original is dropped (`selector-replace`); otherwise it is
/// kept (`selector-extend`). This mirrors dart-sass `_extendComplex`/
/// `_extendCompound`: every target is applied simultaneously, and freshly
/// produced selectors are re-extended to a fixpoint so a selector matching two
/// targets collapses correctly (e.g. extending `c.d` by `c, .d` with `.e`).
pub(crate) fn extend_compound_target(
    selectors: &[Complex],
    targets: &[Compound],
    extenders: &[Complex],
    replace: bool,
) -> Vec<Complex> {
    reset_extend_budget();
    // Originals are never trimmed away (dart-sass keeps the input selectors so a
    // rule still matches what it always matched). In replace mode the matched
    // originals are dropped before this point, so the set is the surviving ones.
    let mut originals: FxHashSet<Complex> = FxHashSet::default();
    if !replace {
        for complex in selectors {
            originals.insert(complex.clone());
        }
    }

    let mut result: Vec<Complex> = Vec::new();
    let mut seen: FxHashSet<String> = FxHashSet::default();
    // Each input complex is extended independently and its results emitted
    // consecutively (dart-sass groups a selector's extensions right after it),
    // so the per-complex fixpoint stays local to its input.
    for complex in selectors {
        // Worklist so that a selector produced by one target can itself be
        // re-extended by another target (dart-sass applies all extensions
        // simultaneously). Bounded to guarantee termination.
        let mut queue: std::collections::VecDeque<Complex> = std::collections::VecDeque::new();
        queue.push_back(complex.clone());
        let mut local_seen: FxHashSet<String> = FxHashSet::default();
        // dart `_extendComplex` promotes the FIRST product of extending an
        // original input complex to an original itself (extension_store.dart
        // `if (first && _originals.contains(complex)) _originals.add(output)`).
        // dart extends every target simultaneously, so that first product is the
        // FULLY-replaced selector. Our worklist replaces one target per step, so
        // the fully-replaced selector is the first one that extends to only
        // itself (`is_self_only` — no target left to replace). In replace mode
        // that terminal selector is the original that must survive `_trim`, so
        // `selector.replace((c, d c), c, e)` keeps `d e` (the bare `e` from
        // input `c` would otherwise trim it) while `replace("c.d", "c, .d", .e)`
        // still collapses to `.e` (the intermediate `.d.e` is NOT promoted).
        // Non-replace mode keeps the unchanged input as its first product
        // (already in `originals`), so the promotion is needed only for replace.
        let mut promote_first = replace;
        while let Some(cur) = queue.pop_front() {
            if !consume_extend_work() || result.len() > 100_000 {
                break;
            }
            let cur_rendered = cur.render();
            let extended = extend_complex_compound(&cur, targets, extenders, replace);
            // Whether this complex produced anything other than itself: only
            // then do we re-feed the new selectors (re-feeding an unchanged
            // selector would loop forever).
            let is_self_only = extended.len() == 1
                && extended.first().map(Complex::render).as_deref() == Some(cur_rendered.as_str());
            for c in extended {
                let rendered = c.render();
                // Promote the first FULLY-replaced product of this input to an
                // original (dart `_extendComplex` line 630). A product is fully
                // replaced once no target remains — i.e. re-extending it yields
                // only itself. Checked structurally here (not via the re-feed
                // worklist) because a terminal product can be redundant and thus
                // never re-fed: in `replace((c, d c), c, e)`, `d e` is covered
                // by the sibling `e` so it is not re-fed, yet must be promoted so
                // `_trim` keeps it.
                if promote_first {
                    let re = extend_complex_compound(&c, targets, extenders, replace);
                    let terminal = re.len() == 1
                        && re.first().map(Complex::render).as_deref() == Some(rendered.as_str());
                    if terminal {
                        originals.insert(c.clone());
                        promote_first = false;
                    }
                }
                // A selector already covered by a previously-produced one is
                // redundant; it is trimmed from the output and, crucially, must
                // not be re-fed — a self-referential extender (`.x` -> `.x .y`)
                // would otherwise grow `.x .y .y …` without bound. dart-sass
                // trims during its fixpoint. Checked before `c` joins `result`.
                let redundant = result.iter().any(|r| complex_is_superselector(r, &c));
                if !is_self_only
                    && rendered != cur_rendered
                    && !redundant
                    && rendered.len() <= EXTEND_REFEED_MAX_LEN
                    && local_seen.insert(rendered.clone())
                {
                    queue.push_back(c.clone());
                }
                if seen.insert(rendered) {
                    result.push(c);
                }
            }
        }
    }
    // Drop selectors made redundant by a superselector elsewhere in the list
    // (dart-sass `_trim`), keeping originals. The one-off builtin store never
    // fills `_sourceSpecificity` (only `@extend`'s addExtension does), so
    // every max-specificity here is 0 and plain superselector coverage trims.
    let source_spec: FxHashMap<Simple, u64> = FxHashMap::default();
    trim(
        result
            .into_iter()
            .map(|c| {
                let o = originals.contains(&c);
                (c, o)
            })
            .collect(),
        &source_spec,
    )
}

/// Extend one complex selector against one or more compound targets: compute
/// each component's options (original first unless replaced), take the Cartesian
/// product, and `weave` each path — the same shape as `extend_complex`.
fn extend_complex_compound(
    complex: &Complex,
    targets: &[Compound],
    extenders: &[Complex],
    replace: bool,
) -> Vec<Complex> {
    let d = to_dart(complex);
    // dart-sass: a complex selector with more than one leading combinator is
    // never extended (the caller keeps the original).
    if d.leading.len() > 1 {
        return vec![complex.clone()];
    }

    let mut per_component: Vec<Vec<DComplex>> = Vec::new();
    let mut any_extended = false;
    for (i, comp) in d.comps.iter().enumerate() {
        match extend_component_compound(comp, targets, extenders, replace) {
            None => per_component.push(vec![DComplex {
                leading: if i == 0 { d.leading.clone() } else { Vec::new() },
                comps: vec![comp.clone()],
            }]),
            Some(extended) => {
                any_extended = true;
                if i == 0 && !d.leading.is_empty() {
                    // dart-sass: a first-component extension must have no
                    // leading combinators (or the same ones); the complex's own
                    // leading run is then re-attached.
                    per_component.push(
                        extended
                            .into_iter()
                            .filter(|n| n.leading.is_empty() || n.leading == d.leading)
                            .map(|n| DComplex {
                                leading: d.leading.clone(),
                                comps: n.comps,
                            })
                            .collect(),
                    );
                } else {
                    per_component.push(extended);
                }
            }
        }
    }
    if !any_extended {
        return vec![complex.clone()];
    }

    // dart-sass `paths`: for each component's options, the *option* is the outer
    // loop and the accumulated paths the inner loop, so the first component's
    // choice varies fastest in the output order.
    let mut combos: Vec<Vec<DComplex>> = vec![Vec::new()];
    for opts in &per_component {
        let mut next: Vec<Vec<DComplex>> = Vec::new();
        for opt in opts {
            for combo in &combos {
                let mut c = combo.clone();
                c.push(opt.clone());
                next.push(c);
            }
        }
        combos = next;
        if combos.len() > 100_000 {
            break;
        }
    }

    let mut out = Vec::new();
    let mut seen = FxHashSet::default();
    for path in combos {
        for woven in weave(&path) {
            let c = from_dart(&woven);
            let r = c.render();
            if seen.insert(r) {
                out.push(c);
            }
        }
    }
    out
}

/// Options for one component against a compound target. The original component
/// is option 0 in extend mode (and in replace mode when it does not match);
/// each matching extender contributes the woven replacement.
fn extend_component_compound(
    comp: &TComp,
    targets: &[Compound],
    extenders: &[Complex],
    replace: bool,
) -> Option<Vec<DComplex>> {
    // First extend any selector-pseudo arguments (`:is(...)`, `:not(...)`, …)
    // in place, producing an "effective" compound that the per-compound
    // extension below then runs against.
    let effective = expand_pseudos_compound_target(&comp.compound, targets, extenders, replace);
    let pseudo_changed = effective.simples != comp.compound.simples;
    let comp = TComp {
        compound: effective,
        combinators: comp.combinators.clone(),
    };
    let comp = &comp;
    // The original component (as a one-component complex), keeping its
    // trailing combinator run.
    let original = DComplex {
        leading: Vec::new(),
        comps: vec![comp.clone()],
    };
    // Targets whose compound is a subselector of this component's compound: each
    // matching target contributes its own woven extensions (dart-sass applies
    // every extension simultaneously).
    let matching: Vec<&Compound> = targets
        .iter()
        .filter(|t| compound_is_superselector(t, &comp.compound, &[]))
        .collect();
    if matching.is_empty() {
        return pseudo_changed.then_some(vec![original]);
    }

    let mut options: Vec<DComplex> = Vec::new();
    if !replace {
        options.push(original);
    }
    let mut seen: FxHashSet<String> = FxHashSet::default();
    for target in matching {
        // The simples of this compound not covered by this target.
        let remaining: Vec<Simple> = comp
            .compound
            .simples
            .iter()
            .filter(|s| !target.simples.contains(s))
            .cloned()
            .collect();
        for ext in extenders {
            let ext_d = to_dart(ext);
            if ext_d.is_useless() {
                continue;
            }
            let Some((last, parents)) = ext_d.comps.split_last() else {
                // A combinator-only extender (`>`): when it replaces the whole
                // compound, the extension is the extender itself plus the
                // component's trailing run (dart-sass's single-simple shortcut;
                // with leftover simples dart-sass errors — we skip instead).
                if remaining.is_empty() {
                    let candidate = ext_d.clone().with_additional_combinators(&comp.combinators);
                    if !candidate.is_useless() && seen.insert(render_dcomplex(&candidate)) {
                        options.push(candidate);
                    }
                }
                continue;
            };
            let Some(unified) = unify_compounds(&remaining, &last.compound.simples) else {
                continue;
            };
            // The extender's parent components, then the unified trailing
            // compound keeping the extender's own trailing run; the original
            // component's trailing run is appended after that (dart-sass
            // `withAdditionalCombinators`).
            let mut comps = parents.to_vec();
            comps.push(TComp {
                compound: Compound { simples: unified },
                combinators: last.combinators.clone(),
            });
            let candidate = DComplex {
                leading: ext_d.leading.clone(),
                comps,
            }
            .with_additional_combinators(&comp.combinators);
            if candidate.is_useless() {
                continue;
            }
            let key = render_dcomplex(&candidate);
            if seen.insert(key) {
                options.push(candidate);
            }
        }
    }
    if options.is_empty() {
        // Replace mode with no successful unification: keep the original so the
        // selector isn't silently dropped (dart-sass leaves an unmatched
        // component intact).
        options.push(DComplex {
            leading: Vec::new(),
            comps: vec![comp.clone()],
        });
    }
    Some(options)
}

/// Whether any compound in `s` contains `target` as one of its simple
/// selectors (used to satisfy `@extend` target lookup against rules whose
/// bogus combinators omitted them from the CSS).
pub(crate) fn selector_contains_simple(s: &str, target: &Simple) -> bool {
    for part in split_top(s, ',') {
        if let Some(complex) = parse_complex(part.trim()) {
            for comp in &complex.components {
                if comp.compound.simples.iter().any(|x| x == target) {
                    return true;
                }
            }
        }
    }
    false
}

// ---- specificity (dart SimpleSelector/ComplexSelector.specificity) -----

/// dart `SimpleSelector.specificity`: classes/attributes/placeholders and
/// plain pseudo-classes weigh 1000, IDs weigh 1000², types 1, universal 0.
/// `:where()` is 0; selector-argument pseudos (`:is`/`:not`/`:matches`/
/// `:has`…) take the max of their argument complexes.
fn simple_specificity(s: &Simple) -> u64 {
    match s {
        Simple::Universal { .. } => 0,
        Simple::Type(t) => {
            // `ns|*` renders as a Type carrying `*`; the universal part is 0.
            if t.ends_with('*') {
                0
            } else {
                1
            }
        }
        Simple::Id(_) => 1_000_000,
        Simple::Class(_) | Simple::Placeholder(_) | Simple::Attribute(_) => 1000,
        Simple::Pseudo(text) => pseudo_specificity(text),
    }
}

fn pseudo_specificity(text: &str) -> u64 {
    let is_element = text.starts_with("::");
    let body = text.trim_start_matches(':');
    let (name, arg) = match body.split_once('(') {
        Some((n, rest)) => (n.to_ascii_lowercase(), Some(rest.trim_end_matches(')'))),
        None => (body.to_ascii_lowercase(), None),
    };
    let base = unvendor(&name).to_string();
    if base == "where" {
        return 0;
    }
    if let Some(arg) = arg {
        let selectorish =
            matches!(base.as_str(), "is" | "matches" | "any" | "not" | "has") || base.ends_with("-any");
        if selectorish {
            if let Some(list) = parse_list(arg) {
                return list.iter().map(complex_specificity).max().unwrap_or(0);
            }
        }
    }
    if is_element {
        1
    } else {
        1000
    }
}

fn compound_specificity(c: &Compound) -> u64 {
    c.simples.iter().map(simple_specificity).sum()
}

/// dart `ComplexSelector.specificity`: the sum of its compounds'.
pub(crate) fn complex_specificity(c: &Complex) -> u64 {
    c.components
        .iter()
        .map(|comp| compound_specificity(&comp.compound))
        .sum()
}

/// All simple selectors in a complex, recursing into selector-argument
/// pseudos (dart `_simpleSelectors`).
fn all_simples_of(complex: &Complex, out: &mut Vec<Simple>) {
    for comp in &complex.components {
        for s in &comp.compound.simples {
            out.push(s.clone());
            if let Simple::Pseudo(text) = s {
                if let Some(open) = text.find('(') {
                    if text.ends_with(')') {
                        if let Some(list) = parse_list(&text[open + 1..text.len() - 1]) {
                            for inner in &list {
                                all_simples_of(inner, out);
                            }
                        }
                    }
                }
            }
        }
    }
}

/// Build dart's `_sourceSpecificity` map: every simple selector of every
/// extender records (first write wins) its complex's specificity.
pub(crate) fn source_specificity_map(extensions: &[Extension]) -> FxHashMap<Simple, u64> {
    let mut map: FxHashMap<Simple, u64> = FxHashMap::default();
    for ext in extensions {
        for complex in &ext.extenders {
            let spec = complex_specificity(complex);
            let mut simples = Vec::new();
            all_simples_of(complex, &mut simples);
            for s in simples {
                map.entry(s).or_insert(spec);
            }
        }
    }
    map
}

#[cfg(test)]
mod compress_tests {
    use super::{compress_selector, escape_end};

    #[test]
    fn an_escape_is_one_token() {
        // `\` plus up to six hex digits plus the one whitespace that closes
        // them; anything else is `\` plus exactly one character.
        let chars = |s: &str| s.chars().collect::<Vec<char>>();
        assert_eq!(escape_end(&chars(r"\31 a"), 0), 4); // digits + terminator
        assert_eq!(escape_end(&chars(r"\31a"), 0), 4); // three hex digits
        assert_eq!(escape_end(&chars(r"\100000 x"), 0), 8); // six, then the space
        assert_eq!(escape_end(&chars(r"\1000000"), 0), 7); // seven digits: six taken
        assert_eq!(escape_end(&chars(r"\,b"), 0), 2); // not hex: one character
        assert_eq!(escape_end(&chars(r"\ b"), 0), 2); // an escaped space
        assert_eq!(escape_end(&chars(r"\"), 0), 1); // nothing follows
        assert_eq!(escape_end(&chars("\\31\r\nx"), 0), 5); // CRLF is one terminator
    }

    #[test]
    fn only_structural_whitespace_goes() {
        let c = |s: &str| compress_selector(s).into_owned();
        assert_eq!(c(".a > .b"), ".a>.b");
        assert_eq!(c(".a  >  .b"), ".a>.b");
        assert_eq!(c(".a .b"), ".a .b");
        assert_eq!(c(":has(+ .b)"), ":has(+.b)");
        assert_eq!(c(":not(.b, .c)"), ":not(.b,.c)");
        assert_eq!(c(":lang(en, fr)"), ":lang(en, fr)");
        assert_eq!(c(r".\31  > .b"), r".\31 >.b");
        assert_eq!(c(r":not(.\31 , .b)"), r":not(.\31 ,.b)");
        assert_eq!(c(r#"[a="x > y"]"#), r#"[a="x > y"]"#);
        // A selector with nothing to compress is borrowed, not rebuilt.
        assert!(matches!(
            compress_selector(".a .b"),
            std::borrow::Cow::Borrowed(_)
        ));
    }
}
