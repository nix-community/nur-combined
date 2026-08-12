use bevy::prelude::*;
use wasmtime::Store;
use wasmtime::component::Linker;
use bevy_voxel_world::prelude::*;
use avian3d::prelude::*;
use std::io::{self, BufRead};
use std::path::PathBuf;
use std::sync::{mpsc::{channel, Receiver}, Mutex};
use serde::{Deserialize, Serialize};
use matchbox_socket::WebRtcSocket;
use hanga::i18n::{self, Locale, TextCommand};
use hanga::{
    action_fingerprint, clamp_mod_state, clamp_voxel_type, clamp_wallet, contract_is_offered,
    fracture_offsets, is_action_physically_possible, is_connected_to_ground,
    unpack_economy_params, verify_action_signature, voxel_has_support,
};

mod mod_manager;
use mod_manager::{ModRuntime, ModManagerPlugin, SHARED_WASM};

#[derive(Resource, Clone, Default)]
struct DefaultWorld;


thread_local! {
    static WASM_INSTANCE: std::cell::RefCell<Option<(Store<()>, mod_manager::Plugin)>> = std::cell::RefCell::new(None);
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
                            if let Some((engine, component)) = shared.as_ref() {
                                let mut store = Store::new(engine, ());
                                if let Ok(instance) = mod_manager::Plugin::instantiate(&mut store, component, &Linker::new(engine)) {
                                    *instance_opt = Some((store, instance));
                                }
                            }
                        }
                    }
                    
                    if let Some((store, func)) = instance_opt.as_mut() {
                        if let Ok(voxel_type) = func.hanga_engine_gameplay().call_query_voxel(store, pos.x, pos.y, pos.z) {
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

#[derive(Resource, Clone, Copy, Default)]
struct UiLocale(Locale);

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
    let locale = Locale::from_env_and_args(&args);

    let mut app = App::new();

    let (tx, rx) = channel();

    if is_headless {
        info!("Starting Hanga in HEADLESS NODE mode (Persistent Server)");
        app.add_plugins(DefaultPlugins.set(WindowPlugin {
            primary_window: None,
            ..default()
        }));
    } else if is_text_client {
        info!("Starting Hanga in TEXT CLIENT mode (Screen-reader Accessible)");
        app.add_plugins(DefaultPlugins);
        app.insert_resource(StdinReceiver { rx: Mutex::new(rx) });
        app.add_systems(Update, read_terminal_input.after(validate_incoming_actions));

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
        app.add_systems(Update, read_agent_input.after(validate_incoming_actions));

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

    let mod_name = args
        .windows(2)
        .find(|w| w[0] == "--mod")
        .map(|w| w[1].as_str())
        .unwrap_or("urban_chaos");
    let wasm_path = resolve_wasm_path(mod_name);
    info!(
        "Loading WASM mod '{}' from {} (locale {})",
        mod_name,
        wasm_path.display(),
        locale.code()
    );

    app.add_plugins((
            VoxelWorldPlugin::with_config(DefaultWorld),
            PhysicsPlugins::default(),
            CitySimPlugin,
            DistributedMultiplayerPlugin,
            ModManagerPlugin { wasm_path: wasm_path.to_string_lossy().into_owned() },
            AiStorytellerPlugin,
            EconomicSimulationPlugin,
        ))
        .init_resource::<TrustLedger>()
        .init_resource::<ModOffer>()
        .insert_resource(CheatMode(is_cheater))
        .insert_resource(UiLocale(locale))
        .add_systems(Startup, setup)
        .add_message::<ProposedAction>()
        .add_systems(
            Update,
            (
                generate_voxel_colliders,
                player_movement,
                player_interaction,
                validate_incoming_actions,
            )
                .chain(),
        )
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
    AcceptJob,
    CompleteJob,
    Fence,
}

#[derive(Serialize, Debug)]
struct AgentObservation {
    status: String,
    player_pos: [f32; 3],
    trust_score: f32,
    wanted_level: u32,
    credits: i32,
    offer_kind: i32,
    contract_kind: i32,
    voxel_ahead: i32,
    voxel_label: String,
    locale: String,
    in_vehicle: bool,
}

#[derive(Component)]
pub struct Player;

#[derive(Component)]
pub struct ModState(pub u32);

/// Opaque integer owned by the loaded mod (credits in Urban Chaos).
#[derive(Component, Default)]
pub struct ModWallet(pub i32);

/// Active contract tuple from the mod: kind, payout, danger. kind 0 = none.
#[derive(Component, Default, Clone, Copy)]
pub struct ModContract {
    pub kind: i32,
    pub payout: i32,
    pub danger: i32,
}

/// Latest storyteller offer. Engine does not interpret kind.
#[derive(Resource, Default, Clone, Copy)]
pub struct ModOffer {
    pub kind: i32,
    pub payout: i32,
    pub danger: i32,
}

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
        fingerprint: u64,
    },
    Explosion {
        player_entity: Entity,
        center_pos: IVec3,
        radius: f32,
        fingerprint: u64,
    },
    PlaceBlock {
        player_entity: Entity,
        voxel_pos: IVec3,
        voxel_type: u8,
        fingerprint: u64,
    },
    EnterVehicle {
        player_entity: Entity,
        vehicle_entity: Entity,
        fingerprint: u64,
    },
    /// Generic mod verb (5=accept, 6=complete, 7=fence). Engine does not name the game.
    Verb {
        player_entity: Entity,
        verb: i32,
        extra: i32,
        fingerprint: u64,
    },
}

fn signed_break(player_entity: Entity, voxel_pos: IVec3) -> ProposedAction {
    ProposedAction::BreakBlock {
        player_entity,
        voxel_pos,
        fingerprint: action_fingerprint(1, voxel_pos.x, voxel_pos.y, voxel_pos.z, 0),
    }
}

fn signed_place(player_entity: Entity, voxel_pos: IVec3, voxel_type: u8) -> ProposedAction {
    ProposedAction::PlaceBlock {
        player_entity,
        voxel_pos,
        voxel_type,
        fingerprint: action_fingerprint(2, voxel_pos.x, voxel_pos.y, voxel_pos.z, voxel_type as i32),
    }
}

fn signed_enter(player_entity: Entity, vehicle_entity: Entity) -> ProposedAction {
    let bits = vehicle_entity.to_bits() as i32;
    ProposedAction::EnterVehicle {
        player_entity,
        vehicle_entity,
        fingerprint: action_fingerprint(3, bits, 0, 0, 0),
    }
}

fn signed_explosion(player_entity: Entity, center_pos: IVec3, radius: f32) -> ProposedAction {
    ProposedAction::Explosion {
        player_entity,
        center_pos,
        radius,
        fingerprint: action_fingerprint(4, center_pos.x, center_pos.y, center_pos.z, radius as i32),
    }
}

fn signed_verb(player_entity: Entity, verb: i32, extra: i32) -> ProposedAction {
    ProposedAction::Verb {
        player_entity,
        verb,
        extra,
        fingerprint: action_fingerprint(verb as u8, extra, 0, 0, 0),
    }
}

fn resolve_wasm_path(mod_name: &str) -> PathBuf {
    let file = format!("{mod_name}.wasm");
    let rel = PathBuf::from("mods")
        .join(mod_name)
        .join("target/wasm32-unknown-unknown/debug")
        .join(&file);
    if rel.exists() {
        return rel;
    }
    if let Ok(exe) = std::env::current_exe() {
        if let Some(dir) = exe.parent() {
            let next = dir.join(&rel);
            if next.exists() {
                return next;
            }
            let beside = dir.join("mods").join(&file);
            if beside.exists() {
                return beside;
            }
        }
    }
    rel
}

fn with_mod<T>(
    mod_runtime: &ModRuntime,
    f: impl FnOnce(&mut mod_manager::MainModContext) -> T,
) -> Option<T> {
    let mut guard = mod_runtime.context.lock().ok()?;
    let ctx = guard.as_mut()?;
    Some(f(ctx))
}

fn setup(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    mod_runtime: Res<ModRuntime>,
    locale: Res<UiLocale>,
) {
    info!("Hanga engine starting (gameplay owned by the loaded WASM mod)");
    if let Some(supported) = with_mod(&mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_supported_locales(&mut ctx.store)
            .unwrap_or_default()
    }) {
        info!(
            "Mod locales: {supported} (host locale {})",
            locale.0.code()
        );
    }

    let (px, py, pz) = with_mod(&mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_player_spawn(&mut ctx.store)
            .unwrap_or((490, 50, 490))
    })
    .unwrap_or((490, 50, 490));
    let player_pos = Vec3::new(px as f32, py as f32, pz as f32);

    commands.spawn((
        Camera3d::default(),
        Transform::from_translation(player_pos).looking_at(player_pos + Vec3::Z * 10.0, Vec3::Y),
        Player,
        RigidBody::Dynamic,
        Collider::capsule(0.4, 1.0),
        LinearVelocity::default(),
        AngularVelocity::default(),
        LockedAxes::new().lock_rotation_x().lock_rotation_z(),
        ModState(0),
        ModWallet(0),
        ModContract::default(),
    ));

    let count = with_mod(&mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_vehicle_spawn_count(&mut ctx.store)
            .unwrap_or(0)
    })
    .unwrap_or(0)
    .max(0) as u32;

    for i in 0..count {
        let (x, y, z) = with_mod(&mod_runtime, |ctx| {
            ctx.bindings
                .hanga_engine_gameplay()
                .call_vehicle_spawn(&mut ctx.store, i as i32)
                .unwrap_or((500, 50, 495))
        })
        .unwrap_or((500, 50, 495));
        let transform = Transform::from_xyz(x as f32, y as f32, z as f32);
        if i == 0 {
            commands.spawn((
                Vehicle,
                transform,
                RigidBody::Dynamic,
                Collider::cuboid(2.0, 1.5, 4.0),
                LinearVelocity::default(),
                AngularVelocity::default(),
            ));
        } else {
            commands.spawn((
                Vehicle,
                VehicleAi,
                transform,
                RigidBody::Dynamic,
                Collider::cuboid(2.0, 1.5, 4.0),
                LinearVelocity::default(),
                AngularVelocity::default(),
            ));
        }
    }

    let ambient = with_mod(&mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_ambient_agent_count(&mut ctx.store)
            .unwrap_or(0)
    })
    .unwrap_or(0)
    .max(0);
    for i in 0..ambient {
        let (x, y, z, kind) = with_mod(&mod_runtime, |ctx| {
            ctx.bindings
                .hanga_engine_gameplay()
                .call_ambient_agent_spawn(&mut ctx.store, i)
                .unwrap_or((0, 2, 0, 2))
        })
        .unwrap_or((0, 2, 0, 2));
        spawn_agent(
            &mut commands,
            &mut meshes,
            &mut materials,
            Vec3::new(x as f32, y as f32, z as f32),
            kind,
        );
    }
}

fn spawn_agent(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    pos: Vec3,
    ai_type: i32,
) {
    let color = match ai_type {
        1 => Color::srgb(0.1, 0.2, 0.9),
        2 => Color::srgb(0.2, 0.7, 0.3),
        _ => Color::srgb(0.5, 0.5, 0.5),
    };
    commands.spawn((
        Mesh3d(meshes.add(Capsule3d::new(0.4, 1.0))),
        MeshMaterial3d(materials.add(color)),
        Transform::from_translation(pos),
        RigidBody::Dynamic,
        Collider::capsule(0.4, 1.0),
        LockedAxes::new().lock_rotation_x().lock_rotation_z(),
        LinearVelocity::default(),
        AgentAi(ai_type as u32),
    ));
}

fn voxel_type_of(voxel: WorldVoxel<u8>) -> Option<i32> {
    match voxel {
        WorldVoxel::Solid(t) => Some(t as i32),
        _ => None,
    }
}

fn spawn_debris(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    pos: IVec3,
    velocity: Vec3,
    color: Color,
) {
    let target = Vec3::new(pos.x as f32, pos.y as f32, pos.z as f32);
    commands.spawn((
        Mesh3d(meshes.add(Cuboid::from_size(Vec3::splat(1.0)))),
        MeshMaterial3d(materials.add(color)),
        Transform::from_translation(target),
        RigidBody::Dynamic,
        Collider::cuboid(1.0, 1.0, 1.0),
        LinearVelocity(velocity),
    ));
}

/// Teardown: unset a voxel and let the mod decide debris + collapse of unsupported neighbors.
fn teardown_fracture(
    commands: &mut Commands,
    voxel_world: &mut VoxelWorld<DefaultWorld>,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    origin: IVec3,
    outward: Vec3,
    action_type: i32,
    mod_runtime: &ModRuntime,
) {
    let Some(origin_type) = voxel_type_of(voxel_world.get_voxel(origin)) else {
        return;
    };
    let can = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_can_fracture(&mut ctx.store, origin_type)
            .unwrap_or(0)
    })
    .unwrap_or(0);
    let impulse = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_debris_impulse(&mut ctx.store, action_type)
            .unwrap_or(5.0)
    })
    .unwrap_or(5.0);
    let spread = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_fracture_spread(&mut ctx.store, origin_type)
            .unwrap_or(0)
    })
    .unwrap_or(0);

    voxel_world.set_voxel(origin, WorldVoxel::Unset);
    if can > 0 {
        spawn_debris(
            commands,
            meshes,
            materials,
            origin,
            outward * impulse,
            Color::srgb(0.5, 0.5, 0.5),
        );
    }

    let max_hops = (spread.max(1) as u32).saturating_mul(4).saturating_add(4).min(32);
    let mut collapse = Vec::new();
    for (dx, dy, dz) in fracture_offsets(spread) {
        let npos = origin + IVec3::new(dx, dy, dz);
        let Some(ntype) = voxel_type_of(voxel_world.get_voxel(npos)) else {
            continue;
        };
        let ncan = with_mod(mod_runtime, |ctx| {
            ctx.bindings
                .hanga_engine_gameplay()
                .call_can_fracture(&mut ctx.store, ntype)
                .unwrap_or(0)
        })
        .unwrap_or(0);
        if ncan <= 0 {
            continue;
        }
        let below_solid = voxel_type_of(voxel_world.get_voxel(npos - IVec3::Y)).is_some();
        if voxel_has_support(npos.y, below_solid) {
            continue;
        }
        let grounded = is_connected_to_ground((npos.x, npos.y, npos.z), max_hops, |x, y, z| {
            voxel_type_of(voxel_world.get_voxel(IVec3::new(x, y, z))).is_some()
        });
        if grounded {
            continue;
        }
        collapse.push((npos, dx, dy, dz));
    }
    for (npos, dx, dy, dz) in collapse {
        voxel_world.set_voxel(npos, WorldVoxel::Unset);
        let n_out = Vec3::new(dx as f32, dy as f32 + 1.0, dz as f32).normalize_or_zero() * impulse;
        spawn_debris(
            commands,
            meshes,
            materials,
            npos,
            n_out,
            Color::srgb(0.6, 0.45, 0.3),
        );
    }
}

fn apply_mod_action(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    mod_runtime: &ModRuntime,
    action_type: i32,
    extra: i32,
    mod_state: &mut ModState,
    wallet: &mut ModWallet,
    spawn_hint: Vec3,
) {
    if let Some((new_state, ai_type, new_wallet)) = with_mod(mod_runtime, |ctx| {
        let g = ctx.bindings.hanga_engine_gameplay();
        let new_state = g
            .call_mod_evaluate_action(&mut ctx.store, action_type, mod_state.0 as i32)
            .ok()?;
        let ai_type = g
            .call_mod_should_spawn_agent(
                &mut ctx.store,
                action_type,
                mod_state.0 as i32,
                new_state,
            )
            .unwrap_or(0);
        let new_wallet = g
            .call_mod_wallet_after(&mut ctx.store, action_type, wallet.0, extra)
            .unwrap_or(wallet.0);
        Some((new_state, ai_type, new_wallet))
    })
    .flatten()
    {
        let old_state = mod_state.0;
        mod_state.0 = clamp_mod_state(new_state, 0, 5) as u32;
        wallet.0 = clamp_wallet(new_wallet);
        info!(
            "WASM Mod evaluated action {}! State {} -> {}, wallet {}",
            action_type, old_state, mod_state.0, wallet.0
        );
        if ai_type > 0 {
            let spawn_pos = spawn_hint + Vec3::new(5.0, 2.0, 5.0);
            spawn_agent(commands, meshes, materials, spawn_pos, ai_type);
            info!("WASM Mod requested AgentAi type {} at {:?}", ai_type, spawn_pos);
        }
    }
}

fn action_range(mod_runtime: &ModRuntime, action_type: i32, fallback: f32) -> f32 {
    with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_mod_get_action_range(&mut ctx.store, action_type)
            .unwrap_or(fallback)
    })
    .unwrap_or(fallback)
}

/// The Anti-Cheat P2P Judge: Intercepts all optimistic actions and verifies them
fn validate_incoming_actions(
    mut commands: Commands,
    mut events: MessageReader<ProposedAction>,
    mut player_query: Query<(&Transform, &mut ModState, &mut ModWallet, &mut ModContract), With<Player>>,
    vehicles: Query<&Transform, (With<Vehicle>, Without<Player>)>,
    mut voxel_world: VoxelWorld<DefaultWorld>,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    mut trust_ledger: ResMut<TrustLedger>,
    mut offer: ResMut<ModOffer>,
    mod_runtime: Res<ModRuntime>,
) {
    for action in events.read() {
        match action {
            &ProposedAction::BreakBlock { player_entity, voxel_pos, fingerprint } => {
                if !verify_action_signature(1, voxel_pos.x, voxel_pos.y, voxel_pos.z, 0, fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    warn!("FRAUD DETECTED: BreakBlock signature mismatch");
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, _)) = player_query.get_mut(player_entity) else {
                    trust_ledger.penalize(player_entity, 1.0);
                    warn!("FRAUD DETECTED: Action received for non-existent Player entity!");
                    continue;
                };
                let player_pos = transform.translation;
                let target_pos = Vec3::new(voxel_pos.x as f32, voxel_pos.y as f32, voxel_pos.z as f32);
                let range = action_range(&mod_runtime, 1, 10.0);
                let distance = player_pos.distance(target_pos);
                if !is_action_physically_possible(
                    player_pos.x, player_pos.y, player_pos.z,
                    target_pos.x, target_pos.y, target_pos.z,
                    range,
                ) {
                    trust_ledger.penalize(player_entity, 0.2);
                    warn!(
                        "FRAUD DETECTED: Player {:?} tried to break a block {} meters away (max {}m)! Action Rejected.",
                        player_entity, distance, range
                    );
                    continue;
                }

                info!(
                    "Action Verified fingerprint={fingerprint:#x}! Fracturing block at {:?}",
                    voxel_pos
                );
                let outward = Vec3::new(
                    (player_pos.x - target_pos.x) * -0.4,
                    1.0,
                    (player_pos.z - target_pos.z) * -0.4,
                );
                teardown_fracture(
                    &mut commands,
                    &mut voxel_world,
                    &mut meshes,
                    &mut materials,
                    voxel_pos,
                    outward,
                    1,
                    &mod_runtime,
                );
                apply_mod_action(
                    &mut commands,
                    &mut meshes,
                    &mut materials,
                    &mod_runtime,
                    1,
                    0,
                    &mut mod_state,
                    &mut wallet,
                    target_pos,
                );
            }
            &ProposedAction::Explosion { player_entity, center_pos, radius, fingerprint } => {
                if !verify_action_signature(4, center_pos.x, center_pos.y, center_pos.z, radius as i32, fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, _)) = player_query.get_mut(player_entity) else {
                    continue;
                };
                let player_pos = transform.translation;
                let target_pos = Vec3::new(center_pos.x as f32, center_pos.y as f32, center_pos.z as f32);
                let range = action_range(&mod_runtime, 4, 30.0);
                if !is_action_physically_possible(
                    player_pos.x, player_pos.y, player_pos.z,
                    target_pos.x, target_pos.y, target_pos.z,
                    range,
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
                                teardown_fracture(
                                    &mut commands,
                                    &mut voxel_world,
                                    &mut meshes,
                                    &mut materials,
                                    center_pos + offset,
                                    offset.as_vec3().normalize_or_zero(),
                                    4,
                                    &mod_runtime,
                                );
                            }
                        }
                    }
                }
                apply_mod_action(
                    &mut commands,
                    &mut meshes,
                    &mut materials,
                    &mod_runtime,
                    4,
                    0,
                    &mut mod_state,
                    &mut wallet,
                    target_pos,
                );
            }
            &ProposedAction::PlaceBlock { player_entity, voxel_pos, voxel_type, fingerprint } => {
                if !verify_action_signature(2, voxel_pos.x, voxel_pos.y, voxel_pos.z, voxel_type as i32, fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, _)) = player_query.get_mut(player_entity) else {
                    trust_ledger.penalize(player_entity, 1.0);
                    warn!("FRAUD DETECTED: Action received for non-existent Player entity!");
                    continue;
                };
                let player_pos = transform.translation;
                let target_pos = Vec3::new(voxel_pos.x as f32, voxel_pos.y as f32, voxel_pos.z as f32);
                let range = action_range(&mod_runtime, 2, 10.0);
                let distance = player_pos.distance(target_pos);
                if !is_action_physically_possible(
                    player_pos.x, player_pos.y, player_pos.z,
                    target_pos.x, target_pos.y, target_pos.z,
                    range,
                ) {
                    trust_ledger.penalize(player_entity, 0.2);
                    warn!(
                        "FRAUD DETECTED: Player {:?} tried to place a block {} meters away (max {}m)! Action Rejected.",
                        player_entity, distance, range
                    );
                    continue;
                }

                info!("Action Verified! Placing block at {:?}", voxel_pos);
                voxel_world.set_voxel(voxel_pos, WorldVoxel::Solid(clamp_voxel_type(voxel_type as i32)));
                apply_mod_action(
                    &mut commands,
                    &mut meshes,
                    &mut materials,
                    &mod_runtime,
                    2,
                    0,
                    &mut mod_state,
                    &mut wallet,
                    target_pos,
                );
            }
            &ProposedAction::EnterVehicle { player_entity, vehicle_entity, fingerprint } => {
                let bits = vehicle_entity.to_bits() as i32;
                if !verify_action_signature(3, bits, 0, 0, 0, fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, _)) = player_query.get_mut(player_entity) else {
                    continue;
                };
                let Ok(v_transform) = vehicles.get(vehicle_entity) else {
                    trust_ledger.penalize(player_entity, 0.5);
                    warn!("FRAUD DETECTED: EnterVehicle for missing vehicle {:?}", vehicle_entity);
                    continue;
                };
                let range = action_range(&mod_runtime, 3, 5.0);
                let player_pos = transform.translation;
                let v_pos = v_transform.translation;
                if !is_action_physically_possible(
                    player_pos.x, player_pos.y, player_pos.z,
                    v_pos.x, v_pos.y, v_pos.z,
                    range,
                ) {
                    trust_ledger.penalize(player_entity, 0.2);
                    continue;
                }
                commands.entity(player_entity).insert(InVehicle(vehicle_entity));
                info!("Player {:?} entered vehicle {:?}", player_entity, vehicle_entity);
                apply_mod_action(
                    &mut commands,
                    &mut meshes,
                    &mut materials,
                    &mod_runtime,
                    3,
                    0,
                    &mut mod_state,
                    &mut wallet,
                    player_pos,
                );
            }
            &ProposedAction::Verb { player_entity, verb, extra, fingerprint } => {
                if !verify_action_signature(verb as u8, extra, 0, 0, 0, fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    warn!("FRAUD DETECTED: Verb signature mismatch");
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, mut contract)) =
                    player_query.get_mut(player_entity)
                else {
                    continue;
                };
                let (kind, danger, payout) = if verb == 5 {
                    (offer.kind, offer.danger, offer.payout)
                } else {
                    (contract.kind, contract.danger, contract.payout)
                };
                let allowed = with_mod(&mod_runtime, |ctx| {
                    ctx.bindings
                        .hanga_engine_gameplay()
                        .call_mod_can_complete(
                            &mut ctx.store,
                            verb,
                            mod_state.0 as i32,
                            kind,
                            danger,
                        )
                        .unwrap_or(0)
                })
                .unwrap_or(0);
                if allowed <= 0 {
                    info!("Mod refused verb {verb} (state {}, kind {kind}, danger {danger})", mod_state.0);
                    continue;
                }
                let wallet_extra = if verb == 6 { payout } else { extra };
                let hint = transform.translation;
                apply_mod_action(
                    &mut commands,
                    &mut meshes,
                    &mut materials,
                    &mod_runtime,
                    verb,
                    wallet_extra,
                    &mut mod_state,
                    &mut wallet,
                    hint,
                );
                match verb {
                    5 if contract_is_offered(offer.kind) => {
                        *contract = ModContract {
                            kind: offer.kind,
                            payout: offer.payout,
                            danger: offer.danger,
                        };
                        *offer = ModOffer::default();
                        info!("Player accepted contract kind {}", contract.kind);
                    }
                    6 => {
                        info!("Player completed contract kind {}", contract.kind);
                        *contract = ModContract::default();
                    }
                    7 => info!("Player fenced loot, wallet {}", wallet.0),
                    _ => {}
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
        if let Some((v_vel, v_ang, v_pos)) = target_vehicle {
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

            events.write(signed_break(player_entity, voxel_pos));
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

            events.write(signed_explosion(player_entity, voxel_pos, 4.0));
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

// Minecraft/Luanti voxels: bevy_voxel_world + WASM query_voxel
// Teardown debris: avian3d + WASM can_fracture / fracture_spread

/// Engine-side city simulation (physics + AI ticks). Gameplay numbers come from the mod.
pub struct CitySimPlugin;
impl Plugin for CitySimPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(
            Update,
            (
                agent_ai_tick,
                wanted_decay,
                vehicle_collision_damage,
                vehicle_traffic_system,
            )
                .chain()
                .after(validate_incoming_actions),
        );
    }
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
                        events.write(signed_break(player_entity, voxel_pos));
                        break;
                    }
                }
            }
        }
    }
}

fn path_blocked(transform: &Transform, voxel_world: &VoxelWorld<DefaultWorld>) -> bool {
    let fwd = transform.forward();
    for i in 2..=5 {
        let check = transform.translation + *fwd * (i as f32);
        let voxel_pos = IVec3::new(
            check.x.round() as i32,
            check.y.round() as i32,
            check.z.round() as i32,
        );
        if voxel_type_of(voxel_world.get_voxel(voxel_pos)).is_some() {
            return true;
        }
    }
    false
}

fn vehicle_traffic_system(
    mut vehicles: Query<(&Transform, &mut LinearVelocity), With<VehicleAi>>,
    voxel_world: VoxelWorld<DefaultWorld>,
    mod_runtime: Res<ModRuntime>,
) {
    for (transform, mut velocity) in vehicles.iter_mut() {
        let fwd = transform.forward();
        let blocked = path_blocked(transform, &voxel_world);
        if let Some((vx, vz)) = with_mod(&mod_runtime, |ctx| {
            let g = ctx.bindings.hanga_engine_gameplay();
            let vx = g
                .call_compute_traffic_vx(&mut ctx.store, fwd.x, fwd.z, blocked)
                .unwrap_or(0.0);
            let vz = g
                .call_compute_traffic_vz(&mut ctx.store, fwd.x, fwd.z, blocked)
                .unwrap_or(0.0);
            (vx, vz)
        }) {
            velocity.x = vx;
            velocity.z = vz;
        } else if blocked {
            velocity.x = 0.0;
            velocity.z = 0.0;
        } else {
            velocity.x = fwd.x * 10.0;
            velocity.z = fwd.z * 10.0;
        }
    }
}

/// AI logic for all agents, entirely powered by the WASM mod!
fn agent_ai_tick(
    mut agents: Query<(&Transform, &mut LinearVelocity, &AgentAi)>,
    players: Query<&Transform, (With<Player>, Without<AgentAi>)>,
    mod_runtime: Res<ModRuntime>,
) {
    if let Some(player_transform) = players.iter().next() {
        let p_pos = player_transform.translation;
        
        // Grab the WASM Engine and Module from the globals
        for (agent_transform, mut velocity, agent) in agents.iter_mut() {
            let c_pos = agent_transform.translation;
            if let Some((vx, vz)) = with_mod(&mod_runtime, |ctx| {
                let g = ctx.bindings.hanga_engine_gameplay();
                let vx = g
                    .call_compute_agent_vx(
                        &mut ctx.store,
                        agent.0 as i32,
                        c_pos.x,
                        c_pos.z,
                        p_pos.x,
                        p_pos.z,
                    )
                    .ok()?;
                let vz = g
                    .call_compute_agent_vz(
                        &mut ctx.store,
                        agent.0 as i32,
                        c_pos.x,
                        c_pos.z,
                        p_pos.x,
                        p_pos.z,
                    )
                    .ok()?;
                Some((vx, vz))
            })
            .flatten()
            {
                velocity.x = vx;
                velocity.z = vz;
            }
        }
    }
}

fn wanted_decay(
    time: Res<Time>,
    mut timer: Local<f32>,
    mut players: Query<&mut ModState, With<Player>>,
    agents: Query<(Entity, &AgentAi)>,
    mut commands: Commands,
    mod_runtime: Res<ModRuntime>,
) {
    *timer += time.delta_secs();
    if *timer < 8.0 {
        return;
    }
    let dt_ms = (*timer * 1000.0) as i32;
    *timer = 0.0;
    let mut wanted = 0i32;
    for mut state in players.iter_mut() {
        if let Some(new_state) = with_mod(&mod_runtime, |ctx| {
            ctx.bindings
                .hanga_engine_gameplay()
                .call_mod_tick(&mut ctx.store, state.0 as i32, dt_ms)
                .ok()
        })
        .flatten()
        {
            let clamped = clamp_mod_state(new_state, 0, 5) as u32;
            if clamped != state.0 {
                info!("Mod tick: state {} -> {}", state.0, clamped);
            }
            state.0 = clamped;
            wanted = state.0 as i32;
        }
    }
    for (entity, agent) in agents.iter() {
        let drop = with_mod(&mod_runtime, |ctx| {
            ctx.bindings
                .hanga_engine_gameplay()
                .call_should_despawn_agent(&mut ctx.store, agent.0 as i32, wanted)
                .unwrap_or(0)
        })
        .unwrap_or(0);
        if drop > 0 {
            commands.entity(entity).despawn();
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
        let _ = futures::executor::block_on(message_loop);
    });
    
    commands.insert_resource(P2pSocket(socket));
}

fn handle_p2p_receive(
    socket: Option<ResMut<P2pSocket>>,
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
        for (_peer_id, packet) in socket.0.channel_mut(0).receive() {
            if let Ok(action) = bincode::deserialize::<ProposedAction>(&packet) {
                // Write it to ECS so validate_incoming_actions processes it!
                event_writer.write(action);
            }
        }
    }
}

fn handle_p2p_broadcast(
    socket: Option<ResMut<P2pSocket>>,
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
                ProposedAction::Verb { player_entity, .. } => Some(*player_entity) == local_player,
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

// --- Dynamic AI ---
pub struct AiStorytellerPlugin;
impl Plugin for AiStorytellerPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Update, update_storyteller.after(wanted_decay));
    }
}
fn update_storyteller(
    time: Res<Time>,
    mut timer: Local<f32>,
    mod_runtime: Res<ModRuntime>,
    mut offer: ResMut<ModOffer>,
    locale: Res<UiLocale>,
    players: Query<&ModState, With<Player>>,
) {
    *timer += time.delta_secs();
    if *timer < 10.0 {
        return;
    }
    *timer = 0.0;
    let player_state = players.iter().next().map(|s| s.0 as i32).unwrap_or(0);
    let lang = locale.0.code();
    if let Some((event_id, label)) = with_mod(&mod_runtime, |ctx| {
        let g = ctx.bindings.hanga_engine_gameplay();
        let player_level = g.call_mod_get_storyteller_level(&mut ctx.store).unwrap_or(0);
        let event_id = g.call_generate_story_event(&mut ctx.store, player_level).ok()?;
        let label = g
            .call_event_label(&mut ctx.store, event_id, lang)
            .unwrap_or_else(|_| "event".into());
        Some((event_id, label))
    })
    .flatten()
    {
        info!("STORYTELLER (WASM): {label} (id {event_id})");
    }
    if !contract_is_offered(offer.kind) {
        if let Some((kind, payout, danger)) = with_mod(&mod_runtime, |ctx| {
            ctx.bindings
                .hanga_engine_gameplay()
                .call_mod_offer_contract(&mut ctx.store, player_state)
                .ok()
        })
        .flatten()
        {
            if contract_is_offered(kind) {
                *offer = ModOffer { kind, payout, danger };
                info!("STORYTELLER (WASM): offer kind {kind} payout {payout} danger {danger}");
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
fn update_macro_economy(time: Res<Time>, mut timer: Local<f32>, mod_runtime: Res<ModRuntime>) {
    *timer += time.delta_secs();
    if *timer >= 5.0 {
        *timer = 0.0;
        if let Some((price, supply, demand)) = with_mod(&mod_runtime, |ctx| {
            let g = ctx.bindings.hanga_engine_gameplay();
            let packed = g.call_mod_get_economy_params(&mut ctx.store).unwrap_or(0);
            let (supply, demand) = unpack_economy_params(packed);
            let price = g
                .call_compute_economy_price(&mut ctx.store, 100, supply, demand)
                .ok()?;
            Some((price, supply, demand))
        })
        .flatten()
        {
            info!(
                "ECONOMY (WASM): Bread is now trading at ${} (Supply: {}, Demand: {})",
                price, supply, demand
            );
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

fn nearest_vehicle(
    player_pos: Vec3,
    vehicles: &Query<(Entity, &Transform), (With<Vehicle>, Without<Player>)>,
) -> Option<Entity> {
    vehicles
        .iter()
        .min_by(|a, b| {
            a.1.translation
                .distance(player_pos)
                .partial_cmp(&b.1.translation.distance(player_pos))
                .unwrap_or(std::cmp::Ordering::Equal)
        })
        .map(|(e, _)| e)
}

/// Polls the standard input channel non-blockingly and parses text commands
fn look_voxel_ahead(
    transform: &Transform,
    voxel_world: &VoxelWorld<DefaultWorld>,
    mod_runtime: &ModRuntime,
    locale: Locale,
) -> (IVec3, i32, String) {
    let forward_pos = transform.translation + (transform.forward() * 2.0);
    let voxel_pos = IVec3::new(
        forward_pos.x.round() as i32,
        forward_pos.y.round() as i32,
        forward_pos.z.round() as i32,
    );
    let voxel_type = voxel_type_of(voxel_world.get_voxel(voxel_pos)).unwrap_or(0);
    let raw = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_voxel_label(&mut ctx.store, voxel_type, locale.code())
            .unwrap_or_else(|_| "unknown".into())
    })
    .unwrap_or_else(|| "unknown".into());
    (voxel_pos, voxel_type, i18n::tr_label(locale, &raw))
}

fn mod_contract_name(mod_runtime: &ModRuntime, locale: Locale, kind: i32) -> String {
    if kind <= 0 {
        return i18n::t(locale, "job_none").to_string();
    }
    with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_contract_label(&mut ctx.store, kind, locale.code())
            .unwrap_or_default()
    })
    .filter(|name| !name.is_empty())
    .unwrap_or_else(|| format!("#{kind}"))
}

fn job_status_line(
    locale: Locale,
    mod_runtime: &ModRuntime,
    state: &ModState,
    wallet: &ModWallet,
    contract: &ModContract,
    offer: &ModOffer,
) -> String {
    let job = if contract_is_offered(contract.kind) {
        let name = mod_contract_name(mod_runtime, locale, contract.kind);
        i18n::format_job_active(locale, &name, contract.payout, contract.danger)
    } else if contract_is_offered(offer.kind) {
        let name = mod_contract_name(mod_runtime, locale, offer.kind);
        i18n::format_job_offer(locale, &name, offer.payout, offer.danger)
    } else {
        i18n::t(locale, "job_none").to_string()
    };
    i18n::format_status(locale, state.0, wallet.0, &job)
}

fn say(locale: Locale, body: &str) {
    println!("{}", i18n::say(locale, body));
}

fn read_terminal_input(
    receiver: Res<StdinReceiver>,
    mut query: Query<(Entity, &Transform, &mut LinearVelocity, &ModState, &ModWallet, &ModContract), With<Player>>,
    vehicles: Query<(Entity, &Transform), (With<Vehicle>, Without<Player>)>,
    voxel_world: VoxelWorld<DefaultWorld>,
    mod_runtime: Res<ModRuntime>,
    offer: Res<ModOffer>,
    mut locale: ResMut<UiLocale>,
    mut events: MessageWriter<ProposedAction>,
) {
    if let Ok(rx) = receiver.rx.lock() {
        while let Ok(line) = rx.try_recv() {
            match i18n::parse_text_command(&line) {
                TextCommand::MoveForward => {
                    if let Some((_, transform, mut velocity, _, _, _)) = query.iter_mut().next() {
                        let forward = transform.forward();
                        velocity.x = forward.x * 10.0;
                        velocity.z = forward.z * 10.0;
                        say(locale.0, i18n::t(locale.0, "moving"));
                    }
                }
                TextCommand::BreakBlock => {
                    if let Some((player_entity, transform, _, _, _, _)) = query.iter_mut().next() {
                        let forward_pos = transform.translation + (transform.forward() * 2.0);
                        let voxel_pos = IVec3::new(
                            forward_pos.x.round() as i32,
                            forward_pos.y.round() as i32,
                            forward_pos.z.round() as i32,
                        );
                        events.write(signed_break(player_entity, voxel_pos));
                        say(
                            locale.0,
                            &i18n::t(locale.0, "breaking").replace("{pos}", &format!("{voxel_pos:?}")),
                        );
                    }
                }
                TextCommand::PlaceBlock => {
                    if let Some((player_entity, transform, _, _, _, _)) = query.iter_mut().next() {
                        let forward_pos = transform.translation + (transform.forward() * 2.0);
                        let voxel_pos = IVec3::new(
                            forward_pos.x.round() as i32,
                            forward_pos.y.round() as i32,
                            forward_pos.z.round() as i32,
                        );
                        events.write(signed_place(player_entity, voxel_pos, 2));
                        say(
                            locale.0,
                            &i18n::t(locale.0, "placing").replace("{pos}", &format!("{voxel_pos:?}")),
                        );
                    }
                }
                TextCommand::EnterVehicle => {
                    if let Some((player_entity, transform, _, _, _, _)) = query.iter().next() {
                        if let Some(vehicle_entity) = nearest_vehicle(transform.translation, &vehicles) {
                            events.write(signed_enter(player_entity, vehicle_entity));
                            say(locale.0, i18n::t(locale.0, "entering"));
                        } else {
                            say(locale.0, i18n::t(locale.0, "no_vehicle"));
                        }
                    }
                }
                TextCommand::AcceptJob => {
                    if let Some((player_entity, _, _, _, _, _)) = query.iter().next() {
                        events.write(signed_verb(player_entity, 5, 0));
                        say(locale.0, i18n::t(locale.0, "accepting"));
                    }
                }
                TextCommand::CompleteJob => {
                    if let Some((player_entity, _, _, _, _, _)) = query.iter().next() {
                        events.write(signed_verb(player_entity, 6, 0));
                        say(locale.0, i18n::t(locale.0, "completing"));
                    }
                }
                TextCommand::Fence => {
                    if let Some((player_entity, _, _, _, _, _)) = query.iter().next() {
                        events.write(signed_verb(player_entity, 7, 0));
                        say(locale.0, i18n::t(locale.0, "fencing"));
                    }
                }
                TextCommand::Look => {
                    if let Some((_, transform, _, state, wallet, contract)) = query.iter().next() {
                        let (pos, _ty, label) =
                            look_voxel_ahead(transform, &voxel_world, &mod_runtime, locale.0);
                        let status = job_status_line(locale.0, &mod_runtime, state, wallet, contract, &offer);
                        say(
                            locale.0,
                            &i18n::format_look(locale.0, &status, &label, &format!("{pos:?}")),
                        );
                    }
                }
                TextCommand::SetLang(next) => {
                    locale.0 = next;
                    say(next, &i18n::format_lang_set(next));
                }
                TextCommand::Unknown => {
                    say(
                        locale.0,
                        &i18n::t(locale.0, "unknown").replace("{cmd}", line.trim()),
                    );
                }
            }
        }
    }
}

/// Polls standard input for JSON commands specifically for LLM Agents
fn read_agent_input(
    receiver: Res<StdinReceiver>,
    mut query: Query<(Entity, &Transform, &mut LinearVelocity, &ModState, &ModWallet, &ModContract, Option<&InVehicle>), With<Player>>,
    vehicles: Query<(Entity, &Transform), (With<Vehicle>, Without<Player>)>,
    voxel_world: VoxelWorld<DefaultWorld>,
    mod_runtime: Res<ModRuntime>,
    offer: Res<ModOffer>,
    locale: Res<UiLocale>,
    mut events: MessageWriter<ProposedAction>,
    trust_ledger: Res<TrustLedger>,
) {
    if let Ok(rx) = receiver.rx.lock() {
        while let Ok(line) = rx.try_recv() {
            if let Ok(command) = serde_json::from_str::<AgentCommand>(&line) {
                match command {
                    AgentCommand::MoveForward => {
                        if let Some((_, transform, mut velocity, _, _, _, _)) = query.iter_mut().next() {
                            let forward = transform.forward();
                            velocity.x = forward.x * 10.0;
                            velocity.z = forward.z * 10.0;
                        }
                    }
                    AgentCommand::BreakBlock { pos } => {
                        if let Some((player_entity, _, _, _, _, _, _)) = query.iter_mut().next() {
                            events.write(signed_break(
                                player_entity,
                                IVec3::new(pos[0], pos[1], pos[2]),
                            ));
                        }
                    }
                    AgentCommand::PlaceBlock { pos, voxel_type } => {
                        if let Some((player_entity, _, _, _, _, _, _)) = query.iter_mut().next() {
                            events.write(signed_place(
                                player_entity,
                                IVec3::new(pos[0], pos[1], pos[2]),
                                voxel_type,
                            ));
                        }
                    }
                    AgentCommand::EnterVehicle => {
                        if let Some((player_entity, transform, _, _, _, _, _)) = query.iter_mut().next() {
                            if let Some(vehicle_entity) =
                                nearest_vehicle(transform.translation, &vehicles)
                            {
                                events.write(signed_enter(player_entity, vehicle_entity));
                            }
                        }
                    }
                    AgentCommand::AcceptJob => {
                        if let Some((player_entity, _, _, _, _, _, _)) = query.iter().next() {
                            events.write(signed_verb(player_entity, 5, 0));
                        }
                    }
                    AgentCommand::CompleteJob => {
                        if let Some((player_entity, _, _, _, _, _, _)) = query.iter().next() {
                            events.write(signed_verb(player_entity, 6, 0));
                        }
                    }
                    AgentCommand::Fence => {
                        if let Some((player_entity, _, _, _, _, _, _)) = query.iter().next() {
                            events.write(signed_verb(player_entity, 7, 0));
                        }
                    }
                    AgentCommand::Look => {
                        if let Some((entity, transform, _, state, wallet, contract, in_vehicle)) = query.iter_mut().next() {
                            let score = trust_ledger.peer_scores.get(&entity).copied().unwrap_or(100.0);
                            let (_pos, voxel_ahead, voxel_label) =
                                look_voxel_ahead(transform, &voxel_world, &mod_runtime, locale.0);
                            let obs = AgentObservation {
                                status: "ok".into(),
                                player_pos: [transform.translation.x, transform.translation.y, transform.translation.z],
                                trust_score: score,
                                wanted_level: state.0,
                                credits: wallet.0,
                                offer_kind: offer.kind,
                                contract_kind: contract.kind,
                                voxel_ahead,
                                voxel_label,
                                locale: locale.0.code().into(),
                                in_vehicle: in_vehicle.is_some(),
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
                    wanted_level: 0,
                    credits: 0,
                    offer_kind: 0,
                    contract_kind: 0,
                    voxel_ahead: 0,
                    voxel_label: String::new(),
                    locale: locale.0.code().into(),
                    in_vehicle: false,
                };
                if let Ok(json) = serde_json::to_string(&err) {
                    println!("{}", json);
                }
            }
        }
    }
}
