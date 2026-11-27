//! `f64` → shortest round-trip decimal, byte-compatible with Rust's `{}`
//! Display formatting (which never uses exponential notation), without the
//! `core::fmt` machinery. A line-faithful port of the Ryū `d2s` algorithm
//! (Ulf Adams, "Ryū: fast float-to-string conversion", PLDI 2018) with the
//! 125-bit full tables; the tables are generated offline with arbitrary-
//! precision integers (see the checksum test) like `musl_math`'s.
//!
//! Verified against `format!("{n}")` by an exhaustive-category differential
//! fuzz (every exponent × random mantissas, boundaries, halfway ties) — see
//! `tests/ryu_fuzz.rs` — and by the full sass-spec suite.

#![allow(clippy::many_single_char_names)]

include!("ryu_tables.rs");

const MANTISSA_BITS: u32 = 52;
const EXPONENT_BITS: u32 = 11;
const BIAS: i32 = 1023;
const POW5_INV_BITCOUNT: i32 = 125;
const POW5_BITCOUNT: i32 = 125;

/// ceil(log2(5^e)), for 0 <= e <= 3528.
#[inline]
fn pow5bits(e: i32) -> i32 {
    (((e as u64 * 1217359) >> 19) + 1) as i32
}

/// floor(e * log10(2)), for 0 <= e <= 1650.
#[inline]
fn log10_pow2(e: i32) -> u32 {
    ((e as u64 * 78913) >> 18) as u32
}

/// floor(e * log10(5)), for 0 <= e <= 2620.
#[inline]
fn log10_pow5(e: i32) -> u32 {
    ((e as u64 * 732923) >> 20) as u32
}

#[inline]
fn pow5_factor(mut value: u64) -> u32 {
    let mut count = 0;
    loop {
        debug_assert!(value != 0);
        let q = value / 5;
        if q * 5 != value {
            return count;
        }
        value = q;
        count += 1;
    }
}

/// Whether `value` is divisible by `5^p`.
#[inline]
fn multiple_of_power_of_5(value: u64, p: u32) -> bool {
    pow5_factor(value) >= p
}

/// Whether `value` is divisible by `2^p`.
#[inline]
fn multiple_of_power_of_2(value: u64, p: u32) -> bool {
    value & ((1u64 << p) - 1) == 0
}

/// (m * mul) >> j, where mul is a 128-bit value as (lo, hi) and 64 <= j < 128.
#[inline]
fn mul_shift_64(m: u64, mul: (u64, u64), j: i32) -> u64 {
    let b0 = m as u128 * mul.0 as u128;
    let b2 = m as u128 * mul.1 as u128;
    (((b0 >> 64) + b2) >> (j - 64)) as u64
}

/// The shortest decimal: `digits * 10^exponent` round-trips to the input.
pub(crate) struct FloatingDecimal64 {
    pub(crate) digits: u64,
    pub(crate) exponent: i32,
}

/// Core Ryū d2d on a non-zero, finite double's IEEE fields.
fn d2d(ieee_mantissa: u64, ieee_exponent: u32) -> FloatingDecimal64 {
    let (e2, m2): (i32, u64) = if ieee_exponent == 0 {
        (1 - BIAS - MANTISSA_BITS as i32 - 2, ieee_mantissa)
    } else {
        (
            ieee_exponent as i32 - BIAS - MANTISSA_BITS as i32 - 2,
            (1u64 << MANTISSA_BITS) | ieee_mantissa,
        )
    };
    let even = (m2 & 1) == 0;
    let accept_bounds = even;

    // Step 2: determine the interval of valid decimal representations.
    let mv = 4 * m2;
    // Implicit bool -> int conversion: 1 when the lower bound is closer.
    let mm_shift: u64 = u64::from(ieee_mantissa != 0 || ieee_exponent <= 1);

    // Step 3: convert to a decimal power base via 128-bit arithmetic.
    let mut vr: u64;
    let mut vp: u64;
    let mut vm: u64;
    let e10: i32;
    let mut vm_is_trailing_zeros = false;
    let mut vr_is_trailing_zeros = false;
    if e2 >= 0 {
        let q = log10_pow2(e2) - u32::from(e2 > 3);
        e10 = q as i32;
        let k = POW5_INV_BITCOUNT + pow5bits(q as i32) - 1;
        let i = -e2 + q as i32 + k;
        let mul = DOUBLE_POW5_INV_SPLIT[q as usize];
        vr = mul_shift_64(mv, mul, i);
        vp = mul_shift_64(mv + 2, mul, i);
        vm = mul_shift_64(mv - 1 - mm_shift, mul, i);
        if q <= 21 {
            // Only one of mp, mv, mm can be a multiple of 5, if any.
            if mv % 5 == 0 {
                vr_is_trailing_zeros = multiple_of_power_of_5(mv, q);
            } else if accept_bounds {
                vm_is_trailing_zeros = multiple_of_power_of_5(mv - 1 - mm_shift, q);
            } else {
                vp -= u64::from(multiple_of_power_of_5(mv + 2, q));
            }
        }
    } else {
        let q = log10_pow5(-e2) - u32::from(-e2 > 1);
        e10 = q as i32 + e2;
        let i = -e2 - q as i32;
        let k = pow5bits(i) - POW5_BITCOUNT;
        let j = q as i32 - k;
        let mul = DOUBLE_POW5_SPLIT[i as usize];
        vr = mul_shift_64(mv, mul, j);
        vp = mul_shift_64(mv + 2, mul, j);
        vm = mul_shift_64(mv - 1 - mm_shift, mul, j);
        if q <= 1 {
            // {vr,vp,vm} is trailing zeros if {mv,mp,mm} has at least q
            // trailing zero bits.
            vr_is_trailing_zeros = true;
            if accept_bounds {
                // mm = mv - 1 - mm_shift, so it has 1 trailing 0 bit iff
                // mm_shift == 1.
                vm_is_trailing_zeros = mm_shift == 1;
            } else {
                // mp = mv + 2, so it always has at least one trailing 0 bit.
                vp -= 1;
            }
        } else if q < 63 {
            vr_is_trailing_zeros = multiple_of_power_of_2(mv, q);
        }
    }

    // Step 4: find the shortest decimal representation in the interval.
    let mut removed: i32 = 0;
    let mut last_removed_digit: u8 = 0;
    let output: u64 = if vm_is_trailing_zeros || vr_is_trailing_zeros {
        // General case (rare).
        loop {
            let vp_div10 = vp / 10;
            let vm_div10 = vm / 10;
            if vp_div10 <= vm_div10 {
                break;
            }
            let vm_mod10 = (vm - 10 * vm_div10) as u32;
            let vr_div10 = vr / 10;
            let vr_mod10 = (vr - 10 * vr_div10) as u32;
            vm_is_trailing_zeros &= vm_mod10 == 0;
            last_removed_digit = vr_mod10 as u8;
            vr = vr_div10;
            vp = vp_div10;
            vm = vm_div10;
            removed += 1;
        }
        if vm_is_trailing_zeros {
            loop {
                let vm_div10 = vm / 10;
                let vm_mod10 = (vm - 10 * vm_div10) as u32;
                if vm_mod10 != 0 {
                    break;
                }
                let vp_div10 = vp / 10;
                let vr_div10 = vr / 10;
                let vr_mod10 = (vr - 10 * vr_div10) as u32;
                last_removed_digit = vr_mod10 as u8;
                vr = vr_div10;
                vp = vp_div10;
                vm = vm_div10;
                removed += 1;
            }
        }
        // Reference Ryū rounds an exact .....50..0 tie to EVEN here (ECMA
        // toString semantics). Rust's Display rounds such exact ties UP
        // (half away from zero) — verified by the differential fuzz — so the
        // even-adjustment is deliberately omitted.
        // We need to take vr + 1 if vr is outside bounds or we need to round up.
        vr + u64::from((vr == vm && (!accept_bounds || !vm_is_trailing_zeros)) || last_removed_digit >= 5)
    } else {
        // Specialized common case: no trailing zeros in vr/vm.
        let mut round_up = false;
        let vp_div100 = vp / 100;
        let vm_div100 = vm / 100;
        if vp_div100 > vm_div100 {
            let vr_div100 = vr / 100;
            let vr_mod100 = (vr - 100 * vr_div100) as u32;
            round_up = vr_mod100 >= 50;
            vr = vr_div100;
            vp = vp_div100;
            vm = vm_div100;
            removed += 2;
        }
        loop {
            let vp_div10 = vp / 10;
            let vm_div10 = vm / 10;
            if vp_div10 <= vm_div10 {
                break;
            }
            let vr_div10 = vr / 10;
            let vr_mod10 = (vr - 10 * vr_div10) as u32;
            round_up = vr_mod10 >= 5;
            vr = vr_div10;
            vp = vp_div10;
            vm = vm_div10;
            removed += 1;
        }
        vr + u64::from(vr == vm || round_up)
    };
    FloatingDecimal64 {
        digits: output,
        exponent: e10 + removed,
    }
}

/// Format a finite, non-zero `f64` exactly as Rust's `{}` Display does —
/// shortest round-trip digits in plain positional notation, no exponent
/// form ever (`1e300` prints all 301 characters). The caller handles NaN,
/// infinities, and zero.
pub(crate) fn format64(f: f64, out: &mut String) {
    let bits = f.to_bits();
    let sign = (bits >> (MANTISSA_BITS + EXPONENT_BITS)) != 0;
    let ieee_mantissa = bits & ((1u64 << MANTISSA_BITS) - 1);
    let ieee_exponent = ((bits >> MANTISSA_BITS) & ((1u64 << EXPONENT_BITS) - 1)) as u32;
    debug_assert!(ieee_exponent != ((1 << EXPONENT_BITS) - 1) && (ieee_exponent != 0 || ieee_mantissa != 0));

    if sign {
        out.push('-');
    }
    let v = d2d(ieee_mantissa, ieee_exponent);

    // Decimal digits of v.digits, written into a stack buffer back-to-front.
    let mut buf = [0u8; 17];
    let mut n = v.digits;
    let mut at = buf.len();
    loop {
        at -= 1;
        buf[at] = b'0' + (n % 10) as u8;
        n /= 10;
        if n == 0 {
            break;
        }
    }
    // Validate the ASCII digit run ONCE; the branches below slice this `&str`
    // (str slicing is byte-indexed, so no further UTF-8 checks) instead of
    // re-validating each fragment.
    let digits = std::str::from_utf8(&buf[at..]).expect("ascii digits");
    let len = digits.len() as i32;
    // The decimal point sits after `point` digits: digits * 10^exponent.
    let point = len + v.exponent;
    if v.exponent >= 0 {
        // All digits before the point, then exponent zeros: 123000…
        out.reserve(digits.len() + v.exponent as usize);
        out.push_str(digits);
        push_zeros(out, v.exponent as usize);
    } else if point > 0 {
        // Point inside the digit run: 12.3…
        let point = point as usize;
        out.reserve(digits.len() + 1);
        out.push_str(&digits[..point]);
        out.push('.');
        out.push_str(&digits[point..]);
    } else {
        // 0.00…digits
        let zeros = (-point) as usize;
        out.reserve(2 + zeros + digits.len());
        out.push_str("0.");
        push_zeros(out, zeros);
        out.push_str(digits);
    }
}

/// Append `n` ASCII '0' bytes (a single extend, not a per-char push loop).
#[inline]
fn push_zeros(out: &mut String, n: usize) {
    out.extend(std::iter::repeat('0').take(n));
}

#[cfg(test)]
mod tests {
    use super::*;

    fn fmt(f: f64) -> String {
        let mut s = String::new();
        format64(f, &mut s);
        s
    }

    #[test]
    fn matches_display_on_classics() {
        for v in [
            0.1,
            0.3,
            1.5,
            2.5,
            100.0_f64.next_up(),
            1e300,
            5e-324,
            1e-4,
            123456.789,
            33.333333333333336,
            2154.15598416745,
            657390374199289.2,
            9007199254740993.0,
            1.7976931348623157e308,
            2.2250738585072014e-308,
        ] {
            assert_eq!(fmt(v), format!("{v}"), "for {v:e}");
            assert_eq!(fmt(-v), format!("{}", -v), "for -{v:e}");
        }
    }

    /// Differential fuzz vs `format!("{n}")`. Default ~2M cases (CI-fast);
    /// set RYU_FUZZ_N for the big runs (the port was validated at 2e8+).
    /// Categories: pure random bit patterns, every exponent with random
    /// mantissas, mantissa boundary patterns, integers and their halves
    /// (exact-tie hunting), and powers of ten.
    #[test]
    fn differential_fuzz_vs_display() {
        let n: u64 = std::env::var("RYU_FUZZ_N")
            .ok()
            .and_then(|v| v.parse().ok())
            .unwrap_or(2_000_000);
        let threads: u64 = std::thread::available_parallelism().map_or(4, |p| p.get() as u64);
        let per = n / threads;
        let handles: Vec<_> = (0..threads)
            .map(|t| {
                std::thread::spawn(move || {
                    let mut state: u64 = 0x9e3779b97f4a7c15 ^ (t.wrapping_mul(0xbf58476d1ce4e5b9) + 1);
                    let mut rng = move || {
                        state ^= state << 13;
                        state ^= state >> 7;
                        state ^= state << 17;
                        state
                    };
                    let check = |f: f64| {
                        if !f.is_finite() || f == 0.0 {
                            return;
                        }
                        let mut got = String::new();
                        format64(f, &mut got);
                        let want = format!("{f}");
                        assert_eq!(got, want, "mismatch for bits 0x{:016x}", f.to_bits());
                    };
                    for i in 0..per {
                        // 1: pure random bit pattern
                        check(f64::from_bits(rng()));
                        // 2: every exponent, random mantissa
                        let exp = (i % 2046) + 1;
                        check(f64::from_bits((exp << 52) | (rng() & ((1 << 52) - 1))));
                        // 3: mantissa boundaries (all-zeros/all-ones/single-bit)
                        let m = match i % 4 {
                            0 => 0,
                            1 => (1 << 52) - 1,
                            2 => 1 << (i % 52),
                            _ => ((1 << 52) - 1) ^ (1 << (i % 52)),
                        };
                        check(f64::from_bits((exp << 52) | m));
                        // 4: integers and exact halves/quarters (tie hunting)
                        let int = (rng() % 1_000_000_000_000_000_000) as f64;
                        check(int + 0.5);
                        check(int + 0.25);
                        check((int + 0.5) / 1024.0);
                        // 5: subnormals
                        check(f64::from_bits(rng() & ((1 << 52) - 1)));
                    }
                    // powers of ten and neighbors, once per thread
                    for p in -308..=308 {
                        let v = 10f64.powi(p);
                        check(v);
                        check(v.next_up());
                        check(v.next_down());
                    }
                })
            })
            .collect();
        for h in handles {
            h.join().expect("fuzz thread panicked = mismatch found");
        }
    }

    #[test]
    fn tables_checksum() {
        // Guard the generated tables against accidental edits: FNV-1a over
        // all limbs, value pinned by the generator run that produced them.
        let mut h: u64 = 0xcbf29ce484222325;
        let mut mix = |x: u64| {
            for b in x.to_le_bytes() {
                h ^= b as u64;
                h = h.wrapping_mul(0x100000001b3);
            }
        };
        for &(lo, hi) in DOUBLE_POW5_SPLIT.iter().chain(DOUBLE_POW5_INV_SPLIT.iter()) {
            mix(lo);
            mix(hi);
        }
        assert_eq!(h, TABLE_CHECKSUM, "regenerate ryu_tables.rs");
    }
}
