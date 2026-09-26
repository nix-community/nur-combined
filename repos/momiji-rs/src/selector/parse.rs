//! The selector-string parser: turns an already-resolved selector string (after
//! `&`/interpolation substitution) into the structured [`Complex`]/[`Compound`]/
//! [`Simple`] model the `@extend` engine in [`super`] operates on. Pure parsing,
//! no extend logic.

use super::*;

// ---- parsing -----------------------------------------------------------

/// Parse a selector-list string (already `&`/interpolation-resolved) into
/// complex selectors. Returns `None` if anything is unparseable (the caller
/// then falls back to leaving the selector untouched).
pub(crate) fn parse_list(sel: &str) -> Option<Vec<Complex>> {
    let mut out = Vec::new();
    for part in split_top(sel, ',') {
        let part = part.trim();
        if part.is_empty() {
            continue;
        }
        out.push(parse_complex(part)?);
    }
    if out.is_empty() {
        return None;
    }
    Some(out)
}

/// Parse a single complex selector.
pub(super) fn parse_complex(s: &str) -> Option<Complex> {
    let chars: Vec<char> = s.chars().collect();
    let mut components = Vec::new();
    let mut i = 0;
    // The run of combinators seen since the last compound. dart-sass preserves a
    // run of more than one (`c > > d`) and a leading run (`~ ~ c`).
    let mut pending: Vec<Combinator> = Vec::new();
    loop {
        skip_ws(&chars, &mut i);
        if i >= chars.len() {
            break;
        }
        // A combinator (a run of them is collected, not just the last).
        let combinator = match chars[i] {
            '>' => Some(Combinator::Child),
            '+' => Some(Combinator::NextSibling),
            '~' => Some(Combinator::FollowingSibling),
            _ => None,
        };
        if let Some(c) = combinator {
            pending.push(c);
            i += 1;
            continue;
        }
        let compound = parse_compound(&chars, &mut i)?;
        components.push(ComplexComponent {
            combinators: std::mem::take(&mut pending),
            compound,
        });
    }
    // A trailing combinator run (`c >`, `c + >`) or a combinator-only selector
    // (`>`) is preserved in `trailing`. A truly empty complex is unparseable.
    if components.is_empty() && pending.is_empty() {
        return None;
    }
    Some(Complex {
        components,
        trailing: pending,
    })
}

/// Parse one compound selector starting at `*i`, advancing `*i` past it.
pub(super) fn parse_compound(chars: &[char], i: &mut usize) -> Option<Compound> {
    let mut simples = Vec::new();
    while *i < chars.len() {
        let c = chars[*i];
        match c {
            ' ' | '\t' | '\n' | '\r' | '>' | '+' | '~' | ',' => break,
            '.' => {
                *i += 1;
                let name = read_ident(chars, i)?;
                simples.push(Simple::Class(name));
            }
            '#' => {
                *i += 1;
                let name = read_ident(chars, i)?;
                simples.push(Simple::Id(name));
            }
            '%' => {
                *i += 1;
                let name = read_ident(chars, i)?;
                simples.push(Simple::Placeholder(name));
            }
            '[' => {
                let text = read_bracketed(chars, i)?;
                simples.push(Simple::Attribute(normalize_attribute(&text)));
            }
            ':' => {
                let text = read_pseudo(chars, i)?;
                // Canonicalize a `:nth-child`/`:nth-last-child` An+B argument so
                // comparisons and output match dart-sass (`2n + 1` → `2n+1`).
                let text = normalize_nth(&text).unwrap_or(text);
                // Re-serialize a selector-argument pseudo canonically (its
                // attributes/inner pseudos normalize recursively, so
                // `:not([a = b])` and `:not([a=b])` compare equal).
                let text = normalize_pseudo_arg(&text).unwrap_or(text);
                simples.push(Simple::Pseudo(text));
            }
            '*' => {
                *i += 1;
                // `*|...` uses `*` as a namespace prefix.
                if *i < chars.len() && chars[*i] == '|' && chars.get(*i + 1) != Some(&'=') {
                    *i += 1;
                    match read_type_after_ns(chars, i)? {
                        // `*|*`
                        Simple::Universal { .. } => simples.push(Simple::Universal {
                            ns: Some("*".to_string()),
                        }),
                        // `*|type`
                        Simple::Type(t) => simples.push(Simple::Type(format!("*|{t}"))),
                        other => simples.push(other),
                    }
                } else {
                    simples.push(Simple::Universal { ns: None });
                }
            }
            '|' => {
                // A leading `|` is the *empty* namespace: `|c`, `|*`.
                *i += 1;
                match read_type_after_ns(chars, i)? {
                    Simple::Universal { .. } => simples.push(Simple::Universal {
                        ns: Some(String::new()),
                    }),
                    Simple::Type(t) => simples.push(Simple::Type(format!("|{t}"))),
                    other => simples.push(other),
                }
            }
            _ if is_ident_start(c) || c == '\\' => {
                let (name, is_ns) = read_type_or_ns(chars, i)?;
                if is_ns {
                    let after = read_type_after_ns(chars, i)?;
                    // prepend namespace to the rendered text
                    match after {
                        Simple::Universal { .. } => simples.push(Simple::Universal { ns: Some(name) }),
                        Simple::Type(t) => simples.push(Simple::Type(format!("{name}|{t}"))),
                        other => simples.push(other),
                    }
                } else {
                    simples.push(Simple::Type(name));
                }
            }
            _ => return None,
        }
    }
    if simples.is_empty() {
        return None;
    }
    Some(Compound { simples })
}

/// Read a type selector or a namespace prefix. Returns `(text, is_namespace)`
/// where `is_namespace` is true when the next char is `|` (not `|=`).
fn read_type_or_ns(chars: &[char], i: &mut usize) -> Option<(String, bool)> {
    let name = read_ident(chars, i)?;
    if *i < chars.len() && chars[*i] == '|' && chars.get(*i + 1) != Some(&'=') {
        *i += 1; // consume '|'
        Some((name, true))
    } else {
        Some((name, false))
    }
}

/// After a namespace `ns|`, read either `*` or a type name.
fn read_type_after_ns(chars: &[char], i: &mut usize) -> Option<Simple> {
    if *i < chars.len() && chars[*i] == '*' {
        *i += 1;
        return Some(Simple::Universal { ns: None });
    }
    let t = read_ident(chars, i)?;
    Some(Simple::Type(t))
}

/// Decode a CSS identifier's `\` escapes to their literal characters, then
/// re-serialize it in dart-sass's canonical escape form (its `_writeIdentifier`).
/// A plain ASCII identifier with no escapes round-trips unchanged.
pub(crate) fn canonicalize_ident(raw: &str) -> String {
    if !raw.contains('\\') {
        return raw.to_string();
    }
    // ---- decode ----
    let chars: Vec<char> = raw.chars().collect();
    let mut decoded: Vec<char> = Vec::with_capacity(chars.len());
    let mut i = 0;
    while i < chars.len() {
        if chars[i] == '\\' {
            i += 1;
            if i >= chars.len() {
                // A trailing lone backslash decodes to U+FFFD per CSS.
                decoded.push('\u{FFFD}');
                break;
            }
            if chars[i].is_ascii_hexdigit() {
                let mut hex = String::new();
                let mut digits = 0;
                while digits < 6 && i < chars.len() && chars[i].is_ascii_hexdigit() {
                    hex.push(chars[i]);
                    i += 1;
                    digits += 1;
                }
                // One optional trailing whitespace terminates the escape.
                if i < chars.len() && chars[i].is_whitespace() {
                    i += 1;
                }
                let cp = u32::from_str_radix(&hex, 16).unwrap_or(0);
                // U+0000 and out-of-range/surrogate code points map to U+FFFD.
                let ch = if cp == 0 {
                    '\u{FFFD}'
                } else {
                    char::from_u32(cp).unwrap_or('\u{FFFD}')
                };
                decoded.push(ch);
            } else {
                decoded.push(chars[i]);
                i += 1;
            }
        } else {
            decoded.push(chars[i]);
            i += 1;
        }
    }
    // ---- re-serialize (dart-sass `_writeIdentifier`) ----
    let mut out = String::new();
    let first_is_hyphen = decoded.first() == Some(&'-');
    for (idx, &c) in decoded.iter().enumerate() {
        let cu = c as u32;
        let needs_hex = cu < 0x20
            || cu == 0x7F
            || (idx == 0 && c.is_ascii_digit())
            || (idx == 1 && c.is_ascii_digit() && first_is_hyphen);
        if needs_hex {
            out.push('\\');
            out.push_str(&format!("{cu:x}"));
            // dart-sass always terminates a numeric escape with a single space
            // so it can never be misread as continuing into the next character.
            out.push(' ');
        } else if c == '_' || c == '-' || c.is_ascii_alphanumeric() || cu >= 0x80 {
            out.push(c);
        } else {
            out.push('\\');
            out.push(c);
        }
    }
    out
}

fn read_ident(chars: &[char], i: &mut usize) -> Option<String> {
    let start = *i;
    let mut s = String::new();
    let mut saw_escape = false;
    while *i < chars.len() {
        let c = chars[*i];
        if c == '\\' {
            // A hex escape consumes up to six digits PLUS one optional
            // trailing whitespace — `\02e foo` is the single identifier
            // `\.foo`, not two compounds.
            saw_escape = true;
            s.push(c);
            *i += 1;
            if *i < chars.len() && chars[*i].is_ascii_hexdigit() {
                let mut digits = 0;
                while digits < 6 && *i < chars.len() && chars[*i].is_ascii_hexdigit() {
                    s.push(chars[*i]);
                    *i += 1;
                    digits += 1;
                }
                if *i < chars.len() && chars[*i].is_whitespace() {
                    s.push(chars[*i]);
                    *i += 1;
                }
            } else if *i < chars.len() {
                s.push(chars[*i]);
                *i += 1;
            }
            continue;
        }
        if is_ident_char(c) {
            s.push(c);
            *i += 1;
        } else {
            break;
        }
    }
    if *i == start {
        return None;
    }
    // Canonicalize the escape spelling so `\2E foo`, `\02e foo`, and `\.foo`
    // all compare (and extend-match) equal.
    if saw_escape {
        s = canonicalize_ident(&s);
    }
    Some(s)
}

/// Whether `c` is CSS whitespace — the five code points CSS counts, which is
/// NOT `char::is_whitespace()`: that also matches NBSP and the other Unicode
/// spaces, and eating one of those as an escape's delimiter would delete a
/// character the value is supposed to keep.
fn is_css_whitespace(c: char) -> bool {
    matches!(c, ' ' | '\t' | '\n' | '\r' | '\u{c}')
}

/// Decode the CSS escapes in an attribute selector's quoted value, the way
/// dart's parser does before the serializer re-escapes it: `\22 ` is a `"`,
/// `\61 bc` is `abc`, and `\<char>` is that character.
///
/// Two details the spec is picky about. A hex escape takes up to six digits and
/// then swallows ONE trailing whitespace as its delimiter — a CRLF counting as
/// that one, not as two. And a backslash before a newline is a line
/// continuation inside a string, contributing nothing, where "newline" again
/// means LF, CR, CRLF or form feed.
fn decode_css_escapes(raw: &str) -> String {
    if !raw.contains('\\') {
        return raw.to_string();
    }
    let cs: Vec<char> = raw.chars().collect();
    let mut out = String::with_capacity(raw.len());
    let mut i = 0;
    while i < cs.len() {
        if cs[i] != '\\' || i + 1 >= cs.len() {
            out.push(cs[i]);
            i += 1;
            continue;
        }
        i += 1; // the backslash
        if !cs[i].is_ascii_hexdigit() {
            // `\<char>` is that character, EXCEPT a newline: that is a line
            // continuation inside a string and contributes nothing. CRLF is
            // one newline, so it consumes both.
            match cs[i] {
                '\r' if cs.get(i + 1) == Some(&'\n') => i += 2,
                '\n' | '\r' | '\u{c}' => i += 1,
                c => {
                    out.push(c);
                    i += 1;
                }
            }
            continue;
        }
        let start = i;
        while i < cs.len() && i - start < 6 && cs[i].is_ascii_hexdigit() {
            i += 1;
        }
        let hex: String = cs[start..i].iter().collect();
        // Exactly one whitespace may follow as the escape's delimiter, and a
        // CRLF is that one whitespace rather than two.
        if i < cs.len() && is_css_whitespace(cs[i]) {
            if cs[i] == '\r' && cs.get(i + 1) == Some(&'\n') {
                i += 2;
            } else {
                i += 1;
            }
        }
        let cp = u32::from_str_radix(&hex, 16).unwrap_or(0xFFFD);
        // NUL, a surrogate and an out-of-range code point all become U+FFFD,
        // as CSS requires.
        out.push(char::from_u32(cp).filter(|_| cp != 0).unwrap_or('\u{FFFD}'));
    }
    out
}

/// Whether an attribute value can be written without quotes — a CSS
/// identifier. dart allows ONE leading `-` before the name-start character
/// (`[a="-leading"]` is `[a=-leading]`) but not two (`--two` stays quoted),
/// and a leading digit keeps its quotes.
fn is_attr_identifier(v: &str) -> bool {
    let body = v.strip_prefix('-').unwrap_or(v);
    let mut chars = body.chars();
    let starts = chars
        .next()
        .is_some_and(|c| c.is_ascii_alphabetic() || c == '_' || (c as u32) >= 0x80);
    starts && chars.all(|c| c.is_ascii_alphanumeric() || matches!(c, '-' | '_') || (c as u32) >= 0x80)
}

/// Canonicalize an attribute selector the way dart-sass serializes one:
/// whitespace around the operator is dropped (`[a = b]` -> `[a=b]`), and the
/// value is decoded and re-serialized — a plain identifier loses its quotes
/// (`[a="b"]` -> `[a=b]`), anything else takes whichever quote needs fewer
/// escapes. Anything that doesn't fit the simple `[name op value modifier?]`
/// grammar is returned verbatim.
pub(crate) fn normalize_attribute(text: &str) -> String {
    let inner = match text.strip_prefix('[').and_then(|t| t.strip_suffix(']')) {
        Some(i) => i.trim(),
        None => return text.to_string(),
    };
    let cs: Vec<char> = inner.chars().collect();
    let mut i = 0usize;
    let is_name_char =
        |c: char| c.is_ascii_alphanumeric() || matches!(c, '-' | '_' | '\\') || (c as u32) >= 0x80;
    // Optional namespace + name. A `|` is part of the name unless followed
    // by `=` (the `|=` operator).
    let name_start = i;
    while i < cs.len() {
        let c = cs[i];
        if is_name_char(c) || c == '*' || (c == '|' && cs.get(i + 1) != Some(&'=')) {
            i += 1;
        } else {
            break;
        }
    }
    if i == name_start {
        return text.to_string();
    }
    let name: String = cs[name_start..i].iter().collect();
    let mut j = i;
    while j < cs.len() && cs[j].is_whitespace() {
        j += 1;
    }
    if j >= cs.len() {
        return format!("[{name}]");
    }
    // Operator: `=` or one of `~|^$*` followed by `=`.
    let op: String = if cs[j] == '=' {
        j += 1;
        "=".to_string()
    } else if matches!(cs[j], '~' | '|' | '^' | '$' | '*') && cs.get(j + 1) == Some(&'=') {
        let o = format!("{}=", cs[j]);
        j += 2;
        o
    } else {
        return text.to_string();
    };
    while j < cs.len() && cs[j].is_whitespace() {
        j += 1;
    }
    // Value: quoted or an identifier run.
    #[allow(clippy::needless_late_init)]
    let value: String;
    if j < cs.len() && (cs[j] == '"' || cs[j] == '\'') {
        let q = cs[j];
        j += 1;
        let vstart = j;
        while j < cs.len() && cs[j] != q {
            if cs[j] == '\\' {
                j += 1;
            }
            j += 1;
        }
        if j >= cs.len() {
            return text.to_string();
        }
        let raw: String = cs[vstart..j].iter().collect();
        j += 1; // closing quote
                // dart DECODES the escapes and re-serializes, rather than
                // echoing the source text: a plain-identifier value loses its
                // quotes, and everything else is re-quoted with whichever quote
                // needs fewer escapes. Echoing `raw` between double quotes —
                // which is what this did — turns `[a='b"c']` into `[a="b"c"]`,
                // CSS a browser reads as `[a="b"` plus garbage.
        let decoded = decode_css_escapes(&raw);
        value = if is_attr_identifier(&decoded) {
            decoded
        } else {
            crate::value::serialize_quoted(&decoded)
        };
    } else {
        let vstart = j;
        while j < cs.len() && !cs[j].is_whitespace() && cs[j] != ']' {
            if cs[j] == '\\' {
                j += 1;
            }
            j += 1;
        }
        if j == vstart {
            return text.to_string();
        }
        value = cs[vstart..j].iter().collect();
    }
    while j < cs.len() && cs[j].is_whitespace() {
        j += 1;
    }
    // Optional single-letter modifier (`i`/`s`).
    if j < cs.len() {
        let m: String = cs[j..].iter().collect();
        let m = m.trim();
        if m.len() == 1 && m.chars().next().is_some_and(|c| c.is_ascii_alphabetic()) {
            return format!("[{name}{op}{value} {m}]");
        }
        return text.to_string();
    }
    format!("[{name}{op}{value}]")
}

/// Read a `[...]` attribute selector verbatim, returning the full text.
fn read_bracketed(chars: &[char], i: &mut usize) -> Option<String> {
    let start = *i;
    *i += 1; // '['
    let mut depth = 1;
    while *i < chars.len() {
        match chars[*i] {
            '\\' => {
                *i += 2;
                continue;
            }
            '"' | '\'' => {
                let q = chars[*i];
                *i += 1;
                while *i < chars.len() && chars[*i] != q {
                    if chars[*i] == '\\' {
                        *i += 1;
                    }
                    *i += 1;
                }
                *i += 1;
                continue;
            }
            '[' => depth += 1,
            ']' => {
                depth -= 1;
                if depth == 0 {
                    *i += 1;
                    return Some(chars[start..*i].iter().collect());
                }
            }
            _ => {}
        }
        *i += 1;
    }
    None
}

/// Read a pseudo-class/element selector verbatim (with any `(...)` argument).
fn read_pseudo(chars: &[char], i: &mut usize) -> Option<String> {
    let start = *i;
    *i += 1; // first ':'
    if *i < chars.len() && chars[*i] == ':' {
        *i += 1; // '::'
    }
    // name
    read_ident(chars, i)?;
    // optional argument
    if *i < chars.len() && chars[*i] == '(' {
        let mut depth = 0;
        while *i < chars.len() {
            match chars[*i] {
                '\\' => {
                    *i += 2;
                    continue;
                }
                '"' | '\'' => {
                    let q = chars[*i];
                    *i += 1;
                    while *i < chars.len() && chars[*i] != q {
                        if chars[*i] == '\\' {
                            *i += 1;
                        }
                        *i += 1;
                    }
                    *i += 1;
                    continue;
                }
                '(' => depth += 1,
                ')' => {
                    depth -= 1;
                    if depth == 0 {
                        *i += 1;
                        break;
                    }
                }
                _ => {}
            }
            *i += 1;
        }
    }
    Some(chars[start..*i].iter().collect())
}

pub(super) fn skip_ws(chars: &[char], i: &mut usize) {
    while *i < chars.len() && chars[*i].is_whitespace() {
        *i += 1;
    }
}

fn is_ident_start(c: char) -> bool {
    c.is_ascii_alphabetic() || c == '_' || c == '-' || !c.is_ascii()
}

fn is_ident_char(c: char) -> bool {
    c.is_ascii_alphanumeric() || c == '_' || c == '-' || !c.is_ascii()
}

/// Split `s` on the top-level (paren/bracket depth 0) occurrences of `sep`.
pub(super) fn split_top(s: &str, sep: char) -> Vec<String> {
    let mut out = Vec::new();
    let mut cur = String::new();
    let mut paren = 0i32;
    let mut bracket = 0i32;
    let mut chars = s.chars().peekable();
    while let Some(c) = chars.next() {
        match c {
            '\\' => {
                cur.push(c);
                if let Some(n) = chars.next() {
                    cur.push(n);
                }
            }
            '(' => {
                paren += 1;
                cur.push(c);
            }
            ')' => {
                paren -= 1;
                cur.push(c);
            }
            '[' => {
                bracket += 1;
                cur.push(c);
            }
            ']' => {
                bracket -= 1;
                cur.push(c);
            }
            _ if c == sep && paren == 0 && bracket == 0 => {
                out.push(std::mem::take(&mut cur));
            }
            _ => cur.push(c),
        }
    }
    out.push(cur);
    out
}

/// Parse a single complex selector (one comma-free selector). Returns `None`
/// on any parse failure.
pub(crate) fn parse_complex_one(s: &str) -> Option<Complex> {
    parse_complex(s.trim())
}
