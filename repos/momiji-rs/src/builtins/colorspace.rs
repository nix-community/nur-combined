//! dart-sass's exact color-space conversion engine.
//!
//! A bit-faithful port of `ColorSpace.convert`/`convertLinear` and the
//! per-space `convert` overrides from dart-sass (extracted from the shipped
//! JS bundle): conversions go through ONE precomputed transformation matrix
//! between linear spaces — not an XYZ hub — and every `Math.pow` call maps to
//! the glibc/musl `pow` port in [`crate::musl_math`]. Formula shapes, branch
//! constants, and operation order are copied exactly; this is what makes the
//! converted channel values byte-identical to the sass-spec expectations.

// Constants are dart's exact literals (e.g. its written-out pi); clippy's
// suggestions to use std consts would be no-ops but obscure the provenance.
#![allow(clippy::approx_constant, clippy::excessive_precision)]

use crate::musl_math::pow;
use crate::value::ColorSpace;

#[allow(clippy::unreadable_literal)]
mod matrices {
    include!("colorspace_matrices.rs");
}
use matrices::*;

/// The nodes of dart's transformation-matrix graph: the linear form of each
/// RGB family plus the three hub spaces. `ColorSpace`s sharing a node differ
/// only in their transfer functions (`Srgb`/`Rgb`/`SrgbLinear` are all
/// `LinSrgb`).
#[derive(Clone, Copy, PartialEq, Eq)]
enum Lin {
    Srgb,
    DisplayP3,
    A98,
    Prophoto,
    Rec2020,
    XyzD65,
    XyzD50,
    Lms,
}

fn matrix(src: Lin, dst: Lin) -> &'static [f64; 9] {
    use Lin::*;
    match (src, dst) {
        (Srgb, DisplayP3) => &LINEAR_SRGB_TO_LINEAR_DISPLAY_P3,
        (Srgb, A98) => &LINEAR_SRGB_TO_LINEAR_A98_RGB,
        (Srgb, Prophoto) => &LINEAR_SRGB_TO_LINEAR_PROPHOTO_RGB,
        (Srgb, Rec2020) => &LINEAR_SRGB_TO_LINEAR_REC2020,
        (Srgb, XyzD65) => &LINEAR_SRGB_TO_XYZ_D65,
        (Srgb, XyzD50) => &LINEAR_SRGB_TO_XYZ_D50,
        (Srgb, Lms) => &LINEAR_SRGB_TO_LMS,
        (DisplayP3, Srgb) => &LINEAR_DISPLAY_P3_TO_LINEAR_SRGB,
        (DisplayP3, A98) => &LINEAR_DISPLAY_P3_TO_LINEAR_A98_RGB,
        (DisplayP3, Prophoto) => &LINEAR_DISPLAY_P3_TO_LINEAR_PROPHOTO_RGB,
        (DisplayP3, Rec2020) => &LINEAR_DISPLAY_P3_TO_LINEAR_REC2020,
        (DisplayP3, XyzD65) => &LINEAR_DISPLAY_P3_TO_XYZ_D65,
        (DisplayP3, XyzD50) => &LINEAR_DISPLAY_P3_TO_XYZ_D50,
        (DisplayP3, Lms) => &LINEAR_DISPLAY_P3_TO_LMS,
        (A98, Srgb) => &LINEAR_A98_RGB_TO_LINEAR_SRGB,
        (A98, DisplayP3) => &LINEAR_A98_RGB_TO_LINEAR_DISPLAY_P3,
        (A98, Prophoto) => &LINEAR_A98_RGB_TO_LINEAR_PROPHOTO_RGB,
        (A98, Rec2020) => &LINEAR_A98_RGB_TO_LINEAR_REC2020,
        (A98, XyzD65) => &LINEAR_A98_RGB_TO_XYZ_D65,
        (A98, XyzD50) => &LINEAR_A98_RGB_TO_XYZ_D50,
        (A98, Lms) => &LINEAR_A98_RGB_TO_LMS,
        (Prophoto, Srgb) => &LINEAR_PROPHOTO_RGB_TO_LINEAR_SRGB,
        (Prophoto, DisplayP3) => &LINEAR_PROPHOTO_RGB_TO_LINEAR_DISPLAY_P3,
        (Prophoto, A98) => &LINEAR_PROPHOTO_RGB_TO_LINEAR_A98_RGB,
        (Prophoto, Rec2020) => &LINEAR_PROPHOTO_RGB_TO_LINEAR_REC2020,
        (Prophoto, XyzD65) => &LINEAR_PROPHOTO_RGB_TO_XYZ_D65,
        (Prophoto, XyzD50) => &LINEAR_PROPHOTO_RGB_TO_XYZ_D50,
        (Prophoto, Lms) => &LINEAR_PROPHOTO_RGB_TO_LMS,
        (Rec2020, Srgb) => &LINEAR_REC2020_TO_LINEAR_SRGB,
        (Rec2020, DisplayP3) => &LINEAR_REC2020_TO_LINEAR_DISPLAY_P3,
        (Rec2020, A98) => &LINEAR_REC2020_TO_LINEAR_A98_RGB,
        (Rec2020, Prophoto) => &LINEAR_REC2020_TO_LINEAR_PROPHOTO_RGB,
        (Rec2020, XyzD65) => &LINEAR_REC2020_TO_XYZ_D65,
        (Rec2020, XyzD50) => &LINEAR_REC2020_TO_XYZ_D50,
        (Rec2020, Lms) => &LINEAR_REC2020_TO_LMS,
        (XyzD65, Srgb) => &XYZ_D65_TO_LINEAR_SRGB,
        (XyzD65, DisplayP3) => &XYZ_D65_TO_LINEAR_DISPLAY_P3,
        (XyzD65, A98) => &XYZ_D65_TO_LINEAR_A98_RGB,
        (XyzD65, Prophoto) => &XYZ_D65_TO_LINEAR_PROPHOTO_RGB,
        (XyzD65, Rec2020) => &XYZ_D65_TO_LINEAR_REC2020,
        (XyzD65, XyzD50) => &XYZ_D65_TO_XYZ_D50,
        (XyzD65, Lms) => &XYZ_D65_TO_LMS,
        (XyzD50, Srgb) => &XYZ_D50_TO_LINEAR_SRGB,
        (XyzD50, DisplayP3) => &XYZ_D50_TO_LINEAR_DISPLAY_P3,
        (XyzD50, A98) => &XYZ_D50_TO_LINEAR_A98_RGB,
        (XyzD50, Prophoto) => &XYZ_D50_TO_LINEAR_PROPHOTO_RGB,
        (XyzD50, Rec2020) => &XYZ_D50_TO_LINEAR_REC2020,
        (XyzD50, XyzD65) => &XYZ_D50_TO_XYZ_D65,
        (XyzD50, Lms) => &XYZ_D50_TO_LMS,
        (Lms, Srgb) => &LMS_TO_LINEAR_SRGB,
        (Lms, DisplayP3) => &LMS_TO_LINEAR_DISPLAY_P3,
        (Lms, A98) => &LMS_TO_LINEAR_A98_RGB,
        (Lms, Prophoto) => &LMS_TO_LINEAR_PROPHOTO_RGB,
        (Lms, Rec2020) => &LMS_TO_LINEAR_REC2020,
        (Lms, XyzD65) => &LMS_TO_XYZ_D65,
        (Lms, XyzD50) => &LMS_TO_XYZ_D50,
        // Same node: no matrix is applied (callers short-circuit).
        _ => unreachable!("no transformation matrix for identical linear nodes"),
    }
}

// ---- transfer functions (dart's exact constants) ---------------------

fn srgb_to_linear(c: f64) -> f64 {
    let abs = c.abs();
    if abs <= 0.04045 {
        c / 12.92
    } else {
        c.signum() * pow((abs + 0.055) / 1.055, 2.4)
    }
}

fn srgb_from_linear(c: f64) -> f64 {
    let abs = c.abs();
    if abs <= 0.0031308 {
        c * 12.92
    } else {
        c.signum() * (1.055 * pow(abs, 0.4166666666666667) - 0.055)
    }
}

fn a98_to_linear(c: f64) -> f64 {
    c.signum() * pow(c.abs(), 2.19921875)
}

fn a98_from_linear(c: f64) -> f64 {
    c.signum() * pow(c.abs(), 0.4547069271758437)
}

fn prophoto_to_linear(c: f64) -> f64 {
    let abs = c.abs();
    if abs <= 0.03125 {
        c / 16.0
    } else {
        c.signum() * pow(abs, 1.8)
    }
}

fn prophoto_from_linear(c: f64) -> f64 {
    let abs = c.abs();
    if abs >= 0.001953125 {
        c.signum() * pow(abs, 0.5555555555555556)
    } else {
        16.0 * c
    }
}

// dart-sass 1.102.0 switched rec2020 from the BT.2020 piecewise curve to the
// pure 2.4 gamma of the latest CSS Color 4 draft (rec2020.dart).
fn rec2020_to_linear(c: f64) -> f64 {
    c.signum() * pow(c.abs(), 2.4)
}

fn rec2020_from_linear(c: f64) -> f64 {
    c.signum() * pow(c.abs(), 1.0 / 2.4)
}

/// A space's (linear node, toLinear, fromLinear) triple.
type LinTransfer = (Lin, fn(f64) -> f64, fn(f64) -> f64);

/// The linear node and transfer functions of a matrix-graph color space.
/// `Rgb` participates with srgb transfers over 0..1 channels (the 0..255
/// scaling is applied at the [`convert`] boundary).
fn lin_of(space: ColorSpace) -> LinTransfer {
    fn id(c: f64) -> f64 {
        c
    }
    match space {
        ColorSpace::Rgb | ColorSpace::Srgb | ColorSpace::Hsl | ColorSpace::Hwb => {
            (Lin::Srgb, srgb_to_linear, srgb_from_linear)
        }
        ColorSpace::SrgbLinear => (Lin::Srgb, id, id),
        ColorSpace::DisplayP3 => (Lin::DisplayP3, srgb_to_linear, srgb_from_linear),
        ColorSpace::DisplayP3Linear => (Lin::DisplayP3, id, id),
        ColorSpace::A98Rgb => (Lin::A98, a98_to_linear, a98_from_linear),
        ColorSpace::ProphotoRgb => (Lin::Prophoto, prophoto_to_linear, prophoto_from_linear),
        ColorSpace::Rec2020 => (Lin::Rec2020, rec2020_to_linear, rec2020_from_linear),
        ColorSpace::XyzD65 => (Lin::XyzD65, id, id),
        ColorSpace::XyzD50 => (Lin::XyzD50, id, id),
        ColorSpace::Lab | ColorSpace::Lch | ColorSpace::Oklab | ColorSpace::Oklch => {
            unreachable!("lab-family spaces are handled before the matrix graph")
        }
    }
}

// ---- hsl / hwb (dart `HslColorSpace.convert` / `HwbColorSpace.convert`) --

/// JS `Math.max` (NaN-propagating, unlike Rust's `f64::max` which ignores
/// NaN) — the comparisons in the conversion code must see dart's values.
fn js_max(a: f64, b: f64) -> f64 {
    if a.is_nan() || b.is_nan() {
        f64::NAN
    } else {
        a.max(b)
    }
}

/// JS `Math.min` (NaN-propagating).
fn js_min(a: f64, b: f64) -> f64 {
    if a.is_nan() || b.is_nan() {
        f64::NAN
    } else {
        a.min(b)
    }
}

/// dart `hueToRgb(m1, m2, hue)` — the CSS2 algorithm.
fn hue_to_rgb(m1: f64, m2: f64, mut hue: f64) -> f64 {
    if hue < 0.0 {
        hue += 1.0;
    }
    if hue > 1.0 {
        hue -= 1.0;
    }
    if hue < 0.16666666666666666 {
        m1 + (m2 - m1) * hue * 6.0
    } else if hue < 0.5 {
        m2
    } else if hue < 0.6666666666666666 {
        m1 + (m2 - m1) * (0.6666666666666666 - hue) * 6.0
    } else {
        m1
    }
}

/// hsl [hue-deg, sat-%, light-%] -> srgb [0..1].
pub(crate) fn hsl_to_srgb(hsl: [f64; 3]) -> [f64; 3] {
    let scaled_hue = (hsl[0] / 360.0).rem_euclid(1.0);
    let scaled_saturation = hsl[1] / 100.0;
    let scaled_lightness = hsl[2] / 100.0;
    let m2 = if scaled_lightness <= 0.5 {
        scaled_lightness * (scaled_saturation + 1.0)
    } else {
        scaled_lightness + scaled_saturation - scaled_lightness * scaled_saturation
    };
    let m1 = scaled_lightness * 2.0 - m2;
    [
        hue_to_rgb(m1, m2, scaled_hue + 0.3333333333333333),
        hue_to_rgb(m1, m2, scaled_hue),
        hue_to_rgb(m1, m2, scaled_hue - 0.3333333333333333),
    ]
}

/// hwb [hue-deg, white-%, black-%] -> srgb [0..1].
pub(crate) fn hwb_to_srgb(hwb: [f64; 3]) -> [f64; 3] {
    let scaled_hue = hwb[0].rem_euclid(360.0) / 360.0;
    let mut scaled_whiteness = hwb[1] / 100.0;
    let mut scaled_blackness = hwb[2] / 100.0;
    let sum = scaled_whiteness + scaled_blackness;
    if sum > 1.0 {
        scaled_whiteness /= sum;
        scaled_blackness /= sum;
    }
    let factor = 1.0 - scaled_whiteness - scaled_blackness;
    let to_rgb = |hue: f64| hue_to_rgb(0.0, 1.0, hue) * factor + scaled_whiteness;
    [
        to_rgb(scaled_hue + 0.3333333333333333),
        to_rgb(scaled_hue),
        to_rgb(scaled_hue - 0.3333333333333333),
    ]
}

/// srgb [0..1] -> hsl [hue-deg, sat-%, light-%] (dart `SrgbColorSpace.convert`
/// for an hsl destination, including the negative-saturation normalization
/// out-of-gamut channels produce).
pub(crate) fn srgb_to_hsl(rgb: [f64; 3]) -> [f64; 3] {
    let (red, green, blue) = (rgb[0], rgb[1], rgb[2]);
    let max = js_max(js_max(red, green), blue);
    let min = js_min(js_min(red, green), blue);
    let delta = max - min;
    let mut hue = if max == min {
        0.0
    } else if max == red {
        60.0 * (green - blue) / delta + 360.0
    } else if max == green {
        60.0 * (blue - red) / delta + 120.0
    } else {
        60.0 * (red - green) / delta + 240.0
    };
    let lightness = (min + max) / 2.0;
    let mut saturation = if lightness == 0.0 || lightness == 1.0 {
        0.0
    } else {
        100.0 * (max - lightness) / lightness.min(1.0 - lightness)
    };
    if saturation < 0.0 {
        hue += 180.0;
        saturation = saturation.abs();
    }
    [hue.rem_euclid(360.0), saturation, lightness * 100.0]
}

/// srgb [0..1] -> hwb [hue-deg, white-%, black-%].
pub(super) fn srgb_to_hwb(rgb: [f64; 3]) -> [f64; 3] {
    let (red, green, blue) = (rgb[0], rgb[1], rgb[2]);
    let max = js_max(js_max(red, green), blue);
    let min = js_min(js_min(red, green), blue);
    let delta = max - min;
    let hue = if max == min {
        0.0
    } else if max == red {
        60.0 * (green - blue) / delta + 360.0
    } else if max == green {
        60.0 * (blue - red) / delta + 120.0
    } else {
        60.0 * (red - green) / delta + 240.0
    };
    [hue.rem_euclid(360.0), min * 100.0, 100.0 - max * 100.0]
}

// ---- lab / lch (dart `LabColorSpace` / `XyzD50ColorSpace`) ---------------

/// dart's `math.pow(x, 3)` compiles to `x*x*x` on the VM (small-integer
/// exponents are intrinsics, NOT the libm pow) — using the real pow here
/// drifts a ulp from the dart-VM oracle on far-range inputs.
#[inline]
fn cube(t: f64) -> f64 {
    t * t * t
}

/// dart's `math.pow(x, 2)` intrinsic (see [`cube`]).
#[inline]
fn square(t: f64) -> f64 {
    t * t
}

const LAB_EPSILON: f64 = 0.008856451679035631; // 216/24389
const LAB_KAPPA: f64 = 903.2962962962963; // 24389/27
const D50_X: f64 = 0.9642956764295677;
const D50_Z: f64 = 0.8251046025104602;

/// dart `LabColorSpace._convertFToXorZ`.
fn lab_f_to_x_or_z(component: f64) -> f64 {
    let cubed = cube(component);
    if cubed > LAB_EPSILON {
        cubed
    } else {
        (116.0 * component - 16.0) / LAB_KAPPA
    }
}

/// lab [L, a, b] -> xyz-d50 (dart `LabColorSpace.convert`, default arm).
fn lab_to_xyz_d50(lab: [f64; 3]) -> [f64; 3] {
    let f1 = (lab[0] + 16.0) / 116.0;
    let x = lab_f_to_x_or_z(lab[1] / 500.0 + f1) * D50_X;
    let y = if lab[0] > 8.0 {
        cube(f1)
    } else {
        lab[0] / LAB_KAPPA
    };
    let z = lab_f_to_x_or_z(f1 - lab[2] / 200.0) * D50_Z;
    [x, y, z]
}

/// dart `XyzD50ColorSpace._convertComponentToLabF`.
fn xyz_component_to_lab_f(component: f64) -> f64 {
    if component > LAB_EPSILON {
        pow(component, 0.3333333333333333)
    } else {
        (LAB_KAPPA * component + 16.0) / 116.0
    }
}

/// xyz-d50 -> lab (dart `XyzD50ColorSpace.convert`, lab/lch arm).
fn xyz_d50_to_lab(xyz: [f64; 3]) -> [f64; 3] {
    let f0 = xyz_component_to_lab_f(xyz[0] / D50_X);
    let f1 = xyz_component_to_lab_f(xyz[1] / 1.0);
    let f2 = xyz_component_to_lab_f(xyz[2] / D50_Z);
    [116.0 * f1 - 16.0, 500.0 * (f0 - f1), 200.0 * (f1 - f2)]
}

const PI: f64 = 3.141592653589793;

/// lch-style [L, chroma, hue-deg] -> lab-style [L, a, b] (dart
/// `LchColorSpace.convert` / `OklchColorSpace.convert`).
pub(super) fn lch_to_lab(lch: [f64; 3]) -> [f64; 3] {
    let hue_radians = lch[2] * PI / 180.0;
    [lch[0], lch[1] * hue_radians.cos(), lch[1] * hue_radians.sin()]
}

/// lab-style [L, a, b] -> lch-style [L, chroma, hue-deg] (dart `labToLch`:
/// `pow(a, 2)` — the VM's square intrinsic — and a `+360` negative-hue fold).
pub(super) fn lab_to_lch(lab: [f64; 3]) -> [f64; 3] {
    let chroma = (square(lab[1]) + square(lab[2])).sqrt();
    let mut hue = lab[2].atan2(lab[1]) * 180.0 / PI;
    if hue < 0.0 {
        hue += 360.0;
    }
    [lab[0], chroma, hue]
}

// ---- oklab / oklch (dart `OklabColorSpace` / `LmsColorSpace`) ------------

/// oklab [L, a, b] -> LMS (dart `OklabColorSpace.convert`: matrix rows cubed
/// through `pow(x, 3)` — the VM's `x*x*x` intrinsic).
fn oklab_to_lms(oklab: [f64; 3]) -> [f64; 3] {
    let m = &OKLAB_TO_LMS;
    [
        cube(m[0] * oklab[0] + m[1] * oklab[1] + m[2] * oklab[2]),
        cube(m[3] * oklab[0] + m[4] * oklab[1] + m[5] * oklab[2]),
        cube(m[6] * oklab[0] + m[7] * oklab[1] + m[8] * oklab[2]),
    ]
}

/// LMS -> oklab (dart `LmsColorSpace.convert`, oklab arm: signed cube roots
/// via `pow(abs, 1/3) * sign`, then the lmsToOklab matrix).
fn lms_to_oklab(lms: [f64; 3]) -> [f64; 3] {
    let scale = |t: f64| pow(t.abs(), 0.3333333333333333) * t.signum();
    let l = scale(lms[0]);
    let m = scale(lms[1]);
    let s = scale(lms[2]);
    let t = &LMS_TO_OKLAB;
    [
        t[0] * l + t[1] * m + t[2] * s,
        t[3] * l + t[4] * m + t[5] * s,
        t[6] * l + t[7] * m + t[8] * s,
    ]
}

// ---- the conversion engine ----------------------------------------------

/// Convert `ch` (in `src`'s canonical channel units) to `dest`'s units,
/// following dart-sass's exact conversion graph.
pub(super) fn convert(src: ColorSpace, dest: ColorSpace, ch: [f64; 3]) -> [f64; 3] {
    if src == dest {
        return ch;
    }
    match src {
        ColorSpace::Hsl => from_srgb_source(hsl_to_srgb(ch), dest),
        ColorSpace::Hwb => from_srgb_source(hwb_to_srgb(ch), dest),
        ColorSpace::Rgb => from_srgb_source([ch[0] / 255.0, ch[1] / 255.0, ch[2] / 255.0], dest),
        ColorSpace::Lab => from_lab_source(ch, dest),
        ColorSpace::Lch => {
            let lab = lch_to_lab(ch);
            if dest == ColorSpace::Lab {
                lab
            } else {
                from_lab_source(lab, dest)
            }
        }
        ColorSpace::Oklab => from_oklab_source(ch, dest),
        ColorSpace::Oklch => {
            // dart's `OklabColorSpace.convert` has NO same-space case, so an
            // oklch source bound for oklab still round-trips through LMS
            // (cube then cube root) — `oklch(10% 999999 0deg)` comes back as
            // `oklab(9.9999999976% 999998.9999999992 0)`. Only a direct
            // oklab→oklab conversion short-circuits (at the toSpace level).
            from_oklab_source(lch_to_lab(ch), dest)
        }
        _ => convert_linear(src, ch, dest),
    }
}

/// dart `SrgbColorSpace.convert`: srgb channels already in [0..1].
fn from_srgb_source(rgb: [f64; 3], dest: ColorSpace) -> [f64; 3] {
    match dest {
        ColorSpace::Hsl => srgb_to_hsl(rgb),
        ColorSpace::Hwb => srgb_to_hwb(rgb),
        ColorSpace::Rgb => [rgb[0] * 255.0, rgb[1] * 255.0, rgb[2] * 255.0],
        ColorSpace::Srgb => rgb,
        ColorSpace::SrgbLinear => [
            srgb_to_linear(rgb[0]),
            srgb_to_linear(rgb[1]),
            srgb_to_linear(rgb[2]),
        ],
        _ => convert_linear(ColorSpace::Srgb, rgb, dest),
    }
}

/// dart `LabColorSpace.convert`, default arm: lab -> xyz-d50 -> onward.
fn from_lab_source(lab: [f64; 3], dest: ColorSpace) -> [f64; 3] {
    match dest {
        ColorSpace::Lab => lab,
        ColorSpace::Lch => lab_to_lch(lab),
        _ => convert_linear(ColorSpace::XyzD50, lab_to_xyz_d50(lab), dest),
    }
}

/// dart `OklabColorSpace.convert`: an oklch destination goes through
/// `labToLch`; EVERYTHING else — including oklab itself — falls to the
/// default LMS arm (dart has no same-space case here, so an oklab
/// destination cubes into LMS and cube-roots straight back).
fn from_oklab_source(oklab: [f64; 3], dest: ColorSpace) -> [f64; 3] {
    match dest {
        ColorSpace::Oklch => lab_to_lch(oklab),
        _ => convert_linear_from_lms(oklab_to_lms(oklab), dest),
    }
}

/// dart `ColorSpace.convertLinear` with an `Lms` source (LMS has no
/// `ColorSpace` of its own here).
fn convert_linear_from_lms(lms: [f64; 3], dest: ColorSpace) -> [f64; 3] {
    let (through_lin, finalize) = through_of(dest);
    let transformed = if through_lin == Lin::Lms {
        lms
    } else {
        let m = matrix(Lin::Lms, through_lin);
        let (_, _, from_linear) = lin_of_through(through_lin, dest);
        apply(m, lms, from_linear)
    };
    finalize_dest(transformed, dest, finalize)
}

/// dart `ColorSpace.convertLinear`: toLinear each channel, ONE matrix into the
/// destination's through-space, fromLinear each channel, then the
/// destination's special finalization.
fn convert_linear(src: ColorSpace, ch: [f64; 3], dest: ColorSpace) -> [f64; 3] {
    let (src_lin, to_linear, _) = lin_of(src);
    let (through_lin, finalize) = through_of(dest);
    let same_space = src_lin == through_lin && through_space_equals_src(src, dest);
    let transformed = if same_space {
        ch
    } else {
        let linear = [to_linear(ch[0]), to_linear(ch[1]), to_linear(ch[2])];
        let (_, _, from_linear) = lin_of_through(through_lin, dest);
        if src_lin == through_lin {
            [
                from_linear(linear[0]),
                from_linear(linear[1]),
                from_linear(linear[2]),
            ]
        } else {
            apply(matrix(src_lin, through_lin), linear, from_linear)
        }
    };
    finalize_dest(transformed, dest, finalize)
}

#[inline]
fn apply(m: &[f64; 9], v: [f64; 3], from_linear: fn(f64) -> f64) -> [f64; 3] {
    [
        from_linear(m[0] * v[0] + m[1] * v[1] + m[2] * v[2]),
        from_linear(m[3] * v[0] + m[4] * v[1] + m[5] * v[2]),
        from_linear(m[6] * v[0] + m[7] * v[1] + m[8] * v[2]),
    ]
}

/// Which finalization the destination needs after reaching its through-space.
#[derive(Clone, Copy, PartialEq)]
enum Finalize {
    None,
    Hsl,
    Hwb,
    Rgb255,
    Lab,
    Lch,
    Oklab,
    Oklch,
}

/// The linear node a destination converts THROUGH (dart's dest mapping in
/// `convertLinear`), plus its finalization step.
fn through_of(dest: ColorSpace) -> (Lin, Finalize) {
    match dest {
        ColorSpace::Hsl => (Lin::Srgb, Finalize::Hsl),
        ColorSpace::Hwb => (Lin::Srgb, Finalize::Hwb),
        ColorSpace::Rgb => (Lin::Srgb, Finalize::Rgb255),
        ColorSpace::Lab => (Lin::XyzD50, Finalize::Lab),
        ColorSpace::Lch => (Lin::XyzD50, Finalize::Lch),
        ColorSpace::Oklab => (Lin::Lms, Finalize::Oklab),
        ColorSpace::Oklch => (Lin::Lms, Finalize::Oklch),
        _ => (lin_of(dest).0, Finalize::None),
    }
}

/// Whether dart's `t2 === _this` short-circuit applies: the destination's
/// through-SPACE (not just node) is the source space, so the channels pass
/// through untouched (e.g. srgb -> hsl skips the linear round-trip).
fn through_space_equals_src(src: ColorSpace, dest: ColorSpace) -> bool {
    let through_space = match dest {
        ColorSpace::Hsl | ColorSpace::Hwb | ColorSpace::Rgb => ColorSpace::Srgb,
        ColorSpace::Lab | ColorSpace::Lch => ColorSpace::XyzD50,
        // Oklab/Oklch go through LMS, which no ColorSpace equals.
        ColorSpace::Oklab | ColorSpace::Oklch => return false,
        other => other,
    };
    through_space == src
}

/// The fromLinear of the through-space (hsl/hwb/rgb255 finalize from srgb,
/// lab/lch from xyz-d50, oklab/oklch from LMS — all with their through-space
/// transfer, which for the hubs is the identity).
fn lin_of_through(through: Lin, dest: ColorSpace) -> LinTransfer {
    fn id(c: f64) -> f64 {
        c
    }
    match through {
        Lin::Srgb => match dest {
            // The srgb-through destinations apply srgb's own transfer.
            ColorSpace::SrgbLinear => (Lin::Srgb, id, id),
            _ => (Lin::Srgb, srgb_to_linear, srgb_from_linear),
        },
        Lin::DisplayP3 => match dest {
            ColorSpace::DisplayP3Linear => (Lin::DisplayP3, id, id),
            _ => (Lin::DisplayP3, srgb_to_linear, srgb_from_linear),
        },
        Lin::A98 => (Lin::A98, a98_to_linear, a98_from_linear),
        Lin::Prophoto => (Lin::Prophoto, prophoto_to_linear, prophoto_from_linear),
        Lin::Rec2020 => (Lin::Rec2020, rec2020_to_linear, rec2020_from_linear),
        Lin::XyzD65 | Lin::XyzD50 | Lin::Lms => (through, id, id),
    }
}

fn finalize_dest(transformed: [f64; 3], _dest: ColorSpace, finalize: Finalize) -> [f64; 3] {
    match finalize {
        Finalize::None => transformed,
        Finalize::Hsl => srgb_to_hsl(transformed),
        Finalize::Hwb => srgb_to_hwb(transformed),
        Finalize::Rgb255 => [
            transformed[0] * 255.0,
            transformed[1] * 255.0,
            transformed[2] * 255.0,
        ],
        Finalize::Lab => xyz_d50_to_lab(transformed),
        Finalize::Lch => lab_to_lch(xyz_d50_to_lab(transformed)),
        Finalize::Oklab => lms_to_oklab(transformed),
        Finalize::Oklch => lab_to_lch(lms_to_oklab(transformed)),
    }
}
