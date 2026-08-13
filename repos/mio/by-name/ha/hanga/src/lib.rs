/// Pure engine logic — no Bevy, no WASM, no I/O.
///
/// All functions here are deterministic and independently testable.
/// The ECS systems in main.rs call these; `cargo test --lib` exercises them.

pub mod bindings;
pub mod figure;
pub mod i18n;
pub mod palette;

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

// ─── Teardown / fracture helpers ──────────────────────────────────────────────

/// A voxel is supported if it sits below the ground plane, or the cell
/// immediately underneath is solid. The engine supplies `below_is_solid`;
/// the predicate is pure so it can be property-tested and Kani-checked.
pub fn voxel_has_support(y: i32, below_is_solid: bool) -> bool {
    y < 0 || below_is_solid
}

/// Chebyshev (chessboard) distance between two voxel cells.
pub fn chebyshev_distance(ax: i32, ay: i32, az: i32, bx: i32, by: i32, bz: i32) -> i32 {
    (ax - bx).abs().max((ay - by).abs()).max((az - bz).abs())
}

/// Offsets in a Chebyshev ball of `spread`, excluding the origin.
/// The engine iterates these after a break and asks the mod what may collapse.
pub fn fracture_offsets(spread: i32) -> Vec<(i32, i32, i32)> {
    let spread = spread.max(0);
    let mut out = Vec::new();
    for x in -spread..=spread {
        for y in -spread..=spread {
            for z in -spread..=spread {
                if x == 0 && y == 0 && z == 0 {
                    continue;
                }
                out.push((x, y, z));
            }
        }
    }
    out
}

/// Pack a voxel catalog index into the 0..=255 material range used by the renderer.
pub fn clamp_voxel_type(voxel_type: i32) -> u8 {
    voxel_type.clamp(0, 255) as u8
}

/// Split a comma-separated name catalog. Empty fragments are dropped.
pub fn parse_name_catalog(csv: &str) -> Vec<String> {
    csv.split(',')
        .map(str::trim)
        .filter(|s| !s.is_empty())
        .map(|s| s.to_string())
        .collect()
}

/// Look up a catalog name by meshing index. Missing index → None.
pub fn catalog_name(catalog: &[String], index: i32) -> Option<&str> {
    catalog.get(index as usize).map(String::as_str)
}

/// Look up a catalog index by English name.
pub fn catalog_index(catalog: &[String], name: &str) -> Option<u8> {
    catalog
        .iter()
        .position(|entry| entry == name)
        .and_then(|i| u8::try_from(i).ok())
}

// ─── Connectivity (Teardown support) ──────────────────────────────────────────

const FACE_NEIGHBORS: [(i32, i32, i32); 6] = [
    (1, 0, 0),
    (-1, 0, 0),
    (0, 1, 0),
    (0, -1, 0),
    (0, 0, 1),
    (0, 0, -1),
];

/// 6-connected flood fill: can `start` walk through solid cells to bedrock (`y < 0`)
/// within `max_hops`? Used so cantilevers stay up if they still touch the ground.
pub fn is_connected_to_ground(
    start: (i32, i32, i32),
    max_hops: u32,
    mut is_solid: impl FnMut(i32, i32, i32) -> bool,
) -> bool {
    if start.1 < 0 {
        return true;
    }
    if !is_solid(start.0, start.1, start.2) {
        return false;
    }
    let mut seen = std::collections::HashSet::new();
    let mut queue = std::collections::VecDeque::new();
    seen.insert(start);
    queue.push_back((start, 0u32));
    while let Some(((x, y, z), hops)) = queue.pop_front() {
        if y < 0 {
            return true;
        }
        if hops >= max_hops {
            continue;
        }
        for (dx, dy, dz) in FACE_NEIGHBORS {
            let n = (x + dx, y + dy, z + dz);
            if !seen.insert(n) {
                continue;
            }
            if n.1 < 0 || is_solid(n.0, n.1, n.2) {
                queue.push_back((n, hops + 1));
            }
        }
    }
    false
}

/// Default Matchbox room. Only used when the player opts into `--p2p` or Multiplayer.
pub const DEFAULT_P2P_URL: &str = "ws://localhost:3536/hanga_room";

/// `Some(url)` if `--p2p` is present. A following non-flag argument overrides the room URL.
pub fn parse_p2p_url(args: &[String]) -> Option<String> {
    let mut i = 0;
    while i < args.len() {
        if args[i] == "--p2p" {
            if i + 1 < args.len() && !args[i + 1].starts_with('-') {
                return Some(args[i + 1].clone());
            }
            return Some(DEFAULT_P2P_URL.to_string());
        }
        i += 1;
    }
    None
}

/// Graphical `nix run` shows a menu. Headless / text / agent / `--play` / `--p2p` skip it.
pub fn should_skip_menu(args: &[String]) -> bool {
    args.iter().any(|a| {
        matches!(
            a.as_str(),
            "--play" | "--skip-menu" | "--headless" | "--text-client" | "--agent-client" | "--p2p"
        )
    })
}

pub const DEFAULT_MOD: &str = "urban_chaos";
pub const SHIPPED_MODS: &[&str] = &["urban_chaos", "testbed"];

/// `--mod urban_chaos` or `--mod /path/to/mod.wasm`. Defaults to Urban Chaos.
pub fn parse_mod_spec(args: &[String]) -> String {
    args.windows(2)
        .find(|w| w[0] == "--mod")
        .map(|w| w[1].clone())
        .unwrap_or_else(|| DEFAULT_MOD.to_string())
}

/// Cycle Urban Chaos <-> Testbed. Unknown specs return the next shipped mod.
pub fn cycle_shipped_mod(current: &str) -> &'static str {
    let idx = SHIPPED_MODS
        .iter()
        .position(|name| *name == current)
        .unwrap_or(0);
    SHIPPED_MODS[(idx + 1) % SHIPPED_MODS.len()]
}

/// i18n key for a shipped gameplay mod. Custom `--mod` paths keep the spec text.
pub fn shipped_mod_label_key(spec: &str) -> Option<&'static str> {
    match spec {
        "urban_chaos" => Some("game_urban_chaos"),
        "testbed" => Some("game_testbed"),
        _ => None,
    }
}

/// Resolve a mod spec to a `.wasm` path. First existing candidate wins.
///
/// Search order: an explicit file, `HANGA_MODS`, next to the binary, `share/hanga/mods`,
/// then Cargo `target/...` and the historical `mods/<name>/target/...` layout.
pub fn resolve_wasm_path(
    spec: &str,
    cwd: &std::path::Path,
    exe_dir: Option<&std::path::Path>,
    env_mods: Option<&std::path::Path>,
) -> std::path::PathBuf {
    use std::path::{Path, PathBuf};

    let direct = Path::new(spec);
    if spec.ends_with(".wasm") || direct.is_file() {
        return if direct.is_absolute() {
            direct.to_path_buf()
        } else {
            cwd.join(direct)
        };
    }

    let file = format!("{spec}.wasm");
    let mut candidates: Vec<PathBuf> = Vec::new();
    if let Some(dir) = env_mods {
        candidates.push(dir.join(&file));
    }
    if let Some(exe) = exe_dir {
        candidates.push(exe.join("mods").join(&file));
        if let Some(root) = exe.parent() {
            candidates.push(root.join("share/hanga/mods").join(&file));
        }
    }
    candidates.push(cwd.join("mods").join(&file));
    for profile in ["release", "debug"] {
        candidates.push(
            cwd.join("target/wasm32-unknown-unknown")
                .join(profile)
                .join(&file),
        );
        candidates.push(
            cwd.join("mods")
                .join(spec)
                .join("target/wasm32-unknown-unknown")
                .join(profile)
                .join(&file),
        );
    }

    for path in &candidates {
        if path.is_file() {
            return path.clone();
        }
    }

    env_mods
        .map(|dir| dir.join(&file))
        .or_else(|| exe_dir.map(|dir| dir.join("mods").join(&file)))
        .unwrap_or_else(|| {
            cwd.join("mods")
                .join(spec)
                .join("target/wasm32-unknown-unknown/debug")
                .join(file)
        })
}

fn fnv_mix(mut h: u64, w: u64) -> u64 {
    h ^= w;
    h.wrapping_mul(0x0000_0100_0000_01B3)
}

fn fingerprint_bytes(mut h: u64, bytes: &[u8]) -> u64 {
    for b in bytes {
        h = fnv_mix(h, *b as u64);
    }
    h
}

/// Stable fingerprint of an optimistic action (for logs / duplicate detection).
pub fn action_fingerprint(kind: &str, x: i32, y: i32, z: i32, extra: &str) -> u64 {
    let mut h = 0xcbf29ce484222325u64;
    h = fingerprint_bytes(h, kind.as_bytes());
    for w in [x as u64, y as u64, z as u64] {
        h = fnv_mix(h, w);
    }
    fingerprint_bytes(h, extra.as_bytes())
}

/// Peers reject an action whose claimed fingerprint does not match the payload.
pub fn verify_action_signature(
    kind: &str,
    x: i32,
    y: i32,
    z: i32,
    extra: &str,
    claimed: u64,
) -> bool {
    action_fingerprint(kind, x, y, z, extra) == claimed
}

pub const INVENTORY_SLOTS: usize = 8;

/// Put `item` into the first matching or empty slot. Returns false if the bag is full.
pub fn inventory_add(items: &mut [String], counts: &mut [u32], item: &str) -> bool {
    if item.is_empty() || items.len() != counts.len() {
        return false;
    }
    for i in 0..items.len() {
        if items[i] == item && counts[i] > 0 && counts[i] < 999 {
            counts[i] += 1;
            return true;
        }
    }
    for i in 0..items.len() {
        if items[i].is_empty() || counts[i] == 0 {
            items[i] = item.to_string();
            counts[i] = 1;
            return true;
        }
    }
    false
}

/// Take one item from `selected`. Clears the slot when the count hits zero.
pub fn inventory_take(items: &mut [String], counts: &mut [u32], selected: usize) -> Option<String> {
    if selected >= items.len() || items.len() != counts.len() {
        return None;
    }
    if items[selected].is_empty() || counts[selected] == 0 {
        return None;
    }
    let id = items[selected].clone();
    counts[selected] -= 1;
    if counts[selected] == 0 {
        items[selected].clear();
    }
    Some(id)
}

pub fn clamp_hotbar_index(index: i32) -> usize {
    index.clamp(0, (INVENTORY_SLOTS as i32) - 1) as usize
}

pub const LOOK_SENSITIVITY: f32 = 0.0025;
pub const LOOK_PITCH_LIMIT: f32 = std::f32::consts::FRAC_PI_2 - 0.02;

/// Integrate mouse delta into yaw/pitch. `dx` right and `dy` down are screen-space.
pub fn apply_mouse_look(yaw: f32, pitch: f32, dx: f32, dy: f32, sensitivity: f32) -> (f32, f32) {
    let yaw = yaw - dx * sensitivity;
    let pitch = (pitch - dy * sensitivity).clamp(-LOOK_PITCH_LIMIT, LOOK_PITCH_LIMIT);
    (yaw, pitch)
}

fn inventory_remove_one(items: &mut [String], counts: &mut [u32], item: &str) -> bool {
    if item.is_empty() || items.len() != counts.len() {
        return false;
    }
    for i in 0..items.len() {
        if items[i] == item && counts[i] > 0 {
            counts[i] -= 1;
            if counts[i] == 0 {
                items[i].clear();
            }
            return true;
        }
    }
    false
}

/// Spend one `a` and one `b` (two of the same if `a == b`) and add `result`.
pub fn inventory_craft_pair(
    items: &mut [String],
    counts: &mut [u32],
    a: &str,
    b: &str,
    result: &str,
) -> bool {
    if items.len() != counts.len() || result.is_empty() || a.is_empty() || b.is_empty() {
        return false;
    }
    let mut next_items = items.to_vec();
    let mut next_counts = counts.to_vec();
    if !inventory_remove_one(&mut next_items, &mut next_counts, a) {
        return false;
    }
    if !inventory_remove_one(&mut next_items, &mut next_counts, b) {
        return false;
    }
    if !inventory_add(&mut next_items, &mut next_counts, result) {
        return false;
    }
    items.clone_from_slice(&next_items);
    counts.copy_from_slice(&next_counts);
    true
}

/// Item currently selected on the hotbar, if the slot is occupied.
pub fn inventory_selected<'a>(
    items: &'a [String],
    counts: &[u32],
    selected: usize,
) -> Option<&'a str> {
    if selected >= items.len() || items.len() != counts.len() {
        return None;
    }
    if !items[selected].is_empty() && counts[selected] > 0 {
        Some(items[selected].as_str())
    } else {
        None
    }
}

/// Wallet / score integer owned by the mod; engine only clamps to a safe range.
pub fn clamp_wallet(value: i32) -> i32 {
    value.clamp(0, 1_000_000)
}

/// A contract offer is live when the mod returns a non-empty kind name.
pub fn contract_is_offered(kind: &str) -> bool {
    !kind.is_empty()
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

    // ── voxel_has_support / fracture_offsets ──────────────────────────────────

    #[test]
    fn bedrock_is_always_supported() {
        assert!(voxel_has_support(-1, false));
        assert!(voxel_has_support(-100, false));
    }

    #[test]
    fn surface_unsupported_without_solid_below() {
        assert!(!voxel_has_support(0, false));
        assert!(!voxel_has_support(12, false));
    }

    #[test]
    fn surface_supported_with_solid_below() {
        assert!(voxel_has_support(0, true));
        assert!(voxel_has_support(12, true));
    }

    #[test]
    fn fracture_offsets_excludes_origin() {
        let offsets = fracture_offsets(1);
        assert!(!offsets.contains(&(0, 0, 0)));
        assert_eq!(offsets.len(), 26); // 3^3 - 1
    }

    #[test]
    fn fracture_offsets_zero_spread_is_empty() {
        assert!(fracture_offsets(0).is_empty());
        assert!(fracture_offsets(-3).is_empty());
    }

    #[test]
    fn chebyshev_distance_matches_spread_membership() {
        for &(a, b, c) in &[(1, 0, 0), (2, 2, 2), (0, -4, 1)] {
            let d = chebyshev_distance(0, 0, 0, a, b, c);
            let inside = fracture_offsets(d).contains(&(a, b, c));
            assert!(inside, "offset ({a},{b},{c}) must be in spread {d}");
        }
    }

    #[test]
    fn clamp_voxel_type_bounds() {
        assert_eq!(clamp_voxel_type(-1), 0);
        assert_eq!(clamp_voxel_type(3), 3);
        assert_eq!(clamp_voxel_type(300), 255);
    }

    #[test]
    fn name_catalog_maps_english_ids() {
        let catalog = parse_name_catalog("air, concrete, glass,");
        assert_eq!(catalog, ["air", "concrete", "glass"]);
        assert_eq!(catalog_name(&catalog, 1), Some("concrete"));
        assert_eq!(catalog_index(&catalog, "glass"), Some(2));
        assert_eq!(catalog_index(&catalog, "rail"), None);
        assert!(parse_name_catalog("  ").is_empty());
    }

    // ── is_connected_to_ground ────────────────────────────────────────────────

    #[test]
    fn bedrock_cell_is_grounded() {
        assert!(is_connected_to_ground((0, -1, 0), 4, |_, _, _| false));
    }

    #[test]
    fn air_is_not_grounded() {
        assert!(!is_connected_to_ground((0, 3, 0), 8, |_, _, _| false));
    }

    #[test]
    fn column_standing_on_bedrock_is_grounded() {
        let solid = |x: i32, y: i32, z: i32| x == 0 && z == 0 && (0..=3).contains(&y);
        assert!(is_connected_to_ground((0, 3, 0), 8, solid));
    }

    #[test]
    fn floating_block_is_not_grounded() {
        let solid = |x: i32, y: i32, z: i32| x == 0 && z == 0 && (2..=4).contains(&y);
        assert!(!is_connected_to_ground((0, 3, 0), 8, solid));
    }

    #[test]
    fn cantilever_connected_sideways_stays_up() {
        // A 1-wide arm at y=1 attached to a pillar on bedrock at x=0.
        let solid = |x: i32, y: i32, z: i32| {
            z == 0 && ((x == 0 && (0..=2).contains(&y)) || (x == 1 && y == 1) || (x == 2 && y == 1))
        };
        assert!(is_connected_to_ground((2, 1, 0), 8, solid));
    }

    #[test]
    fn hop_limit_prevents_infinite_search() {
        let solid = |_x: i32, y: i32, _z: i32| y >= 0;
        assert!(!is_connected_to_ground((0, 5, 0), 2, solid));
    }

    #[test]
    fn action_fingerprint_is_stable_and_sensitive() {
        let a = action_fingerprint("break", 4, 5, 6, "");
        let b = action_fingerprint("break", 4, 5, 6, "");
        let c = action_fingerprint("break", 4, 5, 7, "");
        assert_eq!(a, b);
        assert_ne!(a, c);
        assert_ne!(
            action_fingerprint("place", 4, 5, 6, "concrete"),
            action_fingerprint("place", 4, 5, 6, "glass")
        );
    }

    #[test]
    fn matching_fingerprint_is_accepted() {
        let fp = action_fingerprint("complete_contract", 10, 0, 0, "400");
        assert!(verify_action_signature("complete_contract", 10, 0, 0, "400", fp));
    }

    #[test]
    fn tampered_fingerprint_is_rejected() {
        let fp = action_fingerprint("break", 2, 3, 4, "");
        assert!(!verify_action_signature("break", 2, 3, 4, "", fp.wrapping_add(1)));
        assert!(!verify_action_signature("break", 2, 3, 5, "", fp));
    }

    #[test]
    fn wallet_clamp_rejects_overflow_and_debt() {
        assert_eq!(clamp_wallet(250), 250);
        assert_eq!(clamp_wallet(-80), 0);
        assert_eq!(clamp_wallet(i32::MAX), 1_000_000);
    }

    #[test]
    fn contract_kind_empty_is_not_an_offer() {
        assert!(!contract_is_offered(""));
        assert!(contract_is_offered("smash-and-grab"));
        assert!(contract_is_offered("armored-truck"));
    }

    fn empty_bag() -> ([String; INVENTORY_SLOTS], [u32; INVENTORY_SLOTS]) {
        (std::array::from_fn(|_| String::new()), [0u32; INVENTORY_SLOTS])
    }

    #[test]
    fn inventory_stacks_then_opens_a_new_slot() {
        let (mut items, mut counts) = empty_bag();
        assert!(inventory_add(&mut items, &mut counts, "glass"));
        assert!(inventory_add(&mut items, &mut counts, "glass"));
        assert_eq!((items[0].as_str(), counts[0]), ("glass", 2));
        assert!(inventory_add(&mut items, &mut counts, "concrete"));
        assert_eq!((items[1].as_str(), counts[1]), ("concrete", 1));
        assert_eq!(inventory_take(&mut items, &mut counts, 0).as_deref(), Some("glass"));
        assert_eq!(counts[0], 1);
        assert_eq!(inventory_take(&mut items, &mut counts, 0).as_deref(), Some("glass"));
        assert!(items[0].is_empty());
        assert_eq!(inventory_take(&mut items, &mut counts, 0), None);
    }

    #[test]
    fn hotbar_index_stays_in_range() {
        assert_eq!(clamp_hotbar_index(-2), 0);
        assert_eq!(clamp_hotbar_index(3), 3);
        assert_eq!(clamp_hotbar_index(99), 7);
        let mut items: [String; INVENTORY_SLOTS] = std::array::from_fn(|_| String::new());
        items[0] = "glass".into();
        let counts = [2, 0, 0, 0, 0, 0, 0, 0];
        assert_eq!(inventory_selected(&items, &counts, 0), Some("glass"));
        assert_eq!(inventory_selected(&items, &counts, 1), None);
    }

    #[test]
    fn mouse_look_yaws_left_and_clamps_pitch() {
        let (yaw, _pitch) = apply_mouse_look(0.0, 0.0, 10.0, 0.0, 0.01);
        assert!(yaw < 0.0, "mouse right turns clockwise / look left in YXZ");
        let (_, up) = apply_mouse_look(0.0, 0.0, 0.0, -4000.0, 0.01);
        assert!((up - LOOK_PITCH_LIMIT).abs() < 1e-5);
        let (_, down) = apply_mouse_look(0.0, 0.0, 0.0, 4000.0, 0.01);
        assert!((down + LOOK_PITCH_LIMIT).abs() < 1e-5);
    }

    #[test]
    fn craft_spends_two_and_gives_the_product() {
        let (mut items, mut counts) = empty_bag();
        items[0] = "concrete".into();
        counts[0] = 2;
        assert!(inventory_craft_pair(
            &mut items,
            &mut counts,
            "concrete",
            "concrete",
            "sidewalk"
        ));
        assert_eq!((items[0].as_str(), counts[0]), ("sidewalk", 1));
        assert!(!inventory_craft_pair(
            &mut items,
            &mut counts,
            "concrete",
            "concrete",
            "sidewalk"
        ));
        items[0] = "concrete".into();
        counts[0] = 1;
        items[1] = "glass".into();
        counts[1] = 1;
        assert!(inventory_craft_pair(
            &mut items,
            &mut counts,
            "concrete",
            "glass",
            "glass"
        ));
        assert_eq!(inventory_selected(&items, &counts, 0), Some("glass"));
        assert_eq!(counts.iter().sum::<u32>(), 1);
    }

    #[test]
    fn p2p_flag_is_opt_in() {
        assert_eq!(parse_p2p_url(&["hanga".into()]), None);
        assert_eq!(
            parse_p2p_url(&["hanga".into(), "--p2p".into()]),
            Some(DEFAULT_P2P_URL.into())
        );
        assert_eq!(
            parse_p2p_url(&["hanga".into(), "--p2p".into(), "ws://host/room".into()]),
            Some("ws://host/room".into())
        );
        assert!(!should_skip_menu(&["hanga".into()]));
        assert!(should_skip_menu(&["hanga".into(), "--play".into()]));
        assert!(should_skip_menu(&["hanga".into(), "--p2p".into()]));
        assert!(should_skip_menu(&["hanga".into(), "--headless".into()]));
    }

    #[test]
    fn mod_spec_defaults_to_urban_chaos() {
        assert_eq!(parse_mod_spec(&["hanga".into()]), DEFAULT_MOD);
        assert_eq!(
            parse_mod_spec(&["hanga".into(), "--mod".into(), "testbed".into()]),
            "testbed"
        );
    }

    #[test]
    fn shipped_mods_cycle_urban_chaos_and_testbed() {
        assert_eq!(cycle_shipped_mod("urban_chaos"), "testbed");
        assert_eq!(cycle_shipped_mod("testbed"), "urban_chaos");
        assert_eq!(cycle_shipped_mod("custom.wasm"), "testbed");
        assert_eq!(shipped_mod_label_key("testbed"), Some("game_testbed"));
        assert_eq!(shipped_mod_label_key("/tmp/x.wasm"), None);
    }

    #[test]
    fn wasm_path_prefers_env_mods_then_explicit_file() {
        use std::fs;

        let root = std::env::temp_dir().join(format!("hanga-wasm-{}", std::process::id()));
        let mods = root.join("installed");
        let cwd = root.join("cwd");
        fs::create_dir_all(&mods).unwrap();
        fs::create_dir_all(&cwd).unwrap();
        let installed = mods.join("urban_chaos.wasm");
        fs::write(&installed, b"\0asm").unwrap();
        let found = resolve_wasm_path("urban_chaos", &cwd, None, Some(&mods));
        assert_eq!(found, installed);

        let explicit = cwd.join("custom.wasm");
        fs::write(&explicit, b"\0asm").unwrap();
        let by_file = resolve_wasm_path(explicit.to_str().unwrap(), &cwd, None, Some(&mods));
        assert_eq!(by_file, explicit);

        let missing = resolve_wasm_path("testbed", &cwd, None, Some(&mods));
        assert_eq!(missing, mods.join("testbed.wasm"));
        let _ = fs::remove_dir_all(&root);
    }
}

#[cfg(kani)]
mod kani_verification {
    use super::*;

    #[kani::proof]
    fn verify_signature_roundtrip() {
        let kind: u8 = kani::any();
        let x: i32 = kani::any();
        let y: i32 = kani::any();
        let z: i32 = kani::any();
        let extra: u8 = kani::any();
        let kind_name = match kind % 4 {
            0 => "break",
            1 => "place",
            2 => "explode",
            _ => "craft",
        };
        let extra_name = match extra % 3 {
            0 => "",
            1 => "concrete",
            _ => "glass",
        };
        let fp = action_fingerprint(kind_name, x, y, z, extra_name);
        kani::assert(
            verify_action_signature(kind_name, x, y, z, extra_name, fp),
            "fingerprint must verify against its own payload",
        );
    }

    #[kani::proof]
    fn verify_wallet_clamp_is_non_negative() {
        let value: i32 = kani::any();
        let clamped = clamp_wallet(value);
        kani::assert(clamped >= 0 && clamped <= 1_000_000, "wallet clamp bounds");
    }
}
