#[unsafe(no_mangle)]
pub extern "C" fn init_mod() -> i32 {
    // This is the Urban Chaos mod initializing!
    // We run the layout generator to prep the city grid.
    let _layout = CityLayout::generate(1000, 1000);
    // Return 100 indicating successful initialization
    100
}

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
        // Step 1: L-System for roads (Highways -> Streets)
        let roads = Self::generate_l_system_roads(width, height);
        
        // Step 2: Voronoi for Districts
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
        // Generate a grid of roads every 100 blocks
        for x in (0..width).step_by(100) {
            roads.push(Road { start: (x, 0), end: (x, height) });
        }
        for z in (0..height).step_by(100) {
            roads.push(Road { start: (0, z), end: (width, z) });
        }
        roads
    }

    fn generate_voronoi_districts(width: u32, height: u32) -> Vec<District> {
        let mut districts = Vec::new();
        // Just plop a downtown in the center, and suburban around it
        districts.push(District { center: (width / 2, height / 2), district_type: DistrictType::Downtown });
        districts.push(District { center: (width / 4, height / 4), district_type: DistrictType::Suburban });
        districts.push(District { center: (width * 3 / 4, height * 3 / 4), district_type: DistrictType::Industrial });
        districts
    }

    /// Queries the 3D voxel type at a specific coordinate based on the 2D layout.
    pub fn get_voxel_at(&self, x: i32, y: i32, z: i32) -> u8 {
        // Ground plane
        if y < 0 {
            return 1; // Solid bedrock/concrete base
        }

        // Road grid every 100 blocks, road is 6 blocks wide, sidewalks are 2 blocks wide
        let mod_x = (x % 100).abs();
        let mod_z = (z % 100).abs();
        
        let is_road_x = mod_x < 3;
        let is_road_z = mod_z < 3;
        let is_sidewalk_x = mod_x >= 3 && mod_x < 5;
        let is_sidewalk_z = mod_z >= 3 && mod_z < 5;
        
        if y == 0 {
            if is_road_x || is_road_z {
                return 2; // Asphalt road
            }
            if is_sidewalk_x || is_sidewalk_z {
                return 4; // Sidewalk (Concrete)
            }
        }

        // Generate buildings inside the grid cells
        let cell_x = x - (x % 100) + 50;
        let cell_z = z - (z % 100) + 50;
        
        // Pseudo-random number for cell variance
        let prng = (cell_x.abs() * 73 + cell_z.abs() * 37) % 100;
        let is_park = prng < 15; // 15% chance for a park block

        if y == 0 && is_park {
            return 5; // Grass
        }

        // Simple distance to center of city to determine height (downtown is taller)
        let dist_to_center = ((cell_x - (self.width / 2) as i32).pow(2) + (cell_z - (self.height / 2) as i32).pow(2)) as f32;
        let dist_to_center = dist_to_center.sqrt();
        
        let max_height = if dist_to_center < 300.0 {
            60 + (prng % 60) // Downtown skyscrapers (60-119)
        } else if dist_to_center < 600.0 {
            20 + (prng % 30) // Commercial / Industrial (20-49)
        } else {
            10 + (prng % 10) // Suburbs (10-19)
        };

        // Building footprint
        let local_x = (x - cell_x).abs();
        let local_z = (z - cell_z).abs();
        
        // Building shape variance
        let mut footprint = 20;
        if prng % 3 == 0 && local_x > 10 && local_z < 10 {
            // L-Shape carving
            footprint = 0; 
        }

        if !is_park && local_x < footprint && local_z < footprint {
            if y < max_height {
                // Glass walls for downtown, concrete for others
                if max_height > 50 && (local_x == footprint - 1 || local_z == footprint - 1) {
                    return 3; // Glass
                }
                return 1; // Concrete
            }
            // Add a small antenna on top of some buildings
            if y >= max_height && y < max_height + 5 && local_x == 0 && local_z == 0 && prng % 2 == 0 {
                return 1; // Antenna pole
            }
        }

        0 // Air
    }
}

/// WASM exported function that the engine calls to get block data
#[unsafe(no_mangle)]
pub extern "C" fn query_voxel(x: i32, y: i32, z: i32) -> i32 {
    let layout = CityLayout::generate(1000, 1000);
    layout.get_voxel_at(x, y, z) as i32
}

/// WASM exported function to evaluate arbitrary actions and return a new state
#[unsafe(no_mangle)]
pub extern "C" fn mod_evaluate_action(action_type: i32, current_state: i32) -> i32 {
    // In our Urban Chaos mod, state is the Wanted Level (0-5)
    match action_type {
        1 => current_state.saturating_add(1).min(5), // BreakBlock = minor offense
        2 => current_state,                          // PlaceBlock = no offense
        3 => current_state.saturating_add(3).min(5), // EnterVehicle = grand theft auto!
        4 => 5,                                      // Explosion = terrorism! 5 stars immediately!
        _ => current_state,
    }
}

/// Returns the AI type to spawn (0 = none, 1 = Cop, etc)
#[unsafe(no_mangle)]
pub extern "C" fn mod_should_spawn_agent(_action_type: i32, old_state: i32, new_state: i32) -> i32 {
    // If our wanted level increased and is > 0, spawn a Cop (Agent Type 1)
    if new_state > old_state && new_state > 0 {
        return 1;
    }
    0
}

/// Generic AI velocity computation
#[unsafe(no_mangle)]
pub extern "C" fn compute_agent_vx(ai_type: i32, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
    if ai_type == 1 {
        // Cop AI: chase player
        let dx = px - cx;
        let dz = pz - cz;
        let len = (dx * dx + dz * dz).sqrt();
        if len < 2.0 { return 0.0; }
        return (dx / len) * 8.0;
    }
    0.0
}

#[unsafe(no_mangle)]
pub extern "C" fn compute_agent_vz(ai_type: i32, cx: f32, cz: f32, px: f32, pz: f32) -> f32 {
    if ai_type == 1 {
        // Cop AI: chase player
        let dx = px - cx;
        let dz = pz - cz;
        let len = (dx * dx + dz * dz).sqrt();
        if len < 2.0 { return 0.0; }
        return (dz / len) * 8.0;
    }
    0.0
}

/// WASM exported function for dynamic economy pricing
#[unsafe(no_mangle)]
pub extern "C" fn compute_economy_price(base_price: i32, supply: i32, demand: i32) -> i32 {
    if supply == 0 {
        return base_price * 10;
    }
    // Simple dynamic pricing model
    let price = (base_price * demand) / supply;
    price.max(1) // Price never drops below 1
}

/// Returns the valid player action range (anti-cheat distance) for each action type.
/// The engine enforces this, but the MOD defines what is physically plausible in its world.
/// action_type: 1=BreakBlock, 2=PlaceBlock, 3=EnterVehicle, 4=Explosion
#[unsafe(no_mangle)]
pub extern "C" fn mod_get_action_range(action_type: i32) -> f32 {
    match action_type {
        1 => 10.0, // BreakBlock: must be within 10m
        2 => 10.0, // PlaceBlock: must be within 10m
        3 => 5.0,  // EnterVehicle: must be adjacent
        4 => 30.0, // Explosion (RPG): rocket can travel far
        _ => 10.0,
    }
}

/// Returns the X velocity for an autonomous traffic vehicle given its forward direction.
/// The ENGINE provides the vehicle's forward vector; the MOD decides the speed.
#[unsafe(no_mangle)]
pub extern "C" fn compute_traffic_vx(forward_x: f32, _forward_z: f32) -> f32 {
    forward_x * 10.0 // Urban traffic speed: 10 m/s
}

/// Returns the Z velocity for an autonomous traffic vehicle given its forward direction.
#[unsafe(no_mangle)]
pub extern "C" fn compute_traffic_vz(_forward_x: f32, forward_z: f32) -> f32 {
    forward_z * 10.0
}

/// Returns the 'player level' the AI Storyteller should use when generating events.
/// The MOD owns the progression curve — the engine just calls this to ask.
#[unsafe(no_mangle)]
pub extern "C" fn mod_get_storyteller_level() -> i32 {
    // In Urban Chaos, the city is always in a mid-tier chaos state (level 10).
    // A more advanced mod could track this dynamically via shared memory.
    10
}

/// Returns packed economic parameters: high 16 bits = supply, low 16 bits = demand.
/// The MOD owns the city's economic model; the engine unpacks and uses the values.
#[unsafe(no_mangle)]
pub extern "C" fn mod_get_economy_params() -> i32 {
    let supply: i32 = 5;
    let demand: i32 = 8;
    (supply << 16) | demand
}

/// WASM exported function for AI storyteller event generation
#[unsafe(no_mangle)]
pub extern "C" fn generate_story_event(player_level: i32) -> i32 {
    // 0 = peaceful day
    // 1 = small bandit raid
    // 2 = alien invasion
    if player_level < 5 {
        return 0; // Peaceful
    } else if player_level < 20 {
        return 1; // Bandits
    } else {
        return 2; // Aliens
    }
}
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
        kani::assert(voxel_id <= 5, "Voxel ID must be a known block type");
    }

    #[kani::proof]
    fn verify_query_voxel_ffi_never_panics() {
        let x: i32 = kani::any();
        let y: i32 = kani::any();
        let z: i32 = kani::any();
        let result = query_voxel(x, y, z);
        kani::assert(result >= 0 && result <= 5, "FFI returns a valid known voxel");
    }

    #[kani::proof]
    fn verify_mod_evaluate_action_stays_bounded() {
        let action_type: i32 = kani::any();
        let current_level: i32 = kani::any();
        kani::assume(current_level >= 0 && current_level <= 5);
        let result = mod_evaluate_action(action_type, current_level);
        kani::assert(result >= 0 && result <= 5, "Wanted level must stay 0-5");
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // ── CityLayout::get_voxel_at ─────────────────────────────────────────────

    #[test]
    fn voxel_below_ground_is_solid() {
        let layout = CityLayout { width: 1000, height: 1000, roads: vec![], districts: vec![] };
        assert!(layout.get_voxel_at(0, -1, 0) > 0, "below ground must be solid");
        assert!(layout.get_voxel_at(500, -100, 500) > 0);
    }

    #[test]
    fn voxel_high_in_air_is_air() {
        let layout = CityLayout { width: 1000, height: 1000, roads: vec![], districts: vec![] };
        // y=500 is far above any building
        assert_eq!(layout.get_voxel_at(50, 500, 50), 0, "high altitude should be air");
    }

    #[test]
    fn road_surface_is_asphalt() {
        let layout = CityLayout { width: 1000, height: 1000, roads: vec![], districts: vec![] };
        // Roads are at y=0 where mod_x < 3 or mod_z < 3
        let voxel = layout.get_voxel_at(0, 0, 0); // x%100=0, z%100=0 → road
        assert_eq!(voxel, 2, "road centre should be asphalt (type 2)");
    }

    #[test]
    fn query_voxel_ffi_matches_get_voxel_at() {
        // The WASM FFI wrapper must return the same value as the Rust function.
        let layout = CityLayout { width: 1000, height: 1000, roads: vec![], districts: vec![] };
        for (x, y, z) in [(0, 0, 0), (500, 50, 500), (0, -1, 0), (50, 500, 50)] {
            let direct = layout.get_voxel_at(x, y, z) as i32;
            let via_ffi = query_voxel(x, y, z);
            assert_eq!(direct, via_ffi, "FFI wrapper must match direct call at ({x},{y},{z})");
        }
    }

    // ── mod_evaluate_action (wanted level / ModState) ─────────────────────────

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

    // ── mod_should_spawn_agent ────────────────────────────────────────────────

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

    // ── mod_get_action_range ──────────────────────────────────────────────────

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

    // ── compute_traffic_vx/vz ────────────────────────────────────────────────

    #[test]
    fn traffic_velocity_is_forward_times_speed() {
        let vx = compute_traffic_vx(1.0, 0.0);
        let vz = compute_traffic_vz(0.0, 1.0);
        assert!((vx - 10.0).abs() < 1e-6, "full-forward-x should give vx=10");
        assert!((vz - 10.0).abs() < 1e-6, "full-forward-z should give vz=10");
    }

    #[test]
    fn traffic_stationary_when_forward_is_zero() {
        assert!((compute_traffic_vx(0.0, 0.0)).abs() < 1e-6);
        assert!((compute_traffic_vz(0.0, 0.0)).abs() < 1e-6);
    }

    #[test]
    fn traffic_diagonal_forward() {
        let fwd = 1.0_f32 / 2.0_f32.sqrt();
        let vx = compute_traffic_vx(fwd, fwd);
        let vz = compute_traffic_vz(fwd, fwd);
        assert!((vx - fwd * 10.0).abs() < 1e-5);
        assert!((vz - fwd * 10.0).abs() < 1e-5);
    }

    // ── compute_agent_vx/vz ──────────────────────────────────────────────────

    #[test]
    fn cop_chases_player_in_x() {
        // player at (10, 0), cop at (0, 0) → cop should move +x
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
        // cop within 2 units of player — should not move
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

    // ── compute_economy_price ─────────────────────────────────────────────────

    #[test]
    fn economy_basic_price() {
        // (100 * 8) / 5 = 160
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

    // ── mod_get_economy_params ────────────────────────────────────────────────

    #[test]
    fn economy_params_unpacked_correctly() {
        let packed = mod_get_economy_params();
        let supply = (packed >> 16) & 0xFFFF;
        let demand = packed & 0xFFFF;
        assert_eq!(supply, 5);
        assert_eq!(demand, 8);
    }

    // ── generate_story_event ──────────────────────────────────────────────────

    #[test]
    fn story_peaceful_at_low_level() {
        assert_eq!(generate_story_event(0), 0);
        assert_eq!(generate_story_event(4), 0);
    }

    #[test]
    fn story_bandits_at_mid_level() {
        assert_eq!(generate_story_event(5), 1);
        assert_eq!(generate_story_event(19), 1);
    }

    #[test]
    fn story_aliens_at_high_level() {
        assert_eq!(generate_story_event(20), 2);
        assert_eq!(generate_story_event(100), 2);
    }

    // ── mod_get_storyteller_level ─────────────────────────────────────────────

    #[test]
    fn storyteller_level_returns_positive() {
        let level = mod_get_storyteller_level();
        assert!(level >= 0, "storyteller level must be non-negative");
    }
}
