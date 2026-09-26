//! A bit-faithful port of musl's double-precision `pow` (the ARM
//! optimized-routines implementation, Copyright (c) 2018, Arm Limited,
//! SPDX-License-Identifier: MIT — the same algorithm glibc >= 2.28 ships,
//! in its non-FMA form).
//!
//! Color-space conversion calls THIS pow rather than `f64::powf`: platform
//! libms round differently in the last ulp on real inputs, and those
//! single-ulp differences are visible in sasso's byte-exact color output.
//! Measured against the full sass-spec color corpus this implementation
//! matches the expectations best (the corpus is of mixed provenance — a
//! V8/fdlibm port was tried too and loses 20 net cases). The port is
//! validated bit-for-bit against the compiled musl C (see `oracle_tests`).

#![allow(
    clippy::excessive_precision,
    clippy::approx_constant,
    clippy::unreadable_literal
)]

include!(concat!(env!("CARGO_MANIFEST_DIR"), "/src/musl_math_tables.rs"));

const OFF: u64 = 0x3fe6955500000000;
const SIGN_BIAS: u32 = 0x800 << 7;

#[inline]
fn top12(x: f64) -> u32 {
    (x.to_bits() >> 52) as u32
}

#[inline]
fn log_inline(ix: u64) -> (f64, f64) {
    let tmp = ix.wrapping_sub(OFF);
    let i = ((tmp >> (52 - 7)) % 128) as usize;
    let k = (tmp as i64) >> 52;
    let iz = ix.wrapping_sub(tmp & (0xfffu64 << 52));
    let z = f64::from_bits(iz);
    let kd = k as f64;
    let (invc, logc, logctail) = LOG_TAB[i];
    // non-FMA split (glibc baseline x86-64 has no FMA in the generic build)
    let zhi = f64::from_bits((iz.wrapping_add(1u64 << 31)) & (u64::MAX << 32));
    let zlo = z - zhi;
    let rhi = zhi * invc - 1.0;
    let rlo = zlo * invc;
    let r = rhi + rlo;
    let t1 = kd * LN2HI + logc;
    let t2 = t1 + r;
    let lo1 = kd * LN2LO + logctail;
    let lo2 = t1 - t2 + r;
    let ar = LOG_POLY[0] * r;
    let ar2 = r * ar;
    let ar3 = r * ar2;
    let arhi = LOG_POLY[0] * rhi;
    let arhi2 = rhi * arhi;
    let hi = t2 + arhi2;
    let lo3 = rlo * (ar + arhi);
    let lo4 = t2 - hi + arhi2;
    let p = ar3
        * (LOG_POLY[1]
            + r * LOG_POLY[2]
            + ar2 * (LOG_POLY[3] + r * LOG_POLY[4] + ar2 * (LOG_POLY[5] + r * LOG_POLY[6])));
    let lo = lo1 + lo2 + lo3 + lo4 + p;
    let y = hi + lo;
    (y, hi - y + lo)
}

#[inline]
// `lo = one - hi + y + lo` must keep its left-to-right summation order
// (clippy's `lo += …` suggestion would reassociate and change the bits).
#[allow(clippy::assign_op_pattern)]
fn specialcase(tmp: f64, mut sbits: u64, ki: u64) -> f64 {
    if (ki & 0x80000000) == 0 {
        sbits = sbits.wrapping_sub(1009u64 << 52);
        let scale = f64::from_bits(sbits);
        return f64::from_bits(0x7f00000000000000) * (scale + scale * tmp);
    }
    sbits = sbits.wrapping_add(1022u64 << 52);
    let scale = f64::from_bits(sbits);
    let mut y = scale + scale * tmp;
    if y.abs() < 1.0 {
        let one = if y < 0.0 { -1.0 } else { 1.0 };
        let mut lo = scale - y + scale * tmp;
        let hi = one + y;
        lo = one - hi + y + lo;
        y = (hi + lo) - one;
        if y == 0.0 {
            y = f64::from_bits(sbits & 0x8000000000000000);
        }
    }
    f64::from_bits(0x0010000000000000) * y
}

#[inline]
fn exp_inline(x: f64, xtail: f64, sign_bias: u32) -> f64 {
    let mut abstop = top12(x) & 0x7ff;
    if abstop.wrapping_sub(0x3c9) >= 0x408 - 0x3c9 {
        if abstop.wrapping_sub(0x3c9) >= 0x80000000 {
            let one = 1.0 + x;
            return if sign_bias != 0 { -one } else { one };
        }
        if abstop >= 0x409 {
            if (x.to_bits() >> 63) != 0 {
                return if sign_bias != 0 { -0.0 } else { 0.0 };
            }
            return if sign_bias != 0 {
                f64::NEG_INFINITY
            } else {
                f64::INFINITY
            };
        }
        abstop = 0;
    }
    let z = INVLN2N * x;
    let kd_shifted = z + SHIFT;
    let ki = kd_shifted.to_bits();
    let kd = kd_shifted - SHIFT;
    let r = x + kd * NEGLN2HIN + kd * NEGLN2LON + xtail;
    let idx = (2 * (ki % 128)) as usize;
    let top = (ki.wrapping_add(sign_bias as u64)) << (52 - 7);
    let tail = f64::from_bits(EXP_TAB[idx]);
    let sbits = EXP_TAB[idx + 1].wrapping_add(top);
    let r2 = r * r;
    let tmp = tail + r + r2 * (C2 + r * C3) + r2 * r2 * (C4 + r * C5);
    if abstop == 0 {
        return specialcase(tmp, sbits, ki);
    }
    let scale = f64::from_bits(sbits);
    scale + scale * tmp
}

#[inline]
fn checkint(iy: u64) -> i32 {
    let e = ((iy >> 52) & 0x7ff) as i32;
    if e < 0x3ff {
        return 0;
    }
    if e > 0x3ff + 52 {
        return 2;
    }
    if iy & ((1u64 << (0x3ff + 52 - e)) - 1) != 0 {
        return 0;
    }
    if iy & (1u64 << (0x3ff + 52 - e)) != 0 {
        return 1;
    }
    2
}

#[inline]
fn zeroinfnan(i: u64) -> bool {
    i.wrapping_mul(2).wrapping_sub(1) >= (0x7ffu64 << 53).wrapping_sub(1)
}

pub(crate) fn pow(x: f64, y: f64) -> f64 {
    let mut sign_bias: u32 = 0;
    let mut ix = x.to_bits();
    let iy = y.to_bits();
    let mut topx = top12(x);
    let topy = top12(y);
    if topx.wrapping_sub(1) >= 0x7ff - 1 || (topy & 0x7ff).wrapping_sub(0x3be) >= 0x43e - 0x3be {
        if zeroinfnan(iy) {
            if iy.wrapping_mul(2) == 0 {
                return 1.0;
            }
            if ix == 1.0f64.to_bits() {
                return 1.0;
            }
            if ix.wrapping_mul(2) > f64::INFINITY.to_bits().wrapping_mul(2)
                || iy.wrapping_mul(2) > f64::INFINITY.to_bits().wrapping_mul(2)
            {
                return x + y;
            }
            if ix.wrapping_mul(2) == 1.0f64.to_bits().wrapping_mul(2) {
                return 1.0;
            }
            if (ix.wrapping_mul(2) < 1.0f64.to_bits().wrapping_mul(2)) == ((iy >> 63) == 0) {
                return 0.0;
            }
            return y * y;
        }
        if zeroinfnan(ix) {
            let mut x2 = x * x;
            if (ix >> 63) != 0 && checkint(iy) == 1 {
                x2 = -x2;
            }
            return if (iy >> 63) != 0 { 1.0 / x2 } else { x2 };
        }
        if (ix >> 63) != 0 {
            let yint = checkint(iy);
            if yint == 0 {
                return f64::NAN;
            }
            if yint == 1 {
                sign_bias = SIGN_BIAS;
            }
            ix &= 0x7fffffffffffffff;
            topx &= 0x7ff;
        }
        if (topy & 0x7ff).wrapping_sub(0x3be) >= 0x43e - 0x3be {
            if ix == 1.0f64.to_bits() {
                return 1.0;
            }
            if (topy & 0x7ff) < 0x3be {
                return if ix > 1.0f64.to_bits() { 1.0 + y } else { 1.0 - y };
            }
            return if (ix > 1.0f64.to_bits()) == ((topy & 0x800) == 0) {
                f64::INFINITY
            } else {
                0.0
            };
        }
        if topx == 0 {
            ix = (x * f64::from_bits(0x4330000000000000)).to_bits();
            ix &= 0x7fffffffffffffff;
            ix = ix.wrapping_sub(52u64 << 52);
        }
    }
    let (hi, lo) = log_inline(ix);
    let yhi = f64::from_bits(iy & (u64::MAX << 27));
    let ylo = y - yhi;
    let lhi = f64::from_bits(hi.to_bits() & (u64::MAX << 27));
    let llo = hi - lhi + lo;
    let ehi = yhi * lhi;
    let elo = ylo * lhi + y * llo;
    exp_inline(ehi, elo, sign_bias)
}

#[cfg(test)]
mod tests {
    use super::pow;

    #[test]
    fn special_cases() {
        assert_eq!(pow(2.0, 0.0), 1.0);
        assert_eq!(pow(f64::NAN, 0.0), 1.0);
        assert_eq!(pow(0.0, 3.0), 0.0);
        assert_eq!(pow(-0.0, 3.0).to_bits(), (-0.0f64).to_bits());
        assert_eq!(pow(0.0, -2.0), f64::INFINITY);
        assert_eq!(pow(-2.0, 3.0), -8.0);
        assert_eq!(pow(-2.0, 2.0), 4.0);
        assert!(pow(-2.0, 2.5).is_nan());
        assert_eq!(pow(f64::INFINITY, -1.0), 0.0);
        assert_eq!(pow(0.5, f64::INFINITY), 0.0);
        assert_eq!(pow(0.5, f64::NEG_INFINITY), f64::INFINITY);
        assert_eq!(pow(-1.0, f64::INFINITY), 1.0);
    }

    /// Bit-exact fuzz against the locally-compiled musl C `pow` built with the
    /// non-FMA path (set `MUSL_POW_ORACLE=/path/to/powtest`); skipped when
    /// unset.
    #[test]
    fn matches_musl_c_oracle() {
        let Ok(oracle) = std::env::var("MUSL_POW_ORACLE") else {
            return;
        };
        use std::process::{Command, Stdio};
        let exps = [
            2.4,
            1.0 / 2.4,
            0.4166666666666667,
            1.0 / 3.0,
            0.3333333333333333,
            3.0,
            2.0,
            1.8,
            0.5555555555555556,
            2.19921875,
            0.4547069271758437,
            0.45,
            2.2222222222222223,
            0.5,
            -1.5,
            7.3,
        ];
        let mut pairs: Vec<(f64, f64)> = Vec::new();
        let mut state = 0x243F6A8885A308D3u64;
        let mut rnd = || {
            state = state
                .wrapping_mul(6364136223846793005)
                .wrapping_add(1442695040888963407);
            state
        };
        for _ in 0..20_000 {
            let m = (rnd() >> 11) as f64 / (1u64 << 53) as f64;
            let e = ((rnd() % 121) as i32) - 60;
            let base = m * 2f64.powi(e);
            for &y in &exps {
                pairs.push((base, y));
            }
        }
        for _ in 0..100_000 {
            let x = f64::from_bits(rnd() & 0x7fefffffffffffff);
            let y = f64::from_bits(rnd() & 0x7fefffffffffffff);
            pairs.push((x, y));
            pairs.push((-x, y.round()));
        }
        let input: String = pairs
            .iter()
            .map(|(x, y)| format!("{:016x} {:016x}\n", x.to_bits(), y.to_bits()))
            .collect();
        let dir = std::env::temp_dir();
        let in_path = dir.join("musl_pow_in.txt");
        let out_path = dir.join("musl_pow_out.txt");
        std::fs::write(&in_path, input).expect("write input");
        let infile = std::fs::File::open(&in_path).expect("open input");
        let outfile = std::fs::File::create(&out_path).expect("create output");
        let status = Command::new(&oracle)
            .stdin(Stdio::from(infile))
            .stdout(Stdio::from(outfile))
            .status()
            .expect("oracle run");
        assert!(status.success());
        let expected: Vec<u64> = std::fs::read_to_string(&out_path)
            .expect("read output")
            .trim()
            .lines()
            .map(|l| u64::from_str_radix(l.trim(), 16).expect("hex"))
            .collect();
        assert_eq!(expected.len(), pairs.len());
        let mut bad = 0;
        for ((x, y), want_bits) in pairs.iter().zip(&expected) {
            let got = pow(*x, *y);
            if f64::from_bits(*want_bits).is_nan() {
                assert!(got.is_nan(), "pow({x:e}, {y:e}) want NaN got {got:e}");
                continue;
            }
            if got.to_bits() != *want_bits {
                bad += 1;
                if bad <= 10 {
                    eprintln!(
                        "pow({x:e}, {y:e}): got {:016x} want {want_bits:016x}",
                        got.to_bits()
                    );
                }
            }
        }
        assert_eq!(bad, 0, "{bad}/{} mismatches vs musl C", pairs.len());
    }
}
