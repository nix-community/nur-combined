//! List built-in functions (`length`, `nth`, `set-nth`, `join`, `append`,
//! `index`, `list-separator`).
//!
//! A non-list value behaves as a single-element list (length 1); the empty
//! list `()` has length 0. Sass indexes lists 1-based, with negative indices
//! counting back from the end. Shared argument helpers live in the parent
//! module: `super::{arg, require, num, as_color, channel, clamp01}`. Return
//! `Some(Ok(..))`/`Some(Err(..))` for a name this family owns, or `None` to
//! let the next family try.

use crate::error::Error;
use crate::scanner::Pos;
use crate::value::{List, ListSep, Number, SassStr, Value};

/// The names the list family owns by name (the single source of truth,
/// mirroring the `try_call` match arms below). `length`/`nth` are list-owned:
/// the map family only claims them when the first argument is a map, so they
/// belong here (and are absent from [`super::map::NAMES`]).
pub(super) const NAMES: &[&str] = &[
    "length",
    "nth",
    "set-nth",
    "join",
    "append",
    "index",
    "list-separator",
    "is-bracketed",
    "zip",
];

pub(super) fn try_call(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    Some(match name {
        "length" => fn_length(pos_args, named, pos),
        "nth" => fn_nth(pos_args, named, pos),
        "set-nth" => fn_set_nth(pos_args, named, pos),
        "join" => fn_join(pos_args, named, pos),
        "append" => fn_append(pos_args, named, pos),
        "index" => fn_index(pos_args, named, pos),
        "list-separator" => fn_list_separator(pos_args, named, pos),
        "is-bracketed" => fn_is_bracketed(pos_args, named, pos),
        "zip" => fn_zip(pos_args, named),
        _ => return None,
    })
}

/// Dispatch a `sass:list` member that has no global alias (`slash`). Returns
/// `None` for any other member so the caller can report it as undefined.
pub(super) fn call_module_member(
    member: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    Some(match member {
        "slash" => fn_slash(pos_args, named, pos),
        _ => return None,
    })
}

/// `list.slash($elements...)`: a slash-separated list of the arguments
/// (e.g. `list.slash(1, 2, 3)` → `1 / 2 / 3`). dart-sass requires at least two
/// elements.
fn fn_slash(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    if !named.is_empty() {
        return Err(Error::at(
            "No arguments named ($".to_string() + &named[0].0 + ").",
            pos,
        ));
    }
    if pos_args.len() < 2 {
        return Err(Error::at("At least two elements are required.".to_string(), pos));
    }
    Ok(Value::List(List {
        items: pos_args.to_vec().into(),
        sep: ListSep::Slash,
        bracketed: false,
        keywords: None,
    }))
}

/// Borrow a value as a list of elements and its separator. A list yields its
/// own items and separator; a map yields its entries as `key value` space
/// lists (comma-separated); any other value (including `null`) is a
/// single-element list. dart-sass reports a lone non-list as space-separated.
fn as_items(v: &Value) -> (Vec<Value>, ListSep) {
    match v {
        Value::List(l) => (l.items.to_vec(), l.sep),
        Value::Map(m) => {
            let items = m
                .entries
                .iter()
                .map(|(k, val)| {
                    Value::List(List {
                        items: vec![k.clone(), val.clone()].into(),
                        sep: ListSep::Space,
                        bracketed: false,
                        keywords: None,
                    })
                })
                .collect();
            (items, ListSep::Comma)
        }
        other => (vec![other.clone()], ListSep::Space),
    }
}

/// The element count of a value treated as a list.
fn list_len(v: &Value) -> usize {
    match v {
        Value::List(l) => l.items.len(),
        _ => 1,
    }
}

fn unitless(value: f64) -> Value {
    Value::Number(Number::unitless(value))
}

/// Resolve a 1-based (possibly negative) Sass index against a list of `len`
/// elements into a 0-based offset, erroring exactly like dart-sass on a
/// non-integer, zero, or out-of-range index. `$n` may carry a unit, which is
/// ignored (matching dart-sass).
fn resolve_index(
    params: &[&str],
    pos_args: &[Value],
    named: &[(String, Value)],
    i: usize,
    len: usize,
    pos: Pos,
) -> Result<usize, Error> {
    let v = super::require(params, pos_args, named, i, pos)?;
    let pname = params.get(i).copied().unwrap_or("");
    let raw = match v {
        Value::Number(n) => n.value,
        other => {
            return Err(Error::at(
                format!("${pname}: {} is not a number.", other.to_css(false)),
                pos,
            ))
        }
    };
    if raw.fract() != 0.0 {
        return Err(Error::at(
            format!("${pname}: {} is not an int.", crate::value::fmt_num(raw, false)),
            pos,
        ));
    }
    let index = raw as i64;
    if index == 0 {
        return Err(Error::at(format!("${pname}: List index may not be 0."), pos));
    }
    let len_i = len as i64;
    if index.abs() > len_i {
        return Err(Error::at(
            format!(
                "${pname}: Invalid index {} for a list with {} element{}.",
                crate::value::fmt_num(raw, false),
                len,
                if len == 1 { "" } else { "s" }
            ),
            pos,
        ));
    }
    // Map 1-based / negative index to a 0-based offset.
    let zero_based = if index > 0 { index - 1 } else { len_i + index };
    Ok(zero_based as usize)
}

/// Parse a `$separator` argument into a concrete `ListSep`, or `None` for the
/// keyword `auto`. Accepts `space`/`comma`/`slash`.
fn parse_separator(v: &Value, pos: Pos) -> Result<Option<ListSep>, Error> {
    if let Value::Str(SassStr { text, .. }) = v {
        match text.as_ref() {
            "auto" => return Ok(None),
            "comma" => return Ok(Some(ListSep::Comma)),
            "space" => return Ok(Some(ListSep::Space)),
            "slash" => return Ok(Some(ListSep::Slash)),
            _ => {}
        }
    }
    Err(Error::at(
        "$separator: Must be \"space\", \"comma\", \"slash\", or \"auto\".",
        pos,
    ))
}

/// `length($list)`: the unitless element count.
fn fn_length(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    validate_args(&["list"], pos_args, named, pos)?;
    let v = super::require(&["list"], pos_args, named, 0, pos)?;
    Ok(unitless(list_len(v) as f64))
}

/// `nth($list, $n)`: the element at the 1-based (negative-from-end) index.
fn fn_nth(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["list", "n"];
    validate_args(&params, pos_args, named, pos)?;
    let list = super::require(&params, pos_args, named, 0, pos)?;
    let (items, _) = as_items(list);
    let idx = resolve_index(&params, pos_args, named, 1, items.len(), pos)?;
    items
        .get(idx)
        .cloned()
        .ok_or_else(|| Error::at("Internal index error.", pos))
}

/// `set-nth($list, $n, $value)`: a copy of the list with one element replaced,
/// preserving the original separator.
fn fn_set_nth(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["list", "n", "value"];
    validate_args(&params, pos_args, named, pos)?;
    let list = super::require(&params, pos_args, named, 0, pos)?;
    let (mut items, sep) = as_items(list);
    let idx = resolve_index(&params, pos_args, named, 1, items.len(), pos)?;
    let value = super::require(&params, pos_args, named, 2, pos)?.clone();
    if let Some(slot) = items.get_mut(idx) {
        *slot = value;
    }
    // `set-nth` preserves the source list's bracketing (dart-sass).
    let bracketed = matches!(list, Value::List(l) if l.bracketed);
    Ok(Value::List(List::new(items, sep, bracketed)))
}

/// The "settled" separator of a value, or `None` when undecided. A non-empty
/// `List` value carries its own separator; a bare value defaults to space.
/// An empty list is normally undecided (dart-sass defaults it to space), but an
/// empty *comma* list is one that was deliberately built comma-separated
/// (e.g. the result of `map.keys(())`/`map.values(())`), so its separator is
/// settled to comma — a literal empty `()` is stored space-separated and stays
/// undecided.
fn settled_sep(v: &Value) -> Option<ListSep> {
    match v {
        // A list with a real (non-undecided) separator is settled, even when
        // empty or single-element — the separator is an explicit choice that
        // `list.join`/`list.append` must honour.
        Value::List(l) if l.sep != ListSep::Undecided => Some(l.sep),
        // A non-empty map behaves as a comma-separated list of its entries.
        Value::Map(m) if !m.entries.is_empty() => Some(ListSep::Comma),
        // An undecided list, or a bare value, has no settled separator.
        _ => None,
    }
}

/// `join($list1, $list2, $separator: auto, $bracketed: auto)`: concatenated
/// list. With `auto`, the separator is list1's settled separator (or list2's
/// when list1 has none), defaulting to space when neither is settled. The
/// `$bracketed` flag defaults to list1's bracketing (`auto`), or is forced
/// true/false by a truthy/falsey argument.
fn fn_join(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["list1", "list2", "separator", "bracketed"];
    validate_args(&params, pos_args, named, pos)?;
    let list1 = super::require(&params, pos_args, named, 0, pos)?;
    let list2 = super::require(&params, pos_args, named, 1, pos)?;
    let (items1, _) = as_items(list1);
    let (items2, _) = as_items(list2);

    let sep = match super::arg(&params, pos_args, named, 2) {
        Some(v) => match parse_separator(v, pos)? {
            Some(s) => s,
            None => join_auto_separator(list1, list2),
        },
        None => join_auto_separator(list1, list2),
    };

    // `$bracketed`: `auto` (default) inherits list1's brackets; any other value
    // is truthy/falsey.
    let bracketed = match super::arg(&params, pos_args, named, 3) {
        None => matches!(list1, Value::List(l) if l.bracketed),
        Some(Value::Str(s)) if !s.quoted && &*s.text == "auto" => {
            matches!(list1, Value::List(l) if l.bracketed)
        }
        Some(v) => v.is_truthy(),
    };

    let mut items = items1;
    items.extend(items2);
    Ok(Value::List(List::new(items, sep, bracketed)))
}

/// The dart-sass "Only N argument(s) allowed, but M were passed." error.
/// `named` decides the "positional" wording, as in [`super::check_arity`].
fn too_many(passed: usize, max: usize, named: &[(String, Value)], pos: Pos) -> Error {
    let kind = if named.is_empty() { "" } else { "positional " };
    Error::at(
        format!(
            "Only {} {}argument{} allowed, but {} {} passed.",
            max,
            kind,
            if max == 1 { "" } else { "s" },
            passed,
            if passed == 1 { "was" } else { "were" }
        ),
        pos,
    )
}

/// Validate a fixed-arity (non-variadic) builtin's argument list against its
/// declared `params`, in dart's own order: a POSITIONAL overflow is the
/// "Only N argument(s) allowed…" error (only positional arguments count toward
/// it — see [`super::check_arity`]), and only then is a named argument whose
/// name is not a declared parameter "No parameter named $X.".
fn validate_args(
    params: &[&str],
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Result<(), Error> {
    // dart's order (`ArgumentDeclaration.verify`): the positional overflow is
    // reported before an unrecognized name.
    if pos_args.len() > params.len() {
        return Err(too_many(pos_args.len(), params.len(), named, pos));
    }
    if let Some((n, _)) = named.iter().find(|(n, _)| !params.contains(&n.as_str())) {
        return Err(Error::at(format!("No parameter named ${n}."), pos));
    }
    Ok(())
}

/// `join`'s `auto` rule: list1's settled separator, else list2's, else space.
/// `join` always yields a *decided* separator (dart-sass), so even
/// `join((), ())` is space-separated, not undecided.
fn join_auto_separator(list1: &Value, list2: &Value) -> ListSep {
    settled_sep(list1)
        .or_else(|| settled_sep(list2))
        .unwrap_or(ListSep::Space)
}

/// `append($list, $val, $separator: auto)`: the list with `$val` appended.
/// With `auto`, the existing list's settled separator is kept, defaulting to
/// space for a bare value or empty list.
fn fn_append(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["list", "val", "separator"];
    validate_args(&params, pos_args, named, pos)?;
    let list = super::require(&params, pos_args, named, 0, pos)?;
    let val = super::require(&params, pos_args, named, 1, pos)?.clone();
    let (mut items, _) = as_items(list);

    let sep = match super::arg(&params, pos_args, named, 2) {
        Some(v) => match parse_separator(v, pos)? {
            Some(s) => s,
            None => settled_sep(list).unwrap_or(ListSep::Space),
        },
        None => settled_sep(list).unwrap_or(ListSep::Space),
    };
    // `append` keeps the source list's bracketing (dart-sass).
    let bracketed = matches!(list, Value::List(l) if l.bracketed);

    items.push(val);
    Ok(Value::List(List::new(items, sep, bracketed)))
}

/// `index($list, $value)`: the 1-based position of the first element equal to
/// `$value` (by Sass `==`), or `null` when absent.
fn fn_index(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["list", "value"];
    validate_args(&params, pos_args, named, pos)?;
    let list = super::require(&params, pos_args, named, 0, pos)?;
    let value = super::require(&params, pos_args, named, 1, pos)?;
    let (items, _) = as_items(list);
    match items.iter().position(|item| item.sass_eq(value)) {
        Some(i) => Ok(unitless((i + 1) as f64)),
        None => Ok(Value::Null),
    }
}

/// `list-separator($list)`: the unquoted keyword `comma` or `space`. An empty
/// list or a bare value is "undecided" and reports `space`.
fn fn_list_separator(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    validate_args(&["list"], pos_args, named, pos)?;
    let v = super::require(&["list"], pos_args, named, 0, pos)?;
    // A bare value or empty list is "undecided", which dart-sass reports as
    // space; otherwise the list's own separator is authoritative.
    let sep = settled_sep(v).unwrap_or(ListSep::Space);
    let text = match sep {
        ListSep::Comma => "comma",
        ListSep::Space | ListSep::Undecided => "space",
        ListSep::Slash => "slash",
    };
    Ok(Value::Str(SassStr {
        text: text.into(),
        quoted: false,
    }))
}

/// `is-bracketed($list)`: `true` when the list was written with square
/// brackets. A bare value or an empty/non-bracketed list reports `false`.
fn fn_is_bracketed(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    validate_args(&["list"], pos_args, named, pos)?;
    let v = super::require(&["list"], pos_args, named, 0, pos)?;
    let bracketed = matches!(v, Value::List(l) if l.bracketed);
    Ok(Value::Bool(bracketed))
}

/// `zip($lists...)`: combine corresponding elements of each list into a
/// comma-separated list of space-separated sublists, truncating to the
/// shortest input. With a single element per row the row is that bare value;
/// when any input is empty (length 0) the result is the empty list.
fn fn_zip(pos_args: &[Value], named: &[(String, Value)]) -> Result<Value, Error> {
    // `zip` takes only the variadic positional `$lists`; any trailing named
    // arguments are treated as further lists, matching dart-sass's rest list.
    let lists: Vec<Vec<Value>> = pos_args
        .iter()
        .chain(named.iter().map(|(_, v)| v))
        .map(|v| as_items(v).0)
        .collect();
    let rows = lists.iter().map(|l| l.len()).min().unwrap_or(0);
    let mut out = Vec::with_capacity(rows);
    for i in 0..rows {
        let row: Vec<Value> = lists.iter().map(|l| l[i].clone()).collect();
        out.push(Value::List(List {
            items: row.into(),
            sep: ListSep::Space,
            bracketed: false,
            keywords: None,
        }));
    }
    Ok(Value::List(List {
        items: out.into(),
        sep: ListSep::Comma,
        bracketed: false,
        keywords: None,
    }))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn pos() -> Pos {
        Pos { line: 1, col: 1 }
    }

    fn n(value: f64) -> Value {
        Value::Number(Number::unitless(value))
    }

    fn num_unit(value: f64, unit: &str) -> Value {
        Value::Number(Number::with_unit(value, unit))
    }

    fn s(text: &str) -> Value {
        Value::Str(SassStr {
            text: text.into(),
            quoted: false,
        })
    }

    fn list(items: Vec<Value>, sep: ListSep) -> Value {
        Value::List(List {
            items: items.into(),
            sep,
            bracketed: false,
            keywords: None,
        })
    }

    fn call(name: &str, args: &[Value]) -> Value {
        try_call(name, args, &[], pos())
            .expect("name owned by list family")
            .expect("no error")
    }

    fn call_err(name: &str, args: &[Value]) -> Error {
        try_call(name, args, &[], pos())
            .expect("name owned by list family")
            .expect_err("expected error")
    }

    #[test]
    fn length_counts_elements() {
        assert_eq!(call("length", &[list(vec![], ListSep::Space)]).to_css(false), "0");
        assert_eq!(call("length", &[num_unit(5.0, "px")]).to_css(false), "1");
        assert_eq!(
            call(
                "length",
                &[list(
                    vec![num_unit(1.0, "px"), num_unit(2.0, "px"), num_unit(3.0, "px")],
                    ListSep::Space
                )]
            )
            .to_css(false),
            "3"
        );
    }

    #[test]
    fn nth_one_based_and_negative() {
        let l = list(vec![s("a"), s("b"), s("c")], ListSep::Space);
        assert_eq!(call("nth", &[l.clone(), n(1.0)]).to_css(false), "a");
        assert_eq!(call("nth", &[l.clone(), n(-1.0)]).to_css(false), "c");
        // Single non-list value behaves as a one-element list.
        assert_eq!(call("nth", &[s("solo"), n(1.0)]).to_css(false), "solo");
    }

    #[test]
    fn nth_index_errors() {
        let l = list(vec![s("a"), s("b"), s("c")], ListSep::Space);
        assert_eq!(
            call_err("nth", &[l.clone(), n(0.0)]).message,
            "$n: List index may not be 0."
        );
        assert_eq!(
            call_err("nth", &[l.clone(), n(5.0)]).message,
            "$n: Invalid index 5 for a list with 3 elements."
        );
        assert_eq!(call_err("nth", &[l, n(1.5)]).message, "$n: 1.5 is not an int.");
    }

    #[test]
    fn set_nth_replaces_and_keeps_separator() {
        let l = list(vec![s("a"), s("b"), s("c")], ListSep::Space);
        assert_eq!(
            call("set-nth", &[l.clone(), n(2.0), s("x")]).to_css(false),
            "a x c"
        );
        assert_eq!(call("set-nth", &[l, n(-1.0), s("z")]).to_css(false), "a b z");
        // Single value -> one-element list.
        assert_eq!(call("set-nth", &[s("a"), n(1.0), s("z")]).to_css(false), "z");
    }

    #[test]
    fn join_default_uses_list1_separator() {
        let a = list(vec![num_unit(1.0, "px"), num_unit(2.0, "px")], ListSep::Space);
        let b = list(vec![num_unit(3.0, "px"), num_unit(4.0, "px")], ListSep::Space);
        assert_eq!(call("join", &[a, b]).to_css(false), "1px 2px 3px 4px");

        let c = list(vec![s("a"), s("b")], ListSep::Comma);
        let d = list(vec![s("c"), s("d")], ListSep::Comma);
        assert_eq!(call("join", &[c, d]).to_css(false), "a, b, c, d");
    }

    #[test]
    fn join_single_list_borrows_list2_separator() {
        // list1 has <2 items, so list2's comma wins.
        let a = s("a");
        let b = list(vec![s("b"), s("c")], ListSep::Comma);
        assert_eq!(call("join", &[a, b]).to_css(false), "a, b, c");
    }

    #[test]
    fn join_explicit_separator() {
        let a = list(vec![num_unit(1.0, "px"), num_unit(2.0, "px")], ListSep::Space);
        assert_eq!(
            call("join", &[a, num_unit(3.0, "px"), s("comma")]).to_css(false),
            "1px, 2px, 3px"
        );
    }

    #[test]
    fn append_default_and_explicit() {
        let a = list(vec![num_unit(1.0, "px"), num_unit(2.0, "px")], ListSep::Space);
        assert_eq!(
            call("append", &[a.clone(), num_unit(3.0, "px")]).to_css(false),
            "1px 2px 3px"
        );
        let c = list(vec![s("a"), s("b")], ListSep::Comma);
        assert_eq!(call("append", &[c, s("c")]).to_css(false), "a, b, c");
        assert_eq!(
            call("append", &[a, num_unit(3.0, "px"), s("comma")]).to_css(false),
            "1px, 2px, 3px"
        );
    }

    #[test]
    fn append_to_empty_list() {
        assert_eq!(
            call("append", &[list(vec![], ListSep::Space), s("x")]).to_css(false),
            "x"
        );
    }

    #[test]
    fn index_finds_or_null() {
        let l = list(vec![s("a"), s("b"), s("c")], ListSep::Space);
        assert_eq!(call("index", &[l.clone(), s("b")]).to_css(false), "2");
        assert!(matches!(call("index", &[l, s("z")]), Value::Null));
        // Number equality is by value+unit.
        let nums = list(
            vec![num_unit(1.0, "px"), num_unit(2.0, ""), num_unit(3.0, "px")],
            ListSep::Space,
        );
        assert!(matches!(call("index", &[nums, num_unit(2.0, "px")]), Value::Null));
    }

    #[test]
    fn list_separator_reports_keyword() {
        assert_eq!(
            call("list-separator", &[list(vec![s("a"), s("b")], ListSep::Comma)]).to_css(false),
            "comma"
        );
        assert_eq!(
            call("list-separator", &[list(vec![s("a"), s("b")], ListSep::Space)]).to_css(false),
            "space"
        );
        // A bare value (not a list) -> space.
        assert_eq!(call("list-separator", &[s("a")]).to_css(false), "space");
        // A deliberately comma-separated empty list (e.g. the result of
        // `map.keys(())`) reports comma; a space-separated empty list (the
        // literal `()`) stays undecided and reports space.
        assert_eq!(
            call("list-separator", &[list(vec![], ListSep::Comma)]).to_css(false),
            "comma"
        );
        assert_eq!(
            call("list-separator", &[list(vec![], ListSep::Space)]).to_css(false),
            "space"
        );
    }

    #[test]
    fn is_bracketed_reports_flag() {
        let bracketed = Value::List(List {
            items: vec![s("a"), s("b")].into(),
            sep: ListSep::Space,
            bracketed: true,
            keywords: None,
        });
        assert!(matches!(call("is-bracketed", &[bracketed]), Value::Bool(true)));
        assert!(matches!(
            call("is-bracketed", &[list(vec![s("a"), s("b")], ListSep::Space)]),
            Value::Bool(false)
        ));
        // A bare value and an empty list are not bracketed.
        assert!(matches!(call("is-bracketed", &[s("a")]), Value::Bool(false)));
        assert!(matches!(
            call("is-bracketed", &[list(vec![], ListSep::Space)]),
            Value::Bool(false)
        ));
    }

    #[test]
    fn zip_interleaves_to_shortest() {
        let a = list(vec![n(1.0), n(2.0), n(3.0)], ListSep::Space);
        let b = list(vec![s("c"), s("d"), s("e")], ListSep::Space);
        assert_eq!(call("zip", &[a, b]).to_css(false), "1 c, 2 d, 3 e");
        // Truncates to the shortest input.
        let a = list(vec![n(1.0), n(2.0), n(3.0)], ListSep::Space);
        let b = list(vec![s("c"), s("d")], ListSep::Space);
        assert_eq!(call("zip", &[a, b]).to_css(false), "1 c, 2 d");
        // A single list yields one element per row.
        let a = list(vec![s("a"), s("b"), s("c")], ListSep::Space);
        assert_eq!(call("zip", &[a]).to_css(false), "a, b, c");
    }

    #[test]
    fn rejects_unknown_names_and_bad_separator() {
        assert!(try_call("frobnicate", &[s("x")], &[], pos()).is_none());
        let err = call_err("join", &[s("a"), s("b"), s("dash")]);
        assert_eq!(
            err.message,
            "$separator: Must be \"space\", \"comma\", \"slash\", or \"auto\"."
        );
    }
}
