//! Math built-in functions.
//!
//! Unary unit-preserving ops (`abs`, `ceil`, `floor`, `round`), the
//! variadic bounds functions (`min`, `max`, `clamp`), powers/roots/logs
//! (`pow`, `sqrt`, `exp`, `log`), trigonometry (`sin`, `cos`, `tan`,
//! `asin`, `acos`, `atan`, `atan2`), `hypot`, `sign`, and the stepped
//! remainders (`rem`, `mod`). Each is unit-checked and byte-matched to
//! dart-sass.
//!
//! `min`/`max`/`clamp` reduce to a single number only when every argument
//! is a compatible-unit number; otherwise they fall back to a preserved CSS
//! `min()`/`max()`/`clamp()` call (so `min(1px, 2vw)` round-trips).
//!
//! Shared argument helpers live in the parent module. Return
//! `Some(Ok(..))`/`Some(Err(..))` for a name this family owns, or `None`
//! to let the next family try.

use crate::error::Error;
use crate::scanner::Pos;
use crate::value::{convert_factor, CalcNode, Number, Value};

/// The names the math family owns (the single source of truth, mirroring the
/// `unary_op` set plus the `try_call` match arms below). The math family
/// lowercases the name before dispatch (so `SiN` folds to `sin`), so these are
/// the *lowercase* names; `is_builtin` lowercases before testing membership.
pub(super) const NAMES: &[&str] = &[
    // `unary_op`
    "abs", "ceil", "floor", // `try_call` match arms
    "round", "min", "max", "clamp", "sign", "pow", "sqrt", "exp", "log", "hypot", "sin", "cos", "tan",
    "asin", "acos", "atan", "atan2", "rem", "mod", "random",
];

pub(super) fn try_call(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    // The math functions double as CSS calculation functions, which dart-sass
    // matches case-insensitively (`SiN(1deg)` folds to `sin(1deg)`). Lowercase
    // the name once and dispatch on that; every name this family owns is
    // unambiguous, so this can never steal a name from another family.
    let lname = name.to_ascii_lowercase();
    let name = lname.as_str();
    // Simple unit-preserving unary ops.
    if let Some(op) = unary_op(name) {
        return Some(unary(pos_args, named, pos, op));
    }
    match name {
        "round" => Some(round(pos_args, named, pos)),
        "min" => Some(min_max(name, pos_args, named, pos, true)),
        "max" => Some(min_max(name, pos_args, named, pos, false)),
        "clamp" => Some(clamp(pos_args, named, pos)),
        "sign" => Some(sign(pos_args, named, pos)),
        "pow" => Some(pow(pos_args, named, pos)),
        "sqrt" => Some(unitless_unary("number", pos_args, named, pos, f64::sqrt)),
        "exp" => Some(unitless_unary("number", pos_args, named, pos, f64::exp)),
        "log" => Some(log(pos_args, named, pos)),
        "hypot" => Some(hypot(pos_args, named, pos)),
        "sin" => Some(trig(pos_args, named, pos, f64::sin)),
        "cos" => Some(trig(pos_args, named, pos, f64::cos)),
        "tan" => Some(trig(pos_args, named, pos, f64::tan)),
        "asin" => Some(inverse_trig(pos_args, named, pos, f64::asin)),
        "acos" => Some(inverse_trig(pos_args, named, pos, f64::acos)),
        "atan" => Some(inverse_trig(pos_args, named, pos, f64::atan)),
        "atan2" => Some(atan2(pos_args, named, pos)),
        "rem" => Some(remainder("rem", pos_args, named, pos, true)),
        "mod" => Some(remainder("mod", pos_args, named, pos, false)),
        "random" => Some(random(pos_args, named, pos)),
        _ => None,
    }
}

fn unary_op(name: &str) -> Option<fn(f64) -> f64> {
    Some(match name {
        "abs" => f64::abs,
        "ceil" => ceil_int,
        "floor" => floor_int,
        _ => return None,
    })
}

/// A rounding RESULT is an int in dart, so it is never a negative zero:
/// `math.round(-0.4)`, `math.ceil(-0.4)` and `round(to-zero, -0.4, 1)` are all
/// `0`, where IEEE rounding gives `-0`. Two neighbours are NOT covered by
/// that: `math.abs(-0)` is `0` because IEEE `abs` clears the sign of its own
/// accord (dart's answer too), while `round()` with an INFINITE step returns
/// the input's sign unrounded, so `round(to-zero, -0.4, infinity)` IS `-0` —
/// it never reaches the multiply below. Everything else keeps the sign:
/// `math.div(0, -1)` and `math.sqrt(-0)` are negative zeros.
fn int_result(v: f64) -> f64 {
    if v == 0.0 {
        0.0
    } else {
        v
    }
}

fn ceil_int(v: f64) -> f64 {
    int_result(v.ceil())
}

fn floor_int(v: f64) -> f64 {
    int_result(v.floor())
}

/// `math.div($number1, $number2)`: true division. Unlike the `/` operator it
/// always divides (never produces a slash-separated value for two numbers),
/// reusing the evaluator's division so unit handling matches exactly.
pub(super) fn module_div(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["number1", "number2"];
    check_max_args(pos_args, named, 2, pos)?;
    let a = super::require(&params, pos_args, named, 0, pos)?.clone();
    let b = super::require(&params, pos_args, named, 1, pos)?.clone();
    crate::eval::eval_div(a, b, false, pos)
}

/// Reject a call with more POSITIONAL arguments than a fixed-arity function
/// accepts; named ones do not count toward the limit. `max_args` is the
/// function's declared arity. See [`super::check_arity`] for the wording rules
/// (singular/plural, and "positional" once a named argument is in play).
fn check_max_args(
    pos_args: &[Value],
    named: &[(String, Value)],
    max_args: usize,
    pos: Pos,
) -> Result<(), Error> {
    super::check_arity(max_args, pos_args, named, pos)
}

/// The rounding strategy keyword of a `round()` call's first argument.
#[derive(Clone, Copy, PartialEq)]
enum RoundStrategy {
    Nearest,
    Up,
    Down,
    ToZero,
}

impl RoundStrategy {
    fn from_str(s: &str) -> Option<Self> {
        Some(match s {
            "nearest" => RoundStrategy::Nearest,
            "up" => RoundStrategy::Up,
            "down" => RoundStrategy::Down,
            "to-zero" => RoundStrategy::ToZero,
            _ => return None,
        })
    }
}

/// `round()` as dart-sass's CSS `round()` calculation:
/// - `round(number)` — nearest, no step (half away from zero);
/// - `round(number, step)` — nearest with a step;
/// - `round(strategy, number, step)` — explicit strategy with a step.
///
/// Step is converted into the number's unit; non-finite operands and a zero
/// step follow the CSS spec (see `round_with_step`). Genuinely unsimplifiable
/// arguments (a `var()`, an unknown/incompatible unit pair, etc.) fall back to
/// a preserved `round(...)` form.
fn round(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    // A named argument (`round($number: …)`) forces the legacy one-argument
    // `math.round`, which requires an actual number rather than the CSS
    // `round()` calculation's preserve-on-unsimplifiable behaviour. Any other
    // named-argument shape falls through to the positional handling below,
    // which reports the arity/name error.
    if pos_args.is_empty() && named.len() == 1 && named[0].0 == "number" {
        let n = as_num(&named[0].1, pos)?;
        return Ok(num_value(n.copy_units(int_result(n.value.round()))));
    }
    let args = all_args(pos_args, named);
    match args.len() {
        0 => Err(Error::at("Missing argument.", pos)),
        1 => {
            // One-argument form: nearest, unit preserved. An unsimplifiable
            // argument (a `var()`, interpolation, …) preserves the call.
            match round_operand(&args[0], pos)? {
                Some(n) => Ok(num_value(n.copy_units(int_result(n.value.round())))),
                None => Ok(preserved_round(&args)),
            }
        }
        2 => {
            // A bare strategy keyword as the first of two args means the step
            // is missing: that errors when the value is a real number, but an
            // unsimplifiable value (`round(up, var(--c))`) preserves the call
            // verbatim, matching dart-sass.
            if let Value::Str(s) = &args[0] {
                if !s.quoted && RoundStrategy::from_str(&s.text.to_ascii_lowercase()).is_some() {
                    return match round_operand(&args[1], pos)? {
                        Some(_) => Err(Error::at("If strategy is not null, step is required.", pos)),
                        None => Ok(preserved_round(&args)),
                    };
                }
            }
            if args.iter().any(is_quoted_str) {
                return Err(Error::at("Only 1 argument allowed, but 2 were passed.", pos));
            }
            // `round(number, step)`: nearest with a step.
            let number = round_operand(&args[0], pos)?;
            let step = round_operand(&args[1], pos)?;
            match (number, step) {
                (Some(number), Some(step)) => {
                    round_with_step(RoundStrategy::Nearest, &number, &step, false, pos)
                }
                _ => Ok(preserved_round(&args)),
            }
        }
        3 => {
            // The first argument must be a strategy keyword. A quoted string
            // can't be used in a calculation; any other non-strategy value is
            // a "must be either nearest, up, down or to-zero" error.
            let strategy = match &args[0] {
                Value::Str(s) if !s.quoted => {
                    match RoundStrategy::from_str(&s.text.to_ascii_lowercase()) {
                        Some(st) => st,
                        // A non-strategy unquoted string (e.g. `var()`) leaves
                        // the whole call unsimplified.
                        None => return Ok(preserved_round(&args)),
                    }
                }
                Value::Str(s) => {
                    return Err(Error::at(
                        format!("Value \"{}\" can't be used in a calculation.", s.text),
                        pos,
                    ))
                }
                other => {
                    return Err(Error::at(
                        format!(
                            "{} must be either nearest, up, down or to-zero.",
                            other.to_css(false)
                        ),
                        pos,
                    ))
                }
            };
            let number = round_operand(&args[1], pos)?;
            let step = round_operand(&args[2], pos)?;
            match (number, step) {
                (Some(number), Some(step)) => round_with_step(strategy, &number, &step, true, pos),
                _ => Ok(preserved_round(&args)),
            }
        }
        n => Err(Error::at(
            format!("Only 3 arguments allowed, but {n} were passed."),
            pos,
        )),
    }
}

/// Whether a value is a quoted string (which can never be a calc operand).
fn is_quoted_str(v: &Value) -> bool {
    matches!(v, Value::Str(s) if s.quoted)
}

/// Interpret a `round()` number/step operand. A plain number (or one of the
/// bare `infinity`/`-infinity`/`NaN`/`pi`/`e` constants, or a folded calc
/// number) yields `Some(n)`. An unquoted non-constant string — a `var()`, an
/// interpolation, a bare identifier — or a preserved calc yields `Ok(None)`,
/// meaning the call should be preserved verbatim. A quoted string can't be
/// used in a calculation and is an error.
fn round_operand(v: &Value, pos: Pos) -> Result<Option<Number>, Error> {
    match v {
        Value::Number(n) => Ok(Some(n.clone())),
        Value::Calc(crate::value::CalcNode::Number(n)) => Ok(Some(n.clone())),
        Value::Str(s) if !s.quoted => Ok(const_number(&s.text)),
        Value::Calc(_) => Ok(None),
        Value::Str(s) => Err(Error::at(
            format!("Value \"{}\" can't be used in a calculation.", s.text),
            pos,
        )),
        other => Err(Error::at(
            format!("Value {} can't be used in a calculation.", other.to_css(false)),
            pos,
        )),
    }
}

/// dart-sass's `_roundWithStep`: round `number` to a multiple of `step`
/// (converted into `number`'s unit) under `strategy`, handling non-finite
/// operands and a zero step exactly as the CSS spec requires.
fn round_with_step(
    strategy: RoundStrategy,
    number: &Number,
    step: &Number,
    explicit: bool,
    pos: Pos,
) -> Result<Value, Error> {
    let unit = number.unit().to_string();
    let with_unit = |value: f64| num_value(Number::with_unit(value, &unit));
    // Coerce the step into the number's unit; an incompatible pair preserves
    // the call (a real/unitless or known cross-dimension mix errors, matching
    // the two-argument unit rules).
    let step_v = match coerce_step(step, number, pos) {
        StepCoercion::Value(v) => v,
        StepCoercion::Preserve => {
            return Ok(preserved_round_nums(strategy, number, step, explicit));
        }
        StepCoercion::Error(e) => return Err(e),
    };

    let nv = number.value;
    // NaN when number and step are both infinite, or step is 0, or either is
    // NaN.
    if (nv.is_infinite() && step_v.is_infinite()) || step_v == 0.0 || nv.is_nan() || step_v.is_nan() {
        return Ok(with_unit(f64::NAN));
    }
    // An infinite number rounds to itself.
    if nv.is_infinite() {
        return Ok(with_unit(nv));
    }
    // An infinite step collapses to a signed zero / signed infinity by
    // strategy and sign.
    if step_v.is_infinite() {
        if nv == 0.0 {
            return Ok(with_unit(nv));
        }
        let value = match strategy {
            RoundStrategy::Nearest | RoundStrategy::ToZero => {
                if nv > 0.0 {
                    0.0
                } else {
                    -0.0
                }
            }
            RoundStrategy::Up => {
                if nv > 0.0 {
                    f64::INFINITY
                } else {
                    -0.0
                }
            }
            RoundStrategy::Down => {
                if nv < 0.0 {
                    f64::NEG_INFINITY
                } else {
                    0.0
                }
            }
        };
        return Ok(with_unit(value));
    }

    let q = nv / step_v;
    let rounded = match strategy {
        RoundStrategy::Nearest => q.round(),
        RoundStrategy::Up => {
            if step_v < 0.0 {
                q.floor()
            } else {
                q.ceil()
            }
        }
        RoundStrategy::Down => {
            if step_v < 0.0 {
                q.ceil()
            } else {
                q.floor()
            }
        }
        RoundStrategy::ToZero => {
            if nv < 0.0 {
                q.ceil()
            } else {
                q.floor()
            }
        }
    };
    Ok(with_unit(int_result(rounded * step_v)))
}

/// The outcome of coercing a `round()` step into the number's unit.
enum StepCoercion {
    Value(f64),
    Preserve,
    Error(Error),
}

/// dart-sass `_verifyCompatibleNumbers`: a number with complex units cannot
/// ride into a preserved (unsimplified) CSS calculation — it is rejected with
/// its calc-form spelling ("Number calc(2px * 1px) isn't compatible with CSS
/// calculations.").
fn verify_no_complex_units(numbers: &[&Number], pos: Pos) -> Result<(), Error> {
    for n in numbers {
        if n.has_complex_units() {
            return Err(Error::at(
                format!(
                    "Number {} isn't compatible with CSS calculations.",
                    n.to_css(false)
                ),
                pos,
            ));
        }
    }
    Ok(())
}

/// [`verify_no_complex_units`] over a `Value` slice (only numbers checked).
fn verify_no_complex_args(args: &[Value], pos: Pos) -> Result<(), Error> {
    for v in args {
        if let Value::Number(n) = v {
            verify_no_complex_units(&[n], pos)?;
        }
    }
    Ok(())
}

/// Coerce `step` into `number`'s unit for `round()`. Equal/convertible units
/// combine; a relative/unknown unit pair preserves the call; a real-vs-unitless
/// or known cross-dimension mix is an error (matching dart-sass). A multi-unit
/// operand combines only with convertible unit lists; otherwise it is the
/// "isn't compatible with CSS calculations." rejection.
fn coerce_step(step: &Number, number: &Number, pos: Pos) -> StepCoercion {
    if step.has_complex_units() || number.has_complex_units() {
        return match crate::value::unit_lists_factor(
            (step.numer_units(), step.denom_units()),
            (number.numer_units(), number.denom_units()),
        ) {
            Some(factor) => StepCoercion::Value(step.value * factor),
            None => match verify_no_complex_units(&[number, step], pos) {
                Err(e) => StepCoercion::Error(e),
                // Unreachable: one operand is known complex.
                Ok(()) => StepCoercion::Preserve,
            },
        };
    }
    if step.unit().eq_ignore_ascii_case(number.unit()) {
        return StepCoercion::Value(step.value);
    }
    if step.is_unitless() && number.is_unitless() {
        return StepCoercion::Value(step.value);
    }
    // A unitless operand mixed with a real unit is incompatible.
    if step.is_unitless() != number.is_unitless() {
        return StepCoercion::Error(incompatible(number, step, pos));
    }
    if let Some(factor) = convert_factor(step.unit(), number.unit()) {
        return StepCoercion::Value(step.value * factor);
    }
    if crate::value::calc_units_incompatible(number.unit(), step.unit()) {
        return StepCoercion::Error(incompatible(number, step, pos));
    }
    StepCoercion::Preserve
}

/// Coerce `n` into `target`'s unit for the binary/variadic math functions
/// (`atan2`, `hypot`, `mod`, `rem`), which behave like `calc()`:
/// equal/convertible units combine; a real-vs-unitless or known
/// cross-dimension mix is an error; any pair involving an unknown/relative
/// unit (`%`, `foo`, `vw`) that can't be converted preserves the whole call.
/// (Identical rules to [`coerce_step`], reused via the same outcome enum.)
fn combine_into(n: &Number, target: &Number, pos: Pos) -> StepCoercion {
    coerce_step(n, target, pos)
}

/// Build the preserved `round(...)` form over the original arguments (for an
/// argument that cannot be simplified to a number, e.g. a `var()`).
fn preserved_round(args: &[Value]) -> Value {
    preserved_call("round", args)
}

/// Build the preserved `round(strategy, number, step)` form when the operands
/// are numbers but their units keep the call from simplifying. The strategy
/// keyword is emitted whenever it was authored explicitly (the three-argument
/// form), or for any non-`nearest` strategy; the implicit-`nearest`
/// two-argument form preserves as `round(number, step)`, matching dart-sass.
///
/// The result is a CALCULATION, like every other preserved call: `[measured]`
/// against dart-sass 1.104.1, `meta.type-of(round(1px, 2bar))` is
/// `calculation`, and compressed output drops the space after each comma
/// (`round(1px,2bar)`) — which a preserved unquoted string could not do,
/// because it carries one spelling for both styles.
fn preserved_round_nums(strategy: RoundStrategy, number: &Number, step: &Number, explicit: bool) -> Value {
    let kw = match strategy {
        RoundStrategy::Nearest => "nearest",
        RoundStrategy::Up => "up",
        RoundStrategy::Down => "down",
        RoundStrategy::ToZero => "to-zero",
    };
    let mut args = Vec::with_capacity(3);
    if strategy != RoundStrategy::Nearest || explicit {
        args.push(CalcNode::Str(kw.to_string()));
    }
    args.push(CalcNode::Number(number.clone()));
    args.push(CalcNode::Number(step.clone()));
    Value::Calc(CalcNode::Func {
        name: "round".to_string(),
        args,
    })
}

/// Apply a unit-preserving unary numeric operation, requiring a number.
fn unary(
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    op: fn(f64) -> f64,
) -> Result<Value, Error> {
    check_max_args(pos_args, named, 1, pos)?;
    let n = require_num(&["number"], pos_args, named, 0, pos)?;
    Ok(num_value(n.copy_units(op(n.value))))
}

/// `sign(x)`: -1, 0, or 1, with the operand's full units (also for zero) —
/// dart-sass `SassNumber(value.sign).coerceToMatch(arg)`. `±0`/NaN pass
/// through as themselves (`1 / sign(-0.0)` is `-infinity`); a `%` operand
/// can't simplify (its sign could flip after resolution against the unknown
/// reference value), so the call is preserved.
fn sign(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    check_max_args(pos_args, named, 1, pos)?;
    let n = require_num(&["number"], pos_args, named, 0, pos)?;
    if n.numer_units().iter().any(|u| &**u == "%") {
        return Ok(preserved_call("sign", &all_args(pos_args, named)));
    }
    let s = if n.value > 0.0 {
        1.0
    } else if n.value < 0.0 {
        -1.0
    } else {
        n.value
    };
    Ok(num_value(n.copy_units(s)))
}

/// `pow(base, exp)`: both operands must be unitless; result is unitless.
fn pow(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    check_max_args(pos_args, named, 2, pos)?;
    let base = require_num(&["base", "exponent"], pos_args, named, 0, pos)?;
    let exp = require_num(&["base", "exponent"], pos_args, named, 1, pos)?;
    no_unit(&base, pos)?;
    no_unit(&exp, pos)?;
    Ok(unitless(base.value.powf(exp.value)))
}

/// A unitless unary op (`sqrt`, `exp`): the argument must have no units and
/// the result is unitless.
fn unitless_unary(
    param: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    op: fn(f64) -> f64,
) -> Result<Value, Error> {
    check_max_args(pos_args, named, 1, pos)?;
    let n = require_num(&[param], pos_args, named, 0, pos)?;
    no_unit(&n, pos)?;
    Ok(unitless(op(n.value)))
}

/// `log(x)` (natural) or `log(x, base)`. Both operands must be unitless.
fn log(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    check_max_args(pos_args, named, 2, pos)?;
    let params = &["number", "base"];
    let x = require_num(params, pos_args, named, 0, pos)?;
    no_unit(&x, pos)?;
    match super::arg(params, pos_args, named, 1) {
        // An explicit `null` base means the natural logarithm (dart-sass).
        Some(b) if !matches!(b, Value::Null) => {
            let b = as_num(b, pos)?;
            no_unit(&b, pos)?;
            Ok(unitless(x.value.ln() / b.value.ln()))
        }
        _ => Ok(unitless(x.value.ln())),
    }
}

/// `hypot(a, b, ...)`: sqrt of the sum of squares, with unit coercion onto
/// the first argument's unit (`hypot(3px, 4cm)` converts cm to px). Coercion
/// follows the `calc()` rules: a real-vs-unitless or known cross-dimension mix
/// is an error, while an unknown/relative-unit pair that can't be converted
/// preserves the whole call verbatim (`hypot(1%, 2%)`).
fn hypot(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let nums = collect_nums(pos_args, named, pos)?;
    let first = match nums.first() {
        Some(n) => n.clone(),
        None => return Err(Error::at("At least one argument must be passed.", pos)),
    };
    // A complex-unit operand is rejected even alone (`hypot(-7px / 4em)` ->
    // "Number calc(-1.75px / 1em) isn't compatible with CSS calculations.").
    verify_no_complex_units(&nums.iter().collect::<Vec<_>>(), pos)?;
    // A `%` operand makes the result context-dependent, so dart-sass preserves
    // the call rather than folding (`hypot(1%, 2%)`, `hypot(1%, 2px)`).
    if nums.iter().any(is_percent) {
        let args: Vec<Value> = nums.into_iter().map(Value::Number).collect();
        return Ok(preserved_call("hypot", &args));
    }
    let mut sum = 0.0;
    for n in &nums {
        match combine_into(n, &first, pos) {
            StepCoercion::Value(v) => sum += v * v,
            StepCoercion::Preserve => {
                let args: Vec<Value> = nums.into_iter().map(Value::Number).collect();
                return Ok(preserved_call("hypot", &args));
            }
            StepCoercion::Error(e) => return Err(e),
        }
    }
    Ok(num_value(first.copy_units(sum.sqrt())))
}

/// `sin`/`cos`/`tan`: accept an angle (`deg`/`grad`/`rad`/`turn`) or a
/// unitless number treated as radians; return a unitless number.
fn trig(pos_args: &[Value], named: &[(String, Value)], pos: Pos, op: fn(f64) -> f64) -> Result<Value, Error> {
    check_max_args(pos_args, named, 1, pos)?;
    let n = require_num(&["number"], pos_args, named, 0, pos)?;
    let radians = angle_to_radians(&n, pos)?;
    Ok(unitless(op(radians)))
}

/// `asin`/`acos`/`atan`: the argument must be unitless; the result is in
/// degrees.
fn inverse_trig(
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    op: fn(f64) -> f64,
) -> Result<Value, Error> {
    check_max_args(pos_args, named, 1, pos)?;
    let n = require_num(&["number"], pos_args, named, 0, pos)?;
    no_unit(&n, pos)?;
    Ok(degrees(op(n.value).to_degrees()))
}

/// `atan2(y, x)`: the two-argument arctangent, returned in degrees. The
/// operands are coerced together like `calc()`: a real-vs-unitless or known
/// cross-dimension mix is an error, while an unknown/relative-unit pair that
/// can't be converted preserves the call verbatim (`atan2(1%, 2%)`).
fn atan2(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    check_max_args(pos_args, named, 2, pos)?;
    let params = &["y", "x"];
    let y = require_num(params, pos_args, named, 0, pos)?;
    let x = require_num(params, pos_args, named, 1, pos)?;
    // A complex-unit operand is rejected before the `%` preserve below.
    verify_no_complex_units(&[&y, &x], pos)?;
    // A `%` operand would produce a context-dependent result, so dart-sass
    // preserves the call rather than folding (`atan2(1%, 2%)`).
    if is_percent(&y) || is_percent(&x) {
        return Ok(preserved_call("atan2", &[Value::Number(y), Value::Number(x)]));
    }
    let xv = match combine_into(&x, &y, pos) {
        StepCoercion::Value(v) => v,
        StepCoercion::Preserve => return Ok(preserved_call("atan2", &[Value::Number(y), Value::Number(x)])),
        StepCoercion::Error(e) => return Err(e),
    };
    Ok(degrees(y.value.atan2(xv).to_degrees()))
}

/// Whether a number's unit is `%` (case-insensitive). The geometric functions
/// (`atan2`, `hypot`) preserve their call when any operand is a percentage,
/// since the result would be context-dependent.
fn is_percent(n: &Number) -> bool {
    n.unit() == "%"
}

/// `rem(a, b)` (truncated, sign of dividend) or `mod(a, b)` (floored, sign
/// of divisor). The divisor is coerced into the dividend's unit under the
/// `calc()` rules: a real-vs-unitless or known cross-dimension mix is an
/// error, while an unknown/relative-unit pair that can't be converted
/// preserves the call verbatim (`mod(1px, 2bar)`).
fn remainder(
    fname: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    truncated: bool,
) -> Result<Value, Error> {
    check_max_args(pos_args, named, 2, pos)?;
    let params = &["dividend", "modulus"];
    let a = require_num(params, pos_args, named, 0, pos)?;
    let b = require_num(params, pos_args, named, 1, pos)?;
    let bv = match combine_into(&b, &a, pos) {
        StepCoercion::Value(v) => v,
        StepCoercion::Preserve => return Ok(preserved_call(fname, &[Value::Number(a), Value::Number(b)])),
        StepCoercion::Error(e) => return Err(e),
    };
    let value = if bv == 0.0 {
        f64::NAN
    } else if truncated {
        a.value % bv
    } else {
        a.value - bv * (a.value / bv).floor()
    };
    Ok(num_value(a.copy_units(value)))
}

/// `min`/`max`: reduce all-numeric, compatible-unit arguments to the
/// smallest/largest (keeping the winning argument's own unit). If any
/// argument is a non-number or any pair of units is incompatible, fall back
/// to a preserved CSS `min()`/`max()` call over the evaluated arguments.
fn min_max(
    fname: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    is_min: bool,
) -> Result<Value, Error> {
    let args: Vec<Value> = all_args(pos_args, named)
        .into_iter()
        .map(normalize_const)
        .collect();
    if args.is_empty() {
        return Err(Error::at("Missing argument.", pos));
    }
    match reduce_min_max(&args, is_min, pos)? {
        Some(n) => Ok(num_value(n)),
        None => {
            verify_no_complex_args(&args, pos)?;
            // The BUILTIN min/max (reached via a splat or meta.call — the
            // direct spelling parses as a CSS calculation upstream) requires
            // numbers: dart's math.min asserts every argument
            // ("blah is not a number."). Only calc-style substitutions
            // (var()/calc strings) keep the call preserved.
            if let Some(bad) = args
                .iter()
                .find(|v| !matches!(v, Value::Number(_)) && !value_is_calc_substitution(v))
            {
                return Err(Error::at(format!("{} is not a number.", bad.to_css(false)), pos));
            }
            Ok(preserved_call(fname, &args))
        }
    }
}

/// Whether a non-number min/max argument is a calc-style substitution that
/// keeps the call preserved (a `var()`/`calc()`/`env()` string or a nested
/// calculation) rather than a plain value dart's builtin rejects.
fn value_is_calc_substitution(v: &Value) -> bool {
    match v {
        Value::Calc(_) => true,
        Value::Str(s) => {
            let t = s.text.trim_start().to_ascii_lowercase();
            t.starts_with("var(")
                || t.starts_with("calc(")
                || t.starts_with("env(")
                || t.starts_with("min(")
                || t.starts_with("max(")
                || t.starts_with("clamp(")
        }
        _ => false,
    }
}

/// `clamp(min, value, max)`. A single non-number argument is a preserved CSS
/// calculation (`clamp(var(--c))`); any other arity is an error. With three
/// numbers, dart-sass clamps `value` against `min`/`max` checking `min` first
/// (`value < min` → `min`; else `value > max` → `max`; else `value`), keeping
/// the winning argument's own unit. A known cross-dimension pair errors; an
/// unconvertible-but-not-incompatible pair (`clamp(1px, 2vw, 3px)`) preserves.
fn clamp(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let args: Vec<Value> = all_args(pos_args, named)
        .into_iter()
        .map(normalize_const)
        .collect();
    if args.len() == 1 && !matches!(args[0], Value::Number(_)) {
        // A lone `var()`, interpolation, or bare identifier is a preserved
        // CSS `clamp()` calculation rather than an arity error.
        return Ok(preserved_call("clamp", &args));
    }
    if args.len() != 3 {
        return Err(Error::at(
            format!("3 arguments required, but {} were passed.", args.len()),
            pos,
        ));
    }
    let (lo, val, hi) = match (&args[0], &args[1], &args[2]) {
        (Value::Number(a), Value::Number(b), Value::Number(c)) => (a, b, c),
        _ => {
            verify_no_complex_args(&args, pos)?;
            return Ok(preserved_call("clamp", &args));
        }
    };
    // Multi-unit arguments must be mutually convertible (dart
    // `isComparableTo`): the values compare in `min`'s units and the winning
    // argument is returned as-is (`clamp(1px*1px, 2px*2px, 3px*3px)` ->
    // `calc(4px * 1px)`); a non-convertible complex operand is rejected.
    if lo.has_complex_units() || val.has_complex_units() || hi.has_complex_units() {
        let coerce = |n: &Number| {
            crate::value::unit_lists_factor(
                (n.numer_units(), n.denom_units()),
                (lo.numer_units(), lo.denom_units()),
            )
            .map(|f| n.value * f)
        };
        return match (coerce(val), coerce(hi)) {
            (Some(val_v), Some(hi_v)) => {
                let winner = if val_v < lo.value {
                    lo
                } else if val_v > hi_v {
                    hi
                } else {
                    val
                };
                Ok(num_value(winner.clone()))
            }
            _ => {
                verify_no_complex_units(&[lo, val, hi], pos)?;
                // Unreachable: one operand is known complex.
                Ok(preserved_call("clamp", &args))
            }
        };
    }
    // A known cross-dimension pair (against `min`) is an error, matching
    // dart-sass; an unconvertible relative/unknown unit preserves the call.
    if crate::value::calc_units_incompatible(lo.unit(), val.unit()) {
        return Err(incompatible(lo, val, pos));
    }
    if crate::value::calc_units_incompatible(lo.unit(), hi.unit()) {
        return Err(incompatible(lo, hi, pos));
    }
    // Coerce `value` and `hi` into `lo`'s unit; preserve if any pair is not
    // convertible (but not a hard incompatibility, e.g. `1px`/`2vw`).
    let val_v = match try_coerce(val, lo) {
        Some(v) => v,
        None => return Ok(preserved_call("clamp", &args)),
    };
    let hi_v = match try_coerce(hi, lo) {
        Some(v) => v,
        None => return Ok(preserved_call("clamp", &args)),
    };
    // dart-sass checks `min` before `max` (so `clamp(3, 5, 1)` is `1`, not the
    // CSS `max(min, min(value, max))` result), keeping the winner's own unit.
    let winner = if val_v < lo.value {
        lo
    } else if val_v > hi_v {
        hi
    } else {
        val
    };
    Ok(num_value(winner.clone()))
}

/// `math.round($number)`: the legacy single-argument numeric round (nearest,
/// unit preserved). dart-sass requires exactly one number; a non-number or
/// extra arguments are an error (unlike the global CSS `round()` calculation,
/// which accepts a rounding strategy and step and preserves unknown args).
pub(super) fn module_round(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    super::check_arity(1, pos_args, named, pos)?;
    let v = super::require(&["number"], pos_args, named, 0, pos)?;
    let n = as_num(v, pos)?;
    Ok(num_value(n.copy_units(int_result(n.value.round()))))
}

/// `math.min(...)` / `math.max(...)`: the numeric (not CSS-calc) reductions.
/// Every argument must be a number with a compatible unit; a non-number or a
/// non-convertible unit pair is an error (unlike the global `min`/`max`, which
/// preserve such calls as CSS calculations).
pub(super) fn module_min_max(
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    is_min: bool,
) -> Result<Value, Error> {
    let args = all_args(pos_args, named);
    if args.is_empty() {
        return Err(Error::at("At least one argument must be passed.", pos));
    }
    // Every argument must be a number (dart-sass: "<v> is not a number.").
    for v in &args {
        if !matches!(v, Value::Number(_)) {
            return Err(Error::at(format!("{} is not a number.", v.to_css(false)), pos));
        }
    }
    match reduce_min_max(&args, is_min, pos)? {
        Some(n) => Ok(num_value(n)),
        // All numbers but >1 cluster: a non-convertible unit pair is an error
        // for the numeric form. Find a representative incompatible pair.
        None => {
            let nums: Vec<&Number> = args
                .iter()
                .filter_map(|v| match v {
                    Value::Number(n) => Some(n),
                    _ => None,
                })
                .collect();
            for (i, a) in nums.iter().enumerate() {
                for b in &nums[i + 1..] {
                    if try_coerce(b, a).is_none() {
                        return Err(incompatible(a, b, pos));
                    }
                }
            }
            // Should be unreachable (a single cluster would have returned
            // `Some`); fall back to the first value.
            Ok(num_value((*nums[0]).clone()))
        }
    }
}

/// `math.clamp($min, $number, $max)`: the numeric (not CSS-calc) clamp. All
/// three arguments must be numbers with compatible units (mixing a unitless
/// value with a real unit is an error). dart-sass: `min >= max` → `min`;
/// `number <= min` → `min`; `number >= max` → `max`; otherwise `number`,
/// keeping the winning argument's own unit.
pub(super) fn module_clamp(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["min", "number", "max"];
    super::check_arity(params.len(), pos_args, named, pos)?;
    let want = |i: usize, label: &str| -> Result<Number, Error> {
        let v = super::require(&params, pos_args, named, i, pos)?;
        match v {
            Value::Number(n) => Ok(n.clone()),
            other => Err(Error::at(
                format!("${label}: {} is not a number.", other.to_css(false)),
                pos,
            )),
        }
    };
    let min = want(0, "min")?;
    let number = want(1, "number")?;
    let max = want(2, "max")?;
    // Coerce `number` and `max` into `min`'s unit; mixing unitless with a real
    // unit (or a hard cross-dimension pair) is an error.
    let number_v = coerce_for_clamp(&min, &number, "min", "number", pos)?;
    let max_v = coerce_for_clamp(&min, &max, "min", "max", pos)?;
    // dart-sass precedence: an inverted range or a value at/below `min` yields
    // `min`; a value at/above `max` yields `max`; otherwise the value itself.
    // Both boundary checks are inclusive.
    let winner = if min.value >= max_v || number_v <= min.value {
        min
    } else if number_v >= max_v {
        max
    } else {
        number
    };
    Ok(num_value(winner))
}

/// Coerce `n` into `base`'s unit for `math.clamp`, raising dart-sass's
/// "incompatible units" error when one side is unitless and the other is not,
/// or when the units are a hard cross-dimension mismatch.
fn coerce_for_clamp(
    base: &Number,
    n: &Number,
    base_label: &str,
    n_label: &str,
    pos: Pos,
) -> Result<f64, Error> {
    let unitless_mix = base.is_unitless() != n.is_unitless();
    if unitless_mix {
        return Err(Error::at(
            format!(
                "${n_label}: {} and ${base_label}: {} have incompatible units (one has units and the other doesn't).",
                n.to_css(false),
                base.to_css(false)
            ),
            pos,
        ));
    }
    match try_coerce(n, base) {
        Some(v) => Ok(v),
        None => Err(incompatible(base, n, pos)),
    }
}

/// `random()` — a pseudo-random float in `[0, 1)` — or `random($limit)` — a
/// pseudo-random integer in `[1, $limit]`. `$limit` must be a positive
/// integer (its unit is ignored, matching dart-sass's legacy behaviour); a
/// non-number / non-integer / non-positive limit errors.
fn random(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    check_max_args(pos_args, named, 1, pos)?;
    let r = next_random();
    match super::arg(&["limit"], pos_args, named, 0) {
        None => Ok(unitless(round_to_precision(r))),
        Some(Value::Null) => Ok(unitless(round_to_precision(r))),
        Some(v) => {
            let n = as_num(v, pos)?;
            // dart-sass treats a value within the 1e-11 precision of an
            // integer as that integer.
            let rounded = n.value.round();
            if (n.value - rounded).abs() >= 1e-11 {
                return Err(Error::at(
                    format!("$limit: {} is not an int.", n.to_css(false)),
                    pos,
                ));
            }
            if rounded < 1.0 {
                return Err(Error::at(
                    format!("$limit: Must be greater than 0, was {}.", n.to_css(false)),
                    pos,
                ));
            }
            // floor(r * limit) + 1 lands in [1, limit].
            let pick = (r * rounded).floor() + 1.0;
            Ok(unitless(pick.min(rounded)))
        }
    }
}

/// Round a `[0,1)` random draw to sasso's 10-digit output precision so its
/// serialization is stable (dart-sass emits e.g. `0.8820566029`).
fn round_to_precision(x: f64) -> f64 {
    (x * 1e10).round() / 1e10
}

/// A pseudo-random `f64` in `[0, 1)` from a process-wide xorshift64* state,
/// seeded once from the system clock. Pure Rust, no external dependency.
fn next_random() -> f64 {
    use std::cell::Cell;
    use std::time::{SystemTime, UNIX_EPOCH};
    thread_local! {
        static STATE: Cell<u64> = const { Cell::new(0) };
    }
    STATE.with(|s| {
        let mut x = s.get();
        if x == 0 {
            // Seed from the clock; fall back to a fixed nonzero constant if
            // the clock is unavailable (never zero, which would stick).
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
        let v = x.wrapping_mul(0x2545_F491_4F6C_DD1D);
        // Take the top 53 bits for a uniform double in [0, 1).
        ((v >> 11) as f64) / ((1u64 << 53) as f64)
    })
}

// ---- shared helpers --------------------------------------------------

/// All positional arguments followed by all named-argument values, in order.
fn all_args(pos_args: &[Value], named: &[(String, Value)]) -> Vec<Value> {
    let mut v: Vec<Value> = pos_args.to_vec();
    v.extend(named.iter().map(|(_, val)| val.clone()));
    v
}

/// Replace a bare calc-constant string (`infinity`/`-infinity`/`NaN`/`pi`/`e`)
/// with its numeric value; pass any other value through unchanged. Used by
/// `min`/`max`/`clamp`, which accept the constants while still preserving a
/// genuine non-number argument as a CSS call.
fn normalize_const(v: Value) -> Value {
    if let Value::Str(s) = &v {
        if !s.quoted {
            if let Some(n) = const_number(&s.text) {
                return Value::Number(n);
            }
        }
    }
    v
}

/// Reduce a list of values to the min/max number under dart-sass's calc
/// `min()`/`max()` simplification:
///
/// - `Ok(Some(n))` — every argument folds into one number; the result keeps
///   the winning argument's own unit (`min(1in, 2cm)` → `2cm`).
/// - `Ok(None)` — two or more mutually-incomparable clusters remain
///   (`min(1px, 2vw)`, `min(1c, 2d)`), so the call is preserved.
/// - `Err` — a known cross-dimension pair is genuinely incompatible
///   (`min(1s, 2px)`), matching dart-sass's "<a> and <b> are incompatible."
///
/// Each new value is folded into the first existing cluster it is comparable
/// to (equal/convertible units, or a unitless operand against anything);
/// otherwise it starts a new cluster. (The unitless-vs-multiple-cluster
/// "potentially incompatible" error case is left preserved rather than
/// errored — a strict subset of dart's behaviour that never folds wrongly.)
fn reduce_min_max(args: &[Value], is_min: bool, pos: Pos) -> Result<Option<Number>, Error> {
    // dart-sass `SassCalculation.min`/`max`: a sequential fold where a
    // unitless operand is comparable to anything (the legacy rule, so
    // `min(1c, 2)` computes `1c`); the first incomparable pair stops the
    // simplification.
    let mut best: Option<Number> = None;
    let mut simplified = true;
    for v in args {
        let n = match v {
            Value::Number(n) => n.clone(),
            _ => {
                simplified = false;
                break;
            }
        };
        match &mut best {
            None => best = Some(n),
            Some(b) => match try_coerce(&n, b) {
                Some(nv) => {
                    // Pick the winner, keeping its own authored unit.
                    let pick_n = if is_min { nv < b.value } else { nv > b.value };
                    if pick_n {
                        *b = n;
                    }
                }
                None => {
                    simplified = false;
                    break;
                }
            },
        }
    }
    if simplified {
        return Ok(best);
    }
    // Preserve path: every number pair must be at least *potentially*
    // compatible (dart `_verifyCompatibleNumbers`) — a unitless operand can
    // never combine with a unit in a real calculation, and two known units
    // must share a dimension; an unknown unit is potentially anything.
    let nums: Vec<&Number> = args
        .iter()
        .filter_map(|v| match v {
            Value::Number(n) => Some(n),
            _ => None,
        })
        .collect();
    for i in 0..nums.len() {
        for j in i + 1..nums.len() {
            let (a, b) = (nums[i], nums[j]);
            if a.has_complex_units() || b.has_complex_units() {
                continue; // rejected separately by verify_no_complex_args
            }
            let (ua, ub) = (a.unit(), b.unit());
            if a.is_unitless() != b.is_unitless() || crate::value::calc_units_incompatible(ua, ub) {
                return Err(incompatible(a, b, pos));
            }
        }
    }
    Ok(None)
}

/// Convert `n` into `target`'s unit, returning the converted scalar, or
/// `None` if their units are incompatible. A unitless operand keeps its
/// value and adopts the comparison silently.
fn try_coerce(n: &Number, target: &Number) -> Option<f64> {
    if n.has_complex_units() || target.has_complex_units() {
        return crate::value::unit_lists_factor(
            (n.numer_units(), n.denom_units()),
            (target.numer_units(), target.denom_units()),
        )
        .map(|f| n.value * f);
    }
    if n.unit().eq_ignore_ascii_case(target.unit()) || n.is_unitless() || target.is_unitless() {
        return Some(n.value);
    }
    convert_factor(n.unit(), target.unit()).map(|f| n.value * f)
}

/// Convert an angle number to radians, accepting `deg`/`grad`/`rad`/`turn`
/// or a unitless value (already radians). Errors on any other unit.
fn angle_to_radians(n: &Number, pos: Pos) -> Result<f64, Error> {
    use std::f64::consts::PI;
    let deg = match n.unit().to_ascii_lowercase().as_str() {
        // unitless and radians are already in radians.
        "" | "rad" => return Ok(n.value),
        "deg" => n.value,
        "grad" => n.value * 9.0 / 10.0,
        "turn" => n.value * 360.0,
        _ => {
            return Err(Error::at(
                format!(
                    "$number: Expected {} to have an angle unit (deg, grad, rad, turn).",
                    n.to_css(false)
                ),
                pos,
            ))
        }
    };
    Ok(deg * PI / 180.0)
}

/// Collect every argument as a number, erroring on the first non-number.
fn collect_nums(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Vec<Number>, Error> {
    let args = all_args(pos_args, named);
    if args.is_empty() {
        // A variadic member names no parameter to be missing.
        return Err(Error::at(
            "At least one argument must be passed.".to_string(),
            pos,
        ));
    }
    let mut out = Vec::with_capacity(args.len());
    for v in &args {
        out.push(as_num(v, pos)?);
    }
    Ok(out)
}

/// Interpret an unquoted-string calc constant (`infinity`, `-infinity`,
/// `nan`, `pi`, `e`, case-insensitive) as the matching unitless number. These
/// are the same constants `calc()` recognizes; dart-sass's math functions
/// accept them as numeric inputs too.
fn const_number(text: &str) -> Option<Number> {
    let value = match text.to_ascii_lowercase().as_str() {
        "infinity" => f64::INFINITY,
        "-infinity" => f64::NEG_INFINITY,
        "nan" => f64::NAN,
        "pi" => std::f64::consts::PI,
        "e" => std::f64::consts::E,
        _ => return None,
    };
    Some(Number::unitless(value))
}

/// Convert a value to a `Number`, also accepting the bare calc constants
/// (`infinity`/`-infinity`/`NaN`/`pi`/`e`); erroring on any other non-number.
fn as_num(v: &Value, pos: Pos) -> Result<Number, Error> {
    match v {
        Value::Number(n) => Ok(n.clone()),
        Value::Str(s) if !s.quoted => match const_number(&s.text) {
            Some(n) => Ok(n),
            None => Err(Error::at(format!("{} is not a number.", s.text), pos)),
        },
        other => Err(Error::at(
            format!("{} is not a number.", other.to_css(false)),
            pos,
        )),
    }
}

/// Fetch the argument at `i` as a `Number`, erroring on a missing or
/// non-number argument.
fn require_num(
    params: &[&str],
    pos_args: &[Value],
    named: &[(String, Value)],
    i: usize,
    pos: Pos,
) -> Result<Number, Error> {
    let v = super::require(params, pos_args, named, i, pos)?;
    as_num(v, pos)
}

/// Wrap a result number as a value: a finite number stays a plain `Number`,
/// while a non-finite result (infinity/NaN) becomes a `calc()` so it
/// serializes as `calc(infinity)` / `calc(NaN)` / `calc(-infinity)`, matching
/// dart-sass.
fn num_value(n: Number) -> Value {
    if n.value.is_finite() {
        Value::Number(n)
    } else {
        Value::Calc(crate::value::CalcNode::Number(n))
    }
}

/// Ensure a number is unitless, erroring with dart-sass's wording.
fn no_unit(n: &Number, pos: Pos) -> Result<(), Error> {
    if n.is_unitless() {
        Ok(())
    } else {
        Err(Error::at(
            format!("Expected {} to have no units.", n.to_css(false)),
            pos,
        ))
    }
}

fn unitless(value: f64) -> Value {
    num_value(Number::unitless(value))
}

fn degrees(value: f64) -> Value {
    num_value(Number::with_unit(value, "deg"))
}

fn incompatible(a: &Number, b: &Number, pos: Pos) -> Error {
    Error::at(
        format!("{} and {} are incompatible.", a.to_css(false), b.to_css(false)),
        pos,
    )
}

/// Build the preserved CSS form `name(arg, arg, ...)` over evaluated
/// arguments, matching dart-sass's serialization (comma + space separated).
/// An unreduced CSS math function (`min`/`max`/`clamp`/`hypot`/…) becomes a
/// calculation value, so `meta.type-of` reports `calculation` and
/// `meta.calc-name`/`meta.calc-args` can inspect it. Each argument keeps its
/// kind: a number stays a number node, a nested calculation is inlined, and any
/// other operand is its verbatim serialization.
fn preserved_call(name: &str, args: &[Value]) -> Value {
    Value::Calc(CalcNode::Func {
        name: name.to_string(),
        args: args.iter().map(value_to_calc_node).collect(),
    })
}

fn value_to_calc_node(v: &Value) -> CalcNode {
    match v {
        Value::Number(n) => CalcNode::Number(n.clone()),
        Value::Calc(node) => node.clone(),
        other => CalcNode::Str(other.to_css(false)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::scanner::Pos;
    use crate::value::SassStr;

    fn pos() -> Pos {
        Pos { line: 1, col: 1 }
    }

    fn n(value: f64, unit: &str) -> Value {
        Value::Number(Number::with_unit(value, unit))
    }

    fn call(name: &str, args: &[Value]) -> Value {
        try_call(name, args, &[], pos())
            .expect("name owned by math family")
            .expect("no error")
    }

    fn err(name: &str, args: &[Value]) -> bool {
        try_call(name, args, &[], pos()).expect("name owned").is_err()
    }

    #[test]
    fn abs_keeps_unit_and_magnitude() {
        assert_eq!(call("abs", &[n(-3.0, "px")]).to_css(false), "3px");
        assert_eq!(call("abs", &[n(3.0, "")]).to_css(false), "3");
    }

    #[test]
    fn ceil_and_floor_keep_unit() {
        assert_eq!(call("ceil", &[n(4.2, "px")]).to_css(false), "5px");
        assert_eq!(call("floor", &[n(4.8, "%")]).to_css(false), "4%");
    }

    #[test]
    fn round_is_half_away_from_zero() {
        assert_eq!(call("round", &[n(2.5, "")]).to_css(false), "3");
        assert_eq!(call("round", &[n(-2.5, "deg")]).to_css(false), "-3deg");
        assert_eq!(call("round", &[n(0.5, "")]).to_css(false), "1");
    }

    #[test]
    fn round_strategies_with_step() {
        let kw = |s: &str| {
            Value::Str(SassStr {
                text: s.into(),
                quoted: false,
            })
        };
        assert_eq!(
            call("round", &[kw("nearest"), n(117.0, "px"), n(25.0, "px")]).to_css(false),
            "125px"
        );
        assert_eq!(
            call("round", &[kw("up"), n(101.0, "px"), n(25.0, "px")]).to_css(false),
            "125px"
        );
        assert_eq!(
            call("round", &[kw("down"), n(122.0, "px"), n(25.0, "px")]).to_css(false),
            "100px"
        );
        // to-zero with a negative step keeps the step's sign in the rounding.
        assert_eq!(
            call("round", &[kw("to-zero"), n(-120.0, "px"), n(-25.0, "px")]).to_css(false),
            "-125px"
        );
        // Two-argument nearest-with-step and unit coercion.
        assert_eq!(call("round", &[n(117.0, ""), n(25.0, "")]).to_css(false), "125");
        assert_eq!(
            call("round", &[n(117.0, "cm"), n(25.0, "mm")]).to_css(false),
            "117.5cm"
        );
        // A zero step yields NaN, serialized as a calculation.
        assert_eq!(
            call("round", &[kw("nearest"), n(10.0, "px"), n(0.0, "px")]).to_css(false),
            "calc(NaN * 1px)"
        );
        // An infinite number rounds to itself (a calculation).
        assert_eq!(
            call("round", &[kw("nearest"), kw("infinity"), n(5.0, "")]).to_css(false),
            "calc(infinity)"
        );
        // A bare strategy with no step, a unit mismatch, and a missing arg all
        // error.
        assert!(err("round", &[kw("nearest"), n(5.0, "")]));
        assert!(err("round", &[n(10.0, "px"), n(5.0, "")]));
        assert!(err("round", &[]));
    }

    #[test]
    fn min_max_pick_winning_argument_unit() {
        assert_eq!(call("min", &[n(1.0, "px"), n(2.0, "px")]).to_css(false), "1px");
        assert_eq!(
            call("max", &[n(1.0, ""), n(2.0, ""), n(3.0, "")]).to_css(false),
            "3"
        );
        // min(1in, 2cm): 1in == 2.54cm > 2cm, so 2cm wins (keeps cm).
        assert_eq!(call("min", &[n(1.0, "in"), n(2.0, "cm")]).to_css(false), "2cm");
        // single arg returns itself even with an unknown unit.
        assert_eq!(call("min", &[n(1.0, "vw")]).to_css(false), "1vw");
    }

    #[test]
    fn min_max_preserve_css_form_on_incompatible() {
        assert_eq!(
            call("min", &[n(1.0, "px"), n(2.0, "vw")]).to_css(false),
            "min(1px, 2vw)"
        );
        // a non-number argument also forces the preserved form.
        let var = Value::Str(SassStr {
            text: "var(--x)".into(),
            quoted: false,
        });
        assert_eq!(
            call("min", &[n(1.0, "px"), var]).to_css(false),
            "min(1px, var(--x))"
        );
    }

    #[test]
    fn clamp_orders_min_value_max() {
        assert_eq!(
            call("clamp", &[n(1.0, "px"), n(5.0, "px"), n(3.0, "px")]).to_css(false),
            "3px"
        );
        assert_eq!(
            call("clamp", &[n(1.0, "px"), n(0.0, "px"), n(3.0, "px")]).to_css(false),
            "1px"
        );
        // unresolvable middle arg preserves the CSS call.
        let var = Value::Str(SassStr {
            text: "var(--x)".into(),
            quoted: false,
        });
        assert_eq!(
            call("clamp", &[n(1.0, "px"), var, n(3.0, "px")]).to_css(false),
            "clamp(1px, var(--x), 3px)"
        );
    }

    #[test]
    fn pow_sqrt_exp_log_are_unitless() {
        assert_eq!(call("pow", &[n(2.0, ""), n(3.0, "")]).to_css(false), "8");
        assert_eq!(call("sqrt", &[n(4.0, "")]).to_css(false), "2");
        assert_eq!(call("exp", &[n(0.0, "")]).to_css(false), "1");
        assert_eq!(call("log", &[n(8.0, ""), n(2.0, "")]).to_css(false), "3");
        assert!(err("sqrt", &[n(4.0, "px")]));
        assert!(err("pow", &[n(2.0, "px"), n(2.0, "")]));
    }

    #[test]
    fn trig_accepts_angles_and_returns_unitless() {
        assert_eq!(call("sin", &[n(30.0, "deg")]).to_css(false), "0.5");
        assert_eq!(call("cos", &[n(0.0, "")]).to_css(false), "1");
        assert_eq!(call("tan", &[n(45.0, "deg")]).to_css(false), "1");
        assert_eq!(call("sin", &[n(100.0, "grad")]).to_css(false), "1");
        assert_eq!(call("sin", &[n(0.25, "turn")]).to_css(false), "1");
        assert!(err("sin", &[n(1.0, "px")]));
    }

    #[test]
    fn inverse_trig_returns_degrees() {
        assert_eq!(call("asin", &[n(0.5, "")]).to_css(false), "30deg");
        assert_eq!(call("acos", &[n(1.0, "")]).to_css(false), "0deg");
        assert_eq!(call("atan", &[n(1.0, "")]).to_css(false), "45deg");
        assert_eq!(call("atan2", &[n(1.0, ""), n(1.0, "")]).to_css(false), "45deg");
    }

    #[test]
    fn sign_keeps_units() {
        assert_eq!(call("sign", &[n(-5.0, "px")]).to_css(false), "-1px");
        // Zero keeps the operand's unit too (dart `coerceToMatch`).
        assert_eq!(call("sign", &[n(0.0, "px")]).to_css(false), "0px");
        assert_eq!(call("sign", &[n(3.0, "")]).to_css(false), "1");
        // A `%` operand preserves the call.
        assert_eq!(call("sign", &[n(7.0, "%")]).to_css(false), "sign(7%)");
    }

    #[test]
    fn hypot_converts_onto_first_unit() {
        assert_eq!(call("hypot", &[n(3.0, ""), n(4.0, "")]).to_css(false), "5");
        assert_eq!(call("hypot", &[n(3.0, "px"), n(4.0, "px")]).to_css(false), "5px");
        assert!(err("hypot", &[n(3.0, "px"), n(4.0, "")]));
    }

    #[test]
    fn rem_and_mod_signs() {
        assert_eq!(call("rem", &[n(10.0, ""), n(3.0, "")]).to_css(false), "1");
        assert_eq!(call("rem", &[n(-10.0, ""), n(3.0, "")]).to_css(false), "-1");
        assert_eq!(call("mod", &[n(-10.0, ""), n(3.0, "")]).to_css(false), "2");
        // 10px rem 3pt -> 3pt == 4px, 10 % 4 == 2 -> 2px.
        assert_eq!(call("rem", &[n(10.0, "px"), n(3.0, "pt")]).to_css(false), "2px");
        assert!(err("rem", &[n(10.0, "px"), n(3.0, "")]));
    }

    #[test]
    fn rejects_non_numbers_and_unknown_names() {
        let e = try_call("abs", &[Value::Bool(true)], &[], pos());
        assert!(e.is_some());
        assert!(e.expect("some").is_err());
        assert!(try_call("definitely-not-math", &[n(4.0, "")], &[], pos()).is_none());
    }
}
