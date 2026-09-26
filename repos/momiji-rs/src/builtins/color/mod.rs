//! Core color builtins: `rgb`/`rgba`/`hsl`/`hsla`/`mix`, the legacy
//! `lighten`/`darken`, `percentage`, and the channel getters
//! `red`/`green`/`blue`/`alpha`.
//!
//! Split into focused submodules around the `try_call` dispatch (below), the
//! legacy color constructors ([`legacy`]), the modern `sass:color` module
//! members ([`modern`]), and the shared color-space math ([`math`]). This is a
//! pure organizational split: every `color::…` path external callers use is
//! preserved via the re-exports at the bottom of this file.

pub(crate) mod deprecate;
pub(crate) mod legacy;
mod math;
mod modern;
pub(crate) mod removed;

// Shared imports. These are private to `color`, but Rust makes them visible to
// the child submodules, which pull them in with `use super::*;`.
use super::color_ext::{computed, named_repr};
use super::{arg, as_color, channel, check_arity, num, require, require_legacy_color};
use crate::error::Error;
use crate::scanner::Pos;
use crate::value::{fmt_num, CalcNode, Color, ColorSpace, List, ListSep, ModernColor, Number, Value};

// Bring every sibling submodule item into this module's scope so the glue
// `try_call` below (and each submodule's `use super::*;`) can name them.
use legacy::*;
use math::*;
use modern::*;

// Re-exports preserving the external `color::…` API surface (the paths
// `crate::builtins::color::…` and `super::color::…` that `builtins::mod` and
// `builtins::color_ext` already use).
pub(crate) use legacy::call_module_member;
pub(crate) use math::{
    convert_modern, legacy_alpha_adjust, legacy_hsl_adjust, legacy_to_modern, make_modern_in, space_arg,
    stored_alpha,
};
pub(crate) use modern::{
    grayscale_modern, invert_in_space, missing_channel_err, modify_in_space, modify_in_space_full,
    modify_in_space_opt, ModifyOp,
};

/// Whether a value is a "special" channel argument that cannot be evaluated
/// to a plain number — a `var()`/`env()`/`attr()` (an unquoted string holding
/// a CSS function) or a `calc()` (a [`Value::Calc`]). dart-sass does not error
/// on these; it preserves the whole color call verbatim, re-serialized from
/// the evaluated arguments.
fn is_special(v: &Value) -> bool {
    match v {
        Value::Calc(_) => true,
        Value::Str(s) => !s.quoted && s.text.contains('('),
        _ => false,
    }
}

/// Whether a value is specifically a `var(...)` reference (an unquoted string
/// whose first CSS function is `var`, case-insensitively). dart's legacy
/// two-argument `rgb($color, $alpha)` / `hsl` overloads short-circuit to a
/// verbatim passthrough only for `var()` — not `env()`, `calc()`, or any other
/// special — so the color-type check is suppressed exactly when a `var()` is
/// present.
fn is_var(v: &Value) -> bool {
    matches!(v, Value::Str(s) if !s.quoted && {
        let t = s.text.trim_start();
        t.len() >= 4 && t[..4].eq_ignore_ascii_case("var(")
    })
}

/// Like [`is_special`] but for the legacy `rgb`/`hsl` channels, where a
/// `calc()` that folds to a degenerate constant (`infinity`, `-infinity`,
/// `NaN`) is *not* special — dart-sass folds it to that floating point value
/// and computes/clamps the real channel rather than preserving the call.
fn is_special_legacy(v: &Value) -> bool {
    match v {
        Value::Calc(node) => degenerate_const(node).is_none(),
        other => is_special(other),
    }
}

/// The floating-point value of a degenerate `calc()` constant
/// (`calc(infinity)`, `calc(-infinity)`, `calc(NaN)`), or `None` for any other
/// calculation. dart-sass folds these constants to the corresponding `f64`.
fn degenerate_const(node: &CalcNode) -> Option<f64> {
    if let CalcNode::Str(s) = node {
        return match s.trim().to_ascii_lowercase().as_str() {
            "infinity" => Some(f64::INFINITY),
            "-infinity" => Some(f64::NEG_INFINITY),
            "nan" => Some(f64::NAN),
            _ => None,
        };
    }
    None
}

/// Whether a value is the `none` missing-channel keyword (an unquoted `none`).
pub(super) fn is_none_keyword(v: &Value) -> bool {
    matches!(v, Value::Str(s) if !s.quoted && s.text.eq_ignore_ascii_case("none"))
}

/// Re-serialize a special-value color call: `name(arg1, arg2, …)`, each
/// argument via `to_css(false)`, comma-joined (the form dart-sass normalizes
/// every legacy `rgb()`/`hsl()` special-value call to).
fn special_call(name: &str, args: &[&Value]) -> Value {
    let parts: Vec<String> = args.iter().map(|v| v.to_css(false)).collect();
    Value::Str(crate::value::SassStr {
        text: format!("{name}({})", parts.join(", ")).into(),
        quoted: false,
    })
}

/// Preserve a color call verbatim from a single channels value (space- or
/// slash-joined), matching dart-sass's "wrong channel count" passthrough
/// (`rgb(var(--foo) 2)` → `rgb(var(--foo) 2)`).
fn verbatim_call(name: &str, channels: &Value) -> Value {
    Value::Str(crate::value::SassStr {
        text: format!("{name}({})", channels.to_css(false)).into(),
        quoted: false,
    })
}

/// The name of the channel at index `i` for a legacy color-function error
/// message: a named channel for the first three (`red channel`,
/// `hue channel`, …), or `channel <N>` (1-based) for any overflow position,
/// matching dart-sass.
fn legacy_channel_name(names: &[&str], i: usize) -> String {
    match names.get(i) {
        Some(name) => format!("{name} channel"),
        None => format!("channel {}", i + 1),
    }
}

// The modern color-space member names live with their dispatch in `modern`;
// aliased here (a `const` alias, not a `use` re-export, to keep `modern::NAMES`
// `pub(super)`) so `is_builtin`'s family table can fold them into the color
// family without duplicating the list.
pub(super) const MODERN_NAMES: &[&str] = modern::NAMES;

/// The core color names this module's `try_call` owns by name (the single
/// source of truth, mirroring the match arms below). The modern CSS Color 4
/// members `try_call` delegates to live in [`MODERN_NAMES`]; the family's full
/// name set is the union of the two (see `is_builtin`).
pub(super) const NAMES: &[&str] = &[
    "rgb",
    "rgba",
    "hsl",
    "hsla",
    "hwb",
    "lab",
    "lch",
    "oklab",
    "oklch",
    "color",
    "mix",
    "lighten",
    "darken",
    "percentage",
    "red",
    "green",
    "blue",
    "alpha",
];

pub(super) fn try_call(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    Some(match name {
        "rgb" | "rgba" => fn_rgb(name, pos_args, named, pos),
        "hsl" | "hsla" => fn_hsl(name, pos_args, named, pos),
        "hwb" => fn_hwb(pos_args, named, pos),
        "lab" | "lch" | "oklab" | "oklch" => fn_lab_family(name, pos_args, named, pos),
        "color" => fn_color(pos_args, named, pos),
        "mix" => fn_mix(pos_args, named, pos),
        "lighten" => fn_adjust_lightness(name, pos_args, named, pos, 1.0),
        "darken" => fn_adjust_lightness(name, pos_args, named, pos, -1.0),
        "percentage" => fn_percentage(pos_args, named, pos),
        "red" | "green" | "blue" => fn_channel(name, pos_args, named, pos),
        "alpha" => fn_alpha(pos_args, named, pos),
        _ => return try_call_modern(name, pos_args, named, pos),
    })
}

/// Read an alpha argument: a `%` is divided by 100, a unitless number is used
/// directly, and the result is clamped to `[0, 1]`. NaN clamps to 0. Any
/// other unit is an error (`Expected … to have unit "%" or no units.`).
fn alpha_value(v: &Value, pos: Pos) -> Result<f64, Error> {
    if let Some(c) = degenerate_value(v) {
        // A degenerate alpha is still an alpha: its UNIT is checked first, so
        // `calc(infinity * 1px)` is the wrong unit rather than an opaque
        // color. A `%` one divides like a literal percentage (which changes
        // nothing for a non-finite value, but keeps the two paths the same).
        let pct = match channel_unit_number(v) {
            Some(n) if !n.has_complex_units() && n.unit() == "%" => true,
            Some(n) if !n.is_unitless() => {
                return Err(Error::at(
                    format!(
                        "$alpha: Expected {} to have unit \"%\" or no units.",
                        v.to_css(false)
                    ),
                    pos,
                ))
            }
            _ => false,
        };
        return Ok(clamp_alpha(if pct { c / 100.0 } else { c }));
    }
    match v {
        // One arm for both spellings: a slash-division's quotient carries its
        // unit like any number, so it cannot drift from the literal path. (No
        // input reaches here as a `Slash` today — a channels list's alpha is
        // split out as a plain token, and a division anywhere else has already
        // evaluated to a number — but the two must not diverge if one ever
        // does.)
        Value::Number(num) | Value::Slash(num, _) => {
            // A COMPOUND unit only reports its first numerator, so `%*px` is
            // not the percentage it starts with.
            let raw = if !num.has_complex_units() && num.unit() == "%" {
                num.value / 100.0
            } else if num.is_unitless() {
                num.value
            } else {
                return Err(Error::at(
                    format!(
                        "$alpha: Expected {} to have unit \"%\" or no units.",
                        num.to_css(false)
                    ),
                    pos,
                ));
            };
            Ok(clamp_alpha(raw))
        }
        other => Err(Error::at(
            format!("$alpha: {} is not a number.", channel_err_css(other)),
            pos,
        )),
    }
}

/// Clamp an alpha value to `[0, 1]`, mapping NaN — and a negative zero, which
/// `clamp` keeps — to 0 (matching dart-sass).
fn clamp_alpha(v: f64) -> f64 {
    if v.is_nan() {
        0.0
    } else {
        crate::value::without_negative_zero(v.clamp(0.0, 1.0))
    }
}

/// Whether a value is a `calc()` that folds to a degenerate constant
/// (`infinity`, `-infinity`, `NaN`).
fn is_degenerate_calc(v: &Value) -> bool {
    degenerate_value(v).is_some()
}

/// The non-finite value of a degenerate channel: a non-finite number (the
/// usual form, since a fully-folded `calc()` unwraps to a number), the
/// quotient a slash-division carries (`hsl(0/0 50% 50%)` — inside a
/// SPACE-separated channels list `0/0` keeps its spelling instead of
/// collapsing to a number), or a residual `calc()` constant.
fn degenerate_value(v: &Value) -> Option<f64> {
    match v {
        Value::Number(n) | Value::Slash(n, _) if !n.value.is_finite() => Some(n.value),
        Value::Calc(node) => match node {
            CalcNode::Number(n) if !n.value.is_finite() => Some(n.value),
            _ => degenerate_const(node),
        },
        _ => None,
    }
}

/// The [`Number`] underlying a color channel for unit inspection and
/// normalization: a plain number, the quotient of a slash-division (`6px/2`,
/// whose unit decides the channel's), or a degenerate `calc()` that folded to
/// a unit-bearing number (`calc(infinity * 1px)`). Returns `None` for any
/// non-numeric channel (handled by the "is not a number" / passthrough paths).
fn channel_unit_number(v: &Value) -> Option<&Number> {
    match v {
        Value::Number(n) | Value::Slash(n, _) | Value::Calc(CalcNode::Number(n)) => Some(n),
        _ => None,
    }
}

/// dart-sass 1.104.0: "Colors now convert NaN and negative zero, as well as
/// infinity and negative infinity for polar-hue channels, to 0 as per the CSS
/// spec." This runs on the channel VALUE before anything else inspects it, so
/// a `NaN` channel stops being degenerate at all and the call parses into an
/// ordinary color. Only a surviving infinity is still degenerate and keeps its
/// `calc(...)` spelling (`hsl(0, calc(infinity * 1%), 50%)`).
///
/// A FINITE negative zero converts here too, rather than on the stored
/// channels: the degenerate path a surviving infinity takes serializes the
/// values it was handed instead of a built color, so `hsl(-0, calc(infinity),
/// 50%)` would otherwise write the sign back out.
fn normalize_channel(v: &Value, polar_hue: bool) -> Value {
    let num = channel_unit_number(v);
    let converts = match degenerate_value(v) {
        Some(c) => c.is_nan() || (polar_hue && c.is_infinite()),
        None => num.is_some_and(|n| n.value == 0.0 && n.value.is_sign_negative()),
    };
    if !converts {
        return v.clone();
    }
    // The zero keeps the channel's UNIT, so the per-channel unit checks still
    // see what the caller wrote: `calc(NaN * 1%)` is a `%` whiteness, and
    // `calc(NaN * 1px)` is still the wrong unit.
    let zero = match num {
        Some(n) => n.copy_units(0.0),
        None => Number::unitless(0.0),
    };
    Value::Number(zero)
}

/// Apply [`normalize_channel`] to every component of a channel list, where
/// `polar_hue` is the index of the space's hue channel (if it has one).
fn normalize_channels(comps: &[Value], polar_hue: Option<usize>) -> Vec<Value> {
    comps
        .iter()
        .enumerate()
        .map(|(i, v)| normalize_channel(v, polar_hue == Some(i)))
        .collect()
}

/// dart validates the ALPHA's unit early — after the all-numeric channel pass
/// but before the channel COUNT and before the channels' own units — so a bad
/// alpha is what gets reported when the channels are wrong as well. Only the
/// unit is checked here; every other alpha error stays where it is.
fn validate_alpha_unit(alpha: Option<&Value>, pos: Pos) -> Result<(), Error> {
    let Some(a) = alpha else { return Ok(()) };
    if let Some(n) = channel_unit_number(a) {
        if !n.is_unitless() && (n.has_complex_units() || n.unit() != "%") {
            return Err(Error::at(
                format!(
                    "$alpha: Expected {} to have unit \"%\" or no units.",
                    a.to_css(false)
                ),
                pos,
            ));
        }
    }
    Ok(())
}

/// Render a non-number CHANNEL for a "channel to be a number" diagnostic: an
/// unbracketed multi-item list is parenthesized (`(1 2)`, `(1, 2)`), matching
/// dart-sass; a bracketed one already carries its own delimiters, and every
/// other value prints plainly.
fn channel_err_css(v: &Value) -> String {
    match v {
        Value::List(l) if l.items.len() > 1 && !l.bracketed => list_paren_css(v),
        _ => v.to_css(false),
    }
}

/// Serialize a list value wrapped in parentheses, as dart-sass does in its
/// channel-list error messages (`(1%, 2, 3)`, `(1% 2)`).
fn list_paren_css(v: &Value) -> String {
    format!("({})", v.to_css(false))
}
