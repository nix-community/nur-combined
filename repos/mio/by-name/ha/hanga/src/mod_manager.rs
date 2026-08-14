use wasmtime::{Engine, Config, Store};
use wasmtime::component::{Component, Linker};
use bevy::prelude::*;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex, RwLock};
use std::path::{Path, PathBuf};
use notify::{Watcher, RecursiveMode, Event};
use crossbeam_channel::{unbounded, Receiver};

static WASM_GEN: AtomicU64 = AtomicU64::new(0);

wasmtime::component::bindgen!({
    world: "plugin",
    path: "wit",
});

/// Global reference so that worker threads (like terrain generation) can
/// instantiate their own stateless WASM instances for fast concurrent access.
/// Always the **lead** mod of the current game.
pub static SHARED_WASM: RwLock<Option<(u64, Engine, Component)>> = RwLock::new(None);

/// A persistent WASM context that holds the main Store and Instance.
/// Used by the main thread for game logic, preserving global mod state
/// (e.g. static variables) between game ticks.
pub struct MainModContext {
    pub store: Store<()>,
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

        let context = Arc::new(Mutex::new(Self::load_mod(&watch_path, true)));

        Self {
            context,
            packs: Vec::new(),
            rx,
            watch_path: watch_path.clone(),
            loaded_paths: vec![watch_path],
            _watcher: watcher,
        }
    }

    fn load_mod(path: &Path, publish_shared: bool) -> Option<MainModContext> {
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

        let mut store = Store::new(&engine, ());
        let linker = Linker::new(&engine);
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
        self.watch_path = lead_path.clone();
        self.loaded_paths = paths;
        let lead = Self::load_mod(lead_path, true);
        if let Ok(mut ctx) = self.context.lock() {
            *ctx = lead;
        }
        self.packs = mods[1..]
            .iter()
            .map(|(name, path)| {
                info!("Loading pack '{name}' from {}", path.display());
                PackMod {
                    name: name.clone(),
                    path: path.clone(),
                    context: Arc::new(Mutex::new(Self::load_mod(path, false))),
                }
            })
            .collect();
        if !lead_name.is_empty() {
            info!(
                "Game collection lead '{lead_name}' plus {} pack(s)",
                self.packs.len()
            );
        }
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
    let new_context = ModRuntime::load_mod(&runtime.watch_path, true);
    if new_context.is_some() {
        let mut ctx_lock = runtime.context.lock().unwrap();
        *ctx_lock = new_context;
        info!("Lead WASM reloaded successfully!");
    } else {
        error!("Failed to reload lead WASM mod");
    }
    for pack in &runtime.packs {
        let reloaded = ModRuntime::load_mod(&pack.path, false);
        if let Ok(mut ctx) = pack.context.lock() {
            *ctx = reloaded;
        }
    }
}
