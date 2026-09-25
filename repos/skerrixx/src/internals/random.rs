//! tiny non-crypto rng, replacing `rand` for the `--super` easter egg. seeded
//! from `/dev/urandom` (falls back to time + pid). not for anything that
//! matters.

use std::cell::Cell;

thread_local! {
    static STATE: Cell<u64> = Cell::new(seed());
}

fn seed() -> u64 {
    if let Ok(mut f) = std::fs::File::open("/dev/urandom") {
        use std::io::Read;
        let mut buf = [0u8; 8];
        if f.read_exact(&mut buf).is_ok() {
            return u64::from_ne_bytes(buf);
        }
    }
    let nanos = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_nanos() as u64)
        .unwrap_or(0);
    nanos ^ (std::process::id() as u64).wrapping_mul(0x9E37_79B9_7F4A_7C15)
}

fn next_u64() -> u64 {
    STATE.with(|s| {
        let mut x = s.get();
        // xorshift64
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        s.set(x);
        x
    })
}

/// uniform value in `start..end` (end exclusive). end must be > start.
pub fn random_range(start: usize, end: usize) -> usize {
    debug_assert!(end > start, "random_range: end must be greater than start");
    let span = end - start;
    if span == 0 {
        return start;
    }
    // modulo bias is fine here, small spans and nothing sensitive.
    start + (next_u64() as usize) % span
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn random_range_stays_in_bounds() {
        for _ in 0..1000 {
            let v = random_range(1, 7);
            assert!((1..7).contains(&v), "out of range: {v}");
        }
    }
}
