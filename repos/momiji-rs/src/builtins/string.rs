//! String built-in functions (`unquote`, `quote`, `str-length`, …).
//!
//! Shared argument helpers live in the parent module:
//! `super::{arg, require, num, as_color, channel, clamp01}`. Return
//! `Some(Ok(..))`/`Some(Err(..))` for a name this family owns, or `None`
//! to let the next family try.
//!
//! Sass counts Unicode characters (not bytes) and indexes strings 1-based,
//! with negative indices counting back from the end.

use crate::error::Error;
use crate::scanner::Pos;
use crate::value::{List, ListSep, Number, SassStr, Value};

/// The names the string family owns by name (the single source of truth,
/// mirroring the `try_call` match arms below).
pub(super) const NAMES: &[&str] = &[
    "quote",
    "unquote",
    "to-upper-case",
    "to-lower-case",
    "str-length",
    "str-index",
    "str-slice",
    "str-insert",
    "unique-id",
];

pub(super) fn try_call(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    // Maximum positional arity per function; passing more is an error.
    let max = match name {
        "unique-id" => 0,
        "quote" | "unquote" | "to-upper-case" | "to-lower-case" | "str-length" => 1,
        "str-index" => 2,
        "str-slice" | "str-insert" => 3,
        _ => usize::MAX,
    };
    if let Err(e) = check_arity(pos_args, named, max, pos) {
        // Only enforce for names this family actually owns.
        if max != usize::MAX {
            return Some(Err(e));
        }
    }
    Some(match name {
        "quote" => fn_set_quoted(pos_args, named, pos, true),
        "unquote" => fn_set_quoted(pos_args, named, pos, false),
        "to-upper-case" => fn_change_case(pos_args, named, pos, true),
        "to-lower-case" => fn_change_case(pos_args, named, pos, false),
        "str-length" => fn_str_length(pos_args, named, pos),
        "str-index" => fn_str_index(pos_args, named, pos),
        "str-slice" => fn_str_slice(pos_args, named, pos),
        "str-insert" => fn_str_insert(pos_args, named, pos),
        "unique-id" => Ok(fn_unique_id()),
        _ => return None,
    })
}

/// Dispatch a `sass:string` member that has no global alias (`split`). Returns
/// `None` for any other member so the caller can report it as undefined.
pub(super) fn call_module_member(
    member: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    Some(match member {
        "split" => fn_split(pos_args, named, pos),
        _ => return None,
    })
}

/// Reject more positional arguments than `max` (dart-sass "Only N argument(s)
/// allowed, but M were passed.").
fn check_arity(pos_args: &[Value], named: &[(String, Value)], max: usize, pos: Pos) -> Result<(), Error> {
    super::check_arity(max, pos_args, named, pos)
}

/// Extract `(text, quoted)` from a required string argument, erroring with
/// dart-sass's `$<param>: <value> is not a string.` message otherwise.
fn require_string<'v>(
    params: &[&str],
    pos_args: &'v [Value],
    named: &'v [(String, Value)],
    i: usize,
    pos: Pos,
) -> Result<(&'v str, bool), Error> {
    let v = super::require(params, pos_args, named, i, pos)?;
    match v {
        Value::Str(SassStr { text, quoted }) => Ok((text.as_ref(), *quoted)),
        other => Err(Error::at(
            format!(
                "${}: {} is not a string.",
                params.get(i).copied().unwrap_or(""),
                other.to_css(false)
            ),
            pos,
        )),
    }
}

/// Extract a unitless integer index, matching dart-sass which rejects any
/// unit on string indices.
fn require_index(
    params: &[&str],
    pos_args: &[Value],
    named: &[(String, Value)],
    i: usize,
    pos: Pos,
) -> Result<i64, Error> {
    let v = super::require(params, pos_args, named, i, pos)?;
    let pname = params.get(i).copied().unwrap_or("");
    match v {
        Value::Number(n) => {
            let value = n.value;
            if !n.is_unitless() {
                return Err(Error::at(
                    format!("${pname}: Expected {} to have no units.", v.to_css(false)),
                    pos,
                ));
            }
            // dart-sass requires an integer index (it rounds within a tiny
            // tolerance, but a genuine fraction like `0.5` is an error).
            if (value - value.round()).abs() > 1e-11 {
                return Err(Error::at(
                    format!("${pname}: {} is not an int.", crate::value::fmt_num(value, false)),
                    pos,
                ));
            }
            Ok(value.round() as i64)
        }
        other => Err(Error::at(
            format!("${pname}: {} is not a number.", other.to_css(false)),
            pos,
        )),
    }
}

fn quoted_str(text: String, quoted: bool) -> Value {
    Value::Str(SassStr {
        text: text.into(),
        quoted,
    })
}

/// `quote($string)` / `unquote($string)`. dart-sass 1.x rejects non-string
/// arguments for both with `$string: ... is not a string.`.
fn fn_set_quoted(
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    quoted: bool,
) -> Result<Value, Error> {
    let (text, _) = require_string(&["string"], pos_args, named, 0, pos)?;
    Ok(quoted_str(text.to_string(), quoted))
}

/// `to-upper-case` / `to-lower-case`: ASCII-only case change, preserving the
/// argument's quotedness.
fn fn_change_case(
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    upper: bool,
) -> Result<Value, Error> {
    let (text, quoted) = require_string(&["string"], pos_args, named, 0, pos)?;
    let mapped: String = if upper {
        text.chars().map(|c| c.to_ascii_uppercase()).collect()
    } else {
        text.chars().map(|c| c.to_ascii_lowercase()).collect()
    };
    Ok(quoted_str(mapped, quoted))
}

/// `str-length($string)`: unitless character count.
fn fn_str_length(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let (text, _) = require_string(&["string"], pos_args, named, 0, pos)?;
    Ok(Value::Number(Number::unitless(text.chars().count() as f64)))
}

/// `str-index($string, $substring)`: 1-based char index of the first
/// occurrence, or `null` when absent.
fn fn_str_index(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["string", "substring"];
    let (text, _) = require_string(&params, pos_args, named, 0, pos)?;
    let (sub, _) = require_string(&params, pos_args, named, 1, pos)?;
    match text.find(sub) {
        // `find` gives a byte offset; convert to a 1-based char index.
        Some(byte) => Ok(Value::Number(Number::unitless(
            (text[..byte].chars().count() + 1) as f64,
        ))),
        None => Ok(Value::Null),
    }
}

/// Normalize a 1-based (possibly negative) index into a 1-based position used
/// for slicing. Index `0` stays `0`; negatives count from the end.
fn normalize_index(index: i64, len: i64) -> i64 {
    if index > 0 {
        index
    } else if index == 0 {
        0
    } else {
        len + index + 1
    }
}

/// `str-slice($string, $start-at, $end-at: -1)`: 1-based inclusive slice with
/// negative indices counting from the end; preserves quotedness.
fn fn_str_slice(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["string", "start-at", "end-at"];
    let (text, quoted) = require_string(&params, pos_args, named, 0, pos)?;
    let chars: Vec<char> = text.chars().collect();
    let len = chars.len() as i64;

    let start_at = require_index(&params, pos_args, named, 1, pos)?;
    let end_at = match super::arg(&params, pos_args, named, 2) {
        Some(_) => require_index(&params, pos_args, named, 2, pos)?,
        None => -1,
    };

    // Resolve to 1-based positions, then clamp into range.
    let start = normalize_index(start_at, len).max(1);
    let end = normalize_index(end_at, len).min(len);

    if start > end || start > len || end < 1 {
        return Ok(quoted_str(String::new(), quoted));
    }
    // Indices are valid 1..=len here; convert to 0-based slice bounds.
    let lo = (start - 1) as usize;
    let hi = end as usize;
    let slice: String = chars[lo..hi].iter().collect();
    Ok(quoted_str(slice, quoted))
}

/// `str-insert($string, $insert, $index)`: insert at a 1-based index
/// (negative counts from the end); preserves the host string's quotedness.
fn fn_str_insert(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["string", "insert", "index"];
    let (text, quoted) = require_string(&params, pos_args, named, 0, pos)?;
    let (insert, _) = require_string(&params, pos_args, named, 1, pos)?;
    let chars: Vec<char> = text.chars().collect();
    let len = chars.len() as i64;
    let index = require_index(&params, pos_args, named, 2, pos)?;

    // Compute the 0-based offset at which `insert` is placed.
    let offset: usize = if index > 0 {
        (index - 1).min(len).max(0) as usize
    } else if index == 0 {
        0
    } else {
        (len + index + 1).clamp(0, len) as usize
    };

    let mut out = String::new();
    out.extend(chars[..offset].iter());
    out.push_str(insert);
    out.extend(chars[offset..].iter());
    Ok(quoted_str(out, quoted))
}

/// `unique-id()`: a randomly-generated unquoted string that is a valid CSS
/// identifier (`u` + base-36 digits) and differs on every call. dart-sass
/// exposes this both globally (deprecated) and as `string.unique-id`.
fn fn_unique_id() -> Value {
    use std::cell::Cell;
    use std::time::{SystemTime, UNIX_EPOCH};
    thread_local! {
        static STATE: Cell<u64> = const { Cell::new(0) };
    }
    let x = STATE.with(|s| {
        let mut x = s.get();
        if x == 0 {
            let seed = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .map(|d| d.as_nanos() as u64)
                .unwrap_or(0x9E37_79B9_7F4A_7C15);
            x = seed | 1;
        }
        // xorshift64*
        x ^= x >> 12;
        x ^= x << 25;
        x ^= x >> 27;
        s.set(x);
        x.wrapping_mul(0x2545_F491_4F6C_DD1D)
    });
    // dart-sass picks a value in [36^5, 36^6); render base-36 after a `u`.
    let range = 36u64.pow(6) - 36u64.pow(5);
    let n = 36u64.pow(5) + (x % range);
    Value::Str(SassStr {
        text: format!("u{}", to_base36(n)).into(),
        quoted: false,
    })
}

/// Render `n` in lowercase base-36.
fn to_base36(mut n: u64) -> String {
    const DIGITS: &[u8; 36] = b"0123456789abcdefghijklmnopqrstuvwxyz";
    if n == 0 {
        return "0".to_string();
    }
    let mut buf = Vec::new();
    while n > 0 {
        buf.push(DIGITS[(n % 36) as usize]);
        n /= 36;
    }
    buf.reverse();
    String::from_utf8(buf).unwrap_or_default()
}

/// `string.split($string, $separator, $limit: null)`: split `$string` on each
/// occurrence of `$separator`, returning a bracketed comma list of quoted
/// substrings. An empty `$separator` splits into individual characters. A
/// positive `$limit` caps the number of splits (so at most `limit + 1` parts).
fn fn_split(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["string", "separator", "limit"];
    check_arity(pos_args, named, 3, pos)?;
    let (text, text_quoted) = require_string(&params, pos_args, named, 0, pos)?;
    let (sep, _) = require_string(&params, pos_args, named, 1, pos)?;
    // `$limit` is the maximum number of splits (not parts). `null`/absent means
    // unlimited; it must be a positive integer otherwise.
    let limit = match super::arg(&params, pos_args, named, 2) {
        None | Some(Value::Null) => None,
        Some(Value::Number(num)) => {
            if !num.is_unitless() || (num.value - num.value.round()).abs() > 1e-11 {
                return Err(Error::at(
                    format!(
                        "$limit: {} is not an int.",
                        crate::value::fmt_num(num.value, false)
                    ),
                    pos,
                ));
            }
            let l = num.value.round() as i64;
            if l < 1 {
                return Err(Error::at(format!("$limit: Must be 1 or greater, was {l}."), pos));
            }
            Some(l as usize)
        }
        Some(other) => {
            return Err(Error::at(
                format!("$limit: {} is not a number.", other.to_css(false)),
                pos,
            ))
        }
    };

    let parts = split_string(text, sep, limit);
    // Each part inherits the input string's quotedness (dart-sass).
    let items = parts
        .into_iter()
        .map(|p| {
            Value::Str(SassStr {
                text: p.into(),
                quoted: text_quoted,
            })
        })
        .collect();
    Ok(Value::List(List {
        items,
        sep: ListSep::Comma,
        bracketed: true,
        keywords: None,
    }))
}

/// Split `text` on `sep`, honouring an optional cap on the number of splits.
/// An empty separator yields each character; an empty string yields no parts.
fn split_string(text: &str, sep: &str, limit: Option<usize>) -> Vec<String> {
    if text.is_empty() {
        return Vec::new();
    }
    if sep.is_empty() {
        // Split into individual characters (capped by `limit` splits, so the
        // tail beyond the cap stays joined).
        let chars: Vec<char> = text.chars().collect();
        return match limit {
            Some(n) if n < chars.len() => {
                let mut out: Vec<String> = chars[..n].iter().map(|c| c.to_string()).collect();
                out.push(chars[n..].iter().collect());
                out
            }
            _ => chars.iter().map(|c| c.to_string()).collect(),
        };
    }
    let mut out: Vec<String> = Vec::new();
    let mut rest = text;
    let mut splits = 0usize;
    while let Some(idx) = rest.find(sep) {
        if let Some(max) = limit {
            if splits >= max {
                break;
            }
        }
        out.push(rest[..idx].to_string());
        rest = &rest[idx + sep.len()..];
        splits += 1;
    }
    out.push(rest.to_string());
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn pos() -> Pos {
        Pos { line: 1, col: 1 }
    }

    fn s(text: &str, quoted: bool) -> Value {
        Value::Str(SassStr {
            text: text.into(),
            quoted,
        })
    }

    fn n(value: f64) -> Value {
        Value::Number(Number::unitless(value))
    }

    fn call(name: &str, args: &[Value]) -> Value {
        try_call(name, args, &[], pos())
            .expect("name owned by string family")
            .expect("no error")
    }

    #[test]
    fn quote_and_unquote_flip_quotedness() {
        assert_eq!(call("quote", &[s("hello", false)]).to_css(false), "\"hello\"");
        assert_eq!(call("unquote", &[s("foo", true)]).to_css(false), "foo");
    }

    #[test]
    fn quote_rejects_non_strings() {
        let err = try_call("quote", &[n(42.0)], &[], pos());
        assert!(err.expect("owned").is_err());
        let err = try_call("unquote", &[Value::Bool(true)], &[], pos());
        assert!(err.expect("owned").is_err());
    }

    #[test]
    fn case_change_is_ascii_and_preserves_quoting() {
        assert_eq!(
            call("to-upper-case", &[s("aBc-Def", true)]).to_css(false),
            "\"ABC-DEF\""
        );
        assert_eq!(call("to-lower-case", &[s("ABC", false)]).to_css(false), "abc");
    }

    #[test]
    fn str_length_counts_unicode_chars() {
        assert_eq!(call("str-length", &[s("hello", true)]).to_css(false), "5");
        assert_eq!(call("str-length", &[s("café", true)]).to_css(false), "4");
    }

    #[test]
    fn str_index_is_one_based_or_null() {
        assert_eq!(
            call("str-index", &[s("Hello World", true), s("o", true)]).to_css(false),
            "5"
        );
        assert!(matches!(
            call("str-index", &[s("abc", true), s("z", true)]),
            Value::Null
        ));
    }

    #[test]
    fn str_slice_handles_negatives_and_defaults() {
        assert_eq!(
            call("str-slice", &[s("abcdef", true), n(2.0), n(4.0)]).to_css(false),
            "\"bcd\""
        );
        assert_eq!(
            call("str-slice", &[s("abcdef", true), n(2.0)]).to_css(false),
            "\"bcdef\""
        );
        assert_eq!(
            call("str-slice", &[s("abcdef", true), n(-3.0), n(-1.0)]).to_css(false),
            "\"def\""
        );
        // start > end yields empty; start 0 acts like 1.
        assert_eq!(
            call("str-slice", &[s("abcdef", true), n(4.0), n(2.0)]).to_css(false),
            "\"\""
        );
        assert_eq!(
            call("str-slice", &[s("abcde", false), n(0.0), n(3.0)]).to_css(false),
            "abc"
        );
        // end 0 resolves before the first char -> empty.
        assert_eq!(
            call("str-slice", &[s("abcde", true), n(2.0), n(0.0)]).to_css(false),
            "\"\""
        );
    }

    #[test]
    fn str_insert_positions_and_clamps() {
        assert_eq!(
            call("str-insert", &[s("abc", true), s("X", true), n(2.0)]).to_css(false),
            "\"aXbc\""
        );
        assert_eq!(
            call("str-insert", &[s("abc", true), s("X", true), n(-1.0)]).to_css(false),
            "\"abcX\""
        );
        assert_eq!(
            call("str-insert", &[s("abc", true), s("X", true), n(100.0)]).to_css(false),
            "\"abcX\""
        );
        assert_eq!(
            call("str-insert", &[s("abc", false), s("X", true), n(-5.0)]).to_css(false),
            "Xabc"
        );
    }

    #[test]
    fn rejects_unknown_names_and_units() {
        assert!(try_call("frobnicate", &[s("x", true)], &[], pos()).is_none());
        let unit_idx = Value::Number(Number::with_unit(2.0, "px"));
        let err = try_call("str-slice", &[s("abc", true), unit_idx], &[], pos());
        assert!(err.expect("owned").is_err());
    }
}
