mod support;

use support::Agent;

#[test]
fn test_headless_agent_simulation() {
    let mut agent = Agent::new("urban_chaos", true);
    let observation = agent.wait_for(|reply| reply["world_ready"] == true);
    assert_eq!(observation["trust_score"], 1.0);
    assert_eq!(observation["wanted_level"], 0);
}

#[test]
fn test_pure_engine_headless_subsystems() {
    use hanga::TrustLedger;
    use hanga::is_action_physically_possible;
    let mut ledger = TrustLedger::default();
    assert!(ledger.is_trusted(1));
    assert_eq!(ledger.score(1), 1.0);
    ledger.penalize(1, 0.4);
    assert!((ledger.score(1) - 0.6).abs() < 1e-5);
    ledger.penalize(1, 0.8);
    assert!(!ledger.is_trusted(1));
    assert!(is_action_physically_possible(
        0.0, 0.0, 0.0, 3.0, 4.0, 0.0, 6.0
    ));
    assert!(!is_action_physically_possible(
        0.0, 0.0, 0.0, 10.0, 0.0, 0.0, 5.0
    ));
}

#[test]
fn test_pure_engine_inventory_and_crafting() {
    use hanga::{inventory_add, inventory_take, inventory_craft_pair, INVENTORY_SLOTS};
    let mut items = vec![String::new(); INVENTORY_SLOTS];
    let mut counts = vec![0u32; INVENTORY_SLOTS];

    // Add concrete and glass
    assert!(inventory_add(&mut items, &mut counts, "concrete"));
    assert!(inventory_add(&mut items, &mut counts, "glass"));
    assert_eq!(items[0], "concrete");
    assert_eq!(counts[0], 1);
    assert_eq!(items[1], "glass");
    assert_eq!(counts[1], 1);

    // Craft them into platform
    assert!(inventory_craft_pair(&mut items, &mut counts, "concrete", "glass", "platform"));
    assert_eq!(counts[0], 0);
    assert_eq!(counts[1], 0);
    // Platform was inserted
    assert_eq!(items[2], "platform");
    assert_eq!(counts[2], 1);

    // Taking platform
    assert_eq!(inventory_take(&mut items, &mut counts, "platform"), Some(2));
    assert_eq!(counts[2], 0);
}

#[test]
fn test_pure_engine_voxel_overlay_and_ground_support() {
    use hanga::{overlay_set, overlay_get, take_voxel_writes, is_connected_to_ground, VoxelOverlay};
    let mut overlay = VoxelOverlay::default();
    overlay_set(&mut overlay, 10, 20, 30, "workbench");
    assert_eq!(overlay_get(&overlay, 10, 20, 30), Some("workbench"));

    let writes = take_voxel_writes(&mut overlay);
    assert_eq!(writes.len(), 1);
    assert_eq!(writes[0], (10, 20, 30, "workbench".to_string()));
    assert_eq!(overlay_get(&overlay, 10, 20, 30), None);

    // Bedrock and column ground support
    assert!(is_connected_to_ground(0, 0, 0, |_| true));
    assert!(!is_connected_to_ground(0, 5, 0, |_| false));
}

#[test]
fn test_pure_engine_economy_and_fingerprints() {
    use hanga::{pack_economy_params, unpack_economy_params, action_fingerprint, verify_action_signature};
    let packed = pack_economy_params(1234, 5678);
    let (s, d) = unpack_economy_params(packed);
    assert_eq!(s, 1234);
    assert_eq!(d, 5678);

    let fp = action_fingerprint("break", 10, 20, 30, "");
    assert!(verify_action_signature("break", 10, 20, 30, "", fp));
    assert!(!verify_action_signature("place", 10, 20, 30, "", fp));
    assert!(!verify_action_signature("break", 11, 20, 30, "", fp));
}
