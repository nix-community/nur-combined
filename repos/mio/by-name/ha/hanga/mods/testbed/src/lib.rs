//! Hanga Testbed — a debug game that exercises the engine without Urban Chaos rules.
//!
//! Infinite checkerboard floor, no wanted level, no cops, no economy spikes.
//! Used to verify the WASM bridge and Teardown debris independently of city gen.

wit_bindgen::generate!({ world: "plugin", path: "../../wit" });

include!("../../locale.rs");

struct TestbedMod;

pub fn query_voxel(x: i32, y: i32, z: i32) -> i32 {
    if y < 0 {
        return 1;
    }
    if y == 0 {
        // Checkerboard: even cells concrete, odd cells glass so we can see materials.
        return if (x.wrapping_add(z) & 1) == 0 { 1 } else { 3 };
    }
    0
}

pub fn mod_evaluate_action(_action_type: i32, current_state: i32) -> i32 {
    current_state // no wanted level in the testbed
}

pub fn mod_should_spawn_agent(_action_type: i32, _old_state: i32, _new_state: i32) -> i32 {
    0
}

pub fn compute_agent_vx(_ai_type: i32, _cx: f32, _cz: f32, _px: f32, _pz: f32) -> f32 {
    0.0
}

pub fn compute_agent_vz(_ai_type: i32, _cx: f32, _cz: f32, _px: f32, _pz: f32) -> f32 {
    0.0
}

pub fn compute_economy_price(base_price: i32, supply: i32, demand: i32) -> i32 {
    if supply == 0 {
        return base_price;
    }
    (base_price * demand / supply).max(1)
}

pub fn mod_get_action_range(_action_type: i32) -> f32 {
    20.0
}

pub fn compute_traffic_vx(_forward_x: f32, _forward_z: f32, _blocked: bool) -> f32 {
    0.0
}

pub fn compute_traffic_vz(_forward_x: f32, _forward_z: f32, _blocked: bool) -> f32 {
    0.0
}

pub fn mod_get_storyteller_level() -> i32 {
    0
}

pub fn mod_get_economy_params() -> i32 {
    (1 << 16) | 1
}

pub fn generate_story_event(_player_level: i32) -> i32 {
    0
}

pub fn player_spawn() -> (i32, i32, i32) {
    (0, 4, 0)
}

pub fn vehicle_spawn_count() -> i32 {
    1
}

pub fn vehicle_spawn(_index: i32) -> (i32, i32, i32) {
    (4, 2, 0)
}

pub fn can_fracture(voxel_type: i32) -> i32 {
    if voxel_type > 0 { 1 } else { 0 }
}

pub fn fracture_spread(_voxel_type: i32) -> i32 {
    1
}

pub fn debris_impulse(_action_type: i32) -> f32 {
    8.0
}

pub fn mod_tick(current_state: i32, _dt_ms: i32) -> i32 {
    current_state
}

pub fn should_despawn_agent(_agent_type: i32, _current_state: i32) -> i32 {
    0
}

pub fn ambient_agent_count() -> i32 {
    0
}

pub fn ambient_agent_spawn(_index: i32) -> (i32, i32, i32, i32) {
    (0, 2, 0, 2)
}

pub fn voxel_label(voxel_type: i32) -> String {
    voxel_label_for("en", voxel_type)
}

pub fn voxel_label_for(locale: &str, voxel_type: i32) -> String {
    let lang = locale_id(locale);
    match (lang, voxel_type) {
        (1, 0) => "hau",
        (1, 1) => "raima",
        (1, 3) => "karaihe",
        (1, _) => "tē mōhiotia",
        (2, 0) => "air",
        (2, 1) => "béton",
        (2, 3) => "verre",
        (2, _) => "inconnu",
        (3, 0) => "空氣",
        (3, 1) => "混凝土",
        (3, 3) => "玻璃",
        (3, _) => "未知",
        (_, 0) => "air",
        (_, 1) => "concrete",
        (_, 3) => "glass",
        _ => "unknown",
    }
    .into()
}

pub fn mod_wallet_after(_action_type: i32, current_wallet: i32, _extra: i32) -> i32 {
    current_wallet
}

pub fn mod_offer_contract(_player_state: i32) -> (i32, i32, i32) {
    (0, 0, 0)
}

pub fn mod_can_complete(
    _action_type: i32,
    _player_state: i32,
    _contract_kind: i32,
    _contract_danger: i32,
) -> i32 {
    0
}

pub fn event_label(_event_id: i32) -> String {
    event_label_for("en", 0)
}

pub fn event_label_for(locale: &str, _event_id: i32) -> String {
    match locale_id(locale) {
        1 => "korekore",
        2 => "vide",
        3 => "虛空",
        _ => "void",
    }
    .into()
}

pub fn contract_label_for(_locale: &str, _kind: i32) -> String {
    String::new()
}

pub fn loot_item(voxel_type: i32) -> i32 {
    match voxel_type {
        1 | 3 => voxel_type,
        _ => 0,
    }
}

pub fn item_label_for(locale: &str, item_id: i32) -> String {
    if item_id <= 0 {
        return String::new();
    }
    voxel_label_for(locale, item_id)
}

impl exports::hanga::engine::gameplay::Guest for TestbedMod {
    fn init_mod() {}
    fn query_voxel(x: i32, y: i32, z: i32) -> i32 {
        crate::query_voxel(x, y, z)
    }
    fn mod_evaluate_action(action_type: i32, current_state: i32) -> i32 {
        crate::mod_evaluate_action(action_type, current_state)
    }
    fn mod_should_spawn_agent(a: i32, o: i32, n: i32) -> i32 {
        crate::mod_should_spawn_agent(a, o, n)
    }
    fn compute_agent_vx(t: i32, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
        crate::compute_agent_vx(t, cx, cz, px, pz)
    }
    fn compute_agent_vz(t: i32, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
        crate::compute_agent_vz(t, cx, cz, px, pz)
    }
    fn compute_economy_price(b: i32, s: i32, d: i32) -> i32 {
        crate::compute_economy_price(b, s, d)
    }
    fn mod_get_action_range(a: i32) -> f32 {
        crate::mod_get_action_range(a)
    }
    fn compute_traffic_vx(x: f32, z: f32, blocked: bool) -> f32 {
        crate::compute_traffic_vx(x, z, blocked)
    }
    fn compute_traffic_vz(x: f32, z: f32, blocked: bool) -> f32 {
        crate::compute_traffic_vz(x, z, blocked)
    }
    fn mod_get_storyteller_level() -> i32 {
        crate::mod_get_storyteller_level()
    }
    fn mod_get_economy_params() -> i32 {
        crate::mod_get_economy_params()
    }
    fn generate_story_event(level: i32) -> i32 {
        crate::generate_story_event(level)
    }
    fn player_spawn() -> (i32, i32, i32) {
        crate::player_spawn()
    }
    fn vehicle_spawn_count() -> i32 {
        crate::vehicle_spawn_count()
    }
    fn vehicle_spawn(index: i32) -> (i32, i32, i32) {
        crate::vehicle_spawn(index)
    }
    fn can_fracture(voxel_type: i32) -> i32 {
        crate::can_fracture(voxel_type)
    }
    fn fracture_spread(voxel_type: i32) -> i32 {
        crate::fracture_spread(voxel_type)
    }
    fn debris_impulse(action_type: i32) -> f32 {
        crate::debris_impulse(action_type)
    }
    fn mod_tick(current_state: i32, dt_ms: i32) -> i32 {
        crate::mod_tick(current_state, dt_ms)
    }
    fn should_despawn_agent(agent_type: i32, current_state: i32) -> i32 {
        crate::should_despawn_agent(agent_type, current_state)
    }
    fn ambient_agent_count() -> i32 {
        crate::ambient_agent_count()
    }
    fn ambient_agent_spawn(index: i32) -> (i32, i32, i32, i32) {
        crate::ambient_agent_spawn(index)
    }
    fn voxel_label(voxel_type: i32, locale: String) -> String {
        crate::voxel_label_for(&locale, voxel_type)
    }
    fn mod_wallet_after(action_type: i32, current_wallet: i32, extra: i32) -> i32 {
        crate::mod_wallet_after(action_type, current_wallet, extra)
    }
    fn mod_offer_contract(player_state: i32) -> (i32, i32, i32) {
        crate::mod_offer_contract(player_state)
    }
    fn mod_can_complete(
        action_type: i32,
        player_state: i32,
        contract_kind: i32,
        contract_danger: i32,
    ) -> i32 {
        crate::mod_can_complete(action_type, player_state, contract_kind, contract_danger)
    }
    fn event_label(event_id: i32, locale: String) -> String {
        crate::event_label_for(&locale, event_id)
    }
    fn contract_label(kind: i32, locale: String) -> String {
        crate::contract_label_for(&locale, kind)
    }
    fn supported_locales() -> String {
        crate::supported_locales()
    }

    fn loot_item(voxel_type: i32) -> i32 {
        crate::loot_item(voxel_type)
    }

    fn item_label(item_id: i32, locale: String) -> String {
        crate::item_label_for(&locale, item_id)
    }
}

export!(TestbedMod);

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn floor_is_checkerboard() {
        assert_eq!(query_voxel(0, 0, 0), 1);
        assert_eq!(query_voxel(1, 0, 0), 3);
        assert_eq!(query_voxel(0, 1, 0), 0);
        assert!(query_voxel(0, -1, 0) > 0);
    }

    #[test]
    fn no_wanted_level_and_no_cops() {
        assert_eq!(mod_evaluate_action(4, 0), 0);
        assert_eq!(mod_should_spawn_agent(4, 0, 0), 0);
    }

    #[test]
    fn everything_solid_can_fracture() {
        assert_eq!(can_fracture(1), 1);
        assert_eq!(can_fracture(3), 1);
        assert_eq!(can_fracture(0), 0);
    }

    #[test]
    fn spawn_is_above_floor() {
        let (_x, y, _z) = player_spawn();
        assert!(y > 0);
    }

    #[test]
    fn testbed_has_no_ambient_or_decay() {
        assert_eq!(ambient_agent_count(), 0);
        assert_eq!(mod_tick(3, 8000), 3);
        assert_eq!(voxel_label(0), "air");
    }

    #[test]
    fn testbed_has_no_heists_or_wallet() {
        assert_eq!(mod_offer_contract(5), (0, 0, 0));
        assert_eq!(mod_wallet_after(6, 99, 1200), 99);
        assert_eq!(mod_can_complete(5, 0, 1, 1), 0);
        assert_eq!(event_label(2), "void");
    }

    #[test]
    fn testbed_labels_follow_locale() {
        assert_eq!(voxel_label_for("mi", 0), "hau");
        assert_eq!(voxel_label_for("fr", 3), "verre");
        assert_eq!(voxel_label_for("zh-TW", 1), "混凝土");
        assert_eq!(event_label_for("zh-TW", 0), "虛空");
        assert_eq!(event_label_for("fr", 9), "vide");
        assert!(contract_label_for("en", 1).is_empty());
        assert_eq!(supported_locales(), "en,mi,fr,zh-TW");
    }

    #[test]
    fn testbed_solids_drop_themselves() {
        assert_eq!(loot_item(1), 1);
        assert_eq!(loot_item(3), 3);
        assert_eq!(loot_item(0), 0);
        assert_eq!(item_label_for("en", 1), "concrete");
        assert!(item_label_for("en", 0).is_empty());
    }
}
