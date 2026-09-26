//! Map built-in functions (`map-get`, `map-keys`, `map-values`,
//! `map-has-key`, `map-merge`, `map-remove`) plus the map-aware overloads of
//! `length`/`nth`.
//!
//! Sass maps are ordered key/value collections; keys compare by Sass `==`.
//! This family is registered ahead of the list family so that `length`/`nth`
//! on a map are handled here, while the same names on a list fall through to
//! the list family (this `try_call` returns `None` for them unless the first
//! argument is actually a map). Shared argument helpers live in the parent
//! module: `super::{arg, require, num}`.

use crate::error::Error;
use crate::scanner::Pos;
use crate::value::{List, ListSep, Map, Number, Value};

/// The names the map family owns *unconditionally* by name (the single source
/// of truth, mirroring the `map-*` match arms below). `length`/`nth` are
/// deliberately absent: they are owned by the list family and only claimed here
/// when the first argument is a map (a runtime condition that never removes
/// them from the builtin set), so they live in [`super::list::NAMES`].
pub(super) const NAMES: &[&str] = &[
    "map-get",
    "map-keys",
    "map-values",
    "map-has-key",
    "map-merge",
    "map-remove",
];

pub(super) fn try_call(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    Some(match name {
        "map-get" => fn_map_get(pos_args, named, pos),
        "map-keys" => fn_map_keys(pos_args, named, pos),
        "map-values" => fn_map_values(pos_args, named, pos),
        "map-has-key" => fn_map_has_key(pos_args, named, pos),
        "map-merge" => fn_map_merge(pos_args, named, pos),
        "map-remove" => fn_map_remove(pos_args, named, pos),
        // `length`/`nth` are owned by the list family; this family only claims
        // them when the first argument is a map (so list calls fall through).
        "length" if first_is_map(pos_args, named) => fn_length(pos_args, named, pos),
        "nth" if first_is_map(pos_args, named) => fn_nth(pos_args, named, pos),
        _ => return None,
    })
}

/// Dispatch a `sass:map` member that has no global alias (`set`, `deep-merge`,
/// `deep-remove`). Returns `None` for any other member so the caller can report
/// it as undefined.
pub(super) fn call_module_member(
    member: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    Some(match member {
        "set" => fn_map_set(pos_args, named, pos),
        "deep-merge" => fn_map_deep_merge(pos_args, named, pos),
        "deep-remove" => fn_map_deep_remove(pos_args, named, pos),
        _ => return None,
    })
}

/// Whether the first argument (positional or by the conventional first
/// parameter name) is a map. Used to decide whether `length`/`nth` belong to
/// this family or fall through to the list family.
fn first_is_map(pos_args: &[Value], named: &[(String, Value)]) -> bool {
    if let Some(v) = pos_args.first() {
        return matches!(v, Value::Map(_));
    }
    named
        .iter()
        .any(|(n, v)| (n == "list" || n == "map") && matches!(v, Value::Map(_)))
}

/// Coerce a value into map entries. A map yields its entries; the empty list
/// `()` is the empty map; any other value is not a map (an error).
fn as_map(v: &Value, fname: &str, pos: Pos) -> Result<Vec<(Value, Value)>, Error> {
    match v {
        Value::Map(m) => Ok(m.entries.as_ref().clone()),
        // The empty list doubles as the empty map.
        Value::List(l) if l.items.is_empty() => Ok(Vec::new()),
        other => Err(Error::at(
            format!("$map: {} is not a map for `{fname}`.", other.to_css(false)),
            pos,
        )),
    }
}

fn unitless(value: f64) -> Value {
    Value::Number(Number::unitless(value))
}

/// A comma list of the given items. dart-sass `map-keys`/`map-values` always
/// return a comma-separated list, even when empty (so `list.separator()` of an
/// empty result reports `comma`).
fn comma_list(items: Vec<Value>) -> Value {
    Value::List(List {
        items: items.into(),
        sep: ListSep::Comma,
        bracketed: false,
        keywords: None,
    })
}

/// Collect the `($key, $keys...)` arguments of a nested map accessor. The first
/// key is `$key` (positional or named), the rest is the `$keys...` splat (all
/// further positional arguments). dart-sass requires at least the one `$key`.
fn key_path<'v>(
    pos_args: &'v [Value],
    named: &'v [(String, Value)],
    pos: Pos,
) -> Result<Vec<&'v Value>, Error> {
    let mut keys: Vec<&Value> = Vec::new();
    if let Some(first) = pos_args.get(1) {
        keys.push(first);
    } else if let Some((_, v)) = named.iter().find(|(n, _)| n == "key") {
        keys.push(v);
    }
    if keys.is_empty() {
        return Err(Error::at("Missing argument $key.".to_string(), pos));
    }
    keys.extend(pos_args.iter().skip(2));
    Ok(keys)
}

/// `map-get($map, $key, $keys...)`: the value at the nested key path, or `null`
/// when any key along the path is absent (or an intermediate value is not a map).
fn fn_map_get(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let map_v = super::require(&["map"], pos_args, named, 0, pos)?;
    let mut entries = as_map(map_v, "map-get", pos)?;
    let keys = key_path(pos_args, named, pos)?;
    for (i, key) in keys.iter().enumerate() {
        let found = entries
            .iter()
            .find(|(k, _)| k.sass_eq(key))
            .map(|(_, v)| v.clone());
        match found {
            Some(v) => {
                if i + 1 == keys.len() {
                    return Ok(v);
                }
                // Descend; a non-map intermediate value means "not found".
                match &v {
                    Value::Map(m) => entries = m.entries.as_ref().clone(),
                    Value::List(l) if l.items.is_empty() => entries = Vec::new(),
                    _ => return Ok(Value::Null),
                }
            }
            None => return Ok(Value::Null),
        }
    }
    Ok(Value::Null)
}

/// Reject more positional arguments than a fixed-arity function accepts
/// (dart-sass "Only N argument(s) allowed, but M were passed.").
fn check_arity(pos_args: &[Value], named: &[(String, Value)], max: usize, pos: Pos) -> Result<(), Error> {
    super::check_arity(max, pos_args, named, pos)
}

/// `map-keys($map)`: a comma list of the map's keys in order.
fn fn_map_keys(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    check_arity(pos_args, named, 1, pos)?;
    let map_v = super::require(&["map"], pos_args, named, 0, pos)?;
    let entries = as_map(map_v, "map-keys", pos)?;
    Ok(comma_list(entries.into_iter().map(|(k, _)| k).collect()))
}

/// `map-values($map)`: a comma list of the map's values in order.
fn fn_map_values(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    check_arity(pos_args, named, 1, pos)?;
    let map_v = super::require(&["map"], pos_args, named, 0, pos)?;
    let entries = as_map(map_v, "map-values", pos)?;
    Ok(comma_list(entries.into_iter().map(|(_, v)| v).collect()))
}

/// `map-has-key($map, $key, $keys...)`: whether the map contains the nested key
/// path.
fn fn_map_has_key(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let map_v = super::require(&["map"], pos_args, named, 0, pos)?;
    let mut entries = as_map(map_v, "map-has-key", pos)?;
    let keys = key_path(pos_args, named, pos)?;
    for (i, key) in keys.iter().enumerate() {
        let found = entries
            .iter()
            .find(|(k, _)| k.sass_eq(key))
            .map(|(_, v)| v.clone());
        match found {
            Some(v) => {
                if i + 1 == keys.len() {
                    return Ok(Value::Bool(true));
                }
                match &v {
                    Value::Map(m) => entries = m.entries.as_ref().clone(),
                    Value::List(l) if l.items.is_empty() => entries = Vec::new(),
                    _ => return Ok(Value::Bool(false)),
                }
            }
            None => return Ok(Value::Bool(false)),
        }
    }
    Ok(Value::Bool(false))
}

/// Merge `b`'s entries into `a` (shallow): `a` keeps its order, shared keys take
/// `b`'s value, and `b`'s new keys append in order.
fn shallow_merge(a: Vec<(Value, Value)>, b: Vec<(Value, Value)>) -> Map {
    let mut map = Map::new(a);
    for (k, v) in b {
        map.insert(k, v);
    }
    map
}

/// Borrow a value's map entries when it is a map (or the empty list, which
/// doubles as the empty map), else `None`.
fn entries_of(v: &Value) -> Option<Vec<(Value, Value)>> {
    match v {
        Value::Map(m) => Some(m.entries.as_ref().clone()),
        Value::List(l) if l.items.is_empty() => Some(Vec::new()),
        _ => None,
    }
}

/// Recursively merge `b` into `a`: a value that is a map in *both* operands is
/// merged in turn; otherwise `b`'s value wins (dart-sass `deepMergeImpl`). The
/// empty list `()` counts as the empty map on either side.
fn deep_merge(a: Vec<(Value, Value)>, b: Vec<(Value, Value)>) -> Map {
    let mut map = Map::new(a);
    for (k, v) in b {
        let merged = match (map.get(&k).and_then(entries_of), entries_of(&v)) {
            (Some(existing), Some(incoming)) => Value::Map(deep_merge(existing, incoming)),
            _ => v,
        };
        map.insert(k, merged);
    }
    map
}

/// Navigate `entries` along `keys`, build maps for missing/non-map nodes, apply
/// `transform` to the value at the leaf, and rebuild the map spine. With an
/// empty `keys` the transform applies to the whole map directly.
fn modify_map(
    entries: Vec<(Value, Value)>,
    keys: &[&Value],
    transform: &mut dyn FnMut(Option<Value>) -> Value,
) -> Vec<(Value, Value)> {
    match keys.split_first() {
        None => {
            // No keys: transform receives the whole map and replaces it.
            match transform(Some(Value::Map(Map::new(entries)))) {
                Value::Map(m) => m.entries.as_ref().clone(),
                // A non-map result at the root degrades to an empty map spine;
                // callers always pass at least the map itself for this case.
                _ => Vec::new(),
            }
        }
        Some((key, rest)) => {
            let mut map = Map::new(entries);
            let child = map.get(key).cloned();
            let new_child = if rest.is_empty() {
                transform(child)
            } else {
                let child_entries = match child {
                    Some(Value::Map(m)) => m.entries.as_ref().clone(),
                    Some(Value::List(l)) if l.items.is_empty() => Vec::new(),
                    _ => Vec::new(),
                };
                Value::Map(Map::new(modify_map(child_entries, rest, transform)))
            };
            map.insert((*key).clone(), new_child);
            map.entries.as_ref().clone()
        }
    }
}

/// `map-merge($map1, $map2)` or the nested `map-merge($map1, $keys..., $map2)`:
/// merge `$map2` into the (possibly nested) submap of `$map1` at the key path.
fn fn_map_merge(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    merge_impl(pos_args, named, pos, false)
}

/// `map-deep-merge($map1, $map2)`: like `map-merge` but recursive.
fn fn_map_deep_merge(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    merge_impl(pos_args, named, pos, true)
}

/// Shared body for `map.merge` / `map.deep-merge`. With named `$map1`/`$map2`
/// the call is the simple two-map form; otherwise the first positional argument
/// is `$map1`, the last is `$map2`, and the keys in between form the nested path.
fn merge_impl(pos_args: &[Value], named: &[(String, Value)], pos: Pos, deep: bool) -> Result<Value, Error> {
    let merge = |a: Vec<(Value, Value)>, b: Vec<(Value, Value)>| {
        if deep {
            deep_merge(a, b)
        } else {
            shallow_merge(a, b)
        }
    };
    // Resolve `$map1` (positional 0 or named) and the path/`$map2`.
    let map1_v = super::require(&["map1"], pos_args, named, 0, pos)?;
    let map1 = as_map_named(map1_v, "map1", pos)?;
    if pos_args.len() <= 1 {
        // Two-map form via named `$map2`.
        let map2_v = named
            .iter()
            .find(|(n, _)| n == "map2")
            .map(|(_, v)| v)
            .ok_or_else(|| Error::at("Missing argument $map2.".to_string(), pos))?;
        let map2 = as_map_named(map2_v, "map2", pos)?;
        return Ok(Value::Map(merge(map1, map2)));
    }
    // Positional form: last arg is `$map2`, middle args are the key path.
    let map2_v = &pos_args[pos_args.len() - 1];
    let map2 = as_map_named(map2_v, "map2", pos)?;
    let keys: Vec<&Value> = pos_args[1..pos_args.len() - 1].iter().collect();
    if keys.is_empty() {
        return Ok(Value::Map(merge(map1, map2)));
    }
    let mut transform = |child: Option<Value>| {
        let child_entries = match child {
            Some(Value::Map(m)) => m.entries.as_ref().clone(),
            Some(Value::List(l)) if l.items.is_empty() => Vec::new(),
            _ => Vec::new(),
        };
        Value::Map(merge(child_entries, map2.clone()))
    };
    Ok(Value::Map(Map::new(modify_map(map1, &keys, &mut transform))))
}

/// `map-set($map, $key, $keys..., $value)`: set the value at the nested key
/// path, creating maps along the way. Requires the map, at least one key, and a
/// value (the last argument).
fn fn_map_set(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let map_v = super::require(&["map"], pos_args, named, 0, pos)?;
    let entries = as_map_named(map_v, "map", pos)?;
    // Named two-arg form `map.set($map, $key, $value)` via $key/$value.
    let named_key = named.iter().find(|(n, _)| n == "key").map(|(_, v)| v);
    let named_value = named.iter().find(|(n, _)| n == "value").map(|(_, v)| v);
    let (keys, value): (Vec<&Value>, &Value) = match (named_key, named_value) {
        (Some(k), Some(v)) => (vec![k], v),
        _ => {
            // Positional: $map, then keys..., then $value (the last positional).
            if pos_args.len() < 3 {
                return Err(Error::at("Expected $args to contain a key.", pos));
            }
            let value = &pos_args[pos_args.len() - 1];
            let keys = pos_args[1..pos_args.len() - 1].iter().collect();
            (keys, value)
        }
    };
    let mut transform = |_old: Option<Value>| value.clone();
    Ok(Value::Map(Map::new(modify_map(entries, &keys, &mut transform))))
}

/// `map-remove($map, $keys...)`: drop every entry whose key matches one of the
/// `$keys`. The `$keys` rest is positional; a single key may also be passed as
/// the named `$key` (but not mixed with positional keys).
fn fn_map_remove(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let map_v = super::require(&["map"], pos_args, named, 0, pos)?;
    let mut entries = as_map_named(map_v, "map", pos)?;
    // Every argument after the map is a positional key to remove.
    let mut keys: Vec<Value> = pos_args.iter().skip(1).cloned().collect();
    // A named `$key` provides a single key, but mixing it with positional rest
    // keys is the same argument supplied twice (dart-sass errors).
    if let Some((_, v)) = named.iter().find(|(n, _)| n == "key") {
        if !keys.is_empty() {
            return Err(Error::at(
                "Argument $keys was passed both by position and by name.",
                pos,
            ));
        }
        keys.push(v.clone());
    }
    entries.retain(|(k, _)| !keys.iter().any(|rk| rk.sass_eq(k)));
    Ok(Value::Map(Map::new(entries)))
}

/// `map-deep-remove($map, $key, $keys...)`: remove the entry at the nested key
/// path. Needs at least one key (dart-sass).
fn fn_map_deep_remove(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let map_v = super::require(&["map"], pos_args, named, 0, pos)?;
    let entries = as_map_named(map_v, "map", pos)?;
    let keys = key_path(pos_args, named, pos)?;
    // The last key is removed; the keys before it locate the parent submap.
    let (last, parents) = match keys.split_last() {
        Some(pair) => pair,
        None => return Ok(Value::Map(Map::new(entries))),
    };
    Ok(Value::Map(Map::new(deep_remove(entries, parents, last))))
}

/// Navigate `entries` along `parents`; at the located submap, drop `last`. A
/// missing intermediate map leaves the structure unchanged.
fn deep_remove(entries: Vec<(Value, Value)>, parents: &[&Value], last: &Value) -> Vec<(Value, Value)> {
    match parents.split_first() {
        None => {
            let mut entries = entries;
            entries.retain(|(k, _)| !k.sass_eq(last));
            entries
        }
        Some((key, rest)) => {
            let mut map = Map::new(entries);
            if let Some(Value::Map(child)) = map.get(key).cloned().as_ref() {
                let new_child = deep_remove(child.entries.as_ref().clone(), rest, last);
                map.insert((*key).clone(), Value::Map(Map::new(new_child)));
            }
            map.entries.as_ref().clone()
        }
    }
}

/// Coerce a value into map entries with a parameter-named error message
/// (`$map1: 1 is not a map.`) matching dart-sass.
fn as_map_named(v: &Value, param: &str, pos: Pos) -> Result<Vec<(Value, Value)>, Error> {
    match v {
        Value::Map(m) => Ok(m.entries.as_ref().clone()),
        Value::List(l) if l.items.is_empty() => Ok(Vec::new()),
        other => Err(Error::at(
            format!("${param}: {} is not a map.", other.to_css(false)),
            pos,
        )),
    }
}

/// `length($map)`: the number of entries.
fn fn_length(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let map_v = super::require(&["map"], pos_args, named, 0, pos)?;
    let entries = as_map(map_v, "length", pos)?;
    Ok(unitless(entries.len() as f64))
}

/// `nth($map, $n)`: the 1-based (negative-from-end) entry as a `key value`
/// space list.
fn fn_nth(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["list", "n"];
    let map_v = super::require(&params, pos_args, named, 0, pos)?;
    let entries = as_map(map_v, "nth", pos)?;
    let n = super::require(&params, pos_args, named, 1, pos)?;
    let raw = super::num(n, pos)?;
    if raw.fract() != 0.0 {
        return Err(Error::at(
            format!("$n: {} is not an int.", crate::value::fmt_num(raw, false)),
            pos,
        ));
    }
    let len = entries.len() as i64;
    let index = raw as i64;
    if index == 0 {
        return Err(Error::at("$n: List index may not be 0.", pos));
    }
    if index.abs() > len {
        return Err(Error::at(
            format!(
                "$n: Invalid index {} for a list with {} element{}.",
                crate::value::fmt_num(raw, false),
                len,
                if len == 1 { "" } else { "s" }
            ),
            pos,
        ));
    }
    let zero_based = if index > 0 { index - 1 } else { len + index } as usize;
    let (k, v) = entries[zero_based].clone();
    Ok(Value::List(List {
        items: vec![k, v].into(),
        sep: ListSep::Space,
        bracketed: false,
        keywords: None,
    }))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::value::SassStr;

    fn pos() -> Pos {
        Pos { line: 1, col: 1 }
    }

    fn s(text: &str) -> Value {
        Value::Str(SassStr {
            text: text.into(),
            quoted: false,
        })
    }

    fn n(value: f64) -> Value {
        unitless(value)
    }

    fn map(pairs: &[(&str, Value)]) -> Value {
        Value::Map(Map::new(pairs.iter().map(|(k, v)| (s(k), v.clone())).collect()))
    }

    fn call(name: &str, args: &[Value]) -> Value {
        try_call(name, args, &[], pos())
            .expect("name owned by map family")
            .expect("no error")
    }

    #[test]
    fn map_get_returns_value_or_null() {
        let m = map(&[("c", s("d"))]);
        assert_eq!(call("map-get", &[m.clone(), s("c")]).to_css(false), "d");
        assert!(matches!(call("map-get", &[m, s("z")]), Value::Null));
    }

    #[test]
    fn map_keys_and_values_are_comma_lists() {
        let m = map(&[("c", n(1.0)), ("d", n(2.0))]);
        assert_eq!(call("map-keys", std::slice::from_ref(&m)).to_css(false), "c, d");
        assert_eq!(call("map-values", &[m]).to_css(false), "1, 2");
    }

    #[test]
    fn map_has_key_reports_presence() {
        let m = map(&[("c", s("d"))]);
        assert_eq!(call("map-has-key", &[m.clone(), s("c")]).to_css(false), "true");
        assert_eq!(call("map-has-key", &[m, s("z")]).to_css(false), "false");
    }

    #[test]
    fn map_merge_overwrites_and_appends() {
        let a = map(&[("c", s("d"))]);
        let b = map(&[("e", s("f"))]);
        assert_eq!(call("map-merge", &[a, b]).to_css(false), "(c: d, e: f)");
        let a = map(&[("c", n(1.0))]);
        let b = map(&[("c", n(2.0))]);
        assert_eq!(call("map-merge", &[a, b]).to_css(false), "(c: 2)");
    }

    #[test]
    fn map_remove_drops_keys() {
        let m = map(&[("c", s("d")), ("x", s("y"))]);
        assert_eq!(call("map-remove", &[m, s("c")]).to_css(false), "(x: y)");
    }

    #[test]
    fn length_and_nth_on_maps() {
        let m = map(&[("c", n(1.0)), ("d", n(2.0))]);
        assert_eq!(call("length", std::slice::from_ref(&m)).to_css(false), "2");
        assert_eq!(call("nth", &[m, n(1.0)]).to_css(false), "c 1");
    }

    #[test]
    fn length_and_nth_decline_non_maps() {
        // A non-map first argument leaves these for the list family.
        assert!(try_call("length", &[s("x")], &[], pos()).is_none());
        assert!(try_call("nth", &[s("x"), n(1.0)], &[], pos()).is_none());
    }

    #[test]
    fn empty_list_acts_as_empty_map() {
        let empty = Value::List(List {
            items: Vec::new().into(),
            sep: ListSep::Space,
            bracketed: false,
            keywords: None,
        });
        assert_eq!(call("map-keys", std::slice::from_ref(&empty)).to_css(false), "");
        assert!(matches!(call("map-get", &[empty, s("a")]), Value::Null));
    }
}
