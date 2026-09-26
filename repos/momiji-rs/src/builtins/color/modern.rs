use super::*;

/// The modern CSS Color 4 `sass:color` members this submodule owns by name
/// (the single source of truth, mirroring the `try_call_modern` match arms
/// below). Folded into the family's [`super::NAMES`].
pub(super) const NAMES: &[&str] = &[
    "color-space",
    "color-channel",
    "color-to-space",
    "color-is-legacy",
    "color-is-missing",
    "color-is-in-gamut",
    "color-is-powerless",
    "color-to-gamut",
    "color-same",
];

pub(super) fn try_call_modern(
    name: &str,
    pos_args: &[Value],
    named: &[(String, Value)],
    pos: Pos,
) -> Option<Result<Value, Error>> {
    Some(match name {
        "color-space" => fn_space(pos_args, named, pos),
        "color-channel" => fn_color_channel(pos_args, named, pos),
        "color-to-space" => fn_to_space(pos_args, named, pos),
        "color-is-legacy" => fn_is_legacy(pos_args, named, pos),
        "color-is-missing" => fn_is_missing(pos_args, named, pos),
        "color-is-in-gamut" => fn_is_in_gamut(pos_args, named, pos),
        "color-is-powerless" => fn_is_powerless(pos_args, named, pos),
        "color-to-gamut" => fn_to_gamut(pos_args, named, pos),
        "color-same" => fn_same(pos_args, named, pos),
        _ => return None,
    })
}

/// Read a channel-name argument. dart-sass requires it to be a *quoted*
/// string: an unquoted string (`hue`) errors "Expected … to be a quoted
/// string"; a non-string errors "… is not a string".
fn channel_name_arg(v: &Value, pos: Pos) -> Result<String, Error> {
    match v {
        Value::Str(s) if s.quoted => Ok(s.text.to_string()),
        Value::Str(s) => Err(Error::at(
            format!("$channel: Expected {} to be a quoted string.", s.text),
            pos,
        )),
        other => Err(Error::at(
            format!("$channel: {} is not a string.", other.to_css(false)),
            pos,
        )),
    }
}

fn fn_space(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color"];
    check_arity(params.len(), pos_args, named, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    Ok(Value::Str(crate::value::SassStr {
        text: color_space_of(&c).name().to_string().into(),
        quoted: false,
    }))
}

fn fn_is_legacy(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color"];
    check_arity(params.len(), pos_args, named, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    Ok(Value::Bool(color_space_of(&c).is_legacy()))
}

fn fn_to_space(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color", "space"];
    check_arity(2, pos_args, named, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    let space = space_arg(require(&params, pos_args, named, 1, pos)?, pos)?;
    let mc = legacy_to_modern(&c);
    if mc.space == space {
        return Ok(Value::Color(c));
    }
    let out = convert_to_space(&mc, space);
    Ok(Value::Color(make_modern_in(out, space)))
}

fn fn_color_channel(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color", "channel", "space"];
    check_arity(3, pos_args, named, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    let chan = channel_name_arg(require(&params, pos_args, named, 1, pos)?, pos)?;
    let mc = legacy_to_modern(&c);
    // The space to read the channel in: explicit `$space`, else the color's own.
    let space = match arg(&params, pos_args, named, 2) {
        Some(v) => space_arg(v, pos)?,
        None => mc.space,
    };
    if chan == "alpha" {
        let a = mc.alpha.unwrap_or(0.0);
        return Ok(Value::Number(Number::unitless(a)));
    }
    let target = convert_modern(&mc, space);
    let idx = channel_index_in(space, &chan).ok_or_else(|| {
        Error::at(
            // dart interpolates the color with `Value.toString()`, i.e. the
            // INSPECT serializer, not CSS output (lib/src/value.dart:439;
            // message at lib/src/functions/color.dart:699).
            format!("$channel: Color {} has no channel named {chan}.", c.inspect_css()),
            pos,
        )
    })?;
    // dart reads the stored channel verbatim: hwb normalization happens at
    // CONSTRUCTION (and on `change`), so an `adjust`/`scale` result whose
    // whiteness + blackness exceed 100 reads its raw values here.
    let raw = target.channels[idx].unwrap_or(0.0);
    Ok(Value::Number(channel_number(space, idx, raw)))
}

fn fn_is_missing(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color", "channel"];
    check_arity(params.len(), pos_args, named, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    let chan = channel_name_arg(require(&params, pos_args, named, 1, pos)?, pos)?;
    let mc = legacy_to_modern(&c);
    let missing = if chan == "alpha" {
        mc.alpha.is_none()
    } else {
        match channel_index_in(mc.space, &chan) {
            Some(idx) => mc.channels[idx].is_none(),
            None => {
                // Inspect semantics, as above: dart's message is built in
                // `SassColor.isChannelMissing` (lib/src/value/color.dart:733)
                // and interpolates `$this` through `Value.toString()`.
                return Err(Error::at(
                    format!(
                        "$channel: Color {} doesn't have a channel named \"{chan}\".",
                        c.inspect_css()
                    ),
                    pos,
                ));
            }
        }
    };
    Ok(Value::Bool(missing))
}

fn fn_is_in_gamut(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color", "space"];
    check_arity(2, pos_args, named, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    let mc = legacy_to_modern(&c);
    let space = match arg(&params, pos_args, named, 1) {
        Some(v) => space_arg(v, pos)?,
        None => mc.space,
    };
    Ok(Value::Bool(in_gamut(&mc, space)))
}

fn fn_is_powerless(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color", "channel", "space"];
    check_arity(3, pos_args, named, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    let chan = channel_name_arg(require(&params, pos_args, named, 1, pos)?, pos)?;
    let mc = legacy_to_modern(&c);
    let space = match arg(&params, pos_args, named, 2) {
        Some(v) => space_arg(v, pos)?,
        None => mc.space,
    };
    let conv = convert_modern(&mc, space);
    if chan == "alpha" {
        return Ok(Value::Bool(false));
    }
    let idx = channel_index_in(space, &chan).ok_or_else(|| {
        // Inspect semantics, as above: dart's message is built in
        // `SassColor.isChannelPowerless` (lib/src/value/color.dart:757).
        Error::at(
            format!(
                "$channel: Color {} doesn't have a channel named \"{chan}\".",
                c.inspect_css()
            ),
            pos,
        )
    })?;
    Ok(Value::Bool(channel_powerless(space, idx, &conv)))
}

fn fn_same(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color1", "color2"];
    check_arity(params.len(), pos_args, named, pos)?;
    let c1 = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    let c2 = as_color(require(&params, pos_args, named, 1, pos)?, pos)?;
    let m1 = legacy_to_modern(&c1);
    let m2 = legacy_to_modern(&c2);
    // color.same compares the *realized* colors: a missing channel counts as 0
    // and is NOT carried through the conversion (the spec converts none -> 0
    // before the xyz conversion). Fill none with 0 so convert_modern yields
    // plain numbers rather than carrying missing components into xyz.
    let fill0 = |m: &ModernColor| ModernColor {
        space: m.space,
        channels: [
            Some(z(m.channels[0])),
            Some(z(m.channels[1])),
            Some(z(m.channels[2])),
        ],
        alpha: m.alpha,
    };
    // Compare in xyz-d65 (a canonical space) with alpha.
    let x1 = convert_modern(&fill0(&m1), ColorSpace::XyzD65);
    let x2 = convert_modern(&fill0(&m2), ColorSpace::XyzD65);
    let close = |a: f64, b: f64| (a - b).abs() < 1e-7;
    let same = close(z(x1.channels[0]), z(x2.channels[0]))
        && close(z(x1.channels[1]), z(x2.channels[1]))
        && close(z(x1.channels[2]), z(x2.channels[2]))
        && close(m1.alpha.unwrap_or(1.0), m2.alpha.unwrap_or(1.0));
    Ok(Value::Bool(same))
}

fn fn_to_gamut(pos_args: &[Value], named: &[(String, Value)], pos: Pos) -> Result<Value, Error> {
    let params = ["color", "space", "method"];
    check_arity(params.len(), pos_args, named, pos)?;
    let c = as_color(require(&params, pos_args, named, 0, pos)?, pos)?;
    let mc = legacy_to_modern(&c);
    let space = match arg(&params, pos_args, named, 1) {
        Some(v) => space_arg(v, pos)?,
        None => mc.space,
    };
    // `$method` is required (forwards-compatibility with the CSS spec).
    let method = match arg(&params, pos_args, named, 2) {
        Some(v) => v,
        None => {
            return Err(Error::at(
                "$method: color.to-gamut() requires a $method argument for \
                 forwards-compatibility with changes in the CSS spec. Suggestion:\n\n\
                 $method: local-minde"
                    .to_string(),
                pos,
            ))
        }
    };
    let clip = match method {
        Value::Str(s) if !s.quoted && s.text.eq_ignore_ascii_case("clip") => true,
        Value::Str(s) if !s.quoted && s.text.eq_ignore_ascii_case("local-minde") => false,
        Value::Str(s) if s.quoted => {
            return Err(Error::at(
                format!("$method: Expected \"{}\" to be an unquoted string.", s.text),
                pos,
            ))
        }
        other => {
            return Err(Error::at(
                format!(
                    "$method: {} must be either clip or local-minde.",
                    other.to_css(false)
                ),
                pos,
            ))
        }
    };
    // dart returns the color untouched when the target space is unbounded.
    if channel_bounds(space).is_none() {
        return Ok(Value::Color(c));
    }
    // dart ALWAYS round-trips: `toSpace(space)` (keeping missing channels) →
    // map only when out of gamut → `toSpace(color.space, legacyMissing:
    // false)` (zero-fills legacy missing on the way back). Even an in-gamut
    // color picks up the round-trip conversion (powerless-hue → none etc).
    let work = convert_modern(&mc, space);
    let mapped = if is_in_gamut(&work) {
        work
    } else if clip {
        clip_in_own_space(&work)
    } else {
        gamut_map(&work)
    };
    let back = convert_modern_filled(&mapped, mc.space);
    Ok(Value::Color(make_modern_in(back, mc.space)))
}

/// The kind of modify operation for the modern change/adjust/scale path.
#[derive(Clone, Copy)]
pub(crate) enum ModifyOp {
    Change,
    Adjust,
    Scale,
}

/// The modern `color.change`/`adjust`/`scale` with an explicit `$space`:
/// convert the color to `space`, apply the per-channel operation, convert back
/// to the color's original space.
pub(crate) fn modify_in_space(
    c: &Color,
    space: ColorSpace,
    chans: &[(String, &Value)],
    op: ModifyOp,
    pos: Pos,
) -> Result<Value, Error> {
    modify_in_space_full(c, space, chans, op, false, true, pos)
}

/// As [`modify_in_space`], but with control over whether a *powerless* channel
/// (e.g. an hsl hue at zero saturation) counts as missing. The explicit-`$space`
/// path treats powerless channels as missing (erroring on `adjust`/`scale`); the
/// legacy keyword path operates on the color's stored channels and does not.
pub(crate) fn modify_in_space_opt(
    c: &Color,
    space: ColorSpace,
    chans: &[(String, &Value)],
    op: ModifyOp,
    powerless_check: bool,
    pos: Pos,
) -> Result<Value, Error> {
    modify_in_space_full(c, space, chans, op, powerless_check, false, pos)
}

/// The shared `change`/`adjust`/`scale` core. `legacy_format` selects how the
/// result is serialized: the legacy-keyword path (no `$space`) keeps the
/// original color's format when the result lands in the sRGB gamut, but falls
/// back to the working space (keeping its canonical channels) when it doesn't —
/// so e.g. `adjust(red, $lightness: 100%)` stays `hsl(0, 100%, 150%)` instead of
/// the negative-saturation rgb round-trip. The explicit-`$space`/non-legacy path
/// always converts back to the color's original space.
#[allow(clippy::too_many_arguments)]
pub(crate) fn modify_in_space_full(
    c: &Color,
    space: ColorSpace,
    chans: &[(String, &Value)],
    op: ModifyOp,
    powerless_check: bool,
    legacy_format: bool,
    pos: Pos,
) -> Result<Value, Error> {
    let orig = legacy_to_modern(c);
    let mut work = convert_modern(&orig, space);
    // A missing channel INTRODUCED by the conversion (a powerless hue from an
    // achromatic source, e.g. `black` -> hsl) is filled with 0 so modifying it
    // works (dart's working-space conversion fills legacy missing channels);
    // an AUTHORED missing channel (analogous to a source `none`) stays
    // missing, so `adjust` still errors on it and `change` still sets it.
    if orig.space != space {
        let missing_in_src = |cat: ChannelCategory| {
            (0..3).any(|i| orig.channels[i].is_none() && channel_category(orig.space, i) == Some(cat))
        };
        for i in 0..3 {
            if work.channels[i].is_none() {
                let authored = channel_category(space, i).is_some_and(&missing_in_src);
                if !authored {
                    work.channels[i] = Some(0.0);
                }
            }
        }
    }
    // `adjust`/`scale` combine each amount with the channel's current value, so
    // a missing (`none`) channel is unsupported (dart-sass errors rather than
    // guessing). `change` *sets* the channel, so a missing channel is fine. The
    // error serializes the source color in the working space.
    let combining = matches!(op, ModifyOp::Adjust | ModifyOp::Scale);
    // A channel only becomes powerless-as-missing through a *conversion* (an
    // achromatic source whose hue collapses); a color already in the working
    // space keeps its explicit (if powerless) channels.
    let powerless_active = powerless_check && orig.space != space;
    // For the error message, such a powerless channel is serialized as `none`.
    let orig_work = work.clone();
    let missing_channel_error = |name: &str| {
        let color = if powerless_active {
            make_modern(null_powerless(&orig_work, space))
        } else {
            make_modern(orig_work.clone())
        };
        missing_channel_err(name, &Value::Color(color), pos)
    };
    let mut alpha_given = false;
    for (name, v) in chans {
        if name == "alpha" {
            if combining && orig_work.alpha.is_none() {
                return Err(missing_channel_error(name));
            }
            work.alpha = apply_alpha(work.alpha.unwrap_or(1.0), v, op, pos)?;
            alpha_given = true;
            continue;
        }
        let idx = channel_index_in(space, name).ok_or_else(|| {
            Error::at(
                format!(
                    "${name}: Color space {} doesn't have a channel with this name.",
                    space.name()
                ),
                pos,
            )
        })?;
        // Validate the channel value's unit (skipped for a scale `%` and for a
        // `none` change keyword, handled below).
        if !matches!(op, ModifyOp::Scale) && !is_none_keyword(v) {
            validate_modify_unit(space, idx, name, v, matches!(op, ModifyOp::Change), pos)?;
        }
        // `adjust`/`scale` combine each amount with the channel's current value,
        // so a missing (`none`) — or, on a conversion's powerless — channel of
        // the source color is unsupported (checked against the original, like
        // dart-sass).
        let powerless = powerless_active && channel_powerless(space, idx, &orig_work);
        if combining && (orig_work.channels[idx].is_none() || powerless) {
            return Err(missing_channel_error(name));
        }
        match op {
            ModifyOp::Change => {
                if is_none_keyword(v) {
                    work.channels[idx] = None;
                } else {
                    work.channels[idx] = modify_channel_value(space, idx, v);
                }
            }
            ModifyOp::Adjust => {
                let amt = modify_channel_value(space, idx, v).unwrap_or(0.0);
                let cur = work.channels[idx].unwrap_or(0.0);
                work.channels[idx] = Some(clamp_adjust_channel(space, idx, cur + amt));
            }
            ModifyOp::Scale => {
                let bounds = scale_bounds(space, idx)
                    .ok_or_else(|| Error::at(format!("${name}: Channel isn't scalable."), pos))?;
                let factor = scale_pct(name, v, pos)?;
                let cur = work.channels[idx].unwrap_or(0.0);
                work.channels[idx] = Some(scale_to(cur, factor, bounds));
            }
        }
    }
    // `change` rebuilds through the hwb constructor in dart, which normalizes
    // a whiteness + blackness sum past 100; `adjust`/`scale` keep raw values.
    if matches!(op, ModifyOp::Change) && space == ColorSpace::Hwb {
        if let (Some(wv), Some(bv)) = (work.channels[1], work.channels[2]) {
            if wv + bv > 100.0 {
                let t = wv + bv;
                work.channels[1] = Some(wv / t * 100.0);
                work.channels[2] = Some(bv / t * 100.0);
            }
        }
    }
    // dart rebuilds a `change` result with `alpha ?? color.alpha`, and that
    // getter answers 0 for a missing alpha — so `change` hands back a CONCRETE
    // alpha even when it was missing and even when no channel was named
    // (`color.change(hsl(240 100% 50% / none), $lightness: 60%)` is
    // `hsla(240, 100%, 60%, 0)`). Only an explicit `$alpha: none` keeps it
    // missing. `adjust`/`scale` errored on a missing alpha long before here.
    if matches!(op, ModifyOp::Change) && !alpha_given {
        work.alpha = Some(work.alpha.unwrap_or(0.0));
    }
    // dart-sass builds the modified color in the WORKING space -- through
    // `SassColor.forSpaceInternal` -- and only then converts it back, so the
    // whole of 1.104.0's channel normalization applies to the new channel
    // VALUES. `change(red, $hue: NaN)` is `hsl(0, 100%, 50%)`, i.e. red again,
    // not the black an unnormalized NaN hue would convert to; and a polar hue
    // is reduced into `[0, 360)` BEFORE the conversion reads it, which only a
    // conversion can observe: `(390 % 360) / 360` is exactly `1/12` while
    // `(390 / 360) % 1` is an ulp short, and that ulp is the difference between
    // `color.complement(rgba(10, 20, 30, 0.4))` writing `rgba(30, 20, 10, 0.4)`
    // and writing a percentage triple.
    let work = normalize_polar(work);
    // The legacy-keyword path keeps the original format when the result is in
    // the sRGB gamut, otherwise serializes in the (legacy) working space.
    let dest = if legacy_format && !in_gamut(&work, ColorSpace::Rgb) {
        space
    } else {
        orig.space
    };
    // Result leg: a legacy destination fills missing channels.
    let back = convert_modern_filled(&work, dest);
    Ok(Value::Color(make_modern_in(back, dest)))
}

/// The "modifying a missing channel" error dart-sass raises when `adjust`/
/// `scale` is applied to a `none` channel. `color` is the source color
/// serialized in the working space.
pub(crate) fn missing_channel_err(name: &str, color: &Value, pos: Pos) -> Error {
    Error::at(
        format!(
            "${name}: Because the CSS working group is still deciding on the best \
             behavior, Sass doesn't currently support modifying missing channels \
             (color: {}).",
            color.to_css(false)
        ),
        pos,
    )
}

/// Apply a change/adjust/scale to the alpha channel. Returns `None` for a
/// `change` to `none`.
fn apply_alpha(cur: f64, v: &Value, op: ModifyOp, pos: Pos) -> Result<Option<f64>, Error> {
    Ok(match op {
        ModifyOp::Change => {
            if is_none_keyword(v) {
                return Ok(None);
            }
            // `change` validates the alpha is within [0,1] (or [0%,100%]). A
            // non-`%` unit is used as a raw value (within [0,1]); the bounds in
            // the error message carry that unit (e.g. `0px and 1px`).
            match v {
                // One arm for both spellings, as in `alpha_value`: a
                // slash-division's quotient is validated like any number. (A
                // named `$alpha:` argument has already evaluated to a number,
                // so nothing reaches here as a `Slash` today.)
                Value::Number(n) | Value::Slash(n, _) => {
                    // A COMPOUND unit only reports its first numerator, so it
                    // is not the percentage it starts with: `50%/2px` is a
                    // `%/px` value bounded at 1, not a 25% alpha.
                    let pct = !n.has_complex_units() && n.unit() == "%";
                    let max_disp = if pct { 100.0 } else { 1.0 };
                    if n.value.is_nan() || n.value < 0.0 || n.value > max_disp {
                        let (b0, b1) = if pct {
                            ("0%".to_string(), "100%".to_string())
                        } else {
                            let u = n.unit_string();
                            (format!("0{u}"), format!("1{u}"))
                        };
                        return Err(Error::at(
                            format!("$alpha: Expected {} to be within {b0} and {b1}.", n.to_css(false)),
                            pos,
                        ));
                    }
                    Some(if pct { n.value / 100.0 } else { n.value })
                }
                other => {
                    return Err(Error::at(
                        format!(
                            "$alpha: {} is not a number or unquoted \"none\".",
                            other.to_css(false)
                        ),
                        pos,
                    ))
                }
            }
        }
        ModifyOp::Adjust => {
            // Alpha is natively unitless: dart-sass strips any unit (warning to
            // stderr for `%`/other units) and uses the raw number directly. A
            // non-number amount (including `none`) is an error.
            let amt = match v {
                Value::Number(n) => n.value,
                Value::Slash(n, _) => n.value,
                other => {
                    return Err(Error::at(
                        format!("$alpha: {} is not a number.", other.to_css(false)),
                        pos,
                    ))
                }
            };
            Some((cur + amt).clamp(0.0, 1.0))
        }
        ModifyOp::Scale => {
            let factor = scale_pct("alpha", v, pos)?;
            Some(scale_to(cur, factor, (0.0, 1.0)))
        }
    })
}

/// CSS Color 4 `color.invert($color, $weight, $space)`: invert each channel in
/// `space` (mixing toward the original by `1 - weight`), then convert back to
/// the color's original space.
pub(crate) fn invert_in_space(
    c: &Color,
    space: ColorSpace,
    weight: f64,
    powerless_check: bool,
    pos: Pos,
) -> Result<Color, Error> {
    let orig = legacy_to_modern(c);
    let dest = orig.space;
    let src = convert_modern(&orig, space);
    // A channel only becomes powerless-as-missing through a *conversion*.
    let powerless_active = powerless_check && orig.space != space;
    // Inverting transforms each *modified* channel using its current value, so a
    // missing (`none`) — or, after a conversion, powerless — channel is
    // unsupported. Pass-through channels (e.g. hsl saturation, lch chroma, the
    // hwb whiteness/blackness swap) are exempt. Report the first offending
    // channel in storage order, like dart-sass.
    for idx in 0..3 {
        if !invert_modifies(space, idx) {
            continue;
        }
        let powerless = powerless_active && channel_powerless(space, idx, &src);
        if src.channels[idx].is_none() || powerless {
            let name = space.channel_names()[idx];
            let color = if powerless_active {
                make_modern(null_powerless(&src, space))
            } else {
                make_modern(src.clone())
            };
            return Err(missing_channel_err(name, &Value::Color(color), pos));
        }
    }
    let inverted = invert_channels(space, &src);
    // A full-weight invert IS the inverted color (no mixing) — mixing would
    // resurrect a missing channel from the original via the interpolation
    // missing-takes-other rule.
    if (weight - 1.0).abs() < 1e-11 {
        let mut back = convert_modern_filled(&inverted, dest);
        // Like `change` and `grayscale`, the rebuilt color carries a concrete
        // alpha even when no conversion resolved it:
        // `invert(oklch(50% 0.1 20deg / none), $space: oklch)` is `/ 0`.
        back.alpha = Some(back.alpha.unwrap_or(0.0));
        return Ok(make_modern_in(back, dest));
    }
    // Mix the inverted color toward the original by `1 - weight` (per channel).
    let mix = |a: Option<f64>, b: Option<f64>, hue: bool| -> Option<f64> {
        match (a, b) {
            (Some(x), Some(y)) => {
                if hue {
                    Some(interpolate_hue(x, y, weight, HueMethod::Shorter))
                } else {
                    Some(x * weight + y * (1.0 - weight))
                }
            }
            _ => a.or(b),
        }
    };
    let hue_idx = match space {
        ColorSpace::Hsl | ColorSpace::Hwb => Some(0),
        ColorSpace::Lch | ColorSpace::Oklch => Some(2),
        _ => None,
    };
    let channels = [
        mix(inverted.channels[0], src.channels[0], hue_idx == Some(0)),
        mix(inverted.channels[1], src.channels[1], hue_idx == Some(1)),
        mix(inverted.channels[2], src.channels[2], hue_idx == Some(2)),
    ];
    let mc = ModernColor {
        space,
        channels,
        alpha: src.alpha,
    };
    // Result leg: a legacy destination fills missing channels (incl. a hue
    // the working-space round trip made powerless).
    let back = convert_modern_filled(&mc, dest);
    Ok(make_modern_in(back, dest))
}

/// `color.grayscale` for a non-legacy color: set the oklch chroma to 0 (a
/// perceptual gray), then convert back to the color's own space.
pub(crate) fn grayscale_modern(c: &Color) -> Color {
    let orig = legacy_to_modern(c);
    let dest = orig.space;
    let mut oklch = convert_modern(&orig, ColorSpace::Oklch);
    oklch.channels[1] = Some(0.0);
    let mut back = convert_modern(&oklch, dest);
    // Like `change`, the rebuilt color carries a concrete alpha:
    // `grayscale(hsl(240 100% 50% / none))` is `hsla(240, 0%, 50%, 0)`.
    back.alpha = Some(back.alpha.unwrap_or(0.0));
    make_modern_in(back, dest)
}
