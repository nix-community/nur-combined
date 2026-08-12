//! Hanga Testbed — a debug game that exercises the engine without Urban Chaos rules.
//!
//! Infinite checkerboard floor, no wanted level, no cops, no economy spikes.
//! Used to verify the WASM bridge and Teardown debris independently of city gen.

wit_bindgen::generate!({ world: "plugin", path: "../../wit" });

include!("../../locale.rs");

struct TestbedMod;

pub const ACTION_BREAK: &str = "break";
pub const ACTION_EXPLODE: &str = "explode";

pub fn voxel_catalog() -> String {
    "air,concrete,glass".into()
}

pub fn query_voxel(x: i32, y: i32, z: i32) -> i32 {
    if y < 0 {
        return 1; // concrete
    }
    if y == 0 {
        // Checkerboard: even cells concrete, odd cells glass so we can see materials.
        return if (x.wrapping_add(z) & 1) == 0 { 1 } else { 2 };
    }
    0
}

#[cfg(test)]
fn voxel_name(index: i32) -> &'static str {
    match index {
        1 => "concrete",
        2 => "glass",
        _ => "air",
    }
}

pub fn mod_evaluate_action(_action: &str, current_state: i32) -> i32 {
    current_state // no wanted level in the testbed
}

pub fn mod_should_spawn_agent(_action: &str, _old_state: i32, _new_state: i32) -> String {
    String::new()
}

pub fn compute_agent_vx(_agent: &str, _cx: f32, _cz: f32, _px: f32, _pz: f32) -> f32 {
    0.0
}

pub fn compute_agent_vz(_agent: &str, _cx: f32, _cz: f32, _px: f32, _pz: f32) -> f32 {
    0.0
}

pub fn compute_economy_price(base_price: i32, supply: i32, demand: i32) -> i32 {
    if supply == 0 {
        return base_price;
    }
    (base_price * demand / supply).max(1)
}

pub fn mod_get_action_range(_action: &str) -> f32 {
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

pub fn generate_story_event(_player_level: i32) -> String {
    "void".into()
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

pub fn can_fracture(voxel: &str) -> i32 {
    if voxel.is_empty() || voxel == "air" {
        0
    } else {
        1
    }
}

pub fn fracture_spread(_voxel: &str) -> i32 {
    1
}

pub fn debris_impulse(_action: &str) -> f32 {
    8.0
}

pub fn mod_tick(current_state: i32, _dt_ms: i32) -> i32 {
    current_state
}

pub fn should_despawn_agent(_agent: &str, _current_state: i32) -> i32 {
    0
}

pub fn ambient_agent_count() -> i32 {
    0
}

pub fn ambient_agent_spawn(_index: i32) -> (i32, i32, i32, String) {
    (0, 2, 0, "pedestrian".into())
}

pub fn voxel_label(voxel: &str) -> String {
    voxel_label_for("en", voxel)
}

pub fn voxel_label_for(locale: &str, voxel: &str) -> String {
    let lang = locale_id(locale);
    match (lang, voxel) {
        (1, "air") => "hau",
        (1, "concrete") => "raima",
        (1, "glass") => "karaihe",
        (1, _) => "tē mōhiotia",
        (2, "air") => "air",
        (2, "concrete") => "béton",
        (2, "glass") => "verre",
        (2, _) => "inconnu",
        (3, "air") => "空氣",
        (3, "concrete") => "混凝土",
        (3, "glass") => "玻璃",
        (3, _) => "未知",
        (_, "air") => "air",
        (_, "concrete") => "concrete",
        (_, "glass") => "glass",
        _ => "unknown",
    }
    .into()
}

pub fn mod_wallet_after(_action: &str, current_wallet: i32, _extra: i32) -> i32 {
    current_wallet
}

pub fn mod_offer_contract(_player_state: i32) -> (String, i32, i32) {
    (String::new(), 0, 0)
}

pub fn mod_can_complete(
    _action: &str,
    _player_state: i32,
    _contract_kind: &str,
    _contract_danger: i32,
) -> i32 {
    0
}

pub fn event_label(_event: &str) -> String {
    event_label_for("en", "void")
}

pub fn event_label_for(locale: &str, _event: &str) -> String {
    match locale_id(locale) {
        1 => "korekore",
        2 => "vide",
        3 => "虛空",
        _ => "void",
    }
    .into()
}

pub fn contract_label_for(_locale: &str, _kind: &str) -> String {
    String::new()
}

pub fn loot_item(voxel: &str) -> String {
    match voxel {
        "concrete" | "glass" => voxel.into(),
        _ => String::new(),
    }
}

pub fn item_label_for(locale: &str, item: &str) -> String {
    if item.is_empty() {
        return String::new();
    }
    voxel_label_for(locale, item)
}

pub fn craft_result(_item_a: &str, _item_b: &str) -> String {
    String::new()
}

impl exports::hanga::engine::gameplay::Guest for TestbedMod {
    fn init_mod() {}
    fn voxel_catalog() -> String {
        crate::voxel_catalog()
    }
    fn query_voxel(x: i32, y: i32, z: i32) -> i32 {
        crate::query_voxel(x, y, z)
    }
    fn mod_evaluate_action(action: String, current_state: i32) -> i32 {
        crate::mod_evaluate_action(&action, current_state)
    }
    fn mod_should_spawn_agent(a: String, o: i32, n: i32) -> String {
        crate::mod_should_spawn_agent(&a, o, n)
    }
    fn compute_agent_vx(t: String, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
        crate::compute_agent_vx(&t, cx, cz, px, pz)
    }
    fn compute_agent_vz(t: String, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
        crate::compute_agent_vz(&t, cx, cz, px, pz)
    }
    fn compute_economy_price(b: i32, s: i32, d: i32) -> i32 {
        crate::compute_economy_price(b, s, d)
    }
    fn mod_get_action_range(a: String) -> f32 {
        crate::mod_get_action_range(&a)
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
    fn generate_story_event(level: i32) -> String {
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
    fn can_fracture(voxel: String) -> i32 {
        crate::can_fracture(&voxel)
    }
    fn fracture_spread(voxel: String) -> i32 {
        crate::fracture_spread(&voxel)
    }
    fn debris_impulse(action: String) -> f32 {
        crate::debris_impulse(&action)
    }
    fn mod_tick(current_state: i32, dt_ms: i32) -> i32 {
        crate::mod_tick(current_state, dt_ms)
    }
    fn should_despawn_agent(agent: String, current_state: i32) -> i32 {
        crate::should_despawn_agent(&agent, current_state)
    }
    fn ambient_agent_count() -> i32 {
        crate::ambient_agent_count()
    }
    fn ambient_agent_spawn(index: i32) -> (i32, i32, i32, String) {
        crate::ambient_agent_spawn(index)
    }
    fn voxel_label(voxel: String, locale: String) -> String {
        crate::voxel_label_for(&locale, &voxel)
    }
    fn mod_wallet_after(action: String, current_wallet: i32, extra: i32) -> i32 {
        crate::mod_wallet_after(&action, current_wallet, extra)
    }
    fn mod_offer_contract(player_state: i32) -> (String, i32, i32) {
        crate::mod_offer_contract(player_state)
    }
    fn mod_can_complete(
        action: String,
        player_state: i32,
        contract_kind: String,
        contract_danger: i32,
    ) -> i32 {
        crate::mod_can_complete(&action, player_state, &contract_kind, contract_danger)
    }
    fn event_label(event: String, locale: String) -> String {
        crate::event_label_for(&locale, &event)
    }
    fn contract_label(kind: String, locale: String) -> String {
        crate::contract_label_for(&locale, &kind)
    }
    fn supported_locales() -> String {
        crate::supported_locales()
    }

    fn loot_item(voxel: String) -> String {
        crate::loot_item(&voxel)
    }

    fn item_label(item: String, locale: String) -> String {
        crate::item_label_for(&locale, &item)
    }

    fn craft_result(item_a: String, item_b: String) -> String {
        crate::craft_result(&item_a, &item_b)
    }
}

export!(TestbedMod);

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn floor_is_checkerboard() {
        assert_eq!(voxel_name(query_voxel(0, 0, 0)), "concrete");
        assert_eq!(voxel_name(query_voxel(1, 0, 0)), "glass");
        assert_eq!(voxel_name(query_voxel(0, 1, 0)), "air");
        assert_eq!(voxel_name(query_voxel(0, -1, 0)), "concrete");
        assert_eq!(voxel_catalog(), "air,concrete,glass");
    }

    #[test]
    fn no_wanted_level_and_no_cops() {
        assert_eq!(mod_evaluate_action(ACTION_EXPLODE, 0), 0);
        assert!(mod_should_spawn_agent(ACTION_EXPLODE, 0, 0).is_empty());
    }

    #[test]
    fn everything_solid_can_fracture() {
        assert_eq!(can_fracture("concrete"), 1);
        assert_eq!(can_fracture("glass"), 1);
        assert_eq!(can_fracture("air"), 0);
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
        assert_eq!(voxel_label("air"), "air");
    }

    #[test]
    fn testbed_has_no_heists_or_wallet() {
        assert_eq!(mod_offer_contract(5), (String::new(), 0, 0));
        assert_eq!(mod_wallet_after("complete_contract", 99, 1200), 99);
        assert_eq!(mod_can_complete("accept_contract", 0, "smash-and-grab", 1), 0);
        assert_eq!(event_label("armored-truck-heist"), "void");
    }

    #[test]
    fn testbed_labels_follow_locale() {
        assert_eq!(voxel_label_for("mi", "air"), "hau");
        assert_eq!(voxel_label_for("fr", "glass"), "verre");
        assert_eq!(voxel_label_for("zh-TW", "concrete"), "混凝土");
        assert_eq!(event_label_for("zh-TW", "void"), "虛空");
        assert_eq!(event_label_for("fr", "unknown"), "vide");
        assert!(contract_label_for("en", "smash-and-grab").is_empty());
        assert_eq!(supported_locales(), "en,mi,fr,zh-TW");
    }

    #[test]
    fn testbed_solids_drop_themselves() {
        assert_eq!(loot_item("concrete"), "concrete");
        assert_eq!(loot_item("glass"), "glass");
        assert!(loot_item("air").is_empty());
        assert_eq!(item_label_for("en", "concrete"), "concrete");
        assert!(item_label_for("en", "").is_empty());
        assert!(craft_result("concrete", "concrete").is_empty());
    }
}
