use bevy::input::mouse::AccumulatedMouseMotion;
use bevy::prelude::*;
use bevy::window::{CursorGrabMode, CursorOptions, PrimaryWindow};
use wasmtime::Store;
use wasmtime::component::Linker;
use bevy_voxel_world::prelude::*;
use avian3d::prelude::*;
use std::io::{self, BufRead};
use std::path::{Path, PathBuf};
use std::sync::{mpsc::{channel, Receiver}, Mutex};
use serde::{Deserialize, Serialize};
use matchbox_socket::WebRtcSocket;
use hanga::bindings::{
    self, BindingSet, ACTION_ACCEPT, ACTION_BACK, ACTION_BREAK, ACTION_COMPLETE, ACTION_CRAFT,
    ACTION_ENTER, ACTION_EXPLODE, ACTION_FENCE, ACTION_FORWARD, ACTION_JUMP, ACTION_LEFT,
    ACTION_MENU_CONTROLS, ACTION_MENU_LANG, ACTION_MENU_MULTI, ACTION_MENU_PLAY, ACTION_MENU_QUIT,
    ACTION_PAUSE, ACTION_PLACE, ACTION_RIGHT, ALL_ACTIONS,
};
use hanga::i18n::{self, Locale, TextCommand};
use hanga::{
    action_fingerprint, apply_mouse_look, catalog_index, catalog_name, clamp_hotbar_index,
    clamp_mod_state, clamp_voxel_type, clamp_wallet, contract_is_offered, fracture_offsets,
    inventory_add, inventory_craft_pair, inventory_selected, inventory_take,
    is_action_physically_possible, is_connected_to_ground, parse_name_catalog, parse_p2p_url,
    should_skip_menu, unpack_economy_params, verify_action_signature, voxel_has_support,
    DEFAULT_P2P_URL, INVENTORY_SLOTS, LOOK_SENSITIVITY,
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

    fn texture_index_mapper(&self) -> TextureIndexMapperFn<Self::MaterialIndex> {
        std::sync::Arc::new(|mat| match mat {
            1 => [1, 1, 1],
            2 => [2, 2, 2],
            3 => [3, 3, 3],
            4 => [4, 4, 4],
            5 => [5, 5, 5],
            6 => [6, 6, 6],
            7 => [7, 7, 7],
            _ => [0, 0, 0],
        })
    }

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

#[derive(States, Clone, Copy, PartialEq, Eq, Hash, Debug, Default)]
enum GameMode {
    #[default]
    Menu,
    Controls,
    Playing,
}

#[derive(Resource, Default)]
struct P2pConfig {
    url: Option<String>,
}

#[derive(Resource)]
struct P2pWatch(Mutex<Receiver<String>>);

#[derive(Resource)]
struct P2pDead;

#[derive(Component)]
struct MenuRoot;

#[derive(Component, Clone, Copy)]
enum MenuAction {
    Play,
    Multiplayer,
    Lang,
    Controls,
    Quit,
}

#[derive(Component)]
struct MenuLabel(&'static str);

#[derive(Resource, Clone)]
struct KeyBindings(BindingSet);

#[derive(Resource, Clone)]
struct BindingsPath(PathBuf);

#[derive(Resource, Default)]
struct BindCapture {
    action: Option<String>,
    ignore_frames: u8,
}

#[derive(Component)]
struct ControlsRoot;

#[derive(Component, Clone, Copy)]
struct BindRow(&'static str);

#[derive(Component)]
struct BindRowText(&'static str);

#[derive(Component)]
struct ControlsHintText;

#[derive(Component)]
struct ControlsBack;

#[derive(Component)]
struct HudRoot;

#[derive(Component)]
struct HudStatus;

#[derive(Component)]
struct HudHotbar;

#[derive(Component)]
struct HudHint;

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
    let p2p_url = parse_p2p_url(&args);
    let skip_menu = should_skip_menu(&args);
    let bindings_path = resolve_bindings_path(&args);
    let bindings = load_bindings(&bindings_path);
    info!("Key bindings {}", bindings_path.display());

    let mut app = App::new();

    let (tx, rx) = channel();

    let window_plugin = if is_headless {
        WindowPlugin {
            primary_window: None,
            ..default()
        }
    } else {
        WindowPlugin {
            primary_window: Some(Window {
                title: "Hanga".into(),
                ..default()
            }),
            ..default()
        }
    };

    if is_headless {
        info!("Starting Hanga in HEADLESS NODE mode (Persistent Server)");
        app.add_plugins(DefaultPlugins.set(window_plugin));
    } else if is_text_client {
        info!("Starting Hanga in TEXT CLIENT mode (Screen-reader Accessible)");
        app.add_plugins(DefaultPlugins.set(window_plugin));
        app.insert_resource(StdinReceiver { rx: Mutex::new(rx) });
        app.add_systems(Update, read_terminal_input.after(validate_incoming_actions));

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
        app.add_plugins(DefaultPlugins.set(window_plugin));
        app.insert_resource(StdinReceiver { rx: Mutex::new(rx) });
        app.add_systems(Update, read_agent_input.after(validate_incoming_actions));

        std::thread::spawn(move || {
            let stdin = io::stdin();
            for line in stdin.lock().lines() {
                if let Ok(line) = line {
                    let _ = tx.send(line);
                }
            }
        });
    } else {
        app.add_plugins(DefaultPlugins.set(window_plugin));
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

    app.init_state::<GameMode>();
    if skip_menu {
        app.insert_state(GameMode::Playing);
    }

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
        .init_resource::<VoxelCatalog>()
        .insert_resource(CheatMode(is_cheater))
        .insert_resource(UiLocale(locale))
        .insert_resource(P2pConfig { url: p2p_url })
        .insert_resource(KeyBindings(bindings))
        .insert_resource(BindingsPath(bindings_path))
        .init_resource::<BindCapture>()
        .add_systems(Startup, setup)
        .add_systems(OnEnter(GameMode::Menu), spawn_main_menu)
        .add_systems(OnExit(GameMode::Menu), despawn_main_menu)
        .add_systems(OnEnter(GameMode::Controls), spawn_controls_menu)
        .add_systems(OnExit(GameMode::Controls), despawn_controls_menu)
        .add_systems(OnEnter(GameMode::Playing), (spawn_hud, grab_cursor))
        .add_systems(OnExit(GameMode::Playing), (despawn_hud, release_cursor))
        .add_systems(
            Update,
            (menu_keyboard, menu_buttons, refresh_menu_labels).run_if(in_state(GameMode::Menu)),
        )
        .add_systems(
            Update,
            (
                capture_rebind,
                controls_buttons,
                controls_keyboard,
                refresh_controls_labels,
            )
                .run_if(in_state(GameMode::Controls)),
        )
        .add_systems(
            Update,
            (pause_to_menu, select_hotbar, player_look, update_hud)
                .run_if(in_state(GameMode::Playing)),
        )
        .add_message::<ProposedAction>()
        .add_systems(
            Update,
            (
                generate_voxel_colliders,
                player_movement.run_if(in_state(GameMode::Playing)),
                player_interaction.run_if(in_state(GameMode::Playing)),
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
    PlaceBlock { pos: [i32; 3], voxel: String },
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
    offer_kind: String,
    contract_kind: String,
    voxel_ahead: String,
    voxel_label: String,
    locale: String,
    in_vehicle: bool,
    held_item: String,
    hotbar_selected: u32,
}

#[derive(Component)]
pub struct Player;

#[derive(Component)]
pub struct ModState(pub u32);

/// Opaque integer owned by the loaded mod (credits in Urban Chaos).
#[derive(Component, Default)]
pub struct ModWallet(pub i32);

/// Active contract tuple from the mod: kind, payout, danger. empty kind = none.
#[derive(Component, Default, Clone)]
pub struct ModContract {
    pub kind: String,
    pub payout: i32,
    pub danger: i32,
}

/// Generic hotbar. Item names are opaque to the engine; the mod owns them.
#[derive(Component, Clone)]
pub struct ModInventory {
    pub items: [String; INVENTORY_SLOTS],
    pub counts: [u32; INVENTORY_SLOTS],
    pub selected: usize,
}

impl Default for ModInventory {
    fn default() -> Self {
        Self {
            items: std::array::from_fn(|_| String::new()),
            counts: [0; INVENTORY_SLOTS],
            selected: 0,
        }
    }
}

/// English voxel names in meshing-index order, loaded from the mod catalog.
#[derive(Resource, Clone, Default)]
pub struct VoxelCatalog(pub Vec<String>);

#[derive(Component, Default)]
struct LookYaw(f32);

#[derive(Component, Default)]
struct LookPitch(f32);

/// Latest storyteller offer. Engine does not interpret kind.
#[derive(Resource, Default, Clone)]
pub struct ModOffer {
    pub kind: String,
    pub payout: i32,
    pub danger: i32,
}

#[derive(Component)]
pub struct AgentAi(pub String);

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
        voxel: String,
        fingerprint: u64,
    },
    EnterVehicle {
        player_entity: Entity,
        vehicle_entity: Entity,
        fingerprint: u64,
    },
    /// Generic mod verb (accept_contract, complete_contract, fence, craft).
    Verb {
        player_entity: Entity,
        verb: String,
        extra: String,
        fingerprint: u64,
    },
}

fn signed_break(player_entity: Entity, voxel_pos: IVec3) -> ProposedAction {
    ProposedAction::BreakBlock {
        player_entity,
        voxel_pos,
        fingerprint: action_fingerprint(ACTION_BREAK, voxel_pos.x, voxel_pos.y, voxel_pos.z, ""),
    }
}

fn signed_place(player_entity: Entity, voxel_pos: IVec3, voxel: &str) -> ProposedAction {
    ProposedAction::PlaceBlock {
        player_entity,
        voxel_pos,
        voxel: voxel.to_string(),
        fingerprint: action_fingerprint(ACTION_PLACE, voxel_pos.x, voxel_pos.y, voxel_pos.z, voxel),
    }
}

fn signed_enter(player_entity: Entity, vehicle_entity: Entity) -> ProposedAction {
    let bits = vehicle_entity.to_bits() as i32;
    ProposedAction::EnterVehicle {
        player_entity,
        vehicle_entity,
        fingerprint: action_fingerprint(ACTION_ENTER, bits, 0, 0, ""),
    }
}

fn signed_explosion(player_entity: Entity, center_pos: IVec3, radius: f32) -> ProposedAction {
    let extra = (radius as i32).to_string();
    ProposedAction::Explosion {
        player_entity,
        center_pos,
        radius,
        fingerprint: action_fingerprint(
            ACTION_EXPLODE,
            center_pos.x,
            center_pos.y,
            center_pos.z,
            &extra,
        ),
    }
}

fn signed_verb(player_entity: Entity, verb: &str, extra: &str) -> ProposedAction {
    ProposedAction::Verb {
        player_entity,
        verb: verb.to_string(),
        extra: extra.to_string(),
        fingerprint: action_fingerprint(verb, 0, 0, 0, extra),
    }
}

fn aim_from(
    cameras: &Query<&GlobalTransform, With<VoxelWorldCamera<DefaultWorld>>>,
    fallback: &Transform,
) -> (Vec3, Dir3) {
    if let Some(tf) = cameras.iter().next() {
        (tf.translation(), tf.forward())
    } else {
        (fallback.translation, fallback.forward())
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

fn resolve_bindings_path(args: &[String]) -> PathBuf {
    if let Some(path) = bindings::parse_bindings_path(args) {
        return PathBuf::from(path);
    }
    if let Ok(path) = std::env::var("HANGA_BINDINGS") {
        return PathBuf::from(path);
    }
    let base = std::env::var("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .or_else(|_| std::env::var("HOME").map(|home| PathBuf::from(home).join(".config")))
        .unwrap_or_else(|_| PathBuf::from("."));
    base.join("hanga").join("bindings.conf")
}

fn load_bindings(path: &Path) -> BindingSet {
    let defaults = BindingSet::defaults();
    match std::fs::read_to_string(path) {
        Ok(text) => defaults.overlay(&bindings::parse_bindings(&text)),
        Err(_) => {
            persist_bindings(path, &defaults);
            defaults
        }
    }
}

fn persist_bindings(path: &Path, set: &BindingSet) {
    if let Some(dir) = path.parent() {
        let _ = std::fs::create_dir_all(dir);
    }
    if let Err(err) = std::fs::write(path, bindings::format_bindings(set)) {
        warn!("Could not save bindings to {}: {err}", path.display());
    }
}

fn mouse_bind_name(button: MouseButton) -> String {
    match button {
        MouseButton::Left => "MouseLeft".into(),
        MouseButton::Right => "MouseRight".into(),
        MouseButton::Middle => "MouseMiddle".into(),
        MouseButton::Back => "MouseBack".into(),
        MouseButton::Forward => "MouseForward".into(),
        MouseButton::Other(n) => format!("MouseOther{n}"),
    }
}

fn mouse_from_name(name: &str) -> Option<MouseButton> {
    match name {
        "MouseLeft" => Some(MouseButton::Left),
        "MouseRight" => Some(MouseButton::Right),
        "MouseMiddle" => Some(MouseButton::Middle),
        "MouseBack" => Some(MouseButton::Back),
        "MouseForward" => Some(MouseButton::Forward),
        other => other
            .strip_prefix("MouseOther")
            .and_then(|n| n.parse().ok())
            .map(MouseButton::Other),
    }
}

fn bind_active(
    bind: &str,
    keys: &ButtonInput<KeyCode>,
    mouse: &ButtonInput<MouseButton>,
    just: bool,
) -> bool {
    let Some(name) = bindings::canonical_bind(bind) else {
        return false;
    };
    if let Some(button) = mouse_from_name(&name) {
        return if just {
            mouse.just_pressed(button)
        } else {
            mouse.pressed(button)
        };
    }
    if just {
        keys.get_just_pressed()
            .any(|key| format!("{key:?}") == name)
    } else {
        keys.get_pressed().any(|key| format!("{key:?}") == name)
    }
}

fn action_pressed(
    keys: &ButtonInput<KeyCode>,
    mouse: &ButtonInput<MouseButton>,
    set: &BindingSet,
    action: &str,
) -> bool {
    set.binds(action)
        .iter()
        .any(|bind| bind_active(bind, keys, mouse, false))
}

fn action_just_pressed(
    keys: &ButtonInput<KeyCode>,
    mouse: &ButtonInput<MouseButton>,
    set: &BindingSet,
    action: &str,
) -> bool {
    set.binds(action)
        .iter()
        .any(|bind| bind_active(bind, keys, mouse, true))
}

fn menu_caption(locale: Locale, set: &BindingSet, key: &str) -> String {
    let action = match key {
        "menu_play" => Some(ACTION_MENU_PLAY),
        "menu_multiplayer" => Some(ACTION_MENU_MULTI),
        "menu_lang" => Some(ACTION_MENU_LANG),
        "menu_controls" => Some(ACTION_MENU_CONTROLS),
        "menu_quit" => Some(ACTION_MENU_QUIT),
        _ => None,
    };
    match action {
        Some(action) => format!("{}  {}", set.display(action), i18n::t(locale, key)),
        None => i18n::t(locale, key).to_string(),
    }
}

fn bind_row_caption(locale: Locale, set: &BindingSet, action: &str) -> String {
    format!(
        "{}   {}",
        i18n::t(locale, &format!("bind_{action}")),
        set.display(action)
    )
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
    let catalog = load_voxel_catalog(&mod_runtime);
    if catalog.0.is_empty() {
        warn!("Mod voxel catalog is empty; place/loot will reject unknown names");
    } else {
        info!("Mod voxels: {}", catalog.0.join(", "));
    }
    commands.insert_resource(catalog);

    let (px, py, pz) = with_mod(&mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_player_spawn(&mut ctx.store)
            .unwrap_or((490, 50, 490))
    })
    .unwrap_or((490, 50, 490));
    let player_pos = Vec3::new(px as f32, py as f32, pz as f32);

    commands
        .spawn((
            Transform::from_translation(player_pos),
            Player,
            RigidBody::Dynamic,
            Collider::capsule(0.4, 1.0),
            LinearVelocity::default(),
            AngularVelocity::default(),
            LockedAxes::new().lock_rotation_x().lock_rotation_z(),
            ModState(0),
            ModWallet(0),
            ModContract::default(),
            ModInventory::default(),
            LookYaw(0.0),
        ))
        .with_children(|parent| {
            parent.spawn((
                Camera3d::default(),
                VoxelWorldCamera::<DefaultWorld>::default(),
                Transform::from_xyz(0.0, 0.55, 0.0),
                LookPitch(0.0),
            ));
        });

    commands.spawn((
        DirectionalLight {
            illuminance: 14_000.0,
            shadow_maps_enabled: false,
            ..default()
        },
        Transform::from_rotation(Quat::from_euler(EulerRot::XYZ, -1.05, 0.55, 0.0)),
    ));
    commands.spawn(AmbientLight {
        color: Color::srgb(0.62, 0.68, 0.78),
        brightness: 240.0,
        ..default()
    });

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
                .unwrap_or((0, 2, 0, "pedestrian".into()))
        })
        .unwrap_or((0, 2, 0, "pedestrian".into()));
        spawn_agent(
            &mut commands,
            &mut meshes,
            &mut materials,
            Vec3::new(x as f32, y as f32, z as f32),
            &kind,
        );
    }
}

fn load_voxel_catalog(mod_runtime: &ModRuntime) -> VoxelCatalog {
    let csv = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_voxel_catalog(&mut ctx.store)
            .unwrap_or_default()
    })
    .unwrap_or_default();
    VoxelCatalog(parse_name_catalog(&csv))
}

fn spawn_agent(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    pos: Vec3,
    kind: &str,
) {
    let color = match kind {
        "cop" => Color::srgb(0.1, 0.2, 0.9),
        "pedestrian" => Color::srgb(0.2, 0.7, 0.3),
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
        AgentAi(kind.to_string()),
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
    action: &str,
    catalog: &VoxelCatalog,
    mod_runtime: &ModRuntime,
) {
    let Some(origin_type) = voxel_type_of(voxel_world.get_voxel(origin)) else {
        return;
    };
    let origin_name = catalog_name(&catalog.0, origin_type)
        .unwrap_or("")
        .to_string();
    let can = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_can_fracture(&mut ctx.store, &origin_name)
            .unwrap_or(0)
    })
    .unwrap_or(0);
    let impulse = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_debris_impulse(&mut ctx.store, action)
            .unwrap_or(5.0)
    })
    .unwrap_or(5.0);
    let spread = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_fracture_spread(&mut ctx.store, &origin_name)
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
        let nname = catalog_name(&catalog.0, ntype).unwrap_or("").to_string();
        let ncan = with_mod(mod_runtime, |ctx| {
            ctx.bindings
                .hanga_engine_gameplay()
                .call_can_fracture(&mut ctx.store, &nname)
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
    action: &str,
    extra: i32,
    mod_state: &mut ModState,
    wallet: &mut ModWallet,
    spawn_hint: Vec3,
) {
    if let Some((new_state, agent, new_wallet)) = with_mod(mod_runtime, |ctx| {
        let g = ctx.bindings.hanga_engine_gameplay();
        let new_state = g
            .call_mod_evaluate_action(&mut ctx.store, action, mod_state.0 as i32)
            .ok()?;
        let agent = g
            .call_mod_should_spawn_agent(&mut ctx.store, action, mod_state.0 as i32, new_state)
            .unwrap_or_default();
        let new_wallet = g
            .call_mod_wallet_after(&mut ctx.store, action, wallet.0, extra)
            .unwrap_or(wallet.0);
        Some((new_state, agent, new_wallet))
    })
    .flatten()
    {
        let old_state = mod_state.0;
        mod_state.0 = clamp_mod_state(new_state, 0, 5) as u32;
        wallet.0 = clamp_wallet(new_wallet);
        info!(
            "WASM Mod evaluated action {action}! State {} -> {}, wallet {}",
            old_state, mod_state.0, wallet.0
        );
        if !agent.is_empty() {
            let spawn_pos = spawn_hint + Vec3::new(5.0, 2.0, 5.0);
            spawn_agent(commands, meshes, materials, spawn_pos, &agent);
            info!("WASM Mod requested AgentAi {agent} at {:?}", spawn_pos);
        }
    }
}

fn action_range(mod_runtime: &ModRuntime, action: &str, fallback: f32) -> f32 {
    with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_mod_get_action_range(&mut ctx.store, action)
            .unwrap_or(fallback)
    })
    .unwrap_or(fallback)
}

/// The Anti-Cheat P2P Judge: Intercepts all optimistic actions and verifies them
fn grant_loot(inv: &mut ModInventory, mod_runtime: &ModRuntime, voxel: &str) {
    let item = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_loot_item(&mut ctx.store, voxel)
            .unwrap_or_default()
    })
    .unwrap_or_default();
    if !item.is_empty() {
        let _ = inventory_add(&mut inv.items, &mut inv.counts, &item);
    }
}

fn consume_selected(inv: &mut ModInventory, voxel: &str) -> bool {
    let Some(held) = inventory_selected(&inv.items, &inv.counts, inv.selected) else {
        return false;
    };
    if held != voxel {
        return false;
    }
    inventory_take(&mut inv.items, &mut inv.counts, inv.selected).is_some()
}

fn validate_incoming_actions(
    mut commands: Commands,
    mut events: MessageReader<ProposedAction>,
    mut player_query: Query<
        (
            &Transform,
            &mut ModState,
            &mut ModWallet,
            &mut ModContract,
            &mut ModInventory,
        ),
        With<Player>,
    >,
    vehicles: Query<&Transform, (With<Vehicle>, Without<Player>)>,
    mut voxel_world: VoxelWorld<DefaultWorld>,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    mut trust_ledger: ResMut<TrustLedger>,
    mut offer: ResMut<ModOffer>,
    catalog: Res<VoxelCatalog>,
    mod_runtime: Res<ModRuntime>,
) {
    for action in events.read() {
        match action {
            ProposedAction::BreakBlock { player_entity, voxel_pos, fingerprint } => {
                let player_entity = *player_entity;
                let voxel_pos = *voxel_pos;
                let fingerprint = *fingerprint;
                if !verify_action_signature(ACTION_BREAK, voxel_pos.x, voxel_pos.y, voxel_pos.z, "", fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    warn!("FRAUD DETECTED: BreakBlock signature mismatch");
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, _, mut inventory)) =
                    player_query.get_mut(player_entity)
                else {
                    trust_ledger.penalize(player_entity, 1.0);
                    warn!("FRAUD DETECTED: Action received for non-existent Player entity!");
                    continue;
                };
                let player_pos = transform.translation;
                let target_pos = Vec3::new(voxel_pos.x as f32, voxel_pos.y as f32, voxel_pos.z as f32);
                let range = action_range(&mod_runtime, ACTION_BREAK, 10.0);
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
                if let Some(origin_type) = voxel_type_of(voxel_world.get_voxel(voxel_pos)) {
                    let name = catalog_name(&catalog.0, origin_type).unwrap_or("").to_string();
                    grant_loot(&mut inventory, &mod_runtime, &name);
                }
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
                    ACTION_BREAK,
                    &catalog,
                    &mod_runtime,
                );
                apply_mod_action(
                    &mut commands,
                    &mut meshes,
                    &mut materials,
                    &mod_runtime,
                    ACTION_BREAK,
                    0,
                    &mut mod_state,
                    &mut wallet,
                    target_pos,
                );
            }
            ProposedAction::Explosion { player_entity, center_pos, radius, fingerprint } => {
                let player_entity = *player_entity;
                let center_pos = *center_pos;
                let radius = *radius;
                let fingerprint = *fingerprint;
                let extra = (radius as i32).to_string();
                if !verify_action_signature(ACTION_EXPLODE, center_pos.x, center_pos.y, center_pos.z, &extra, fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, _, _)) = player_query.get_mut(player_entity) else {
                    continue;
                };
                let player_pos = transform.translation;
                let target_pos = Vec3::new(center_pos.x as f32, center_pos.y as f32, center_pos.z as f32);
                let range = action_range(&mod_runtime, ACTION_EXPLODE, 30.0);
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
                                    ACTION_EXPLODE,
                                    &catalog,
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
                    ACTION_EXPLODE,
                    0,
                    &mut mod_state,
                    &mut wallet,
                    target_pos,
                );
            }
            ProposedAction::PlaceBlock { player_entity, voxel_pos, voxel, fingerprint } => {
                let player_entity = *player_entity;
                let voxel_pos = *voxel_pos;
                let fingerprint = *fingerprint;
                if !verify_action_signature(ACTION_PLACE, voxel_pos.x, voxel_pos.y, voxel_pos.z, voxel, fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, _, mut inventory)) =
                    player_query.get_mut(player_entity)
                else {
                    trust_ledger.penalize(player_entity, 1.0);
                    warn!("FRAUD DETECTED: Action received for non-existent Player entity!");
                    continue;
                };
                let player_pos = transform.translation;
                let target_pos = Vec3::new(voxel_pos.x as f32, voxel_pos.y as f32, voxel_pos.z as f32);
                let range = action_range(&mod_runtime, ACTION_PLACE, 10.0);
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

                let Some(index) = catalog_index(&catalog.0, voxel).filter(|i| *i > 0) else {
                    info!("PlaceBlock rejected: unknown voxel {voxel}");
                    continue;
                };
                if !consume_selected(&mut inventory, voxel) {
                    info!("PlaceBlock rejected: hotbar does not hold {voxel}");
                    continue;
                }
                info!("Action Verified! Placing {voxel} at {:?}", voxel_pos);
                voxel_world.set_voxel(voxel_pos, WorldVoxel::Solid(clamp_voxel_type(index as i32)));
                apply_mod_action(
                    &mut commands,
                    &mut meshes,
                    &mut materials,
                    &mod_runtime,
                    ACTION_PLACE,
                    0,
                    &mut mod_state,
                    &mut wallet,
                    target_pos,
                );
            }
            ProposedAction::EnterVehicle { player_entity, vehicle_entity, fingerprint } => {
                let player_entity = *player_entity;
                let vehicle_entity = *vehicle_entity;
                let fingerprint = *fingerprint;
                let bits = vehicle_entity.to_bits() as i32;
                if !verify_action_signature(ACTION_ENTER, bits, 0, 0, "", fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, _, _)) = player_query.get_mut(player_entity) else {
                    continue;
                };
                let Ok(v_transform) = vehicles.get(vehicle_entity) else {
                    trust_ledger.penalize(player_entity, 0.5);
                    warn!("FRAUD DETECTED: EnterVehicle for missing vehicle {:?}", vehicle_entity);
                    continue;
                };
                let range = action_range(&mod_runtime, ACTION_ENTER, 5.0);
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
                    ACTION_ENTER,
                    0,
                    &mut mod_state,
                    &mut wallet,
                    player_pos,
                );
            }
            ProposedAction::Verb { player_entity, verb, extra, fingerprint } => {
                let player_entity = *player_entity;
                let fingerprint = *fingerprint;
                if !verify_action_signature(verb, 0, 0, 0, extra, fingerprint) {
                    trust_ledger.penalize(player_entity, 0.4);
                    warn!("FRAUD DETECTED: Verb signature mismatch");
                    continue;
                }
                let Ok((transform, mut mod_state, mut wallet, mut contract, mut inventory)) =
                    player_query.get_mut(player_entity)
                else {
                    continue;
                };
                if verb == ACTION_CRAFT {
                    let Some((item_a, item_b)) = extra.split_once('+') else {
                        info!("Craft refused: extra is not item+item");
                        continue;
                    };
                    let product = with_mod(&mod_runtime, |ctx| {
                        ctx.bindings
                            .hanga_engine_gameplay()
                            .call_craft_result(&mut ctx.store, item_a, item_b)
                            .unwrap_or_default()
                    })
                    .unwrap_or_default();
                    let mut items = inventory.items.clone();
                    let mut counts = inventory.counts;
                    if product.is_empty()
                        || !inventory_craft_pair(&mut items, &mut counts, item_a, item_b, &product)
                    {
                        info!("Craft refused ({item_a}+{item_b} -> {product})");
                        continue;
                    }
                    inventory.items = items;
                    inventory.counts = counts;
                    let hint = transform.translation;
                    apply_mod_action(
                        &mut commands,
                        &mut meshes,
                        &mut materials,
                        &mod_runtime,
                        verb,
                        0,
                        &mut mod_state,
                        &mut wallet,
                        hint,
                    );
                    info!("Crafted {product} from {item_a}+{item_b}");
                    continue;
                }
                let (kind, danger, payout) = if verb == ACTION_ACCEPT {
                    (offer.kind.clone(), offer.danger, offer.payout)
                } else {
                    (contract.kind.clone(), contract.danger, contract.payout)
                };
                let allowed = with_mod(&mod_runtime, |ctx| {
                    ctx.bindings
                        .hanga_engine_gameplay()
                        .call_mod_can_complete(
                            &mut ctx.store,
                            verb,
                            mod_state.0 as i32,
                            &kind,
                            danger,
                        )
                        .unwrap_or(0)
                })
                .unwrap_or(0);
                if allowed <= 0 {
                    info!("Mod refused verb {verb} (state {}, kind {kind}, danger {danger})", mod_state.0);
                    continue;
                }
                let wallet_extra = if verb == ACTION_COMPLETE { payout } else { 0 };
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
                if verb == ACTION_ACCEPT && contract_is_offered(&offer.kind) {
                    *contract = ModContract {
                        kind: offer.kind.clone(),
                        payout: offer.payout,
                        danger: offer.danger,
                    };
                    *offer = ModOffer::default();
                    info!("Player accepted contract {}", contract.kind);
                } else if verb == ACTION_COMPLETE {
                    info!("Player completed contract {}", contract.kind);
                    *contract = ModContract::default();
                } else if verb == ACTION_FENCE {
                    info!("Player fenced loot, wallet {}", wallet.0);
                }
            }
        }
    }
}

fn grab_cursor(mut windows: Query<&mut CursorOptions, With<PrimaryWindow>>) {
    if let Some(mut cursor) = windows.iter_mut().next() {
        cursor.grab_mode = CursorGrabMode::Locked;
        cursor.visible = false;
    }
}

fn release_cursor(mut windows: Query<&mut CursorOptions, With<PrimaryWindow>>) {
    if let Some(mut cursor) = windows.iter_mut().next() {
        cursor.grab_mode = CursorGrabMode::None;
        cursor.visible = true;
    }
}

fn player_look(
    motion: Res<AccumulatedMouseMotion>,
    mut bodies: Query<(&mut Transform, &mut LookYaw, &mut AngularVelocity), With<Player>>,
    mut cameras: Query<(&mut Transform, &mut LookPitch), (With<LookPitch>, Without<Player>)>,
) {
    let Some((mut body, mut yaw, mut angular)) = bodies.iter_mut().next() else {
        return;
    };
    let Some((mut cam, mut pitch)) = cameras.iter_mut().next() else {
        return;
    };
    let (next_yaw, next_pitch) = apply_mouse_look(
        yaw.0,
        pitch.0,
        motion.delta.x,
        motion.delta.y,
        LOOK_SENSITIVITY,
    );
    yaw.0 = next_yaw;
    pitch.0 = next_pitch;
    body.rotation = Quat::from_rotation_y(yaw.0);
    angular.x = 0.0;
    angular.z = 0.0;
    cam.rotation = Quat::from_euler(EulerRot::YXZ, 0.0, pitch.0, 0.0);
}

/// Very basic first person controller for MVP (and vehicle controller)
fn player_movement(
    keyboard_input: Res<ButtonInput<KeyCode>>,
    mouse_input: Res<ButtonInput<MouseButton>>,
    bindings: Res<KeyBindings>,
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

        if action_pressed(&keyboard_input, &mouse_input, &bindings.0, ACTION_FORWARD) {
            direction += *forward;
        }
        if action_pressed(&keyboard_input, &mouse_input, &bindings.0, ACTION_BACK) {
            direction -= *forward;
        }
        if action_pressed(&keyboard_input, &mouse_input, &bindings.0, ACTION_RIGHT) {
            if target_vehicle.is_some() {
                rotation_y -= 1.0; // Steer right
            } else {
                direction += *right;
            }
        }
        if action_pressed(&keyboard_input, &mouse_input, &bindings.0, ACTION_LEFT) {
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
            if action_just_pressed(&keyboard_input, &mouse_input, &bindings.0, ACTION_JUMP) {
                player_velocity.y = 5.0;
            }
        }
    }
}

/// Allows the player to click and fracture blocks
fn player_interaction(
    mouse_input: Res<ButtonInput<MouseButton>>,
    keys: Res<ButtonInput<KeyCode>>,
    mut events: MessageWriter<ProposedAction>,
    query: Query<(Entity, &Transform, &ModInventory), With<Player>>,
    cameras: Query<&GlobalTransform, With<VoxelWorldCamera<DefaultWorld>>>,
    vehicles: Query<(Entity, &Transform), (With<Vehicle>, Without<Player>)>,
    cheat_mode: Res<CheatMode>,
    mod_runtime: Res<ModRuntime>,
    bindings: Res<KeyBindings>,
) {
    if action_just_pressed(&keys, &mouse_input, &bindings.0, ACTION_BREAK) {
        if let Some((player_entity, transform, _)) = query.iter().next() {
            let (origin, forward) = aim_from(&cameras, transform);
            let forward_pos = if cheat_mode.0 {
                warn!("CHEAT MODE: Attempting to illegally destroy a block far away...");
                origin + (*forward * 50.0)
            } else {
                origin + (*forward * 2.0)
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
    
    if action_just_pressed(&keys, &mouse_input, &bindings.0, ACTION_EXPLODE) {
        if let Some((player_entity, transform, _)) = query.iter().next() {
            let (origin, forward) = aim_from(&cameras, transform);
            let forward_pos = origin + (*forward * 15.0);
            let voxel_pos = IVec3::new(
                forward_pos.x.round() as i32,
                forward_pos.y.round() as i32,
                forward_pos.z.round() as i32,
            );

            events.write(signed_explosion(player_entity, voxel_pos, 4.0));
            info!("Player fired RPG (Explosion) at {:?}", voxel_pos);
        }
    }

    if action_just_pressed(&keys, &mouse_input, &bindings.0, ACTION_PLACE) {
        if let Some((player_entity, transform, inventory)) = query.iter().next() {
            if let Some(item) = inventory_selected(&inventory.items, &inventory.counts, inventory.selected)
            {
                let (origin, forward) = aim_from(&cameras, transform);
                let forward_pos = origin + (*forward * 2.0);
                let voxel_pos = IVec3::new(
                    forward_pos.x.round() as i32,
                    forward_pos.y.round() as i32,
                    forward_pos.z.round() as i32,
                );
                events.write(signed_place(player_entity, voxel_pos, item));
                info!("Player sent PlaceBlock request at {:?}", voxel_pos);
            }
        }
    }

    if action_just_pressed(&keys, &mouse_input, &bindings.0, ACTION_ENTER) {
        if let Some((player_entity, transform, _)) = query.iter().next() {
            if let Some(vehicle_entity) = nearest_vehicle(transform.translation, &vehicles) {
                events.write(signed_enter(player_entity, vehicle_entity));
            }
        }
    }

    if action_just_pressed(&keys, &mouse_input, &bindings.0, ACTION_CRAFT) {
        if let Some((player_entity, _, inventory)) = query.iter().next() {
            if let Some((a, b)) = pick_craft_pair(inventory, &mod_runtime) {
                events.write(signed_verb(player_entity, ACTION_CRAFT, &format!("{a}+{b}")));
            }
        }
    }
}

fn pick_craft_pair(inventory: &ModInventory, mod_runtime: &ModRuntime) -> Option<(String, String)> {
    let a = inventory_selected(&inventory.items, &inventory.counts, inventory.selected)?
        .to_string();
    let recipe = |x: &str, y: &str| {
        with_mod(mod_runtime, |ctx| {
            ctx.bindings
                .hanga_engine_gameplay()
                .call_craft_result(&mut ctx.store, x, y)
                .unwrap_or_default()
        })
        .unwrap_or_default()
    };
    if inventory.counts[inventory.selected] >= 2 && !recipe(&a, &a).is_empty() {
        return Some((a.clone(), a));
    }
    for i in 0..INVENTORY_SLOTS {
        if inventory.items[i].is_empty() || inventory.counts[i] == 0 {
            continue;
        }
        if i == inventory.selected && inventory.counts[i] < 2 {
            continue;
        }
        let b = inventory.items[i].clone();
        if !recipe(&a, &b).is_empty() {
            return Some((a, b));
        }
    }
    None
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
                .after(validate_incoming_actions)
                .run_if(in_state(GameMode::Playing)),
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
                        &agent.0,
                        c_pos.x,
                        c_pos.z,
                        p_pos.x,
                        p_pos.z,
                    )
                    .ok()?;
                let vz = g
                    .call_compute_agent_vz(
                        &mut ctx.store,
                        &agent.0,
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
                .call_should_despawn_agent(&mut ctx.store, &agent.0, wanted)
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
        app.add_systems(OnEnter(GameMode::Playing), start_p2p_if_requested);
        app.add_systems(
            Update,
            (reap_dead_p2p, handle_p2p_receive, handle_p2p_broadcast)
                .chain()
                .run_if(in_state(GameMode::Playing)),
        );
    }
}
#[derive(Resource)]
struct P2pSocket(WebRtcSocket);

fn start_p2p_if_requested(mut commands: Commands, config: Res<P2pConfig>) {
    let Some(room_url) = config.url.clone() else {
        info!("Single-player: P2P off. Use Multiplayer or --p2p when a signaling server is running.");
        return;
    };
    info!("Connecting to P2P mesh at {room_url}");
    let (socket, message_loop) = WebRtcSocket::builder(room_url)
        .add_reliable_channel()
        .build();

    let (done_tx, done_rx) = channel();
    std::thread::spawn(move || {
        if let Err(err) = futures::executor::block_on(message_loop) {
            let _ = done_tx.send(err.to_string());
        }
    });

    commands.insert_resource(P2pSocket(socket));
    commands.insert_resource(P2pWatch(Mutex::new(done_rx)));
}

fn reap_dead_p2p(
    mut commands: Commands,
    watch: Option<Res<P2pWatch>>,
    dead: Option<Res<P2pDead>>,
) {
    let mut drop = dead.is_some();
    if let Some(watch) = watch {
        if let Ok(rx) = watch.0.lock() {
            if let Ok(err) = rx.try_recv() {
                warn!("P2P signaling ended ({err}). Staying in single-player.");
                drop = true;
            }
        }
    }
    if drop {
        commands.remove_resource::<P2pSocket>();
        commands.remove_resource::<P2pWatch>();
        commands.remove_resource::<P2pDead>();
    }
}

fn handle_p2p_receive(
    socket: Option<ResMut<P2pSocket>>,
    mut event_writer: MessageWriter<ProposedAction>,
    mut commands: Commands,
) {
    let Some(mut socket) = socket else {
        return;
    };
    let peers = match std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| socket.0.update_peers()))
    {
        Ok(peers) => peers,
        Err(_) => {
            warn!("P2P socket closed; dropping mesh and continuing single-player.");
            commands.insert_resource(P2pDead);
            return;
        }
    };
    for (peer, new_state) in peers {
        match new_state {
            matchbox_socket::PeerState::Connected => info!("P2P Peer {:?} connected!", peer),
            matchbox_socket::PeerState::Disconnected => info!("P2P Peer {:?} disconnected!", peer),
        }
    }

    if let Ok(packets) = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        socket.0.channel_mut(0).receive()
    })) {
        for (_peer_id, packet) in packets {
            if let Ok(action) = bincode::deserialize::<ProposedAction>(&packet) {
                event_writer.write(action);
            }
        }
    } else {
        commands.insert_resource(P2pDead);
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
        app.add_systems(
            Update,
            update_storyteller
                .after(wanted_decay)
                .run_if(in_state(GameMode::Playing)),
        );
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
            .call_event_label(&mut ctx.store, &event_id, lang)
            .unwrap_or_else(|_| "event".into());
        Some((event_id, label))
    })
    .flatten()
    {
        info!("STORYTELLER (WASM): {label} ({event_id})");
    }
    if !contract_is_offered(&offer.kind) {
        if let Some((kind, payout, danger)) = with_mod(&mod_runtime, |ctx| {
            ctx.bindings
                .hanga_engine_gameplay()
                .call_mod_offer_contract(&mut ctx.store, player_state)
                .ok()
        })
        .flatten()
        {
            if contract_is_offered(&kind) {
                *offer = ModOffer { kind, payout, danger };
                info!(
                    "STORYTELLER (WASM): offer {} payout {payout} danger {danger}",
                    offer.kind
                );
            }
        }
    }
}

// --- Global Economy ---
pub struct EconomicSimulationPlugin;
impl Plugin for EconomicSimulationPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(
            Update,
            update_macro_economy.run_if(in_state(GameMode::Playing)),
        );
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

fn pause_to_menu(
    keys: Res<ButtonInput<KeyCode>>,
    mouse: Res<ButtonInput<MouseButton>>,
    bindings: Res<KeyBindings>,
    mut next: ResMut<NextState<GameMode>>,
) {
    if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_PAUSE) {
        info!("Paused to menu");
        next.set(GameMode::Menu);
    }
}

fn select_hotbar(
    keys: Res<ButtonInput<KeyCode>>,
    mouse: Res<ButtonInput<MouseButton>>,
    bindings: Res<KeyBindings>,
    mut query: Query<&mut ModInventory, With<Player>>,
) {
    let slot = (0..INVENTORY_SLOTS).find_map(|slot| {
        let action = bindings::hotbar_action(slot)?;
        action_just_pressed(&keys, &mouse, &bindings.0, action).then_some(slot)
    });
    if let Some(slot) = slot {
        if let Some(mut inventory) = query.iter_mut().next() {
            inventory.selected = clamp_hotbar_index(slot as i32);
        }
    }
}

fn spawn_hud(mut commands: Commands, locale: Res<UiLocale>) {
    commands
        .spawn((
            HudRoot,
            Node {
                width: Val::Percent(100.0),
                height: Val::Percent(100.0),
                flex_direction: FlexDirection::Column,
                justify_content: JustifyContent::FlexEnd,
                align_items: AlignItems::Center,
                padding: UiRect::all(Val::Px(14.0)),
                row_gap: Val::Px(4.0),
                ..default()
            },
        ))
        .with_children(|parent| {
            parent.spawn((
                HudStatus,
                Text::new(""),
                TextFont {
                    font_size: FontSize::Px(18.0),
                    ..default()
                },
                TextColor(Color::srgb(0.95, 0.93, 0.86)),
            ));
            parent.spawn((
                HudHotbar,
                Text::new(""),
                TextFont {
                    font_size: FontSize::Px(16.0),
                    ..default()
                },
                TextColor(Color::srgb(0.86, 0.8, 0.62)),
            ));
            parent.spawn((
                HudHint,
                Text::new(i18n::t(locale.0, "play_hint")),
                TextFont {
                    font_size: FontSize::Px(14.0),
                    ..default()
                },
                TextColor(Color::srgb(0.62, 0.64, 0.68)),
            ));
        });
}

fn despawn_hud(mut commands: Commands, roots: Query<Entity, With<HudRoot>>) {
    for entity in &roots {
        commands.entity(entity).despawn();
    }
}

fn update_hud(
    locale: Res<UiLocale>,
    players: Query<(&ModState, &ModWallet, &ModContract, &ModInventory), With<Player>>,
    offer: Res<ModOffer>,
    mod_runtime: Res<ModRuntime>,
    mut status: Query<&mut Text, (With<HudStatus>, Without<HudHotbar>, Without<HudHint>)>,
    mut hotbar: Query<&mut Text, (With<HudHotbar>, Without<HudStatus>, Without<HudHint>)>,
    mut hint: Query<&mut Text, (With<HudHint>, Without<HudStatus>, Without<HudHotbar>)>,
) {
    let Some((state, wallet, contract, inventory)) = players.iter().next() else {
        return;
    };
    if let Some(mut text) = status.iter_mut().next() {
        *text = Text::new(job_status_line(
            locale.0,
            &mod_runtime,
            state,
            wallet,
            contract,
            &offer,
            inventory,
        ));
    }
    if let Some(mut text) = hotbar.iter_mut().next() {
        *text = Text::new(hotbar_line(locale.0, &mod_runtime, inventory));
    }
    if let Some(mut text) = hint.iter_mut().next() {
        *text = Text::new(i18n::t(locale.0, "play_hint"));
    }
}

fn spawn_main_menu(mut commands: Commands, locale: Res<UiLocale>, bindings: Res<KeyBindings>) {
    commands
        .spawn((
            MenuRoot,
            Node {
                width: Val::Percent(100.0),
                height: Val::Percent(100.0),
                flex_direction: FlexDirection::Column,
                justify_content: JustifyContent::Center,
                align_items: AlignItems::Center,
                row_gap: Val::Px(10.0),
                ..default()
            },
            BackgroundColor(Color::srgba(0.02, 0.03, 0.05, 0.82)),
        ))
        .with_children(|parent| {
            parent.spawn((
                Text::new(menu_caption(locale.0, &bindings.0, "menu_title")),
                TextFont {
                    font_size: FontSize::Px(64.0),
                    ..default()
                },
                TextColor(Color::srgb(0.95, 0.85, 0.45)),
                MenuLabel("menu_title"),
            ));
            parent.spawn((
                Text::new(menu_caption(locale.0, &bindings.0, "menu_hint")),
                TextFont {
                    font_size: FontSize::Px(16.0),
                    ..default()
                },
                TextColor(Color::srgb(0.7, 0.72, 0.75)),
                MenuLabel("menu_hint"),
            ));
            for (action, key) in [
                (MenuAction::Play, "menu_play"),
                (MenuAction::Multiplayer, "menu_multiplayer"),
                (MenuAction::Lang, "menu_lang"),
                (MenuAction::Controls, "menu_controls"),
                (MenuAction::Quit, "menu_quit"),
            ] {
                parent
                    .spawn((
                        Button,
                        action,
                        Node {
                            width: Val::Px(320.0),
                            height: Val::Px(48.0),
                            justify_content: JustifyContent::Center,
                            align_items: AlignItems::Center,
                            margin: UiRect::top(Val::Px(6.0)),
                            ..default()
                        },
                        BackgroundColor(Color::srgb(0.14, 0.17, 0.22)),
                    ))
                    .with_children(|btn| {
                        btn.spawn((
                            Text::new(menu_caption(locale.0, &bindings.0, key)),
                            TextFont {
                                font_size: FontSize::Px(22.0),
                                ..default()
                            },
                            TextColor(Color::WHITE),
                            MenuLabel(key),
                        ));
                    });
            }
        });
}

fn despawn_main_menu(mut commands: Commands, roots: Query<Entity, With<MenuRoot>>) {
    for entity in &roots {
        commands.entity(entity).despawn();
    }
}

fn apply_menu_action(
    action: MenuAction,
    next: &mut NextState<GameMode>,
    locale: &mut UiLocale,
    p2p: &mut P2pConfig,
    exit: &mut MessageWriter<AppExit>,
) {
    match action {
        MenuAction::Play => {
            info!("Starting single-player");
            next.set(GameMode::Playing);
        }
        MenuAction::Multiplayer => {
            if p2p.url.is_none() {
                p2p.url = Some(DEFAULT_P2P_URL.to_string());
            }
            info!(
                "Starting with optional P2P ({})",
                p2p.url.as_deref().unwrap_or(DEFAULT_P2P_URL)
            );
            next.set(GameMode::Playing);
        }
        MenuAction::Lang => {
            locale.0 = locale.0.next();
            info!("Menu language {}", locale.0.code());
        }
        MenuAction::Controls => {
            next.set(GameMode::Controls);
        }
        MenuAction::Quit => {
            exit.write(AppExit::Success);
        }
    }
}

fn menu_keyboard(
    keys: Res<ButtonInput<KeyCode>>,
    mouse: Res<ButtonInput<MouseButton>>,
    bindings: Res<KeyBindings>,
    mut next: ResMut<NextState<GameMode>>,
    mut locale: ResMut<UiLocale>,
    mut p2p: ResMut<P2pConfig>,
    mut exit: MessageWriter<AppExit>,
) {
    let action = if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_MENU_PLAY) {
        Some(MenuAction::Play)
    } else if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_MENU_MULTI) {
        Some(MenuAction::Multiplayer)
    } else if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_MENU_LANG) {
        Some(MenuAction::Lang)
    } else if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_MENU_CONTROLS) {
        Some(MenuAction::Controls)
    } else if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_MENU_QUIT) {
        Some(MenuAction::Quit)
    } else {
        None
    };
    if let Some(action) = action {
        apply_menu_action(action, &mut next, &mut locale, &mut p2p, &mut exit);
    }
}

fn menu_buttons(
    mut interaction: Query<
        (&Interaction, &MenuAction, &mut BackgroundColor),
        (Changed<Interaction>, With<Button>),
    >,
    mut next: ResMut<NextState<GameMode>>,
    mut locale: ResMut<UiLocale>,
    mut p2p: ResMut<P2pConfig>,
    mut exit: MessageWriter<AppExit>,
) {
    for (interaction, action, mut bg) in &mut interaction {
        match *interaction {
            Interaction::Pressed => {
                apply_menu_action(*action, &mut next, &mut locale, &mut p2p, &mut exit);
            }
            Interaction::Hovered => {
                *bg = BackgroundColor(Color::srgb(0.26, 0.32, 0.42));
            }
            Interaction::None => {
                *bg = BackgroundColor(Color::srgb(0.14, 0.17, 0.22));
            }
        }
    }
}

fn refresh_menu_labels(
    locale: Res<UiLocale>,
    bindings: Res<KeyBindings>,
    mut labels: Query<(&MenuLabel, &mut Text)>,
) {
    if !locale.is_changed() && !bindings.is_changed() {
        return;
    }
    for (label, mut text) in &mut labels {
        *text = Text::new(menu_caption(locale.0, &bindings.0, label.0));
    }
}

fn spawn_controls_menu(mut commands: Commands, locale: Res<UiLocale>, bindings: Res<KeyBindings>) {
    commands
        .spawn((
            ControlsRoot,
            Node {
                width: Val::Percent(100.0),
                height: Val::Percent(100.0),
                flex_direction: FlexDirection::Column,
                justify_content: JustifyContent::Center,
                align_items: AlignItems::Center,
                row_gap: Val::Px(4.0),
                padding: UiRect::all(Val::Px(12.0)),
                ..default()
            },
            BackgroundColor(Color::srgba(0.02, 0.03, 0.05, 0.88)),
        ))
        .with_children(|parent| {
            parent.spawn((
                Text::new(i18n::t(locale.0, "controls_title")),
                TextFont {
                    font_size: FontSize::Px(40.0),
                    ..default()
                },
                TextColor(Color::srgb(0.95, 0.85, 0.45)),
            ));
            parent.spawn((
                ControlsHintText,
                Text::new(i18n::t(locale.0, "controls_hint")),
                TextFont {
                    font_size: FontSize::Px(14.0),
                    ..default()
                },
                TextColor(Color::srgb(0.7, 0.72, 0.75)),
            ));
            parent
                .spawn(Node {
                    width: Val::Px(520.0),
                    max_height: Val::Px(420.0),
                    flex_direction: FlexDirection::Column,
                    overflow: Overflow::scroll_y(),
                    row_gap: Val::Px(3.0),
                    ..default()
                })
                .with_children(|list| {
                    for action in ALL_ACTIONS {
                        list.spawn((
                            Button,
                            BindRow(action),
                            Node {
                                width: Val::Percent(100.0),
                                height: Val::Px(32.0),
                                justify_content: JustifyContent::SpaceBetween,
                                align_items: AlignItems::Center,
                                padding: UiRect::horizontal(Val::Px(10.0)),
                                ..default()
                            },
                            BackgroundColor(Color::srgb(0.14, 0.17, 0.22)),
                        ))
                        .with_children(|row| {
                            row.spawn((
                                BindRowText(action),
                                Text::new(bind_row_caption(locale.0, &bindings.0, action)),
                                TextFont {
                                    font_size: FontSize::Px(16.0),
                                    ..default()
                                },
                                TextColor(Color::WHITE),
                            ));
                        });
                    }
                });
            parent
                .spawn((
                    Button,
                    ControlsBack,
                    Node {
                        width: Val::Px(220.0),
                        height: Val::Px(40.0),
                        justify_content: JustifyContent::Center,
                        align_items: AlignItems::Center,
                        margin: UiRect::top(Val::Px(8.0)),
                        ..default()
                    },
                    BackgroundColor(Color::srgb(0.14, 0.17, 0.22)),
                ))
                .with_children(|btn| {
                    btn.spawn((
                        Text::new(i18n::t(locale.0, "controls_back")),
                        TextFont {
                            font_size: FontSize::Px(20.0),
                            ..default()
                        },
                        TextColor(Color::WHITE),
                    ));
                });
        });
}

fn despawn_controls_menu(
    mut commands: Commands,
    roots: Query<Entity, With<ControlsRoot>>,
    mut capture: ResMut<BindCapture>,
) {
    capture.action = None;
    for entity in &roots {
        commands.entity(entity).despawn();
    }
}

fn capture_rebind(
    mut capture: ResMut<BindCapture>,
    mut bindings: ResMut<KeyBindings>,
    path: Res<BindingsPath>,
    keys: Res<ButtonInput<KeyCode>>,
    mouse: Res<ButtonInput<MouseButton>>,
) {
    if capture.ignore_frames > 0 {
        capture.ignore_frames -= 1;
        return;
    }
    let Some(action) = capture.action.clone() else {
        return;
    };
    if let Some(key) = keys.get_just_pressed().next() {
        bindings.0.set_bind(&action, format!("{key:?}"));
        persist_bindings(&path.0, &bindings.0);
        capture.action = None;
        return;
    }
    if let Some(button) = mouse.get_just_pressed().next() {
        bindings.0.set_bind(&action, mouse_bind_name(*button));
        persist_bindings(&path.0, &bindings.0);
        capture.action = None;
    }
}

fn controls_buttons(
    mut interaction: Query<
        (&Interaction, Option<&BindRow>, Option<&ControlsBack>, &mut BackgroundColor),
        (Changed<Interaction>, With<Button>),
    >,
    mut capture: ResMut<BindCapture>,
    mut next: ResMut<NextState<GameMode>>,
) {
    for (interaction, row, back, mut bg) in &mut interaction {
        match *interaction {
            Interaction::Pressed => {
                if let Some(row) = row {
                    if capture.action.as_deref() == Some(row.0) {
                        capture.action = None;
                    } else {
                        capture.action = Some(row.0.to_string());
                        capture.ignore_frames = 2;
                    }
                } else if back.is_some() {
                    capture.action = None;
                    next.set(GameMode::Menu);
                }
            }
            Interaction::Hovered => {
                *bg = BackgroundColor(Color::srgb(0.26, 0.32, 0.42));
            }
            Interaction::None => {
                *bg = BackgroundColor(Color::srgb(0.14, 0.17, 0.22));
            }
        }
    }
}

fn controls_keyboard(
    keys: Res<ButtonInput<KeyCode>>,
    capture: Res<BindCapture>,
    mut next: ResMut<NextState<GameMode>>,
) {
    if capture.action.is_some() {
        return;
    }
    if keys.just_pressed(KeyCode::Escape) {
        next.set(GameMode::Menu);
    }
}

fn refresh_controls_labels(
    locale: Res<UiLocale>,
    bindings: Res<KeyBindings>,
    capture: Res<BindCapture>,
    mut rows: Query<(&BindRowText, &mut Text), Without<ControlsHintText>>,
    mut hint: Query<&mut Text, With<ControlsHintText>>,
) {
    if !locale.is_changed() && !bindings.is_changed() && !capture.is_changed() {
        return;
    }
    for (row, mut text) in &mut rows {
        *text = Text::new(bind_row_caption(locale.0, &bindings.0, row.0));
    }
    if let Some(mut text) = hint.iter_mut().next() {
        *text = Text::new(if let Some(action) = &capture.action {
            i18n::t(locale.0, "controls_waiting").replace(
                "{action}",
                i18n::t(locale.0, &format!("bind_{action}")),
            )
        } else {
            i18n::t(locale.0, "controls_hint").to_string()
        });
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
    catalog: &VoxelCatalog,
    mod_runtime: &ModRuntime,
    locale: Locale,
) -> (IVec3, String, String) {
    let forward_pos = transform.translation + (transform.forward() * 2.0);
    let voxel_pos = IVec3::new(
        forward_pos.x.round() as i32,
        forward_pos.y.round() as i32,
        forward_pos.z.round() as i32,
    );
    let voxel_type = voxel_type_of(voxel_world.get_voxel(voxel_pos)).unwrap_or(0);
    let voxel = catalog_name(&catalog.0, voxel_type)
        .unwrap_or("air")
        .to_string();
    let raw = with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_voxel_label(&mut ctx.store, &voxel, locale.code())
            .unwrap_or_else(|_| "unknown".into())
    })
    .unwrap_or_else(|| "unknown".into());
    (voxel_pos, voxel, i18n::tr_label(locale, &raw))
}

fn mod_contract_name(mod_runtime: &ModRuntime, locale: Locale, kind: &str) -> String {
    if kind.is_empty() {
        return i18n::t(locale, "job_none").to_string();
    }
    with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_contract_label(&mut ctx.store, kind, locale.code())
            .unwrap_or_default()
    })
    .filter(|name| !name.is_empty())
    .unwrap_or_else(|| kind.to_string())
}

fn mod_item_label(mod_runtime: &ModRuntime, locale: Locale, item: &str) -> String {
    if item.is_empty() {
        return String::new();
    }
    with_mod(mod_runtime, |ctx| {
        ctx.bindings
            .hanga_engine_gameplay()
            .call_item_label(&mut ctx.store, item, locale.code())
            .unwrap_or_default()
    })
    .filter(|name| !name.is_empty())
    .map(|raw| i18n::tr_label(locale, &raw))
    .unwrap_or_else(|| item.to_string())
}

fn held_status(locale: Locale, mod_runtime: &ModRuntime, inventory: &ModInventory) -> String {
    match inventory_selected(&inventory.items, &inventory.counts, inventory.selected) {
        Some(id) => i18n::format_held(
            locale,
            &mod_item_label(mod_runtime, locale, id),
            inventory.counts[inventory.selected],
        ),
        None => i18n::t(locale, "hands_empty").to_string(),
    }
}

fn hotbar_line(locale: Locale, mod_runtime: &ModRuntime, inventory: &ModInventory) -> String {
    let mut parts = Vec::with_capacity(INVENTORY_SLOTS);
    for i in 0..INVENTORY_SLOTS {
        let selected = i == inventory.selected;
        let open = if selected { "[" } else { " " };
        let close = if selected { "]" } else { " " };
        let id = inventory.items[i].as_str();
        let count = inventory.counts[i];
        if !id.is_empty() && count > 0 {
            let label = mod_item_label(mod_runtime, locale, id);
            parts.push(format!("{open}{}:{label}×{count}{close}", i + 1));
        } else {
            parts.push(format!("{open}{}{close}", i + 1));
        }
    }
    i18n::format_hotbar(locale, &parts.join(" "))
}

fn job_status_line(
    locale: Locale,
    mod_runtime: &ModRuntime,
    state: &ModState,
    wallet: &ModWallet,
    contract: &ModContract,
    offer: &ModOffer,
    inventory: &ModInventory,
) -> String {
    let job = if contract_is_offered(&contract.kind) {
        let name = mod_contract_name(mod_runtime, locale, &contract.kind);
        i18n::format_job_active(locale, &name, contract.payout, contract.danger)
    } else if contract_is_offered(&offer.kind) {
        let name = mod_contract_name(mod_runtime, locale, &offer.kind);
        i18n::format_job_offer(locale, &name, offer.payout, offer.danger)
    } else {
        i18n::t(locale, "job_none").to_string()
    };
    i18n::format_status(
        locale,
        state.0,
        wallet.0,
        &job,
        &held_status(locale, mod_runtime, inventory),
    )
}

fn say(locale: Locale, body: &str) {
    println!("{}", i18n::say(locale, body));
}

fn read_terminal_input(
    receiver: Res<StdinReceiver>,
    mut query: Query<(Entity, &Transform, &mut LinearVelocity, &ModState, &ModWallet, &ModContract, &ModInventory), With<Player>>,
    vehicles: Query<(Entity, &Transform), (With<Vehicle>, Without<Player>)>,
    voxel_world: VoxelWorld<DefaultWorld>,
    catalog: Res<VoxelCatalog>,
    mod_runtime: Res<ModRuntime>,
    offer: Res<ModOffer>,
    mut locale: ResMut<UiLocale>,
    mut events: MessageWriter<ProposedAction>,
) {
    if let Ok(rx) = receiver.rx.lock() {
        while let Ok(line) = rx.try_recv() {
            match i18n::parse_text_command(&line) {
                TextCommand::MoveForward => {
                    if let Some((_, transform, mut velocity, _, _, _, _)) = query.iter_mut().next() {
                        let forward = transform.forward();
                        velocity.x = forward.x * 10.0;
                        velocity.z = forward.z * 10.0;
                        say(locale.0, i18n::t(locale.0, "moving"));
                    }
                }
                TextCommand::BreakBlock => {
                    if let Some((player_entity, transform, _, _, _, _, _)) = query.iter_mut().next() {
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
                    if let Some((player_entity, transform, _, _, _, _, inventory)) = query.iter_mut().next() {
                        let forward_pos = transform.translation + (transform.forward() * 2.0);
                        let voxel_pos = IVec3::new(
                            forward_pos.x.round() as i32,
                            forward_pos.y.round() as i32,
                            forward_pos.z.round() as i32,
                        );
                        if let Some(item) =
                            inventory_selected(&inventory.items, &inventory.counts, inventory.selected)
                        {
                            events.write(signed_place(player_entity, voxel_pos, item));
                            say(
                                locale.0,
                                &i18n::t(locale.0, "placing").replace("{pos}", &format!("{voxel_pos:?}")),
                            );
                        } else {
                            say(locale.0, i18n::t(locale.0, "empty_slot"));
                        }
                    }
                }
                TextCommand::EnterVehicle => {
                    if let Some((player_entity, transform, _, _, _, _, _)) = query.iter().next() {
                        if let Some(vehicle_entity) = nearest_vehicle(transform.translation, &vehicles) {
                            events.write(signed_enter(player_entity, vehicle_entity));
                            say(locale.0, i18n::t(locale.0, "entering"));
                        } else {
                            say(locale.0, i18n::t(locale.0, "no_vehicle"));
                        }
                    }
                }
                TextCommand::AcceptJob => {
                    if let Some((player_entity, _, _, _, _, _, _)) = query.iter().next() {
                        events.write(signed_verb(player_entity, ACTION_ACCEPT, ""));
                        say(locale.0, i18n::t(locale.0, "accepting"));
                    }
                }
                TextCommand::CompleteJob => {
                    if let Some((player_entity, _, _, _, _, _, _)) = query.iter().next() {
                        events.write(signed_verb(player_entity, ACTION_COMPLETE, ""));
                        say(locale.0, i18n::t(locale.0, "completing"));
                    }
                }
                TextCommand::Fence => {
                    if let Some((player_entity, _, _, _, _, _, _)) = query.iter().next() {
                        events.write(signed_verb(player_entity, ACTION_FENCE, ""));
                        say(locale.0, i18n::t(locale.0, "fencing"));
                    }
                }
                TextCommand::Craft => {
                    if let Some((player_entity, _, _, _, _, _, inventory)) = query.iter().next() {
                        if let Some((a, b)) = pick_craft_pair(inventory, &mod_runtime) {
                            events.write(signed_verb(player_entity, ACTION_CRAFT, &format!("{a}+{b}")));
                            let la = mod_item_label(&mod_runtime, locale.0, &a);
                            let lb = mod_item_label(&mod_runtime, locale.0, &b);
                            let product = with_mod(&mod_runtime, |ctx| {
                                ctx.bindings
                                    .hanga_engine_gameplay()
                                    .call_craft_result(&mut ctx.store, &a, &b)
                                    .unwrap_or_default()
                            })
                            .unwrap_or_default();
                            let out = mod_item_label(&mod_runtime, locale.0, &product);
                            say(locale.0, &i18n::format_crafting(locale.0, &la, &lb, &out));
                        } else {
                            say(locale.0, i18n::t(locale.0, "no_recipe"));
                        }
                    }
                }
                TextCommand::Look => {
                    if let Some((_, transform, _, state, wallet, contract, inventory)) = query.iter().next() {
                        let (pos, _name, label) =
                            look_voxel_ahead(transform, &voxel_world, &catalog, &mod_runtime, locale.0);
                        let status = job_status_line(
                            locale.0,
                            &mod_runtime,
                            state,
                            wallet,
                            contract,
                            &offer,
                            inventory,
                        );
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
    mut query: Query<(Entity, &Transform, &mut LinearVelocity, &ModState, &ModWallet, &ModContract, &ModInventory, Option<&InVehicle>), With<Player>>,
    vehicles: Query<(Entity, &Transform), (With<Vehicle>, Without<Player>)>,
    voxel_world: VoxelWorld<DefaultWorld>,
    catalog: Res<VoxelCatalog>,
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
                        if let Some((_, transform, mut velocity, _, _, _, _, _)) = query.iter_mut().next() {
                            let forward = transform.forward();
                            velocity.x = forward.x * 10.0;
                            velocity.z = forward.z * 10.0;
                        }
                    }
                    AgentCommand::BreakBlock { pos } => {
                        if let Some((player_entity, _, _, _, _, _, _, _)) = query.iter_mut().next() {
                            events.write(signed_break(
                                player_entity,
                                IVec3::new(pos[0], pos[1], pos[2]),
                            ));
                        }
                    }
                    AgentCommand::PlaceBlock { pos, voxel } => {
                        if let Some((player_entity, _, _, _, _, _, _, _)) = query.iter_mut().next() {
                            events.write(signed_place(
                                player_entity,
                                IVec3::new(pos[0], pos[1], pos[2]),
                                &voxel,
                            ));
                        }
                    }
                    AgentCommand::EnterVehicle => {
                        if let Some((player_entity, transform, _, _, _, _, _, _)) = query.iter_mut().next() {
                            if let Some(vehicle_entity) =
                                nearest_vehicle(transform.translation, &vehicles)
                            {
                                events.write(signed_enter(player_entity, vehicle_entity));
                            }
                        }
                    }
                    AgentCommand::AcceptJob => {
                        if let Some((player_entity, _, _, _, _, _, _, _)) = query.iter().next() {
                            events.write(signed_verb(player_entity, ACTION_ACCEPT, ""));
                        }
                    }
                    AgentCommand::CompleteJob => {
                        if let Some((player_entity, _, _, _, _, _, _, _)) = query.iter().next() {
                            events.write(signed_verb(player_entity, ACTION_COMPLETE, ""));
                        }
                    }
                    AgentCommand::Fence => {
                        if let Some((player_entity, _, _, _, _, _, _, _)) = query.iter().next() {
                            events.write(signed_verb(player_entity, ACTION_FENCE, ""));
                        }
                    }
                    AgentCommand::Look => {
                        if let Some((entity, transform, _, state, wallet, contract, inventory, in_vehicle)) = query.iter_mut().next() {
                            let score = trust_ledger.peer_scores.get(&entity).copied().unwrap_or(100.0);
                            let (_pos, voxel_ahead, voxel_label) =
                                look_voxel_ahead(transform, &voxel_world, &catalog, &mod_runtime, locale.0);
                            let obs = AgentObservation {
                                status: "ok".into(),
                                player_pos: [transform.translation.x, transform.translation.y, transform.translation.z],
                                trust_score: score,
                                wanted_level: state.0,
                                credits: wallet.0,
                                offer_kind: offer.kind.clone(),
                                contract_kind: contract.kind.clone(),
                                voxel_ahead,
                                voxel_label,
                                locale: locale.0.code().into(),
                                in_vehicle: in_vehicle.is_some(),
                                held_item: inventory_selected(
                                    &inventory.items,
                                    &inventory.counts,
                                    inventory.selected,
                                )
                                .unwrap_or("")
                                .to_string(),
                                hotbar_selected: inventory.selected as u32,
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
                    offer_kind: String::new(),
                    contract_kind: String::new(),
                    voxel_ahead: String::new(),
                    voxel_label: String::new(),
                    locale: locale.0.code().into(),
                    in_vehicle: false,
                    held_item: String::new(),
                    hotbar_selected: 0,
                };
                if let Ok(json) = serde_json::to_string(&err) {
                    println!("{}", json);
                }
            }
        }
    }
}
