use wasmtime::{Engine, Config, Store};
use wasmtime::component::{Component, Linker};
use bevy::prelude::*;
use std::sync::{Arc, Mutex, RwLock};
use std::path::{Path, PathBuf};
use notify::{Watcher, RecursiveMode, Event};
use crossbeam_channel::{unbounded, Receiver};

wasmtime::component::bindgen!({
    world: "plugin",
    path: "wit",
});

/// Global reference so that worker threads (like terrain generation) can 
/// instantiate their own stateless WASM instances for fast concurrent access.
pub static SHARED_WASM: RwLock<Option<(Engine, Component)>> = RwLock::new(None);

/// A persistent WASM context that holds the main Store and Instance.
/// Used by the main thread for game logic, preserving global mod state 
/// (e.g. static variables) between game ticks.
pub struct MainModContext {
    pub store: Store<()>,
    pub bindings: Plugin,
}

#[derive(Resource)]
pub struct ModRuntime {
    pub context: Arc<Mutex<Option<MainModContext>>>,
    pub rx: Receiver<Event>,
    pub watch_path: PathBuf,
    // we must hold the watcher to keep it alive
    _watcher: notify::RecommendedWatcher,
}

impl ModRuntime {
    pub fn new(wasm_path: &Path) -> Self {
        let (tx, rx) = unbounded();
        
        let watch_dir = wasm_path.parent().unwrap().to_path_buf();
        let watch_path = wasm_path.to_path_buf();
        
        // Setup watcher
        let mut watcher = notify::recommended_watcher(move |res: notify::Result<Event>| {
            if let Ok(event) = res {
                let _ = tx.send(event);
            }
        }).unwrap();
        
        let _ = watcher.watch(&watch_dir, RecursiveMode::NonRecursive);

        let context = Arc::new(Mutex::new(Self::load_mod(&watch_path)));

        Self {
            context,
            rx,
            watch_path,
            _watcher: watcher,
        }
    }

    fn load_mod(path: &Path) -> Option<MainModContext> {
        let mut config = Config::new();
        config.wasm_multi_memory(true);
        config.wasm_component_model(true);
        let engine = Engine::new(&config).ok()?;
        let component = Component::from_file(&engine, path).ok()?;
        
        // Update the global reference for worker threads
        if let Ok(mut shared) = SHARED_WASM.write() {
            *shared = Some((engine.clone(), component.clone()));
        }
        
        let mut store = Store::new(&engine, ());
        let linker = Linker::new(&engine);
        let bindings = Plugin::instantiate(&mut store, &component, &linker).ok()?;
        
        // Call init_mod
        let _ = bindings.hanga_engine_gameplay().call_init_mod(&mut store);
        
        Some(MainModContext { store, bindings })
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

fn watch_mod_changes(mut runtime: ResMut<ModRuntime>) {
    let mut changed = false;
    while let Ok(event) = runtime.rx.try_recv() {
        if event.kind.is_modify() || event.kind.is_create() {
            for path in event.paths {
                if path.extension().map_or(false, |ext| ext == "wasm") {
                    changed = true;
                }
            }
        }
    }
    
    if changed {
        info!("Reloading WASM mod...");
        let new_context = ModRuntime::load_mod(&runtime.watch_path);
        if new_context.is_some() {
            let mut ctx_lock = runtime.context.lock().unwrap();
            *ctx_lock = new_context;
            info!("WASM mod reloaded successfully!");
        } else {
            error!("Failed to reload WASM mod");
        }
    }
}
