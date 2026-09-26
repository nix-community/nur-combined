use super::*;

/// Evaluate the `/` operator. When `slash` is set and both operands are
/// numbers, produce a slash-separated value that serializes as `a/b` but
/// behaves numerically as the quotient; otherwise perform real division.
pub(crate) fn eval_div(l: Value, r: Value, slash: bool, pos: Pos) -> Result<Value, Error> {
    if let Some(e) = callable_value_error(&l, &r, pos) {
        return Err(e);
    }
    // The parser only sets `slash` when both operands are numeric literals
    // (or themselves slash divisions), so they are always numbers here. The
    // slash-separated value keeps the authored `a/b` spelling; the carried
    // numeric quotient — used if the slash is later forced into arithmetic —
    // is the real division with full unit cancellation (`1/1px` carries
    // `1px^-1`, so `math.unit(1/1px)` reports `"px^-1"`).
    // Fast path: plain `number / number` (the overwhelmingly common case) —
    // no slash carry, no clone. `without_slash` is a no-op on a plain Number,
    // so this is behavior-identical to the first match arm below.
    if !slash {
        if let (Value::Number(a), Value::Number(b)) = (&l, &r) {
            return divide_numbers(a, b, pos);
        }
    }
    // The clones below are only reached for the slash-carry and non-number
    // cases; guarding on `slash` keeps the common path from building the
    // tuple's clones eagerly.
    if slash {
        if let (Value::Number(a), Value::Number(b)) = (l.clone().without_slash(), r.clone().without_slash()) {
            let repr = format!("{}/{}", slash_repr(&l), slash_repr(&r));
            return Ok(Value::Slash(a.div(&b), repr));
        }
    }
    match (l.clone().without_slash(), r.clone().without_slash()) {
        (Value::Number(a), Value::Number(b)) => divide_numbers(&a, &b, pos),
        // dart-sass: `SassColor.dividedBy` throws "Undefined operation" when
        // the right side is a number or another color; any other right side
        // (a string, `var()`, …) falls back to the slash join below
        // (`#AAA/#{itpl}` → `#AAA/itpl`).
        (lv @ Value::Color(_), rv @ (Value::Number(_) | Value::Color(_))) => {
            Err(undefined_op(&lv, "/", &rv, pos))
        }
        // Every other left/right pair (a calculation, `var()`, unquoted
        // string, list, `true`/`null`, or a number divided by a non-number)
        // forms a slash-separated unquoted string `left/right`, mirroring
        // dart-sass's default `Value.dividedBy`. This is what lets a `/` next
        // to a `calc()`/`var()` special value survive (and what carries the
        // alpha slash through `rgb(1 2 var(--x) / 0.4)`). A slash-division
        // operand keeps its chained spelling (`1/2/foo()`, not `0.5/foo()`).
        // A map or empty-list operand has no CSS serialization, so the slash
        // join itself errors (`() / 1` → `()`, `1 / (a: 1)` → `(a: 1)`).
        _ => {
            if let Some(e) = serialize_pair_error(&l, &r, pos) {
                return Err(e);
            }
            Ok(Value::Str(SassStr {
                text: format!("{}/{}", slash_repr(&l), slash_repr(&r)).into(),
                quoted: false,
            }))
        }
    }
}

/// Real division of two numbers with dart-sass unit semantics: division never
/// errors on units — convertible units cancel (scaling the value), and
/// whatever remains becomes the quotient's numerator/denominator lists
/// (`math.div(1, 1px)` -> `1px^-1`, `math.div(1px, 1s)` -> `1px/s`).
pub(super) fn divide_numbers(a: &Number, b: &Number, _pos: Pos) -> Result<Value, Error> {
    Ok(Value::Number(a.div(b)))
}

/// The slash-spelling text of an operand: a slash value keeps its chained
/// `a/b` text; any other value uses its plain CSS form.
pub(super) fn slash_repr(v: &Value) -> String {
    match v {
        Value::Slash(_, repr) => repr.clone(),
        other => other.to_css(false),
    }
}

pub(super) fn eval_binary(op: BinOp, l: Value, r: Value, pos: Pos) -> Result<Value, Error> {
    match op {
        BinOp::Add => binary_add(l, r, pos),
        BinOp::Sub => binary_sub(l, r, pos),
        BinOp::Mod => num_binop(l, r, pos, "%", sass_modulo),
        BinOp::Mul => binary_mul(l, r, pos),
        BinOp::Eq => Ok(Value::Bool(l.sass_eq(&r))),
        BinOp::Neq => Ok(Value::Bool(!l.sass_eq(&r))),
        BinOp::Lt => num_compare(l, r, pos, "<", |a, b| a < b),
        BinOp::Gt => num_compare(l, r, pos, ">", |a, b| a > b),
        BinOp::Le => num_compare(l, r, pos, "<=", |a, b| a <= b),
        BinOp::Ge => num_compare(l, r, pos, ">=", |a, b| a >= b),
        BinOp::And | BinOp::Or => Err(Error::unpositioned(
            "internal: and/or are short-circuited in eval_expr",
        )),
        // The single-`=` Microsoft-filter operator joins both evaluated sides
        // with `=` (no surrounding whitespace) into an unquoted string,
        // matching dart-sass (`alpha(opacity=80)` -> `alpha(opacity=80)`).
        BinOp::SingleEq => Ok(Value::Str(SassStr {
            text: format!("{}={}", l.to_css(false), r.to_css(false)).into(),
            quoted: false,
        })),
    }
}

pub(super) fn num_compare(
    l: Value,
    r: Value,
    pos: Pos,
    sym: &str,
    f: impl Fn(f64, f64) -> bool,
) -> Result<Value, Error> {
    match (l, r) {
        (Value::Number(a), Value::Number(b)) => {
            let (av, bv, _) = coerce_pair(&a, &b, pos)?;
            Ok(Value::Bool(f(av, bv)))
        }
        (l, r) => Err(undefined_op(&l, sym, &r, pos)),
    }
}

pub(super) fn binary_add(l: Value, r: Value, pos: Pos) -> Result<Value, Error> {
    if let (Value::Number(a), Value::Number(b)) = (&l, &r) {
        let (av, bv, proto) = coerce_pair(a, b, pos)?;
        return Ok(Value::Number(proto.copy_units(av + bv)));
    }
    // dart-sass removed color arithmetic: `color + color`/`color + number`
    // (either order) is "Undefined operation", not string concatenation.
    if color_arith_undefined(&l, &r) {
        return Err(undefined_op(&l, "+", &r, pos));
    }
    if let Some(e) = callable_value_error(&l, &r, pos) {
        return Err(e);
    }
    // A calculation can only be `+`-concatenated with a string; against any
    // other operand (number, color, bool, list, another calculation) dart-sass
    // raises "Undefined operation" rather than string-concatenating.
    let calc_with_nonstring = (matches!(&l, Value::Calc(_)) && !matches!(&r, Value::Str(_)))
        || (matches!(&r, Value::Calc(_)) && !matches!(&l, Value::Str(_)));
    if calc_with_nonstring {
        return Err(undefined_op(&l, "+", &r, pos));
    }
    // A map or empty list cannot be serialized for string concatenation, so
    // `map + x` / `() + x` errors like dart-sass with "(…) isn't a valid CSS
    // value." (`1 + ()` → `()`, `1 + (a: 1)` → `(a: 1)`).
    if let Some(e) = serialize_pair_error(&l, &r, pos) {
        return Err(e);
    }
    // String concatenation. When the left operand is a string the result keeps
    // the left string's quotedness; for any other left operand dart-sass's
    // default `Value.plus` quotes the result iff the right operand is a quoted
    // string (`1 + "x"` -> `"1x"`, `red + "x"` -> `"redx"`).
    let quoted = match &l {
        Value::Str(s) => s.quoted,
        _ => matches!(&r, Value::Str(s) if s.quoted),
    };
    let text = format!("{}{}", concat_str(&l), concat_str(&r));
    Ok(Value::Str(SassStr {
        text: text.into(),
        quoted,
    }))
}

/// The `-` (minus) operator. Two numbers subtract numerically (coercing to a
/// common unit); for any other operand pair dart-sass falls back to its
/// default `Value.minus`, an *unquoted* string join `<left>-<right>` where each
/// side keeps its own serialization (so quoted strings keep their quotes:
/// `"q" - 1` -> `"q"-1`). A `calc()` value has no `minus` overload and errors,
/// and a map cannot serialize as a CSS value.
pub(super) fn binary_sub(l: Value, r: Value, pos: Pos) -> Result<Value, Error> {
    if let (Value::Number(a), Value::Number(b)) = (&l, &r) {
        let (av, bv, proto) = coerce_pair(a, b, pos)?;
        return Ok(Value::Number(proto.copy_units(av - bv)));
    }
    // Removed color arithmetic: `color - color`/`color - number` (either
    // order) is "Undefined operation", not a string join.
    if color_arith_undefined(&l, &r) {
        return Err(undefined_op(&l, "-", &r, pos));
    }
    if let Some(e) = callable_value_error(&l, &r, pos) {
        return Err(e);
    }
    if matches!(&l, Value::Calc(_)) || matches!(&r, Value::Calc(_)) {
        return Err(undefined_op(&l, "-", &r, pos));
    }
    if let Some(e) = serialize_pair_error(&l, &r, pos) {
        return Err(e);
    }
    let text = format!("{}-{}", l.to_css(false), r.to_css(false));
    Ok(Value::Str(SassStr {
        text: text.into(),
        quoted: false,
    }))
}

pub(super) fn binary_mul(l: Value, r: Value, pos: Pos) -> Result<Value, Error> {
    match (l, r) {
        // Units multiply per dart-sass: convertible numerator/denominator
        // pairs cancel, the rest concatenate (`1px * 1em` -> `1px*em`,
        // serialized as `calc(1px * 1em)`).
        (Value::Number(a), Value::Number(b)) => Ok(Value::Number(a.mul(&b))),
        (l, r) => Err(undefined_op(&l, "*", &r, pos)),
    }
}

/// Sass modulo (dart `moduloLikeSass`): a floored modulo whose result takes
/// the divisor's sign. `1.2 % -4.7 == -3.5`, `-1.2 % 4.7 == 3.5`. An
/// infinite dividend (or a zero divisor) yields NaN; an infinite DIVISOR
/// returns the dividend when their signs agree (`1px % infinity*1px == 1px`,
/// signed zeros included) and NaN otherwise.
pub(super) fn sass_modulo(a: f64, b: f64) -> f64 {
    if a.is_infinite() {
        return f64::NAN;
    }
    if b.is_infinite() {
        // dart compares signIncludingZero, so `-0.0 % -infinity` is `-0.0`.
        return if a.is_sign_negative() == b.is_sign_negative() {
            a
        } else {
            f64::NAN
        };
    }
    if b == 0.0 {
        return f64::NAN;
    }
    a - b * (a / b).floor()
}

pub(super) fn num_binop(
    l: Value,
    r: Value,
    pos: Pos,
    sym: &str,
    f: impl Fn(f64, f64) -> f64,
) -> Result<Value, Error> {
    match (l, r) {
        (Value::Number(a), Value::Number(b)) => {
            let (av, bv, proto) = coerce_pair(&a, &b, pos)?;
            Ok(Value::Number(proto.copy_units(f(av, bv))))
        }
        (l, r) => Err(undefined_op(&l, sym, &r, pos)),
    }
}

/// Coerce two numbers onto common units for `+`, `-`, `%`, and comparison.
/// The result keeps the LEFT operand's units; the right operand is converted
/// into them (`1in + 1cm` → both in inches, result `in`). When exactly one
/// operand is unitless the other's units are adopted with no rescaling
/// (`5 + 1px` → `6px`). Incompatible units error, matching dart-sass's
/// `<a> and <b> have incompatible units.` (a multi-unit operand prints in its
/// calc form there).
///
/// Returns `(left_value, right_value, prototype)` with both values expressed
/// in the prototype's units (build the result via `prototype.copy_units(..)`).
pub(super) fn coerce_pair(a: &Number, b: &Number, pos: Pos) -> Result<(f64, f64, Number), Error> {
    let incompatible = || {
        Err(Error::at(
            format!(
                "{} and {} have incompatible units.",
                a.to_css(false),
                b.to_css(false)
            ),
            pos,
        ))
    };
    // A multi-unit operand coerces via full unit-list matching.
    if a.has_complex_units() || b.has_complex_units() {
        if b.is_unitless() {
            return Ok((a.value, b.value, a.clone()));
        }
        if a.is_unitless() {
            return Ok((a.value, b.value, b.clone()));
        }
        return match crate::value::unit_lists_factor(
            (b.numer_units(), b.denom_units()),
            (a.numer_units(), a.denom_units()),
        ) {
            Some(factor) => Ok((a.value, b.value * factor, a.clone())),
            None => incompatible(),
        };
    }
    // Identical units (exact strings, like dart) or a unitless operand never
    // need a numeric conversion.
    if a.unit() == b.unit() || b.is_unitless() {
        return Ok((a.value, b.value, a.clone()));
    }
    if a.is_unitless() {
        return Ok((a.value, b.value, b.clone()));
    }
    // Two distinct real units: convert the right into the left's unit.
    match crate::value::convert_factor(b.unit(), a.unit()) {
        Some(factor) => Ok((a.value, b.value * factor, a.clone())),
        None => incompatible(),
    }
}

pub(super) fn concat_str(v: &Value) -> String {
    match v {
        Value::Str(s) => s.text.to_string(),
        other => other.to_css(false),
    }
}

/// Whether a `+`/`-` operation is the removed color arithmetic that dart-sass
/// rejects with "Undefined operation": a color combined with another color or a
/// number. A color with a string (or other type) still string-concatenates via
/// the default `Value.plus`/`Value.minus`.
pub(super) fn color_arith_undefined(l: &Value, r: &Value) -> bool {
    let numeric = |v: &Value| matches!(v, Value::Color(_) | Value::Number(_));
    (matches!(l, Value::Color(_)) && numeric(r)) || (matches!(r, Value::Color(_)) && numeric(l))
}

/// A map or empty list cannot be serialized into the unquoted `left<op>right`
/// string that dart-sass's default `Value.plus`/`minus`/`dividedBy` build, so
/// such an operand makes the whole `+`/`-`/`/` join an error — checking the
/// left operand before the right, exactly as dart's left-then-right
/// serialization order surfaces it (`() / 1` → `()`, `1 / (a: 1)` → `(a: 1)`).
pub(super) fn serialize_pair_error(l: &Value, r: &Value, pos: Pos) -> Option<Error> {
    css_value_error_msg(l)
        .or_else(|| css_value_error_msg(r))
        .map(|msg| Error::at(msg, pos))
}

/// A first-class function or mixin reference is not a valid CSS value, so it
/// cannot appear in arithmetic or a slash: dart-sass errors "<inspect> isn't a
/// valid CSS value." for the first such operand (left before right).
pub(super) fn callable_value_error(l: &Value, r: &Value, pos: Pos) -> Option<Error> {
    for v in [l, r] {
        let inspect = match v {
            Value::Function(f) => Some(f.inspect()),
            Value::Mixin(m) => Some(m.inspect()),
            _ => None,
        };
        if let Some(s) = inspect {
            return Some(Error::at(format!("{s} isn't a valid CSS value."), pos));
        }
    }
    None
}

pub(super) fn undefined_op(l: &Value, sym: &str, r: &Value, pos: Pos) -> Error {
    Error::at(
        format!(
            "Undefined operation \"{} {} {}\".",
            l.to_css(false),
            sym,
            r.to_css(false)
        ),
        pos,
    )
}
