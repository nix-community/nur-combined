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

pub mod soft_body;

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

/// City materials. Meshing uses the catalog index; gameplay always uses the English name.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[repr(u8)]
pub enum Voxel {
    Air = 0,
    Concrete = 1,
    Asphalt = 2,
    Glass = 3,
    Sidewalk = 4,
    Grass = 5,
    Tile = 6,
    Rail = 7,
    Workbench = 8,
    Brick = 9,
    Drill = 10,
}

impl Voxel {
    pub const CATALOG: &[&str] = &[
        "air",
        "concrete",
        "asphalt",
        "glass",
        "sidewalk",
        "grass",
        "tile",
        "rail",
        "workbench",
        "brick",
        "drill",
    ];

    pub fn name(self) -> &'static str {
        Self::CATALOG[self as usize]
    }

    pub fn index(self) -> u8 {
        self as u8
    }

    pub fn from_name(name: &str) -> Option<Self> {
        match name {
            "air" => Some(Self::Air),
            "concrete" => Some(Self::Concrete),
            "asphalt" => Some(Self::Asphalt),
            "glass" => Some(Self::Glass),
            "sidewalk" => Some(Self::Sidewalk),
            "grass" => Some(Self::Grass),
            "tile" => Some(Self::Tile),
            "rail" => Some(Self::Rail),
            "workbench" => Some(Self::Workbench),
            "brick" => Some(Self::Brick),
            "drill" => Some(Self::Drill),
            _ => None,
        }
    }

    pub fn is_solid(self) -> bool {
        self != Self::Air
    }
}

pub const ACTION_BREAK: &str = "break";
pub const ACTION_PLACE: &str = "place";
pub const ACTION_ENTER: &str = "enter_vehicle";
pub const ACTION_EXPLODE: &str = "explode";
pub const ACTION_ACCEPT: &str = "accept_contract";
pub const ACTION_COMPLETE: &str = "complete_contract";
pub const ACTION_FENCE: &str = "fence";
pub const ACTION_CRAFT: &str = "craft";
pub const ACTION_CRASH: &str = "crash";

pub const PART_HULL: &str = "hull";
pub const PART_CABIN: &str = "cabin";
pub const PART_WHEEL: &str = "wheel";
pub const PART_LAMP: &str = "lamp";

pub const AGENT_COP: &str = "cop";
pub const AGENT_PEDESTRIAN: &str = "pedestrian";
pub const AGENT_TRAIN: &str = "train";

pub const CONTRACT_SMASH: &str = "smash-and-grab";
pub const CONTRACT_SUBWAY: &str = "subway-pinch";
pub const CONTRACT_CHOP: &str = "chop-shop";
pub const CONTRACT_TRUCK: &str = "armored-truck";
pub const CONTRACT_DRILL: &str = "drill-heist";
pub const CONTRACT_BANK: &str = "bank-robbery";

pub const EVENT_QUIET: &str = "quiet-streets";
pub const EVENT_SMASH: &str = "smash-and-grab-contract";
pub const EVENT_SUBWAY: &str = "subway-pinch-contract";
pub const EVENT_CHOP: &str = "chop-shop-contract";
pub const EVENT_TRUCK: &str = "armored-truck-heist";
pub const EVENT_DRILL: &str = "drill-heist-contract";
pub const EVENT_BANK: &str = "bank-robbery-heist";

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

    /// Queries the 3D voxel at a specific coordinate based on the 2D layout.
    pub fn get_voxel_at(&self, x: i32, y: i32, z: i32) -> Voxel {
        let mod_x = (x % 100).abs();
        let mod_z = (z % 100).abs();

        let is_road_x = mod_x < 3;
        let is_road_z = mod_z < 3;
        let is_sidewalk_x = mod_x >= 3 && mod_x < 5;
        let is_sidewalk_z = mod_z >= 3 && mod_z < 5;
        let is_road = is_road_x || is_road_z;
        let is_sidewalk = (is_sidewalk_x || is_sidewalk_z) && !is_road;

        if y < -12 {
            return Voxel::Concrete;
        }

        // Sidewalk shafts at 200 m intersections (metro access).
        let shaft = is_sidewalk && near_period(x, 200, 5) && near_period(z, 200, 5);
        if shaft && (-8..=0).contains(&y) {
            if y == -8 {
                return Voxel::Tile;
            }
            return Voxel::Air;
        }

        // Station hall under the same intersections.
        let station = (is_road || is_sidewalk) && near_period(x, 200, 8) && near_period(z, 200, 8);
        if station && (-8..=-4).contains(&y) {
            if y == -8 {
                return Voxel::Tile;
            }
            return Voxel::Air;
        }

        if is_road && (-8..-2).contains(&y) {
            if y == -8 {
                return Voxel::Tile;
            }
            if y == -7 && ((is_road_x && mod_x == 1) || (is_road_z && mod_z == 1)) {
                return Voxel::Rail;
            }
            return Voxel::Air;
        }
        if is_road && y == -2 {
            return Voxel::Concrete;
        }

        if y < 0 {
            return Voxel::Concrete;
        }

        let cell_x = x - (x % 100) + 50;
        let cell_z = z - (z % 100) + 50;

        let prng = (cell_x.abs() * 73 + cell_z.abs() * 37) % 100;
        let is_park = prng < 15;

        if y == 0 {
            if is_road {
                return Voxel::Asphalt;
            }
            if is_sidewalk {
                return Voxel::Sidewalk;
            }
            if is_park {
                return Voxel::Grass;
            }
        }

        // Street benches sit on the sidewalk, not over metro shafts.
        if y == 1 && is_sidewalk && !shaft {
            let bench = (mod_x == 4 && mod_z == 20) || (mod_z == 4 && mod_x == 20);
            if bench {
                return Voxel::Workbench;
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
                    return Voxel::Glass;
                }
                return Voxel::Concrete;
            }
            if y >= max_height && y < max_height + 5 && local_x == 0 && local_z == 0 && prng % 2 == 0
            {
                return Voxel::Concrete;
            }
        }

        Voxel::Air
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

pub fn voxel_catalog() -> String {
    Voxel::CATALOG.join(",")
}

pub fn query_voxel(x: i32, y: i32, z: i32) -> i32 {
    city().get_voxel_at(x, y, z).index() as i32
}

/// Urban Chaos: state is the Wanted Level (0-5).
pub fn mod_evaluate_action(action: &str, current_state: i32) -> i32 {
    match action {
        ACTION_BREAK => current_state.saturating_add(1).min(5),
        ACTION_PLACE => current_state,
        ACTION_ENTER => current_state.saturating_add(3).min(5),
        ACTION_EXPLODE => 5,
        ACTION_ACCEPT => current_state,
        ACTION_COMPLETE => current_state.saturating_add(1).min(5),
        ACTION_FENCE => current_state,
        ACTION_CRAFT => current_state,
        ACTION_CRASH => current_state.saturating_add(2).min(5),
        _ => current_state,
    }
}

pub fn mod_should_spawn_agent(_action: &str, old_state: i32, new_state: i32) -> String {
    if new_state > old_state && new_state > 0 {
        AGENT_COP.into()
    } else {
        String::new()
    }
}

pub fn compute_economy_price(base_price: i32, supply: i32, demand: i32) -> i32 {
    if supply == 0 {
        return base_price * 10;
    }
    ((base_price * demand) / supply).max(1)
}

pub fn mod_get_action_range(action: &str) -> f32 {
    match action {
        ACTION_BREAK | ACTION_PLACE => 10.0,
        ACTION_ENTER => 5.0,
        ACTION_EXPLODE => 30.0,
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

pub fn generate_story_event(player_level: i32) -> String {
    match player_level.clamp(0, 5) {
        0 => EVENT_QUIET.into(),
        1 => EVENT_SMASH.into(),
        2 => EVENT_SUBWAY.into(),
        3 => EVENT_CHOP.into(),
        4 => EVENT_TRUCK.into(),
        _ => EVENT_DRILL.into(),
    }
}

pub fn player_spawn() -> (i32, i32, i32) {
    (504, 2, 508)
}

pub fn vehicle_spawn_count() -> i32 {
    6
}

pub fn vehicle_spawn(index: i32) -> (i32, i32, i32) {
    if index <= 0 {
        (500, 2, 495)
    } else {
        (510 + (index - 1) * 10, 2, 495)
    }
}

const CAR_BODIES: [[f32; 3]; 6] = [
    [0.22, 0.24, 0.28],
    [0.18, 0.32, 0.22],
    [0.42, 0.40, 0.36],
    [0.12, 0.14, 0.38],
    [0.48, 0.18, 0.14],
    [0.72, 0.72, 0.70],
];

const CAR_PLAYER: [f32; 3] = [0.78, 0.18, 0.14];
const CAR_CABIN: [f32; 3] = [0.12, 0.16, 0.20];
const CAR_WHEEL: [f32; 3] = [0.08, 0.08, 0.09];
const CAR_LAMP: [f32; 3] = [0.92, 0.86, 0.55];

/// Street car kit. The host only builds boxes; this game owns the car.
pub fn vehicle_kit(index: i32) -> hanga::engine::host::Value {
    let player = index <= 0;
    let body = if player {
        CAR_PLAYER
    } else {
        CAR_BODIES[((index - 1) as usize) % CAR_BODIES.len()]
    };
    let mut parts = vec![
        part_dict(PART_HULL, [1.85, 0.48, 3.80], [0.0, -0.22, 0.0], body),
        part_dict(PART_CABIN, [1.55, 0.50, 1.70], [0.0, 0.24, 0.45], CAR_CABIN),
        part_dict(PART_LAMP, [0.18, 0.12, 0.10], [-0.62, -0.08, -1.88], CAR_LAMP),
        part_dict(PART_LAMP, [0.18, 0.12, 0.10], [0.62, -0.08, -1.88], CAR_LAMP),
    ];
    for (x, z) in [(-0.82, -1.15), (0.82, -1.15), (-0.82, 1.20), (0.82, 1.20)] {
        parts.push(part_dict(
            PART_WHEEL,
            [0.28, 0.42, 0.42],
            [x, -0.42, z],
            CAR_WHEEL,
        ));
    }
    wire_dict(vec![
        field("kind", atom_text("car")),
        field("traffic", atom_flag(!player)),
        field("speed", atom_float(25.0)),
        field("stiffness", atom_int(32)),
        field("tires", wire_list(vec![atom_text("wheel")])),
        field(
            "collider",
            wire_dict(vec![
                field("x", atom_float(2.0)),
                field("y", atom_float(1.2)),
                field("z", atom_float(4.0)),
            ]),
        ),
        field(
            "beams",
            wire_list(vec![
                beam_dict("hull", "cabin"),
                beam_dict("cabin", "lamp"),
                beam_dict("hull", "wheel"),
                beam_dict("hull", "lamp"),
            ]),
        ),
        field("parts", wire_list(parts)),
    ])
}

/// Earth streets. The host only applies the field; this game owns "down".
pub fn gravity() -> hanga::engine::host::Value {
    wire_dict(vec![
        field("kind", atom_text("constant")),
        field("x", atom_float(0.0)),
        field("y", atom_float(-9.81)),
        field("z", atom_float(0.0)),
        field("jump", atom_float(5.0)),
        field("walk", atom_float(10.0)),
    ])
}

/// Buildings and station tiles shatter; roads, rails, and ground stay put.
pub fn can_fracture(voxel: &str) -> i32 {
    match voxel {
        "concrete" | "glass" | "tile" | "workbench" | "brick" => 1,
        _ => 0,
    }
}

pub fn fracture_spread(voxel: &str) -> i32 {
    match voxel {
        "glass" => 3,
        "concrete" | "tile" | "brick" => 2,
        "workbench" => 1,
        _ => 0,
    }
}

pub fn debris_impulse(action: &str) -> f32 {
    match action {
        ACTION_EXPLODE => 15.0,
        ACTION_BREAK | ACTION_CRASH => 5.0,
        _ => 2.0,
    }
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
pub fn should_despawn_agent(agent: &str, current_state: i32) -> i32 {
    if agent == AGENT_COP && current_state <= 0 {
        1
    } else {
        0
    }
}

pub fn ambient_agent_count() -> i32 {
    8
}

pub fn ambient_agent_spawn(index: i32) -> (i32, i32, i32, String) {
    let i = index.max(0);
    if i >= 6 {
        let z = 400 + (i - 6) * 100;
        return (400, -7, z, AGENT_TRAIN.into());
    }
    (502 + i * 8, 2, 500, AGENT_PEDESTRIAN.into())
}

pub fn voxel_label(voxel: &str) -> String {
    voxel_label_for("en", voxel)
}

pub fn voxel_label_for(locale: &str, voxel: &str) -> String {
    let lang = locale_id(locale);
    match (lang, voxel) {
        (1, "air") => "hau",
        (1, "concrete") => "raima",
        (1, "asphalt") => "huarahi tā",
        (1, "glass") => "karaihe",
        (1, "sidewalk") => "ara hīkoi",
        (1, "grass") => "pātītī",
        (1, "tile") => "tāera",
        (1, "rail") => "rerewē",
        (1, "workbench") => "pae mahi",
        (1, "brick") => "pereki",
        (1, _) => "tē mōhiotia",
        (2, "air") => "air",
        (2, "concrete") => "béton",
        (2, "asphalt") => "asphalte",
        (2, "glass") => "verre",
        (2, "sidewalk") => "trottoir",
        (2, "grass") => "herbe",
        (2, "tile") => "carrelage",
        (2, "rail") => "rail",
        (2, "workbench") => "établi",
        (2, "brick") => "brique",
        (2, _) => "inconnu",
        (3, "air") => "空氣",
        (3, "concrete") => "混凝土",
        (3, "asphalt") => "柏油",
        (3, "glass") => "玻璃",
        (3, "sidewalk") => "人行道",
        (3, "grass") => "草地",
        (3, "tile") => "磁磚",
        (3, "rail") => "鐵軌",
        (3, "workbench") => "工作台",
        (3, "brick") => "磚塊",
        (3, _) => "未知",
        (_, "air") => "air",
        (_, "concrete") => "concrete",
        (_, "asphalt") => "asphalt",
        (_, "glass") => "glass",
        (_, "sidewalk") => "sidewalk",
        (_, "grass") => "grass",
        (_, "tile") => "tile",
        (_, "rail") => "rail",
        (_, "workbench") => "workbench",
        (_, "brick") => "brick",
        _ => "unknown",
    }
    .into()
}

/// Heist board. Danger is min wanted to cash out.
pub fn heist_for_wanted(wanted: i32) -> (&'static str, i32, i32) {
    match wanted {
        i if i >= 5 => (CONTRACT_BANK, 5000, 5),
        4 => (CONTRACT_DRILL, 2000, 4),
        3 => (CONTRACT_TRUCK, 1200, 4),
        2 => (CONTRACT_CHOP, 500, 2),
        1 => (CONTRACT_SUBWAY, 600, 2),
        _ => (CONTRACT_SMASH, 250, 1),
    }
}

/// World mark the host paints. Need rules live in `mod_can_complete`.
pub fn contract_mark(kind: &str) -> hanga::engine::host::Value {
    let (x, y, z, radius, take, r, g, b) = match kind {
        CONTRACT_SMASH => (531, 3, 550, 14.0, true, 0.92, 0.28, 0.22),
        CONTRACT_SUBWAY => (400, -6, 400, 16.0, false, 0.35, 0.72, 0.82),
        CONTRACT_CHOP => (504, 2, 520, 10.0, true, 0.78, 0.52, 0.22),
        CONTRACT_TRUCK => (510, 2, 495, 12.0, false, 0.22, 0.28, 0.72),
        CONTRACT_DRILL => (490, 2, 530, 12.0, true, 0.40, 0.40, 0.80),
        CONTRACT_BANK => (550, -4, 550, 12.0, true, 1.0, 0.84, 0.0),
        _ => return wire_empty(),
    };
    wire_dict(vec![
        field("x", atom_int(x)),
        field("y", atom_int(y)),
        field("z", atom_int(z)),
        field("radius", atom_float(radius)),
        field("take", atom_flag(take)),
        field("r", atom_float(r)),
        field("g", atom_float(g)),
        field("b", atom_float(b)),
    ])
}

pub fn mod_offer_contract(player_state: i32) -> (String, i32, i32) {
    let (kind, payout, danger) = heist_for_wanted(player_state.clamp(0, 5));
    (kind.into(), payout, danger)
}

pub fn event_label(event: &str) -> String {
    event_label_for("en", event)
}

pub fn event_label_for(locale: &str, event: &str) -> String {
    let lang = locale_id(locale);
    match (lang, event) {
        (1, EVENT_QUIET) => "ngā huarahi mārie",
        (1, EVENT_SMASH) => "kirimina pakaru-hopu",
        (1, EVENT_SUBWAY) => "hopu rerewē",
        (1, EVENT_CHOP) => "oma toa tapahi",
        (1, EVENT_TRUCK) => "keehi taraka pākaha",
        (1, _) => "takahanga tē mōhiotia",
        (2, EVENT_QUIET) => "rues calmes",
        (2, EVENT_SMASH) => "contrat de vol à la sauvette",
        (2, EVENT_SUBWAY) => "pincement du métro",
        (2, EVENT_CHOP) => "course à l'atelier",
        (2, EVENT_TRUCK) => "casse de fourgon blindé",
        (2, _) => "événement inconnu",
        (3, EVENT_QUIET) => "平靜的街道",
        (3, EVENT_SMASH) => "搶劫合約",
        (3, EVENT_SUBWAY) => "地鐵扒竊",
        (3, EVENT_CHOP) => "拆車廠跑單",
        (3, EVENT_TRUCK) => "運鈔車搶案",
        (3, EVENT_DRILL) => "鑽頭搶案",
        (3, EVENT_BANK) => "銀行搶劫案",
        (3, _) => "未知事件",
        (_, EVENT_QUIET) => "quiet streets",
        (_, EVENT_SMASH) => "smash-and-grab contract",
        (_, EVENT_SUBWAY) => "subway pinch",
        (_, EVENT_CHOP) => "chop-shop run",
        (_, EVENT_TRUCK) => "armored-truck heist",
        (_, EVENT_DRILL) => "drill-heist contract",
        (_, EVENT_BANK) => "bank-robbery heist",
        _ => "unknown event",
    }
    .into()
}

pub fn loot_item(voxel: &str) -> String {
    match voxel {
        "concrete" | "glass" | "grass" | "tile" | "workbench" | "brick" => voxel.into(),
        _ => String::new(),
    }
}

pub fn item_label_for(locale: &str, item: &str) -> String {
    if item.is_empty() {
        return String::new();
    }
    voxel_label_for(locale, item)
}

/// Street recipes: scrap pairs plus workbench / brick loops.
pub fn craft_result(item_a: &str, item_b: &str) -> String {
    let (a, b) = if item_a <= item_b {
        (item_a, item_b)
    } else {
        (item_b, item_a)
    };
    match (a, b) {
        ("concrete", "concrete") => "sidewalk".into(),
        ("concrete", "glass") => "tile".into(),
        ("grass", "grass") => "concrete".into(),
        ("tile", "tile") => "rail".into(),
        ("glass", "glass") => "workbench".into(),
        ("glass", "sidewalk") => "workbench".into(),
        ("concrete", "grass") => "brick".into(),
        ("concrete", "workbench") => "brick".into(),
        ("brick", "brick") => "concrete".into(),
        ("rail", "workbench") => "drill".into(),
        _ => String::new(),
    }
}

/// Soft street metal: BeamNG-like fold, not a node-beam solver.
pub fn crash_severity(speed: f32, into_solid: bool) -> i32 {
    let speed = speed.max(0.0);
    if speed < 8.0 {
        return 0;
    }
    if !into_solid && speed < 10.0 {
        return 0;
    }
    if speed < 14.0 {
        25
    } else if speed < 20.0 {
        50
    } else if speed < 28.0 {
        75
    } else {
        100
    }
}

pub fn crash_crumple(severity: i32) -> i32 {
    severity.clamp(0, 100)
}

pub fn crash_detach(part: &str, severity: i32) -> i32 {
    let need = match part {
        PART_LAMP => 25,
        PART_WHEEL => 50,
        PART_CABIN => 75,
        PART_HULL => 101,
        _ => 101,
    };
    i32::from(severity >= need)
}

pub fn crash_wrecks(severity: i32) -> i32 {
    i32::from(severity >= 75)
}

pub fn crash_action(severity: i32) -> String {
    if severity >= 100 {
        ACTION_EXPLODE.into()
    } else if severity >= 50 {
        ACTION_CRASH.into()
    } else {
        String::new()
    }
}

pub fn crash_ignites(severity: i32) -> i32 {
    i32::from(severity >= 75)
}

pub fn crash_part_impulse(severity: i32) -> f32 {
    4.0 + (severity.clamp(0, 100) as f32) * 0.12
}

pub fn crash_kit(speed: f32, into_solid: bool) -> hanga::engine::host::Value {
    let severity = crash_severity(speed, into_solid);
    if severity <= 0 {
        return wire_empty();
    }
    let mut fields = vec![
        field("severity", atom_int(severity as i64)),
        field("crumple", atom_int(crash_crumple(severity) as i64)),
        field("wrecks", atom_flag(crash_wrecks(severity) != 0)),
        field("ignites", atom_flag(crash_ignites(severity) != 0)),
        field("impulse", atom_float(crash_part_impulse(severity) as f64)),
    ];
    let action = crash_action(severity);
    if !action.is_empty() {
        fields.push(field("action", atom_text(action)));
    }
    let mut detach = Vec::new();
    for part in [PART_LAMP, PART_WHEEL, PART_CABIN] {
        if crash_detach(part, severity) == 1 {
            detach.push(atom_text(part));
        }
    }
    if !detach.is_empty() {
        fields.push(field("detach", wire_list(detach)));
    }
    wire_dict(fields)
}

pub const FIRE_FUEL_MS: i32 = 12_000;
pub const FIRE_BURST_MS: i32 = 8_000;

pub fn fire_kit(age_ms: i32, nearby: &str) -> hanga::engine::host::Value {
    if age_ms >= FIRE_FUEL_MS {
        return wire_dict(vec![field("out", atom_flag(true))]);
    }
    let consume = matches!(nearby, "glass" | "tile" | "workbench" | "grass");
    let heat = 0.45 + (age_ms as f32 / FIRE_FUEL_MS as f32) * 0.9;
    wire_dict(vec![
        field("heat", atom_float(heat as f64)),
        field("range", atom_float(6.0)),
        field("consume", atom_flag(consume)),
        field("jump", atom_flag(age_ms >= 400)),
        field("burst", atom_flag(age_ms >= FIRE_BURST_MS)),
        field("out", atom_flag(false)),
    ])
}

pub fn contract_label(kind: &str) -> String {
    contract_label_for("en", kind)
}

pub fn contract_label_for(locale: &str, kind: &str) -> String {
    if kind.is_empty() {
        return String::new();
    }
    let lang = locale_id(locale);
    match (lang, kind) {
        (1, CONTRACT_SMASH) => "kirimina pakaru-hopu",
        (1, CONTRACT_SUBWAY) => "hopu rerewē",
        (1, CONTRACT_CHOP) => "toa tapahi",
        (1, CONTRACT_TRUCK) => "keehi taraka pākaha",
        (1, CONTRACT_DRILL) => "pāhua drill",
        (1, CONTRACT_BANK) => "pāhua pēke",
        (1, _) => "mahi tē mōhiotia",
        (2, CONTRACT_SMASH) => "vol à la sauvette",
        (2, CONTRACT_SUBWAY) => "pincement du métro",
        (2, CONTRACT_CHOP) => "atelier de découpe",
        (2, CONTRACT_TRUCK) => "fourgon blindé",
        (2, CONTRACT_DRILL) => "casse par forage",
        (2, CONTRACT_BANK) => "braquage de banque",
        (2, _) => "contrat inconnu",
        (3, CONTRACT_SMASH) => "搶劫合約",
        (3, CONTRACT_SUBWAY) => "地鐵扒竊",
        (3, CONTRACT_CHOP) => "拆車廠",
        (3, CONTRACT_TRUCK) => "運鈔車搶案",
        (3, CONTRACT_DRILL) => "鑽頭搶案",
        (3, CONTRACT_BANK) => "銀行搶劫",
        (3, _) => "未知任務",
        (_, CONTRACT_SMASH) => "smash-and-grab",
        (_, CONTRACT_SUBWAY) => "subway pinch",
        (_, CONTRACT_CHOP) => "chop-shop",
        (_, CONTRACT_TRUCK) => "armored-truck heist",
        (_, CONTRACT_DRILL) => "drill-heist",
        (_, CONTRACT_BANK) => "bank-robbery",
        _ => "unknown contract",
    }
    .into()
}

/// extra is payout for complete, unused otherwise.
pub fn mod_wallet_after(action: &str, current_wallet: i32, extra: i32) -> i32 {
    let next = match action {
        ACTION_BREAK => current_wallet.saturating_add(5),
        ACTION_ENTER => current_wallet.saturating_add(50),
        ACTION_COMPLETE => current_wallet.saturating_add(extra.max(0)),
        ACTION_FENCE => {
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
    action: &str,
    player_state: i32,
    contract_kind: &str,
    contract_danger: i32,
    held: &str,
    y: i32,
    vehicle: bool,
    near: bool,
) -> i32 {
    match action {
        ACTION_ACCEPT => i32::from(!contract_kind.is_empty()),
        ACTION_COMPLETE => {
            if contract_kind.is_empty() || player_state < contract_danger {
                return 0;
            }
            i32::from(match contract_kind {
                CONTRACT_SMASH => near && held_one_of(held, &["glass", "tile"]),
                CONTRACT_SUBWAY => near && y < 0,
                CONTRACT_CHOP => near && held_one_of(held, &["brick", "concrete", "workbench"]),
                CONTRACT_TRUCK => near && vehicle,
                CONTRACT_DRILL => near && held == "workbench",
                CONTRACT_BANK => near && y < 0 && held == "drill",
                _ => near,
            })
        }
        ACTION_FENCE => i32::from(player_state <= 0),
        _ => 0,
    }
}

fn held_one_of(held: &str, names: &[&str]) -> bool {
    names.iter().any(|name| *name == held)
}

pub fn compute_agent_vx(agent: &str, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
    match agent {
        AGENT_COP => {
            let dx = px - cx;
            let dz = pz - cz;
            let len = (dx * dx + dz * dz).sqrt();
            if len < 2.0 {
                return 0.0;
            }
            (dx / len) * 8.0
        }
        AGENT_PEDESTRIAN => {
            let dx = px - cx;
            let dz = pz - cz;
            if dx * dx + dz * dz < 2.25 {
                0.0
            } else {
                3.0
            }
        }
        AGENT_TRAIN => 0.0,
        _ => 0.0,
    }
}

pub fn compute_agent_vz(agent: &str, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
    match agent {
        AGENT_COP => {
            let dx = px - cx;
            let dz = pz - cz;
            let len = (dx * dx + dz * dz).sqrt();
            if len < 2.0 {
                return 0.0;
            }
            (dz / len) * 8.0
        }
        AGENT_PEDESTRIAN => 0.0,
        AGENT_TRAIN => 25.0,
        _ => 0.0,
    }
}

pub fn on_message(from: &str, topic: &str, payload: &hanga::engine::host::Value) -> hanga::engine::host::Value {
    if let Some(reply) = host_bus_reply(topic, payload) {
        return reply;
    }
    match topic {
        "ping" => wire_text("pong"),
        "name" => wire_text("urban_chaos"),
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
        "has" => bus_has(BUS_TOPICS, payload),
        "methods" => wire_methods(BUS_TOPICS),
        _ => wire_empty(),
    }
}

impl exports::hanga::engine::guest::Guest for UrbanChaosMod {
    fn abi() -> i32 {
        6
    }

    fn ready() {
        let _ = city();
        crate::greet_peers();
        crate::host_log("info", "urban_chaos ready");
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

// ─── Soft-Body Solver (BeamNG-style) ──────────────────────────────────────────

#[derive(Clone, Copy)]
pub struct Node {
    pub mass: f32,
    pub px: f32, pub py: f32, pub pz: f32,
    pub vx: f32, pub vy: f32, pub vz: f32,
}

#[derive(Clone, Copy)]
pub struct Beam {
    pub node_a: usize,
    pub node_b: usize,
    pub rest_length: f32,
    pub stiffness: f32,
    pub damping: f32,
    pub plastic_yield: f32,
}

pub fn tick_softbody(nodes: &mut [Node], beams: &mut [Beam], dt: f32) {
    // Spring-damper forces
    for beam in beams.iter_mut() {
        let a = nodes[beam.node_a];
        let b = nodes[beam.node_b];
        
        let dx = b.px - a.px;
        let dy = b.py - a.py;
        let dz = b.pz - a.pz;
        
        let dist = (dx * dx + dy * dy + dz * dz).sqrt().max(0.001);
        let deformation = dist - beam.rest_length;
        
        // Plastic yield: permanently deform rest length if stressed too much
        if deformation.abs() > beam.plastic_yield {
            beam.rest_length += deformation * 0.1 * dt; 
        }
        
        let force_mag = deformation * beam.stiffness;
        
        let rel_vx = b.vx - a.vx;
        let rel_vy = b.vy - a.vy;
        let rel_vz = b.vz - a.vz;
        let rel_v_proj = (rel_vx * dx + rel_vy * dy + rel_vz * dz) / dist;
        let damping_force = rel_v_proj * beam.damping;
        
        let total_force = force_mag + damping_force;
        
        let fx = (dx / dist) * total_force;
        let fy = (dy / dist) * total_force;
        let fz = (dz / dist) * total_force;
        
        nodes[beam.node_a].vx += fx / a.mass * dt;
        nodes[beam.node_a].vy += fy / a.mass * dt;
        nodes[beam.node_a].vz += fz / a.mass * dt;
        
        nodes[beam.node_b].vx -= fx / b.mass * dt;
        nodes[beam.node_b].vy -= fy / b.mass * dt;
        nodes[beam.node_b].vz -= fz / b.mass * dt;
    }
    
    // Integration
    for node in nodes.iter_mut() {
        node.px += node.vx * dt;
        node.py += node.vy * dt;
        node.pz += node.vz * dt;
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

        let voxel = layout.get_voxel_at(x, y, z);
        kani::assert(
            (voxel.index() as usize) < Voxel::CATALOG.len(),
            "Voxel must be a known catalog entry",
        );
    }

    #[kani::proof]
    fn verify_query_voxel_ffi_never_panics() {
        let x: i32 = kani::any();
        let y: i32 = kani::any();
        let z: i32 = kani::any();
        let result = query_voxel(x, y, z);
        kani::assert(
            result >= 0 && (result as usize) < Voxel::CATALOG.len(),
            "FFI returns a valid known voxel",
        );
    }

    #[kani::proof]
    fn verify_mod_evaluate_action_stays_bounded() {
        let action_pick: u8 = kani::any();
        let current_level: i32 = kani::any();
        kani::assume(current_level >= 0 && current_level <= 5);
        let action = match action_pick % 10 {
            0 => ACTION_BREAK,
            1 => ACTION_PLACE,
            2 => ACTION_ENTER,
            3 => ACTION_EXPLODE,
            4 => ACTION_ACCEPT,
            5 => ACTION_COMPLETE,
            6 => ACTION_FENCE,
            7 => ACTION_CRAFT,
            8 => ACTION_CRASH,
            _ => "unknown",
        };
        let result = mod_evaluate_action(action, current_level);
        kani::assert(result >= 0 && result <= 5, "Wanted level must stay 0-5");
    }

    #[kani::proof]
    fn verify_can_fracture_is_boolean() {
        let pick: u8 = kani::any();
        let voxel = match pick % 11 {
            0 => "air",
            1 => "concrete",
            2 => "asphalt",
            3 => "glass",
            4 => "sidewalk",
            5 => "grass",
            6 => "tile",
            7 => "rail",
            8 => "workbench",
            9 => "brick",
            _ => "unknown",
        };
        let result = can_fracture(voxel);
        kani::assert(result == 0 || result == 1, "can_fracture is 0 or 1");
    }

    #[kani::proof]
    fn verify_loot_item_is_known_or_empty() {
        let pick: u8 = kani::any();
        let voxel = Voxel::CATALOG[(pick as usize) % Voxel::CATALOG.len()];
        let item = loot_item(voxel);
        kani::assert(
            item.is_empty() || item == voxel,
            "loot is empty or the voxel",
        );
        kani::assert(
            item.is_empty() || Voxel::from_name(&item).is_some(),
            "loot name stays in the catalog",
        );
    }

    #[kani::proof]
    fn verify_wallet_never_goes_negative() {
        let action_pick: u8 = kani::any();
        let wallet: i32 = kani::any();
        let extra: i32 = kani::any();
        kani::assume(wallet >= 0 && wallet <= 1_000_000);
        let action = match action_pick % 5 {
            0 => ACTION_BREAK,
            1 => ACTION_ENTER,
            2 => ACTION_COMPLETE,
            3 => ACTION_FENCE,
            _ => ACTION_PLACE,
        };
        let result = mod_wallet_after(action, wallet, extra);
        kani::assert(result >= 0 && result <= 1_000_000, "wallet stays in range");
    }

    #[kani::proof]
    fn verify_mod_can_complete_anti_cheat() {
        let action_pick: u8 = kani::any();
        let player_state: i32 = kani::any();
        let contract_kind_pick: u8 = kani::any();
        let contract_danger: i32 = kani::any();
        let held_pick: u8 = kani::any();
        let y: i32 = kani::any();
        let vehicle: bool = kani::any();
        let near: bool = kani::any();

        let action = match action_pick % 4 {
            0 => ACTION_ACCEPT,
            1 => ACTION_COMPLETE,
            2 => ACTION_FENCE,
            _ => "unknown",
        };

        let contract_kind = match contract_kind_pick % 5 {
            0 => CONTRACT_SMASH,
            1 => CONTRACT_SUBWAY,
            2 => CONTRACT_CHOP,
            3 => CONTRACT_TRUCK,
            _ => "",
        };

        let held = match held_pick % 5 {
            0 => "glass",
            1 => "brick",
            2 => "concrete",
            3 => "workbench",
            _ => "",
        };

        let result = mod_can_complete(
            action,
            player_state,
            contract_kind,
            contract_danger,
            held,
            y,
            vehicle,
            near,
        );

        if action == ACTION_COMPLETE {
            if player_state < contract_danger {
                kani::assert(result == 0, "Cannot complete contract if wanted level is too low");
            }
            if !near {
                kani::assert(result == 0, "Cannot complete contract if not near the mark");
            }
        }
    }

    #[kani::proof]
    fn verify_softbody_momentum_conservation() {
        let dt: f32 = 0.016;
        
        let mut nodes = [
            Node { mass: 1.0, px: kani::any(), py: kani::any(), pz: kani::any(), vx: kani::any(), vy: kani::any(), vz: kani::any() },
            Node { mass: 2.0, px: kani::any(), py: kani::any(), pz: kani::any(), vx: kani::any(), vy: kani::any(), vz: kani::any() },
        ];
        
        let mut beams = [
            Beam { node_a: 0, node_b: 1, rest_length: kani::any(), stiffness: kani::any(), damping: 0.0, plastic_yield: kani::any() },
        ];
        
        for n in &nodes {
            kani::assume(n.px.is_finite() && n.px.abs() < 100.0);
            kani::assume(n.py.is_finite() && n.py.abs() < 100.0);
            kani::assume(n.pz.is_finite() && n.pz.abs() < 100.0);
            kani::assume(n.vx.is_finite() && n.vx.abs() < 100.0);
            kani::assume(n.vy.is_finite() && n.vy.abs() < 100.0);
            kani::assume(n.vz.is_finite() && n.vz.abs() < 100.0);
        }
        
        kani::assume(beams[0].rest_length.is_finite() && beams[0].rest_length > 0.1 && beams[0].rest_length < 100.0);
        kani::assume(beams[0].stiffness.is_finite() && beams[0].stiffness >= 0.0 && beams[0].stiffness < 1000.0);
        kani::assume(beams[0].plastic_yield.is_finite() && beams[0].plastic_yield > 0.0 && beams[0].plastic_yield < 100.0);
        
        let initial_px = nodes[0].mass * nodes[0].vx + nodes[1].mass * nodes[1].vx;
        let initial_py = nodes[0].mass * nodes[0].vy + nodes[1].mass * nodes[1].vy;
        let initial_pz = nodes[0].mass * nodes[0].vz + nodes[1].mass * nodes[1].vz;
        
        tick_softbody(&mut nodes, &mut beams, dt);
        
        let final_px = nodes[0].mass * nodes[0].vx + nodes[1].mass * nodes[1].vx;
        let final_py = nodes[0].mass * nodes[0].vy + nodes[1].mass * nodes[1].vy;
        let final_pz = nodes[0].mass * nodes[0].vz + nodes[1].mass * nodes[1].vz;
        
        // The internal spring forces must cancel out perfectly.
        kani::assert((initial_px - final_px).abs() < 0.1, "X momentum must be conserved");
        kani::assert((initial_py - final_py).abs() < 0.1, "Y momentum must be conserved");
        kani::assert((initial_pz - final_pz).abs() < 0.1, "Z momentum must be conserved");
    }
}

#[cfg(test)]
mod kani_replay {
    use super::*;

    #[test]
    fn kani_replay_engine_mod_bounds() {
        let layout = CityLayout {
            width: 1000,
            height: 1000,
            roads: vec![],
            districts: vec![],
        };
        for (x, y, z) in [
            (0, 0, 0),
            (i32::MAX, i32::MIN, 0),
            (-4, 50, 9999),
            (500, 2, 500),
        ] {
            let voxel = layout.get_voxel_at(x, y, z);
            assert!((voxel.index() as usize) < Voxel::CATALOG.len());
            let result = query_voxel(x, y, z);
            assert!(result >= 0 && (result as usize) < Voxel::CATALOG.len());
        }
        for level in 0..=5 {
            for action in [
                ACTION_BREAK,
                ACTION_PLACE,
                ACTION_ENTER,
                ACTION_EXPLODE,
                ACTION_ACCEPT,
                ACTION_COMPLETE,
                ACTION_FENCE,
                ACTION_CRAFT,
                ACTION_CRASH,
                "unknown",
            ] {
                let result = mod_evaluate_action(action, level);
                assert!((0..=5).contains(&result));
            }
        }
        for voxel in [
            "air", "concrete", "asphalt", "glass", "sidewalk", "grass", "tile", "rail",
            "workbench", "brick", "unknown",
        ] {
            let result = can_fracture(voxel);
            assert!(result == 0 || result == 1);
        }
        for voxel in Voxel::CATALOG {
            let item = loot_item(voxel);
            assert!(item.is_empty() || item == *voxel);
            assert!(item.is_empty() || Voxel::from_name(&item).is_some());
        }
        for wallet in [0, 1, 50, 1_000_000] {
            for extra in [0, 10, -3] {
                for action in [ACTION_BREAK, ACTION_ENTER, ACTION_COMPLETE, ACTION_FENCE, ACTION_PLACE]
                {
                    let result = mod_wallet_after(action, wallet, extra);
                    assert!((0..=1_000_000).contains(&result));
                }
            }
        }
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
        assert!(layout.get_voxel_at(0, -1, 0).is_solid(), "below ground must be solid");
        assert!(layout.get_voxel_at(500, -100, 500).is_solid());
    }

    #[test]
    fn voxel_high_in_air_is_air() {
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(50, 500, 50), Voxel::Air, "high altitude should be air");
    }

    #[test]
    fn road_surface_is_asphalt() {
        let layout = empty_layout();
        let voxel = layout.get_voxel_at(0, 0, 0);
        assert_eq!(voxel, Voxel::Asphalt, "road centre should be asphalt");
    }

    #[test]
    fn query_voxel_ffi_matches_get_voxel_at() {
        let layout = empty_layout();
        for (x, y, z) in [(0, 0, 0), (500, 50, 500), (0, -1, 0), (50, 500, 50)] {
            let direct = layout.get_voxel_at(x, y, z).index() as i32;
            let via_ffi = query_voxel(x, y, z);
            assert_eq!(direct, via_ffi, "FFI wrapper must match direct call at ({x},{y},{z})");
        }
    }

    #[test]
    fn catalog_is_english_names_in_index_order() {
        assert_eq!(
            voxel_catalog(),
            "air,concrete,asphalt,glass,sidewalk,grass,tile,rail,workbench,brick,drill"
        );
        assert_eq!(Voxel::from_name("tile"), Some(Voxel::Tile));
        assert_eq!(Voxel::from_name("workbench"), Some(Voxel::Workbench));
        assert_eq!(Voxel::Brick.name(), "brick");
        assert_eq!(Voxel::Glass.name(), "glass");
    }

    #[test]
    fn break_block_increases_wanted_level() {
        assert_eq!(mod_evaluate_action(ACTION_BREAK, 0), 1);
        assert_eq!(mod_evaluate_action(ACTION_BREAK, 3), 4);
    }

    #[test]
    fn break_block_caps_at_5() {
        assert_eq!(mod_evaluate_action(ACTION_BREAK, 5), 5, "must not exceed 5 stars");
        assert_eq!(mod_evaluate_action(ACTION_BREAK, 4), 5);
    }

    #[test]
    fn place_block_no_offense() {
        assert_eq!(mod_evaluate_action(ACTION_PLACE, 0), 0);
        assert_eq!(mod_evaluate_action(ACTION_PLACE, 3), 3);
    }

    #[test]
    fn enter_vehicle_grand_theft_auto() {
        assert_eq!(mod_evaluate_action(ACTION_ENTER, 0), 3);
        assert_eq!(mod_evaluate_action(ACTION_ENTER, 3), 5, "must cap at 5");
    }

    #[test]
    fn explosion_is_instant_5_stars() {
        assert_eq!(mod_evaluate_action(ACTION_EXPLODE, 0), 5);
        assert_eq!(mod_evaluate_action(ACTION_EXPLODE, 2), 5);
    }

    #[test]
    fn unknown_action_type_is_neutral() {
        assert_eq!(mod_evaluate_action("unknown", 2), 2);
        assert_eq!(mod_evaluate_action("", 4), 4);
    }

    #[test]
    fn spawn_cop_when_wanted_level_rises() {
        assert_eq!(mod_should_spawn_agent(ACTION_BREAK, 0, 1), AGENT_COP);
        assert_eq!(mod_should_spawn_agent(ACTION_EXPLODE, 2, 5), AGENT_COP);
    }

    #[test]
    fn no_spawn_when_level_unchanged() {
        assert!(mod_should_spawn_agent(ACTION_PLACE, 3, 3).is_empty());
    }

    #[test]
    fn no_spawn_when_level_drops() {
        assert!(mod_should_spawn_agent("", 5, 3).is_empty());
    }

    #[test]
    fn no_spawn_when_new_state_is_zero() {
        assert!(mod_should_spawn_agent(ACTION_BREAK, 0, 0).is_empty());
    }

    #[test]
    fn break_block_range_is_10() {
        assert!((mod_get_action_range(ACTION_BREAK) - 10.0).abs() < 1e-6);
    }

    #[test]
    fn explosion_range_is_30() {
        assert!((mod_get_action_range(ACTION_EXPLODE) - 30.0).abs() < 1e-6);
    }

    #[test]
    fn enter_vehicle_range_is_5() {
        assert!((mod_get_action_range(ACTION_ENTER) - 5.0).abs() < 1e-6);
    }

    #[test]
    fn unknown_action_range_defaults_to_10() {
        assert!((mod_get_action_range("unknown") - 10.0).abs() < 1e-6);
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
        let vx = compute_agent_vx(AGENT_COP, 0.0, 0.0, 10.0, 0.0);
        assert!(vx > 0.0, "cop should move toward player on x axis");
    }

    #[test]
    fn cop_chases_player_in_z() {
        let vz = compute_agent_vz(AGENT_COP, 0.0, 0.0, 0.0, 10.0);
        assert!(vz > 0.0, "cop should move toward player on z axis");
    }

    #[test]
    fn cop_stops_when_adjacent() {
        let vx = compute_agent_vx(AGENT_COP, 0.0, 0.0, 1.0, 0.0);
        assert!((vx).abs() < 1e-6, "cop too close, should stop");
    }

    #[test]
    fn unknown_ai_type_has_zero_velocity() {
        let vx = compute_agent_vx("unknown", 0.0, 0.0, 100.0, 100.0);
        let vz = compute_agent_vz("unknown", 0.0, 0.0, 100.0, 100.0);
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
        assert_eq!(generate_story_event(0), EVENT_QUIET);
    }

    #[test]
    fn story_follows_the_heist_board() {
        assert_eq!(generate_story_event(1), EVENT_SMASH);
        assert_eq!(generate_story_event(2), EVENT_SUBWAY);
        assert_eq!(generate_story_event(3), EVENT_CHOP);
        assert_eq!(generate_story_event(4), EVENT_TRUCK);
        assert_eq!(generate_story_event(5), EVENT_DRILL);
    }

    #[test]
    fn storyteller_level_returns_positive() {
        let level = mod_get_storyteller_level();
        assert!(level >= 0, "storyteller level must be non-negative");
    }

    #[test]
    fn player_spawns_in_city() {
        let (x, y, z) = player_spawn();
        assert_eq!(y, 2, "street level, not mid-air");
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(x, 0, z), Voxel::Sidewalk);
        assert_eq!(layout.get_voxel_at(x, y, z), Voxel::Air);
    }

    #[test]
    fn vehicle_spawns_are_near_player() {
        assert_eq!(vehicle_spawn_count(), 6);
        let (x, y, z) = vehicle_spawn(0);
        assert_eq!(y, 2, "cars sit on the road");
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(x, 0, z), Voxel::Asphalt);
        let (x2, _, _) = vehicle_spawn(1);
        assert_eq!(x2, 510);
    }

    #[test]
    fn cars_are_this_game_not_the_engine() {
        let player = vehicle_kit(0);
        assert_eq!(payload_str(&player, "kind"), "car");
        assert!(!payload_flag(&player, "traffic"));
        assert_eq!(payload_i64(&player, "stiffness"), 32);
        let tires = as_list(&dict_child(&player, "tires").unwrap()).unwrap();
        assert_eq!(payload_str(&tires[0], "name"), "wheel");
        let beams = as_list(&dict_child(&player, "beams").unwrap()).unwrap();
        assert_eq!(payload_str(&beams[2], "a"), "hull");
        assert_eq!(payload_str(&beams[2], "b"), "wheel");
        assert_eq!(payload_str(&beams[1], "a"), "cabin");
        let parts = as_list(&dict_child(&player, "parts").unwrap()).unwrap();
        assert_eq!(parts.len(), 8);
        assert_eq!(payload_str(&parts[0], "name"), "hull");
        assert_eq!(payload_str(&parts[1], "name"), "cabin");
        assert_eq!(payload_str(&parts[4], "name"), "wheel");
        assert_eq!(payload_str(&parts[2], "name"), "lamp");
        assert!((payload_f32(&parts[0], "r") - 0.78).abs() < 1e-5);
        let traffic = vehicle_kit(1);
        assert!(payload_flag(&traffic, "traffic"));
        let tparts = as_list(&dict_child(&traffic, "parts").unwrap()).unwrap();
        assert!((payload_f32(&tparts[0], "r") - 0.78).abs() > 1e-3);
        let p1 = as_list(&dict_child(&vehicle_kit(1), "parts").unwrap()).unwrap();
        let p2 = as_list(&dict_child(&vehicle_kit(2), "parts").unwrap()).unwrap();
        assert_ne!(payload_f32(&p1[0], "r"), payload_f32(&p2[0], "r"));
    }

    #[test]
    fn streets_use_earth_gravity() {
        let g = gravity();
        assert_eq!(payload_str(&g, "kind"), "constant");
        assert!((payload_f32(&g, "y") + 9.81).abs() < 1e-5);
        assert!((payload_f32(&g, "jump") - 5.0).abs() < 1e-5);
        assert!((payload_f32(&g, "walk") - 10.0).abs() < 1e-5);
    }

    #[test]
    fn buildings_fracture_roads_do_not() {
        assert_eq!(can_fracture("concrete"), 1);
        assert_eq!(can_fracture("glass"), 1);
        assert_eq!(can_fracture("tile"), 1);
        assert_eq!(can_fracture("workbench"), 1);
        assert_eq!(can_fracture("brick"), 1);
        assert_eq!(can_fracture("asphalt"), 0);
        assert_eq!(can_fracture("grass"), 0);
        assert_eq!(can_fracture("rail"), 0);
        assert_eq!(can_fracture("air"), 0);
    }

    #[test]
    fn glass_spreads_further_than_concrete() {
        assert!(fracture_spread("glass") > fracture_spread("concrete"));
        assert_eq!(fracture_spread("asphalt"), 0);
    }

    #[test]
    fn explosion_impulse_stronger_than_melee() {
        assert!(debris_impulse(ACTION_EXPLODE) > debris_impulse(ACTION_BREAK));
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
        assert_eq!(should_despawn_agent(AGENT_COP, 0), 1);
        assert_eq!(should_despawn_agent(AGENT_COP, 2), 0);
        assert_eq!(should_despawn_agent(AGENT_PEDESTRIAN, 0), 0);
    }

    #[test]
    fn pedestrians_stroll_east_and_yield() {
        let vx = compute_agent_vx(AGENT_PEDESTRIAN, 0.0, 0.0, 100.0, 0.0);
        assert!((vx - 3.0).abs() < 1e-5);
        assert!((compute_agent_vz(AGENT_PEDESTRIAN, 0.0, 0.0, 100.0, 0.0)).abs() < 1e-6);
        assert!((compute_agent_vx(AGENT_PEDESTRIAN, 0.0, 0.0, 1.0, 0.0)).abs() < 1e-6);
    }

    #[test]
    fn ambient_agents_are_pedestrians_on_the_street() {
        assert_eq!(ambient_agent_count(), 8);
        let (x, y, _z, kind) = ambient_agent_spawn(0);
        assert_eq!(kind, AGENT_PEDESTRIAN);
        assert!(y < 10, "pedestrians walk the street, not rooftops");
        assert!(x >= 500);
    }

    #[test]
    fn train_agent_moves_fast_along_z_axis() {
        let (x, y, _z, kind) = ambient_agent_spawn(6);
        assert_eq!(kind, AGENT_TRAIN);
        assert_eq!(y, -7);
        assert_eq!(x, 400);
        assert_eq!(compute_agent_vx(AGENT_TRAIN, 0.0, 0.0, 0.0, 0.0), 0.0);
        assert_eq!(compute_agent_vz(AGENT_TRAIN, 0.0, 0.0, 0.0, 0.0), 25.0);
    }

    #[test]
    fn voxel_labels_cover_city_materials() {
        assert_eq!(voxel_label("asphalt"), "asphalt");
        assert_eq!(voxel_label("glass"), "glass");
        assert_eq!(voxel_label("tile"), "tile");
        assert_eq!(voxel_label("rail"), "rail");
        assert_eq!(voxel_label("workbench"), "workbench");
        assert_eq!(voxel_label("brick"), "brick");
        assert_eq!(voxel_label("unknown"), "unknown");
    }

    #[test]
    fn sidewalk_is_beside_the_road() {
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(4, 0, 10), Voxel::Sidewalk);
    }

    #[test]
    fn workbenches_sit_on_the_sidewalk() {
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(4, 0, 20), Voxel::Sidewalk);
        assert_eq!(layout.get_voxel_at(4, 1, 20), Voxel::Workbench);
        assert_eq!(layout.get_voxel_at(20, 1, 4), Voxel::Workbench);
        assert_eq!(layout.get_voxel_at(4, 1, 4), Voxel::Air, "no bench over the metro shaft");
        assert_eq!(layout.get_voxel_at(504, 1, 508), Voxel::Air, "player spawn stays clear");
    }

    #[test]
    fn subway_runs_under_the_street() {
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(1, -8, 20), Voxel::Tile, "tunnel floor is tile");
        assert_eq!(layout.get_voxel_at(1, -7, 20), Voxel::Rail, "centerline is rail");
        assert_eq!(layout.get_voxel_at(0, -7, 20), Voxel::Air, "tunnel air beside the rail");
        assert_eq!(layout.get_voxel_at(0, -2, 0), Voxel::Concrete, "slab under the asphalt");
        assert_eq!(layout.get_voxel_at(0, -20, 0), Voxel::Concrete, "bedrock");
    }

    #[test]
    fn metro_shaft_and_station_at_intersection() {
        let layout = empty_layout();
        assert_eq!(layout.get_voxel_at(4, 0, 4), Voxel::Air, "shaft opening in the sidewalk");
        assert_eq!(layout.get_voxel_at(4, -4, 4), Voxel::Air, "shaft down to the platform");
        assert_eq!(layout.get_voxel_at(1, -8, 1), Voxel::Tile, "station floor");
        assert_eq!(layout.get_voxel_at(1, -6, 1), Voxel::Air, "station hall");
    }

    #[test]
    fn loot_drops_breakable_city_blocks() {
        assert_eq!(loot_item("concrete"), "concrete");
        assert_eq!(loot_item("glass"), "glass");
        assert_eq!(loot_item("tile"), "tile");
        assert_eq!(loot_item("grass"), "grass");
        assert_eq!(loot_item("workbench"), "workbench");
        assert_eq!(loot_item("brick"), "brick");
        assert!(loot_item("asphalt").is_empty());
        assert!(loot_item("rail").is_empty());
        assert!(loot_item("air").is_empty());
        assert_eq!(item_label_for("en", "tile"), "tile");
        assert_eq!(item_label_for("mi", "tile"), "tāera");
        assert_eq!(item_label_for("fr", "rail"), "rail");
        assert_eq!(item_label_for("zh-TW", "tile"), "磁磚");
        assert!(item_label_for("en", "").is_empty());
    }

    #[test]
    fn street_crafting_is_symmetric() {
        assert_eq!(craft_result("concrete", "concrete"), "sidewalk");
        assert_eq!(craft_result("glass", "concrete"), "tile");
        assert_eq!(craft_result("concrete", "glass"), "tile");
        assert_eq!(craft_result("tile", "tile"), "rail");
        assert_eq!(craft_result("grass", "grass"), "concrete");
        assert_eq!(craft_result("glass", "glass"), "workbench");
        assert_eq!(craft_result("sidewalk", "glass"), "workbench");
        assert_eq!(craft_result("workbench", "concrete"), "brick");
        assert_eq!(craft_result("grass", "concrete"), "brick");
        assert_eq!(craft_result("brick", "brick"), "concrete");
        assert_eq!(craft_result("rail", "workbench"), "drill");
        assert!(craft_result("asphalt", "asphalt").is_empty());
        assert!(craft_result("concrete", "rail").is_empty());
    }

    #[test]
    fn story_event_labels_are_heists_not_aliens() {
        assert_eq!(event_label(EVENT_QUIET), "quiet streets");
        assert_eq!(event_label(EVENT_SMASH), "smash-and-grab contract");
        assert_eq!(event_label(EVENT_SUBWAY), "subway pinch");
        assert_eq!(event_label(EVENT_CHOP), "chop-shop run");
        assert_eq!(event_label(EVENT_TRUCK), "armored-truck heist");
    }

    #[test]
    fn voxel_and_story_follow_locale() {
        assert_eq!(voxel_label_for("mi", "asphalt"), "huarahi tā");
        assert_eq!(voxel_label_for("mi", "tile"), "tāera");
        assert_eq!(voxel_label_for("fr", "glass"), "verre");
        assert_eq!(voxel_label_for("fr", "rail"), "rail");
        assert_eq!(voxel_label_for("zh-TW", "asphalt"), "柏油");
        assert_eq!(voxel_label_for("zh-TW", "tile"), "磁磚");
        assert_eq!(voxel_label_for("mi", "workbench"), "pae mahi");
        assert_eq!(voxel_label_for("fr", "brick"), "brique");
        assert_eq!(voxel_label_for("zh-TW", "workbench"), "工作台");
        assert_eq!(voxel_label_for("de", "asphalt"), "asphalt", "unknown locale falls back to English");
        assert_eq!(event_label_for("mi", EVENT_QUIET), "ngā huarahi mārie");
        assert_eq!(event_label_for("fr", EVENT_TRUCK), "casse de fourgon blindé");
        assert_eq!(event_label_for("zh-Hant", EVENT_SMASH), "搶劫合約");
        assert_eq!(contract_label_for("en", CONTRACT_SMASH), "smash-and-grab");
        assert_eq!(contract_label_for("zh-TW", CONTRACT_TRUCK), "運鈔車搶案");
        assert_eq!(supported_locales(), "en,mi,fr,zh-TW");
    }

    #[test]
    fn clean_player_is_offered_an_atm_job() {
        assert_eq!(mod_offer_contract(0), (CONTRACT_SMASH.into(), 250, 1));
    }

    #[test]
    fn high_wanted_unlocks_heists() {
        assert_eq!(mod_offer_contract(3), (CONTRACT_TRUCK.into(), 1200, 4));
        assert_eq!(mod_offer_contract(4), (CONTRACT_DRILL.into(), 2000, 4));
        assert_eq!(mod_offer_contract(5), (CONTRACT_BANK.into(), 5000, 5));
    }

    #[test]
    fn scrap_and_stolen_cars_pay_credits() {
        assert_eq!(mod_wallet_after(ACTION_BREAK, 0, 0), 5);
        assert_eq!(mod_wallet_after(ACTION_ENTER, 10, 0), 60);
        assert_eq!(mod_wallet_after(ACTION_PLACE, 10, 0), 10);
    }

    #[test]
    fn completing_a_heist_pays_the_payout() {
        assert_eq!(mod_wallet_after(ACTION_COMPLETE, 100, 250), 350);
        assert_eq!(mod_wallet_after(ACTION_COMPLETE, 100, -50), 100, "negative extra must not drain");
    }

    #[test]
    fn fencing_uses_the_city_market() {
        let after = mod_wallet_after(ACTION_FENCE, 0, 0);
        assert_eq!(after, compute_economy_price(80, 5, 8));
        assert!(after > 0);
    }

    #[test]
    fn accept_needs_an_offer() {
        assert_eq!(mod_can_complete(ACTION_ACCEPT, 0, "", 0, "", 0, false, false), 0);
        assert_eq!(mod_can_complete(ACTION_ACCEPT, 0, CONTRACT_SMASH, 1, "", 0, false, false), 1);
    }

    #[test]
    fn complete_needs_the_job_site() {
        assert_eq!(mod_can_complete(ACTION_COMPLETE, 0, CONTRACT_SMASH, 1, "glass", 3, false, true), 0);
        assert_eq!(mod_can_complete(ACTION_COMPLETE, 1, CONTRACT_SMASH, 1, "glass", 3, false, true), 1);
        assert_eq!(
            mod_can_complete(ACTION_COMPLETE, 1, CONTRACT_SMASH, 1, "", 3, false, true),
            0
        );
        assert_eq!(mod_can_complete(ACTION_COMPLETE, 3, CONTRACT_TRUCK, 4, "", 2, true, true), 0);
        assert_eq!(mod_can_complete(ACTION_COMPLETE, 4, CONTRACT_TRUCK, 4, "", 2, true, true), 1);
        assert_eq!(
            mod_can_complete(ACTION_COMPLETE, 4, CONTRACT_TRUCK, 4, "", 2, false, true),
            0
        );
        assert_eq!(
            mod_can_complete(ACTION_COMPLETE, 2, CONTRACT_SUBWAY, 2, "", -6, false, true),
            1
        );
        assert_eq!(
            mod_can_complete(ACTION_COMPLETE, 2, CONTRACT_CHOP, 2, "brick", 2, false, true),
            1
        );
        assert_eq!(
            mod_can_complete(ACTION_COMPLETE, 5, CONTRACT_BANK, 5, "drill", -4, false, true),
            1
        );
        assert_eq!(
            mod_can_complete(ACTION_COMPLETE, 5, CONTRACT_BANK, 5, "", -4, false, true),
            0
        );
    }

    #[test]
    fn heist_marks_are_in_the_city() {
        assert_eq!(payload_i64(&contract_mark(CONTRACT_SMASH), "x"), 531);
        assert_eq!(payload_i64(&contract_mark(CONTRACT_SUBWAY), "y"), -6);
        assert_eq!(payload_i64(&contract_mark(CONTRACT_CHOP), "z"), 520);
        assert_eq!(payload_i64(&contract_mark(CONTRACT_TRUCK), "x"), 510);
        assert!(wire_is_null(&contract_mark("nope")));
        assert_eq!(mod_offer_contract(1), (CONTRACT_SUBWAY.into(), 600, 2));
        assert_eq!(mod_offer_contract(2), (CONTRACT_CHOP.into(), 500, 2));
    }

    #[test]
    fn fence_only_when_cold() {
        assert_eq!(mod_can_complete(ACTION_FENCE, 0, "", 0, "", 0, false, false), 1);
        assert_eq!(mod_can_complete(ACTION_FENCE, 2, "", 0, "", 0, false, false), 0);
    }

    #[test]
    fn accept_is_not_a_crime() {
        assert_eq!(mod_evaluate_action(ACTION_ACCEPT, 2), 2);
    }

    #[test]
    fn street_metal_folds_like_beamng_junk() {
        assert_eq!(crash_severity(4.0, true), 0);
        assert_eq!(crash_severity(12.0, true), 25);
        assert_eq!(crash_severity(18.0, true), 50);
        assert_eq!(crash_severity(24.0, true), 75);
        assert_eq!(crash_severity(30.0, true), 100);
        assert_eq!(crash_detach(PART_LAMP, 25), 1);
        assert_eq!(crash_detach(PART_WHEEL, 25), 0);
        assert_eq!(crash_detach(PART_WHEEL, 50), 1);
        assert_eq!(crash_detach(PART_CABIN, 75), 1);
        assert_eq!(crash_detach(PART_HULL, 100), 0);
        assert_eq!(crash_wrecks(50), 0);
        assert_eq!(crash_wrecks(75), 1);
        assert!(crash_action(25).is_empty());
        assert_eq!(crash_action(50), ACTION_CRASH);
        assert_eq!(crash_action(100), ACTION_EXPLODE);
        assert_eq!(crash_ignites(50), 0);
        assert_eq!(crash_ignites(75), 1);
        let crash = crash_kit(30.0, true);
        assert!(payload_flag(&crash, "ignites"));
        let detach = as_list(&dict_child(&crash, "detach").unwrap()).unwrap();
        assert!(detach.iter().any(|item| payload_str(item, "") == "lamp"));
        assert!(wire_is_null(&crash_kit(4.0, true)));
        assert_eq!(mod_evaluate_action(ACTION_CRASH, 0), 2);
        assert!(crash_part_impulse(80) > crash_part_impulse(20));
        assert!(!payload_flag(&fire_kit(0, "asphalt"), "out"));
        assert!(payload_flag(&fire_kit(0, "glass"), "consume"));
        assert!(payload_flag(&fire_kit(FIRE_FUEL_MS, "glass"), "out"));
        assert!(payload_flag(&fire_kit(FIRE_BURST_MS, "asphalt"), "burst"));
        assert_eq!(
            wire_as_text(&on_message("testbed", "ping", &wire_empty())),
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
        assert!(
            wire_as_text(&on_message("x", "catalog", &wire_empty()))
                .unwrap_or("")
                .contains("concrete")
        );
    }
}
