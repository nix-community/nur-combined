//! Extended color built-ins (`adjust-hue`, `saturate`, `desaturate`,
//! `complement`, `invert`, `grayscale`, `opacify`/`transparentize`, the
//! `hue`/`saturation`/`lightness` getters, …).
//!
//! Results are *computed* colors: they carry no source spelling, so they
//! serialize via the normal `rgb()`/`rgba()`/hex rule, matching dart-sass.
//! The adjusters keep the input color's SPACE, though — dart hands
//! `saturate(hsl(…), 10%)` back as an `hsl()` — which is what
//! [`legacy_hsl_adjust`] and [`legacy_alpha_adjust`] are for.

use super::color::{
    legacy_alpha_adjust, legacy_hsl_adjust, missing_channel_err, modify_in_space, modify_in_space_opt,
    space_arg, stored_alpha, ModifyOp,
};
use super::{arg, as_color, clamp01, num, require, require_legacy_color};
use crate::error::Error;
use crate::scanner::Pos;
use crate::value::{Color, ColorSpace, Number, SassStr, Value};

/// The modern change/adjust/scale path: used when `$space` is given, or when
/// the color is non-legacy (its own space is the default). Returns `None` for a
/// legacy color with no `$space`, so the caller runs the legacy path.
fn modify_with_space(
    c: &Color,
    named: &[(String, Value)],
    op: ModifyOp,
    pos: Pos,
) -> Option<Result<Value, Error>> {
    let space_arg_v = named.iter().find(|(n, _)| n == "space").map(|(_, v)| v);
    let is_legacy = c.modern.as_ref().map(|m| m.space.is_legacy()).unwrap_or(true);
    if space_arg_v.is_none() && is_legacy {
        return None;
    }
    let space = match space_arg_v {
        Some(v) => match space_arg(v, pos) {
            Ok(s) => s,
            Err(e) => return Some(Err(e)),
        },
        None => c.modern.as_ref().map(|m| m.space).unwrap_or(ColorSpace::Rgb),
    };
    // `$color` (when passed by name) and `$space` are not channels.
    let chans: Vec<(String, &Value)> = named
        .iter()
        .filter(|(n, _)| n != "space" && n != "color")
        .map(|(n, v)| (n.clone(), v))
        .collect();
    // An explicit `$space` enables the powerless-channel missing check.
    Some(modify_in_space_opt(
        c,
        space,
        &chans,
        op,
        space_arg_v.is_some(),
        pos,
    ))
}

/// Build a *computed* color, tagging it with a CSS named-color spelling when
/// its rounded RGB exactly matches one of the 148 CSS color names and it is
/// fully opaque. dart-sass serializes such colors by name (e.g.
/// `lighten(red, 100%)` → `white`, `adjust-hue(red, 180)` → `aqua`); colors
/// that don't match a name fall back to the usual hex/rgb rule via `repr =
/// None`.
pub(super) fn computed(r: f64, g: f64, b: f64, a: f64) -> Color {
    let mut c = Color::rgb(r, g, b, a);
    // dart has no untagged color: an rgb RESULT that left the [0, 255] gamut —
    // a NaN channel included, which is what mixing an infinite channel
    // produces — is written through its hsl form. That rule lives in
    // `ModernColor::legacy_css`, so tag the color to reach it; an in-gamut
    // result keeps the plain hex/rgb/name spelling.
    let in_gamut = |v: f64| (-1e-9..=255.0 + 1e-9).contains(&v);
    if in_gamut(r) && in_gamut(g) && in_gamut(b) {
        c.repr = named_repr(r, g, b, a);
    } else {
        c.modern = Some(Box::new(crate::value::ModernColor {
            space: ColorSpace::Rgb,
            channels: [Some(r), Some(g), Some(b)],
            alpha: Some(a),
        }));
    }
    c
}

/// The CSS named-color spelling for an exact, fully-opaque RGB triple, using
/// dart-sass's canonical name for each color (e.g. `aqua` not `cyan`, `gray`
/// not `grey`). Returns `None` for translucent colors, non-integer channels,
/// or colors with no name.
pub(super) fn named_repr(r: f64, g: f64, b: f64, a: f64) -> Option<std::rc::Rc<str>> {
    if !crate::value::fuzzy_eq(a, 1.0) {
        return None;
    }
    let int = |v: f64| {
        // dart finds the name by looking the color up in `namesByColor`, so the
        // hit needs `fuzzyHashCode` — the 1e11 rounding of `fuzzyEquals` — to
        // agree on every channel. `[measured]`:
        // `color.change(red, $red: 254.9999999999)` is `rgb(100%, 0%, 0%)`, not
        // `red`, even though the channel is 1e-10 from 255.
        let r = v.round();
        if crate::value::fuzzy_eq(v, r) && (0.0..=255.0).contains(&r) {
            Some(r as u16)
        } else {
            None
        }
    };
    let (r, g, b) = (int(r)?, int(g)?, int(b)?);
    let name = match (r, g, b) {
        (0, 0, 0) => "black",
        (0, 0, 128) => "navy",
        (0, 0, 139) => "darkblue",
        (0, 0, 205) => "mediumblue",
        (0, 0, 255) => "blue",
        (0, 100, 0) => "darkgreen",
        (0, 128, 0) => "green",
        (0, 128, 128) => "teal",
        (0, 139, 139) => "darkcyan",
        (0, 191, 255) => "deepskyblue",
        (0, 206, 209) => "darkturquoise",
        (0, 250, 154) => "mediumspringgreen",
        (0, 255, 0) => "lime",
        (0, 255, 127) => "springgreen",
        (0, 255, 255) => "aqua",
        (25, 25, 112) => "midnightblue",
        (30, 144, 255) => "dodgerblue",
        (32, 178, 170) => "lightseagreen",
        (34, 139, 34) => "forestgreen",
        (46, 139, 87) => "seagreen",
        (47, 79, 79) => "darkslategray",
        (50, 205, 50) => "limegreen",
        (60, 179, 113) => "mediumseagreen",
        (64, 224, 208) => "turquoise",
        (65, 105, 225) => "royalblue",
        (70, 130, 180) => "steelblue",
        (72, 61, 139) => "darkslateblue",
        (72, 209, 204) => "mediumturquoise",
        (75, 0, 130) => "indigo",
        (85, 107, 47) => "darkolivegreen",
        (95, 158, 160) => "cadetblue",
        (100, 149, 237) => "cornflowerblue",
        (102, 51, 153) => "rebeccapurple",
        (102, 205, 170) => "mediumaquamarine",
        (105, 105, 105) => "dimgray",
        (106, 90, 205) => "slateblue",
        (107, 142, 35) => "olivedrab",
        (112, 128, 144) => "slategray",
        (119, 136, 153) => "lightslategray",
        (123, 104, 238) => "mediumslateblue",
        (124, 252, 0) => "lawngreen",
        (127, 255, 0) => "chartreuse",
        (127, 255, 212) => "aquamarine",
        (128, 0, 0) => "maroon",
        (128, 0, 128) => "purple",
        (128, 128, 0) => "olive",
        (128, 128, 128) => "gray",
        (135, 206, 235) => "skyblue",
        (135, 206, 250) => "lightskyblue",
        (138, 43, 226) => "blueviolet",
        (139, 0, 0) => "darkred",
        (139, 0, 139) => "darkmagenta",
        (139, 69, 19) => "saddlebrown",
        (143, 188, 143) => "darkseagreen",
        (144, 238, 144) => "lightgreen",
        (147, 112, 219) => "mediumpurple",
        (148, 0, 211) => "darkviolet",
        (152, 251, 152) => "palegreen",
        (153, 50, 204) => "darkorchid",
        (154, 205, 50) => "yellowgreen",
        (160, 82, 45) => "sienna",
        (165, 42, 42) => "brown",
        (169, 169, 169) => "darkgray",
        (173, 216, 230) => "lightblue",
        (173, 255, 47) => "greenyellow",
        (175, 238, 238) => "paleturquoise",
        (176, 196, 222) => "lightsteelblue",
        (176, 224, 230) => "powderblue",
        (178, 34, 34) => "firebrick",
        (184, 134, 11) => "darkgoldenrod",
        (186, 85, 211) => "mediumorchid",
        (188, 143, 143) => "rosybrown",
        (189, 183, 107) => "darkkhaki",
        (192, 192, 192) => "silver",
        (199, 21, 133) => "mediumvioletred",
        (205, 92, 92) => "indianred",
        (205, 133, 63) => "peru",
        (210, 105, 30) => "chocolate",
        (210, 180, 140) => "tan",
        (211, 211, 211) => "lightgray",
        (216, 191, 216) => "thistle",
        (218, 112, 214) => "orchid",
        (218, 165, 32) => "goldenrod",
        (219, 112, 147) => "palevioletred",
        (220, 20, 60) => "crimson",
        (220, 220, 220) => "gainsboro",
        (221, 160, 221) => "plum",
        (222, 184, 135) => "burlywood",
        (224, 255, 255) => "lightcyan",
        (230, 230, 250) => "lavender",
        (233, 150, 122) => "darksalmon",
        (238, 130, 238) => "violet",
        (238, 232, 170) => "palegoldenrod",
        (240, 128, 128) => "lightcoral",
        (240, 230, 140) => "khaki",
        (240, 248, 255) => "aliceblue",
        (240, 255, 240) => "honeydew",
        (240, 255, 255) => "azure",
        (244, 164, 96) => "sandybrown",
        (245, 222, 179) => "wheat",
        (245, 245, 220) => "beige",
        (245, 245, 245) => "whitesmoke",
        (245, 255, 250) => "mintcream",
        (248, 248, 255) => "ghostwhite",
        (250, 128, 114) => "salmon",
        (250, 235, 215) => "antiquewhite",
        (250, 240, 230) => "linen",
        (250, 250, 210) => "lightgoldenrodyellow",
        (253, 245, 230) => "oldlace",
        (255, 0, 0) => "red",
        (255, 0, 255) => "fuchsia",
        (255, 20, 147) => "deeppink",
        (255, 69, 0) => "orangered",
        (255, 99, 71) => "tomato",
        (255, 105, 180) => "hotpink",
        (255, 127, 80) => "coral",
        (255, 140, 0) => "darkorange",
        (255, 160, 122) => "lightsalmon",
        (255, 165, 0) => "orange",
        (255, 182, 193) => "lightpink",
        (255, 192, 203) => "pink",
        (255, 215, 0) => "gold",
        (255, 218, 185) => "peachpuff",
        (255, 222, 173) => "navajowhite",
        (255, 228, 181) => "moccasin",
        (255, 228, 196) => "bisque",
        (255, 228, 225) => "mistyrose",
        (255, 235, 205) => "blanchedalmond",
        (255, 239, 213) => "papayawhip",
        (255, 240, 245) => "lavenderblush",
        (255, 245, 238) => "seashell",
        (255, 248, 220) => "cornsilk",
        (255, 250, 205) => "lemonchiffon",
        (255, 250, 240) => "floralwhite",
        (255, 250, 250) => "snow",
        (255, 255, 0) => "yellow",
        (255, 255, 224) => "lightyellow",
        (255, 255, 240) => "ivory",
        (255, 255, 255) => "white",
        _ => return None,
    };
    Some(name.into())
}

/// The names the `color_ext` family owns by name (the single source of truth,
/// mirroring the `try_call` match arms below).
pub(super) const NAMES: &[&str] = &[
    "adjust-hue",
    "complement",
    "invert",
    "grayscale",
    "saturate",
    "desaturate",
    "opacify",
    "fade-in",
    "transparentize",
    "fade-out",
    "hue",
    "saturation",
    "lightness",
    // NOTE: `whiteness`/`blackness` are deliberately absent. dart-sass never
    // had *global* HWB getters: its `global` list (lib/src/functions/color.dart
    // :31-449) declares `_channelFunction`s only for red/green/blue and
    // hue/saturation/lightness, while `whiteness`/`blackness` appear solely in
    // the `sass:color` module list (same file, lines 532-541). Registering them
    // globally made `whiteness(c)` compute 25% where dart emits the untouched
    // plain-CSS `whiteness(hsl(120, 50%, 50%))`. They stay reachable as the
    // deprecated module members via `call_module_member` below.
    "opacity",
    "ie-hex-str",
    "scale-color",
    "adjust-color",
    "change-color",
];

pub(super) fn try_call(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    Some(match name {
        "adjust-hue" => fn_adjust_hue(pos_args, named, pos),
        "complement" => fn_complement(pos_args, named, pos),
        "invert" => return fn_invert(pos_args, named, pos),
        "grayscale" => return fn_grayscale(pos_args, named, pos),
        "saturate" => return fn_saturate(name, pos_args, named, pos, 1.0),
        "desaturate" => fn_saturate_two(name, pos_args, named, pos, -1.0),
        "opacify" | "fade-in" => fn_fade(name, pos_args, named, pos, 1.0),
        "transparentize" | "fade-out" => fn_fade(name, pos_args, named, pos, -1.0),
        // `whiteness`/`blackness` are *not* listed here: they are module-only
        // (see `call_module_member`).
        "hue" | "saturation" | "lightness" => fn_hsl_getter(name, pos_args, named, pos),
        "opacity" => return fn_opacity(pos_args, named, pos),
        "ie-hex-str" => fn_ie_hex_str(pos_args, named, pos),
        "scale-color" => fn_scale_color(pos_args, named, pos),
        "adjust-color" => fn_adjust_color(pos_args, named, pos),
        "change-color" => fn_change_color(pos_args, named, pos),
        _ => return None,
    })
}

/// `sass:color` members of this family that have **no global alias**.
///
/// dart-sass exposes `whiteness`/`blackness` only on `sass:color`
/// (lib/src/functions/color.dart:532-541, inside the `module` list); its
/// `global` list (same file, line 31) has no such entries, so a bare
/// `whiteness(…)` call is an unknown plain-CSS function that dart passes
/// through verbatim. Dispatching them here — from `call_module` only — keeps
/// `color.whiteness()` / `color.blackness()` working without leaking the names
/// back into the global namespace via `NAMES`/`try_call`.
pub(super) fn call_module_member(
    member: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    match member {
        "whiteness" | "blackness" => Some(fn_hsl_getter(member, pos_args, named, pos)),
        _ => None,
    }
}

/// Error when more than `max` POSITIONAL arguments were supplied to a
/// fixed-arity builtin — named ones do not count toward the limit, they only
/// change the wording. See [`super::check_arity`].
fn check_max_args(pos_args: &[Value], named: &[(String, Value)], max: usize, pos: Pos) -> Result<(), Error> {
    super::check_arity(max, pos_args, named, pos)
}

/// True when a value is a plain-CSS "special" expression (a number, a
/// calculation, or an unquoted string holding a CSS function like `var(...)`).
/// The legacy filter-overloaded color functions (`invert`, `grayscale`,
/// `saturate`, `opacity`) pass such an argument straight through as a CSS
/// function call rather than treating it as a color.
fn is_css_special(v: &Value) -> bool {
    match v {
        Value::Number(_) | Value::Calc(_) | Value::Slash(_, _) => true,
        Value::Str(s) => !s.quoted && s.text.contains('('),
        _ => false,
    }
}

/// Whether a call to one of the four filter-overloaded names takes the
/// plain-CSS path rather than the Sass one.
///
/// ONE definition, consulted by the functions below AND by the evaluator's
/// deprecation check. They were separate once and disagreed: the call was
/// correctly passed through as CSS while `global-builtin` was deprecated
/// anyway, so `filter: grayscale(1)` told the author to rewrite a CSS filter
/// as `color.grayscale` (#122). dart warns only on the Sass path, and the two
/// decisions have to come from the same place to stay that way.
pub(crate) fn is_plain_css_filter_call(name: &str, pos_args: &[Value], named: &[(String, Value)]) -> bool {
    let arg = |param: &str| bound_arg(pos_args, named, param);
    let one_arg = pos_args.len() + named.len() == 1;
    match name {
        // `saturate($amount)` is the CSS filter; `saturate($color, $amount)`
        // is the Sass function, so arity decides before the argument does.
        "saturate" => one_arg && arg("amount").is_some_and(is_css_special),
        // `grayscale`, `opacity` and `invert` do NOT take an arity guard, and
        // that is measured rather than assumed. dart treats `grayscale(1, 2)`
        // as the plain-CSS overload and reports only its arity error; adding
        // `one_arg` here makes the call miss this branch, so the evaluator
        // deprecates it as a global built-in and prints a warning dart never
        // does. `invert` shows the same thing from the other side: its CSS
        // branch is what raises "Only one argument may be passed to the
        // plain-CSS invert() function."
        "grayscale" | "opacity" | "invert" => arg("color").is_some_and(is_css_special),
        _ => false,
    }
}

/// The argument bound to `$param`, positionally or by name — the same binding
/// the function itself will use.
fn bound_arg<'a>(pos_args: &'a [Value], named: &'a [(String, Value)], param: &str) -> Option<&'a Value> {
    pos_args
        .first()
        .or_else(|| named.iter().find(|(n, _)| n == param).map(|(_, v)| v))
}

/// What a `sass:color` MEMBER call does with an argument that the GLOBAL
/// spelling of the same name would have passed through as a plain-CSS filter.
pub(crate) enum ModuleFilterArg {
    /// A number: the filter overload, which the module path still takes and
    /// dart deprecates there (`color-module-compat`).
    Filter,
    /// Any other plain-CSS token — `var(--c)`, `env(…)`, an unsimplifiable
    /// `calc()`, or a bare identifier like `c`. The module path does NOT take
    /// the overload for these; they are colour arguments, and fail as ones.
    NotAColor,
}

/// Which of those two a `color.grayscale`/`color.invert`/`color.opacity` call
/// is, or `None` when the argument is not plain-CSS-special at all (an ordinary
/// colour argument, handled by the function itself).
///
/// The module rule is NARROWER than [`is_plain_css_filter_call`]'s global one,
/// measured against dart-sass 1.104.1: `invert(var(--c))` is a CSS filter,
/// `color.invert(var(--c))` is `$color: var(--c) is not a color.`. Both readers
/// of that rule — the dispatcher, which must raise the error, and the
/// evaluator, which must deprecate exactly the calls that do take the overload
/// — ask this one function, because a disagreement between them would put the
/// warning where dart puts an error (#124; the same shape as #122/#123 one
/// layer up).
///
/// A `calc()` that simplifies to a number IS a number by the time it arrives,
/// so `color.grayscale(calc(1px))` is the filter overload and warns, while
/// `calc(1px + 1em)` is not and does not.
///
/// [`ModuleFilterArg::NotAColor`] covers every UNQUOTED string, not just the
/// `var(…)`-shaped ones [`is_css_special`] recognizes, because that is the only
/// place dart's `$color: ` message prefix is reproduced today: a bare
/// `color.grayscale(c)` reaches it too, and dropping to the generic colour
/// assertion loses the prefix. (That assertion is missing the prefix for every
/// other argument type as well — `null`, `true`, a map, a list — which is a
/// separate gap across the colour and math members, not this rule's.)
pub(crate) fn module_filter_arg<'a>(
    member: &str,
    pos_args: &'a [Value],
    named: &'a [(String, Value)],
) -> Option<(ModuleFilterArg, &'a Value)> {
    if !matches!(member, "grayscale" | "invert" | "opacity") {
        return None;
    }
    let arg = bound_arg(pos_args, named, "color")?;
    if matches!(arg, Value::Number(_)) {
        return Some((ModuleFilterArg::Filter, arg));
    }
    let unquoted_str = matches!(arg, Value::Str(s) if !s.quoted);
    (is_css_special(arg) || unquoted_str).then_some((ModuleFilterArg::NotAColor, arg))
}

/// The CSS text a one-argument filter overload passes through as
/// (`invert(10%)`, `grayscale(var(--c))`) — dart's `_functionString`. Also the
/// `Recommendation:` line of the `color-module-compat` deprecation, from here
/// so that the recommendation cannot spell the call differently from the value
/// the call returns.
pub(crate) fn plain_filter_text(name: &str, arg: &Value) -> String {
    format!("{name}({})", arg.to_css(false))
}

/// Preserve a one-argument filter overload verbatim (`invert(10%)`,
/// `grayscale(var(--c))`).
fn plain_filter(name: &str, arg: &Value) -> Value {
    Value::Str(SassStr {
        text: plain_filter_text(name, arg).into(),
        quoted: false,
    })
}

/// `adjust-hue($color, $degrees)` — rotate the hue by `$degrees`, converting
/// any angle unit (`rad`/`grad`/`turn`) to degrees first.
fn fn_adjust_hue(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color", "degrees"];
    check_max_args(pos_args, named, 2, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    require_legacy_color(&c, "adjust-hue", pos)?;
    let degrees = angle_degrees(require(&params, pos_args, named, 1, pos)?, pos)?;
    Ok(Value::Color(rotate_hue(&c, degrees)))
}

/// Extract a hue angle in degrees from a number, converting the common CSS
/// angle units. Unknown units (and the deprecated unitless/`in` cases) are
/// treated as degrees, matching dart-sass's lenient legacy behavior.
fn angle_degrees(v: &Value, pos: Pos) -> Result<f64, Error> {
    match v {
        Value::Number(n) => Ok(match n.unit() {
            "rad" => n.value.to_degrees(),
            "grad" => n.value * 360.0 / 400.0,
            "turn" => n.value * 360.0,
            _ => n.value,
        }),
        other => Err(Error::at(
            format!("{} is not a number.", other.to_css(false)),
            pos,
        )),
    }
}

/// `complement($color, $space)` — rotate the hue by 180 degrees in `$space`
/// (default `hsl` for legacy colors; required for non-legacy colors).
fn fn_complement(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color", "space"];
    check_max_args(pos_args, named, 2, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    let space_v = arg(&params, pos_args, named, 1);
    let is_legacy = c.modern.as_ref().map(|m| m.space.is_legacy()).unwrap_or(true);
    let space = match space_v {
        Some(v) => space_arg(v, pos)?,
        None if is_legacy => ColorSpace::Hsl,
        None => {
            return Err(Error::at(
                format!(
                    "$space: To use color.complement() with non-legacy color {}, you must provide a $space.",
                    c.to_css(false)
                ),
                pos,
            ))
        }
    };
    // The space must have a hue channel.
    if !matches!(
        space,
        ColorSpace::Hsl | ColorSpace::Hwb | ColorSpace::Lch | ColorSpace::Oklch
    ) {
        return Err(Error::at(
            format!("$space: Color space {} doesn't have a hue channel.", space.name()),
            pos,
        ));
    }
    // complement = adjust the hue by +180deg in the space. An explicit `$space`
    // enables the powerless-channel missing check.
    let deg = Value::Number(Number::with_unit(180.0, "deg"));
    modify_in_space_opt(
        &c,
        space,
        &[("hue".to_string(), &deg)],
        ModifyOp::Adjust,
        space_v.is_some(),
        pos,
    )
}

fn rotate_hue(c: &Color, degrees: f64) -> Color {
    // The hue is normalized back into `[0, 360)` when the result is rebuilt,
    // and an `rgb()`/hex input still ends up as a computed sRGB color — so
    // `adjust-hue(red, 180)` is still `aqua`.
    legacy_hsl_adjust(c, |ch| ch[0] += degrees)
}

/// `invert($color, $weight: 100%)` — invert the RGB channels, then mix the
/// inverted color toward the original by `(100% - weight)`.
///
/// When the single argument is a plain-CSS special value (a number, `var()`,
/// …) this is the CSS `invert()` filter and is preserved verbatim; passing a
/// weight alongside that form is an error.
fn fn_invert(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Option<Result<Value, Error>> {
    let params = ["color", "weight"];
    if let Err(e) = check_max_args(pos_args, named, 3, pos) {
        return Some(Err(e));
    }
    let color = match require(&params, pos_args, named, 0, pos) {
        Ok(v) => v,
        Err(e) => return Some(Err(e)),
    };
    if is_plain_css_filter_call("invert", pos_args, named) {
        if pos_args.len() + named.len() > 1 {
            return Some(Err(Error::at(
                "Only one argument may be passed to the plain-CSS invert() function.".to_string(),
                pos,
            )));
        }
        return Some(Ok(plain_filter("invert", color)));
    }
    let params = ["color", "weight", "space"];
    Some((|| {
        let c = as_color(color, pos)?;
        let weight = match arg(&params, pos_args, named, 1) {
            Some(v) => {
                let n = num(v, pos)?;
                // A NaN is within no range (dart rejects it like any
                // out-of-range value), and the bounds carry the value's unit.
                if n.is_nan() || !(0.0..=100.0).contains(&n) {
                    let unit = weight_unit(v);
                    return Err(Error::at(
                        format!(
                            "$weight: Expected {} to be within 0{unit} and 100{unit}.",
                            v.to_css(false)
                        ),
                        pos,
                    ));
                }
                n
            }
            None => 100.0,
        };
        let w = (weight / 100.0).clamp(0.0, 1.0);
        let space_v = arg(&params, pos_args, named, 2);
        let is_legacy = c.modern.as_ref().map(|m| m.space.is_legacy()).unwrap_or(true);
        // The modern form (`$space` given, or a non-legacy color) inverts each
        // channel in that space; a non-legacy color without $space errors.
        if space_v.is_some() || !is_legacy {
            let space = match space_v {
                Some(v) => space_arg(v, pos)?,
                None => {
                    return Err(Error::at(
                        format!(
                        "$color: To use color.invert() with non-legacy color {}, you must provide a $space.",
                        c.to_css(false)
                    ),
                        pos,
                    ))
                }
            };
            // An explicit `$space` enables the powerless-channel missing check.
            return Ok(Value::Color(super::color::invert_in_space(
                &c,
                space,
                w,
                space_v.is_some(),
                pos,
            )?));
        }
        // Legacy color, no `$space`: invert in rgb (which still rejects a missing
        // rgb channel, but has no powerless channels).
        Ok(Value::Color(super::color::invert_in_space(
            &c,
            ColorSpace::Rgb,
            w,
            false,
            pos,
        )?))
    })())
}

/// `grayscale($color)` — set the HSL saturation to 0. With a plain-CSS
/// special argument it is the CSS `grayscale()` filter, preserved verbatim.
fn fn_grayscale(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Option<Result<Value, Error>> {
    let params = ["color"];
    if let Err(e) = check_max_args(pos_args, named, 1, pos) {
        return Some(Err(e));
    }
    let color = match require(&params, pos_args, named, 0, pos) {
        Ok(v) => v,
        Err(e) => return Some(Err(e)),
    };
    if is_plain_css_filter_call("grayscale", pos_args, named) {
        return Some(Ok(plain_filter("grayscale", color)));
    }
    Some((|| {
        let c = as_color(color, pos)?;
        // A non-legacy color is desaturated by setting its oklch chroma to 0
        // and converting back to its own space; legacy colors set HSL
        // saturation to 0.
        let is_legacy = c.modern.as_ref().map(|m| m.space.is_legacy()).unwrap_or(true);
        if !is_legacy {
            return Ok(Value::Color(super::color::grayscale_modern(&c)));
        }
        // Legacy grayscale is `change($saturation: 0)` in HSL: a same-space
        // hsl input keeps its hue and missing channels; an rgb/hwb input
        // round-trips through hsl and back to its own space (whose legacy
        // serialization then renders the now-powerless hue as 0).
        let zero = Value::Number(crate::value::Number::with_unit(0.0, "%"));
        let chans: Vec<(String, &Value)> = vec![("saturation".to_string(), &zero)];
        super::color::modify_in_space_full(
            &c,
            ColorSpace::Hsl,
            &chans,
            super::color::ModifyOp::Change,
            false,
            false,
            pos,
        )
    })())
}

/// `saturate($amount)` (CSS filter overload) and `saturate($color, $amount)`.
/// The one-argument form with a special CSS value is preserved verbatim.
fn fn_saturate(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    sign: f64,
) -> Option<Result<Value, Error>> {
    // One argument that is a plain-CSS special value → CSS `saturate()` filter.
    if is_plain_css_filter_call("saturate", pos_args, named) {
        let v = pos_args
            .first()
            .or_else(|| named.iter().find(|(n, _)| n == "amount").map(|(_, v)| v))
            .expect("the predicate matched an argument");
        return Some(Ok(plain_filter("saturate", v)));
    }
    Some(fn_saturate_two(name, pos_args, named, pos, sign))
}

/// `saturate`/`desaturate` — adjust HSL saturation by `$amount` percent
/// (validated to be within 0 and 100).
fn fn_saturate_two(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    sign: f64,
) -> Result<Value, Error> {
    let params = ["color", "amount"];
    check_max_args(pos_args, named, 2, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    require_legacy_color(&c, name, pos)?;
    let amount = require(&params, pos_args, named, 1, pos)?;
    let amount = bounded(amount, 0.0, 100.0, true, pos)?;
    Ok(Value::Color(legacy_hsl_adjust(&c, |ch| {
        ch[1] = (ch[1] + sign * amount).clamp(0.0, 100.0);
    })))
}

/// The unit a `$weight`/`$amount` percentage argument carries into the bounds
/// of its range error (`0% and 100%`, `0px and 100px`, `0 and 100`). A
/// COMPOUND unit carries whole (`0%/px and 100%/px`), so this is the full unit
/// spelling, not the first numerator.
fn weight_unit(v: &Value) -> String {
    match v {
        Value::Number(n) | Value::Slash(n, _) => n.unit_string(),
        _ => String::new(),
    }
}

/// Read a number argument and require its value to be within `[lo, hi]`,
/// raising dart-sass's "Expected … to be within …" error otherwise. A NaN is
/// within no range at all, so it is rejected like any out-of-range value
/// (`saturate(red, math.div(0, 0))` is an error in dart-sass, not a color).
/// The number's unit is preserved in the message, and `unit_bounds` spells the
/// BOUNDS with it as well — which dart does for the percentage `$amount`
/// (`saturate(red, 200px)` says `0px and 100px`) but not for the alpha ratio
/// (`transparentize(red, 2px)` still says `0 and 1`).
fn bounded(v: &Value, lo: f64, hi: f64, unit_bounds: bool, pos: Pos) -> Result<f64, Error> {
    match v {
        Value::Number(n) => {
            if n.value.is_nan() || n.value < lo || n.value > hi {
                let unit = if unit_bounds {
                    n.unit_string()
                } else {
                    String::new()
                };
                Err(Error::at(
                    format!(
                        "$amount: Expected {} to be within {}{unit} and {}{unit}.",
                        n.to_css(false),
                        fmt_bound(lo),
                        fmt_bound(hi),
                    ),
                    pos,
                ))
            } else {
                Ok(n.value)
            }
        }
        other => Err(Error::at(
            format!("$amount: {} is not a number.", other.to_css(false)),
            pos,
        )),
    }
}

fn fmt_bound(v: f64) -> String {
    if v.fract() == 0.0 {
        format!("{}", v as i64)
    } else {
        format!("{v}")
    }
}

/// `opacify`/`fade-in` (`sign = +1`) and `transparentize`/`fade-out`
/// (`sign = -1`) — shift the alpha by `$amount`, clamped to `[0, 1]`.
fn fn_fade(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
    sign: f64,
) -> Result<Value, Error> {
    let params = ["color", "amount"];
    check_max_args(pos_args, named, 2, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    require_legacy_color(&c, name, pos)?;
    let amount = require(&params, pos_args, named, 1, pos)?;
    let amount = bounded(amount, 0.0, 1.0, false, pos)?;
    Ok(Value::Color(legacy_alpha_adjust(&c, |a| {
        clamp01(a + sign * amount)
    })))
}

/// `hue` (deg), `saturation`/`lightness` (%), and the HWB-derived
/// `whiteness`/`blackness` (%) getters.
fn fn_hsl_getter(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Result<Value, Error> {
    let params = ["color"];
    check_max_args(pos_args, named, 1, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    // These legacy getters only support legacy colors.
    let is_legacy = c.modern.as_ref().map(|m| m.space.is_legacy()).unwrap_or(true);
    if !is_legacy {
        let space = if matches!(name, "whiteness" | "blackness") {
            "hwb"
        } else {
            "hsl"
        };
        return Err(Error::at(
            format!(
                "color.{name}() is only supported for legacy colors. Please use color.channel() \
                 instead with an explicit $space argument.\n\n\
                 color.channel($color, \"{name}\", $space: {space})"
            ),
            pos,
        ));
    }
    // Prefer the stored hsl/hwb channels (exact) over re-deriving from rgb.
    if let Some(m) = &c.modern {
        let idx = match (m.space, name) {
            (crate::value::ColorSpace::Hsl, "hue") | (crate::value::ColorSpace::Hwb, "hue") => {
                Some((0, "deg"))
            }
            (crate::value::ColorSpace::Hsl, "saturation") => Some((1, "%")),
            (crate::value::ColorSpace::Hsl, "lightness") => Some((2, "%")),
            (crate::value::ColorSpace::Hwb, "whiteness") => Some((1, "%")),
            (crate::value::ColorSpace::Hwb, "blackness") => Some((2, "%")),
            _ => None,
        };
        if let Some((i, unit)) = idx {
            return Ok(Value::Number(Number::with_unit(
                m.channels[i].unwrap_or(0.0),
                unit,
            )));
        }
    }
    let (h, s, l) = c.to_hsl();
    let (value, unit) = match name {
        "hue" => (h, "deg"),
        "saturation" => (s * 100.0, "%"),
        "lightness" => (l * 100.0, "%"),
        "whiteness" => (c.r.min(c.g).min(c.b) / 255.0 * 100.0, "%"),
        // blackness
        _ => ((1.0 - c.r.max(c.g).max(c.b) / 255.0) * 100.0, "%"),
    };
    Ok(Value::Number(Number::with_unit(value, unit)))
}

/// `opacity($color)` returns the alpha; `opacity($number)` (CSS filter
/// overload) is preserved verbatim.
fn fn_opacity(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Option<Result<Value, Error>> {
    let params = ["color"];
    if let Err(e) = check_max_args(pos_args, named, 1, pos) {
        return Some(Err(e));
    }
    let color = match require(&params, pos_args, named, 0, pos) {
        Ok(v) => v,
        Err(e) => return Some(Err(e)),
    };
    if is_plain_css_filter_call("opacity", pos_args, named) {
        return Some(Ok(plain_filter("opacity", color)));
    }
    Some((|| {
        let c = as_color(color, pos)?;
        Ok(Value::Number(Number::unitless(stored_alpha(&c))))
    })())
}

/// `ie-hex-str($color)` — the `#AARRGGBB` Internet Explorer hex string.
fn fn_ie_hex_str(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color"];
    check_max_args(pos_args, named, 1, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    let byte = |v: f64| v.round().clamp(0.0, 255.0) as u8;
    let text = format!(
        "#{:02X}{:02X}{:02X}{:02X}",
        byte(stored_alpha(&c) * 255.0),
        byte(c.r),
        byte(c.g),
        byte(c.b)
    );
    Ok(Value::Str(SassStr {
        text: text.into(),
        quoted: false,
    }))
}

// ---- scale-color / adjust-color / change-color ------------------------

/// Which legacy color space a set of keyword channels operates in.
#[derive(Clone, Copy, PartialEq)]
enum Space {
    Rgb,
    Hsl,
    Hwb,
}

impl Space {
    fn name(self) -> &'static str {
        match self {
            Space::Rgb => "rgb",
            Space::Hsl => "hsl",
            Space::Hwb => "hwb",
        }
    }
}

/// The legacy [`Space`] a color is already in — the fallback working space
/// when no channel keyword names one.
fn own_space(c: &Color) -> Space {
    match c.modern.as_ref().map(|m| m.space) {
        Some(ColorSpace::Hsl) => Space::Hsl,
        Some(ColorSpace::Hwb) => Space::Hwb,
        _ => Space::Rgb,
    }
}

/// A resolved channel argument: its keyword name and the supplied value.
type ChannelArg<'v> = (&'v str, &'v Value);

/// A channel keyword (`red`, `hue`, `alpha`, …) and the space(s) it belongs
/// to. `hue` is shared between HSL and HWB; `alpha` is universal.
fn channel_space(name: &str) -> Option<(Option<Space>, bool)> {
    // (specific space, is_hue_shared)
    Some(match name {
        "red" | "green" | "blue" => (Some(Space::Rgb), false),
        "saturation" | "lightness" => (Some(Space::Hsl), false),
        "whiteness" | "blackness" => (Some(Space::Hwb), false),
        "hue" => (None, true),
        "alpha" => return Some((None, false)),
        _ => return None,
    })
}

/// Collect the channel keyword arguments and resolve the operating space,
/// matching dart-sass's legacy detection: the first space-specific channel
/// fixes the space (hue-only defaults to HSL); any later channel not valid in
/// that space is an error.
fn resolve_channels<'v>(
    _fname: &str,
    c: &Color,
    named: &'v [(String, Value)],
    pos: Pos,
) -> Result<(Space, Vec<ChannelArg<'v>>), Error> {
    // The `$color` argument may be passed by name; it is not a channel.
    let chans: Vec<ChannelArg<'v>> = named
        .iter()
        .filter(|(n, _)| n != "color")
        .map(|(n, v)| (n.as_str(), v))
        .collect();
    // Determine the space from the first space-specific channel. If only the
    // shared `hue` channel is given, default to HSL; with no recognized
    // channel at all — a channel-less or alpha-only call, or an unknown
    // channel name — dart works in the COLOR'S OWN space. That is only
    // observable through a missing channel, which an unnecessary round trip
    // through rgb would fill in (`color.change(hsl(240 none 50%), $alpha: 0.5)`
    // is `hsl(240deg none 50% / 0.5)`, not `hsla(0, 0%, 50%, 0.5)`), and
    // through the unknown-channel error, which names that space.
    let mut space: Option<Space> = None;
    let mut has_hue = false;
    for (n, _) in &chans {
        match channel_space(n) {
            Some((Some(s), _)) => {
                space = Some(s);
                break;
            }
            Some((None, true)) => has_hue = true,
            _ => {}
        }
    }
    let space = space.unwrap_or(if has_hue { Space::Hsl } else { own_space(c) });
    // Validate every channel belongs to the resolved space (alpha is allowed
    // everywhere; unknown channels error against the resolved space too).
    for (n, _) in &chans {
        if *n == "alpha" {
            continue;
        }
        let ok = match channel_space(n) {
            Some((Some(s), _)) => s == space,
            Some((None, true)) => space != Space::Rgb, // hue
            _ => false,
        };
        if !ok {
            return Err(Error::at(
                format!(
                    "${n}: Color space {} doesn't have a channel with this name.",
                    space.name()
                ),
                pos,
            ));
        }
    }
    Ok((space, chans))
}

/// `adjust-color($color, channels…)` — add each amount to the matching
/// channel (rgb values 0–255, hsl/hwb percentages, hue degrees, alpha 0–1),
/// then clamp.
fn fn_adjust_color(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color"];
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    if pos_args.len() > 1 {
        return Err(Error::at(
            "Only one positional argument is allowed. All other arguments must be passed by name."
                .to_string(),
            pos,
        ));
    }
    if let Some(r) = modify_with_space(&c, named, super::color::ModifyOp::Adjust, pos) {
        return r;
    }
    // Legacy color with no $space: detect the legacy space from the channel
    // keywords, then run the modern adjust path (which clamps only rgb/[0,255]
    // and the perceptual lightness/chroma, leaving hsl/hwb percentages free).
    let (space, chans) = resolve_channels("adjust-color", &c, named, pos)?;
    let cspace = match space {
        Space::Rgb => ColorSpace::Rgb,
        Space::Hsl => ColorSpace::Hsl,
        Space::Hwb => ColorSpace::Hwb,
    };
    let chan_args: Vec<(String, &Value)> = chans.iter().map(|(n, v)| (n.to_string(), *v)).collect();
    modify_in_space(&c, cspace, &chan_args, super::color::ModifyOp::Adjust, pos)
}

/// `change-color($color, channels…)` — set each channel to the given value
/// (alpha validated to `[0, 1]`).
fn fn_change_color(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color"];
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    if pos_args.len() > 1 {
        return Err(Error::at(
            "Only one positional argument is allowed. All other arguments must be passed by name."
                .to_string(),
            pos,
        ));
    }
    if let Some(r) = modify_with_space(&c, named, super::color::ModifyOp::Change, pos) {
        return r;
    }
    // Legacy color with no $space: detect the legacy space from the channel
    // keywords, then run the modern (non-clamping, `none`-aware) modify path so
    // out-of-range channels and missing channels match dart-sass.
    let (space, chans) = resolve_channels("change-color", &c, named, pos)?;
    let cspace = match space {
        Space::Rgb => ColorSpace::Rgb,
        Space::Hsl => ColorSpace::Hsl,
        Space::Hwb => ColorSpace::Hwb,
    };
    let chan_args: Vec<(String, &Value)> = chans.iter().map(|(n, v)| (n.to_string(), *v)).collect();
    modify_in_space(&c, cspace, &chan_args, super::color::ModifyOp::Change, pos)
}

/// `scale-color($color, channels…)` — fluidly scale each channel a percentage
/// of the way toward its bound. Each amount must be a `%` within `[-100,
/// 100]`.
fn fn_scale_color(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color"];
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    if pos_args.len() > 1 {
        return Err(Error::at(
            "Only one positional argument is allowed. All other arguments must be passed by name."
                .to_string(),
            pos,
        ));
    }
    if let Some(r) = modify_with_space(&c, named, super::color::ModifyOp::Scale, pos) {
        return r;
    }
    let (space, chans) = resolve_channels("scale-color", &c, named, pos)?;
    let cspace = match space {
        Space::Rgb => ColorSpace::Rgb,
        Space::Hsl => ColorSpace::Hsl,
        Space::Hwb => ColorSpace::Hwb,
    };
    // A color with missing channels keeps them when only the alpha (or
    // nothing) is scaled — the byte-tuple decomposition below would collapse
    // `rgb(none none none)` to black (dart preserves the missing channels).
    {
        let mc = super::color::legacy_to_modern(&c);
        if mc.channels.iter().any(Option::is_none) && chans.iter().all(|(n, _)| *n == "alpha") {
            let mut out = mc;
            for (_, v) in &chans {
                // `scale` combines the amount with the channel's current value,
                // so a MISSING alpha is unsupported here exactly as it is on the
                // common path — this shortcut must not read it as opaque.
                if out.alpha.is_none() {
                    return Err(missing_channel_err("alpha", &Value::Color(c.clone()), pos));
                }
                let factor = scale_factor("alpha", v, pos)?;
                let a = out.alpha.unwrap_or(1.0);
                out.alpha = Some(scale_toward(a, factor, 1.0));
            }
            let space = out.space;
            return Ok(Value::Color(super::color::make_modern_in(out, space)));
        }
    }
    // Run the modern scale path (like adjust/change above): it operates on
    // the color's OWN stored channels — so an hwb color keeps its space and
    // its raw (un-normalized) whiteness/blackness, matching dart.
    let chan_args: Vec<(String, &Value)> = chans.iter().map(|(n, v)| (n.to_string(), *v)).collect();
    modify_in_space(&c, cspace, &chan_args, super::color::ModifyOp::Scale, pos)
}

/// Scale `current` by `factor` (`-1..=1`) toward `max` (when positive) or `0`
/// (when negative).
fn scale_toward(current: f64, factor: f64, max: f64) -> f64 {
    if factor > 0.0 {
        current + (max - current) * factor
    } else {
        current + current * factor
    }
}

/// Read a scale-color amount: a `%` within `[-100, 100]`, returned as a
/// fraction in `[-1, 1]`.
fn scale_factor(name: &str, v: &Value, pos: Pos) -> Result<f64, Error> {
    match v {
        Value::Number(n) => {
            // A COMPOUND unit only reports its first numerator, so `%*px` must
            // be rejected explicitly rather than read as a percentage.
            if n.has_complex_units() || n.unit() != "%" {
                return Err(Error::at(
                    format!("${name}: Expected {} to have unit \"%\".", n.to_css(false)),
                    pos,
                ));
            }
            // A NaN is within no range, so it is rejected like any
            // out-of-range value rather than scaling the channel to nothing.
            if n.value.is_nan() || n.value < -100.0 || n.value > 100.0 {
                return Err(Error::at(
                    format!(
                        "${name}: Expected {} to be within -100% and 100%.",
                        n.to_css(false)
                    ),
                    pos,
                ));
            }
            Ok(n.value / 100.0)
        }
        other => Err(Error::at(
            format!("${name}: {} is not a number.", other.to_css(false)),
            pos,
        )),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::value::Color;

    fn pos() -> Pos {
        Pos { line: 1, col: 1 }
    }

    fn col(s: &str) -> Value {
        let digits = s.strip_prefix('#').unwrap_or(s);
        Value::Color(Color::from_hex(digits).expect("valid hex"))
    }

    fn n(v: f64, unit: &str) -> Value {
        Value::Number(Number::with_unit(v, unit))
    }

    fn css(name: &str, args: &[Value]) -> String {
        try_call(name, args, &[], pos())
            .expect("name owned by color_ext family")
            .expect("no error")
            .to_css(false)
    }

    #[test]
    fn adjust_hue_and_complement() {
        assert_eq!(css("adjust-hue", &[col("#6b717f"), n(60.0, "deg")]), "#796b7f");
        assert_eq!(css("adjust-hue", &[col("#6b717f"), n(-60.0, "deg")]), "#6b7f79");
        assert_eq!(css("complement", &[col("#6b717f")]), "#7f796b");
    }

    #[test]
    fn invert_full_and_weighted() {
        assert_eq!(css("invert", &[col("#b37399")]), "#4c8c66");
        assert_eq!(
            css("invert", &[col("#b37399"), n(80.0, "%")]),
            "rgb(37.8823529412%, 52.9411764706%, 44%)"
        );
        assert_eq!(
            css("invert", &[col("#b37399"), n(50.0, "%")]),
            "rgb(50%, 50%, 50%)"
        );
    }

    #[test]
    fn grayscale_saturate_desaturate() {
        assert_eq!(css("grayscale", &[col("#6b717f")]), "#757575");
        assert_eq!(
            css("saturate", &[col("#cc6699"), n(30.0, "%")]),
            "rgb(92%, 28%, 60%)"
        );
        assert_eq!(css("desaturate", &[col("#6b717f"), n(20.0, "%")]), "#757575");
    }

    #[test]
    fn alpha_shifts() {
        let rgba = Value::Color(Color::rgb(0.0, 51.0, 102.0, 0.7));
        assert_eq!(
            css("opacify", &[rgba.clone(), n(0.2, "")]),
            "rgba(0, 51, 102, 0.9)"
        );
        assert_eq!(
            css("fade-in", &[rgba.clone(), n(0.2, "")]),
            "rgba(0, 51, 102, 0.9)"
        );
        assert_eq!(
            css("transparentize", &[rgba.clone(), n(0.2, "")]),
            "rgba(0, 51, 102, 0.5)"
        );
        // Opacify past full opacity collapses to an opaque hex.
        assert_eq!(css("opacify", &[rgba, n(0.5, "")]), "#003366");
    }

    #[test]
    fn hsl_getters_units() {
        assert_eq!(css("hue", &[col("#6b717f")]), "222deg");
        assert_eq!(css("saturation", &[col("#6b717f")]), "8.547008547%");
        assert_eq!(css("lightness", &[col("#6b717f")]), "45.8823529412%");
    }

    #[test]
    fn unowned_returns_none() {
        assert!(try_call("not-a-color-fn", &[], &[], pos()).is_none());
    }
}
