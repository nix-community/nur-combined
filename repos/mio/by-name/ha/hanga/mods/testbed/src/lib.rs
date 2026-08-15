//! Hanga Testbed — a debug game that exercises the engine without Urban Chaos rules.
//!
//! Infinite checkerboard floor, no wanted level, no cops, no economy spikes.
//! Zero-g lab (`gravity` is `none`). Used to verify the WASM bridge and Teardown
//! debris independently of city gen.

#[cfg(target_arch = "wasm32")]
wit_bindgen::generate!({ world: "plugin", path: "../../wit" });

#[cfg(not(target_arch = "wasm32"))]
wit_bindgen::generate!({
    world: "plugin",
    path: "../../wit",
    with: {
        "hanga:engine/host": generate,
    },
});

include!("../../locale.rs");
include!("../../mod_kit.rs");

use std::sync::atomic::{AtomicI32, Ordering};

static NOTES: AtomicI32 = AtomicI32::new(0);

struct TestbedMod;

fn testbed_topics() -> String {
    format!("{BUS_TOPICS},refuse,veto,selfie,paint,later,note,count,who,see,clock,crew,yell,ask,boom,toss,bark")
}

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

pub fn compute_traffic_vx(forward_x: f32, _forward_z: f32, blocked: bool) -> f32 {
    if blocked {
        0.0
    } else {
        forward_x * 8.0
    }
}

pub fn compute_traffic_vz(_forward_x: f32, forward_z: f32, blocked: bool) -> f32 {
    if blocked {
        0.0
    } else {
        forward_z * 8.0
    }
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
    if beside_peer("urban_chaos") {
        2
    } else {
        1
    }
}

pub fn vehicle_spawn(index: i32) -> (i32, i32, i32) {
    if beside_peer("urban_chaos") {
        if index <= 0 {
            (518, 2, 508)
        } else {
            (522, 2, 500)
        }
    } else {
        (4, 2, 0)
    }
}

/// A rideable slab. Stiff lab plate; a second cart appears next to Urban Chaos.
pub fn vehicle_kit(index: i32) -> hanga::engine::host::Value {
    let cart = beside_peer("urban_chaos") && index >= 1;
    let (kind, traffic, speed, stiffness, collider, deck, rgb) = if cart {
        (
            "cart",
            true,
            8.0,
            88,
            [1.6, 0.5, 2.2],
            [1.60, 0.18, 2.20],
            [0.55, 0.62, 0.58],
        )
    } else {
        (
            "platform",
            false,
            12.0,
            95,
            [2.0, 0.4, 2.0],
            [2.00, 0.20, 2.00],
            [0.45, 0.45, 0.48],
        )
    };
    wire_dict(vec![
        field("kind", atom_text(kind)),
        field("traffic", atom_flag(traffic)),
        field("speed", atom_float(speed)),
        field("stiffness", atom_int(stiffness)),
        field(
            "collider",
            wire_dict(vec![
                field("x", atom_float(collider[0])),
                field("y", atom_float(collider[1])),
                field("z", atom_float(collider[2])),
            ]),
        ),
        field(
            "parts",
            wire_list(vec![part_dict("deck", deck, [0.0, 0.0, 0.0], rgb)]),
        ),
    ])
}

/// Lab void: no gravity. Debris and the player stay where they are.
pub fn gravity() -> hanga::engine::host::Value {
    wire_dict(vec![
        field("kind", atom_text("none")),
        field("jump", atom_float(2.0)),
        field("walk", atom_float(8.0)),
    ])
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

pub fn fracture_kit(voxel: &str, action: &str) -> hanga::engine::host::Value {
    wire_dict(vec![
        field("can", atom_flag(can_fracture(voxel) != 0)),
        field("spread", atom_int(fracture_spread(voxel) as i64)),
        field("impulse", atom_float(debris_impulse(action) as f64)),
    ])
}

pub fn steer(payload: &hanga::engine::host::Value) -> hanga::engine::host::Value {
    let role = payload_str(payload, "role");
    if role == "traffic" {
        let fwd_x = payload_f32(payload, "fwd-x");
        let fwd_z = payload_f32(payload, "fwd-z");
        let blocked = payload_flag(payload, "blocked");
        return wire_dict(vec![
            field("vx", atom_float(compute_traffic_vx(fwd_x, fwd_z, blocked) as f64)),
            field("vz", atom_float(compute_traffic_vz(fwd_x, fwd_z, blocked) as f64)),
        ]);
    }
    let cx = payload_f32(payload, "cur-x");
    let cz = payload_f32(payload, "cur-z");
    let tx = payload_f32(payload, "target-x");
    let tz = payload_f32(payload, "target-z");
    wire_dict(vec![
        field("vx", atom_float(compute_agent_vx(role, cx, cz, tx, tz) as f64)),
        field("vz", atom_float(compute_agent_vz(role, cx, cz, tx, tz) as f64)),
    ])
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
    _held: &str,
    _y: i32,
    _vehicle: bool,
    _near: bool,
) -> i32 {
    0
}

pub fn contract_mark(_kind: &str) -> hanga::engine::host::Value {
    wire_empty()
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

pub fn crash_severity(_speed: f32, _into_solid: bool) -> i32 {
    0
}

pub fn crash_crumple(_severity: i32) -> i32 {
    0
}

pub fn crash_detach(_part: &str, _severity: i32) -> i32 {
    0
}

pub fn crash_wrecks(_severity: i32) -> i32 {
    0
}

pub fn crash_action(_severity: i32) -> String {
    String::new()
}

pub fn crash_ignites(_severity: i32) -> i32 {
    0
}

pub fn crash_part_impulse(_severity: i32) -> f32 {
    0.0
}

pub fn crash_kit(_speed: f32, _into_solid: bool) -> hanga::engine::host::Value {
    wire_empty()
}

pub fn fire_kit(_age_ms: i32, _nearby: &str) -> hanga::engine::host::Value {
    wire_empty()
}

pub fn on_message(from: &str, topic: &str, payload: &hanga::engine::host::Value) -> hanga::engine::host::Value {
    if let Some(reply) = host_bus_reply(topic, payload) {
        return reply;
    }
    match topic {
        "ping" => wire_text("pong"),
        "name" => wire_text("testbed"),
        "catalog" => wire_text(voxel_catalog()),
        "hello" => wire_text(format!("hello {from}")),
        "voxel" => wire_text(host_voxel_at(
            payload_i64(payload, "x") as i32,
            payload_i64(payload, "y") as i32,
            payload_i64(payload, "z") as i32,
        )),
        "probe" => host_voxel_probe(
            payload_i64(payload, "x") as i32,
            payload_i64(payload, "y") as i32,
            payload_i64(payload, "z") as i32,
        ),
        "has" => bus_has(&testbed_topics(), payload),
        "methods" => wire_methods(&testbed_topics()),
        "refuse" => wire_fail("busy"),
        "veto" => wire_flag(true),
        "selfie" => host_player(),
        "paint" => {
            host_voxel_set(
                payload_i64(payload, "x") as i32,
                payload_i64(payload, "y") as i32,
                payload_i64(payload, "z") as i32,
                payload_str(payload, "name"),
            );
            wire_empty()
        }
        "later" => {
            host_after(0, "note", &wire_empty());
            wire_empty()
        }
        "note" => wire_int(NOTES.fetch_add(1, Ordering::Relaxed) as i64 + 1),
        "count" => wire_int(NOTES.load(Ordering::Relaxed) as i64),
        "who" => wire_text(host_id()),
        "see" => {
            let name = match root_cell(payload) {
                Cell::Text(text) => text,
                _ => payload_str(payload, "name").to_string(),
            };
            wire_flag(host_has_mod(&name))
        }
        "clock" => wire_int(host_clock()),
        "crew" => wire_list(host_peers().into_iter().map(atom_text).collect()),
        "yell" => wire_flag(host_emit("veto", &wire_empty())),
        "ask" => host_invoke(
            payload_str(payload, "peer"),
            payload_str(payload, "method"),
            &wire_empty(),
        ),
        "boom" => panic!("testbed boom"),
        "toss" => {
            host_send(
                payload_str(payload, "peer"),
                payload_str(payload, "method"),
                &wire_empty(),
            );
            wire_empty()
        }
        "bark" => {
            host_log("warn", "woof");
            wire_empty()
        }
        _ => wire_empty(),
    }
}

impl exports::hanga::engine::guest::Guest for TestbedMod {
    fn abi() -> i32 {
        6
    }

    fn ready() {
        crate::greet_peers();
        crate::host_log("info", "testbed ready");
    }

    fn voxel_catalog() -> Vec<String> {
        catalog_names(&crate::voxel_catalog())
    }

    fn query_voxel(x: i32, y: i32, z: i32) -> i32 {
        crate::query_voxel(x, y, z)
    }

    fn invoke(
        caller: String,
        method: String,
        args: hanga::engine::host::Value,
    ) -> hanga::engine::host::Value {
        crate::on_message(&caller, &method, &args)
    }
}

export!(TestbedMod);

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn refuse_is_a_bus_error() {
        match root_cell(&on_message("host", "refuse", &wire_empty())) {
            Cell::Fail(reason) => assert_eq!(reason, "busy"),
            other => panic!("{other:?}"),
        }
        match root_cell(&on_message("host", "veto", &wire_empty())) {
            Cell::Flag(true) => {}
            other => panic!("{other:?}"),
        }
    }

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
        assert_eq!(mod_can_complete("accept_contract", 0, "smash-and-grab", 1, "", 0, false, false), 0);
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

    #[test]
    fn testbed_vehicles_do_not_fold() {
        assert_eq!(crash_severity(40.0, true), 0);
        assert_eq!(crash_wrecks(100), 0);
        assert!(crash_action(100).is_empty());
        assert_eq!(crash_ignites(100), 0);
        assert!(wire_is_null(&crash_kit(40.0, true)));
        assert!(wire_is_null(&fire_kit(9_000, "glass")));
        assert_eq!(
            wire_as_text(&on_message("urban_chaos", "ping", &wire_empty())),
            Some("pong")
        );
        assert_eq!(
            wire_as_text(&on_message("x", "voxel", &wire_empty())),
            Some("air")
        );
        let probe = on_message("x", "probe", &wire_empty());
        assert_eq!(payload_text(&probe, "name"), Some("air"));
        assert!(!payload_flag(&probe, "edit"));
        assert!(wire_is_flag(&on_message("x", "has", &wire_text("voxel")), true));
        assert!(wire_is_flag(&on_message("x", "has", &wire_text("nope")), false));
        assert_eq!(
            wire_as_text(&on_message("x", "name", &wire_empty())),
            Some("testbed")
        );
    }

    #[test]
    fn testbed_vehicle_is_a_platform() {
        let kit = vehicle_kit(0);
        assert_eq!(payload_str(&kit, "kind"), "platform");
        assert_eq!(payload_i64(&kit, "stiffness"), 95);
        let parts = as_list(&dict_child(&kit, "parts").unwrap()).unwrap();
        assert_eq!(payload_str(&parts[0], "name"), "deck");
        assert_ne!(payload_str(&kit, "kind"), "car");
        assert_eq!(vehicle_spawn_count(), 1);
    }

    #[test]
    fn testbed_has_no_earth_gravity() {
        let g = gravity();
        assert_eq!(payload_str(&g, "kind"), "none");
        assert!((payload_f32(&g, "walk") - 8.0).abs() < 1e-5);
        assert_eq!(payload_f32(&g, "y"), 0.0);
    }
}
