//! Meta / introspection built-ins (`type-of`, `unit`, `unitless`,
//! `comparable`, `inspect`).
//!
//! `if()` is not handled here — the evaluator implements it lazily.
//!
//! Shared argument helpers live in the parent module:
//! `super::{arg, require, num, as_color, channel, clamp01}`. Return
//! `Some(Ok(..))`/`Some(Err(..))` for a name this family owns, or `None`
//! to let the next family try.

use crate::error::Error;
use crate::scanner::Pos;
use crate::value::{CalcNode, List, ListSep, SassStr, Value};

/// The names the meta family owns by name (the single source of truth,
/// mirroring the `try_call` arms below — including `get-function`, which is
/// dispatched ahead of the `match` but is still owned by this family).
pub(super) const NAMES: &[&str] = &[
    "get-function",
    "type-of",
    "unit",
    "unitless",
    "comparable",
    "inspect",
    "feature-exists",
    "function-exists",
    "calc-name",
    "calc-args",
];

pub(super) fn try_call(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    // `get-function` validates arity/type here; a well-formed call needs a
    // function reference, which this value-only layer cannot construct, so
    // `fn_get_function` returns `None` to fall through to verbatim CSS.
    if name == "get-function" {
        return fn_get_function(pos_args, named, pos);
    }
    // Fixed-arity members reject extra positional arguments before running.
    let max = match name {
        "type-of" | "unit" | "unitless" | "inspect" | "feature-exists" | "calc-name" | "calc-args" => Some(1),
        "comparable" => Some(2),
        _ => None,
    };
    if let Some(max) = max {
        if let Err(e) = super::check_arity(max, pos_args, named, pos) {
            return Some(Err(e));
        }
    }
    Some(match name {
        "type-of" => fn_type_of(pos_args, named, pos),
        "unit" => fn_unit(pos_args, named, pos),
        "unitless" => fn_unitless(pos_args, named, pos),
        "comparable" => fn_comparable(pos_args, named, pos),
        "inspect" => fn_inspect(pos_args, named, pos),
        "feature-exists" => fn_feature_exists(pos_args, named, pos),
        "function-exists" => fn_function_exists(pos_args, named, pos),
        "calc-name" => fn_calc_name(pos_args, named, pos),
        "calc-args" => fn_calc_args(pos_args, named, pos),
        _ => return None,
    })
}

/// `meta.calc-name($calc)`: the calculation's function name as a quoted string
/// (`"calc"`, `"min"`, `"clamp"`, …).
fn fn_calc_name(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let v = super::require(&["calc"], pos_args, named, 0, pos)?;
    match v {
        Value::Calc(node) => {
            let name = match node {
                CalcNode::Func { name, .. } => name.as_str(),
                _ => "calc",
            };
            Ok(Value::Str(SassStr {
                text: name.into(),
                quoted: true,
            }))
        }
        other => Err(Error::at(
            format!("$calc: {} is not a calculation.", other.to_css(false)),
            pos,
        )),
    }
}

/// `meta.calc-args($calc)`: the calculation's arguments as a comma-separated
/// list. A `calc()` holds a single argument (its expression): a bare number
/// stays a number, a nested operation becomes an unquoted string, and any other
/// operand (a `var()`/interpolation result) is its unquoted string.
fn fn_calc_args(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let v = super::require(&["calc"], pos_args, named, 0, pos)?;
    match v {
        // A function calculation (`min`/`clamp`/…) exposes its own arguments; a
        // bare `calc()` has a single argument, its expression.
        Value::Calc(CalcNode::Func { args, .. }) => Ok(Value::List(List::new(
            args.iter().map(calc_node_to_value).collect::<Vec<Value>>(),
            ListSep::Comma,
            false,
        ))),
        Value::Calc(node) => Ok(Value::List(List::new(
            vec![calc_node_to_value(node)],
            ListSep::Comma,
            false,
        ))),
        other => Err(Error::at(
            format!("$calc: {} is not a calculation.", other.to_css(false)),
            pos,
        )),
    }
}

/// Convert one calculation argument node to the Sass value `meta.calc-args`
/// returns for it: a number stays a number; a nested function calculation stays
/// a calculation; an operation or any opaque operand becomes an unquoted string.
fn calc_node_to_value(node: &CalcNode) -> Value {
    match node {
        CalcNode::Number(n) => Value::Number(n.clone()),
        CalcNode::Str(s) => Value::Str(SassStr {
            text: s.clone().into(),
            quoted: false,
        }),
        CalcNode::Func { .. } => Value::Calc(node.clone()),
        CalcNode::Op { .. } => Value::Str(SassStr {
            text: node.to_calc_css(false).into(),
            quoted: false,
        }),
    }
}

/// An unquoted string value.
fn unquoted(text: impl Into<String>) -> Value {
    Value::Str(SassStr {
        text: text.into().into(),
        quoted: false,
    })
}

/// A quoted string value.
fn quoted(text: impl Into<String>) -> Value {
    Value::Str(SassStr {
        text: text.into().into(),
        quoted: true,
    })
}

/// `type-of($value)`: the value's type as an unquoted string
/// (`number`, `string`, `color`, `list`, `bool`, `null`).
fn fn_type_of(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let v = super::require(&["value"], pos_args, named, 0, pos)?;
    Ok(unquoted(v.type_name()))
}

/// `unit($number)`: the number's unit as a *quoted* string (`"px"`, `"%"`,
/// or `""` for a unitless number). Errors on a non-number, matching
/// dart-sass.
fn fn_unit(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let v = super::require(&["number"], pos_args, named, 0, pos)?;
    match v {
        Value::Number(n) => Ok(quoted(n.unit_string())),
        other => Err(Error::at(
            format!("$number: {} is not a number.", other.to_css(false)),
            pos,
        )),
    }
}

/// `unitless($number)`: `true` when the number carries no unit. Errors on a
/// non-number.
fn fn_unitless(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let v = super::require(&["number"], pos_args, named, 0, pos)?;
    match v {
        Value::Number(n) => Ok(Value::Bool(n.is_unitless())),
        other => Err(Error::at(
            format!("$number: {} is not a number.", other.to_css(false)),
            pos,
        )),
    }
}

/// `comparable($number1, $number2)`: `true` when the two numbers' units are
/// compatible — either operand unitless, or the full unit lists convert.
fn fn_comparable(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["number1", "number2"];
    let a = super::require(&params, pos_args, named, 0, pos)?;
    let b = super::require(&params, pos_args, named, 1, pos)?;
    let num_of = |v: &Value, which: &str| -> Result<crate::value::Number, Error> {
        match v {
            Value::Number(n) => Ok(n.clone()),
            other => Err(Error::at(
                format!("${which}: {} is not a number.", other.to_css(false)),
                pos,
            )),
        }
    };
    let na = num_of(a, "number1")?;
    let nb = num_of(b, "number2")?;
    // dart `isComparableTo`: a unitless number is comparable to anything;
    // otherwise the FULL unit lists must convert (so `1px` vs the true
    // quotient `1px^-1` of `1/1px` is NOT comparable).
    let compatible = na.is_unitless()
        || nb.is_unitless()
        || crate::value::unit_lists_factor(
            (na.numer_units(), na.denom_units()),
            (nb.numer_units(), nb.denom_units()),
        )
        .is_some();
    Ok(Value::Bool(compatible))
}

/// `feature-exists($feature)`: `true` when `$feature` names a Sass language
/// feature this implementation supports. dart-sass recognizes a fixed set of
/// feature names (accepting both quoted and unquoted strings); any other name
/// is `false`, and a non-string argument is an error.
fn fn_feature_exists(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let v = super::require(&["feature"], pos_args, named, 0, pos)?;
    let name = match v {
        Value::Str(s) => &s.text,
        other => {
            return Err(Error::at(
                format!("$feature: {} is not a string.", other.to_css(false)),
                pos,
            ))
        }
    };
    // The canonical dart-sass feature set (all long-stable language features).
    let known = matches!(
        name.as_ref(),
        "global-variable-shadowing"
            | "extend-selector-pseudoclass"
            | "units-level-3"
            | "at-error"
            | "custom-property"
    );
    Ok(Value::Bool(known))
}

/// `function-exists($name, $module: null)`: whether a function with the given
/// name is available. dart-sass validates arity (1–2 args) and that `$name` is
/// a string, then checks the current scope. This value-only layer cannot see
/// user-defined functions, so it recognizes built-in functions via the
/// dispatcher's ownership probe and reports `false` otherwise — which matches
/// dart-sass for built-ins and for genuinely-absent names. (A `$module`
/// argument requires `@use`, which is unsupported, so it is accepted and
/// ignored.)
fn fn_function_exists(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["name", "module"];
    super::check_arity(params.len(), pos_args, named, pos)?;
    let v = super::require(&params, pos_args, named, 0, pos)?;
    let name = match v {
        Value::Str(s) => &s.text,
        other => {
            return Err(Error::at(
                format!("$name: {} is not a string.", other.to_css(false)),
                pos,
            ))
        }
    };
    Ok(Value::Bool(super::is_builtin(name)))
}

/// `get-function($name, $css: false, $module: null)`: returns a reference to
/// the named function. This value-only layer has no function-reference value
/// and no view of user-defined functions, so it only enforces the validation
/// dart-sass performs *before* resolution — arity (1–3 args) and that `$name`
/// is a string — and otherwise declines (`None`), letting a well-formed call
/// fall through to verbatim CSS. Returning `Some(Err(..))` for the bad-arity /
/// bad-type cases converts those spec cases from a silent pass-through into the
/// error dart-sass raises.
fn fn_get_function(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Option<Result<Value, Error>> {
    let params = ["name", "css", "module"];
    if let Err(e) = super::check_arity(params.len(), pos_args, named, pos) {
        return Some(Err(e));
    }
    let v = match super::arg(&params, pos_args, named, 0) {
        Some(v) => v,
        None => return Some(Err(Error::at("Missing argument $name.", pos))),
    };
    match v {
        Value::Str(_) => None,
        other => Some(Err(Error::at(
            format!("$name: {} is not a string.", other.to_css(false)),
            pos,
        ))),
    }
}

/// `inspect($value)`: an unquoted string with the value's debug
/// representation, matching dart-sass's `inspect()` — quoted strings keep
/// their quotes, `null` becomes `null`, the empty list becomes `()`, and a
/// single-element comma list keeps its trailing comma `(x,)`.
fn fn_inspect(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let v = super::require(&["value"], pos_args, named, 0, pos)?;
    Ok(unquoted(inspect_value(v)))
}

/// Serialize a value as dart-sass `inspect()` would. Bracketed lists are
/// wrapped in `[...]`; an unbracketed empty list is `()` and a single-element
/// comma list keeps its trailing comma `(x,)`. Maps render `(k: v, …)` with
/// nested keys/values inspected recursively.
pub(crate) fn inspect_value(v: &Value) -> String {
    match v {
        Value::Null => "null".to_string(),
        Value::Str(s) => {
            if s.quoted {
                // dart `_visitQuotedString`: single quotes when the text has a
                // `"` and no `'`, and the quote and backslash escaped — a naive
                // `"{text}"` turns `a"b` into INVALID CSS.
                crate::value::serialize_quoted(&s.text)
            } else {
                // `_visitUnquotedString`, and so its private-use escape, runs
                // HERE: dart inspects with `serializeValue(inspect: true)`,
                // whose style is the default one, and hands back a string that
                // already carries `\e000` — long enough to change
                // `string.length`, and ASCII enough to leave a compressed
                // stylesheet without the BOM a raw character would earn it.
                crate::value::serialize_unquoted(&s.text, false)
            }
        }
        Value::List(l) => {
            let sep_str = match l.sep {
                ListSep::Comma => ", ",
                ListSep::Space | ListSep::Undecided => " ",
                ListSep::Slash => " / ",
            };
            let body = match l.items.len() {
                0 => {
                    // An unbracketed empty list is `()`; a bracketed one is `[]`.
                    return if l.bracketed {
                        "[]".to_string()
                    } else {
                        "()".to_string()
                    };
                }
                1 if l.sep == ListSep::Comma => {
                    format!("{},", inspect_element(&l.items[0], l.sep))
                }
                1 if l.sep == ListSep::Slash => {
                    // A single-element slash list keeps a trailing `/` (no spaces),
                    // mirroring the comma list's trailing `,`.
                    format!("{}/", inspect_element(&l.items[0], l.sep))
                }
                _ => l
                    .items
                    .iter()
                    .map(|e| inspect_element(e, l.sep))
                    .collect::<Vec<_>>()
                    .join(sep_str),
            };
            if l.bracketed {
                format!("[{body}]")
            } else if l.items.len() == 1 && matches!(l.sep, ListSep::Comma | ListSep::Slash) {
                // An unbracketed single-element comma/slash list needs its own
                // parens: `(1,)` / `(1/)`.
                format!("({body})")
            } else {
                body
            }
        }
        Value::Map(m) => {
            if m.entries.is_empty() {
                return "()".to_string();
            }
            // Map keys and values sit in a comma-separated context, so a
            // comma-list key/value is parenthesized (dart-sass).
            let inner = m
                .entries
                .iter()
                .map(|(k, val)| format!("{}: {}", inspect_map_element(k), inspect_map_element(val)))
                .collect::<Vec<_>>()
                .join(", ");
            format!("({inner})")
        }
        // A color inspects in dart's `inspect: true` serializer mode: hwb
        // keeps its own `hwb(...)` form, and out-of-gamut rgb skips the hsl
        // reroute (see `ModernColor::inspect_css`).
        Value::Color(c) => c.inspect_css(),
        // Numbers and booleans inspect exactly as they serialize.
        other => other.to_css(false),
    }
}

/// Serialize a list element, adding surrounding parentheses when dart-sass
/// would: a multi-element *unbracketed* list nested in a comma parent needs
/// parens only when it is itself comma-separated; nested in a space parent, any
/// multi-element unbracketed list needs them. A bracketed list carries its own
/// `[...]`, and empty / single-element comma lists carry their own parens via
/// [`inspect_value`].
/// Serialize a map key or value, matching dart-sass's `_writeMapElement`: an
/// unbracketed comma-separated list is wrapped in parens regardless of length,
/// so an empty arglist becomes `(())`. `inspect_element` only wraps lists of
/// length >= 1, so the empty-comma case is handled here; everything else
/// defers to it (a comma parent, since map entries sit in a comma context).
fn inspect_map_element(v: &Value) -> String {
    if let Value::List(l) = v {
        if l.items.is_empty() && l.sep == ListSep::Comma && !l.bracketed {
            return format!("({})", inspect_value(v));
        }
    }
    inspect_element(v, ListSep::Comma)
}

pub(crate) fn inspect_element(v: &Value, parent_sep: ListSep) -> String {
    if let Value::List(l) = v {
        // A 2+-element list, or a single-element comma list (`(1,)`, whose own
        // serialization already carries parens), is wrapped again when nested in
        // a list/map that would otherwise swallow its separator.
        let single_comma = l.items.len() == 1 && l.sep == ListSep::Comma;
        let candidate = !l.bracketed && (l.items.len() >= 2 || single_comma);
        if candidate {
            let needs_parens = match parent_sep {
                ListSep::Comma => l.sep == ListSep::Comma,
                // A single-element comma list already disambiguates itself in a
                // space context (`(1,) 2`), so it is NOT re-wrapped there; a
                // 2+-element list still is. (Undecided behaves like space.)
                ListSep::Space | ListSep::Undecided => !single_comma,
                ListSep::Slash => l.sep == ListSep::Comma || l.sep == ListSep::Slash,
            };
            if needs_parens {
                return format!("({})", inspect_value(v));
            }
        }
    }
    inspect_value(v)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::value::{Color, List, Number};

    fn pos() -> Pos {
        Pos { line: 1, col: 1 }
    }

    fn n(value: f64, unit: &str) -> Value {
        Value::Number(Number::with_unit(value, unit))
    }

    fn sq(text: &str) -> Value {
        Value::Str(SassStr {
            text: text.into(),
            quoted: true,
        })
    }

    fn su(text: &str) -> Value {
        Value::Str(SassStr {
            text: text.into(),
            quoted: false,
        })
    }

    fn list(items: Vec<Value>, sep: ListSep) -> Value {
        Value::List(List::new(items, sep, false))
    }

    fn call(name: &str, args: &[Value]) -> Value {
        try_call(name, args, &[], pos())
            .expect("name owned by meta family")
            .expect("no error")
    }

    fn call_err(name: &str, args: &[Value]) -> Error {
        try_call(name, args, &[], pos())
            .expect("name owned by meta family")
            .expect_err("expected error")
    }

    #[test]
    fn type_of_reports_type_name() {
        assert_eq!(call("type-of", &[n(1.0, "px")]).to_css(false), "number");
        assert_eq!(call("type-of", &[sq("hi")]).to_css(false), "string");
        assert_eq!(
            call("type-of", &[Value::Color(Color::rgb(255.0, 0.0, 0.0, 1.0))]).to_css(false),
            "color"
        );
        assert_eq!(
            call("type-of", &[list(vec![n(1.0, ""), n(2.0, "")], ListSep::Comma)]).to_css(false),
            "list"
        );
        assert_eq!(call("type-of", &[Value::Bool(true)]).to_css(false), "bool");
        assert_eq!(call("type-of", &[Value::Null]).to_css(false), "null");
    }

    #[test]
    fn unit_is_quoted() {
        assert_eq!(call("unit", &[n(1.0, "px")]).to_css(false), "\"px\"");
        assert_eq!(call("unit", &[n(5.0, "%")]).to_css(false), "\"%\"");
        assert_eq!(call("unit", &[n(5.0, "")]).to_css(false), "\"\"");
        assert!(call_err("unit", &[sq("x")]).message.contains("is not a number"));
    }

    #[test]
    fn unitless_reports_bool() {
        assert!(matches!(call("unitless", &[n(5.0, "")]), Value::Bool(true)));
        assert!(matches!(call("unitless", &[n(5.0, "px")]), Value::Bool(false)));
    }

    #[test]
    fn comparable_unit_groups() {
        let t = |a: Value, b: Value| matches!(call("comparable", &[a, b]), Value::Bool(true));
        assert!(t(n(1.0, "px"), n(2.0, "px")));
        assert!(t(n(1.0, "px"), n(2.0, "cm")));
        assert!(t(n(1.0, "in"), n(2.0, "pt")));
        assert!(t(n(1.0, "px"), n(5.0, ""))); // unitless
        assert!(t(n(5.0, ""), n(5.0, "")));
        assert!(t(n(1.0, "deg"), n(1.0, "turn")));
        assert!(t(n(1.0, "s"), n(1.0, "ms")));
        assert!(t(n(1.0, "Hz"), n(1.0, "kHz")));
        assert!(t(n(1.0, "dpi"), n(1.0, "dppx")));
        assert!(t(n(1.0, "foo"), n(1.0, "foo"))); // identical unknown units

        assert!(!t(n(1.0, "px"), n(1.0, "em")));
        assert!(!t(n(1.0, "px"), n(5.0, "%")));
        assert!(!t(n(1.0, "Q"), n(1.0, "in"))); // Q has no length factor
        assert!(!t(n(1.0, "foo"), n(1.0, "bar")));
        assert!(!t(n(1.0, "px"), n(1.0, "s")));
    }

    #[test]
    fn inspect_scalars() {
        assert_eq!(call("inspect", &[sq("hi")]).to_css(false), "\"hi\"");
        assert_eq!(call("inspect", &[su("hi")]).to_css(false), "hi");
        assert_eq!(call("inspect", &[Value::Null]).to_css(false), "null");
        assert_eq!(call("inspect", &[n(1.0, "px")]).to_css(false), "1px");
        assert_eq!(call("inspect", &[Value::Bool(true)]).to_css(false), "true");
        let red = Color {
            r: 255.0,
            g: 0.0,
            b: 0.0,
            a: 1.0,
            repr: Some("red".into()),
            modern: None,
        };
        assert_eq!(call("inspect", &[Value::Color(red)]).to_css(false), "red");
        // A computed color inspects as its css form.
        assert_eq!(
            call("inspect", &[Value::Color(Color::rgb(255.0, 0.0, 0.0, 1.0))]).to_css(false),
            "#ff0000"
        );
    }

    #[test]
    fn inspect_lists() {
        // top-level comma/space lists: no outer parens
        assert_eq!(
            call(
                "inspect",
                &[list(vec![n(1.0, ""), n(2.0, ""), n(3.0, "")], ListSep::Comma)]
            )
            .to_css(false),
            "1, 2, 3"
        );
        assert_eq!(
            call(
                "inspect",
                &[list(vec![n(1.0, ""), n(2.0, ""), n(3.0, "")], ListSep::Space)]
            )
            .to_css(false),
            "1 2 3"
        );
        // empty list
        assert_eq!(
            call("inspect", &[list(vec![], ListSep::Space)]).to_css(false),
            "()"
        );
        // single-element comma list keeps trailing comma
        assert_eq!(
            call("inspect", &[list(vec![n(1.0, "")], ListSep::Comma)]).to_css(false),
            "(1,)"
        );
    }

    #[test]
    fn inspect_nested_lists() {
        let comma2 = |a: Value, b: Value| list(vec![a, b], ListSep::Comma);
        let space2 = |a: Value, b: Value| list(vec![a, b], ListSep::Space);

        // comma list nested in comma parent -> parens
        assert_eq!(
            call(
                "inspect",
                &[comma2(
                    n(1.0, ""),
                    list(vec![n(2.0, ""), n(3.0, "")], ListSep::Comma)
                )]
            )
            .to_css(false),
            "1, (2, 3)"
        );
        // space list nested in comma parent -> no parens
        assert_eq!(
            call(
                "inspect",
                &[comma2(
                    n(1.0, ""),
                    list(vec![n(2.0, ""), n(3.0, "")], ListSep::Space)
                )]
            )
            .to_css(false),
            "1, 2 3"
        );
        // space lists nested in a space parent -> parens
        assert_eq!(
            call(
                "inspect",
                &[space2(
                    list(vec![n(1.0, ""), n(2.0, "")], ListSep::Space),
                    list(vec![n(3.0, ""), n(4.0, "")], ListSep::Space)
                )]
            )
            .to_css(false),
            "(1 2) (3 4)"
        );
        // comma lists nested in a space parent -> parens
        assert_eq!(
            call(
                "inspect",
                &[space2(
                    list(vec![n(1.0, ""), n(2.0, "")], ListSep::Comma),
                    list(vec![n(3.0, ""), n(4.0, "")], ListSep::Comma)
                )]
            )
            .to_css(false),
            "(1, 2) (3, 4)"
        );
        // single-element comma list nested in a space parent keeps its own parens
        assert_eq!(
            call(
                "inspect",
                &[space2(list(vec![n(1.0, "")], ListSep::Comma), n(2.0, ""))]
            )
            .to_css(false),
            "(1,) 2"
        );
        // empty list nested keeps its own parens
        assert_eq!(
            call("inspect", &[comma2(list(vec![], ListSep::Space), n(1.0, ""))]).to_css(false),
            "(), 1"
        );
    }

    #[test]
    fn feature_exists_known_set() {
        let t = |name: &str, quoted: bool| {
            call(
                "feature-exists",
                &[Value::Str(SassStr {
                    text: name.into(),
                    quoted,
                })],
            )
        };
        assert!(matches!(t("at-error", false), Value::Bool(true)));
        assert!(matches!(t("custom-property", true), Value::Bool(true)));
        assert!(matches!(t("global-variable-shadowing", false), Value::Bool(true)));
        assert!(matches!(t("nope", false), Value::Bool(false)));
        // A non-string argument errors.
        assert!(call_err("feature-exists", &[n(1.0, "")])
            .message
            .contains("is not a string"));
    }

    #[test]
    fn rejects_unknown_names() {
        assert!(try_call("frobnicate", &[Value::Null], &[], pos()).is_none());
    }
}
