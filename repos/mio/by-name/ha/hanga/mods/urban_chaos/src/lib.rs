wit_bindgen::generate!({ world: "plugin", path: "../../wit" });

include!("../../locale.rs");

use std::sync::OnceLock;

struct UrbanChaosMod;

/// Represents the 2D skeleton of our Voxel City
pub struct CityLayout {
    pub width: u32,
    pub height: u32,
    pub roads: Vec<Road>,
    pub districts: Vec<District>,
}

pub struct Road {
    pub start: (u32, u32),
    pub end: (u32, u32),
}

pub struct District {
    pub center: (u32, u32),
    pub district_type: DistrictType,
}

pub enum DistrictType {
    Downtown,
    Suburban,
    Industrial,
}

impl CityLayout {
    pub fn generate(width: u32, height: u32) -> Self {
        let roads = Self::generate_l_system_roads(width, height);
        let districts = Self::generate_voronoi_districts(width, height);
        CityLayout {
            width,
            height,
            roads,
            districts,
        }
    }

    fn generate_l_system_roads(width: u32, height: u32) -> Vec<Road> {
        let mut roads = Vec::new();
        for x in (0..width).step_by(100) {
            roads.push(Road {
                start: (x, 0),
                end: (x, height),
            });
        }
        for z in (0..height).step_by(100) {
            roads.push(Road {
                start: (0, z),
                end: (width, z),
            });
        }
        roads
    }

    fn generate_voronoi_districts(width: u32, height: u32) -> Vec<District> {
        vec![
            District {
                center: (width / 2, height / 2),
                district_type: DistrictType::Downtown,
            },
            District {
                center: (width / 4, height / 4),
                district_type: DistrictType::Suburban,
            },
            District {
                center: (width * 3 / 4, height * 3 / 4),
                district_type: DistrictType::Industrial,
            },
        ]
    }

    /// Queries the 3D voxel type at a specific coordinate based on the 2D layout.
    pub fn get_voxel_at(&self, x: i32, y: i32, z: i32) -> u8 {
        let mod_x = (x % 100).abs();
        let mod_z = (z % 100).abs();

        let is_road_x = mod_x < 3;
        let is_road_z = mod_z < 3;
        let is_sidewalk_x = mod_x >= 3 && mod_x < 5;
        let is_sidewalk_z = mod_z >= 3 && mod_z < 5;
        let is_road = is_road_x || is_road_z;
        let is_sidewalk = (is_sidewalk_x || is_sidewalk_z) && !is_road;

        if y < -12 {
            return 1; // Deep bedrock
        }

        // Sidewalk shafts at 200 m intersections (metro access).
        let shaft = is_sidewalk && near_period(x, 200, 5) && near_period(z, 200, 5);
        if shaft && (-8..=0).contains(&y) {
            if y == -8 {
                return 6; // Station tiles
            }
            return 0; // Access shaft
        }

        // Station hall under the same intersections.
        let station = (is_road || is_sidewalk) && near_period(x, 200, 8) && near_period(z, 200, 8);
        if station && (-8..=-4).contains(&y) {
            if y == -8 {
                return 6;
            }
            return 0;
        }

        if is_road && (-8..-2).contains(&y) {
            if y == -8 {
                return 6;
            }
            if y == -7 && ((is_road_x && mod_x == 1) || (is_road_z && mod_z == 1)) {
                return 7; // Rail
            }
            return 0;
        }
        if is_road && y == -2 {
            return 1; // Street slab over the tunnel
        }

        if y < 0 {
            return 1; // Fill under parks and buildings
        }

        let cell_x = x - (x % 100) + 50;
        let cell_z = z - (z % 100) + 50;

        let prng = (cell_x.abs() * 73 + cell_z.abs() * 37) % 100;
        let is_park = prng < 15;

        if y == 0 {
            if is_road {
                return 2; // Asphalt
            }
            if is_sidewalk {
                return 4;
            }
            if is_park {
                return 5; // Grass
            }
        }

        let dist_to_center = ((cell_x - (self.width / 2) as i32).pow(2)
            + (cell_z - (self.height / 2) as i32).pow(2)) as f32;
        let dist_to_center = dist_to_center.sqrt();

        let max_height = if dist_to_center < 300.0 {
            60 + (prng % 60)
        } else if dist_to_center < 600.0 {
            20 + (prng % 30)
        } else {
            10 + (prng % 10)
        };

        let local_x = (x - cell_x).abs();
        let local_z = (z - cell_z).abs();

        let mut footprint = 20;
        if prng % 3 == 0 && local_x > 10 && local_z < 10 {
            footprint = 0;
        }

        if !is_park && local_x < footprint && local_z < footprint {
            if y < max_height {
                if max_height > 50 && (local_x == footprint - 1 || local_z == footprint - 1) {
                    return 3; // Glass
                }
                return 1; // Concrete
            }
            if y >= max_height && y < max_height + 5 && local_x == 0 && local_z == 0 && prng % 2 == 0
            {
                return 1; // Antenna pole
            }
        }

        0 // Air
    }
}

/// True when `v` is within `radius` of a multiple of `period` (wraps both ways).
fn near_period(v: i32, period: i32, radius: i32) -> bool {
    if period <= 0 || radius < 0 {
        return false;
    }
    let r = v.rem_euclid(period);
    r <= radius || r >= period - radius
}

static CITY: OnceLock<CityLayout> = OnceLock::new();

fn city() -> &'static CityLayout {
    CITY.get_or_init(|| CityLayout::generate(1000, 1000))
}

// ─── Gameplay functions (called by Guest impl and by native tests) ────────────

pub fn query_voxel(x: i32, y: i32, z: i32) -> i32 {
    city().get_voxel_at(x, y, z) as i32
}

/// Urban Chaos: state is the Wanted Level (0-5).
pub fn mod_evaluate_action(action_type: i32, current_state: i32) -> i32 {
    match action_type {
        1 => current_state.saturating_add(1).min(5), // BreakBlock
        2 => current_state,                          // PlaceBlock
        3 => current_state.saturating_add(3).min(5), // EnterVehicle = GTA
        4 => 5,                                      // Explosion = 5 stars
        5 => current_state,                          // AcceptContract
        6 => current_state.saturating_add(1).min(5), // CompleteContract is noisy
        7 => current_state,                          // FenceLoot when cold
        _ => current_state,
    }
}

pub fn mod_should_spawn_agent(_action_type: i32, old_state: i32, new_state: i32) -> i32 {
    if new_state > old_state && new_state > 0 {
        1 // Cop
    } else {
        0
    }
}

pub fn compute_economy_price(base_price: i32, supply: i32, demand: i32) -> i32 {
    if supply == 0 {
        return base_price * 10;
    }
    ((base_price * demand) / supply).max(1)
}

pub fn mod_get_action_range(action_type: i32) -> f32 {
    match action_type {
        1 => 10.0,
        2 => 10.0,
        3 => 5.0,
        4 => 30.0,
        _ => 10.0,
    }
}

pub fn compute_traffic_vx(forward_x: f32, _forward_z: f32, blocked: bool) -> f32 {
    if blocked {
        0.0
    } else {
        forward_x * 10.0
    }
}

pub fn compute_traffic_vz(_forward_x: f32, forward_z: f32, blocked: bool) -> f32 {
    if blocked {
        0.0
    } else {
        forward_z * 10.0
    }
}

pub fn mod_get_storyteller_level() -> i32 {
    10
}

pub fn mod_get_economy_params() -> i32 {
    let supply: i32 = 5;
    let demand: i32 = 8;
    (supply << 16) | demand
}

pub fn generate_story_event(player_level: i32) -> i32 {
    if player_level < 5 {
        0
    } else if player_level < 20 {
        1
    } else {
        2
    }
}

pub fn player_spawn() -> (i32, i32, i32) {
    (490, 50, 490)
}

pub fn vehicle_spawn_count() -> i32 {
    6
}

pub fn vehicle_spawn(index: i32) -> (i32, i32, i32) {
    if index <= 0 {
        (500, 50, 495)
    } else {
        (510 + (index - 1) * 10, 50, 495)
    }
}

/// Voxel types: 0 air, 1 concrete, 2 asphalt, 3 glass, 4 sidewalk, 5 grass, 6 tile, 7 rail.
/// Buildings and station tiles shatter; roads, rails, and ground stay put.
pub fn can_fracture(voxel_type: i32) -> i32 {
    match voxel_type {
        1 | 3 | 6 => 1,
        _ => 0,
    }
}

pub fn fracture_spread(voxel_type: i32) -> i32 {
    match voxel_type {
        3 => 3, // glass shatters further
        1 | 6 => 2,
        _ => 0,
    }
}

pub fn debris_impulse(action_type: i32) -> f32 {
    match action_type {
        4 => 15.0, // explosion
        1 => 5.0,  // melee / pick
        _ => 2.0,
    }
}

/// Decay wanted level by 1 star every 8 seconds of idle time.
pub fn mod_tick(current_state: i32, dt_ms: i32) -> i32 {
    if current_state <= 0 {
        return 0;
    }
    if dt_ms >= 8000 {
        current_state.saturating_sub(1)
    } else {
        current_state
    }
}

/// Cops leave when the player is no longer wanted. Pedestrians stay.
pub fn should_despawn_agent(agent_type: i32, current_state: i32) -> i32 {
    if agent_type == 1 && current_state <= 0 {
        1
    } else {
        0
    }
}

pub fn ambient_agent_count() -> i32 {
    6
}

pub fn ambient_agent_spawn(index: i32) -> (i32, i32, i32, i32) {
    let i = index.max(0);
    // Pedestrians (type 2) on the road near downtown spawn.
    (502 + i * 8, 2, 500, 2)
}

pub fn voxel_label(voxel_type: i32) -> String {
    voxel_label_for("en", voxel_type)
}

pub fn voxel_label_for(locale: &str, voxel_type: i32) -> String {
    let lang = locale_id(locale);
    match (lang, voxel_type) {
        (1, 0) => "hau",
        (1, 1) => "raima",
        (1, 2) => "huarahi tā",
        (1, 3) => "karaihe",
        (1, 4) => "ara hīkoi",
        (1, 5) => "pātītī",
        (1, 6) => "tāera",
        (1, 7) => "rerewē",
        (1, _) => "tē mōhiotia",
        (2, 0) => "air",
        (2, 1) => "béton",
        (2, 2) => "asphalte",
        (2, 3) => "verre",
        (2, 4) => "trottoir",
        (2, 5) => "herbe",
        (2, 6) => "carrelage",
        (2, 7) => "rail",
        (2, _) => "inconnu",
        (3, 0) => "空氣",
        (3, 1) => "混凝土",
        (3, 2) => "柏油",
        (3, 3) => "玻璃",
        (3, 4) => "人行道",
        (3, 5) => "草地",
        (3, 6) => "磁磚",
        (3, 7) => "鐵軌",
        (3, _) => "未知",
        (_, 0) => "air",
        (_, 1) => "concrete",
        (_, 2) => "asphalt",
        (_, 3) => "glass",
        (_, 4) => "sidewalk",
        (_, 5) => "grass",
        (_, 6) => "tile",
        (_, 7) => "rail",
        _ => "unknown",
    }
    .into()
}

/// Heist board: 1 = smash-and-grab, 2 = armored truck. Danger is min wanted to cash out.
pub fn heist_for_wanted(wanted: i32) -> (i32, i32, i32) {
    match wanted {
        i if i >= 3 => (2, 1200, 4),
        i if i >= 1 => (1, 400, 2),
        _ => (1, 250, 1),
    }
}

pub fn mod_offer_contract(player_state: i32) -> (i32, i32, i32) {
    heist_for_wanted(player_state.clamp(0, 5))
}

pub fn event_label(event_id: i32) -> String {
    event_label_for("en", event_id)
}

pub fn event_label_for(locale: &str, event_id: i32) -> String {
    let lang = locale_id(locale);
    match (lang, event_id) {
        (1, 0) => "ngā huarahi mārie",
        (1, 1) => "kirimina pakaru-hopu",
        (1, 2) => "keehi taraka pākaha",
        (1, _) => "takahanga tē mōhiotia",
        (2, 0) => "rues calmes",
        (2, 1) => "contrat de vol à la sauvette",
        (2, 2) => "casse de fourgon blindé",
        (2, _) => "événement inconnu",
        (3, 0) => "平靜的街道",
        (3, 1) => "搶劫合約",
        (3, 2) => "運鈔車搶案",
        (3, _) => "未知事件",
        (_, 0) => "quiet streets",
        (_, 1) => "smash-and-grab contract",
        (_, 2) => "armored-truck heist",
        _ => "unknown event",
    }
    .into()
}

pub fn loot_item(voxel_type: i32) -> i32 {
    match voxel_type {
        1 | 3 | 5 | 6 => voxel_type,
        _ => 0,
    }
}

pub fn item_label_for(locale: &str, item_id: i32) -> String {
    if item_id <= 0 {
        return String::new();
    }
    voxel_label_for(locale, item_id)
}

pub fn contract_label(kind: i32) -> String {
    contract_label_for("en", kind)
}

pub fn contract_label_for(locale: &str, kind: i32) -> String {
    let lang = locale_id(locale);
    match (lang, kind) {
        (_, 0) => "",
        (1, 1) => "kirimina pakaru-hopu",
        (1, 2) => "keehi taraka pākaha",
        (1, _) => "mahi tē mōhiotia",
        (2, 1) => "vol à la sauvette",
        (2, 2) => "fourgon blindé",
        (2, _) => "contrat inconnu",
        (3, 1) => "搶劫合約",
        (3, 2) => "運鈔車搶案",
        (3, _) => "未知任務",
        (_, 1) => "smash-and-grab",
        (_, 2) => "armored-truck heist",
        _ => "unknown contract",
    }
    .into()
}

/// extra is payout for complete, unused otherwise.
pub fn mod_wallet_after(action_type: i32, current_wallet: i32, extra: i32) -> i32 {
    let next = match action_type {
        1 => current_wallet.saturating_add(5),
        3 => current_wallet.saturating_add(50),
        6 => current_wallet.saturating_add(extra.max(0)),
        7 => {
            let packed = crate::mod_get_economy_params();
            let supply = (packed >> 16) & 0xFFFF;
            let demand = packed & 0xFFFF;
            current_wallet.saturating_add(crate::compute_economy_price(80, supply, demand))
        }
        _ => current_wallet,
    };
    next.clamp(0, 1_000_000)
}

pub fn mod_can_complete(
    action_type: i32,
    player_state: i32,
    contract_kind: i32,
    contract_danger: i32,
) -> i32 {
    match action_type {
        5 => {
            if contract_kind > 0 {
                1
            } else {
                0
            }
        }
        6 => {
            if contract_kind > 0 && player_state >= contract_danger {
                1
            } else {
                0
            }
        }
        7 => {
            if player_state <= 0 {
                1
            } else {
                0
            }
        }
        _ => 0,
    }
}

pub fn compute_agent_vx(ai_type: i32, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
    match ai_type {
        1 => {
            let dx = px - cx;
            let dz = pz - cz;
            let len = (dx * dx + dz * dz).sqrt();
            if len < 2.0 {
                return 0.0;
            }
            (dx / len) * 8.0
        }
        2 => {
            // Pedestrian: stroll +X, freeze if the player is on top of them.
            let dx = px - cx;
            let dz = pz - cz;
            if dx * dx + dz * dz < 2.25 {
                0.0
            } else {
                3.0
            }
        }
        _ => 0.0,
    }
}

pub fn compute_agent_vz(ai_type: i32, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
    match ai_type {
        1 => {
            let dx = px - cx;
            let dz = pz - cz;
            let len = (dx * dx + dz * dz).sqrt();
            if len < 2.0 {
                return 0.0;
            }
            (dz / len) * 8.0
        }
        2 => 0.0,
        _ => 0.0,
    }
}

impl exports::hanga::engine::gameplay::Guest for UrbanChaosMod {
    fn init_mod() {
        let _ = city();
    }

    fn query_voxel(x: i32, y: i32, z: i32) -> i32 {
        crate::query_voxel(x, y, z)
    }

    fn mod_evaluate_action(action_type: i32, current_state: i32) -> i32 {
        crate::mod_evaluate_action(action_type, current_state)
    }

    fn mod_should_spawn_agent(action_type: i32, old_state: i32, new_state: i32) -> i32 {
        crate::mod_should_spawn_agent(action_type, old_state, new_state)
    }

    fn compute_agent_vx(ai_type: i32, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
        crate::compute_agent_vx(ai_type, cx, cz, px, pz)
    }

    fn compute_agent_vz(ai_type: i32, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
        crate::compute_agent_vz(ai_type, cx, cz, px, pz)
    }

    fn compute_economy_price(base_price: i32, supply: i32, demand: i32) -> i32 {
        crate::compute_economy_price(base_price, supply, demand)
    }

    fn mod_get_action_range(action_type: i32) -> f32 {
        crate::mod_get_action_range(action_type)
    }

    fn compute_traffic_vx(forward_x: f32, forward_z: f32, blocked: bool) -> f32 {
        crate::compute_traffic_vx(forward_x, forward_z, blocked)
    }

    fn compute_traffic_vz(forward_x: f32, forward_z: f32, blocked: bool) -> f32 {
        crate::compute_traffic_vz(forward_x, forward_z, blocked)
    }

    fn mod_get_storyteller_level() -> i32 {
        crate::mod_get_storyteller_level()
    }

    fn mod_get_economy_params() -> i32 {
        crate::mod_get_economy_params()
    }

    fn generate_story_event(player_level: i32) -> i32 {
        crate::generate_story_event(player_level)
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

export!(UrbanChaosMod);

#[cfg(kani)]
mod kani_verification {
    use super::*;

    #[kani::proof]
    fn verify_get_voxel_at_never_panics() {
        let x: i32 = kani::any();
        let y: i32 = kani::any();
        let z: i32 = kani::any();

        let layout = CityLayout {
            width: 1000,
            height: 1000,
            roads: vec![],
            districts: vec![],
        };

        let voxel_id = layout.get_voxel_at(x, y, z);
        kani::assert(voxel_id <= 7, "Voxel ID must be a known block type");
    }

    #[kani::proof]
    fn verify_query_voxel_ffi_never_panics() {
        let x: i32 = kani::any();
        let y: i32 = kani::any();
        let z: i32 = kani::any();
        let result = query_voxel(x, y, z);
        kani::assert(result >= 0 && result <= 7, "FFI returns a valid known voxel");
    }

    #[kani::proof]
    fn verify_mod_evaluate_action_stays_bounded() {
        let action_type: i32 = kani::any();
        let current_level: i32 = kani::any();
        kani::assume(current_level >= 0 && current_level <= 5);
        let result = mod_evaluate_action(action_type, current_level);
        kani::assert(result >= 0 && result <= 5, "Wanted level must stay 0-5");
    }

    #[kani::proof]
    fn verify_can_fracture_is_boolean() {
        let voxel_type: i32 = kani::any();
        let result = can_fracture(voxel_type);
        kani::assert(result == 0 || result == 1, "can_fracture is 0 or 1");
    }

    #[kani::proof]
    fn verify_loot_item_is_known_or_empty() {
        let voxel_type: i32 = kani::any();
        let item = loot_item(voxel_type);
        kani::assert(item == 0 || item == voxel_type, "loot is empty or the voxel");
        kani::assert(item >= 0 && item <= 7, "loot id stays in the type table");
    }

    #[kani::proof]
    fn verify_wallet_never_goes_negative() {
        let action: i32 = kani::any();
        let wallet: i32 = kani::any();
        let extra: i32 = kani::any();
        kani::assume(wallet >= 0 && wallet <= 1_000_000);
        let result = mod_wallet_after(action, wallet, extra);
        kani::assert(result >= 0 && result <= 1_000_000, "wallet stays in range");
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn empty_layout() -> CityLayout {
        CityLayout {
            width: 1000,
            height: 1000,
            roads: vec![],
            districts: vec![],
        }
    }

    #[test]
    fn voxel_below_ground_is_solid() {
        let layout = empty_layout();
        assert!(layout.get_voxel_at(0, -1, 0) > 0, "below ground must be solid");
        assert!(layout.get_voxel_at(500, -100, 500) > 0);
    }

    #[test]
    fn voxel_high_in_air_is_air() {
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(50, 500, 50), 0, "high altitude should be air");
    }

    #[test]
    fn road_surface_is_asphalt() {
        let layout = empty_layout();
        let voxel = layout.get_voxel_at(0, 0, 0);
        assert_eq!(voxel, 2, "road centre should be asphalt (type 2)");
    }

    #[test]
    fn query_voxel_ffi_matches_get_voxel_at() {
        let layout = empty_layout();
        for (x, y, z) in [(0, 0, 0), (500, 50, 500), (0, -1, 0), (50, 500, 50)] {
            let direct = layout.get_voxel_at(x, y, z) as i32;
            let via_ffi = query_voxel(x, y, z);
            assert_eq!(direct, via_ffi, "FFI wrapper must match direct call at ({x},{y},{z})");
        }
    }

    #[test]
    fn break_block_increases_wanted_level() {
        assert_eq!(mod_evaluate_action(1, 0), 1);
        assert_eq!(mod_evaluate_action(1, 3), 4);
    }

    #[test]
    fn break_block_caps_at_5() {
        assert_eq!(mod_evaluate_action(1, 5), 5, "must not exceed 5 stars");
        assert_eq!(mod_evaluate_action(1, 4), 5);
    }

    #[test]
    fn place_block_no_offense() {
        assert_eq!(mod_evaluate_action(2, 0), 0);
        assert_eq!(mod_evaluate_action(2, 3), 3);
    }

    #[test]
    fn enter_vehicle_grand_theft_auto() {
        assert_eq!(mod_evaluate_action(3, 0), 3);
        assert_eq!(mod_evaluate_action(3, 3), 5, "must cap at 5");
    }

    #[test]
    fn explosion_is_instant_5_stars() {
        assert_eq!(mod_evaluate_action(4, 0), 5);
        assert_eq!(mod_evaluate_action(4, 2), 5);
    }

    #[test]
    fn unknown_action_type_is_neutral() {
        assert_eq!(mod_evaluate_action(99, 2), 2);
        assert_eq!(mod_evaluate_action(-1, 4), 4);
    }

    #[test]
    fn spawn_cop_when_wanted_level_rises() {
        assert_eq!(mod_should_spawn_agent(1, 0, 1), 1, "rising level should spawn cop");
        assert_eq!(mod_should_spawn_agent(4, 2, 5), 1);
    }

    #[test]
    fn no_spawn_when_level_unchanged() {
        assert_eq!(mod_should_spawn_agent(2, 3, 3), 0);
    }

    #[test]
    fn no_spawn_when_level_drops() {
        assert_eq!(mod_should_spawn_agent(0, 5, 3), 0);
    }

    #[test]
    fn no_spawn_when_new_state_is_zero() {
        assert_eq!(mod_should_spawn_agent(1, 0, 0), 0);
    }

    #[test]
    fn break_block_range_is_10() {
        assert!((mod_get_action_range(1) - 10.0).abs() < 1e-6);
    }

    #[test]
    fn explosion_range_is_30() {
        assert!((mod_get_action_range(4) - 30.0).abs() < 1e-6);
    }

    #[test]
    fn enter_vehicle_range_is_5() {
        assert!((mod_get_action_range(3) - 5.0).abs() < 1e-6);
    }

    #[test]
    fn unknown_action_range_defaults_to_10() {
        assert!((mod_get_action_range(99) - 10.0).abs() < 1e-6);
    }

    #[test]
    fn traffic_velocity_is_forward_times_speed() {
        let vx = compute_traffic_vx(1.0, 0.0, false);
        let vz = compute_traffic_vz(0.0, 1.0, false);
        assert!((vx - 10.0).abs() < 1e-6);
        assert!((vz - 10.0).abs() < 1e-6);
    }

    #[test]
    fn traffic_stops_when_blocked() {
        assert!((compute_traffic_vx(1.0, 0.0, true)).abs() < 1e-6);
        assert!((compute_traffic_vz(0.0, 1.0, true)).abs() < 1e-6);
    }

    #[test]
    fn traffic_stationary_when_forward_is_zero() {
        assert!((compute_traffic_vx(0.0, 0.0, false)).abs() < 1e-6);
        assert!((compute_traffic_vz(0.0, 0.0, false)).abs() < 1e-6);
    }

    #[test]
    fn traffic_diagonal_forward() {
        let fwd = 1.0_f32 / 2.0_f32.sqrt();
        let vx = compute_traffic_vx(fwd, fwd, false);
        let vz = compute_traffic_vz(fwd, fwd, false);
        assert!((vx - fwd * 10.0).abs() < 1e-5);
        assert!((vz - fwd * 10.0).abs() < 1e-5);
    }

    #[test]
    fn cop_chases_player_in_x() {
        let vx = compute_agent_vx(1, 0.0, 0.0, 10.0, 0.0);
        assert!(vx > 0.0, "cop should move toward player on x axis");
    }

    #[test]
    fn cop_chases_player_in_z() {
        let vz = compute_agent_vz(1, 0.0, 0.0, 0.0, 10.0);
        assert!(vz > 0.0, "cop should move toward player on z axis");
    }

    #[test]
    fn cop_stops_when_adjacent() {
        let vx = compute_agent_vx(1, 0.0, 0.0, 1.0, 0.0);
        assert!((vx).abs() < 1e-6, "cop too close, should stop");
    }

    #[test]
    fn unknown_ai_type_has_zero_velocity() {
        let vx = compute_agent_vx(99, 0.0, 0.0, 100.0, 100.0);
        let vz = compute_agent_vz(99, 0.0, 0.0, 100.0, 100.0);
        assert!((vx).abs() < 1e-6);
        assert!((vz).abs() < 1e-6);
    }

    #[test]
    fn economy_basic_price() {
        assert_eq!(compute_economy_price(100, 5, 8), 160);
    }

    #[test]
    fn economy_zero_supply_is_scarcity() {
        assert_eq!(compute_economy_price(100, 0, 8), 1000, "zero supply = 10x price");
    }

    #[test]
    fn economy_price_never_below_one() {
        assert_eq!(compute_economy_price(1, 1000, 1), 1, "price floor is 1");
    }

    #[test]
    fn economy_params_unpacked_correctly() {
        let packed = mod_get_economy_params();
        let supply = (packed >> 16) & 0xFFFF;
        let demand = packed & 0xFFFF;
        assert_eq!(supply, 5);
        assert_eq!(demand, 8);
    }

    #[test]
    fn story_quiet_at_low_level() {
        assert_eq!(generate_story_event(0), 0);
        assert_eq!(generate_story_event(4), 0);
    }

    #[test]
    fn story_smash_and_grab_at_mid_level() {
        assert_eq!(generate_story_event(5), 1);
        assert_eq!(generate_story_event(19), 1);
    }

    #[test]
    fn story_armored_truck_at_high_level() {
        assert_eq!(generate_story_event(20), 2);
        assert_eq!(generate_story_event(100), 2);
    }

    #[test]
    fn storyteller_level_returns_positive() {
        let level = mod_get_storyteller_level();
        assert!(level >= 0, "storyteller level must be non-negative");
    }

    #[test]
    fn player_spawns_in_city() {
        let (x, y, z) = player_spawn();
        assert_eq!((x, y, z), (490, 50, 490));
    }

    #[test]
    fn vehicle_spawns_are_near_player() {
        assert_eq!(vehicle_spawn_count(), 6);
        let (x, y, z) = vehicle_spawn(0);
        assert_eq!((x, y, z), (500, 50, 495));
        let (x2, _, _) = vehicle_spawn(1);
        assert_eq!(x2, 510);
    }

    #[test]
    fn buildings_fracture_roads_do_not() {
        assert_eq!(can_fracture(1), 1);
        assert_eq!(can_fracture(3), 1);
        assert_eq!(can_fracture(6), 1);
        assert_eq!(can_fracture(2), 0);
        assert_eq!(can_fracture(5), 0);
        assert_eq!(can_fracture(7), 0);
        assert_eq!(can_fracture(0), 0);
    }

    #[test]
    fn glass_spreads_further_than_concrete() {
        assert!(fracture_spread(3) > fracture_spread(1));
        assert_eq!(fracture_spread(2), 0);
    }

    #[test]
    fn explosion_impulse_stronger_than_melee() {
        assert!(debris_impulse(4) > debris_impulse(1));
    }

    #[test]
    fn wanted_decays_one_star_per_eight_seconds() {
        assert_eq!(mod_tick(3, 8000), 2);
        assert_eq!(mod_tick(1, 8000), 0);
        assert_eq!(mod_tick(4, 1000), 4, "partial interval must not decay");
        assert_eq!(mod_tick(0, 8000), 0);
    }

    #[test]
    fn cops_despawn_when_clear_pedestrians_stay() {
        assert_eq!(should_despawn_agent(1, 0), 1);
        assert_eq!(should_despawn_agent(1, 2), 0);
        assert_eq!(should_despawn_agent(2, 0), 0);
    }

    #[test]
    fn pedestrians_stroll_east_and_yield() {
        let vx = compute_agent_vx(2, 0.0, 0.0, 100.0, 0.0);
        assert!((vx - 3.0).abs() < 1e-5);
        assert!((compute_agent_vz(2, 0.0, 0.0, 100.0, 0.0)).abs() < 1e-6);
        assert!((compute_agent_vx(2, 0.0, 0.0, 1.0, 0.0)).abs() < 1e-6);
    }

    #[test]
    fn ambient_agents_are_pedestrians_on_the_street() {
        assert_eq!(ambient_agent_count(), 6);
        let (x, y, _z, kind) = ambient_agent_spawn(0);
        assert_eq!(kind, 2);
        assert!(y < 10, "pedestrians walk the street, not rooftops");
        assert!(x >= 500);
    }

    #[test]
    fn voxel_labels_cover_city_materials() {
        assert_eq!(voxel_label(2), "asphalt");
        assert_eq!(voxel_label(3), "glass");
        assert_eq!(voxel_label(6), "tile");
        assert_eq!(voxel_label(7), "rail");
        assert_eq!(voxel_label(99), "unknown");
    }

    #[test]
    fn sidewalk_is_beside_the_road() {
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(4, 0, 10), 4);
    }

    #[test]
    fn subway_runs_under_the_street() {
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(1, -8, 20), 6, "tunnel floor is tile");
        assert_eq!(layout.get_voxel_at(1, -7, 20), 7, "centerline is rail");
        assert_eq!(layout.get_voxel_at(0, -7, 20), 0, "tunnel air beside the rail");
        assert_eq!(layout.get_voxel_at(0, -2, 0), 1, "slab under the asphalt");
        assert_eq!(layout.get_voxel_at(0, -20, 0), 1, "bedrock");
    }

    #[test]
    fn metro_shaft_and_station_at_intersection() {
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(4, 0, 4), 0, "shaft opening in the sidewalk");
        assert_eq!(layout.get_voxel_at(4, -4, 4), 0, "shaft down to the platform");
        assert_eq!(layout.get_voxel_at(1, -8, 1), 6, "station floor");
        assert_eq!(layout.get_voxel_at(1, -6, 1), 0, "station hall");
    }

    #[test]
    fn loot_drops_breakable_city_blocks() {
        assert_eq!(loot_item(1), 1);
        assert_eq!(loot_item(3), 3);
        assert_eq!(loot_item(6), 6);
        assert_eq!(loot_item(5), 5);
        assert_eq!(loot_item(2), 0);
        assert_eq!(loot_item(7), 0);
        assert_eq!(loot_item(0), 0);
        assert_eq!(item_label_for("en", 6), "tile");
        assert_eq!(item_label_for("mi", 6), "tāera");
        assert_eq!(item_label_for("fr", 7), "rail");
        assert_eq!(item_label_for("zh-TW", 6), "磁磚");
        assert!(item_label_for("en", 0).is_empty());
    }

    #[test]
    fn story_event_labels_are_heists_not_aliens() {
        assert_eq!(event_label(0), "quiet streets");
        assert_eq!(event_label(1), "smash-and-grab contract");
        assert_eq!(event_label(2), "armored-truck heist");
    }

    #[test]
    fn voxel_and_story_follow_locale() {
        assert_eq!(voxel_label_for("mi", 2), "huarahi tā");
        assert_eq!(voxel_label_for("mi", 6), "tāera");
        assert_eq!(voxel_label_for("fr", 3), "verre");
        assert_eq!(voxel_label_for("fr", 7), "rail");
        assert_eq!(voxel_label_for("zh-TW", 2), "柏油");
        assert_eq!(voxel_label_for("zh-TW", 6), "磁磚");
        assert_eq!(voxel_label_for("de", 2), "asphalt", "unknown locale falls back to English");
        assert_eq!(event_label_for("mi", 0), "ngā huarahi mārie");
        assert_eq!(event_label_for("fr", 2), "casse de fourgon blindé");
        assert_eq!(event_label_for("zh-Hant", 1), "搶劫合約");
        assert_eq!(contract_label_for("en", 1), "smash-and-grab");
        assert_eq!(contract_label_for("zh-TW", 2), "運鈔車搶案");
        assert_eq!(supported_locales(), "en,mi,fr,zh-TW");
    }

    #[test]
    fn clean_player_is_offered_an_atm_job() {
        assert_eq!(mod_offer_contract(0), (1, 250, 1));
    }

    #[test]
    fn high_wanted_unlocks_armored_truck() {
        assert_eq!(mod_offer_contract(4), (2, 1200, 4));
    }

    #[test]
    fn scrap_and_stolen_cars_pay_credits() {
        assert_eq!(mod_wallet_after(1, 0, 0), 5);
        assert_eq!(mod_wallet_after(3, 10, 0), 60);
        assert_eq!(mod_wallet_after(2, 10, 0), 10);
    }

    #[test]
    fn completing_a_heist_pays_the_payout() {
        assert_eq!(mod_wallet_after(6, 100, 250), 350);
        assert_eq!(mod_wallet_after(6, 100, -50), 100, "negative extra must not drain");
    }

    #[test]
    fn fencing_uses_the_city_market() {
        let after = mod_wallet_after(7, 0, 0);
        assert_eq!(after, compute_economy_price(80, 5, 8));
        assert!(after > 0);
    }

    #[test]
    fn accept_needs_an_offer() {
        assert_eq!(mod_can_complete(5, 0, 0, 0), 0);
        assert_eq!(mod_can_complete(5, 0, 1, 1), 1);
    }

    #[test]
    fn complete_needs_enough_heat() {
        assert_eq!(mod_can_complete(6, 0, 1, 1), 0);
        assert_eq!(mod_can_complete(6, 1, 1, 1), 1);
        assert_eq!(mod_can_complete(6, 3, 2, 4), 0);
        assert_eq!(mod_can_complete(6, 4, 2, 4), 1);
    }

    #[test]
    fn fence_only_when_cold() {
        assert_eq!(mod_can_complete(7, 0, 0, 0), 1);
        assert_eq!(mod_can_complete(7, 2, 0, 0), 0);
    }

    #[test]
    fn accept_is_not_a_crime() {
        assert_eq!(mod_evaluate_action(5, 2), 2);
    }
}
