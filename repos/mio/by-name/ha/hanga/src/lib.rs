/// Pure engine logic — no Bevy, no WASM, no I/O.
///
/// All functions here are deterministic and independently testable.
/// The ECS systems in main.rs call these; `cargo test --lib` exercises them.

// ─── Anti-cheat / Trust ──────────────────────────────────────────────────────

/// Tracks P2P peer trust scores keyed by a raw u64 peer id.
/// Starts at 1.0; drops on suspected cheating; negative = banned.
#[derive(Default)]
pub struct TrustLedger {
    pub peer_scores: std::collections::HashMap<u64, f32>,
}

impl TrustLedger {
    /// Penalise a peer, reducing its trust score.
    pub fn penalize(&mut self, peer: u64, penalty: f32) {
        let score = self.peer_scores.entry(peer).or_insert(1.0);
        *score -= penalty;
    }

    /// Returns `true` if the peer is still considered trustworthy (score >= 0).
    pub fn is_trusted(&self, peer: u64) -> bool {
        self.peer_scores.get(&peer).copied().unwrap_or(1.0) >= 0.0
    }

    /// Returns the current trust score for a peer (default 1.0).
    pub fn score(&self, peer: u64) -> f32 {
        self.peer_scores.get(&peer).copied().unwrap_or(1.0)
    }
}

// ─── Anti-cheat geometry ──────────────────────────────────────────────────────

/// Returns `true` if the Euclidean distance between the player (px,py,pz) and
/// target (tx,ty,tz) is within `max_dist`.
///
/// This is the core anti-cheat predicate. It is a pure function so it can be
/// formally verified by Kani and property-tested by proptest.
pub fn is_action_physically_possible(
    px: f32, py: f32, pz: f32,
    tx: f32, ty: f32, tz: f32,
    max_dist: f32,
) -> bool {
    let dx = px - tx;
    let dy = py - ty;
    let dz = pz - tz;
    dx * dx + dy * dy + dz * dz <= max_dist * max_dist
}

// ─── Economy helpers ──────────────────────────────────────────────────────────

/// Unpack the economy params packed integer returned by the WASM mod.
/// Contract: high 16 bits = supply, low 16 bits = demand.
pub fn unpack_economy_params(packed: i32) -> (i32, i32) {
    ((packed >> 16) & 0xFFFF, packed & 0xFFFF)
}

/// Pack supply/demand into a single i32 for WASM return values.
pub fn pack_economy_params(supply: i32, demand: i32) -> i32 {
    ((supply & 0xFFFF) << 16) | (demand & 0xFFFF)
}

// ─── ModState helpers ─────────────────────────────────────────────────────────

/// Clamp a raw mod-state value returned from WASM into a safe range.
pub fn clamp_mod_state(value: i32, min: i32, max: i32) -> i32 {
    value.clamp(min, max)
}

// ─── Tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    // ── TrustLedger ───────────────────────────────────────────────────────────

    #[test]
    fn trust_starts_at_full() {
        let ledger = TrustLedger::default();
        assert!(ledger.is_trusted(42));
        assert!((ledger.score(42) - 1.0).abs() < 1e-6);
    }

    #[test]
    fn penalize_reduces_score() {
        let mut ledger = TrustLedger::default();
        ledger.penalize(1, 0.3);
        assert!((ledger.score(1) - 0.7).abs() < 1e-5, "expected 0.7, got {}", ledger.score(1));
    }

    #[test]
    fn penalize_accumulates_across_calls() {
        let mut ledger = TrustLedger::default();
        ledger.penalize(2, 0.4);
        ledger.penalize(2, 0.4);
        // 1.0 - 0.4 - 0.4 = 0.2
        assert!((ledger.score(2) - 0.2).abs() < 1e-5);
    }

    #[test]
    fn penalize_below_zero_marks_untrusted() {
        let mut ledger = TrustLedger::default();
        ledger.penalize(3, 0.6);
        ledger.penalize(3, 0.6); // 1.0 - 1.2 = -0.2
        assert!(!ledger.is_trusted(3));
    }

    #[test]
    fn full_penalty_leaves_score_at_zero_still_trusted() {
        let mut ledger = TrustLedger::default();
        ledger.penalize(4, 1.0);
        assert!((ledger.score(4) - 0.0).abs() < 1e-6);
        assert!(ledger.is_trusted(4)); // exactly 0.0 is still on the boundary
    }

    #[test]
    fn unknown_peer_is_trusted_by_default() {
        let ledger = TrustLedger::default();
        assert!(ledger.is_trusted(9999));
        assert!((ledger.score(9999) - 1.0).abs() < 1e-6);
    }

    #[test]
    fn multiple_peers_are_independent() {
        let mut ledger = TrustLedger::default();
        ledger.penalize(10, 0.5);
        // peer 11 should be unaffected
        assert!((ledger.score(10) - 0.5).abs() < 1e-5);
        assert!((ledger.score(11) - 1.0).abs() < 1e-6);
    }

    // ── is_action_physically_possible ────────────────────────────────────────

    #[test]
    fn action_at_same_position_is_possible() {
        assert!(is_action_physically_possible(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0));
    }

    #[test]
    fn action_just_within_range_is_possible() {
        assert!(is_action_physically_possible(0.0, 0.0, 0.0, 9.9, 0.0, 0.0, 10.0));
    }

    #[test]
    fn action_exactly_at_range_boundary_is_possible() {
        assert!(is_action_physically_possible(0.0, 0.0, 0.0, 10.0, 0.0, 0.0, 10.0));
    }

    #[test]
    fn action_beyond_range_is_impossible() {
        assert!(!is_action_physically_possible(0.0, 0.0, 0.0, 10.1, 0.0, 0.0, 10.0));
    }

    #[test]
    fn action_negative_direction_is_symmetric() {
        assert!(is_action_physically_possible(0.0, 0.0, 0.0, -9.9, 0.0, 0.0, 10.0));
        assert!(!is_action_physically_possible(0.0, 0.0, 0.0, -10.1, 0.0, 0.0, 10.0));
    }

    #[test]
    fn action_diagonal_within_range() {
        // sqrt(3^2+3^2+3^2) = sqrt(27) ≈ 5.196 < 10
        assert!(is_action_physically_possible(0.0, 0.0, 0.0, 3.0, 3.0, 3.0, 10.0));
    }

    #[test]
    fn action_diagonal_outside_range() {
        // sqrt(7^2+7^2+7^2) = sqrt(147) ≈ 12.12 > 10
        assert!(!is_action_physically_possible(0.0, 0.0, 0.0, 7.0, 7.0, 7.0, 10.0));
    }

    #[test]
    fn anticheat_invariant_no_axis_exceeds_range_when_possible() {
        // CRITICAL PROPERTY: if action is physically possible, no individual axis
        // can exceed the max range. Violating this would allow fraudulent packets.
        let cases: &[(f32, f32, f32, f32, f32, f32, f32)] = &[
            (0.0, 0.0, 0.0, 5.0, 0.0, 0.0, 10.0),
            (100.0, 50.0, 200.0, 107.0, 50.0, 200.0, 10.0),
            (-5.0, 0.0, 0.0, 5.0, 0.0, 0.0, 10.1),
            (0.0, 0.0, 0.0, 3.0, 3.0, 3.0, 10.0),
        ];
        for &(px, py, pz, tx, ty, tz, range) in cases {
            if is_action_physically_possible(px, py, pz, tx, ty, tz, range) {
                assert!((px - tx).abs() <= range);
                assert!((py - ty).abs() <= range);
                assert!((pz - tz).abs() <= range);
            }
        }
    }

    // ── Economy pack/unpack ───────────────────────────────────────────────────

    #[test]
    fn pack_unpack_roundtrip() {
        let packed = pack_economy_params(5, 8);
        let (s, d) = unpack_economy_params(packed);
        assert_eq!(s, 5);
        assert_eq!(d, 8);
    }

    #[test]
    fn pack_unpack_zero() {
        let (s, d) = unpack_economy_params(pack_economy_params(0, 0));
        assert_eq!(s, 0);
        assert_eq!(d, 0);
    }

    #[test]
    fn pack_unpack_max_16bit() {
        let (s, d) = unpack_economy_params(pack_economy_params(0xFFFF, 0xFFFF));
        assert_eq!(s, 0xFFFF);
        assert_eq!(d, 0xFFFF);
    }

    #[test]
    fn pack_unpack_known_value() {
        // (5 << 16) | 8 = 327688 — this is what urban_chaos WASM returns
        let packed = (5 << 16) | 8;
        let (s, d) = unpack_economy_params(packed);
        assert_eq!(s, 5);
        assert_eq!(d, 8);
    }

    // ── clamp_mod_state ───────────────────────────────────────────────────────

    #[test]
    fn clamp_mod_state_within_range() {
        assert_eq!(clamp_mod_state(3, 0, 5), 3);
    }

    #[test]
    fn clamp_mod_state_at_min_boundary() {
        assert_eq!(clamp_mod_state(0, 0, 5), 0);
    }

    #[test]
    fn clamp_mod_state_at_max_boundary() {
        assert_eq!(clamp_mod_state(5, 0, 5), 5);
    }

    #[test]
    fn clamp_mod_state_above_max() {
        assert_eq!(clamp_mod_state(99, 0, 5), 5);
    }

    #[test]
    fn clamp_mod_state_below_min() {
        assert_eq!(clamp_mod_state(-10, 0, 5), 0);
    }

    #[test]
    fn clamp_mod_state_wasm_wantedlevel_overflow() {
        // A WASM mod returning 6 for a 0-5 wanted level must be clamped.
        assert_eq!(clamp_mod_state(6, 0, 5), 5, "WASM overflow must be clamped");
        assert_eq!(clamp_mod_state(i32::MAX, 0, 5), 5);
        assert_eq!(clamp_mod_state(i32::MIN, 0, 5), 0);
    }
}
