use bevy::core_pipeline::Core3d;
use bevy::input::mouse::AccumulatedMouseMotion;
use bevy::prelude::*;
use bevy::render::camera::CameraRenderGraph;
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
    ACTION_MENU_CONTROLS, ACTION_MENU_GAME, ACTION_MENU_LANG, ACTION_MENU_MULTI, ACTION_MENU_PLAY,
    ACTION_MENU_QUIT, ACTION_MENU_ROOM, ACTION_PAUSE, ACTION_PLACE, ACTION_RIGHT, ALL_ACTIONS,
};
use hanga::i18n::{self, Locale, TextCommand};
use hanga::{
    action_fingerprint, apply_mouse_look, catalog_index, catalog_name, clamp_hotbar_index,
    clamp_mod_state, clamp_voxel_type, clamp_wallet, contract_is_offered, fracture_offsets,
    inventory_add, inventory_craft_pair, inventory_selected, inventory_take,
    is_action_physically_possible, is_connected_to_ground,
    overlay_get, overlay_set, take_voxel_writes, VoxelOverlay, PlayerSnap, set_player_snap,
    cycle_p2p_url, merge_name_catalogs, parse_p2p_url, p2p_room_name,
    resolve_wasm_path, should_skip_menu, unpack_economy_params,
    verify_action_signature, voxel_has_support, DEFAULT_P2P_URL, INVENTORY_SLOTS, LOOK_SENSITIVITY,
};
use hanga::crash::{
    apply_stiffness, crash_kit_detaches, crumple_axes, crumple_node_shift, impact_speed,
    parse_crash_kit_node, parse_fire_kit_node, parse_fracture_kit_node, parse_planar_node,
};
use hanga::figure::{figure_palette, figure_salt, yaw_toward};
use hanga::gravity::{
    avian_accel, can_jump_from, jump_needs_floor, parse_gravity_node, point_accel, set_jump,
    set_planar_velocity, walk_up, GravityKit,
};
use hanga::heist::{mark_reached, parse_contract_mark_node, ContractMark};
use hanga::vehicle::{
    beam_length, beam_pin_name, beam_step, is_tire, parse_vehicle_kit_node, tire_squash,
    traffic_ahead_blocks, VehicleKit, BEAM_ROUNDS,
};
use hanga::game::{
    cycle_game, game_search_dirs, load_game_catalog, resolve_game, selected_game_id, GameSpec,
    MenuBackdrop, DEFAULT_GAME,
};
use hanga::sign::{self, ActionKey};

pub mod hoot_runtime;
mod mod_manager;
use mod_manager::{
    payload_f32, payload_i64, payload_text, reply_i32, reply_range, wire_as_text, wire_is_empty,
    wire_is_fail, ModRuntime,
    ModManagerPlugin, SHARED_WASM, wire_bag, wire_empty, wire_float, wire_int, wire_text, Wire,
};

#[derive(Resource, Clone, Default)]
struct DefaultWorld;


thread_local! {
    static WASM_INSTANCE: std::cell::RefCell<Option<(u64, Vec<(Store<mod_manager::HostData>, mod_manager::Plugin)>)>> =
        const { std::cell::RefCell::new(None) };
}

impl VoxelWorldConfig for DefaultWorld {
    type MaterialIndex = u8;
    type ChunkUserBundle = ();

    fn texture_index_mapper(&self) -> TextureIndexMapperFn<Self::MaterialIndex> {
        std::sync::Arc::new(|mat| {
            let layer = u32::from(mat).min(hanga::palette::VOXEL_PALETTE_LAYERS - 1);
            [layer, layer, layer]
        })
    }

    fn voxel_texture(&self) -> Option<(String, u32)> {
        Some((
            hanga::palette::VOXEL_PALETTE_FILE.into(),
            hanga::palette::VOXEL_PALETTE_LAYERS,
        ))
    }

    fn voxel_lookup_delegate(&self) -> VoxelLookupDelegate<Self::MaterialIndex> {
        Box::new(|_chunk_pos, _lod, _chunk_data| Box::new(|pos, _voxel| query_lead_voxel(pos)))
    }
}

fn query_lead_voxel(pos: IVec3) -> WorldVoxel<u8> {
    WASM_INSTANCE.with(|instance_ref| {
        let mut instance_opt = instance_ref.borrow_mut();
        let wanted_gen = SHARED_WASM
            .read()
            .ok()
            .and_then(|shared| shared.last().map(|(rev, _, _, _)| *rev));
        let stale = match (instance_opt.as_ref(), wanted_gen) {
            (Some((rev, _)), Some(want)) => *rev != want,
            (None, Some(_)) => true,
            _ => false,
        };
        if stale {
            if let Ok(shared) = SHARED_WASM.read() {
                let mut instances = Vec::new();
                let mut last_rev = 0;
                for (rev, name, engine, format) in shared.iter() {
                    last_rev = *rev;
                    if let mod_manager::ModFormat::Component(component) = format {
                        let mut store = Store::new(engine, mod_manager::noop_host(name.clone()));
                        let mut linker = Linker::new(engine);
                        if mod_manager::Plugin::add_to_linker::<
                            mod_manager::HostData,
                            wasmtime::component::HasSelf<_>,
                        >(&mut linker, |data| data).is_err() { continue; }
                        if let Ok(instance) = mod_manager::Plugin::instantiate(&mut store, component, &linker) {
                            instances.push((store, instance));
                        }
                    }
                }
                *instance_opt = Some((last_rev, instances));
            }
        }

        if let Some((_, instances)) = instance_opt.as_mut() {
            for (store, func) in instances.iter_mut().rev() {
                if let Ok(voxel_type) = func.hanga_engine_guest().call_query_voxel(store, pos.x, pos.y, pos.z) {
                    if voxel_type != 0 {
                        return WorldVoxel::Solid(voxel_type as u8);
                    }
                }
            }
        }

        if pos.y < 0 {
            return WorldVoxel::Solid(1);
        }
        WorldVoxel::Unset
    })
}

#[derive(Resource, Default)]
struct VoxelEdits(std::collections::HashSet<IVec3>);

fn note_voxel_edit(edits: &mut VoxelEdits, pos: IVec3) {
    edits.0.insert(pos);
}

fn rebake_voxel_edits(
    voxel_world: &mut VoxelWorld<DefaultWorld>,
    edits: &VoxelEdits,
    catalog: &[String],
) {
    for pos in &edits.0 {
        let baked = match overlay_get(pos.x, pos.y, pos.z) {
            Some(VoxelOverlay::Air) => WorldVoxel::Unset,
            Some(VoxelOverlay::Solid(name)) => catalog_index(catalog, &name)
                .filter(|index| *index > 0)
                .map(|index| WorldVoxel::Solid(clamp_voxel_type(index as i32)))
                .unwrap_or_else(|| query_lead_voxel(*pos)),
            None => query_lead_voxel(*pos),
        };
        voxel_world.set_voxel(*pos, baked);
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

#[derive(Resource, Clone)]
struct SelectedMod(String);

#[derive(Resource, Clone)]
struct SelectedGame(String);

#[derive(Resource, Clone)]
struct GameCatalog(Vec<GameSpec>);

#[derive(Resource, Clone)]
struct MenuTheme(MenuBackdrop);

#[derive(Component)]
struct ChromePanel;

#[derive(Component)]
struct ChromeTitle;

#[derive(Component)]
struct ChromeHint;

#[derive(Component)]
struct ChromeButton;

#[derive(Resource, Clone)]
struct ModSearch {
    cwd: PathBuf,
    exe: Option<PathBuf>,
    env: Option<PathBuf>,
}

#[derive(Resource, Clone)]
struct GameSearch(Vec<PathBuf>);

#[derive(Component)]
struct SkyClouds;

#[derive(Component)]
struct MenuSkyCamera;

#[derive(Resource, Default)]
struct SkyFor(String);

/// Which `.game` the current play entities were built for. Empty = none yet.
#[derive(Resource, Default)]
struct WorldFor(String);

#[derive(Component)]
struct PlayWorld;

#[derive(Component)]
struct PlayCamera;

#[derive(Resource, Default)]
struct P2pConfig {
    /// Selected Matchbox URL. Room cycles this without joining.
    url: Option<String>,
    /// This play session should open (or keep) a mesh. Play clears it; Multiplayer sets it.
    join: bool,
}

#[derive(Resource)]
struct P2pWatch(Mutex<Receiver<String>>);

#[derive(Resource)]
struct P2pDead;

#[derive(Resource, Clone)]
struct PeerKey(ActionKey);

#[derive(Resource, Clone)]
struct CollectionId(String);

#[derive(Serialize, Deserialize)]
struct SignedPacket {
    payload: Vec<u8>,
    public: Vec<u8>,
    signature: Vec<u8>,
}

#[derive(Serialize, Deserialize)]
struct ActionEnvelope {
    collection: String,
    action: ProposedAction,
}

#[derive(Component)]
struct MenuRoot;

#[derive(Component, Clone, Copy)]
enum MenuAction {
    Play,
    Multiplayer,
    Room,
    Game,
    Lang,
    Controls,
    Quit,
}

#[derive(Component)]
struct MenuLabel(&'static str);

#[derive(Component)]
struct MenuHotkey(&'static str);

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
    let peer_key_path = sign::resolve_peer_key_path(&args);
    let peer_key = sign::load_or_create_key(&peer_key_path).unwrap_or_else(|err| {
        warn!(
            "Peer key {}: {err}; using an ephemeral identity",
            peer_key_path.display()
        );
        ActionKey::generate()
    });
    let pk = peer_key.public_bytes();
    info!(
        "P2P identity {:02x}{:02x}{:02x}{:02x}… ({})",
        pk[0],
        pk[1],
        pk[2],
        pk[3],
        peer_key_path.display()
    );

    let env_mods = std::env::var_os("HANGA_MODS").map(PathBuf::from);
    let env_games = std::env::var_os("HANGA_GAMES").map(PathBuf::from);
    let exe_dir = std::env::current_exe()
        .ok()
        .and_then(|p| p.parent().map(PathBuf::from));
    let cwd = std::env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
    let game_dirs = game_search_dirs(
        &cwd,
        exe_dir.as_deref(),
        env_games.as_deref(),
        env_mods.as_deref(),
    );
    let catalog = load_game_catalog(&game_dirs);
    let game_id = selected_game_id(&args, DEFAULT_GAME);
    let game = resolve_game(&catalog, &game_id);
    let mod_name = game.lead_mod().to_string();
    let wasm_path = resolve_wasm_path(
        &mod_name,
        &cwd,
        exe_dir.as_deref(),
        env_mods.as_deref(),
    );

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
        install_default_plugins(&mut app, window_plugin, &game, &game_dirs);
    } else if is_text_client {
        info!("Starting Hanga in TEXT CLIENT mode (Screen-reader Accessible)");
        install_default_plugins(&mut app, window_plugin, &game, &game_dirs);
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
        install_default_plugins(&mut app, window_plugin, &game, &game_dirs);
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
        install_default_plugins(&mut app, window_plugin, &game, &game_dirs);
    }

    if is_cheater {
        warn!("Starting Hanga in CHEAT MODE (Will intentionally broadcast fraudulent packets)");
    }
    if !wasm_path.is_file() {
        warn!(
            "WASM mod '{}' not found at {} (set HANGA_MODS or build --target wasm32-unknown-unknown)",
            mod_name,
            wasm_path.display()
        );
    }
    info!(
        "Loading game '{}' (mods {}) from {} (locale {})",
        game.id,
        game.mods.join(","),
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
        .init_resource::<WorldFor>()
        .init_resource::<VoxelEdits>()
        .init_resource::<SkyFor>()
        .init_resource::<WorldGravity>()
        .insert_resource(Gravity(Vec3::ZERO))
        .insert_resource(CheatMode(is_cheater))
        .insert_resource(UiLocale(locale))
        .insert_resource(SelectedGame(game.id.clone()))
        .insert_resource(CollectionId(game.collection_key()))
        .insert_resource(GameCatalog(catalog))
        .insert_resource(MenuTheme(game.backdrop))
        .insert_resource(ClearColor(rgb3(if skip_menu {
            game.backdrop.sky
        } else {
            game.backdrop.clear
        })))
        .insert_resource(SelectedMod(mod_name.clone()))
        .insert_resource(ModSearch {
            cwd,
            exe: exe_dir.clone(),
            env: env_mods.clone(),
        })
        .insert_resource(GameSearch(game_dirs))
        .insert_resource(P2pConfig {
            join: p2p_url.is_some(),
            url: p2p_url,
        })
        .insert_resource(PeerKey(peer_key))
        .insert_resource(KeyBindings(bindings))
        .insert_resource(BindingsPath(bindings_path))
        .init_resource::<BindCapture>()
        .add_systems(
            OnEnter(GameMode::Menu),
            (apply_menu_clear, spawn_menu_sky, order_menu_sky, spawn_main_menu).chain(),
        )
        .add_systems(OnExit(GameMode::Menu), (despawn_menu_sky, despawn_main_menu))
        .add_systems(OnEnter(GameMode::Controls), spawn_controls_menu)
        .add_systems(OnExit(GameMode::Controls), despawn_controls_menu)
        .add_systems(
            OnEnter(GameMode::Playing),
            (
                apply_play_sky,
                ensure_play_world,
                ensure_clouds,
                spawn_hud,
                grab_cursor,
                activate_play_cameras,
            )
                .chain(),
        )
        .add_systems(
            OnExit(GameMode::Playing),
            (deactivate_play_cameras, despawn_hud, release_cursor),
        )
        .add_systems(
            Update,
            (
                sync_selected_game,
                rebake_voxels_on_switch,
                ensure_clouds,
                apply_menu_chrome,
                menu_keyboard,
                menu_buttons,
                refresh_menu_labels,
                drift_clouds,
            )
                .chain()
                .run_if(in_state(GameMode::Menu)),
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
            (pause_to_menu, select_hotbar, player_look, update_hud, drift_clouds)
                .run_if(in_state(GameMode::Playing)),
        )
        .add_message::<ProposedAction>()
        .add_systems(
            Update,
            (
                generate_voxel_colliders,
                apply_guest_voxels.run_if(in_state(GameMode::Playing)),
                player_movement.run_if(in_state(GameMode::Playing)),
                snapshot_player.run_if(in_state(GameMode::Playing)),
                player_interaction.run_if(in_state(GameMode::Playing)),
                validate_incoming_actions,
            )
                .chain(),
        )
        .add_systems(
            FixedUpdate,
            apply_point_gravity.run_if(in_state(GameMode::Playing)),
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

#[derive(Component)]
struct VehicleStiffness(i32);

#[derive(Component, Clone)]
struct VehicleMod(String);

#[derive(Component, Clone)]
struct VehiclePart {
    name: String,
    size: Vec3,
    tire: bool,
    rest_scale: Vec3,
}

#[derive(Clone)]
struct BeamLink {
    from: String,
    to: String,
    rest: f32,
}

#[derive(Component, Default)]
struct VehicleBeams {
    pin: String,
    links: Vec<BeamLink>,
}

#[derive(Component)]
struct VehicleDrive {
    speed: f32,
}

#[derive(Component, Default)]
struct VehicleCrash {
    last_speed: f32,
    peak: i32,
}

#[derive(Component)]
struct Wrecked;

#[derive(Component, Default)]
struct Ignited {
    age_ms: i32,
    bursted: bool,
}

#[derive(Component)]
struct IgnitionLight;

#[derive(Component)]
struct Debris;

#[derive(Component)]
struct HeistMark {
    kind: String,
    radius: f32,
    take: bool,
}

#[derive(Resource, Default, Clone)]
struct WorldGravity(GravityKit);

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

fn with_mod<T>(
    mod_runtime: &ModRuntime,
    f: impl FnOnce(&mut mod_manager::MainModContext) -> T,
) -> Option<T> {
    let mut guard = mod_runtime.context.try_lock().ok()?;
    let ctx = guard.as_mut()?;
    Some(f(ctx))
}

fn with_named_mod<T>(
    mod_runtime: &ModRuntime,
    name: &str,
    f: impl FnOnce(&mut mod_manager::MainModContext) -> T,
) -> Option<T> {
    if !name.is_empty() && name != mod_runtime.lead_name() {
        for pack in &mod_runtime.packs {
            if pack.name == name {
                let mut guard = pack.context.try_lock().ok()?;
                let ctx = guard.as_mut()?;
                return Some(f(ctx));
            }
        }
    }
    with_mod(mod_runtime, f)
}

fn with_pack_mods(
    mod_runtime: &ModRuntime,
    mut f: impl FnMut(&str, &mut mod_manager::MainModContext),
) {
    for pack in &mod_runtime.packs {
        if let Ok(mut guard) = pack.context.try_lock() {
            if let Some(ctx) = guard.as_mut() {
                f(&pack.name, ctx);
            }
        }
    }
}

fn voxel_event(pos: IVec3, name: &str) -> Wire {
    wire_bag(vec![
        ("x", Wire::Int(pos.x as i64)),
        ("y", Wire::Int(pos.y as i64)),
        ("z", Wire::Int(pos.z as i64)),
        ("name", Wire::Text(name.to_string())),
    ])
}

fn apply_guest_voxels(
    mut voxel_world: VoxelWorld<DefaultWorld>,
    catalog: Res<VoxelCatalog>,
    mut edits: ResMut<VoxelEdits>,
) {
    for write in take_voxel_writes() {
        let pos = IVec3::new(write.x, write.y, write.z);
        if write.name.is_empty() || write.name == "air" {
            voxel_world.set_voxel(pos, WorldVoxel::Unset);
        } else if let Some(index) = catalog_index(&catalog.0, &write.name) {
            voxel_world.set_voxel(pos, WorldVoxel::Solid(clamp_voxel_type(index as i32)));
        } else {
            continue;
        }
        note_voxel_edit(&mut edits, pos);
    }
}

fn game_mod_paths(game: &GameSpec, search: &ModSearch) -> Vec<(String, PathBuf)> {
    game.mods
        .iter()
        .filter_map(|name| {
            let path = resolve_wasm_path(
                name,
                &search.cwd,
                search.exe.as_deref(),
                search.env.as_deref(),
            );
            if path.is_file() {
                Some((name.clone(), path))
            } else {
                warn!(
                    "WASM pack '{name}' not found at {} (set HANGA_MODS)",
                    path.display()
                );
                None
            }
        })
        .collect()
}

fn load_game_mods(runtime: &mut ModRuntime, game: &GameSpec, search: &ModSearch) {
    let paths = game_mod_paths(game, search);
    if paths.is_empty() {
        return;
    }
    runtime.load_collection(&paths);
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

fn rgb3(c: [f32; 3]) -> Color {
    Color::srgb(c[0], c[1], c[2])
}

fn rgba4(c: [f32; 4]) -> Color {
    Color::srgba(c[0], c[1], c[2], c[3])
}

fn current_game(catalog: &GameCatalog, selected: &SelectedGame) -> GameSpec {
    resolve_game(&catalog.0, &selected.0)
}

fn menu_action_hotkey(
    set: &BindingSet,
    key: &str,
) -> Option<String> {
    let action = match key {
        "menu_play" => Some(ACTION_MENU_PLAY),
        "menu_multiplayer" => Some(ACTION_MENU_MULTI),
        "menu_room" => Some(ACTION_MENU_ROOM),
        "menu_game" => Some(ACTION_MENU_GAME),
        "menu_lang" => Some(ACTION_MENU_LANG),
        "menu_controls" => Some(ACTION_MENU_CONTROLS),
        "menu_quit" => Some(ACTION_MENU_QUIT),
        _ => None,
    };
    action.map(|a| set.display_pretty(a))
}

fn menu_text(
    locale: Locale,
    key: &str,
    game: &GameSpec,
    p2p: &P2pConfig,
) -> String {
    match key {
        "menu_title" => game.title(locale.code()),
        "menu_game" => format!("{}: {}", i18n::t(locale, key), game.title(locale.code())),
        "menu_room" => {
            let room = p2p
                .url
                .as_deref()
                .map(p2p_room_name)
                .unwrap_or_else(|| i18n::t(locale, "p2p_room_off"));
            format!("{}: {room}", i18n::t(locale, key))
        }
        "menu_multiplayer" => match p2p.url.as_deref() {
            Some(url) => format!("{} ({})", i18n::t(locale, key), p2p_room_name(url)),
            None => i18n::t(locale, key).to_string(),
        },
        _ => i18n::t(locale, key).to_string(),
    }
}

fn bind_row_caption(locale: Locale, set: &BindingSet, action: &str) -> String {
    format!(
        "{}   {}",
        i18n::t(locale, &format!("bind_{action}")),
        set.display_pretty(action)
    )
}

fn install_default_plugins(
    app: &mut App,
    window_plugin: WindowPlugin,
    game: &GameSpec,
    search: &[PathBuf],
) {
    let assets = hanga::palette::prepare_asset_dir(game, search);
    app.add_plugins(
        DefaultPlugins
            .set(window_plugin)
            .set(AssetPlugin {
                file_path: assets.to_string_lossy().into_owned(),
                ..default()
            }),
    );
    app.insert_resource(ClearColor(rgb3(game.backdrop.clear)));
}

fn ensure_play_world(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    mut mod_runtime: ResMut<ModRuntime>,
    mut offer: ResMut<ModOffer>,
    locale: Res<UiLocale>,
    search: Res<ModSearch>,
    catalog: Res<GameCatalog>,
    selected_game: Res<SelectedGame>,
    mut world_for: ResMut<WorldFor>,
    play_world: Query<Entity, With<PlayWorld>>,
    chunks: Query<Entity, With<Chunk<DefaultWorld>>>,
) {
    let game = current_game(&catalog, &selected_game);
    let paths = game_mod_paths(&game, &search);
    if paths.is_empty() {
        warn!(
            "WASM collection '{}' has no mods on disk (set HANGA_MODS)",
            game.id
        );
    } else {
        mod_runtime.load_collection(&paths);
    }
    if world_for.0 == game.id {
        return;
    }
    despawn_play_world(&mut commands, &play_world);
    retire_voxel_chunks(&mut commands, &chunks);
    *offer = ModOffer::default();
    spawn_play_world(
        &mut commands,
        &mut meshes,
        &mut materials,
        &mod_runtime,
        &locale,
        &game,
    );
    world_for.0 = game.id.clone();
}

fn despawn_play_world(commands: &mut Commands, worlds: &Query<Entity, With<PlayWorld>>) {
    for entity in worlds.iter() {
        commands.entity(entity).despawn();
    }
}

fn rebake_voxels_on_switch(
    world_for: Res<WorldFor>,
    mut last: Local<String>,
    mut voxel_world: VoxelWorld<DefaultWorld>,
    edits: Res<VoxelEdits>,
    catalog: Res<VoxelCatalog>,
) {
    if world_for.0.is_empty() || world_for.0 == *last {
        return;
    }
    *last = world_for.0.clone();
    if edits.0.is_empty() {
        return;
    }
    rebake_voxel_edits(&mut voxel_world, &edits, &catalog.0);
}

fn retire_voxel_chunks(
    commands: &mut Commands,
    chunks: &Query<Entity, With<Chunk<DefaultWorld>>>,
) {
    let mut n = 0u32;
    for entity in chunks.iter() {
        commands.entity(entity).insert(NeedsDespawn);
        n += 1;
    }
    if n > 0 {
        info!("Retiring {n} voxel chunks for the new game");
    }
}

fn camera_3d() -> (CameraRenderGraph, Camera3d) {
    (CameraRenderGraph::new(Core3d), Camera3d::default())
}

fn activate_play_cameras(mut cameras: Query<&mut Camera, With<PlayCamera>>) {
    for mut camera in &mut cameras {
        camera.is_active = true;
    }
}

fn deactivate_play_cameras(mut cameras: Query<&mut Camera, With<PlayCamera>>) {
    for mut camera in &mut cameras {
        camera.is_active = false;
    }
}

fn spawn_play_world(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    mod_runtime: &ModRuntime,
    locale: &UiLocale,
    game: &GameSpec,
) {
    info!("Hanga engine starting (gameplay owned by the loaded WASM mod)");
    if let Some(supported) =
        with_mod(&mod_runtime, |ctx| ctx.bus_text_ok("supported-locales")).flatten()
    {
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

    let gravity = with_mod(&mod_runtime, |ctx| {
        ctx.bus_node_ok("gravity", &wire_empty())
            .map(|node| parse_gravity_node(&node))
    })
    .flatten()
    .unwrap_or_default();
    let accel = Vec3::from_array(avian_accel(&gravity));
    commands.insert_resource(Gravity(accel));
    commands.insert_resource(WorldGravity(gravity));

    let (px, py, pz) = with_mod(&mod_runtime, |ctx| {
        ctx.bus_xyz_ok("player-spawn", &wire_empty())
    })
    .flatten()
    .unwrap_or((490, 50, 490));
    let player_pos = Vec3::new(px as f32, py as f32, pz as f32);

    commands
        .spawn((
            PlayWorld,
            Name::new("player"),
            Transform::from_translation(player_pos),
            Visibility::default(),
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
                Name::new("play_camera"),
                camera_3d(),
                VoxelWorldCamera::<DefaultWorld>::default(),
                PlayCamera,
                Transform::from_xyz(0.0, 0.55, 0.0),
                LookPitch(0.0),
                play_fog(game),
            ));
        });

    let atmo = &game.atmosphere;
    commands.spawn((
        PlayWorld,
        DirectionalLight {
            color: rgb3(atmo.sun),
            illuminance: atmo.sun_illuminance,
            shadow_maps_enabled: false,
            ..default()
        },
        Transform::from_rotation(Quat::from_euler(EulerRot::XYZ, -1.05, 0.55, 0.0)),
    ));
    commands.spawn((
        PlayWorld,
        AmbientLight {
            color: rgb3(atmo.ambient),
            brightness: atmo.ambient_brightness,
            ..default()
        },
    ));

    let lead = mod_runtime.lead_name().to_string();
    with_mod(mod_runtime, |ctx| {
        spawn_mod_traffic(commands, meshes, materials, &lead, ctx);
    });
    with_pack_mods(mod_runtime, |name, ctx| {
        info!("Spawning pack '{name}' vehicles and agents");
        spawn_mod_traffic(commands, meshes, materials, name, ctx);
    });
}

/// `Err` = `fail` (keep last motion). `Ok(None)` = not mine (host AI). `Ok(Some)` = kit.
fn steer_planar(
    ctx: &mut mod_manager::MainModContext,
    payload: &Wire,
) -> Result<Option<(f32, f32)>, ()> {
    let node = ctx.bus_node_ok("steer", payload).ok_or(())?;
    Ok(parse_planar_node(&node).map(|v| (v.vx, v.vz)))
}

fn spawn_mod_traffic(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    owner: &str,
    ctx: &mut mod_manager::MainModContext,
) {
    let count = ctx
        .bus_i32("vehicle-spawn-count", &wire_empty(), 0)
        .max(0) as u32;
    for i in 0..count {
        let Some((x, y, z)) = ctx.bus_xyz_ok("vehicle-spawn", &wire_int(i as i64)) else {
            continue;
        };
        let Some(node) = ctx.bus_node_ok("vehicle-kit", &wire_int(i as i64)) else {
            continue;
        };
        if node.is_empty() {
            continue;
        }
        let kit = parse_vehicle_kit_node(&node);
        if kit.parts.is_empty() {
            continue;
        }
        if kit.collider.iter().any(|edge| *edge < 0.1) {
            continue;
        }
        spawn_vehicle(
            commands,
            meshes,
            materials,
            Vec3::new(x as f32, y as f32, z as f32),
            &kit,
            owner,
        );
    }

    let ambient = ctx
        .bus_i32("ambient-agent-count", &wire_empty(), 0)
        .max(0);
    for i in 0..ambient {
        let Some((x, y, z, kind)) =
            ctx.bus_xyz_name_ok("ambient-agent-spawn", &wire_int(i as i64), "pedestrian")
        else {
            continue;
        };
        spawn_agent(
            commands,
            meshes,
            materials,
            Vec3::new(x as f32, y as f32, z as f32),
            &kind,
        );
    }
}

fn load_voxel_catalog(mod_runtime: &ModRuntime) -> VoxelCatalog {
    let mut layers = Vec::new();
    if let Some(names) = with_mod(mod_runtime, |ctx| ctx.voxel_catalog()) {
        if !names.is_empty() {
            layers.push(names);
        }
    }
    with_pack_mods(mod_runtime, |_, ctx| {
        let names = ctx.voxel_catalog();
        if !names.is_empty() {
            layers.push(names);
        }
    });
    VoxelCatalog(merge_name_catalogs(&layers))
}

fn mat(materials: &mut Assets<StandardMaterial>, rgb: [f32; 3]) -> Handle<StandardMaterial> {
    materials.add(StandardMaterial {
        base_color: Color::srgb(rgb[0], rgb[1], rgb[2]),
        perceptual_roughness: 0.78,
        metallic: 0.02,
        ..default()
    })
}

fn spawn_agent(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    pos: Vec3,
    kind: &str,
) {
    let pal = figure_palette(kind, figure_salt(pos.x, pos.z));
    let skin = mat(materials, pal.skin);
    let shirt = mat(materials, pal.shirt);
    let pants = mat(materials, pal.pants);
    let accent = mat(materials, pal.accent);
    let head = meshes.add(Cuboid::from_size(Vec3::new(0.20, 0.22, 0.20)));
    let torso = meshes.add(Cuboid::from_size(Vec3::new(0.36, 0.42, 0.20)));
    let arm = meshes.add(Cuboid::from_size(Vec3::new(0.10, 0.40, 0.10)));
    let leg = meshes.add(Cuboid::from_size(Vec3::new(0.13, 0.48, 0.13)));
    let hat = meshes.add(Cuboid::from_size(Vec3::new(0.26, 0.08, 0.30)));
    let facing = yaw_toward(3.0, 0.0).unwrap_or(0.0);

    commands
        .spawn((
            PlayWorld,
            Name::new(kind.to_string()),
            Transform::from_translation(pos).with_rotation(Quat::from_rotation_y(facing)),
            Visibility::default(),
            RigidBody::Dynamic,
            Collider::capsule(0.35, 0.95),
            LockedAxes::new().lock_rotation_x().lock_rotation_z(),
            LinearVelocity::default(),
            AgentAi(kind.to_string()),
        ))
        .with_children(|body| {
            body.spawn((
                Mesh3d(head),
                MeshMaterial3d(skin),
                Transform::from_xyz(0.0, 0.58, 0.0),
            ));
            body.spawn((
                Mesh3d(torso),
                MeshMaterial3d(shirt.clone()),
                Transform::from_xyz(0.0, 0.18, 0.0),
            ));
            body.spawn((
                Mesh3d(arm.clone()),
                MeshMaterial3d(shirt.clone()),
                Transform::from_xyz(-0.24, 0.16, 0.0),
            ));
            body.spawn((
                Mesh3d(arm),
                MeshMaterial3d(shirt),
                Transform::from_xyz(0.24, 0.16, 0.0),
            ));
            body.spawn((
                Mesh3d(leg.clone()),
                MeshMaterial3d(pants.clone()),
                Transform::from_xyz(-0.10, -0.40, 0.0),
            ));
            body.spawn((
                Mesh3d(leg),
                MeshMaterial3d(pants),
                Transform::from_xyz(0.10, -0.40, 0.0),
            ));
            if pal.has_hat {
                body.spawn((
                    Mesh3d(hat),
                    MeshMaterial3d(accent),
                    Transform::from_xyz(0.0, 0.74, 0.04),
                ));
            }
        });
}

fn spawn_vehicle(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    pos: Vec3,
    kit: &VehicleKit,
    owner: &str,
) {
    let [cx, cy, cz] = kit.collider;
    let mut entity = commands.spawn((
        PlayWorld,
        Name::new("vehicle"),
        Vehicle,
        VehicleDrive { speed: kit.speed },
        VehicleStiffness(kit.stiffness),
        VehicleMod(owner.to_string()),
        VehicleBeams {
            pin: beam_pin_name(&kit.parts).unwrap_or("").to_string(),
            links: spawn_beam_links(kit),
        },
        Transform::from_translation(pos),
        Visibility::default(),
        RigidBody::Dynamic,
        Collider::cuboid(cx, cy, cz),
        LockedAxes::new().lock_rotation_x().lock_rotation_z(),
        LinearVelocity::default(),
        AngularVelocity::default(),
        VehicleCrash::default(),
    ));
    if kit.traffic {
        entity.insert(VehicleAi);
    }
    entity.with_children(|body| {
        for part in &kit.parts {
            let size = Vec3::from_array(part.size);
            body.spawn((
                Name::new(part.name.clone()),
                Mesh3d(meshes.add(Cuboid::from_size(size))),
                MeshMaterial3d(mat(materials, part.rgb)),
                Transform::from_xyz(part.offset[0], part.offset[1], part.offset[2]),
                VehiclePart {
                    name: part.name.clone(),
                    size,
                    tire: is_tire(kit, &part.name),
                    rest_scale: Vec3::ONE,
                },
            ));
        }
    });
}

fn spawn_beam_links(kit: &VehicleKit) -> Vec<BeamLink> {
    let mut links = Vec::new();
    for (from, to) in &kit.beams {
        let Some(anchor) = kit.parts.iter().find(|part| part.name == *from) else {
            continue;
        };
        for part in kit.parts.iter().filter(|part| part.name == *to) {
            let dx = part.offset[0] - anchor.offset[0];
            let dy = part.offset[1] - anchor.offset[1];
            let dz = part.offset[2] - anchor.offset[2];
            links.push(BeamLink {
                from: from.clone(),
                to: to.clone(),
                rest: (dx * dx + dy * dy + dz * dz).sqrt(),
            });
        }
    }
    links
}

fn apply_beam_links(
    children: &Children,
    parts: &mut Query<(Entity, &mut VehiclePart, &mut Transform), Without<Vehicle>>,
    beams: &VehicleBeams,
    detach: &[(Entity, Vec3, Transform)],
    crumple: i32,
    stiffness: i32,
) {
    let skipped: std::collections::HashSet<Entity> =
        detach.iter().map(|(entity, _, _)| *entity).collect();
    let mut nodes = std::collections::HashMap::<String, Entity>::new();
    let mut pos = std::collections::HashMap::<String, [f32; 3]>::new();
    for child in children.iter() {
        if skipped.contains(&child) {
            continue;
        }
        let Ok((_, part, local)) = parts.get(child) else {
            continue;
        };
        if nodes.contains_key(&part.name) {
            continue;
        }
        nodes.insert(part.name.clone(), child);
        pos.insert(part.name.clone(), local.translation.to_array());
    }
    for _ in 0..BEAM_ROUNDS {
        for link in beams.links.iter().chain(beams.links.iter().rev()) {
            let Some(a) = pos.get(&link.from).copied() else {
                continue;
            };
            let Some(b) = pos.get(&link.to).copied() else {
                continue;
            };
            let length = beam_length(link.rest, crumple, stiffness);
            let (na, nb) = beam_step(
                a,
                b,
                length,
                link.from == beams.pin,
                link.to == beams.pin,
            );
            pos.insert(link.from.clone(), na);
            pos.insert(link.to.clone(), nb);
        }
    }
    for (name, entity) in nodes {
        let Some(xyz) = pos.get(&name) else {
            continue;
        };
        let Ok((_, _, mut local)) = parts.get_mut(entity) else {
            continue;
        };
        local.translation = Vec3::from_array(*xyz);
    }
}

fn voxel_type_of(voxel: WorldVoxel<u8>) -> Option<i32> {
    match voxel {
        WorldVoxel::Solid(t) => Some(t as i32),
        _ => None,
    }
}

fn voxel_is_solid(voxel_world: &VoxelWorld<DefaultWorld>, cell: [i32; 3]) -> bool {
    voxel_type_of(voxel_world.get_voxel(IVec3::new(cell[0], cell[1], cell[2]))).is_some()
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
        PlayWorld,
        Debris,
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
    edits: &mut VoxelEdits,
) {
    let Some(origin_type) = voxel_type_of(voxel_world.get_voxel(origin)) else {
        return;
    };
    let origin_name = catalog_name(&catalog.0, origin_type)
        .unwrap_or("")
        .to_string();
    let payload = wire_bag(vec![
        ("voxel", Wire::Text(origin_name.clone())),
        ("action", Wire::Text(action.to_string())),
    ]);
    let origin_kit = match mod_runtime.ask_any_node_ok("fracture-kit", &payload) {
        Some(node) => parse_fracture_kit_node(&node),
        None => {
            voxel_world.set_voxel(origin, WorldVoxel::Unset);
            note_voxel_edit(edits, origin);
            overlay_set(origin.x, origin.y, origin.z, VoxelOverlay::Air);
            return;
        }
    };
    let impulse = origin_kit.impulse;
    let spread = origin_kit.spread;

    voxel_world.set_voxel(origin, WorldVoxel::Unset);
    note_voxel_edit(edits, origin);
    overlay_set(origin.x, origin.y, origin.z, VoxelOverlay::Air);
    if origin_kit.can {
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
        let Some(nkit) = mod_runtime
            .ask_any_node_ok(
                "fracture-kit",
                &wire_bag(vec![
                    ("voxel", Wire::Text(nname.clone())),
                    ("action", Wire::Text(action.to_string())),
                ]),
            )
            .map(|node| parse_fracture_kit_node(&node))
        else {
            continue;
        };
        if !nkit.can {
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
        note_voxel_edit(edits, npos);
        overlay_set(npos.x, npos.y, npos.z, VoxelOverlay::Air);
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
        let eval = ctx.bus(
            "evaluate-action",
            &wire_bag(vec![
                ("action", Wire::Text(action.to_string())),
                ("state", Wire::Int(mod_state.0 as i64)),
            ]),
        );
        if wire_is_fail(&eval) {
            return None;
        }
        let new_state = reply_i32(&eval, mod_state.0 as i32);
        let spawn = ctx.bus(
            "should-spawn-agent",
            &wire_bag(vec![
                ("action", Wire::Text(action.to_string())),
                ("old", Wire::Int(mod_state.0 as i64)),
                ("new", Wire::Int(new_state as i64)),
            ]),
        );
        let agent = if wire_is_fail(&spawn) {
            String::new()
        } else {
            wire_as_text(&spawn)
        };
        let wallet_reply = ctx.bus(
            "wallet-after",
            &wire_bag(vec![
                ("action", Wire::Text(action.to_string())),
                ("wallet", Wire::Int(wallet.0 as i64)),
                ("extra", Wire::Int(extra as i64)),
            ]),
        );
        if wire_is_fail(&wallet_reply) {
            Some((new_state, agent, wallet.0))
        } else {
            Some((new_state, agent, reply_i32(&wallet_reply, wallet.0)))
        }
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

fn matching_mark(
    marks: &Query<(Entity, &HeistMark, &Transform), Without<Player>>,
    kind: &str,
    pos: Vec3,
) -> (bool, bool) {
    if kind.is_empty() {
        return (false, false);
    }
    let Some((_, mark, tf)) = marks.iter().find(|(_, m, _)| m.kind == kind) else {
        return (true, false);
    };
    let reached = mark_reached(
        pos.x,
        pos.y,
        pos.z,
        &ContractMark {
            pos: [
                tf.translation.x.round() as i32,
                tf.translation.y.round() as i32,
                tf.translation.z.round() as i32,
            ],
            radius: mark.radius,
            rgb: [0.0, 0.0, 0.0],
            take: mark.take,
        },
    );
    (reached, mark.take)
}

fn clear_heist_marks(
    commands: &mut Commands,
    marks: &Query<(Entity, &HeistMark, &Transform), Without<Player>>,
) {
    for (entity, _, _) in marks.iter() {
        commands.entity(entity).despawn();
    }
}

fn spawn_contract_mark(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    mod_runtime: &ModRuntime,
    kind: &str,
) {
    let Some(mark) = mod_runtime
        .ask_any_node_ok("contract-mark", &wire_text(kind))
        .and_then(|node| parse_contract_mark_node(&node))
    else {
        return;
    };
    let color = Color::srgb(mark.rgb[0], mark.rgb[1], mark.rgb[2]);
    commands.spawn((
        PlayWorld,
        HeistMark {
            kind: kind.to_string(),
            radius: mark.radius,
            take: mark.take,
        },
        Mesh3d(meshes.add(Cuboid::from_size(Vec3::new(0.55, 2.2, 0.55)))),
        MeshMaterial3d(materials.add(StandardMaterial {
            base_color: color,
            emissive: LinearRgba::rgb(mark.rgb[0], mark.rgb[1], mark.rgb[2]) * 3.0,
            perceptual_roughness: 1.0,
            ..default()
        })),
        Transform::from_xyz(mark.pos[0] as f32, mark.pos[1] as f32, mark.pos[2] as f32),
    ));
}

fn action_range(mod_runtime: &ModRuntime, action: &str, fallback: f32) -> f32 {
    reply_range(
        &mod_runtime.ask_any("action-range", &wire_text(action)),
        fallback,
    )
}

/// The Anti-Cheat P2P Judge: Intercepts all optimistic actions and verifies them
fn grant_loot(inv: &mut ModInventory, mod_runtime: &ModRuntime, voxel: &str) {
    let item = mod_runtime.ask_any_text("loot-item", &wire_text(voxel));
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
            Option<&InVehicle>,
        ),
        With<Player>,
    >,
    marks: Query<(Entity, &HeistMark, &Transform), Without<Player>>,
    vehicles: Query<(&Transform, Option<&Wrecked>), (With<Vehicle>, Without<Player>)>,
    mut voxel_world: VoxelWorld<DefaultWorld>,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    mut trust_ledger: ResMut<TrustLedger>,
    mut offer: ResMut<ModOffer>,
    catalog: Res<VoxelCatalog>,
    mod_runtime: Res<ModRuntime>,
    mut edits: ResMut<VoxelEdits>,
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
                let Ok((transform, mut mod_state, mut wallet, _, mut inventory, _)) =
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

                let name = voxel_type_of(voxel_world.get_voxel(voxel_pos))
                    .and_then(|origin_type| catalog_name(&catalog.0, origin_type).map(str::to_string))
                    .unwrap_or_default();
                if mod_runtime.emit_all("before-dig", &voxel_event(voxel_pos, &name)) {
                    continue;
                }

                info!(
                    "Action Verified fingerprint={fingerprint:#x}! Fracturing block at {:?}",
                    voxel_pos
                );
                if !name.is_empty() {
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
                    &mut edits,
                );
                mod_runtime.notify_all("on-dig", &voxel_event(voxel_pos, &name));
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
                let Ok((transform, mut mod_state, mut wallet, _, _, _)) = player_query.get_mut(player_entity) else {
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
                                    &mut edits,
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
                let Ok((transform, mut mod_state, mut wallet, _, mut inventory, _)) =
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
                note_voxel_edit(&mut edits, voxel_pos);
                overlay_set(
                    voxel_pos.x,
                    voxel_pos.y,
                    voxel_pos.z,
                    VoxelOverlay::Solid(voxel.clone()),
                );
                mod_runtime.notify_all("on-place", &voxel_event(voxel_pos, voxel));
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
                let Ok((transform, mut mod_state, mut wallet, _, _, _)) = player_query.get_mut(player_entity) else {
                    continue;
                };
                let Ok((v_transform, wrecked)) = vehicles.get(vehicle_entity) else {
                    trust_ledger.penalize(player_entity, 0.5);
                    warn!("FRAUD DETECTED: EnterVehicle for missing vehicle {:?}", vehicle_entity);
                    continue;
                };
                if wrecked.is_some() {
                    continue;
                }
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
                let Ok((transform, mut mod_state, mut wallet, mut contract, mut inventory, riding)) =
                    player_query.get_mut(player_entity)
                else {
                    continue;
                };
                if verb == ACTION_CRAFT {
                    let Some((item_a, item_b)) = extra.split_once('+') else {
                        info!("Craft refused: extra is not item+item");
                        continue;
                    };
                    let product = mod_runtime.ask_any_text(
                        "craft-result",
                        &wire_bag(vec![
                            ("a", Wire::Text(item_a.to_string())),
                            ("b", Wire::Text(item_b.to_string())),
                        ]),
                    );
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
                let held = inventory_selected(&inventory.items, &inventory.counts, inventory.selected)
                    .unwrap_or("")
                    .to_string();
                let pos = [
                    transform.translation.x.round() as i32,
                    transform.translation.y.round() as i32,
                    transform.translation.z.round() as i32,
                ];
                let (near, take) = matching_mark(&marks, &kind, transform.translation);
                let allowed = with_mod(&mod_runtime, |ctx| {
                    ctx.bus_i32(
                        "can-complete",
                        &wire_bag(vec![
                            ("action", Wire::Text(verb.to_string())),
                            ("state", Wire::Int(mod_state.0 as i64)),
                            ("kind", Wire::Text(kind.clone())),
                            ("danger", Wire::Int(danger as i64)),
                            ("held", Wire::Text(held.clone())),
                            ("x", Wire::Int(pos[0] as i64)),
                            ("y", Wire::Int(pos[1] as i64)),
                            ("z", Wire::Int(pos[2] as i64)),
                            ("vehicle", Wire::Flag(riding.is_some())),
                            ("near", Wire::Flag(near)),
                        ]),
                        0,
                    )
                })
                .unwrap_or(0);
                if allowed <= 0 {
                    info!("Mod refused verb {verb} (state {}, kind {kind}, danger {danger})", mod_state.0);
                    continue;
                }
                if verb == ACTION_COMPLETE && take {
                    let slot = inventory.selected;
                    let mut items = inventory.items.clone();
                    let mut counts = inventory.counts;
                    if inventory_take(&mut items, &mut counts, slot).is_some() {
                        inventory.items = items;
                        inventory.counts = counts;
                    }
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
                    clear_heist_marks(&mut commands, &marks);
                    spawn_contract_mark(
                        &mut commands,
                        &mut meshes,
                        &mut materials,
                        &mod_runtime,
                        &contract.kind,
                    );
                    info!("Player accepted contract {}", contract.kind);
                } else if verb == ACTION_COMPLETE {
                    info!("Player completed contract {}", contract.kind);
                    *contract = ModContract::default();
                    clear_heist_marks(&mut commands, &marks);
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

fn apply_wish(vel: &mut LinearVelocity, wish: Vec3, speed: f32, kit: &GravityKit, pos: Vec3) {
    let up = walk_up(kit, pos.to_array());
    vel.0 = Vec3::from_array(set_planar_velocity(
        vel.0.to_array(),
        wish.to_array(),
        speed,
        up,
    ));
}

fn apply_point_gravity(
    time: Res<Time>,
    field: Res<WorldGravity>,
    mut bodies: Query<(&Transform, &mut LinearVelocity)>,
) {
    if !matches!(field.0.kind, hanga::gravity::GravityKind::Point { .. }) {
        return;
    }
    let dt = time.delta_secs();
    for (tf, mut vel) in &mut bodies {
        let accel = point_accel(&field.0, tf.translation.to_array());
        vel.0 += Vec3::from_array(accel) * dt;
    }
}

/// Very basic first person controller for MVP (and vehicle controller)
fn player_movement(
    keyboard_input: Res<ButtonInput<KeyCode>>,
    mouse_input: Res<ButtonInput<MouseButton>>,
    bindings: Res<KeyBindings>,
    gravity: Res<WorldGravity>,
    voxel_world: VoxelWorld<DefaultWorld>,
    mut players: Query<(&mut Transform, &mut LinearVelocity, Option<&InVehicle>), With<Player>>,
    mut vehicles: Query<
        (
            &Transform,
            &mut LinearVelocity,
            &mut AngularVelocity,
            Option<&Wrecked>,
            &VehicleDrive,
        ),
        (With<Vehicle>, Without<Player>),
    >,
) {
    if let Some((mut player_transform, mut player_velocity, in_vehicle)) = players.iter_mut().next() {
        let mut direction = Vec3::ZERO;
        let mut rotation_y = 0.0;
        
        let mut target_vehicle: Option<(&mut LinearVelocity, &mut AngularVelocity, Vec3, bool, f32)> = None;
        let forward = if let Some(InVehicle(vehicle_entity)) = in_vehicle {
            if let Ok((v_transform, v_velocity, v_angular, wrecked, drive)) =
                vehicles.get_mut(*vehicle_entity)
            {
                let fwd = v_transform.forward();
                target_vehicle = Some((
                    v_velocity.into_inner(),
                    v_angular.into_inner(),
                    v_transform.translation,
                    wrecked.is_some(),
                    drive.speed,
                ));
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

        if let Some((v_vel, v_ang, v_pos, wrecked, speed)) = target_vehicle {
            if !wrecked {
                apply_wish(v_vel, direction, speed, &gravity.0, v_pos);
                v_ang.y = rotation_y * 2.0;
            }
            player_transform.translation = v_pos;
            player_velocity.0 = v_vel.0;
        } else {
            let pos = player_transform.translation;
            apply_wish(
                &mut player_velocity,
                direction,
                gravity.0.walk,
                &gravity.0,
                pos,
            );
            if gravity.0.jump > 0.0
                && action_just_pressed(&keyboard_input, &mouse_input, &bindings.0, ACTION_JUMP)
            {
                let up = walk_up(&gravity.0, pos.to_array());
                if !jump_needs_floor(&gravity.0)
                    || can_jump_from(pos.to_array(), up, |cell| voxel_is_solid(&voxel_world, cell))
                {
                    player_velocity.0 = Vec3::from_array(set_jump(
                        player_velocity.0.to_array(),
                        gravity.0.jump,
                        up,
                    ));
                }
            }
        }
    }
}

fn snapshot_player(
    players: Query<(&Transform, &ModState, &ModWallet), With<Player>>,
) {
    let Some((transform, state, wallet)) = players.iter().next() else {
        return;
    };
    let (yaw, _, _) = transform.rotation.to_euler(EulerRot::YXZ);
    set_player_snap(PlayerSnap {
        x: transform.translation.x,
        y: transform.translation.y,
        z: transform.translation.z,
        yaw,
        state: state.0 as i32,
        wallet: wallet.0,
    });
}

/// Allows the player to click and fracture blocks
fn player_interaction(
    mouse_input: Res<ButtonInput<MouseButton>>,
    keys: Res<ButtonInput<KeyCode>>,
    mut events: MessageWriter<ProposedAction>,
    query: Query<(Entity, &Transform, &ModInventory), With<Player>>,
    cameras: Query<&GlobalTransform, With<VoxelWorldCamera<DefaultWorld>>>,
    vehicles: Query<(Entity, &Transform), (With<Vehicle>, Without<Player>, Without<Wrecked>)>,
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

    if action_just_pressed(&keys, &mouse_input, &bindings.0, ACTION_ACCEPT) {
        if let Some((player_entity, _, _)) = query.iter().next() {
            events.write(signed_verb(player_entity, ACTION_ACCEPT, ""));
        }
    }
    if action_just_pressed(&keys, &mouse_input, &bindings.0, ACTION_COMPLETE) {
        if let Some((player_entity, _, _)) = query.iter().next() {
            events.write(signed_verb(player_entity, ACTION_COMPLETE, ""));
        }
    }
    if action_just_pressed(&keys, &mouse_input, &bindings.0, ACTION_FENCE) {
        if let Some((player_entity, _, _)) = query.iter().next() {
            events.write(signed_verb(player_entity, ACTION_FENCE, ""));
        }
    }
}

fn pick_craft_pair(inventory: &ModInventory, mod_runtime: &ModRuntime) -> Option<(String, String)> {
    let a = inventory_selected(&inventory.items, &inventory.counts, inventory.selected)?
        .to_string();
    let recipe = |x: &str, y: &str| {
        mod_runtime.ask_any_text(
            "craft-result",
            &wire_bag(vec![
                ("a", Wire::Text(x.to_string())),
                ("b", Wire::Text(y.to_string())),
            ]),
        )
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
    query: Query<(Entity, &Mesh3d), (Added<Mesh3d>, Without<HeistMark>, Without<VehiclePart>)>,
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
                guest_globalstep,
                agent_ai_tick,
                wanted_decay,
                vehicle_crash_system,
                tire_deform_system,
                vehicle_traffic_system,
                fire_spread_system,
                flicker_ignition,
            )
                .chain()
                .after(validate_incoming_actions)
                .run_if(in_state(GameMode::Playing)),
        );
    }
}

fn vehicle_hits_solid(transform: &Transform, voxel_world: &VoxelWorld<DefaultWorld>) -> bool {
    let fwd = transform.forward();
    for i in 1..=3 {
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

fn vehicle_crash_system(
    mut commands: Commands,
    mut vehicles: Query<
        (
            Entity,
            &Transform,
            &LinearVelocity,
            &mut AngularVelocity,
            &Children,
            &mut VehicleCrash,
            &VehicleMod,
            &VehicleStiffness,
            &VehicleBeams,
            Option<&Wrecked>,
            Option<&Ignited>,
        ),
        With<Vehicle>,
    >,
    mut parts: Query<(Entity, &mut VehiclePart, &mut Transform), Without<Vehicle>>,
    mut players: Query<(Entity, Option<&InVehicle>), With<Player>>,
    voxel_world: VoxelWorld<DefaultWorld>,
    mod_runtime: Res<ModRuntime>,
    mut events: MessageWriter<ProposedAction>,
) {
    for (entity, transform, velocity, mut angular, children, mut crash, owner, stiff, beams, wrecked, ignited) in
        vehicles.iter_mut()
    {
        let speed = velocity.length();
        let into_solid = vehicle_hits_solid(transform, &voxel_world);
        let Some(impact) = impact_speed(crash.last_speed, speed, into_solid) else {
            crash.last_speed = speed;
            continue;
        };
        crash.last_speed = speed;
        let Some(outcome) = with_named_mod(&mod_runtime, &owner.0, |ctx| {
            ctx.bus_node_ok(
                "crash-kit",
                &wire_bag(vec![
                    ("speed", Wire::Float(impact as f64)),
                    ("solid", Wire::Flag(into_solid)),
                ]),
            )
            .map(|node| parse_crash_kit_node(&node))
        })
        .flatten() else {
            continue;
        };
        let severity = outcome.severity;
        if severity <= crash.peak {
            continue;
        }
        crash.peak = severity;
        let crumple = apply_stiffness(outcome.crumple, stiff.0);
        let dir = [velocity.x, velocity.y, velocity.z];
        let axes = crumple_axes(crumple, dir);
        let mut detach = Vec::new();
        for child in children.iter() {
            let Ok((part_entity, mut part, mut local)) = parts.get_mut(child) else {
                continue;
            };
            if crash_kit_detaches(&outcome, &part.name) {
                detach.push((part_entity, part.size, *local));
            } else {
                part.rest_scale = Vec3::from_array(axes);
                local.scale = part.rest_scale;
                let shifted = crumple_node_shift(local.translation.to_array(), dir, crumple);
                local.translation = Vec3::from_array(shifted);
            }
        }
        apply_beam_links(children, &mut parts, beams, &detach, crumple, stiff.0);
        let impulse = outcome.impulse;
        let kick = transform.forward() * -impulse + Vec3::Y * (impulse * 0.35);
        for (part_entity, size, local) in detach {
            let world = transform.mul_transform(local);
            commands.entity(part_entity).remove_parent_in_place();
            commands.entity(part_entity).insert((
                PlayWorld,
                world,
                RigidBody::Dynamic,
                Collider::cuboid(size.x, size.y, size.z),
                LinearVelocity(velocity.0 + kick),
                AngularVelocity(Vec3::new(2.4, 1.1, 0.8)),
            ));
        }
        let wrecks = outcome.wrecks;
        if wrecks && wrecked.is_none() {
            commands.entity(entity).insert(Wrecked);
            commands.entity(entity).remove::<LockedAxes>();
            commands.entity(entity).remove::<VehicleAi>();
            angular.0 += Vec3::new(1.6, 0.4, 0.9);
            for (player_entity, riding) in players.iter_mut() {
                if matches!(riding, Some(InVehicle(v)) if *v == entity) {
                    commands.entity(player_entity).remove::<InVehicle>();
                }
            }
        }
        if outcome.ignites && ignited.is_none() {
            hang_ignition(&mut commands, entity);
        }
        let action = outcome.action;
        if action.is_empty() {
            continue;
        }
        let Some((player_entity, _)) = players.iter().next() else {
            continue;
        };
        let pos = IVec3::new(
            transform.translation.x.round() as i32,
            transform.translation.y.round() as i32,
            transform.translation.z.round() as i32,
        );
        if action == "explode" {
            events.write(signed_explosion(player_entity, pos, 4.0));
        } else {
            events.write(signed_verb(player_entity, &action, "crash"));
            if into_solid {
                events.write(signed_break(player_entity, pos + IVec3::new(0, 0, -2)));
            }
        }
    }
}

fn tire_deform_system(
    vehicles: Query<
        (&Transform, &LinearVelocity, &VehicleStiffness, &Children),
        (With<Vehicle>, Without<Wrecked>),
    >,
    mut parts: Query<(&VehiclePart, &mut Transform), Without<Vehicle>>,
    voxel_world: VoxelWorld<DefaultWorld>,
) {
    for (transform, velocity, stiff, children) in vehicles.iter() {
        let feet = transform.translation - Vec3::Y * 0.6;
        let grounded = voxel_is_solid(
            &voxel_world,
            [
                feet.x.round() as i32,
                feet.y.round() as i32,
                feet.z.round() as i32,
            ],
        );
        let squash = tire_squash(velocity.length(), stiff.0, grounded);
        for child in children.iter() {
            let Ok((part, mut local)) = parts.get_mut(child) else {
                continue;
            };
            if !part.tire {
                continue;
            }
            local.scale = part.rest_scale * Vec3::new(1.0, squash, 1.0);
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
    mut vehicles: Query<
        (Entity, &mut Transform, &mut LinearVelocity, &VehicleDrive, &VehicleMod),
        (With<VehicleAi>, Without<Wrecked>, Without<Player>, Without<Debris>),
    >,
    extras: Query<
        (Entity, &Transform),
        (
            Without<VehicleAi>,
            Or<(With<Debris>, With<Player>, With<Wrecked>)>,
        ),
    >,
    voxel_world: VoxelWorld<DefaultWorld>,
    mod_runtime: Res<ModRuntime>,
) {
    let traffic_spots: Vec<(Entity, Vec3)> = vehicles
        .iter()
        .map(|(entity, transform, _, _, _)| (entity, transform.translation))
        .collect();
    let extra_spots: Vec<(Entity, Vec3)> = extras
        .iter()
        .map(|(entity, transform)| (entity, transform.translation))
        .collect();
    for (entity, mut transform, mut velocity, drive, owner) in vehicles.iter_mut() {
        let fwd = transform.forward();
        let origin = transform.translation.to_array();
        let heading = [fwd.x, fwd.y, fwd.z];
        let mut blocked = path_blocked(&transform, &voxel_world);
        if !blocked {
            blocked = traffic_spots
                .iter()
                .chain(extra_spots.iter())
                .any(|(other, pos)| {
                    *other != entity
                        && traffic_ahead_blocks(origin, heading, pos.to_array(), 12.0, 2.5)
                });
        }
        let payload = wire_bag(vec![
            ("role", Wire::Text("traffic".into())),
            ("fwd-x", Wire::Float(fwd.x as f64)),
            ("fwd-z", Wire::Float(fwd.z as f64)),
            ("blocked", Wire::Flag(blocked)),
        ]);
        match with_named_mod(&mod_runtime, &owner.0, |ctx| steer_planar(ctx, &payload)) {
            None | Some(Err(())) => {
                velocity.x = 0.0;
                velocity.z = 0.0;
            }
            Some(Ok(Some((vx, vz)))) => {
                velocity.x = vx;
                velocity.z = vz;
                if let Some(yaw) = yaw_toward(vx, vz) {
                    transform.rotation = Quat::from_rotation_y(yaw);
                }
            }
            Some(Ok(None)) => {
                if blocked {
                    velocity.x = 0.0;
                    velocity.z = 0.0;
                } else {
                    velocity.x = fwd.x * drive.speed;
                    velocity.z = fwd.z * drive.speed;
                }
            }
        }
    }
}

fn hang_ignition(commands: &mut Commands, entity: Entity) {
    commands.entity(entity).insert(Ignited::default());
    commands.entity(entity).with_children(|parent| {
        parent.spawn((
            IgnitionLight,
            PointLight {
                color: Color::srgb(1.0, 0.42, 0.12),
                intensity: 400_000.0,
                range: 16.0,
                radius: 0.35,
                shadow_maps_enabled: false,
                ..default()
            },
            Transform::from_xyz(0.0, 0.55, 0.9),
        ));
    });
}

fn fire_spread_system(
    mut commands: Commands,
    time: Res<Time>,
    mut timer: Local<f32>,
    mut burning: Query<(Entity, &Transform, &mut Ignited, &Children, &VehicleMod), With<Vehicle>>,
    cold: Query<(Entity, &Transform), (With<Vehicle>, Without<Ignited>)>,
    mut lights: Query<&mut PointLight, With<IgnitionLight>>,
    voxel_world: VoxelWorld<DefaultWorld>,
    catalog: Res<VoxelCatalog>,
    mod_runtime: Res<ModRuntime>,
    players: Query<Entity, With<Player>>,
    mut events: MessageWriter<ProposedAction>,
) {
    *timer += time.delta_secs();
    if *timer < 0.2 {
        return;
    }
    let dt_ms = (*timer * 1000.0) as i32;
    *timer = 0.0;
    let player = players.iter().next();
    let cold_spots: Vec<(Entity, Vec3)> = cold
        .iter()
        .map(|(entity, transform)| (entity, transform.translation))
        .collect();
    let mut jump_to = Vec::new();
    for (entity, transform, mut fire, children, owner) in burning.iter_mut() {
        fire.age_ms = fire.age_ms.saturating_add(dt_ms);
        let pos = IVec3::new(
            transform.translation.x.round() as i32,
            transform.translation.y.round() as i32,
            transform.translation.z.round() as i32,
        );
        let nearby = voxel_type_of(voxel_world.get_voxel(pos))
            .and_then(|index| catalog_name(&catalog.0, index).map(str::to_string))
            .unwrap_or_default();
        let Some(kit) = with_named_mod(&mod_runtime, &owner.0, |ctx| {
            ctx.bus_node_ok(
                "fire-kit",
                &wire_bag(vec![
                    ("age", Wire::Int(fire.age_ms as i64)),
                    ("nearby", Wire::Text(nearby.clone())),
                ]),
            )
            .map(|node| parse_fire_kit_node(&node))
        })
        .flatten() else {
            for child in children.iter() {
                if lights.get(child).is_ok() {
                    commands.entity(child).despawn();
                }
            }
            commands.entity(entity).remove::<Ignited>();
            continue;
        };
        if kit.out {
            for child in children.iter() {
                if lights.get(child).is_ok() {
                    commands.entity(child).despawn();
                }
            }
            commands.entity(entity).remove::<Ignited>();
            continue;
        }
        for child in children.iter() {
            if let Ok(mut light) = lights.get_mut(child) {
                light.intensity = 180_000.0 + 320_000.0 * kit.heat;
                light.range = 8.0 + kit.range;
            }
        }
        if kit.consume {
            if let Some(player_entity) = player {
                events.write(signed_break(player_entity, pos));
            }
        }
        if kit.burst && !fire.bursted {
            fire.bursted = true;
            if let Some(player_entity) = player {
                events.write(signed_explosion(player_entity, pos, 3.0));
            }
        }
        if kit.jump {
            let origin = transform.translation;
            let reach = kit.range.max(1.0);
            for (other, spot) in &cold_spots {
                if origin.distance(*spot) <= reach {
                    jump_to.push(*other);
                }
            }
        }
    }
    jump_to.sort();
    jump_to.dedup();
    for other in jump_to {
        hang_ignition(&mut commands, other);
    }
}

fn flicker_ignition(time: Res<Time>, mut lights: Query<&mut PointLight, With<IgnitionLight>>) {
    let pulse = (time.elapsed_secs() * 13.0).sin().abs();
    for mut light in &mut lights {
        light.intensity = 220_000.0 + 280_000.0 * pulse;
    }
}

/// AI logic for all agents, entirely powered by the WASM mod!
fn agent_ai_tick(
    mut agents: Query<(&mut Transform, &mut LinearVelocity, &AgentAi)>,
    players: Query<&Transform, (With<Player>, Without<AgentAi>)>,
    mod_runtime: Res<ModRuntime>,
) {
    if let Some(player_transform) = players.iter().next() {
        let p_pos = player_transform.translation;

        for (mut agent_transform, mut velocity, agent) in agents.iter_mut() {
            let c_pos = agent_transform.translation;
            let payload = wire_bag(vec![
                ("role", Wire::Text(agent.0.clone())),
                ("cur-x", Wire::Float(c_pos.x as f64)),
                ("cur-z", Wire::Float(c_pos.z as f64)),
                ("target-x", Wire::Float(p_pos.x as f64)),
                ("target-z", Wire::Float(p_pos.z as f64)),
            ]);
            match with_mod(&mod_runtime, |ctx| steer_planar(ctx, &payload)) {
                Some(Ok(Some((vx, vz)))) => {
                    velocity.x = vx;
                    velocity.z = vz;
                    if let Some(yaw) = yaw_toward(vx, vz) {
                        agent_transform.rotation = Quat::from_rotation_y(yaw);
                    }
                }
                _ => {
                    velocity.x = 0.0;
                    velocity.z = 0.0;
                }
            }
        }
    }
}

fn guest_globalstep(time: Res<Time>, mod_runtime: Res<ModRuntime>) {
    mod_runtime.flush_after();
    let dt_ms = (time.delta_secs() * 1000.0).round() as i64;
    mod_runtime.notify_all(
        "on-step",
        &wire_bag(vec![("dt", Wire::Int(dt_ms))]),
    );
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
        wanted = state.0 as i32;
        let new_state = with_mod(&mod_runtime, |ctx| {
            let reply = ctx.bus(
                "tick",
                &wire_bag(vec![
                    ("state", Wire::Int(state.0 as i64)),
                    ("dt", Wire::Int(dt_ms as i64)),
                ]),
            );
            if wire_is_fail(&reply) {
                None
            } else {
                Some(reply_i32(&reply, state.0 as i32))
            }
        })
        .flatten()
        .unwrap_or(0);
        
        let clamped = clamp_mod_state(new_state, 0, 5) as u32;
        if clamped != state.0 {
            info!("Mod tick: state {} -> {}", state.0, clamped);
        }
        state.0 = clamped;
        wanted = state.0 as i32;
    }
    for (entity, agent) in agents.iter() {
        let drop = with_mod(&mod_runtime, |ctx| {
            ctx.bus_i32(
                "should-despawn-agent",
                &wire_bag(vec![
                    ("agent", Wire::Text(agent.0.clone())),
                    ("state", Wire::Int(wanted as i64)),
                ]),
                0,
            )
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
struct P2pSocket {
    room: String,
    rtc: WebRtcSocket,
}

fn start_p2p_if_requested(
    mut commands: Commands,
    config: Res<P2pConfig>,
    socket: Option<Res<P2pSocket>>,
    dead: Option<Res<P2pDead>>,
) {
    let Some(room_url) = config.url.clone().filter(|_| config.join) else {
        if socket.is_some() || dead.is_some() {
            commands.remove_resource::<P2pSocket>();
            commands.remove_resource::<P2pWatch>();
            commands.remove_resource::<P2pDead>();
        }
        info!("Single-player: P2P off. Use Room + Multiplayer or --p2p when a signaling server is running.");
        return;
    };
    if let Some(socket) = socket.as_ref() {
        if dead.is_none() && socket.room == room_url {
            return;
        }
    }
    commands.remove_resource::<P2pSocket>();
    commands.remove_resource::<P2pWatch>();
    commands.remove_resource::<P2pDead>();
    info!("Connecting to P2P mesh at {room_url}");
    let (rtc, message_loop) = WebRtcSocket::builder(room_url.clone())
        .add_reliable_channel()
        .build();

    let (done_tx, done_rx) = channel();
    std::thread::spawn(move || {
        if let Err(err) = futures::executor::block_on(message_loop) {
            let _ = done_tx.send(err.to_string());
        }
    });

    commands.insert_resource(P2pSocket {
        room: room_url,
        rtc,
    });
    commands.insert_resource(P2pWatch(Mutex::new(done_rx)));
}

fn reap_dead_p2p(
    mut commands: Commands,
    watch: Option<Res<P2pWatch>>,
    dead: Option<Res<P2pDead>>,
) {
    if dead.is_some() {
        commands.remove_resource::<P2pSocket>();
        commands.remove_resource::<P2pWatch>();
        return;
    }
    let mut drop = false;
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
        commands.insert_resource(P2pDead);
    }
}

fn handle_p2p_receive(
    socket: Option<ResMut<P2pSocket>>,
    mut event_writer: MessageWriter<ProposedAction>,
    mut commands: Commands,
    collection: Res<CollectionId>,
) {
    let Some(mut socket) = socket else {
        return;
    };
    let peers = match std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| socket.rtc.update_peers()))
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
        socket.rtc.channel_mut(0).receive()
    })) {
        for (_peer_id, packet) in packets {
            let Ok(signed) = bincode::deserialize::<SignedPacket>(&packet) else {
                warn!("P2P packet was not a signed action; dropping");
                continue;
            };
            if !sign::verify_signed(&signed.public, &signed.payload, &signed.signature) {
                warn!("P2P packet failed Ed25519 verify; dropping");
                continue;
            }
            if let Ok(envelope) = bincode::deserialize::<ActionEnvelope>(&signed.payload) {
                if envelope.collection != collection.0 {
                    warn!(
                        "P2P action from another collection ({}); dropping",
                        envelope.collection
                    );
                    continue;
                }
                event_writer.write(envelope.action);
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
    key: Res<PeerKey>,
    collection: Res<CollectionId>,
) {
    let local_player = players.iter().next();
    if let Some(mut socket) = socket {
        for action in event_reader.read() {
            let is_local = match action {
                ProposedAction::BreakBlock { player_entity, .. } => Some(*player_entity) == local_player,
                ProposedAction::Explosion { player_entity, .. } => Some(*player_entity) == local_player,
                ProposedAction::PlaceBlock { player_entity, .. } => Some(*player_entity) == local_player,
                ProposedAction::EnterVehicle { player_entity, .. } => Some(*player_entity) == local_player,
                ProposedAction::Verb { player_entity, .. } => Some(*player_entity) == local_player,
            };

            if is_local {
                let Ok(payload) = bincode::serialize(&ActionEnvelope {
                    collection: collection.0.clone(),
                    action: action.clone(),
                }) else {
                    continue;
                };
                let packet = SignedPacket {
                    public: key.0.public_bytes().to_vec(),
                    signature: key.0.sign(&payload).to_vec(),
                    payload,
                };
                if let Ok(bytes) = bincode::serialize(&packet) {
                    let peers: Vec<_> = socket.rtc.connected_peers().collect();
                    let packet_boxed = bytes.into_boxed_slice();
                    for peer in peers {
                        socket.rtc.channel_mut(0).send(packet_boxed.clone(), peer);
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
        let event = ctx.bus("story-event", &wire_int(player_state as i64));
        if wire_is_fail(&event) {
            return None;
        }
        let event_id = wire_as_text(&event);
        if event_id.is_empty() {
            return None;
        }
        let labeled = ctx.bus(
            "event-label",
            &wire_bag(vec![
                ("event", Wire::Text(event_id.clone())),
                ("locale", Wire::Text(lang.to_string())),
            ]),
        );
        let label = if wire_is_fail(&labeled) {
            event_id.clone()
        } else {
            let text = wire_as_text(&labeled);
            if text.is_empty() {
                "event".into()
            } else {
                text
            }
        };
        Some((event_id, label))
    })
    .flatten()
    {
        info!("STORYTELLER (WASM): {label} ({event_id})");
    }
    if !contract_is_offered(&offer.kind) {
        if let Some((kind, payout, danger)) = with_mod(&mod_runtime, |ctx| {
            let reply = ctx.bus("offer-contract", &wire_int(player_state as i64));
            if wire_is_fail(&reply) {
                return None;
            }
            let kind = payload_text(&reply, "kind").to_string();
            if kind.is_empty() {
                return None;
            }
            Some((
                kind,
                payload_i64(&reply, "payout") as i32,
                payload_i64(&reply, "danger") as i32,
            ))
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
            let params = ctx.bus("economy-params", &wire_empty());
            if wire_is_fail(&params) || wire_is_empty(&params) {
                return None;
            }
            let (supply, demand) = unpack_economy_params(reply_i32(&params, 0));
            let priced = ctx.bus(
                "economy-price",
                &wire_bag(vec![
                    ("base", Wire::Int(100)),
                    ("supply", Wire::Int(supply as i64)),
                    ("demand", Wire::Int(demand as i64)),
                ]),
            );
            if wire_is_fail(&priced) || wire_is_empty(&priced) {
                return None;
            }
            Some((reply_i32(&priced, 100), supply, demand))
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
    bindings: Res<KeyBindings>,
    players: Query<(&ModState, &ModWallet, &ModContract, &ModInventory), With<Player>>,
    offer: Res<ModOffer>,
    mod_runtime: Res<ModRuntime>,
    p2p: Res<P2pConfig>,
    socket: Option<Res<P2pSocket>>,
    dead: Option<Res<P2pDead>>,
    mut status: Query<&mut Text, (With<HudStatus>, Without<HudHotbar>, Without<HudHint>)>,
    mut hotbar: Query<&mut Text, (With<HudHotbar>, Without<HudStatus>, Without<HudHint>)>,
    mut hint: Query<&mut Text, (With<HudHint>, Without<HudStatus>, Without<HudHotbar>)>,
) {
    let Some((state, wallet, contract, inventory)) = players.iter().next() else {
        return;
    };
    if let Some(mut text) = status.iter_mut().next() {
        let accept = bindings.0.display(ACTION_ACCEPT);
        *text = Text::new(job_status_line(
            locale.0,
            &mod_runtime,
            state,
            wallet,
            contract,
            &offer,
            inventory,
            Some(&accept),
        ));
    }
    if let Some(mut text) = hotbar.iter_mut().next() {
        *text = Text::new(hotbar_line(locale.0, &mod_runtime, inventory));
    }
    if let Some(mut text) = hint.iter_mut().next() {
        *text = Text::new(play_hint_line(
            locale.0,
            &mod_runtime,
            inventory,
            p2p.url.as_deref().filter(|_| p2p.join),
            p2p_peer_count(socket.as_deref()),
            dead.is_some(),
        ));
    }
}

fn p2p_peer_count(socket: Option<&P2pSocket>) -> usize {
    let Some(socket) = socket else {
        return 0;
    };
    std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        socket.rtc.connected_peers().count()
    }))
    .unwrap_or(0)
}

fn play_hint_line(
    locale: Locale,
    mod_runtime: &ModRuntime,
    inventory: &ModInventory,
    p2p_url: Option<&str>,
    peers: usize,
    dead: bool,
) -> String {
    let controls = i18n::t(locale, "play_hint");
    let p2p = i18n::format_p2p(locale, p2p_url.map(p2p_room_name), peers, dead);
    let Some((a, b)) = pick_craft_pair(inventory, mod_runtime) else {
        return format!("{controls}  |  {p2p}");
    };
    let product = mod_runtime.ask_any_text(
        "craft-result",
        &wire_bag(vec![
            ("a", Wire::Text(a.clone())),
            ("b", Wire::Text(b.clone())),
        ]),
    );
    if product.is_empty() {
        return format!("{controls}  |  {p2p}");
    }
    let recipe = i18n::format_crafting(
        locale,
        &mod_item_label(mod_runtime, locale, &a),
        &mod_item_label(mod_runtime, locale, &b),
        &mod_item_label(mod_runtime, locale, &product),
    );
    format!("{recipe}  |  {controls}  |  {p2p}")
}

fn apply_menu_clear(theme: Res<MenuTheme>, mut clear: ResMut<ClearColor>) {
    clear.0 = rgb3(theme.0.clear);
}

fn apply_play_sky(theme: Res<MenuTheme>, mut clear: ResMut<ClearColor>) {
    clear.0 = rgb3(theme.0.sky);
}

fn sync_selected_game(
    selected: Res<SelectedGame>,
    catalog: Res<GameCatalog>,
    search: Res<ModSearch>,
    games: Res<GameSearch>,
    mut selected_mod: ResMut<SelectedMod>,
    mut theme: ResMut<MenuTheme>,
    mut runtime: ResMut<ModRuntime>,
    mut collection: ResMut<CollectionId>,
) {
    if !selected.is_changed() && !catalog.is_changed() {
        return;
    }
    let game = current_game(&catalog, &selected);
    selected_mod.0 = game.lead_mod().to_string();
    collection.0 = game.collection_key();
    theme.0 = game.backdrop;
    hanga::palette::prepare_asset_dir(&game, &games.0);
    load_game_mods(&mut runtime, &game, &search);
}

fn play_fog(game: &GameSpec) -> DistanceFog {
    match game.atmosphere.fog {
        Some(color) => DistanceFog {
            color: rgb3(color),
            falloff: FogFalloff::Linear {
                start: game.atmosphere.fog_start,
                end: game.atmosphere.fog_end.max(game.atmosphere.fog_start + 1.0),
            },
            ..default()
        },
        None => DistanceFog {
            falloff: FogFalloff::Linear {
                start: 1_000_000.0,
                end: 1_000_001.0,
            },
            ..default()
        },
    }
}

fn spawn_clouds(
    commands: &mut Commands,
    meshes: &mut Assets<Mesh>,
    materials: &mut Assets<StandardMaterial>,
    assets: &AssetServer,
    game: &GameSpec,
) {
    if !game.has_clouds() {
        return;
    }
    let image = assets.load(hanga::palette::CLOUD_FILE);
    let mat = materials.add(StandardMaterial {
        base_color: Color::WHITE,
        base_color_texture: Some(image),
        perceptual_roughness: 1.0,
        metallic: 0.0,
        alpha_mode: AlphaMode::Blend,
        unlit: true,
        cull_mode: None,
        ..default()
    });
    let scale = game.atmosphere.cloud_scale.max(80.0);
    let height = game.atmosphere.cloud_height.max(40.0);
    let mesh = meshes.add(Plane3d {
        half_size: Vec2::splat(scale * 0.5),
        ..default()
    });
    commands.spawn((
        SkyClouds,
        Mesh3d(mesh.clone()),
        MeshMaterial3d(mat.clone()),
        Transform::from_xyz(0.0, height, 0.0),
    ));
    commands.spawn((
        SkyClouds,
        Mesh3d(mesh),
        MeshMaterial3d(mat),
        Transform::from_xyz(scale * 0.18, height + 18.0, -scale * 0.12)
            .with_scale(Vec3::splat(1.15)),
    ));
}

fn ensure_clouds(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
    assets: Res<AssetServer>,
    catalog: Res<GameCatalog>,
    selected: Res<SelectedGame>,
    mut sky_for: ResMut<SkyFor>,
    clouds: Query<Entity, With<SkyClouds>>,
) {
    let game = current_game(&catalog, &selected);
    if sky_for.0 == game.id {
        return;
    }
    for entity in &clouds {
        commands.entity(entity).despawn();
    }
    sky_for.0 = game.id.clone();
    spawn_clouds(
        &mut commands,
        &mut meshes,
        &mut materials,
        &assets,
        &game,
    );
}

fn spawn_menu_sky(mut commands: Commands) {
    commands.spawn((
        Name::new("menu_sky_camera"),
        MenuSkyCamera,
        camera_3d(),
        Transform::from_xyz(24.0, 18.0, 70.0).looking_at(Vec3::new(0.0, 48.0, -40.0), Vec3::Y),
    ));
}

fn order_menu_sky(mut cameras: Query<&mut Camera, With<MenuSkyCamera>>) {
    for mut camera in &mut cameras {
        camera.order = -1;
    }
}

fn despawn_menu_sky(mut commands: Commands, cams: Query<Entity, With<MenuSkyCamera>>) {
    for entity in &cams {
        commands.entity(entity).despawn();
    }
}

fn drift_clouds(time: Res<Time>, mut clouds: Query<&mut Transform, With<SkyClouds>>) {
    let dt = time.delta_secs();
    for (i, mut transform) in clouds.iter_mut().enumerate() {
        let spin = if i == 0 { 0.012 } else { -0.008 };
        transform.rotate_y(spin * dt);
    }
}

fn apply_menu_chrome(
    theme: Res<MenuTheme>,
    mut clear: ResMut<ClearColor>,
    mut panels: Query<&mut BackgroundColor, (With<ChromePanel>, Without<ChromeButton>)>,
    mut buttons: Query<&mut BackgroundColor, (With<ChromeButton>, Without<ChromePanel>)>,
    mut titles: Query<&mut TextColor, (With<ChromeTitle>, Without<ChromeHint>)>,
    mut hints: Query<&mut TextColor, (With<ChromeHint>, Without<ChromeTitle>)>,
) {
    if !theme.is_changed() {
        return;
    }
    clear.0 = rgb3(theme.0.clear);
    for mut bg in &mut panels {
        *bg = BackgroundColor(rgba4(theme.0.panel));
    }
    for mut bg in &mut buttons {
        *bg = BackgroundColor(rgb3(theme.0.button));
    }
    for mut color in &mut titles {
        color.0 = rgb3(theme.0.accent);
    }
    for mut color in &mut hints {
        color.0 = Color::srgba(theme.0.accent[0], theme.0.accent[1], theme.0.accent[2], 0.7);
    }
}

fn spawn_main_menu(
    mut commands: Commands,
    locale: Res<UiLocale>,
    bindings: Res<KeyBindings>,
    catalog: Res<GameCatalog>,
    selected: Res<SelectedGame>,
    theme: Res<MenuTheme>,
    p2p: Res<P2pConfig>,
) {
    let game = current_game(&catalog, &selected);
    let accent_border = Color::srgba(theme.0.accent[0], theme.0.accent[1], theme.0.accent[2], 0.45);
    commands
        .spawn((
            MenuRoot,
            Node {
                width: Val::Percent(100.0),
                height: Val::Percent(100.0),
                justify_content: JustifyContent::Center,
                align_items: AlignItems::Center,
                ..default()
            },
            BackgroundColor(Color::srgba(0.0, 0.0, 0.0, 0.22)),
        ))
        .with_children(|root| {
            root.spawn((
                ChromePanel,
                Node {
                    width: Val::Px(520.0),
                    flex_direction: FlexDirection::Column,
                    justify_content: JustifyContent::Center,
                    align_items: AlignItems::Center,
                    row_gap: Val::Px(8.0),
                    padding: UiRect::axes(Val::Px(36.0), Val::Px(28.0)),
                    border: UiRect::all(Val::Px(1.0)),
                    border_radius: BorderRadius::all(Val::Px(14.0)),
                    ..default()
                },
                BackgroundColor(rgba4(theme.0.panel)),
            ))
            .insert(BorderColor::all(accent_border))
            .with_children(|parent| {
                parent.spawn((
                    Text::new(menu_text(locale.0, "menu_title", &game, &p2p)),
                    TextFont {
                        font_size: FontSize::Px(56.0),
                        ..default()
                    },
                    TextColor(rgb3(theme.0.accent)),
                    ChromeTitle,
                    MenuLabel("menu_title"),
                ));
                parent.spawn((
                    Text::new(menu_text(locale.0, "menu_hint", &game, &p2p)),
                    TextFont {
                        font_size: FontSize::Px(16.0),
                        ..default()
                    },
                    TextColor(Color::srgba(
                        theme.0.accent[0],
                        theme.0.accent[1],
                        theme.0.accent[2],
                        0.7,
                    )),
                    ChromeHint,
                    MenuLabel("menu_hint"),
                ));
                for (action, key) in [
                    (MenuAction::Play, "menu_play"),
                    (MenuAction::Multiplayer, "menu_multiplayer"),
                    (MenuAction::Room, "menu_room"),
                    (MenuAction::Game, "menu_game"),
                    (MenuAction::Lang, "menu_lang"),
                    (MenuAction::Controls, "menu_controls"),
                    (MenuAction::Quit, "menu_quit"),
                ] {
                    parent
                        .spawn((
                            Button,
                            action,
                            ChromeButton,
                            Node {
                                width: Val::Px(440.0),
                                height: Val::Px(46.0),
                                justify_content: JustifyContent::Start,
                                align_items: AlignItems::Center,
                                padding: UiRect::horizontal(Val::Px(18.0)),
                                margin: UiRect::top(Val::Px(4.0)),
                                border: UiRect::all(Val::Px(1.0)),
                                border_radius: BorderRadius::all(Val::Px(8.0)),
                                ..default()
                            },
                            BackgroundColor(rgb3(theme.0.button)),
                        ))
                        .insert(BorderColor::all(Color::srgba(1.0, 1.0, 1.0, 0.08)))
                        .with_children(|btn| {
                            if let Some(hotkey) = menu_action_hotkey(&bindings.0, key) {
                                btn.spawn((
                                    Node {
                                        width: Val::Px(120.0),
                                        ..default()
                                    },
                                )).with_children(|container| {
                                    container.spawn((
                                        Text::new(hotkey),
                                        TextFont {
                                            font_size: FontSize::Px(16.0),
                                            ..default()
                                        },
                                        TextColor(Color::srgba(1.0, 1.0, 1.0, 0.4)),
                                        MenuHotkey(key),
                                    ));
                                });
                            }
                            btn.spawn((
                                Text::new(menu_text(locale.0, key, &game, &p2p)),
                                TextFont {
                                    font_size: FontSize::Px(20.0),
                                    ..default()
                                },
                                TextColor(Color::WHITE),
                                MenuLabel(key),
                            ));
                        });
                }
            });
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
    selected: &mut SelectedGame,
    catalog: &GameCatalog,
    p2p: &mut P2pConfig,
    exit: &mut MessageWriter<AppExit>,
) {
    match action {
        MenuAction::Play => {
            p2p.join = false;
            info!("Starting single-player ({})", selected.0);
            next.set(GameMode::Playing);
        }
        MenuAction::Multiplayer => {
            p2p.join = true;
            if p2p.url.is_none() {
                p2p.url = Some(DEFAULT_P2P_URL.to_string());
            }
            info!(
                "Starting {} with optional P2P ({})",
                selected.0,
                p2p.url.as_deref().unwrap_or(DEFAULT_P2P_URL)
            );
            next.set(GameMode::Playing);
        }
        MenuAction::Room => {
            p2p.url = cycle_p2p_url(p2p.url.as_deref());
            info!(
                "P2P room {}",
                p2p.url.as_deref().map(p2p_room_name).unwrap_or("off")
            );
        }
        MenuAction::Game => {
            selected.0 = cycle_game(&catalog.0, &selected.0);
            info!("Game {}", selected.0);
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
    mut selected: ResMut<SelectedGame>,
    catalog: Res<GameCatalog>,
    mut p2p: ResMut<P2pConfig>,
    mut exit: MessageWriter<AppExit>,
) {
    let action = if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_MENU_PLAY) {
        Some(MenuAction::Play)
    } else if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_MENU_MULTI) {
        Some(MenuAction::Multiplayer)
    } else if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_MENU_ROOM) {
        Some(MenuAction::Room)
    } else if action_just_pressed(&keys, &mouse, &bindings.0, ACTION_MENU_GAME) {
        Some(MenuAction::Game)
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
        apply_menu_action(
            action,
            &mut next,
            &mut locale,
            &mut selected,
            &catalog,
            &mut p2p,
            &mut exit,
        );
    }
}

fn menu_buttons(
    mut interaction: Query<
        (&Interaction, &MenuAction, &mut BackgroundColor),
        (Changed<Interaction>, With<Button>),
    >,
    mut next: ResMut<NextState<GameMode>>,
    mut locale: ResMut<UiLocale>,
    mut selected: ResMut<SelectedGame>,
    catalog: Res<GameCatalog>,
    theme: Res<MenuTheme>,
    mut p2p: ResMut<P2pConfig>,
    mut exit: MessageWriter<AppExit>,
) {
    for (interaction, action, mut bg) in &mut interaction {
        match *interaction {
            Interaction::Pressed => {
                apply_menu_action(
                    *action,
                    &mut next,
                    &mut locale,
                    &mut selected,
                    &catalog,
                    &mut p2p,
                    &mut exit,
                );
            }
            Interaction::Hovered => {
                *bg = BackgroundColor(rgb3(theme.0.button_hover));
            }
            Interaction::None => {
                *bg = BackgroundColor(rgb3(theme.0.button));
            }
        }
    }
}

fn refresh_menu_labels(
    locale: Res<UiLocale>,
    bindings: Res<KeyBindings>,
    catalog: Res<GameCatalog>,
    selected: Res<SelectedGame>,
    p2p: Res<P2pConfig>,
    mut labels: Query<(&MenuLabel, &mut Text), Without<MenuHotkey>>,
    mut hotkeys: Query<(&MenuHotkey, &mut Text), Without<MenuLabel>>,
) {
    if !locale.is_changed() && !bindings.is_changed() && !selected.is_changed() && !p2p.is_changed()
    {
        return;
    }
    let game = current_game(&catalog, &selected);
    for (label, mut text) in &mut labels {
        *text = Text::new(menu_text(locale.0, label.0, &game, &p2p));
    }
    for (hotkey, mut text) in &mut hotkeys {
        if let Some(h) = menu_action_hotkey(&bindings.0, hotkey.0) {
            *text = Text::new(h);
        }
    }
}

fn spawn_controls_menu(
    mut commands: Commands,
    locale: Res<UiLocale>,
    bindings: Res<KeyBindings>,
    theme: Res<MenuTheme>,
) {
    commands
        .spawn((
            ControlsRoot,
            ChromePanel,
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
            BackgroundColor(rgba4(theme.0.panel)),
        ))
        .with_children(|parent| {
            parent.spawn((
                Text::new(i18n::t(locale.0, "controls_title")),
                TextFont {
                    font_size: FontSize::Px(40.0),
                    ..default()
                },
                TextColor(rgb3(theme.0.accent)),
                ChromeTitle,
            ));
            parent.spawn((
                ControlsHintText,
                ChromeHint,
                Text::new(i18n::t(locale.0, "controls_hint")),
                TextFont {
                    font_size: FontSize::Px(14.0),
                    ..default()
                },
                TextColor(Color::srgba(theme.0.accent[0], theme.0.accent[1], theme.0.accent[2], 0.7)),
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
                            ChromeButton,
                            Node {
                                width: Val::Percent(100.0),
                                height: Val::Px(32.0),
                                justify_content: JustifyContent::SpaceBetween,
                                align_items: AlignItems::Center,
                                padding: UiRect::horizontal(Val::Px(10.0)),
                                ..default()
                            },
                            BackgroundColor(rgb3(theme.0.button)),
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
                    ChromeButton,
                    Node {
                        width: Val::Px(220.0),
                        height: Val::Px(40.0),
                        justify_content: JustifyContent::Center,
                        align_items: AlignItems::Center,
                        margin: UiRect::top(Val::Px(8.0)),
                        ..default()
                    },
                    BackgroundColor(rgb3(theme.0.button)),
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
    theme: Res<MenuTheme>,
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
                *bg = BackgroundColor(rgb3(theme.0.button_hover));
            }
            Interaction::None => {
                *bg = BackgroundColor(rgb3(theme.0.button));
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

    #[test]
    fn kani_replay_possible_action_stays_inside_axes() {
        let max = 10.0;
        for (px, py, pz, tx, ty, tz) in [
            (0.0, 0.0, 0.0, 3.0, 4.0, 0.0),
            (0.0, 0.0, 0.0, 10.0, 0.0, 0.0),
            (5.0, -2.0, 1.0, 5.0, 7.0, 1.0),
            (0.0, 0.0, 0.0, 7.0, 7.0, 7.0),
        ] {
            if is_action_physically_possible(px, py, pz, tx, ty, tz, max) {
                assert!((px - tx).abs() <= max);
                assert!((py - ty).abs() <= max);
                assert!((pz - tz).abs() <= max);
            }
        }
    }
}

fn nearest_vehicle(
    player_pos: Vec3,
    vehicles: &Query<(Entity, &Transform), (With<Vehicle>, Without<Player>, Without<Wrecked>)>,
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
    let reply = mod_runtime.ask_any(
        "voxel-label",
        &wire_bag(vec![
            ("voxel", Wire::Text(voxel.clone())),
            ("locale", Wire::Text(locale.code().to_string())),
        ]),
    );
    let raw = if wire_is_fail(&reply) {
        voxel.clone()
    } else {
        let text = wire_as_text(&reply);
        if text.is_empty() {
            "unknown".into()
        } else {
            text
        }
    };
    (voxel_pos, voxel, raw)
}

fn mod_contract_name(mod_runtime: &ModRuntime, locale: Locale, kind: &str) -> String {
    if kind.is_empty() {
        return i18n::t(locale, "job_none").to_string();
    }
    let name = mod_runtime.ask_any_text(
        "contract-label",
        &wire_bag(vec![
            ("kind", Wire::Text(kind.to_string())),
            ("locale", Wire::Text(locale.code().to_string())),
        ]),
    );
    if name.is_empty() {
        kind.to_string()
    } else {
        name
    }
}

fn mod_item_label(mod_runtime: &ModRuntime, locale: Locale, item: &str) -> String {
    if item.is_empty() {
        return String::new();
    }
    let name = mod_runtime.ask_any_text(
        "item-label",
        &wire_bag(vec![
            ("item", Wire::Text(item.to_string())),
            ("locale", Wire::Text(locale.code().to_string())),
        ]),
    );
    if name.is_empty() {
        item.to_string()
    } else {
        name
    }
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
    accept_bind: Option<&str>,
) -> String {
    let job = if contract_is_offered(&contract.kind) {
        let name = mod_contract_name(mod_runtime, locale, &contract.kind);
        i18n::format_job_active(locale, &name, contract.payout, contract.danger)
    } else if contract_is_offered(&offer.kind) {
        let name = mod_contract_name(mod_runtime, locale, &offer.kind);
        match accept_bind {
            Some(bind) => i18n::format_job_offer_bind(locale, &name, offer.payout, offer.danger, bind),
            None => i18n::format_job_offer(locale, &name, offer.payout, offer.danger),
        }
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
    vehicles: Query<(Entity, &Transform), (With<Vehicle>, Without<Player>, Without<Wrecked>)>,
    voxel_world: VoxelWorld<DefaultWorld>,
    catalog: Res<VoxelCatalog>,
    mod_runtime: Res<ModRuntime>,
    offer: Res<ModOffer>,
    gravity: Res<WorldGravity>,
    mut locale: ResMut<UiLocale>,
    mut events: MessageWriter<ProposedAction>,
) {
    if let Ok(rx) = receiver.rx.lock() {
        while let Ok(line) = rx.try_recv() {
            match i18n::parse_text_command(&line) {
                TextCommand::MoveForward => {
                    if let Some((_, transform, mut velocity, _, _, _, _)) = query.iter_mut().next() {
                        apply_wish(
                            &mut velocity,
                            *transform.forward(),
                            gravity.0.walk,
                            &gravity.0,
                            transform.translation,
                        );
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
                            let product = mod_runtime.ask_any_text(
                                "craft-result",
                                &wire_bag(vec![
                                    ("a", Wire::Text(a.clone())),
                                    ("b", Wire::Text(b.clone())),
                                ]),
                            );
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
                            None,
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
    vehicles: Query<(Entity, &Transform), (With<Vehicle>, Without<Player>, Without<Wrecked>)>,
    voxel_world: VoxelWorld<DefaultWorld>,
    catalog: Res<VoxelCatalog>,
    mod_runtime: Res<ModRuntime>,
    offer: Res<ModOffer>,
    gravity: Res<WorldGravity>,
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
                            apply_wish(
                                &mut velocity,
                                *transform.forward(),
                                gravity.0.walk,
                                &gravity.0,
                                transform.translation,
                            );
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
