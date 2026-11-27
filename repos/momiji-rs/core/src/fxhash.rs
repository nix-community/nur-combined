//! A small, fast, non-cryptographic hasher (the "FxHash" algorithm, as used by
//! rustc and Firefox) for the compiler's internal `String`-keyed maps.
//!
//! The default `std` `HashMap` uses SipHash, which is DoS-resistant but slow —
//! and the compiler's hot path is dominated by variable / function / mixin
//! lookups keyed on short identifiers, where collision-resistance against
//! adversarial input is irrelevant (the keys come from the stylesheet being
//! compiled, not the network). Swapping in FxHash cut a visible chunk of the
//! profile's hashing time.
//!
//! Implemented inline (no `rustc-hash` dependency) to preserve sasso's
//! zero-runtime-dependency property, and with no `unsafe` (the crate forbids
//! it): the byte path uses `copy_from_slice` + `from_le_bytes`.

use std::collections::{HashMap, HashSet};
use std::hash::{BuildHasherDefault, Hasher};

/// The FxHash mixing constant (a large odd number; same as rustc-hash).
const SEED: u64 = 0x51_7c_c1_b7_27_22_0a_95;

/// A `HashMap` using [`FxHasher`] instead of the default SipHash.
pub(crate) type FxHashMap<K, V> = HashMap<K, V, BuildHasherDefault<FxHasher>>;

/// A `HashSet` using [`FxHasher`] instead of the default SipHash.
pub(crate) type FxHashSet<K> = HashSet<K, BuildHasherDefault<FxHasher>>;

/// FxHash: fold each machine word of the input into the running hash with a
/// rotate-xor-multiply step. Fast for short keys; not collision-resistant
/// against adversarial input (which the compiler never hashes).
#[derive(Default)]
pub(crate) struct FxHasher {
    hash: u64,
}

impl FxHasher {
    #[inline]
    fn add(&mut self, word: u64) {
        self.hash = (self.hash.rotate_left(5) ^ word).wrapping_mul(SEED);
    }
}

impl Hasher for FxHasher {
    #[inline]
    fn write(&mut self, mut bytes: &[u8]) {
        // Consume 8/4/2/1-byte chunks, each as a little-endian word.
        while bytes.len() >= 8 {
            let mut buf = [0u8; 8];
            buf.copy_from_slice(&bytes[..8]);
            self.add(u64::from_le_bytes(buf));
            bytes = &bytes[8..];
        }
        if bytes.len() >= 4 {
            let mut buf = [0u8; 4];
            buf.copy_from_slice(&bytes[..4]);
            self.add(u64::from(u32::from_le_bytes(buf)));
            bytes = &bytes[4..];
        }
        if bytes.len() >= 2 {
            let mut buf = [0u8; 2];
            buf.copy_from_slice(&bytes[..2]);
            self.add(u64::from(u16::from_le_bytes(buf)));
            bytes = &bytes[2..];
        }
        if let Some(&b) = bytes.first() {
            self.add(u64::from(b));
        }
    }

    #[inline]
    fn write_u8(&mut self, i: u8) {
        self.add(u64::from(i));
    }
    #[inline]
    fn write_u16(&mut self, i: u16) {
        self.add(u64::from(i));
    }
    #[inline]
    fn write_u32(&mut self, i: u32) {
        self.add(u64::from(i));
    }
    #[inline]
    fn write_u64(&mut self, i: u64) {
        self.add(i);
    }
    #[inline]
    fn write_usize(&mut self, i: usize) {
        self.add(i as u64);
    }
    #[inline]
    fn finish(&self) -> u64 {
        self.hash
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn basic_map_roundtrips() {
        let mut m: FxHashMap<String, i32> = FxHashMap::default();
        for i in 0..1000 {
            m.insert(format!("key-{i}"), i);
        }
        assert_eq!(m.len(), 1000);
        for i in 0..1000 {
            assert_eq!(m.get(&format!("key-{i}")), Some(&i));
        }
        assert_eq!(m.get("missing"), None);
    }

    #[test]
    fn distinct_keys_mostly_distinct_hashes() {
        // Sanity: the hasher spreads short identifier-like keys (no all-equal).
        let h = |s: &str| {
            let mut hasher = FxHasher::default();
            hasher.write(s.as_bytes());
            hasher.finish()
        };
        assert_ne!(h("color"), h("width"));
        assert_ne!(h("a"), h("b"));
        assert_ne!(h("margin-top"), h("margin-bottom"));
    }
}
