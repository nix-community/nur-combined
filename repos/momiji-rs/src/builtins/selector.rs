//! The `sass:selector` built-in functions, global spellings.
//!
//! `selector-nest`, `selector-append`, `selector-extend`, `selector-replace`,
//! `selector-unify`, `is-superselector`, `simple-selectors`, and
//! `selector-parse`. Each accepts and returns *selector values*: a selector
//! list is a comma-separated Sass list of complex selectors, and each complex
//! selector is a space-separated Sass list whose items are compound-selector
//! strings interleaved with combinator strings (`>`/`+`/`~`), all unquoted
//! (dart-sass `ComplexSelector.asSassList`).
//!
//! The heavy lifting (parsing, superselector tests, compound/complex
//! unification, parent weaving, and the extend engine) lives in
//! [`crate::selector`]; this module only marshals Sass values to/from selector
//! strings, resolves `&` parent references for `nest`/`append`, validates
//! arguments, and serializes results.

use crate::error::Error;
use crate::scanner::Pos;
use crate::selector::{self, Complex};
// `Compound` is referenced via the fully-qualified `crate::selector::Compound`
// path in `compound_target`'s signature.
use crate::value::{List, ListSep, SassStr, Value};

/// The names the selector family owns by name (the single source of truth,
/// mirroring the `try_call` match arms below).
pub(super) const NAMES: &[&str] = &[
    "selector-nest",
    "selector-append",
    "selector-extend",
    "selector-replace",
    "selector-unify",
    "is-superselector",
    "simple-selectors",
    "selector-parse",
];

pub(super) fn try_call(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    Some(match name {
        "selector-nest" => fn_nest(pos_args, named, pos),
        "selector-append" => fn_append(pos_args, named, pos),
        "selector-extend" => fn_extend(pos_args, named, pos),
        "selector-replace" => fn_replace(pos_args, named, pos),
        "selector-unify" => fn_unify(pos_args, named, pos),
        "is-superselector" => fn_is_superselector(pos_args, named, pos),
        "simple-selectors" => fn_simple_selectors(pos_args, named, pos),
        "selector-parse" => fn_parse(pos_args, named, pos),
        _ => return None,
    })
}

// ---- arity validation -------------------------------------------------

/// Reject more positional arguments than `max` (dart-sass "Only N argument(s)
/// allowed, but M were passed."). Used by the fixed-arity selector functions;
/// `selector-nest` and `selector-append` are variadic and skip this.
fn check_arity(pos_args: &[Value], named: &[(String, Value)], max: usize, pos: Pos) -> Result<(), Error> {
    super::check_arity(max, pos_args, named, pos)
}

// ---- value <-> selector-string marshalling ----------------------------

/// Convert a Sass value into its selector-string form (dart-sass
/// `_selectorString`). The structure is restricted to at most two list levels:
/// a string; a space list of strings; or a comma list whose items are each a
/// string or a space list of strings. A slash list, a deeper nesting, or any
/// non-string/list value is rejected — matching dart-sass exactly (a comma
/// inside a space list, or a list inside a space list, is *not* valid).
fn value_to_selector_string(v: &Value, pname: &str, pos: Pos) -> Result<String, Error> {
    /// A space list of strings → ` `-joined; a lone string → its text. Returns
    /// `None` for anything else (a comma/slash list, or a nested list).
    fn space_or_string(v: &Value) -> Option<String> {
        match v {
            Value::Str(s) => Some(s.text.to_string()),
            Value::List(l) if l.sep == ListSep::Space && !l.items.is_empty() => {
                let mut parts = Vec::with_capacity(l.items.len());
                for item in l.items.iter() {
                    match item {
                        Value::Str(s) => parts.push(s.text.to_string()),
                        _ => return None,
                    }
                }
                Some(parts.join(" "))
            }
            _ => None,
        }
    }
    fn render(v: &Value) -> Option<String> {
        match v {
            Value::Str(s) => Some(s.text.to_string()),
            Value::List(l) if l.items.is_empty() => None,
            Value::List(l) => match l.sep {
                ListSep::Comma => {
                    let mut parts = Vec::with_capacity(l.items.len());
                    for item in l.items.iter() {
                        parts.push(space_or_string(item)?);
                    }
                    Some(parts.join(", "))
                }
                // An undecided list here is single-element, so treat it like a
                // space-separated one.
                ListSep::Space | ListSep::Undecided => space_or_string(v),
                // A slash-separated list is not a valid selector.
                ListSep::Slash => None,
            },
            _ => None,
        }
    }
    render(v).ok_or_else(|| {
        Error::at(
            format!(
                "${pname}: {} is not a valid selector: it must be a string,\na list of strings, or a list of lists of strings.",
                v.to_css(true)
            ),
            pos,
        )
    })
}

/// Read the selector argument at `i` as a parsed selector list, erroring like
/// dart-sass on a non-selector value, empty selector, or parse failure.
fn selector_list_arg(
    params: &[&str],
    pos_args: &[Value],
    named: &[(String, Value)],
    i: usize,
    pos: Pos,
) -> Result<Vec<Complex>, Error> {
    let v = super::require(params, pos_args, named, i, pos)?;
    let pname = params.get(i).copied().unwrap_or("selector");
    let text = value_to_selector_string(v, pname, pos)?;
    parse_selector_text(&text, pname, pos)
}

/// Parse a selector string into a list of complex selectors, erroring with
/// dart-sass's `${pname}: expected selector.` on empty/unparseable input.
fn parse_selector_text(text: &str, pname: &str, pos: Pos) -> Result<Vec<Complex>, Error> {
    if text.trim().is_empty() {
        return Err(Error::at(format!("${pname}: expected selector."), pos));
    }
    // Normalize like the main pipeline first: dart splits adjacent compounds
    // (`[c]d` parses as the descendant `[c] d`).
    let normalized = crate::eval::normalize_selector(text);
    selector::parse_list(&normalized).ok_or_else(|| Error::at(format!("${pname}: expected selector."), pos))
}

// ---- serialization back to a selector value ---------------------------

/// Serialize a list of complex selectors into a selector *value*: a comma list
/// of space lists (each a complex selector's compound/combinator parts), all
/// unquoted strings. A single complex selector still produces the comma list
/// wrapper (length 1), matching dart-sass.
fn selectors_to_value(complexes: &[Complex]) -> Value {
    let items: Vec<Value> = complexes.iter().map(complex_to_value).collect();
    Value::List(List {
        items: items.into(),
        sep: ListSep::Comma,
        bracketed: false,
        keywords: None,
    })
}

/// Serialize one complex selector as a space list of its parts (compounds and
/// combinators) as unquoted strings.
fn complex_to_value(c: &Complex) -> Value {
    let parts = selector::complex_to_list_parts(c);
    let items: Vec<Value> = parts
        .into_iter()
        .map(|text| {
            Value::Str(SassStr {
                text: text.into(),
                quoted: false,
            })
        })
        .collect();
    // A single-component complex selector is still a (one-element) space list.
    Value::List(List {
        items: items.into(),
        sep: ListSep::Space,
        bracketed: false,
        keywords: None,
    })
}

// ---- `&` parent resolution (for nest / append) ------------------------

/// Resolve the child selector string `child` against the parent selector list
/// `parents`, returning the resolved selector list (dart-sass
/// `SelectorList.resolveParentSelectors` over each parent). A child complex that
/// contains a top-level `&` substitutes the parent in place (parent-major
/// order); one without `&` is nested as a descendant of each parent.
fn resolve_parents_str(child: &str, parents: &[String], fname: &str, pos: Pos) -> Result<Vec<String>, Error> {
    let parent_str = parents.join(", ");
    let parent_strs: Vec<String> = parents.to_vec();
    let child_complexes = split_top_commas(child);
    // dart-sass parses each nested selector with parent references allowed, so a
    // `&` that is not at the start of a compound selector is rejected up front.
    for cc in &child_complexes {
        validate_parent_placement(cc)?;
    }
    // Per-child expansions: a top-level `&` expands as a cartesian product
    // over the parent complexes (each occurrence picks independently, the
    // last varying fastest); a `&` inside a selector pseudo receives the
    // WHOLE parent list (`:is(&)` -> `:is(c, d)`); a child without `&` nests
    // under every parent. The groups are then flattened column-major
    // (dart-sass `flattenVertically`).
    let mut groups: Vec<Vec<String>> = Vec::new();
    for cc in &child_complexes {
        if has_parent_ref(cc) {
            groups.push(expand_parent_refs(cc, &parent_strs, &parent_str));
        } else {
            groups.push(parent_strs.iter().map(|p| format!("{p} {}", cc.trim())).collect());
        }
    }
    let mut out: Vec<String> = Vec::new();
    for resolved in flatten_vertically(groups) {
        // Validate by parsing — except when the result still carries a
        // literal `&` (a parent that was itself `&`), which stays raw.
        if has_parent_ref(&resolved) {
            out.push(resolved);
            continue;
        }
        let parsed = selector::parse_list(&resolved)
            .ok_or_else(|| Error::at(format!("Invalid selector produced by {fname}(): {resolved}"), pos))?;
        out.extend(parsed.iter().map(Complex::render));
    }
    if out.is_empty() {
        // No `&` and no parents shouldn't happen (parents is non-empty), but
        // guard against an empty result.
        return Ok(parse_selector_text(&parent_str, "selectors", pos)?
            .iter()
            .map(Complex::render)
            .collect());
    }
    Ok(out)
}

/// Serialize complex-selector strings into a selector value: a comma list of
/// space lists (each string split on top-level whitespace), all unquoted.
/// Handles strings a parsed [`Complex`] can't represent (a literal `&`).
fn selector_strings_to_value(complexes: &[String]) -> Value {
    let items: Vec<Value> = complexes
        .iter()
        .map(|c| {
            let parts = split_top_ws(c);
            Value::List(List {
                items: parts
                    .into_iter()
                    .map(|text| {
                        Value::Str(SassStr {
                            text: text.into(),
                            quoted: false,
                        })
                    })
                    .collect(),
                sep: ListSep::Space,
                bracketed: false,
                keywords: None,
            })
        })
        .collect();
    Value::List(List {
        items: items.into(),
        sep: ListSep::Comma,
        bracketed: false,
        keywords: None,
    })
}

/// Split a complex-selector string on top-level whitespace (outside quotes,
/// parens, and brackets).
fn split_top_ws(s: &str) -> Vec<String> {
    let mut out = Vec::new();
    let mut cur = String::new();
    let mut depth = 0i32;
    let mut chars = s.chars().peekable();
    while let Some(c) = chars.next() {
        match c {
            '\\' => {
                cur.push(c);
                if let Some(n) = chars.next() {
                    cur.push(n);
                }
            }
            '"' | '\'' => {
                cur.push(c);
                let q = c;
                for n in chars.by_ref() {
                    cur.push(n);
                    if n == q {
                        break;
                    }
                }
            }
            '(' | '[' => {
                depth += 1;
                cur.push(c);
            }
            ')' | ']' => {
                depth -= 1;
                cur.push(c);
            }
            c if c.is_whitespace() && depth == 0 => {
                if !cur.is_empty() {
                    out.push(std::mem::take(&mut cur));
                }
            }
            _ => cur.push(c),
        }
    }
    if !cur.is_empty() {
        out.push(cur);
    }
    out
}

/// dart-sass `flattenVertically`: flatten a list of groups column-major —
/// the first element of every group, then the second, … (`[[a,b],[c,d]]` →
/// `[a,c,b,d]`).
fn flatten_vertically(groups: Vec<Vec<String>>) -> Vec<String> {
    if groups.len() == 1 {
        return groups.into_iter().next().unwrap_or_default();
    }
    let mut queues: Vec<std::collections::VecDeque<String>> = groups.into_iter().map(|g| g.into()).collect();
    let mut out = Vec::new();
    while !queues.is_empty() {
        queues.retain_mut(|q| {
            if let Some(v) = q.pop_front() {
                out.push(v);
            }
            !q.is_empty()
        });
    }
    out
}

/// Validate that every top-level `&` in a child complex selector appears at the
/// start of a compound selector (start of the part, or right after a combinator
/// or whitespace), matching dart-sass's parser. A `&` elsewhere (e.g. `d&`,
/// `[d]&`) errors with `"&" may only used at the beginning of a compound
/// selector.`. Quoted strings and the contents of `[…]`/`(…)` groups are
/// skipped.
fn validate_parent_placement(s: &str) -> Result<(), Error> {
    let chars: Vec<char> = s.chars().collect();
    let mut i = 0usize;
    let mut at_compound_start = true;
    let mut depth = 0i32;
    while i < chars.len() {
        let c = chars[i];
        match c {
            '\\' => {
                i += 2;
                at_compound_start = false;
                continue;
            }
            '"' | '\'' => {
                let q = c;
                i += 1;
                while i < chars.len() {
                    if chars[i] == '\\' {
                        i += 2;
                        continue;
                    }
                    if chars[i] == q {
                        i += 1;
                        break;
                    }
                    i += 1;
                }
                at_compound_start = false;
                continue;
            }
            '[' | '(' => {
                depth += 1;
                at_compound_start = false;
            }
            ']' | ')' => {
                depth -= 1;
                at_compound_start = false;
            }
            _ if depth > 0 => {}
            ' ' | '\t' | '\n' | '\r' | '>' | '+' | '~' => at_compound_start = true,
            '&' => {
                if !at_compound_start {
                    return Err(Error::unpositioned(
                        "\"&\" may only used at the beginning of a compound selector.",
                    ));
                }
                at_compound_start = false;
            }
            _ => at_compound_start = false,
        }
        i += 1;
    }
    Ok(())
}

/// Whether a complex-selector string has a top-level `&` (outside brackets,
/// parens, and quotes), i.e. a parent reference this resolver substitutes.
/// Whether `s` contains a `&` parent reference. dart-sass substitutes a `&`
/// wherever it appears in selector position, including inside a selector-list
/// pseudo (`:is(&)`, `:not(&)`), so any paren depth counts; a `&` inside a
/// quoted string, an escape, or an attribute value (`[x=&]`) is literal and
/// does not.
fn has_parent_ref(s: &str) -> bool {
    let mut bracket = 0i32;
    let mut chars = s.chars().peekable();
    while let Some(c) = chars.next() {
        match c {
            '\\' => {
                chars.next();
            }
            '"' | '\'' => {
                let q = c;
                for n in chars.by_ref() {
                    if n == '\\' {
                        continue;
                    }
                    if n == q {
                        break;
                    }
                }
            }
            '[' => bracket += 1,
            ']' => bracket -= 1,
            '&' if bracket == 0 => return true,
            _ => {}
        }
    }
    false
}

/// Replace every unescaped, unquoted top-level `&` in `s` with `parent`. The
/// text directly following a `&` joins onto the parent's last compound by string
/// adjacency (e.g. `&.y` with parent `.a .b` becomes `.a .b.y`).
fn expand_parent_refs(s: &str, parents: &[String], parent_list: &str) -> Vec<String> {
    let mut variants: Vec<String> = vec![String::new()];
    let mut chars = s.chars().peekable();
    let mut paren = 0i32;
    let push_all = |variants: &mut Vec<String>, text: &str| {
        for v in variants.iter_mut() {
            v.push_str(text);
        }
    };
    while let Some(c) = chars.next() {
        match c {
            '\\' => {
                let mut t = String::from(c);
                if let Some(n) = chars.next() {
                    t.push(n);
                }
                push_all(&mut variants, &t);
            }
            '"' | '\'' => {
                let mut t = String::from(c);
                let q = c;
                for n in chars.by_ref() {
                    t.push(n);
                    if n == q {
                        break;
                    }
                }
                push_all(&mut variants, &t);
            }
            '(' => {
                paren += 1;
                push_all(&mut variants, "(");
            }
            ')' => {
                paren -= 1;
                push_all(&mut variants, ")");
            }
            // Inside a selector pseudo the parent reference receives the
            // whole parent LIST (`:is(&)` -> `:is(c, d)`).
            '&' if paren > 0 => push_all(&mut variants, parent_list),
            // A top-level `&` expands as a cartesian product: each occurrence
            // picks a parent complex independently, the last varying fastest.
            '&' => {
                variants = variants
                    .iter()
                    .flat_map(|v| parents.iter().map(move |p| format!("{v}{p}")))
                    .collect();
            }
            _ => push_all(&mut variants, &c.to_string()),
        }
    }
    variants
}

/// Split a selector-list string on top-level commas (depth-aware), trimming.
fn split_top_commas(s: &str) -> Vec<String> {
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
            '"' | '\'' => {
                cur.push(c);
                let q = c;
                for n in chars.by_ref() {
                    cur.push(n);
                    if n == q {
                        break;
                    }
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
            ',' if paren == 0 && bracket == 0 => out.push(std::mem::take(&mut cur)),
            _ => cur.push(c),
        }
    }
    out.push(cur);
    out.into_iter().filter(|p| !p.trim().is_empty()).collect()
}

// ---- nest -------------------------------------------------------------

/// `selector-nest($selectors...)`: nest each selector within the previous,
/// resolving `&` against the accumulated result (dart-sass `nest`).
fn fn_nest(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let mut all: Vec<Value> = pos_args.to_vec();
    for (_, v) in named {
        all.push(v.clone());
    }
    if all.is_empty() {
        return Err(Error::at(
            "$selectors: At least one selector must be passed.".to_string(),
            pos,
        ));
    }
    // The first selector is the base; it MAY contain `&`, which stays
    // literal (dart-sass parses it with parent references allowed):
    // `nest("&")` is `&`, `nest("&", ".x")` is `& .x`.
    let first = value_to_selector_string(&all[0], "selectors", pos)?;
    let mut acc: Vec<String> = if has_parent_ref(&first) {
        let parts = split_top_commas(&first);
        for cc in &parts {
            validate_parent_placement(cc)?;
            // A top-level `&` may not carry a suffix (`&c`) — dart-sass
            // rejects it when parsing the first argument.
            let chars: Vec<char> = cc.chars().collect();
            for (i, ch) in chars.iter().enumerate() {
                if *ch == '&' {
                    if let Some(n) = chars.get(i + 1) {
                        if n.is_alphanumeric() || *n == '-' || *n == '_' || *n == '\\' {
                            return Err(Error::at(
                                "A top-level selector may not contain a parent selector with a suffix."
                                    .to_string(),
                                pos,
                            ));
                        }
                    }
                }
            }
        }
        parts.iter().map(|p| p.trim().to_string()).collect()
    } else {
        parse_arg_selector(&all[0], pos)?
            .iter()
            .map(Complex::render)
            .collect()
    };
    for v in &all[1..] {
        let child = value_to_selector_string(v, "selectors", pos)?;
        acc = resolve_parents_str(&child, &acc, "selector-nest", pos)?;
    }
    Ok(selector_strings_to_value(&acc))
}

/// Parse a single selector value argument into a complex-selector list.
fn parse_arg_selector(v: &Value, pos: Pos) -> Result<Vec<Complex>, Error> {
    let text = value_to_selector_string(v, "selectors", pos)?;
    parse_selector_text(&text, "selectors", pos)
}

// ---- append -----------------------------------------------------------

/// `selector-append($selectors...)`: append each selector to the previous with
/// no descendant combinator — the leading compound of each subsequent complex
/// merges onto the trailing compound of the accumulator (dart-sass `append`).
fn fn_append(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let mut all: Vec<Value> = pos_args.to_vec();
    for (_, v) in named {
        all.push(v.clone());
    }
    if all.is_empty() {
        return Err(Error::at(
            "$selectors: At least one selector must be passed.".to_string(),
            pos,
        ));
    }
    let mut acc = parse_arg_selector(&all[0], pos)?;
    for v in &all[1..] {
        let suffix = parse_arg_selector(v, pos)?;
        acc = append_lists(&acc, &suffix, pos)?;
    }
    Ok(selectors_to_value(&acc))
}

/// Append `suffix` to `prefix`: for each prefix complex × suffix complex, the
/// suffix's leading compound (which must carry no combinator) is concatenated
/// onto the prefix's trailing compound; the rest of the suffix follows
/// (dart-sass `append`/`_prependParent`).
fn append_lists(prefix: &[Complex], suffix: &[Complex], pos: Pos) -> Result<Vec<Complex>, Error> {
    let mut out: Vec<Complex> = Vec::new();
    for p in prefix {
        // A parent with a trailing combinator (`.c ~`) can't be appended onto.
        if !p.trailing.is_empty() {
            return Err(Error::at(
                format!(
                    "Selector \"{}\" can't be used as a parent in a compound selector.",
                    p.render()
                ),
                pos,
            ));
        }
        let p_one = p.render();
        for s in suffix {
            // The first component of the suffix must have no combinator, and its
            // leading simple may not be a universal selector or a namespaced type
            // selector (those can't suffix another compound), matching dart-sass
            // `_prependParent`.
            let s_str = s.render();
            // A combinator-only suffix (`>`) has no compound to append.
            if s.components.is_empty() {
                return Err(Error::at(format!("Can't append {s_str} to {p_one}."), pos));
            }
            if let Some(first) = s.components.first() {
                let leading_blocks_append = matches!(
                    first.compound.simples.first(),
                    Some(crate::selector::Simple::Universal { .. })
                ) || matches!(
                    first.compound.simples.first(),
                    Some(crate::selector::Simple::Type(t)) if t.contains('|')
                );
                if first.combinator().is_some() || leading_blocks_append {
                    return Err(Error::at(format!("Can't append {s_str} to {p_one}."), pos));
                }
            }
            // Concatenate the prefix and the suffix's leading compound by string
            // adjacency, so `.a` + `.b.c` → `.a.b.c` and `ul` + `li` → `ulli`.
            let combined = format!("{p_one}{s_str}");
            let parsed = selector::parse_list(&combined)
                .ok_or_else(|| Error::at(format!("Can't append {s_str} to {p_one}."), pos))?;
            out.extend(parsed);
        }
    }
    Ok(out)
}

// ---- extend / replace -------------------------------------------------

/// `selector-extend($selector, $extendee, $extender)`: extend `$selector` so
/// that wherever `$extendee` matches, `$extender` is added too (keeping the
/// original). Mirrors `@extend` (normal mode).
fn fn_extend(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    extend_or_replace(pos_args, named, pos, false, "selector-extend")
}

/// `selector-replace($selector, $original, $replacement)`: like `selector-extend`
/// but the matched selector is replaced (the original is dropped).
fn fn_replace(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    extend_or_replace(pos_args, named, pos, true, "selector-replace")
}

fn extend_or_replace(
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    replace: bool,
    fname: &str,
) -> Result<Value, Error> {
    let params: &[&str] = if replace {
        &["selector", "original", "replacement"]
    } else {
        &["selector", "extendee", "extender"]
    };
    check_arity(pos_args, named, 3, pos)?;
    let selector = selector_list_arg(params, pos_args, named, 0, pos)?;
    let target_list = selector_list_arg(params, pos_args, named, 1, pos)?;
    let extender = selector_list_arg(params, pos_args, named, 2, pos)?;

    // The extendee/original is a list of compound selectors: each complex
    // selector in it must be a single compound (dart-sass rejects a complex
    // selector here). Every compound becomes a separate extension target.
    let targets = compound_targets(&target_list, pos)?;

    let complexes = selector::extend_compound_target(&selector, &targets, &extender, replace);
    if complexes.is_empty() {
        return Err(Error::at(format!("{fname}() produced an empty selector."), pos));
    }
    Ok(selectors_to_value(&complexes))
}

/// Extract the compound targets of an extendee/original selector list. The list
/// may contain several complex selectors, but each must itself be a single
/// compound (dart-sass rejects a complex selector with a combinator or multiple
/// components, erroring `Can't extend complex selector <rendered>.`).
fn compound_targets(list: &[Complex], pos: Pos) -> Result<Vec<crate::selector::Compound>, Error> {
    let mut out = Vec::with_capacity(list.len());
    for complex in list {
        if complex.components.len() == 1 && complex.components[0].combinator().is_none() {
            out.push(complex.components[0].compound.clone());
        } else {
            return Err(Error::at(
                format!("Can't extend complex selector {}.", complex.render()),
                pos,
            ));
        }
    }
    Ok(out)
}

// ---- unify ------------------------------------------------------------

/// `selector-unify($selector1, $selector2)`: the selectors matching both inputs,
/// or `null` when no combination unifies (dart-sass `unify`).
fn fn_unify(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = &["selector1", "selector2"];
    check_arity(pos_args, named, 2, pos)?;
    let s1 = selector_list_arg(params, pos_args, named, 0, pos)?;
    let s2 = selector_list_arg(params, pos_args, named, 1, pos)?;
    match selector::unify_lists(&s1, &s2) {
        Some(unified) => Ok(selectors_to_value(&unified)),
        None => Ok(Value::Null),
    }
}

// ---- is-superselector -------------------------------------------------

/// `is-superselector($super, $sub)`: whether `$super` matches every element
/// `$sub` matches (dart-sass `is-superselector`).
fn fn_is_superselector(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = &["super", "sub"];
    check_arity(pos_args, named, 2, pos)?;
    let sup = selector_list_arg(params, pos_args, named, 0, pos)?;
    let sub = selector_list_arg(params, pos_args, named, 1, pos)?;
    Ok(Value::Bool(selector::list_is_superselector(&sup, &sub)))
}

// ---- simple-selectors -------------------------------------------------

/// `simple-selectors($selector)`: the simple selectors of a single compound
/// selector, as a comma list of unquoted strings (dart-sass `simple-selectors`).
fn fn_simple_selectors(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = &["selector"];
    check_arity(pos_args, named, 1, pos)?;
    let v = super::require(params, pos_args, named, 0, pos)?;
    let text = value_to_selector_string(v, "selector", pos)?;
    if text.trim().is_empty() {
        return Err(Error::at("$selector: expected selector.".to_string(), pos));
    }
    let simples = selector::parse_compound_simples(&text)
        .ok_or_else(|| Error::at("$selector: expected selector.".to_string(), pos))?;
    let items: Vec<Value> = simples
        .into_iter()
        .map(|text| {
            Value::Str(SassStr {
                text: text.into(),
                quoted: false,
            })
        })
        .collect();
    Ok(Value::List(List {
        items: items.into(),
        sep: ListSep::Comma,
        bracketed: false,
        keywords: None,
    }))
}

// ---- parse ------------------------------------------------------------

/// `selector-parse($selector)`: parse a selector string/value into a selector
/// value (dart-sass `parse`).
fn fn_parse(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = &["selector"];
    check_arity(pos_args, named, 1, pos)?;
    let list = selector_list_arg(params, pos_args, named, 0, pos)?;
    Ok(selectors_to_value(&list))
}
