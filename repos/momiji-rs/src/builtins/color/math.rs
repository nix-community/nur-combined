use super::*;

// =====================================================================
// CSS Color 4 color-space conversion engine.
//
// Channels are stored in each space's canonical units:
//   * rgb/srgb/srgb-linear/display-p3/a98-rgb/prophoto-rgb/rec2020:
//       red/green/blue in 0..=1 (the legacy `rgb` space additionally keeps a
//       0..=255 mirror in Color::{r,g,b}).
//   * hsl: hue deg, saturation/lightness in percent (0..=100).
//   * hwb: hue deg, whiteness/blackness in percent (0..=100).
//   * xyz / xyz-d50: x/y/z unbounded.
//   * lab: lightness 0..=100, a/b unbounded; lch: lightness 0..=100,
//       chroma >= 0, hue deg.
//   * oklab: lightness 0..=1, a/b unbounded; oklch: lightness 0..=1,
//       chroma >= 0, hue deg.
// A `None` channel is a missing channel; conversions treat it as 0.
// =====================================================================

/// Replace a missing (`None`) channel with `0.0` for arithmetic.
pub(super) fn z(v: Option<f64>) -> f64 {
    v.unwrap_or(0.0)
}

/// The CSS Color 4 "analogous component" category of a channel, used to carry
/// a missing channel through a color-space conversion. `None` for channels that
/// are never analogous to a differently-named channel.
#[derive(PartialEq, Eq, Clone, Copy)]
pub(super) enum ChannelCategory {
    Red,
    Green,
    Blue,
    Lightness,
    Colorfulness, // saturation / chroma
    Hue,
    LabA,
    LabB,
    Whiteness,
    Blackness,
}

pub(super) fn channel_category(space: ColorSpace, idx: usize) -> Option<ChannelCategory> {
    use ChannelCategory::*;
    use ColorSpace::*;
    Some(match (space, idx) {
        (Rgb, 0)
        | (Srgb, 0)
        | (SrgbLinear, 0)
        | (DisplayP3, 0)
        | (DisplayP3Linear, 0)
        | (A98Rgb, 0)
        | (ProphotoRgb, 0)
        | (Rec2020, 0) => Red,
        (Rgb, 1)
        | (Srgb, 1)
        | (SrgbLinear, 1)
        | (DisplayP3, 1)
        | (DisplayP3Linear, 1)
        | (A98Rgb, 1)
        | (ProphotoRgb, 1)
        | (Rec2020, 1) => Green,
        (Rgb, 2)
        | (Srgb, 2)
        | (SrgbLinear, 2)
        | (DisplayP3, 2)
        | (DisplayP3Linear, 2)
        | (A98Rgb, 2)
        | (ProphotoRgb, 2)
        | (Rec2020, 2) => Blue,
        (Hsl, 0) | (Hwb, 0) | (Lch, 2) | (Oklch, 2) => Hue,
        (Hsl, 1) | (Lch, 1) | (Oklch, 1) => Colorfulness,
        (Hsl, 2) | (Lab, 0) | (Lch, 0) | (Oklab, 0) | (Oklch, 0) => Lightness,
        (Hwb, 1) => Whiteness,
        (Hwb, 2) => Blackness,
        (Lab, 1) | (Oklab, 1) => LabA,
        (Lab, 2) | (Oklab, 2) => LabB,
        // CSS Color 4 groups the xyz channels with the analogous rgb channels
        // for missing-component carry (Reds: r/x, Greens: g/y, Blues: b/z).
        (XyzD65, 0) | (XyzD50, 0) => Red,
        (XyzD65, 1) | (XyzD50, 1) => Green,
        (XyzD65, 2) | (XyzD50, 2) => Blue,
        _ => return None,
    })
}

/// Convert a [`ModernColor`] to a new space, preserving alpha and carrying
/// over missing channels into analogous channels of the target (CSS Color 4).
pub(crate) fn convert_modern(mc: &ModernColor, target: ColorSpace) -> ModernColor {
    if mc.space == target {
        return mc.clone();
    }
    let src = [z(mc.channels[0]), z(mc.channels[1]), z(mc.channels[2])];
    // dart-sass's exact conversion graph: one precomputed matrix between
    // linear spaces, glibc-rounded `pow`, and dart's formula shapes — see
    // `builtins::colorspace`.
    let out = crate::builtins::colorspace::convert(mc.space, target, src);
    // For each output channel, become missing if the analogous source channel
    // was missing.
    let missing_in_src = |cat: ChannelCategory| {
        (0..3).any(|i| mc.channels[i].is_none() && channel_category(mc.space, i) == Some(cat))
    };
    let mk = |i: usize| match channel_category(target, i) {
        Some(cat) if missing_in_src(cat) => None,
        _ => Some(out[i]),
    };
    let mut channels = [mk(0), mk(1), mk(2)];
    // A hue that is powerless in the result becomes a missing channel,
    // matching dart-sass's conversion behavior: lch/oklch at zero chroma, hsl
    // at fuzzy-zero saturation, and hwb when whiteness+blackness covers
    // everything. (The legacy result fill then turns a missing hsl/hwb hue
    // into 0.)
    // Each of these is dart's `fuzzyEquals(channel, 0)`, with the 1e11 rounding
    // clause that makes 6e-12 NOT zero. `[measured]` against dart-sass 1.104.1:
    // `color.is-missing(color.to-space(lab(50% 0.000000000006 0), lch), "hue")`
    // is false.
    let fz = crate::value::fuzzy_eq;
    if matches!(target, ColorSpace::Lch | ColorSpace::Oklch) && fz(out[1], 0.0) {
        channels[2] = None;
    }
    // dart's lch → lab conversion marks a/b POWERLESS when the lightness is
    // missing or fuzzy-zero (LabColorSpace.convert dest=lab: `powerlessAB =
    // lightness == null || fuzzyEquals(lightness, 0)`). Oklab has NO such
    // rule (`oklch(none 20% 30deg)` keeps its computed a/b), and a same-space
    // conversion is an identity shortcut that never reaches here.
    let lch_to_lab = mc.space == ColorSpace::Lch && target == ColorSpace::Lab;
    if lch_to_lab && (channels[0].is_none() || fz(out[0], 0.0)) {
        channels[1] = None;
        channels[2] = None;
    }
    if target == ColorSpace::Hsl && fz(out[1], 0.0) {
        channels[0] = None;
    }
    if target == ColorSpace::Hwb {
        let sum = out[1] + out[2];
        if sum > 100.0 || fz(sum, 100.0) {
            channels[0] = None;
        }
    }
    ModernColor {
        space: target,
        channels,
        alpha: mc.alpha,
    }
}

/// [`convert_modern`] for a conversion that produces a user-facing RESULT
/// color: a LEGACY result zero-fills its propagated missing channels and a
/// missing alpha (dart-sass `toSpace`'s default `legacyMissing: true`), so
/// `to-space(lab-with-missing, hsl)` and the result leg of `scale`/`adjust`/
/// `change`/`mix`/`to-gamut` with a legacy space emit the plain comma form
/// (`color.scale(hsl(none 50% 50%), $space: hwb)` -> `hsl(0, 50%, 50%)`).
/// INTERMEDIATE conversions (a `$method`/`$space` working leg feeding further
/// computation, e.g. `complement`'s hue rotation or `mix`'s interpolation
/// inputs) keep using raw [`convert_modern`] so missing-ness survives the
/// round trip. Same-space conversion stays the identity in both.
pub(super) fn convert_modern_filled(mc: &ModernColor, target: ColorSpace) -> ModernColor {
    let out = convert_modern(mc, target);
    // Same-space is the identity in dart too, and keeps every missing channel.
    if mc.space == target {
        return out;
    }
    // A REAL conversion resolves a missing ALPHA to 0 whatever the target —
    // `color.is-missing(color.to-space(oklch(50% 0.1 20deg / none), oklab),
    // "alpha")` is false in dart — where the CHANNELS are only zero-filled for
    // a legacy target.
    let alpha = Some(out.alpha.unwrap_or(0.0));
    if !target.is_legacy() {
        return ModernColor { alpha, ..out };
    }
    ModernColor {
        space: target,
        channels: [
            Some(out.channels[0].unwrap_or(0.0)),
            Some(out.channels[1].unwrap_or(0.0)),
            Some(out.channels[2].unwrap_or(0.0)),
        ],
        alpha,
    }
}

/// The color's alpha the way dart's `SassColor.alpha` getter answers it: a
/// MISSING alpha reads as **0**, like any other missing channel.
///
/// [`Color::a`] cannot stand in for this. It mirrors a missing alpha as the
/// opaque `1.0` that *serialization* falls back to, so reading it makes
/// `color.alpha(hsl(240 100% 50% / none))` answer 1 where dart answers 0, and
/// carries that 1 into every arithmetic built on top of it.
pub(crate) fn stored_alpha(c: &Color) -> f64 {
    match &c.modern {
        Some(m) => m.alpha.unwrap_or(0.0),
        None => c.a,
    }
}

/// Build a [`ModernColor`] from a legacy [`Color`] (its current space is
/// `rgb`/`hsl`/`hwb` per `mc.modern`, or plain sRGB → `rgb`).
pub(crate) fn legacy_to_modern(c: &Color) -> ModernColor {
    if let Some(m) = &c.modern {
        return (**m).clone();
    }
    ModernColor {
        space: ColorSpace::Rgb,
        channels: [Some(c.r), Some(c.g), Some(c.b)],
        alpha: Some(c.a),
    }
}

/// Wrap a [`ModernColor`] in a [`Color`], deriving an in-gamut sRGB-byte
/// approximation for the legacy `r`/`g`/`b`/`a` fields (so legacy code paths
/// that read them keep working). The modern representation drives
/// serialization and channel access.
pub(super) fn make_modern(mc: ModernColor) -> Color {
    let mc = normalize_polar(mc);
    let srgb = convert_modern(&mc, ColorSpace::Rgb);
    let mut c = Color::rgb(
        z(srgb.channels[0]).clamp(0.0, 255.0),
        z(srgb.channels[1]).clamp(0.0, 255.0),
        z(srgb.channels[2]).clamp(0.0, 255.0),
        mc.alpha.unwrap_or(1.0),
    );
    c.modern = Some(Box::new(mc));
    c
}

/// dart `SassColor._normalizeHue`: `(hue % 360 + 360 + (invert ? 180 : 0))
/// % 360`. The EXACT fmod sequence matters bit-for-bit — adding 360 and
/// reducing again perturbs the last ulp vs a single euclidean remainder, and
/// sass-spec expectations carry that perturbation.
///
/// dart pattern-matches `0` and any non-finite hue BEFORE the invert shift,
/// which is not the same as shifting and reducing: a 0 hue stays 0 even when a
/// negative saturation asks for the 180° offset. `[measured]` against dart-sass
/// 1.104.1: `color.change(hsl(120, 50%, 50%), $hue: 0, $saturation: -50%)` is
/// `hsl(0, 50%, 50%)`, and `color.change(lch(50% 20 0), $chroma: -20)` keeps
/// `0deg`.
fn normalize_hue(hue: f64, invert: bool) -> f64 {
    if hue == 0.0 || !hue.is_finite() {
        return 0.0;
    }
    let shift = if invert { 180.0 } else { 0.0 };
    (hue % 360.0 + 360.0 + shift) % 360.0
}

/// Normalize a polar color's stored channels exactly like dart's
/// `SassColor.forSpaceInternal`: hsl and lch/oklch take the ABSOLUTE
/// saturation/chroma, inverting the hue by 180° when it was negative beyond
/// fuzz; every legacy/polar hue reduces through [`normalize_hue`]'s fmod
/// sequence. Other spaces are returned unchanged.
pub(super) fn normalize_polar(mut mc: ModernColor) -> ModernColor {
    // dart `fuzzyLessThan(channel1, 0)`: below zero and not `fuzzyEquals` to
    // it, with both clauses of that comparison — a saturation of -6e-12 is NOT
    // zero to dart (scaling by 1e11 rounds to -1), so it inverts the hue.
    let fuzzy_less_than_zero = |v: f64| v < 0.0 && !crate::value::fuzzy_eq(v, 0.0);
    let (hue_idx, mag_idx) = match mc.space {
        ColorSpace::Hsl => (0, Some(1)),
        ColorSpace::Hwb => (0, None),
        ColorSpace::Lch | ColorSpace::Oklch => (2, Some(1)),
        _ => return normalize_degenerate(mc),
    };
    let mut invert = false;
    if let Some(i) = mag_idx {
        if let Some(c) = mc.channels[i] {
            invert = fuzzy_less_than_zero(c);
            mc.channels[i] = Some(c.abs());
        }
    }
    if let Some(h) = mc.channels[hue_idx] {
        // No finite guard here: dart's fmod sends an infinite hue to NaN, which
        // `normalize_degenerate` then turns into 0 — the same 0 the CSS spec
        // asks for.
        mc.channels[hue_idx] = Some(normalize_hue(h, invert));
    }
    normalize_degenerate(mc)
}

/// dart-sass 1.104.0: "Colors now convert NaN and negative zero, as well as
/// infinity and negative infinity for polar-hue channels, to 0 as per the CSS
/// spec." Applied to the STORED channels, so a NaN a conversion produced (not
/// just one the call spelled out) converts too. An infinite NON-hue channel is
/// left alone: it still serializes as `calc(infinity * 1%)`.
pub(super) fn normalize_degenerate(mut mc: ModernColor) -> ModernColor {
    let hue_idx = match mc.space {
        ColorSpace::Hsl | ColorSpace::Hwb => Some(0),
        ColorSpace::Lch | ColorSpace::Oklch => Some(2),
        _ => None,
    };
    for (i, ch) in mc.channels.iter_mut().enumerate() {
        if let Some(v) = ch {
            if v.is_nan() || *v == 0.0 || (hue_idx == Some(i) && v.is_infinite()) {
                *v = 0.0;
            }
        }
    }
    // The alpha is a channel as well, and it reaches here from a COMPUTATION
    // as readily as from a call: `change`/`adjust`/`scale` write `work.alpha`
    // directly, so `color.change(oklch(50% 0.1 20deg), $alpha: -0)` is
    // `… / 0`, not `… / -0`.
    if let Some(a) = &mut mc.alpha {
        if a.is_nan() || *a == 0.0 {
            *a = 0.0;
        }
    }
    mc
}

/// The known predefined `color()` spaces and their [`ColorSpace`].
pub(super) fn predefined_space(name: &str) -> Option<ColorSpace> {
    match name {
        "srgb" => Some(ColorSpace::Srgb),
        "srgb-linear" => Some(ColorSpace::SrgbLinear),
        "display-p3" => Some(ColorSpace::DisplayP3),
        "display-p3-linear" => Some(ColorSpace::DisplayP3Linear),
        "a98-rgb" => Some(ColorSpace::A98Rgb),
        "prophoto-rgb" => Some(ColorSpace::ProphotoRgb),
        "rec2020" => Some(ColorSpace::Rec2020),
        "xyz" | "xyz-d65" => Some(ColorSpace::XyzD65),
        "xyz-d50" => Some(ColorSpace::XyzD50),
        _ => None,
    }
}

/// Parse a numeric channel value for a modern `color()`/lab-family call into a
/// canonical channel value, or `None` for a `none` channel. `pct_base` scales a
/// `%` value (e.g. 1.0 for rgb channels in 0..1, 100.0 for lab lightness).
/// Degenerate calc constants fold to infinity/NaN. The result is NOT clamped.
pub(super) fn modern_channel(v: &Value, pct_base: f64) -> Option<f64> {
    if is_none_keyword(v) {
        return None;
    }
    if let Value::Calc(node) = v {
        if let Some(c) = degenerate_const(node) {
            return Some(c);
        }
    }
    // A slash-division carries its quotient AND its unit, so `50%/2` is 25% of
    // the channel's base — not the raw 25 — and a FOLDED numeric `calc()`,
    // which only survives where the evaluator preserves calculations (inside
    // `@supports`), is a number like any other.
    match channel_unit_number(v) {
        Some(num) => {
            if num.unit() == "%" {
                // dart's `_percentageOrUnitless` is `max * value / 100`, and
                // the order is observable: `0.4 * -40 / 100` is exactly -0.16
                // where `-40 / 100 * 0.4` is -0.16000000000000003, which the
                // compressed number writer rounds -- and, rounding, drops the
                // leading zero dart keeps.
                Some(pct_base * num.value / 100.0)
            } else {
                Some(num.value)
            }
        }
        None => Some(0.0),
    }
}

/// Parse a hue channel (degrees), converting angle units. `none` → `None`.
pub(super) fn modern_hue(v: &Value) -> Option<f64> {
    if is_none_keyword(v) {
        return None;
    }
    if let Value::Calc(node) = v {
        if let Some(c) = degenerate_const(node) {
            return Some(c);
        }
    }
    // A slash-division carries its angle unit too (`1turn/4` is 90deg), as does
    // a folded numeric `calc()` preserved inside `@supports`.
    match channel_unit_number(v) {
        Some(num) => Some(match num.unit() {
            "rad" => num.value.to_degrees(),
            "grad" => num.value * 360.0 / 400.0,
            "turn" => num.value * 360.0,
            _ => num.value,
        }),
        None => Some(0.0),
    }
}

/// Parse a modern alpha channel. `none` → `None`; otherwise clamp to 0..1.
pub(super) fn modern_alpha(v: Option<&Value>) -> Option<f64> {
    match v {
        None => Some(1.0),
        Some(a) if is_none_keyword(a) => None,
        Some(a) => {
            if let Some(c) = degenerate_value(a) {
                return Some(if c.is_nan() { 0.0 } else { c.clamp(0.0, 1.0) });
            }
            match a {
                Value::Number(num) => {
                    let val = if num.unit() == "%" {
                        num.value / 100.0
                    } else {
                        num.value
                    };
                    Some(val.clamp(0.0, 1.0))
                }
                Value::Slash(num, _) => Some(num.value.clamp(0.0, 1.0)),
                _ => Some(1.0),
            }
        }
    }
}

// =====================================================================
// Modern `sass:color` module members (color.space / color.channel /
// color.to-space / color.is-legacy / color.is-missing / color.is-in-gamut /
// color.is-powerless / color.to-gamut / color.same). These are dispatched
// from the module seam under the global names `color-space`, `color-channel`,
// etc.
// =====================================================================

/// The space of a [`Color`] as a [`ColorSpace`] (`rgb` for plain legacy).
pub(super) fn color_space_of(c: &Color) -> ColorSpace {
    c.modern.as_ref().map(|m| m.space).unwrap_or(ColorSpace::Rgb)
}

/// Look up a channel name within `space`, returning its index (and the special
/// `"alpha"`/missing handling left to the caller).
pub(super) fn channel_index_in(space: ColorSpace, channel: &str) -> Option<usize> {
    space.channel_names().iter().position(|n| *n == channel)
}

/// Parse a `$space` argument into a [`ColorSpace`]. dart-sass requires an
/// *unquoted* string: a quoted one errors "Expected … to be an unquoted
/// string".
pub(crate) fn space_arg(v: &Value, pos: Pos) -> Result<ColorSpace, Error> {
    let name = match v {
        Value::Str(s) if !s.quoted => s.text.clone(),
        Value::Str(s) => {
            return Err(Error::at(
                format!("$space: Expected \"{}\" to be an unquoted string.", s.text),
                pos,
            ))
        }
        other => {
            return Err(Error::at(
                format!("$space: {} is not a string.", other.to_css(false)),
                pos,
            ))
        }
    };
    ColorSpace::from_name(&name)
        .ok_or_else(|| Error::at(format!("$space: Unknown color space \"{name}\"."), pos))
}

/// Build a [`Color`] for `mc` already in `space`, choosing whether to leave the
/// `modern` tag attached. Plain-legacy rgb (no missing channels) drops the
/// `modern` field so it serializes like a normal sRGB color.
pub(crate) fn make_modern_in(mc: ModernColor, _space: ColorSpace) -> Color {
    let mc = normalize_degenerate(mc);
    if mc.space == ColorSpace::Rgb && mc.channels.iter().all(|c| c.is_some()) && mc.alpha.is_some() {
        let r = mc.channels[0].unwrap_or(0.0);
        let g = mc.channels[1].unwrap_or(0.0);
        let b = mc.channels[2].unwrap_or(0.0);
        let a = mc.alpha.unwrap_or(1.0);
        let mut c = Color::rgb(r, g, b, a);
        // Out-of-gamut legacy rgb serializes via hsl; attach modern so the
        // serializer can apply that rule. Otherwise a computed in-gamut rgb
        // uses its CSS named-color spelling when it matches one.
        //
        // The bound is dart's `_isChannelInGamut`, fuzzily — a channel 6e-12
        // past 255 is out of gamut to dart, and a looser tolerance here decides
        // the form before the serializer's own exact rules ever run.
        // `[measured]`: `color.change(red, $red: 255.000000000006)` is
        // `hsl(0, 100%, 50%)`, not `red`.
        let in_gamut = |v: f64| {
            let fz = crate::value::fuzzy_eq;
            (v > 0.0 || fz(v, 0.0)) && (v < 255.0 || fz(v, 255.0))
        };
        if !(in_gamut(r) && in_gamut(g) && in_gamut(b)) {
            c.modern = Some(Box::new(mc));
        } else {
            c.repr = named_repr(r, g, b, a);
        }
        return c;
    }
    make_modern(mc)
}

/// The legacy hsl-space adjusters — `lighten`/`darken`, `saturate`/
/// `desaturate` and `adjust-hue` — the way dart-sass runs them: READ the
/// color's hsl channels (a missing channel reads as 0), let `f` change them,
/// rebuild an hsl color from those plain numbers, and hand it back in the
/// color's OWN space.
///
/// Keeping the space is what makes `lighten(hsl(240, 100%, 50%), 10%)` stay
/// `hsl(240, 100%, 60%)` instead of collapsing to `#3333ff`, and it keeps the
/// untouched channels bit-exact for an `hsl()` input — the trip to hsl and
/// back is the identity there, so `lighten(hsl(240, 150%, 50%), 10%)` is
/// `hsl(240, 150%, 60%)`, out of gamut and all. An `hwb()` input stays `hwb`
/// and the trip back applies the ordinary conversion rules, so a result whose
/// whiteness and blackness cover everything picks up a powerless `none` hue
/// (`lighten(hwb(240 90% 0%), 50%)` is `hwb(none 100% 0%)`). Only an
/// `rgb()`/hex/named input still collapses to sRGB, which is where it started.
///
/// Rebuilding from plain numbers is also why a MISSING channel does not
/// survive: `lighten(hsl(240 none 50%), 10%)` is `hsl(240, 0%, 60%)`, where
/// `color.adjust($lightness: 10%)` on the same color keeps the `none`.
pub(crate) fn legacy_hsl_adjust(c: &Color, f: impl FnOnce(&mut [f64; 3])) -> Color {
    let src = legacy_to_modern(c);
    let space = src.space;
    let hsl = convert_modern(&src, ColorSpace::Hsl);
    let mut ch = [z(hsl.channels[0]), z(hsl.channels[1]), z(hsl.channels[2])];
    f(&mut ch);
    // Rebuilding the hsl color normalizes it the way dart's `SassColor.hsl`
    // constructor does, BEFORE the trip back: a non-finite hue becomes 0 there
    // (so `adjust-hue(red, NaN)` is red, not a color of NaN channels), where
    // converting first would hand the rgb arithmetic a hue it has no answer
    // for.
    let adjusted = normalize_polar(ModernColor {
        space: ColorSpace::Hsl,
        channels: [Some(ch[0]), Some(ch[1]), Some(ch[2])],
        alpha: Some(z(src.alpha)),
    });
    make_modern_in(convert_modern(&adjusted, space), space)
}

/// The alpha-only legacy adjusters (`opacify`/`fade-in` and
/// `transparentize`/`fade-out`): dart rebuilds the color in its own space from
/// its own channels, so the space and every channel survive untouched
/// (`transparentize(hsl(240, 100%, 50%), 0.2)` is `hsla(240, 100%, 50%, 0.8)`)
/// and only a missing channel is filled in with 0.
///
/// `f` is handed the STORED alpha, a missing one reading as 0 like any other
/// missing channel — not the 1.0 that `Color::a` mirrors it as for
/// serialization. That is the alpha dart shifts, so
/// `opacify(hsl(240 100% 50% / none), 0.2)` is `hsla(240, 100%, 50%, 0.2)`
/// and `transparentize` of the same color stays at 0.
pub(crate) fn legacy_alpha_adjust(c: &Color, f: impl FnOnce(f64) -> f64) -> Color {
    let src = legacy_to_modern(c);
    let space = src.space;
    let mc = ModernColor {
        space,
        channels: [
            Some(z(src.channels[0])),
            Some(z(src.channels[1])),
            Some(z(src.channels[2])),
        ],
        alpha: Some(f(z(src.alpha))),
    };
    make_modern_in(mc, space)
}

/// Convert `mc` to `space`, carrying over the hue of a polar source when the
/// chroma/saturation is zero (powerless), matching dart-sass's missing-channel
/// behavior is not applied here — only the plain numeric conversion.
pub(super) fn convert_to_space(mc: &ModernColor, space: ColorSpace) -> ModernColor {
    convert_modern_filled(mc, space)
}

/// Build the [`Number`] for a channel value, applying dart-sass's per-channel
/// unit: percentage for lightness/saturation/lightness/whiteness/blackness,
/// `deg` for hue, plain otherwise. Legacy rgb red/green/blue are 0..255.
pub(super) fn channel_number(space: ColorSpace, idx: usize, raw: f64) -> Number {
    use ColorSpace::*;
    let names = space.channel_names();
    let cname = names[idx];
    // dart's channel() builds a `%` number via `value * 100 / channel.max` —
    // the round trip perturbs the last ulp on far-range values, and the spec
    // expectations carry it (a max of 100 is NOT a no-op in floating point).
    let pct = |v: f64, max: f64| Number::with_unit(v * 100.0 / max, "%");
    let deg = |v: f64| Number::with_unit(v, "deg");
    let plain = |v: f64| Number::unitless(v);
    match (space, cname) {
        (Hsl, "saturation") | (Hsl, "lightness") => pct(raw, 100.0),
        (Hwb, "whiteness") | (Hwb, "blackness") => pct(raw, 100.0),
        (Lab, "lightness") | (Lch, "lightness") => pct(raw, 100.0),
        (Oklab, "lightness") | (Oklch, "lightness") => pct(raw, 1.0),
        (_, "hue") => deg(raw),
        _ => plain(raw),
    }
}

/// Whether `mc` is within the gamut of `space`. The bounded RGB-style spaces
/// check their own channels; the legacy hsl/hwb spaces share the sRGB gamut
/// (their rgb representation must fit `[0,255]`); the unbounded perceptual/xyz
/// spaces are always in gamut.
/// Per-channel gamut bounds of a BOUNDED space's own channels (dart's
/// `LinearChannel` min/max); `None` entry = an unbounded (polar hue) channel,
/// outer `None` = an unbounded space (always in gamut).
pub(super) fn channel_bounds(space: ColorSpace) -> Option<[Option<(f64, f64)>; 3]> {
    use ColorSpace::*;
    Some(match space {
        Rgb => [Some((0.0, 255.0)); 3],
        Srgb | SrgbLinear | DisplayP3 | DisplayP3Linear | A98Rgb | ProphotoRgb | Rec2020 => {
            [Some((0.0, 1.0)); 3]
        }
        Hsl | Hwb => [None, Some((0.0, 100.0)), Some((0.0, 100.0))],
        _ => return None,
    })
}

/// dart `SassColor.isInGamut`: a bounded space checks each channel (missing
/// reads as 0) against its own bounds with fuzzy (1e-11) edges; unbounded
/// spaces and polar hue channels are always in gamut.
pub(super) fn is_in_gamut(mc: &ModernColor) -> bool {
    let Some(bounds) = channel_bounds(mc.space) else {
        return true;
    };
    let fuzzy_eq = |a: f64, b: f64| (a - b).abs() < 1e-11;
    for (bound, channel) in bounds.iter().zip(&mc.channels) {
        if let Some((min, max)) = bound {
            let v = channel.unwrap_or(0.0);
            let ok = (v < *max || fuzzy_eq(v, *max)) && (v > *min || fuzzy_eq(v, *min));
            if !ok {
                return false;
            }
        }
    }
    true
}

/// dart `ClipGamutMap`: clamp each bounded channel in the color's OWN space
/// (NaN collapses to the minimum, a missing channel stays missing, polar hue
/// channels pass through).
pub(super) fn clip_in_own_space(mc: &ModernColor) -> ModernColor {
    let Some(bounds) = channel_bounds(mc.space) else {
        return mc.clone();
    };
    let clamp1 = |v: Option<f64>, b: Option<(f64, f64)>| match (v, b) {
        (Some(v), Some((min, max))) => Some(if v.is_nan() { min } else { v.clamp(min, max) }),
        _ => v,
    };
    ModernColor {
        space: mc.space,
        channels: [
            clamp1(mc.channels[0], bounds[0]),
            clamp1(mc.channels[1], bounds[1]),
            clamp1(mc.channels[2], bounds[2]),
        ],
        alpha: mc.alpha,
    }
}

/// In-gamut check after converting into `space` (the public `is-in-gamut`
/// shape, also used by the legacy-format serialization probe).
pub(super) fn in_gamut(mc: &ModernColor, space: ColorSpace) -> bool {
    if mc.space == space {
        return is_in_gamut(mc);
    }
    is_in_gamut(&convert_modern(mc, space))
}

/// dart-sass powerless rules (with fuzzy comparison): hsl hue is powerless at
/// saturation ~0; hwb hue is powerless when whiteness+blackness >= 100;
/// lch/oklch hue is powerless at chroma ~0. (hsl saturation is never powerless.)
pub(super) fn channel_powerless(space: ColorSpace, idx: usize, conv: &ModernColor) -> bool {
    use ColorSpace::*;
    let ch = |i: usize| conv.channels[i].unwrap_or(0.0);
    let fuzzy_zero = |v: f64| v.abs() < 1e-11;
    match (space, idx) {
        (Hsl, 0) => fuzzy_zero(ch(1)),
        (Hwb, 0) => ch(1) + ch(2) >= 100.0 - 1e-11,
        (Lch, 2) | (Oklch, 2) => fuzzy_zero(ch(1)),
        _ => false,
    }
}

/// Return `mc` with any powerless channel (e.g. an hsl hue at zero saturation)
/// set to missing, so the missing-channel error serializes it as `none`.
pub(super) fn null_powerless(mc: &ModernColor, space: ColorSpace) -> ModernColor {
    let mut out = mc.clone();
    for idx in 0..3 {
        if channel_powerless(space, idx, mc) {
            out.channels[idx] = None;
        }
    }
    out
}

/// CSS Color 4 gamut mapping (`local-minde`): reduce oklch chroma via binary
/// search, clipping in the target space, until the clipped color is within a
/// just-noticeable difference (deltaEOK). Ported from the CSS Color 4 spec /
/// dart-sass.
/// dart `LocalMindeGamutMap.map`: `color` is already in the target space.
pub(super) fn gamut_map(color: &ModernColor) -> ModernColor {
    let fuzzy_eq = |a: f64, b: f64| (a - b).abs() < 1e-11;
    let origin_oklch = convert_modern(color, ColorSpace::Oklch);
    let lightness = origin_oklch.channels[0];
    let hue = origin_oklch.channels[2];
    let alpha = color.alpha;
    let l = lightness.unwrap_or(0.0);
    if l > 1.0 || fuzzy_eq(l, 1.0) {
        // A legacy color maps to white via rgb(255,255,255); a modern bounded
        // space takes its channels literally at their maxima (1,1,1).
        return if color.space.is_legacy() {
            convert_modern(
                &ModernColor {
                    space: ColorSpace::Rgb,
                    channels: [Some(255.0); 3],
                    alpha,
                },
                color.space,
            )
        } else {
            ModernColor {
                space: color.space,
                channels: [Some(1.0); 3],
                alpha,
            }
        };
    }
    if l < 0.0 || fuzzy_eq(l, 0.0) {
        return convert_modern(
            &ModernColor {
                space: ColorSpace::Rgb,
                channels: [Some(0.0); 3],
                alpha,
            },
            color.space,
        );
    }
    let mut clipped = if is_in_gamut(color) {
        color.clone()
    } else {
        clip_in_own_space(color)
    };
    if delta_eok(&clipped, color) < 0.02 {
        return clipped;
    }
    let mut max = origin_oklch.channels[1].unwrap_or(0.0);
    let mut min = 0.0;
    let mut min_in_gamut = true;
    while max - min > 0.0001 {
        let chroma = (min + max) / 2.0;
        let current = convert_modern(
            &ModernColor {
                space: ColorSpace::Oklch,
                channels: [lightness, Some(chroma), hue],
                alpha,
            },
            color.space,
        );
        if min_in_gamut && is_in_gamut(&current) {
            min = chroma;
            continue;
        }
        clipped = if is_in_gamut(&current) {
            current.clone()
        } else {
            clip_in_own_space(&current)
        };
        let e = delta_eok(&clipped, &current);
        if e < 0.02 {
            if 0.02 - e < 0.0001 {
                return clipped;
            }
            min = chroma;
            min_in_gamut = false;
        } else {
            max = chroma;
        }
    }
    clipped
}

/// The deltaEOK (Euclidean distance in oklab) between two colors. dart's
/// `math.pow(d, 2)` is the VM's `d*d` square intrinsic (identical bits to a
/// correctly-rounded pow for squares).
fn delta_eok(a: &ModernColor, b: &ModernColor) -> f64 {
    let a = convert_modern(a, ColorSpace::Oklab);
    let b = convert_modern(b, ColorSpace::Oklab);
    let dl = z(a.channels[0]) - z(b.channels[0]);
    let da = z(a.channels[1]) - z(b.channels[1]);
    let db = z(a.channels[2]) - z(b.channels[2]);
    (dl * dl + da * da + db * db).sqrt()
}

/// CSS Color 4 `color.mix($c1, $c2, $weight, $method)` interpolation in
/// `space`. `weight` is the percentage (0..100) of `c1`. Channels are
/// interpolated with premultiplied alpha (except the hue, which uses
/// `hue_method`); a channel missing in one color takes the other's value.
pub(super) fn interpolate_mix(
    c1: &Color,
    c2: &Color,
    weight: f64,
    space: ColorSpace,
    hue_method: HueMethod,
) -> Color {
    let p = weight / 100.0;
    // Powerless channels are blanked in each color's own space first, so the
    // missing carries through the conversion to the interpolation space.
    let m1 = convert_modern(&blank_powerless(legacy_to_modern(c1)), space);
    let m2 = convert_modern(&blank_powerless(legacy_to_modern(c2)), space);
    let a1 = m1.alpha;
    let a2 = m2.alpha;
    // Result alpha (missing treated as the other's, else 1).
    let ra1 = a1.unwrap_or_else(|| a2.unwrap_or(1.0));
    let ra2 = a2.unwrap_or_else(|| a1.unwrap_or(1.0));
    let result_alpha = ra1 * p + ra2 * (1.0 - p);
    let hue_idx = match space {
        ColorSpace::Hsl | ColorSpace::Hwb => Some(0),
        ColorSpace::Lch | ColorSpace::Oklch => Some(2),
        _ => None,
    };
    let mut out = [None; 3];
    for (i, slot) in out.iter_mut().enumerate() {
        let v1 = m1.channels[i];
        let v2 = m2.channels[i];
        // A channel missing in both stays missing.
        if v1.is_none() && v2.is_none() {
            *slot = None;
            continue;
        }
        // Missing in one: take the other's value (carry).
        let x1 = v1.unwrap_or_else(|| v2.unwrap_or(0.0));
        let x2 = v2.unwrap_or_else(|| v1.unwrap_or(0.0));
        if Some(i) == hue_idx {
            *slot = Some(interpolate_hue(x1, x2, p, hue_method));
        } else {
            // Premultiplied-alpha interpolation. A missing alpha counts as 1.
            let pa1 = a1.unwrap_or(1.0);
            let pa2 = a2.unwrap_or(1.0);
            let premul = x1 * pa1 * p + x2 * pa2 * (1.0 - p);
            *slot = Some(if result_alpha.abs() < 1e-12 {
                x1 * p + x2 * (1.0 - p)
            } else {
                premul / result_alpha
            });
        }
    }
    let alpha = if a1.is_none() && a2.is_none() {
        None
    } else {
        Some(result_alpha)
    };
    let mc = ModernColor {
        space,
        channels: out,
        alpha,
    };
    // The result is expressed in c1's original space (CSS Color 4 / dart-sass):
    // a legacy c1 yields a legacy result (missing channels filled), a modern c1
    // keeps its own space.
    let dest = legacy_to_modern(c1).space;
    let back = convert_modern_filled(&mc, dest);
    make_modern_in(back, dest)
}

/// Interpolate two hue angles (degrees) by `p` (fraction of `h1`) using the
/// CSS Color 4 hue interpolation method.
pub(super) fn interpolate_hue(h1: f64, h2: f64, p: f64, method: HueMethod) -> f64 {
    let mut a = h1.rem_euclid(360.0);
    let mut b = h2.rem_euclid(360.0);
    match method {
        HueMethod::Shorter => {
            let diff = b - a;
            if diff > 180.0 {
                a += 360.0;
            } else if diff < -180.0 {
                b += 360.0;
            }
        }
        HueMethod::Longer => {
            // The longer arc: take the complement of the shorter direction.
            let diff = b - a;
            if (0.0..180.0).contains(&diff) {
                b += 360.0;
            } else if (-180.0..0.0).contains(&diff) {
                a += 360.0;
            }
        }
        HueMethod::Increasing => {
            if b < a {
                b += 360.0;
            }
        }
        HueMethod::Decreasing => {
            if a < b {
                a += 360.0;
            }
        }
    }
    a * p + b * (1.0 - p)
}

/// Set a powerless channel to missing (`None`) for interpolation: the hue of
/// hsl (at zero saturation), hwb (whiteness+blackness >= 100) and lch/oklch
/// (at zero chroma) carries no information.
pub(super) fn blank_powerless(mut mc: ModernColor) -> ModernColor {
    let ch = |i: usize| mc.channels[i].unwrap_or(0.0);
    match mc.space {
        ColorSpace::Hsl if ch(1) == 0.0 => mc.channels[0] = None,
        ColorSpace::Hwb if ch(1) + ch(2) >= 100.0 => mc.channels[0] = None,
        ColorSpace::Lch | ColorSpace::Oklch if ch(1) == 0.0 => mc.channels[2] = None,
        _ => {}
    }
    mc
}

// ---- modern change / adjust / scale (with $space) -------------------

/// The scaling bounds [min, max] for a channel of `space` (used by
/// `scale-color`). `None` for the hue channel (not scalable).
pub(super) fn scale_bounds(space: ColorSpace, idx: usize) -> Option<(f64, f64)> {
    use ColorSpace::*;
    let names = space.channel_names();
    if names[idx] == "hue" {
        return None;
    }
    Some(match space {
        Rgb => (0.0, 255.0),
        Srgb | SrgbLinear | DisplayP3 | DisplayP3Linear | A98Rgb | ProphotoRgb | Rec2020 => (0.0, 1.0),
        Hsl | Hwb => (0.0, 100.0),
        Lab => {
            if idx == 0 {
                (0.0, 100.0)
            } else {
                (-125.0, 125.0)
            }
        }
        Lch => {
            if idx == 0 {
                (0.0, 100.0)
            } else {
                (0.0, 150.0)
            }
        }
        Oklab => {
            if idx == 0 {
                (0.0, 1.0)
            } else {
                (-0.4, 0.4)
            }
        }
        Oklch => {
            if idx == 0 {
                (0.0, 1.0)
            } else {
                (0.0, 0.4)
            }
        }
        XyzD65 | XyzD50 => (0.0, 1.0),
    })
}

/// Read a channel value argument for the modern modify path, in the channel's
/// canonical unit. `idx` selects whether it is the polar hue channel.
pub(super) fn modify_channel_value(space: ColorSpace, idx: usize, v: &Value) -> Option<f64> {
    if space.is_polar(idx) {
        modern_hue(v)
    } else {
        modern_channel(v, channel_pct_base(space, idx))
    }
}

impl ColorSpace {
    /// Whether the channel at `index` is a polar hue channel.
    fn is_polar(self, index: usize) -> bool {
        self.channel_names()[index] == "hue"
    }
}

/// The percentage reference (100% = ?) for a channel of `space`.
fn channel_pct_base(space: ColorSpace, idx: usize) -> f64 {
    use ColorSpace::*;
    let names = space.channel_names();
    match (space, names[idx]) {
        (Rgb, _) => 255.0,
        (Srgb | SrgbLinear | DisplayP3 | DisplayP3Linear | A98Rgb | ProphotoRgb | Rec2020, _) => 1.0,
        (Hsl | Hwb, _) => 100.0,
        (Lab, "lightness") | (Lch, "lightness") => 100.0,
        (Oklab, "lightness") | (Oklch, "lightness") => 1.0,
        (Lab, _) => 125.0,
        (Oklab, _) => 0.4,
        (Lch, "chroma") => 150.0,
        (Oklch, "chroma") => 0.4,
        (XyzD65 | XyzD50, _) => 1.0,
        _ => 1.0,
    }
}

/// Read a `scale-color` percentage factor in `[-1, 1]`. Every message names
/// the CHANNEL being scaled (`$red`, `$alpha`, …), as dart-sass does — the
/// parameter is the channel, not a generic `$amount`.
pub(super) fn scale_pct(name: &str, v: &Value, pos: Pos) -> Result<f64, Error> {
    match v {
        // A COMPOUND unit only reports its first numerator, so `%*px` must be
        // rejected explicitly rather than read as a percentage.
        Value::Number(n) if !n.has_complex_units() && n.unit() == "%" => {
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
        Value::Number(n) => Err(Error::at(
            format!("${name}: Expected {} to have unit \"%\".", n.to_css(false)),
            pos,
        )),
        other => Err(Error::at(
            format!("${name}: {} is not a number.", other.to_css(false)),
            pos,
        )),
    }
}

/// Scale `current` by `factor` (`-1..=1`) toward `bounds.1` (positive) or
/// `bounds.0` (negative). dart `_scaleChannel`: a channel already past the
/// targeted bound stays put (scaling can't pull it back into range).
pub(super) fn scale_to(current: f64, factor: f64, bounds: (f64, f64)) -> f64 {
    if factor == 0.0 {
        current
    } else if factor > 0.0 {
        if current >= bounds.1 {
            current
        } else {
            current + (bounds.1 - current) * factor
        }
    } else if current <= bounds.0 {
        current
    } else {
        current + (current - bounds.0) * factor
    }
}

/// dart names `none` among the things it wanted wherever it would have been
/// accepted — which is `change`, the only modify op that takes one.
fn none_suffix(accepts_none: bool) -> &'static str {
    if accepts_none {
        " or unquoted \"none\""
    } else {
        ""
    }
}

/// Validate a channel value's unit for the modern change/adjust path. A hue
/// requires an angle unit (or none); other channels accept `%` or no unit.
pub(super) fn validate_modify_unit(
    space: ColorSpace,
    idx: usize,
    name: &str,
    v: &Value,
    accepts_none: bool,
    pos: Pos,
) -> Result<(), Error> {
    let num = match v {
        // One arm for both spellings, as in the channel readers: a
        // slash-division's quotient is unit-checked like any number. (Nothing
        // reaches here as a `Slash` today — an argument's division has already
        // evaluated — but the two must not diverge if one ever does.)
        Value::Number(n) | Value::Slash(n, _) => n,
        // A DEGENERATE `calc()` is a channel value; a folded numeric one —
        // which only survives where the evaluator preserves calculations,
        // inside `@supports` — is not a number at all.
        Value::Calc(node) if degenerate_const(node).is_some() => return Ok(()),
        other => {
            return Err(Error::at(
                format!(
                    "${name}: {} is not a number{}.",
                    other.to_css(false),
                    none_suffix(accepts_none)
                ),
                pos,
            ))
        }
    };
    if space.is_polar(idx) {
        // Legacy hsl/hwb treat any hue unit leniently (as degrees); the modern
        // spaces require a real angle unit.
        if space.is_legacy() {
            return Ok(());
        }
        let ok = num.is_unitless() || matches!(num.unit(), "deg" | "grad" | "rad" | "turn");
        if !ok {
            return Err(Error::at(
                format!(
                    "${name}: Expected {} to have an angle unit (deg, grad, rad, turn).",
                    num.to_css(false)
                ),
                pos,
            ));
        }
    } else if space == ColorSpace::Hsl {
        // Legacy hsl `saturation`/`lightness` accept any unit: dart-sass emits a
        // deprecation warning (to stderr) for a non-`%` unit but uses the value.
    } else if space == ColorSpace::Hwb {
        // Legacy hwb `whiteness`/`blackness` strictly require `%` (note: the
        // error message has no "or no units" — unitless is also rejected).
        if num.unit() != "%" {
            return Err(Error::at(
                format!("${name}: Expected {} to have unit \"%\".", num.to_css(false)),
                pos,
            ));
        }
    } else if !num.is_unitless() && num.unit() != "%" {
        return Err(Error::at(
            format!(
                "${name}: Expected {} to have unit \"%\" or no units.",
                num.to_css(false)
            ),
            pos,
        ));
    }
    Ok(())
}

/// Clamp an `adjust-color` result channel: legacy rgb channels clamp to
/// `[0,255]`, lab/lch/oklab/oklch lightness clamps to its range, and lch/oklch
/// chroma is floored at 0. hsl/hwb percentages and the modern rgb-style spaces
/// are left unbounded (matching dart-sass).
pub(super) fn clamp_adjust_channel(space: ColorSpace, idx: usize, v: f64) -> f64 {
    use ColorSpace::*;
    let names = space.channel_names();
    match (space, names[idx]) {
        (Rgb, _) => v.clamp(0.0, 255.0),
        (Lab, "lightness") | (Lch, "lightness") => v.clamp(0.0, 100.0),
        (Oklab, "lightness") | (Oklch, "lightness") => v.clamp(0.0, 1.0),
        (Lch, "chroma") | (Oklch, "chroma") => v.max(0.0),
        // hsl saturation can exceed 100% but not go negative; dart-sass clamps
        // the lower bound only (so `adjust($c, $saturation: -100%)` desaturates
        // to grey rather than flipping the hue).
        (Hsl, "saturation") => v.max(0.0),
        _ => v,
    }
}

/// Invert each channel of `src` (already in `space`) per CSS Color 4: rgb-style
/// and lightness channels invert toward their max, lab/oklab a/b negate, hue
/// shifts 180 degrees, chroma is unchanged, and hwb swaps whiteness/blackness.
pub(super) fn invert_channels(space: ColorSpace, src: &ModernColor) -> ModernColor {
    use ColorSpace::*;
    let ch = src.channels;
    let inv_max = |v: Option<f64>, max: f64| v.map(|x| max - x);
    let negate = |v: Option<f64>| v.map(|x| -x);
    let shift_hue = |v: Option<f64>| v.map(|x| x + 180.0);
    let channels = match space {
        Rgb => [
            inv_max(ch[0], 255.0),
            inv_max(ch[1], 255.0),
            inv_max(ch[2], 255.0),
        ],
        Srgb | SrgbLinear | DisplayP3 | DisplayP3Linear | A98Rgb | ProphotoRgb | Rec2020 | XyzD65
        | XyzD50 => [inv_max(ch[0], 1.0), inv_max(ch[1], 1.0), inv_max(ch[2], 1.0)],
        Hsl => [shift_hue(ch[0]), ch[1], inv_max(ch[2], 100.0)],
        Hwb => [shift_hue(ch[0]), ch[2], ch[1]],
        Lab => [inv_max(ch[0], 100.0), negate(ch[1]), negate(ch[2])],
        Oklab => [inv_max(ch[0], 1.0), negate(ch[1]), negate(ch[2])],
        Lch => [inv_max(ch[0], 100.0), ch[1], shift_hue(ch[2])],
        Oklch => [inv_max(ch[0], 1.0), ch[1], shift_hue(ch[2])],
    };
    ModernColor {
        space,
        channels,
        alpha: src.alpha,
    }
}

/// Whether `invert` transforms the channel at `idx` of `space` using its value
/// (so a missing/powerless value is an error), as opposed to passing it through
/// unchanged (hsl saturation, lch/oklch chroma) or merely swapping it (hwb
/// whiteness/blackness).
pub(super) fn invert_modifies(space: ColorSpace, idx: usize) -> bool {
    use ColorSpace::*;
    !matches!(
        (space, idx),
        (Hsl, 1) | (Hwb, 1) | (Hwb, 2) | (Lch, 1) | (Oklch, 1)
    )
}
