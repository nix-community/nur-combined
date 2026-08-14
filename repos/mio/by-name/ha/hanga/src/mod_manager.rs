use wasmtime::{Engine, Config, Store};
use wasmtime::component::{Component, HasSelf, Linker};
use bevy::prelude::*;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex, RwLock};
use std::path::{Path, PathBuf};
use std::time::Instant;
use notify::{Watcher, RecursiveMode, Event};
use crossbeam_channel::{unbounded, Receiver};

static WASM_GEN: AtomicU64 = AtomicU64::new(0);
static HOST_START: std::sync::OnceLock<Instant> = std::sync::OnceLock::new();

wasmtime::component::bindgen!({
    world: "plugin",
    path: "wit",
});

/// Global reference so that worker threads (like terrain generation) can
/// instantiate their own stateless WASM instances for fast concurrent access.
/// Always the **lead** mod of the current game.
pub static SHARED_WASM: RwLock<Option<(u64, Engine, Component)>> = RwLock::new(None);

pub fn host_now_ms() -> i64 {
    HOST_START
        .get_or_init(Instant::now)
        .elapsed()
        .as_millis()
        .min(i64::MAX as u128) as i64
}

pub fn noop_host(name: impl Into<String>) -> HostData {
    HostData {
        name: name.into(),
        bus: Arc::new(NoopBus),
    }
}

pub struct HostData {
    pub name: String,
    pub bus: Arc<dyn EngineBus>,
}

pub trait EngineBus: Send + Sync {
    fn log(&self, from: &str, level: &str, message: &str);
    fn peers(&self, from: &str) -> String;
    fn ask(&self, from: &str, peer: &str, topic: &str, payload: &str) -> String;
}

pub struct NoopBus;

impl EngineBus for NoopBus {
    fn log(&self, from: &str, level: &str, message: &str) {
        match level {
            "error" => error!("[{from}] {message}"),
            "warn" => warn!("[{from}] {message}"),
            "debug" | "trace" => debug!("[{from}] {message}"),
            _ => info!("[{from}] {message}"),
        }
    }

    fn peers(&self, _from: &str) -> String {
        String::new()
    }

    fn ask(&self, _from: &str, _peer: &str, _topic: &str, _payload: &str) -> String {
        String::new()
    }
}

struct LiveBus {
    lead_name: String,
    lead: Arc<Mutex<Option<MainModContext>>>,
    packs: Vec<(String, Arc<Mutex<Option<MainModContext>>>)>,
}

impl EngineBus for LiveBus {
    fn log(&self, from: &str, level: &str, message: &str) {
        NoopBus.log(from, level, message);
    }

    fn peers(&self, from: &str) -> String {
        let mut names = Vec::new();
        if self.lead_name != from && !self.lead_name.is_empty() {
            names.push(self.lead_name.clone());
        }
        for (name, _) in &self.packs {
            if name != from {
                names.push(name.clone());
            }
        }
        names.join(",")
    }

    fn ask(&self, from: &str, peer: &str, topic: &str, payload: &str) -> String {
        if peer.is_empty() {
            let mut reply = String::new();
            if self.lead_name != from {
                reply = deliver(&self.lead, from, topic, payload);
            }
            if !reply.is_empty() {
                return reply;
            }
            for (name, ctx) in &self.packs {
                if name == from {
                    continue;
                }
                reply = deliver(ctx, from, topic, payload);
                if !reply.is_empty() {
                    return reply;
                }
            }
            return String::new();
        }
        if peer == from {
            return String::new();
        }
        if peer == self.lead_name {
            return deliver(&self.lead, from, topic, payload);
        }
        for (name, ctx) in &self.packs {
            if name == peer {
                return deliver(ctx, from, topic, payload);
            }
        }
        String::new()
    }
}

fn deliver(
    slot: &Mutex<Option<MainModContext>>,
    from: &str,
    topic: &str,
    payload: &str,
) -> String {
    let Ok(mut guard) = slot.try_lock() else {
        return String::new();
    };
    let Some(ctx) = guard.as_mut() else {
        return String::new();
    };
    ctx.bindings
        .hanga_engine_gameplay()
        .call_on_message(&mut ctx.store, from, topic, payload)
        .unwrap_or_default()
}

impl hanga::engine::host::Host for HostData {
    fn log(&mut self, level: String, message: String) {
        self.bus.log(&self.name, &level, &message);
    }

    fn now_ms(&mut self) -> i64 {
        host_now_ms()
    }

    fn self_name(&mut self) -> String {
        self.name.clone()
    }

    fn peers(&mut self) -> String {
        self.bus.peers(&self.name)
    }

    fn ask(&mut self, peer: String, topic: String, payload: String) -> String {
        self.bus.ask(&self.name, &peer, &topic, &payload)
    }
}

/// A persistent WASM context that holds the main Store and Instance.
/// Used by the main thread for game logic, preserving global mod state
/// (e.g. static variables) between game ticks.
pub struct MainModContext {
    pub store: Store<HostData>,
    pub bindings: Plugin,
}

pub struct PackMod {
    pub name: String,
    pub path: PathBuf,
    pub context: Arc<Mutex<Option<MainModContext>>>,
}

#[derive(Resource)]
pub struct ModRuntime {
    pub context: Arc<Mutex<Option<MainModContext>>>,
    pub packs: Vec<PackMod>,
    pub rx: Receiver<Event>,
    pub watch_path: PathBuf,
    lead_name: String,
    bus: Arc<dyn EngineBus>,
    loaded_paths: Vec<PathBuf>,
    _watcher: notify::RecommendedWatcher,
}

impl ModRuntime {
    pub fn new(wasm_path: &Path) -> Self {
        let (tx, rx) = unbounded();

        let watch_dir = wasm_path
            .parent()
            .map(Path::to_path_buf)
            .unwrap_or_else(|| PathBuf::from("."));
        let watch_path = wasm_path.to_path_buf();

        let mut watcher = notify::recommended_watcher(move |res: notify::Result<Event>| {
            if let Ok(event) = res {
                let _ = tx.send(event);
            }
        })
        .unwrap();

        let _ = watcher.watch(&watch_dir, RecursiveMode::NonRecursive);

        let lead_name = wasm_path
            .file_stem()
            .and_then(|s| s.to_str())
            .unwrap_or("mod")
            .to_string();
        let context = Arc::new(Mutex::new(None));
        let bus: Arc<dyn EngineBus> = Arc::new(LiveBus {
            lead_name: lead_name.clone(),
            lead: Arc::clone(&context),
            packs: Vec::new(),
        });
        *context.lock().unwrap() = Self::instantiate(&watch_path, &lead_name, Arc::clone(&bus), true);

        Self {
            context,
            packs: Vec::new(),
            rx,
            watch_path: watch_path.clone(),
            lead_name,
            bus,
            loaded_paths: vec![watch_path],
            _watcher: watcher,
        }
    }

    pub fn instantiate(
        path: &Path,
        name: &str,
        bus: Arc<dyn EngineBus>,
        publish_shared: bool,
    ) -> Option<MainModContext> {
        if !path.is_file() {
            error!("WASM mod file missing: {}", path.display());
            return None;
        }
        let mut config = Config::new();
        config.wasm_multi_memory(true);
        config.wasm_component_model(true);
        let engine = Engine::new(&config).ok()?;
        let component = match Component::from_file(&engine, path) {
            Ok(component) => component,
            Err(err) => {
                error!("Failed to load WASM component {}: {err}", path.display());
                return None;
            }
        };

        if publish_shared {
            let rev = WASM_GEN.fetch_add(1, Ordering::Relaxed) + 1;
            if let Ok(mut shared) = SHARED_WASM.write() {
                *shared = Some((rev, engine.clone(), component.clone()));
            }
        }

        let mut store = Store::new(
            &engine,
            HostData {
                name: name.to_string(),
                bus,
            },
        );
        let mut linker = Linker::new(&engine);
        Plugin::add_to_linker::<HostData, HasSelf<_>>(&mut linker, |data| data).ok()?;
        let bindings = Plugin::instantiate(&mut store, &component, &linker).ok()?;

        let _ = bindings.hanga_engine_gameplay().call_init_mod(&mut store);

        Some(MainModContext { store, bindings })
    }

    /// Load another `.wasm` as the lead (same mods directory is already watched).
    pub fn load_spec(&mut self, path: &Path) {
        self.load_collection(&[("".to_string(), path.to_path_buf())]);
    }

    /// Lead is `mods[0]` (terrain + gameplay). Later entries are packs (vehicles, agents, extra voxels).
    pub fn load_collection(&mut self, mods: &[(String, PathBuf)]) {
        if mods.is_empty() {
            return;
        }
        let paths: Vec<PathBuf> = mods.iter().map(|(_, path)| path.clone()).collect();
        if self.loaded_paths == paths {
            if let Ok(ctx) = self.context.lock() {
                if ctx.is_some() {
                    return;
                }
            }
        }
        let (lead_name, lead_path) = &mods[0];
        let lead_name = if lead_name.is_empty() {
            lead_path
                .file_stem()
                .and_then(|s| s.to_str())
                .unwrap_or("mod")
                .to_string()
        } else {
            lead_name.clone()
        };
        self.watch_path = lead_path.clone();
        self.loaded_paths = paths;
        self.lead_name = lead_name.clone();

        let pack_slots: Vec<(String, PathBuf, Arc<Mutex<Option<MainModContext>>>)> = mods[1..]
            .iter()
            .map(|(name, path)| {
                (
                    name.clone(),
                    path.clone(),
                    Arc::new(Mutex::new(None)),
                )
            })
            .collect();
        let bus: Arc<dyn EngineBus> = Arc::new(LiveBus {
            lead_name: lead_name.clone(),
            lead: Arc::clone(&self.context),
            packs: pack_slots
                .iter()
                .map(|(name, _, ctx)| (name.clone(), Arc::clone(ctx)))
                .collect(),
        });
        self.bus = Arc::clone(&bus);

        let lead = Self::instantiate(lead_path, &lead_name, Arc::clone(&bus), true);
        if let Ok(mut ctx) = self.context.lock() {
            *ctx = lead;
        }
        self.packs = pack_slots
            .into_iter()
            .map(|(name, path, context)| {
                info!("Loading pack '{name}' from {}", path.display());
                *context.lock().unwrap() =
                    Self::instantiate(&path, &name, Arc::clone(&bus), false);
                PackMod {
                    name,
                    path,
                    context,
                }
            })
            .collect();
        info!(
            "Game collection lead '{lead_name}' plus {} pack(s)",
            self.packs.len()
        );
    }
}

pub struct ModManagerPlugin {
    pub wasm_path: String,
}

impl bevy::app::Plugin for ModManagerPlugin {
    fn build(&self, app: &mut App) {
        let runtime = ModRuntime::new(Path::new(&self.wasm_path));
        app.insert_resource(runtime);
        app.add_systems(Update, watch_mod_changes);
    }
}

fn watch_mod_changes(runtime: ResMut<ModRuntime>) {
    let mut changed = false;
    while let Ok(event) = runtime.rx.try_recv() {
        if event.kind.is_modify() || event.kind.is_create() {
            for path in event.paths {
                if path.extension().is_some_and(|ext| ext == "wasm") {
                    changed = true;
                }
            }
        }
    }

    if !changed {
        return;
    }
    info!("Reloading WASM collection...");
    let bus = Arc::clone(&runtime.bus);
    let new_context = ModRuntime::instantiate(
        &runtime.watch_path,
        &runtime.lead_name,
        Arc::clone(&bus),
        true,
    );
    if new_context.is_some() {
        let mut ctx_lock = runtime.context.lock().unwrap();
        *ctx_lock = new_context;
        info!("Lead WASM reloaded successfully!");
    } else {
        error!("Failed to reload lead WASM mod");
    }
    for pack in &runtime.packs {
        let reloaded = ModRuntime::instantiate(&pack.path, &pack.name, Arc::clone(&bus), false);
        if let Ok(mut ctx) = pack.context.lock() {
            *ctx = reloaded;
        }
    }
}
