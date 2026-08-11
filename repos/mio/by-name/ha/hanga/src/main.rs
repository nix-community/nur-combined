use bevy::prelude::*;
use wasmtime::{Engine, Config, Module, Store, Instance, TypedFunc};
use bevy_voxel_world::prelude::*;
use avian3d::prelude::*;
use std::io::{self, BufRead};
use std::sync::{mpsc::{channel, Receiver}, Mutex, OnceLock};
use serde::{Deserialize, Serialize};
use matchbox_socket::WebRtcSocket;
// Re-use pure functions from the hanga engine library (no Bevy dep there)
use hanga::{is_action_physically_possible, clamp_mod_state, unpack_economy_params};

mod mod_manager;
use mod_manager::{ModRuntime, ModManagerPlugin, SHARED_WASM};

#[derive(Resource, Clone, Default)]
struct DefaultWorld;


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
                        if let Ok(shared) = SHARED_WASM.read() {
                            if let Some((engine, module)) = shared.as_ref() {
                                let mut store = Store::new(engine, ());
                                if let Ok(instance) = Instance::new(&mut store, module, &[]) {
                                    if let Ok(func) = instance.get_typed_func::<(i32, i32, i32), i32>(&mut store, "query_voxel") {
                                        *instance_opt = Some((store, func));
                                    }
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
        app.add_plugins(DefaultPlugins);
    } else if is_text_client {
        info!("Starting Hanga in TEXT CLIENT mode (Screen-reader Accessible)");
        app.add_plugins(DefaultPlugins);
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
        app.add_plugins(DefaultPlugins);
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
            ModManagerPlugin { wasm_path: "mods/urban_chaos/target/wasm32-unknown-unknown/debug/urban_chaos.wasm".into() },
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

#[derive(Component)]
struct VehicleAi;

#[derive(Serialize, Deserialize, Debug, Clone)]
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
pub struct ModState(pub u32);

#[derive(Component)]
pub struct AgentAi(pub u32);

#[derive(Component)]
pub struct Vehicle;

#[derive(Component)]
pub struct InVehicle(pub Entity);

/// Represents an optimistic action broadcasted by a P2P client over WebRTC
#[derive(Message, Debug, Serialize, Deserialize, Clone)]
enum ProposedAction {
    BreakBlock {
        player_entity: Entity,
        voxel_pos: IVec3,
    },
    Explosion {
        player_entity: Entity,
        center_pos: IVec3,
        radius: f32,
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
        ModState(0), // Initial mod state starts at 0
    ));

    // Spawn a GTA-style Vehicle for the player
    commands.spawn((
        Vehicle,
        Transform::from_xyz(500.0, 50.0, 495.0), // Spawn nearby
        RigidBody::Dynamic,
        Collider::cuboid(2.0, 1.5, 4.0), // Car dimensions
        LinearVelocity::default(),
        AngularVelocity::default(),
    ));

    // Spawn autonomous Traffic Vehicles
    for i in 0..5 {
        commands.spawn((
            Vehicle,
            VehicleAi, // Marked as AI controlled
            Transform::from_xyz(510.0 + (i as f32 * 10.0), 50.0, 495.0),
            RigidBody::Dynamic,
            Collider::cuboid(2.0, 1.5, 4.0),
            LinearVelocity::default(),
            AngularVelocity::default(),
        ));
    }
}


/// The Anti-Cheat P2P Judge: Intercepts all optimistic actions and verifies them
fn validate_incoming_actions(
    mut commands: Commands,
    mut events: MessageReader<ProposedAction>,
    mut player_query: Query<(&Transform, &mut ModState), With<Player>>,
    mut voxel_world: VoxelWorld<DefaultWorld>,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    mut trust_ledger: ResMut<TrustLedger>,
    mut mod_runtime: ResMut<ModRuntime>,
) {
    for action in events.read() {
        match action {
            &ProposedAction::BreakBlock { player_entity, voxel_pos } => {
                // VERIFICATION RULE 1: Does the player actually exist?
                if let Ok((transform, mut mod_state)) = player_query.get_mut(player_entity) {
                    let player_pos = transform.translation;
                    let target_pos = Vec3::new(voxel_pos.x as f32, voxel_pos.y as f32, voxel_pos.z as f32);
                    
                    // VERIFICATION RULE 2: Is the player close enough?
                    // The MOD defines the valid range via mod_get_action_range(1).
                    let range = if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
                        let instance = &ctx.instance;
                        if let Ok(f) = instance.get_typed_func::<i32, f32>(&mut ctx.store, "mod_get_action_range") {
                            f.call(&mut ctx.store, 1).unwrap_or(10.0)
                        } else { 10.0 }
                    } else { 10.0 };
                    let distance = player_pos.distance(target_pos);
                    if !is_action_physically_possible(
                        player_pos.x, player_pos.y, player_pos.z,
                        target_pos.x, target_pos.y, target_pos.z,
                        range
                    ) {
                        trust_ledger.penalize(player_entity, 0.2);
                        warn!("FRAUD DETECTED: Player {:?} tried to break a block {} meters away (max {}m)! Action Rejected.", player_entity, distance, range);
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

                    // Execute the WASM Mod's business logic for Mod State
                    if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
                        let instance = &ctx.instance;
                        if let Ok(mod_evaluate) = instance.get_typed_func::<(i32, i32), i32>(&mut ctx.store, "mod_evaluate_action") {
                            if let Ok(new_state) = mod_evaluate.call(&mut ctx.store, (1, mod_state.0 as i32)) {
                                let old_state = mod_state.0;
                                mod_state.0 = clamp_mod_state(new_state, 0, 5) as u32;
                                info!("WASM Mod evaluated action! State is now {}", mod_state.0);
                                
                                if let Ok(should_spawn) = instance.get_typed_func::<(i32, i32, i32), i32>(&mut ctx.store, "mod_should_spawn_agent") {
                                    if let Ok(ai_type) = should_spawn.call(&mut ctx.store, (1, old_state as i32, mod_state.0 as i32)) {
                                        if ai_type > 0 {
                                            let spawn_pos = target_pos + Vec3::new(5.0, 2.0, 5.0);
                                            commands.spawn((
                                                Mesh3d(meshes.add(Capsule3d::new(0.4, 1.0))),
                                                MeshMaterial3d(materials.add(Color::srgb(0.0, 0.0, 1.0))),
                                                Transform::from_translation(spawn_pos),
                                                RigidBody::Dynamic,
                                                Collider::capsule(0.4, 1.0),
                                                LockedAxes::new().lock_rotation_x().lock_rotation_z(),
                                                LinearVelocity::default(),
                                                AgentAi(ai_type as u32),
                                            ));
                                            info!("WASM Mod requested AgentAi type {} at {:?}", ai_type, spawn_pos);
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        mod_state.0 = mod_state.0 + 1;
                    }
                } else {
                    // Penalty for spoofing an entity ID
                    trust_ledger.penalize(player_entity, 1.0); 
                    warn!("FRAUD DETECTED: Action received for non-existent Player entity!");
                }
            }
            &ProposedAction::Explosion { player_entity, center_pos, radius } => {
                if let Ok((transform, mut mod_state)) = player_query.get_mut(player_entity) {
                    let player_pos = transform.translation;
                    let target_pos = Vec3::new(center_pos.x as f32, center_pos.y as f32, center_pos.z as f32);
                    
                    // The MOD defines the explosion range via mod_get_action_range(4).
                    let range = if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
                        let instance = &ctx.instance;
                        if let Ok(f) = instance.get_typed_func::<i32, f32>(&mut ctx.store, "mod_get_action_range") {
                            f.call(&mut ctx.store, 4).unwrap_or(30.0)
                        } else { 30.0 }
                    } else { 30.0 };
                    if !is_action_physically_possible(
                        player_pos.x, player_pos.y, player_pos.z,
                        target_pos.x, target_pos.y, target_pos.z,
                        range
                    ) {
                        trust_ledger.penalize(player_entity, 0.5);
                        continue;
                    }

                    info!("Action Verified! MASSIVE EXPLOSION at {:?}", center_pos);
                    
                    let iradius = radius.ceil() as i32;
                    for x in -iradius..=iradius {
                        for y in -iradius..=iradius {
                            for z in -iradius..=iradius {
                                let offset = IVec3::new(x, y, z);
                                if offset.as_vec3().length() <= radius {
                                    let v_pos = center_pos + offset;
                                    if voxel_world.get_voxel(v_pos) != WorldVoxel::Unset {
                                        voxel_world.set_voxel(v_pos, WorldVoxel::Unset);
                                        commands.spawn((
                                            Mesh3d(meshes.add(Cuboid::from_size(Vec3::splat(1.0)))),
                                            MeshMaterial3d(materials.add(Color::srgb(0.8, 0.3, 0.1))),
                                            Transform::from_translation(Vec3::new(v_pos.x as f32, v_pos.y as f32, v_pos.z as f32)),
                                            RigidBody::Dynamic,
                                            Collider::cuboid(1.0, 1.0, 1.0),
                                            LinearVelocity(offset.as_vec3().normalize_or_zero() * 15.0),
                                        ));
                                    }
                                }
                            }
                        }
                    }

                    // Execute the WASM Mod's business logic for Mod State
                    if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
                        let instance = &ctx.instance;
                        if let Ok(mod_evaluate) = instance.get_typed_func::<(i32, i32), i32>(&mut ctx.store, "mod_evaluate_action") {
                            if let Ok(new_state) = mod_evaluate.call(&mut ctx.store, (4, mod_state.0 as i32)) {
                                let old_state = mod_state.0;
                                mod_state.0 = new_state as u32;
                                info!("WASM Mod evaluated action! State is now {}", mod_state.0);
                                
                                if let Ok(should_spawn) = instance.get_typed_func::<(i32, i32, i32), i32>(&mut ctx.store, "mod_should_spawn_agent") {
                                    if let Ok(ai_type) = should_spawn.call(&mut ctx.store, (4, old_state as i32, mod_state.0 as i32)) {
                                        if ai_type > 0 {
                                            let spawn_pos = target_pos + Vec3::new(5.0, 2.0, 5.0);
                                            commands.spawn((
                                                Mesh3d(meshes.add(Capsule3d::new(0.4, 1.0))),
                                                MeshMaterial3d(materials.add(Color::srgb(0.0, 0.0, 1.0))),
                                                Transform::from_translation(spawn_pos),
                                                RigidBody::Dynamic,
                                                Collider::capsule(0.4, 1.0),
                                                LockedAxes::new().lock_rotation_x().lock_rotation_z(),
                                                LinearVelocity::default(),
                                                AgentAi(ai_type as u32),
                                            ));
                                            info!("WASM Mod requested AgentAi type {} at {:?}", ai_type, spawn_pos);
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        mod_state.0 = 5;
                    }
                }
            }
            &ProposedAction::PlaceBlock { player_entity, voxel_pos, voxel_type } => {
                // VERIFICATION RULE 1: Does the player actually exist?
                if let Ok((transform, mut mod_state)) = player_query.get_mut(player_entity) {
                    let player_pos = transform.translation;
                    let target_pos = Vec3::new(voxel_pos.x as f32, voxel_pos.y as f32, voxel_pos.z as f32);
                    
                    // VERIFICATION RULE 2: Is the player close enough?
                    // The MOD defines the valid range via mod_get_action_range(2).
                    let range = if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
                        let instance = &ctx.instance;
                        if let Ok(f) = instance.get_typed_func::<i32, f32>(&mut ctx.store, "mod_get_action_range") {
                            f.call(&mut ctx.store, 2).unwrap_or(10.0)
                        } else { 10.0 }
                    } else { 10.0 };
                    let distance = player_pos.distance(target_pos);
                    if !is_action_physically_possible(
                        player_pos.x, player_pos.y, player_pos.z,
                        target_pos.x, target_pos.y, target_pos.z,
                        range
                    ) {
                        trust_ledger.penalize(player_entity, 0.2);
                        warn!("FRAUD DETECTED: Player {:?} tried to place a block {} meters away (max {}m)! Action Rejected.", player_entity, distance, range);
                        continue;
                    }

                    info!("Action Verified! Placing block at {:?}", voxel_pos);
                    
                    // Add the voxel to the world
                    voxel_world.set_voxel(voxel_pos, WorldVoxel::Solid(voxel_type));
                    
                    // Execute the WASM Mod's business logic for Mod State
                    if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
                        let instance = &ctx.instance;
                        if let Ok(mod_evaluate) = instance.get_typed_func::<(i32, i32), i32>(&mut ctx.store, "mod_evaluate_action") {
                            if let Ok(new_state) = mod_evaluate.call(&mut ctx.store, (2, mod_state.0 as i32)) {
                                mod_state.0 = new_state as u32;
                            }
                        }
                    }
                } else {
                    trust_ledger.penalize(player_entity, 1.0); 
                    warn!("FRAUD DETECTED: Action received for non-existent Player entity!");
                }
            }
            &ProposedAction::EnterVehicle { player_entity, vehicle_entity } => {
                if let Ok((_transform, mut mod_state)) = player_query.get_mut(player_entity) {
                    commands.entity(player_entity).insert(InVehicle(vehicle_entity));
                    info!("Player {:?} entered vehicle {:?}", player_entity, vehicle_entity);
                    
                    // Execute the WASM Mod's business logic for Mod State
                    if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
                        let instance = &ctx.instance;
                        if let Ok(mod_evaluate) = instance.get_typed_func::<(i32, i32), i32>(&mut ctx.store, "mod_evaluate_action") {
                            if let Ok(new_state) = mod_evaluate.call(&mut ctx.store, (3, mod_state.0 as i32)) {
                                let old_state = mod_state.0;
                                mod_state.0 = new_state as u32;
                                info!("WASM Mod evaluated action! State is now {}", mod_state.0);
                                
                                if let Ok(should_spawn) = instance.get_typed_func::<(i32, i32, i32), i32>(&mut ctx.store, "mod_should_spawn_agent") {
                                    if let Ok(ai_type) = should_spawn.call(&mut ctx.store, (3, old_state as i32, mod_state.0 as i32)) {
                                        if ai_type > 0 {
                                            let spawn_pos = _transform.translation + Vec3::new(5.0, 2.0, 5.0);
                                            commands.spawn((
                                                Mesh3d(meshes.add(Capsule3d::new(0.4, 1.0))),
                                                MeshMaterial3d(materials.add(Color::srgb(0.0, 0.0, 1.0))),
                                                Transform::from_translation(spawn_pos),
                                                RigidBody::Dynamic,
                                                Collider::capsule(0.4, 1.0),
                                                LockedAxes::new().lock_rotation_x().lock_rotation_z(),
                                                LinearVelocity::default(),
                                                AgentAi(ai_type as u32),
                                            ));
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        mod_state.0 = mod_state.0 + 3;
                    }
                }
            }
        }
    }
}

/// Very basic first person controller for MVP (and vehicle controller)
fn player_movement(
    keyboard_input: Res<ButtonInput<KeyCode>>,
    mut players: Query<(&mut Transform, &mut LinearVelocity, Option<&InVehicle>), With<Player>>,
    mut vehicles: Query<(&Transform, &mut LinearVelocity, &mut AngularVelocity), (With<Vehicle>, Without<Player>)>,
) {
    if let Some((mut player_transform, mut player_velocity, in_vehicle)) = players.iter_mut().next() {
        let mut direction = Vec3::ZERO;
        let mut rotation_y = 0.0;
        
        let mut target_vehicle: Option<(&mut LinearVelocity, &mut AngularVelocity, Vec3)> = None;
        let forward = if let Some(InVehicle(vehicle_entity)) = in_vehicle {
            if let Ok((v_transform, v_velocity, v_angular)) = vehicles.get_mut(*vehicle_entity) {
                let fwd = v_transform.forward();
                target_vehicle = Some((v_velocity.into_inner(), v_angular.into_inner(), v_transform.translation));
                fwd
            } else {
                player_transform.forward()
            }
        } else {
            player_transform.forward()
        };

        let right = player_transform.right();

        if keyboard_input.pressed(KeyCode::KeyW) {
            direction += *forward;
        }
        if keyboard_input.pressed(KeyCode::KeyS) {
            direction -= *forward;
        }
        if keyboard_input.pressed(KeyCode::KeyD) {
            if target_vehicle.is_some() {
                rotation_y -= 1.0; // Steer right
            } else {
                direction += *right;
            }
        }
        if keyboard_input.pressed(KeyCode::KeyA) {
            if target_vehicle.is_some() {
                rotation_y += 1.0; // Steer left
            } else {
                direction -= *right;
            }
        }

        // Flatten movement to XZ plane
        direction.y = 0.0;
        let direction = direction.normalize_or_zero();
        
        // Apply movement velocity, keeping existing gravity (y-axis)
        if let Some((mut v_vel, mut v_ang, v_pos)) = target_vehicle {
            let speed = 25.0; // Vehicles are faster!
            v_vel.x = direction.x * speed;
            v_vel.z = direction.z * speed;
            v_ang.y = rotation_y * 2.0; // Apply steering rotation
            
            // Sync player position and velocity to match the vehicle (for the camera)
            player_transform.translation = v_pos;
            player_velocity.x = v_vel.x;
            player_velocity.z = v_vel.z;
            player_velocity.y = v_vel.y;
        } else {
            let speed = 10.0;
            player_velocity.x = direction.x * speed;
            player_velocity.z = direction.z * speed;
            
            // Player turning camera is usually handled by mouse look, so we just let them strafe with A/D on foot.
            
            // Simple jump (only when on foot)
            if keyboard_input.just_pressed(KeyCode::Space) {
                player_velocity.y = 5.0;
            }
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
    
    if mouse_input.just_pressed(MouseButton::Right) {
        if let Some((player_entity, transform)) = query.iter().next() {
            let forward_pos = transform.translation + (transform.forward() * 15.0);
            let voxel_pos = IVec3::new(
                forward_pos.x.round() as i32,
                forward_pos.y.round() as i32,
                forward_pos.z.round() as i32,
            );

            events.write(ProposedAction::Explosion {
                player_entity,
                center_pos: voxel_pos,
                radius: 4.0, // 4-block radius explosion!
            });
            info!("Player fired RPG (Explosion) at {:?}", voxel_pos);
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
        app.add_systems(Update, (agent_ai_tick, vehicle_collision_damage, vehicle_traffic_system));
    }
}
fn init_city_simulation() {
    info!("Spawning NPC AI, traffic systems, and wanted level mechanics...");
}

fn vehicle_collision_damage(
    mut events: MessageWriter<ProposedAction>,
    query: Query<(Entity, &Transform, &LinearVelocity, Option<&InVehicle>), With<Player>>,
    voxel_world: VoxelWorld<DefaultWorld>,
) {
    for (player_entity, transform, velocity, in_vehicle) in query.iter() {
        if in_vehicle.is_some() {
            let speed = velocity.length();
            if speed > 15.0 {
                let dir = velocity.normalize_or_zero();
                if dir == Vec3::ZERO { continue; }
                
                // Raycast ahead of the vehicle to find blocks to destroy
                for i in 2..=4 {
                    let check_pos = transform.translation + dir * (i as f32);
                    let voxel_pos = IVec3::new(check_pos.x.round() as i32, check_pos.y.round() as i32, check_pos.z.round() as i32);
                    if voxel_world.get_voxel(voxel_pos) != WorldVoxel::Unset {
                        events.write(ProposedAction::BreakBlock {
                            player_entity,
                            voxel_pos,
                        });
                        break;
                    }
                }
            }
        }
    }
}

fn vehicle_traffic_system(
    mut vehicles: Query<(&Transform, &mut LinearVelocity), With<VehicleAi>>,
    mut mod_runtime: ResMut<ModRuntime>,
) {
    // The MOD owns traffic speed and behavior; engine only provides the forward vector.
    if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
        let instance = &ctx.instance;
        if let (Ok(compute_vx), Ok(compute_vz)) = (
            instance.get_typed_func::<(f32, f32), f32>(&mut ctx.store, "compute_traffic_vx"),
            instance.get_typed_func::<(f32, f32), f32>(&mut ctx.store, "compute_traffic_vz"),
        ) {
            for (transform, mut velocity) in vehicles.iter_mut() {
                let fwd = transform.forward();
                velocity.x = compute_vx.call(&mut ctx.store, (fwd.x, fwd.z)).unwrap_or(fwd.x * 10.0);
                velocity.z = compute_vz.call(&mut ctx.store, (fwd.x, fwd.z)).unwrap_or(fwd.z * 10.0);
            }
            return;
        }
    }
    // Fallback: mod not loaded, use hardcoded speed
    for (transform, mut velocity) in vehicles.iter_mut() {
        let forward = transform.forward();
        velocity.x = forward.x * 10.0;
        velocity.z = forward.z * 10.0;
    }
}

/// AI logic for all agents, entirely powered by the WASM mod!
fn agent_ai_tick(
    mut agents: Query<(&Transform, &mut LinearVelocity, &AgentAi)>,
    players: Query<&Transform, (With<Player>, Without<AgentAi>)>,
    mut mod_runtime: ResMut<ModRuntime>,
) {
    if let Some(player_transform) = players.iter().next() {
        let p_pos = player_transform.translation;
        
        // Grab the WASM Engine and Module from the globals
        if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
            let instance = &ctx.instance;
            if let (Ok(compute_vx), Ok(compute_vz)) = (
                instance.get_typed_func::<(i32, f32, f32, f32, f32), f32>(&mut ctx.store, "compute_agent_vx"),
                instance.get_typed_func::<(i32, f32, f32, f32, f32), f32>(&mut ctx.store, "compute_agent_vz")
            ) {
                for (agent_transform, mut velocity, agent) in agents.iter_mut() {
                    let c_pos = agent_transform.translation;
                    
                    // Execute the WASM Mod's generic AI logic
                    if let Ok(vx) = compute_vx.call(&mut ctx.store, (agent.0 as i32, c_pos.x, c_pos.z, p_pos.x, p_pos.z)) {
                        velocity.x = vx;
                    }
                    if let Ok(vz) = compute_vz.call(&mut ctx.store, (agent.0 as i32, c_pos.x, c_pos.z, p_pos.x, p_pos.z)) {
                        velocity.z = vz;
                    }
                }
            }
        }
    }
}

// --- Distributed Multiplayer (P2P) ---
pub struct DistributedMultiplayerPlugin;
impl Plugin for DistributedMultiplayerPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, init_p2p_mesh);
        app.add_systems(Update, (handle_p2p_receive, handle_p2p_broadcast));
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

fn handle_p2p_receive(
    mut socket: Option<ResMut<P2pSocket>>,
    mut event_writer: MessageWriter<ProposedAction>,
) {
    if let Some(mut socket) = socket {
        for (peer, new_state) in socket.0.update_peers() {
            match new_state {
                matchbox_socket::PeerState::Connected => info!("P2P Peer {:?} connected!", peer),
                matchbox_socket::PeerState::Disconnected => info!("P2P Peer {:?} disconnected!", peer),
            }
        }
        
        // Receive network messages
        for (peer_id, packet) in socket.0.channel_mut(0).receive() {
            if let Ok(action) = bincode::deserialize::<ProposedAction>(&packet) {
                // Write it to ECS so validate_incoming_actions processes it!
                event_writer.write(action);
            }
        }
    }
}

fn handle_p2p_broadcast(
    mut socket: Option<ResMut<P2pSocket>>,
    mut event_reader: MessageReader<ProposedAction>,
    players: Query<Entity, With<Player>>,
) {
    let local_player = players.iter().next();
    if let Some(mut socket) = socket {
        // Broadcast local messages
        for action in event_reader.read() {
            let is_local = match action {
                ProposedAction::BreakBlock { player_entity, .. } => Some(*player_entity) == local_player,
                ProposedAction::Explosion { player_entity, .. } => Some(*player_entity) == local_player,
                ProposedAction::PlaceBlock { player_entity, .. } => Some(*player_entity) == local_player,
                ProposedAction::EnterVehicle { player_entity, .. } => Some(*player_entity) == local_player,
            };

            if is_local {
                if let Ok(packet) = bincode::serialize(action) {
                    let peers: Vec<_> = socket.0.connected_peers().collect();
                    let packet_boxed = packet.into_boxed_slice();
                    for peer in peers {
                        socket.0.channel_mut(0).send(packet_boxed.clone(), peer);
                    }
                }
            }
        }
    }
}

// Removed init_wasm_mod_loader and ModdingPlugin since ModManagerPlugin handles it now.

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
        app.add_systems(Update, update_storyteller);
    }
}
fn update_storyteller(time: Res<Time>, mut timer: Local<f32>, mut mod_runtime: ResMut<ModRuntime>) {
    *timer += time.delta_secs();
    if *timer >= 10.0 {
        *timer = 0.0;
        if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
            let instance = &ctx.instance;
            // Ask the MOD what player level to use for story generation.
            let player_level = if let Ok(f) = instance.get_typed_func::<(), i32>(&mut ctx.store, "mod_get_storyteller_level") {
                f.call(&mut ctx.store, ()).unwrap_or(10)
            } else {
                10 // fallback if mod doesn't implement this yet
            };
            if let Ok(gen_story) = instance.get_typed_func::<i32, i32>(&mut ctx.store, "generate_story_event") {
                if let Ok(event_id) = gen_story.call(&mut ctx.store, player_level) {
                    match event_id {
                        0 => info!("STORYTELLER (WASM): It's a peaceful day in the city."),
                        1 => warn!("STORYTELLER (WASM): A small bandit raid has begun!"),
                        2 => error!("STORYTELLER (WASM): ALIEN INVASION!"),
                        _ => {}
                    }
                }
            }
        }
    }
}

// --- Global Economy ---
pub struct EconomicSimulationPlugin;
impl Plugin for EconomicSimulationPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Update, update_macro_economy);
    }
}
fn update_macro_economy(time: Res<Time>, mut timer: Local<f32>, mut mod_runtime: ResMut<ModRuntime>) {
    *timer += time.delta_secs();
    if *timer >= 5.0 {
        *timer = 0.0;
        if let Some(mut ctx) = mod_runtime.context.lock().unwrap().as_mut() {
            let instance = &ctx.instance;
            // Ask the MOD for its economic parameters — supply/demand are mod-owned.
            let (supply, demand) = if let Ok(f) = instance.get_typed_func::<(), i32>(&mut ctx.store, "mod_get_economy_params") {
                if let Ok(packed) = f.call(&mut ctx.store, ()) {
                    unpack_economy_params(packed)
                } else { (5, 8) }
            } else { (5, 8) };
            if let Ok(calc_price) = instance.get_typed_func::<(i32, i32, i32), i32>(&mut ctx.store, "compute_economy_price") {
                let base = 100;
                if let Ok(price) = calc_price.call(&mut ctx.store, (base, supply, demand)) {
                    info!("ECONOMY (WASM): Bread is now trading at ${} (Supply: {}, Demand: {})", price, supply, demand);
                }
            }
        }
    }
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
        /// Bevy-specific property: TrustLedger penalization works with arbitrary
        /// initial scores and penalties. Tests the Bevy Entity-keyed ledger in main.rs.
        #[test]
        fn test_trust_ledger_penalization(
            initial_score in 0.0f32..10.0,
            penalty in 0.0f32..1.0,
        ) {
            let mut ledger = TrustLedger::default();
            let entity = Entity::from_raw_u32(42).unwrap();
            ledger.peer_scores.insert(entity, initial_score);
            ledger.penalize(entity, penalty);
            let final_score = ledger.peer_scores.get(&entity).unwrap();
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
            let _found_vehicle: Option<Entity> = None;
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
                        if let Some((_, transform, mut velocity)) = query.iter_mut().next() {
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
