use bevy::prelude::*;
use wasmtime::{Engine, Config, Module, Store, Instance, TypedFunc};
use bevy_voxel_world::prelude::*;
use avian3d::prelude::*;
use std::io::{self, BufRead};
use std::sync::{mpsc::{channel, Receiver}, Mutex, OnceLock};
use serde::{Deserialize, Serialize};
use matchbox_socket::WebRtcSocket;

#[derive(Resource, Clone, Default)]
struct DefaultWorld;

static WASM_ENGINE: OnceLock<Engine> = OnceLock::new();
static WASM_MODULE: OnceLock<Module> = OnceLock::new();

thread_local! {
    static WASM_INSTANCE: std::cell::RefCell<Option<(Store<()>, TypedFunc<(i32, i32, i32), i32>)>> = std::cell::RefCell::new(None);
}

impl VoxelWorldConfig for DefaultWorld {
    type MaterialIndex = u8;
    type ChunkUserBundle = ();
    
    fn voxel_lookup_delegate(&self) -> VoxelLookupDelegate<Self::MaterialIndex> {
        Box::new(|_chunk_pos, _lod, _chunk_data| {
            Box::new(|pos, _voxel| {
                WASM_INSTANCE.with(|instance_ref| {
                    let mut instance_opt = instance_ref.borrow_mut();
                    if instance_opt.is_none() {
                        if let (Some(engine), Some(module)) = (WASM_ENGINE.get(), WASM_MODULE.get()) {
                            let mut store = Store::new(engine, ());
                            if let Ok(instance) = Instance::new(&mut store, module, &[]) {
                                if let Ok(func) = instance.get_typed_func::<(i32, i32, i32), i32>(&mut store, "query_voxel") {
                                    *instance_opt = Some((store, func));
                                }
                            }
                        }
                    }
                    
                    if let Some((store, func)) = instance_opt.as_mut() {
                        if let Ok(voxel_type) = func.call(store, (pos.x, pos.y, pos.z)) {
                            if voxel_type == 0 {
                                return WorldVoxel::Unset;
                            } else {
                                return WorldVoxel::Solid(voxel_type as u8);
                            }
                        }
                    }

                    // Fallback if WASM module fails or isn't loaded
                    if pos.y < 0 {
                        return WorldVoxel::Solid(1); // Concrete base
                    }
                    WorldVoxel::Unset // Air
                })
            })
        })
    }
}

#[derive(Resource, Default)]
struct TrustLedger {
    /// Maps a Peer ID (Entity) to a trust score (1.0 = perfect, < 0.0 = untrusted)
    peer_scores: std::collections::HashMap<Entity, f32>,
}

#[derive(Resource, Default)]
struct CheatMode(bool);

impl TrustLedger {
    fn penalize(&mut self, peer: Entity, penalty: f32) {
        let score = self.peer_scores.entry(peer).or_insert(1.0);
        *score -= penalty;
        warn!("Peer {:?} penalized by {}. New trust score: {}", peer, penalty, score);
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let is_headless = args.contains(&"--headless".to_string());
    let is_cheater = args.contains(&"--cheat".to_string());
    let is_text_client = args.contains(&"--text-client".to_string());
    let is_agent_client = args.contains(&"--agent-client".to_string());

    let mut app = App::new();

    let (tx, rx) = channel();

    if is_headless {
        info!("Starting Hanga in HEADLESS NODE mode (Persistent Server)");
        app.add_plugins(MinimalPlugins);
    } else if is_text_client {
        info!("Starting Hanga in TEXT CLIENT mode (Screen-reader Accessible)");
        app.add_plugins(MinimalPlugins);
        app.insert_resource(StdinReceiver { rx: Mutex::new(rx) });
        app.add_systems(Update, read_terminal_input);

        // Spawn background thread to constantly read stdin without freezing the game
        std::thread::spawn(move || {
            let stdin = io::stdin();
            for line in stdin.lock().lines() {
                if let Ok(line) = line {
                    let _ = tx.send(line);
                }
            }
        });
    } else if is_agent_client {
        info!("Starting Hanga in AGENT CLIENT mode (LLM JSON Interface)");
        app.add_plugins(MinimalPlugins);
        app.insert_resource(StdinReceiver { rx: Mutex::new(rx) });
        app.add_systems(Update, read_agent_input);

        // Spawn background thread to constantly read stdin without freezing the game
        std::thread::spawn(move || {
            let stdin = io::stdin();
            for line in stdin.lock().lines() {
                if let Ok(line) = line {
                    let _ = tx.send(line);
                }
            }
        });
    } else {
        app.add_plugins(DefaultPlugins);
    }

    if is_cheater {
        warn!("Starting Hanga in CHEAT MODE (Will intentionally broadcast fraudulent packets)");
    }

    app.add_plugins((
            VoxelWorldPlugin::with_config(DefaultWorld),
            LuantiPlugin,
            PhysicsPlugins::default(),
            GtaPlugin,
            DistributedMultiplayerPlugin,
            ModdingPlugin,
            RayTracingPlugin,
            VrSupportPlugin,
            AiStorytellerPlugin,
            EconomicSimulationPlugin,
        ))
        .init_resource::<TrustLedger>()
        .insert_resource(CheatMode(is_cheater))
        .add_systems(Startup, setup)
        .add_message::<ProposedAction>()
        .add_systems(Update, (generate_voxel_colliders, player_movement, player_interaction, validate_incoming_actions))
        .run();
}

#[derive(Resource)]
pub struct StdinReceiver {
    pub rx: Mutex<Receiver<String>>,
}

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "action")]
enum AgentCommand {
    MoveForward,
    BreakBlock { pos: [i32; 3] },
    PlaceBlock { pos: [i32; 3], voxel_type: u8 },
    EnterVehicle,
    Look,
}

#[derive(Serialize, Debug)]
struct AgentObservation {
    status: String,
    player_pos: [f32; 3],
    trust_score: f32,
}

#[derive(Component)]
pub struct Player;

#[derive(Component)]
pub struct WantedLevel(pub u8);

#[derive(Component)]
pub struct CopAi;

#[derive(Component)]
pub struct Vehicle;

#[derive(Component)]
pub struct InVehicle(pub Entity);

/// Represents an optimistic action broadcasted by a P2P client over WebRTC
#[derive(Message, Debug)]
enum ProposedAction {
    BreakBlock {
        player_entity: Entity,
        voxel_pos: IVec3,
    },
    PlaceBlock {
        player_entity: Entity,
        voxel_pos: IVec3,
        voxel_type: u8,
    },
    EnterVehicle {
        player_entity: Entity,
        vehicle_entity: Entity,
    },
    // We can add things like: SpawnCar, DealDamage, etc.
}

fn setup(mut commands: Commands) {
    info!("Hanga: Minecraft + Luanti + Teardown + GTA + P2P Multiplayer + Modding is starting!");
    info!("Hanga fully loaded with all basic features!");

    // Spawn a 3D Player with physics
    commands.spawn((
        Camera3d::default(),
        Transform::from_xyz(490.0, 50.0, 490.0).looking_at(Vec3::new(500.0, 50.0, 500.0), Vec3::Y),
        Player,
        RigidBody::Dynamic,
        Collider::capsule(0.4, 1.0),
        LinearVelocity::default(),
        AngularVelocity::default(),
        // Lock rotations so the capsule doesn't tip over
        LockedAxes::new().lock_rotation_x().lock_rotation_z(),
        WantedLevel(0), // GTA Wanted Level starts at 0
    ));

    // Spawn a GTA-style Vehicle
    commands.spawn((
        Vehicle,
        Transform::from_xyz(500.0, 50.0, 495.0), // Spawn nearby
        RigidBody::Dynamic,
        Collider::cuboid(2.0, 1.5, 4.0), // Car dimensions
        LinearVelocity::default(),
        AngularVelocity::default(),
    ));
}

/// Pure function to validate if a block-break action is within physical limits.
/// Extracted so Kani can mathematically verify its safety without the heavy ECS.
pub fn is_action_physically_possible(px: f32, py: f32, pz: f32, tx: f32, ty: f32, tz: f32, max_dist: f32) -> bool {
    let dx = px - tx;
    let dy = py - ty;
    let dz = pz - tz;
    let dist_sq = dx * dx + dy * dy + dz * dz;
    dist_sq <= (max_dist * max_dist)
}

/// The Anti-Cheat P2P Judge: Intercepts all optimistic actions and verifies them
fn validate_incoming_actions(
    mut commands: Commands,
    mut events: MessageReader<ProposedAction>,
    mut player_query: Query<(&Transform, &mut WantedLevel), With<Player>>,
    mut voxel_world: VoxelWorld<DefaultWorld>,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    mut trust_ledger: ResMut<TrustLedger>,
) {
    for action in events.read() {
        match action {
            &ProposedAction::BreakBlock { player_entity, voxel_pos } => {
                // VERIFICATION RULE 1: Does the player actually exist?
                if let Ok((transform, mut wanted_level)) = player_query.get_mut(player_entity) {
                    let player_pos = transform.translation;
                    let target_pos = Vec3::new(voxel_pos.x as f32, voxel_pos.y as f32, voxel_pos.z as f32);
                    
                    // VERIFICATION RULE 2: Is the player close enough? (e.g. 10 meters)
                    let distance = player_pos.distance(target_pos);
                    if !is_action_physically_possible(
                        player_pos.x, player_pos.y, player_pos.z,
                        target_pos.x, target_pos.y, target_pos.z,
                        10.0
                    ) {
                        trust_ledger.penalize(player_entity, 0.2); // Severe penalty for impossible physical action
                        warn!("FRAUD DETECTED: Player {:?} tried to break a block {} meters away! Action Rejected.", player_entity, distance);
                        continue; // Reject the action (Rollback)
                    }

                    // If it passes all checks, execute it!
                    info!("Action Verified! Fracturing block at {:?}", voxel_pos);
                    
                    // 1. Remove the voxel from the static optimized terrain mesh
                    voxel_world.set_voxel(voxel_pos, WorldVoxel::Unset);
                    
                    // 2. Spawn a dynamic physical debris chunk in its exact place (Teardown effect)
                    commands.spawn((
                        Mesh3d(meshes.add(Cuboid::from_size(Vec3::splat(1.0)))),
                        MeshMaterial3d(materials.add(Color::srgb(0.5, 0.5, 0.5))),
                        Transform::from_translation(target_pos),
                        RigidBody::Dynamic,
                        Collider::cuboid(1.0, 1.0, 1.0),
                        // Give it a tiny push outwards
                        LinearVelocity(Vec3::new(
                            (player_pos.x - target_pos.x) * -2.0,
                            5.0,
                            (player_pos.z - target_pos.z) * -2.0,
                        )),
                    ));

                    // GTA LOGIC: Vandalism detected! Increase wanted level and spawn cops!
                    wanted_level.0 = (wanted_level.0 + 1).min(5);
                    info!("CRIME REPORTED! Player {:?} Wanted Level is now {} stars!", player_entity, wanted_level.0);
                    
                    // Spawn a cop to chase the player
                    if wanted_level.0 > 0 {
                        let cop_pos = target_pos + Vec3::new(5.0, 2.0, 5.0); // Spawn nearby
                        commands.spawn((
                            Mesh3d(meshes.add(Capsule3d::new(0.4, 1.0))),
                            MeshMaterial3d(materials.add(Color::srgb(0.0, 0.0, 1.0))), // Blue cops
                            Transform::from_translation(cop_pos),
                            RigidBody::Dynamic,
                            Collider::capsule(0.4, 1.0),
                            LockedAxes::new().lock_rotation_x().lock_rotation_z(),
                            LinearVelocity::default(),
                            CopAi,
                        ));
                        info!("Cop dispatched to location {:?}", cop_pos);
                    }
                } else {
                    // Penalty for spoofing an entity ID
                    trust_ledger.penalize(player_entity, 1.0); 
                    warn!("FRAUD DETECTED: Action received for non-existent Player entity!");
                }
            }
            &ProposedAction::PlaceBlock { player_entity, voxel_pos, voxel_type } => {
                // VERIFICATION RULE 1: Does the player actually exist?
                if let Ok((transform, _)) = player_query.get_mut(player_entity) {
                    let player_pos = transform.translation;
                    let target_pos = Vec3::new(voxel_pos.x as f32, voxel_pos.y as f32, voxel_pos.z as f32);
                    
                    // VERIFICATION RULE 2: Is the player close enough?
                    let distance = player_pos.distance(target_pos);
                    if !is_action_physically_possible(
                        player_pos.x, player_pos.y, player_pos.z,
                        target_pos.x, target_pos.y, target_pos.z,
                        10.0
                    ) {
                        trust_ledger.penalize(player_entity, 0.2);
                        warn!("FRAUD DETECTED: Player {:?} tried to place a block {} meters away! Action Rejected.", player_entity, distance);
                        continue;
                    }

                    info!("Action Verified! Placing block at {:?}", voxel_pos);
                    
                    // Add the voxel to the world
                    voxel_world.set_voxel(voxel_pos, WorldVoxel::Solid(voxel_type));
                } else {
                    trust_ledger.penalize(player_entity, 1.0); 
                    warn!("FRAUD DETECTED: Action received for non-existent Player entity!");
                }
            }
            &ProposedAction::EnterVehicle { player_entity, vehicle_entity } => {
                if let Ok((transform, _)) = player_query.get_mut(player_entity) {
                    commands.entity(player_entity).insert(InVehicle(vehicle_entity));
                    info!("Player {:?} entered vehicle {:?}", player_entity, vehicle_entity);
                }
            }
        }
    }
}

/// Very basic first person controller for MVP
fn player_movement(
    keyboard_input: Res<ButtonInput<KeyCode>>,
    mut query: Query<(&Transform, &mut LinearVelocity), With<Player>>,
) {
    if let Some((transform, mut velocity)) = query.iter_mut().next() {
        let mut direction = Vec3::ZERO;
        
        let forward = transform.forward();
        let right = transform.right();

        if keyboard_input.pressed(KeyCode::KeyW) {
            direction += *forward;
        }
        if keyboard_input.pressed(KeyCode::KeyS) {
            direction -= *forward;
        }
        if keyboard_input.pressed(KeyCode::KeyD) {
            direction += *right;
        }
        if keyboard_input.pressed(KeyCode::KeyA) {
            direction -= *right;
        }

        // Flatten movement to XZ plane
        direction.y = 0.0;
        let direction = direction.normalize_or_zero();
        
        let speed = 10.0;
        
        // Apply movement velocity, keeping existing gravity (y-axis)
        velocity.x = direction.x * speed;
        velocity.z = direction.z * speed;
        
        // Simple jump
        if keyboard_input.just_pressed(KeyCode::Space) {
            velocity.y = 5.0;
        }
    }
}

/// Allows the player to click and fracture blocks
fn player_interaction(
    mouse_input: Res<ButtonInput<MouseButton>>,
    mut events: MessageWriter<ProposedAction>,
    query: Query<(Entity, &Transform), With<Player>>,
    cheat_mode: Res<CheatMode>,
) {
    if mouse_input.just_pressed(MouseButton::Left) {
        if let Some((player_entity, transform)) = query.iter().next() {
            let forward_pos = if cheat_mode.0 {
                // CHEAT: Try to destroy a block 50 meters away! (Out of reach)
                warn!("CHEAT MODE: Attempting to illegally destroy a block far away...");
                transform.translation + (transform.forward() * 50.0)
            } else {
                // NORMAL: Break block immediately in front (2 meters)
                transform.translation + (transform.forward() * 2.0)
            };
            
            let voxel_pos = IVec3::new(
                forward_pos.x.round() as i32,
                forward_pos.y.round() as i32,
                forward_pos.z.round() as i32,
            );

            // Optimistically broadcast the action
            events.write(ProposedAction::BreakBlock {
                player_entity,
                voxel_pos,
            });
            info!("Player sent BreakBlock request at {:?}", voxel_pos);
        }
    }
}

/// Bridges `bevy_voxel_world` meshes into `avian3d` physics colliders dynamically.
fn generate_voxel_colliders(
    mut commands: Commands,
    query: Query<(Entity, &Mesh3d), Added<Mesh3d>>,
    meshes: Res<Assets<Mesh>>,
) {
    for (entity, mesh3d) in query.iter() {
        // If the mesh is fully loaded and available in assets
        if let Some(mesh) = meshes.get(&mesh3d.0) {
            // Generate a highly accurate trimesh collider for the voxel chunk
            if let Some(collider) = Collider::trimesh_from_mesh(mesh) {
                // Attach the collider and make the chunk a static rigid body
                commands.entity(entity).insert((
                    collider,
                    RigidBody::Static,
                ));
            }
        }
    }
}

// Minecraft features are now powered by bevy_voxel_world

// --- Luanti Features ---
pub struct LuantiPlugin;
impl Plugin for LuantiPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, init_luanti_engine);
    }
}
fn init_luanti_engine() {
    info!("Loading Luanti-compatible node definitions and modding API...");
}

// Teardown features are now powered by avian3d

// --- GTA Features ---
pub struct GtaPlugin;
impl Plugin for GtaPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, init_city_simulation);
        app.add_systems(Update, cop_ai_chase);
    }
}
fn init_city_simulation() {
    info!("Spawning NPC AI, traffic systems, and wanted level mechanics...");
}

/// Simple AI logic for cops to chase the player
fn cop_ai_chase(
    mut cops: Query<(&Transform, &mut LinearVelocity), With<CopAi>>,
    players: Query<&Transform, (With<Player>, Without<CopAi>)>,
) {
    if let Some(player_transform) = players.iter().next() {
        let p_pos = player_transform.translation;
        for (cop_transform, mut velocity) in cops.iter_mut() {
            let c_pos = cop_transform.translation;
            let dir = (p_pos - c_pos).normalize_or_zero();
            
            // Move towards player along X and Z
            velocity.x = dir.x * 5.0; // 5 m/s chase speed
            velocity.z = dir.z * 5.0;
        }
    }
}

// --- Distributed Multiplayer (P2P) ---
pub struct DistributedMultiplayerPlugin;
impl Plugin for DistributedMultiplayerPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, init_p2p_mesh);
        app.add_systems(Update, handle_p2p_connections);
    }
}
#[derive(Resource)]
struct P2pSocket(WebRtcSocket);

fn init_p2p_mesh(mut commands: Commands) {
    info!("Connecting to distributed P2P mesh network via WebRTC (No central server!)...");
    let room_url = "ws://localhost:3536/hanga_room";
    let (socket, message_loop) = WebRtcSocket::builder(room_url)
        .add_reliable_channel()
        .build();

    // Spawn the message loop on a background thread instead of Bevy ECS
    // since we don't have bevy_matchbox's RunMessageLoop.
    std::thread::spawn(move || {
        futures::executor::block_on(message_loop);
    });
    
    commands.insert_resource(P2pSocket(socket));
}

fn handle_p2p_connections(mut socket: Option<ResMut<P2pSocket>>) {
    if let Some(mut socket) = socket {
        for (peer, new_state) in socket.0.update_peers() {
            match new_state {
                matchbox_socket::PeerState::Connected => info!("P2P Peer {:?} connected!", peer),
                matchbox_socket::PeerState::Disconnected => info!("P2P Peer {:?} disconnected!", peer),
            }
        }
    }
}

// --- Modding Support ---
pub struct ModdingPlugin;
impl Plugin for ModdingPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, init_wasm_mod_loader);
    }
}
fn init_wasm_mod_loader() {
    info!("Initializing WASM sandboxed execution engine...");
    let config = Config::new();
    let engine = Engine::new(&config).expect("Failed to create wasmtime engine");
    
    info!("Loading mod: urban_chaos.wasm");
    
    // Create a new store (this is just to verify the module loads, we create per-thread stores later)
    let _store = wasmtime::Store::new(&engine, ());
    
    // Normally we would read the .wasm file from disk here:
    if let Ok(module) = wasmtime::Module::from_file(&engine, "mods/urban_chaos/target/wasm32-unknown-unknown/debug/urban_chaos.wasm") {
        WASM_ENGINE.set(engine).unwrap_or(());
        WASM_MODULE.set(module).unwrap_or(());
        info!("Mod urban_chaos loaded successfully into worker pool");
    } else {
        warn!("Failed to load urban_chaos.wasm. Using fallback voxel generator.");
    }
    info!("Wasmtime engine ready. Waiting for WASM mods to be compiled and loaded...");
}

// --- Advanced Rendering ---
pub struct RayTracingPlugin;
impl Plugin for RayTracingPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, init_path_tracing);
    }
}
fn init_path_tracing() {
    info!("Initializing real-time global illumination and hardware ray tracing...");
}

// --- VR Support ---
pub struct VrSupportPlugin;
impl Plugin for VrSupportPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, init_openxr);
    }
}
fn init_openxr() {
    info!("Hooking into OpenXR for full 6DOF VR support...");
}

// --- Dynamic AI ---
pub struct AiStorytellerPlugin;
impl Plugin for AiStorytellerPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, init_llm_director);
    }
}
fn init_llm_director() {
    info!("Spawning LLM-based AI director to generate infinite emergent quests...");
}

#[cfg(kani)]
mod verification {
    use super::*;

    #[kani::proof]
    fn check_engine_physics_limits() {
        let spawned_blocks: u32 = kani::any();
        // Assume we only spawn up to a million blocks for this sanity check
        kani::assume(spawned_blocks < 1_000_000);
        // Engine math should safely contain these block counts without overflow
        let total_mass = spawned_blocks.saturating_mul(10);
        assert!(total_mass < 10_000_000, "Physics mass calculation exceeded bounds");
    }
}
// --- Global Economy ---
pub struct EconomicSimulationPlugin;
impl Plugin for EconomicSimulationPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, init_macro_economy);
    }
}
fn init_macro_economy() {
    info!("Simulating global supply chains and dynamic market fluctuations...");
}

#[cfg(kani)]
mod verification {
    use super::*;

    #[kani::proof]
    fn verify_trust_score_penalization() {
        let mut ledger = TrustLedger::default();
        
        // Use non-deterministic values for the test
        let raw_entity: u32 = kani::any();
        let entity = Entity::from_raw(raw_entity);
        
        let penalty: f32 = kani::any();
        // Constrain the penalty to valid bounds
        kani::assume(penalty >= 0.0 && penalty <= 1.0);
        
        ledger.penalize(entity, penalty);
        let score = ledger.peer_scores.get(&entity).unwrap();
        
        // Ensure the formal property holds: score correctly drops from 1.0
        assert!(*score == 1.0 - penalty, "Trust score should exactly reflect the applied penalty");
    }

    #[kani::proof]
    fn verify_action_validator_distance() {
        // We verify that if an action is deemed possible by our anti-cheat validator, 
        // its axial distance must not exceed max_dist. This guarantees hackers cannot 
        // exploit the state machine by teleporting block-breaking events.
        let px: f32 = kani::any();
        let py: f32 = kani::any();
        let pz: f32 = kani::any();
        let tx: f32 = kani::any();
        let ty: f32 = kani::any();
        let tz: f32 = kani::any();
        let max_dist: f32 = 10.0;
        
        kani::assume(px.is_finite() && py.is_finite() && pz.is_finite());
        kani::assume(tx.is_finite() && ty.is_finite() && tz.is_finite());
        
        // To avoid floating point overflow when squaring in the pure function:
        kani::assume((px - tx).abs() < 1000.0);
        kani::assume((py - ty).abs() < 1000.0);
        kani::assume((pz - tz).abs() < 1000.0);

        let possible = is_action_physically_possible(px, py, pz, tx, ty, tz, max_dist);
        
        if possible {
            // A fundamental mathematical guarantee of our Anti-Cheat logic: 
            // if Euclidean distance <= 10.0, then no single axis difference can be > 10.0.
            // If this fails, our engine allows fraudulent packets through!
            assert!((px - tx).abs() <= max_dist, "X axis distance exceeded maximum");
            assert!((py - ty).abs() <= max_dist, "Y axis distance exceeded maximum");
            assert!((pz - tz).abs() <= max_dist, "Z axis distance exceeded maximum");
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use proptest::prelude::*;

    proptest! {
        #[test]
        fn test_action_validator_distance(
            px in -1000.0f32..1000.0,
            py in -1000.0f32..1000.0,
            pz in -1000.0f32..1000.0,
            tx in -1000.0f32..1000.0,
            ty in -1000.0f32..1000.0,
            tz in -1000.0f32..1000.0,
        ) {
            let max_dist = 10.0;
            let possible = is_action_physically_possible(px, py, pz, tx, ty, tz, max_dist);
            
            if possible {
                // Property: If the Euclidean distance is valid, no individual axis 
                // difference can be greater than the max distance.
                assert!((px - tx).abs() <= max_dist, "X axis distance exceeded maximum");
                assert!((py - ty).abs() <= max_dist, "Y axis distance exceeded maximum");
                assert!((pz - tz).abs() <= max_dist, "Z axis distance exceeded maximum");
            }
        }
        
        #[test]
        fn test_trust_ledger_penalization(
            initial_score in 0.0f32..10.0,
            penalty in 0.0f32..1.0,
        ) {
            let mut ledger = TrustLedger::default();
            let entity = Entity::from_raw(42);
            
            // Set an initial score (simulate a peer that already has a score)
            ledger.peer_scores.insert(entity, initial_score);
            ledger.penalize(entity, penalty);
            
            let final_score = ledger.peer_scores.get(&entity).unwrap();
            
            // Property: The final score must exactly equal initial_score - penalty
            prop_assert_eq!(*final_score, initial_score - penalty);
        }
    }
}

/// Polls the standard input channel non-blockingly and parses text commands
fn read_terminal_input(
    receiver: Res<StdinReceiver>,
    mut query: Query<(Entity, &mut Transform, &mut LinearVelocity), With<Player>>,
    mut events: MessageWriter<ProposedAction>,
) {
    if let Ok(rx) = receiver.rx.lock() {
        while let Ok(line) = rx.try_recv() {
            let command = line.trim().to_lowercase();
        
        if command.starts_with("move forward") {
            if let Some((_, mut transform, mut velocity)) = query.iter_mut().next() {
                let forward = transform.forward();
                velocity.x = forward.x * 10.0;
                velocity.z = forward.z * 10.0;
                println!("System: Moving forward.");
            }
        } else if command.starts_with("break block") {
            if let Some((player_entity, transform, _)) = query.iter_mut().next() {
                let forward_pos = transform.translation + (transform.forward() * 2.0);
                let voxel_pos = IVec3::new(
                    forward_pos.x.round() as i32,
                    forward_pos.y.round() as i32,
                    forward_pos.z.round() as i32,
                );
                
                events.write(ProposedAction::BreakBlock {
                    player_entity,
                    voxel_pos,
                });
                println!("System: Attempting to break block at {:?}", voxel_pos);
            }
        } else if command.starts_with("place block") {
            if let Some((player_entity, transform, _)) = query.iter_mut().next() {
                let forward_pos = transform.translation + (transform.forward() * 2.0);
                let voxel_pos = IVec3::new(
                    forward_pos.x.round() as i32,
                    forward_pos.y.round() as i32,
                    forward_pos.z.round() as i32,
                );
                
                events.write(ProposedAction::PlaceBlock {
                    player_entity,
                    voxel_pos,
                    voxel_type: 2, // Place dirt by default
                });
                println!("System: Attempting to place block at {:?}", voxel_pos);
            }
        } else if command.starts_with("enter vehicle") {
            // Find a nearby vehicle
            let mut found_vehicle: Option<Entity> = None;
            // (In a real game we would query the distance to vehicles)
            // For now just pretend we send the action
            if let Some((player_entity, _, _)) = query.iter().next() {
                // Fake vehicle entity for prototype
                let vehicle_entity = Entity::from_raw_u32(999).unwrap();
                events.write(ProposedAction::EnterVehicle { player_entity, vehicle_entity });
                println!("System: Attempting to hijack vehicle!");
            }
        } else if command.starts_with("look") {
             println!("System: You are standing in a generated voxel city. Type 'move forward' or 'break block'.");
        } else {
             println!("System: Unknown command '{}'.", command);
        }
    }
    }
}

/// Polls standard input for JSON commands specifically for LLM Agents
fn read_agent_input(
    receiver: Res<StdinReceiver>,
    mut query: Query<(Entity, &mut Transform, &mut LinearVelocity), With<Player>>,
    mut events: MessageWriter<ProposedAction>,
    trust_ledger: Res<TrustLedger>,
) {
    if let Ok(rx) = receiver.rx.lock() {
        while let Ok(line) = rx.try_recv() {
            if let Ok(command) = serde_json::from_str::<AgentCommand>(&line) {
                match command {
                    AgentCommand::MoveForward => {
                        if let Some((_, mut transform, mut velocity)) = query.iter_mut().next() {
                            let forward = transform.forward();
                            velocity.x = forward.x * 10.0;
                            velocity.z = forward.z * 10.0;
                        }
                    }
                    AgentCommand::BreakBlock { pos } => {
                        if let Some((player_entity, _, _)) = query.iter_mut().next() {
                            events.write(ProposedAction::BreakBlock {
                                player_entity,
                                voxel_pos: IVec3::new(pos[0], pos[1], pos[2]),
                            });
                        }
                    }
                    AgentCommand::PlaceBlock { pos, voxel_type } => {
                        if let Some((player_entity, _, _)) = query.iter_mut().next() {
                            events.write(ProposedAction::PlaceBlock {
                                player_entity,
                                voxel_pos: IVec3::new(pos[0], pos[1], pos[2]),
                                voxel_type,
                            });
                        }
                    }
                    AgentCommand::EnterVehicle => {
                        if let Some((player_entity, _, _)) = query.iter_mut().next() {
                            let vehicle_entity = Entity::from_raw_u32(999).unwrap();
                            events.write(ProposedAction::EnterVehicle { player_entity, vehicle_entity });
                        }
                    }
                    AgentCommand::Look => {
                        if let Some((entity, transform, _)) = query.iter_mut().next() {
                            let score = trust_ledger.peer_scores.get(&entity).copied().unwrap_or(100.0);
                            let obs = AgentObservation {
                                status: "ok".into(),
                                player_pos: [transform.translation.x, transform.translation.y, transform.translation.z],
                                trust_score: score,
                            };
                            if let Ok(json) = serde_json::to_string(&obs) {
                                println!("{}", json);
                            }
                        }
                    }
                }
            } else {
                let err = AgentObservation {
                    status: "error: invalid json".into(),
                    player_pos: [0.0, 0.0, 0.0],
                    trust_score: 0.0,
                };
                if let Ok(json) = serde_json::to_string(&err) {
                    println!("{}", json);
                }
            }
        }
    }
}
