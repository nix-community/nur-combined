use std::{
    collections::HashSet,
    io,
    path::PathBuf,
    sync::{
        mpsc::{Receiver, TryRecvError},
        Arc, Mutex,
    },
};

use abi_stable::std_types::{RBoxError, RResult, RString, RVec};
use notify::{Event, RecommendedWatcher, RecursiveMode, Watcher};
use steel::{
    rvals::Custom,
    steel_vm::ffi::{FFIModule, FFIValue, IntoFFIVal, RegisterFFIFn},
};

steel::declare_module!(build_module);

fn file_watcher_module() -> FFIModule {
    let mut module = FFIModule::new("steel/file-watcher");

    module
        .register_fn("receive-paths!", EventReceiver::recv_paths)
        .register_fn("make-empty-watcher", spawn_empty_watcher)
        .register_fn("watch-controller", EventReceiver::controller)
        .register_fn("set-watched-files!", WatchController::set_watched_files);

    module
}

struct EventReceiver {
    inner: Arc<WatcherInner>,
}

struct WatchController {
    inner: Arc<WatcherInner>,
}

struct WatcherInner {
    watcher: Mutex<RecommendedWatcher>,
    receiver: Mutex<Receiver<Event>>,
    watched_paths: Arc<Mutex<HashSet<PathBuf>>>,
    watched_dirs: Mutex<HashSet<PathBuf>>,
}

impl Custom for EventReceiver {}
impl Custom for WatchController {}

impl EventReceiver {
    fn controller(&self) -> FFIValue {
        WatchController {
            inner: Arc::clone(&self.inner),
        }
        .into_ffi_val()
        .unwrap()
    }

    // Poll on the editor thread. An empty event queue must not block callbacks.
    fn recv_paths(&self) -> RResult<FFIValue, RBoxError> {
        let receiver = self.inner.receiver.lock().unwrap();
        let first = match receiver.try_recv() {
            Ok(event) => event,
            Err(TryRecvError::Empty) => return RResult::ROk(FFIValue::BoolV(false)),
            Err(TryRecvError::Disconnected) => {
                return RResult::RErr(RBoxError::new(io::Error::new(
                    io::ErrorKind::BrokenPipe,
                    "file watcher event channel disconnected",
                )));
            }
        };

        self.collect_paths_from(first, &receiver)
    }

    fn collect_paths_from(
        &self,
        first: Event,
        receiver: &Receiver<Event>,
    ) -> RResult<FFIValue, RBoxError> {
        let mut paths = HashSet::new();
        collect_event_paths(first, &mut paths);

        // Drain whatever else is already queued without blocking.
        loop {
            match receiver.try_recv() {
                Ok(event) => collect_event_paths(event, &mut paths),
                Err(TryRecvError::Empty) => break,
                Err(TryRecvError::Disconnected) => {
                    return RResult::RErr(RBoxError::new(io::Error::new(
                        io::ErrorKind::BrokenPipe,
                        "file watcher event channel disconnected",
                    )));
                }
            }
        }

        let paths: RVec<FFIValue> = paths
            .into_iter()
            .filter_map(|path| path.into_os_string().into_string().ok())
            .map(|path| FFIValue::StringV(RString::from(path)))
            .collect();

        RResult::ROk(paths.into_ffi_val().unwrap())
    }
}

impl WatchController {
    fn set_watched_files(&self, paths: Vec<String>) -> RResult<FFIValue, RBoxError> {
        let next_paths: HashSet<PathBuf> = paths
            .iter()
            .map(|path| canonicalize_or_path(path))
            .collect();
        {
            let mut watched_paths = self.inner.watched_paths.lock().unwrap();
            *watched_paths = next_paths;
        }
        match self.reconcile_watched_dirs() {
            Ok(()) => RResult::ROk(FFIValue::BoolV(true)),
            Err(err) => RResult::RErr(RBoxError::new(err)),
        }
    }

    fn reconcile_watched_dirs(&self) -> notify::Result<()> {
        let next_dirs: HashSet<PathBuf> = self
            .inner
            .watched_paths
            .lock()
            .unwrap()
            .iter()
            .filter_map(|path| path.parent().map(PathBuf::from))
            .collect();

        let mut watched_dirs = self.inner.watched_dirs.lock().unwrap();
        let mut watcher = self.inner.watcher.lock().unwrap();

        for dir in next_dirs.difference(&watched_dirs) {
            watcher.watch(dir, RecursiveMode::NonRecursive)?;
        }

        for dir in watched_dirs.difference(&next_dirs) {
            watcher.unwatch(dir)?;
        }

        *watched_dirs = next_dirs;
        Ok(())
    }
}

fn collect_event_paths(event: Event, paths: &mut HashSet<PathBuf>) {
    paths.extend(event.paths.into_iter().filter_map(|path| {
        if path.exists() {
            path.canonicalize().ok()
        } else {
            Some(path)
        }
    }));
}

fn spawn_empty_watcher() -> FFIValue {
    let (sender, receiver) = std::sync::mpsc::channel();
    let watched_paths = Arc::new(Mutex::new(HashSet::new()));
    let watched_paths_for_events = Arc::clone(&watched_paths);

    let watcher = notify::recommended_watcher(move |event: Result<Event, _>| {
        if let Ok(mut event) = event {
            if is_watched_file_event(&event)
                && retain_watched_paths(&mut event, &watched_paths_for_events.lock().unwrap())
            {
                let _ = sender.send(event);
            }
        }
    })
    .unwrap();

    EventReceiver {
        inner: Arc::new(WatcherInner {
            watcher: Mutex::new(watcher),
            receiver: Mutex::new(receiver),
            watched_paths,
            watched_dirs: Mutex::new(HashSet::new()),
        }),
    }
    .into_ffi_val()
    .unwrap()
}

fn is_watched_file_event(event: &Event) -> bool {
    matches!(
        event.kind,
        notify::EventKind::Create(_) | notify::EventKind::Modify(_) | notify::EventKind::Remove(_)
    )
}

fn retain_watched_paths(event: &mut Event, watched_paths: &HashSet<PathBuf>) -> bool {
    event.paths.retain(|path| {
        watched_paths.contains(path) || canonicalized_is_watched(path, watched_paths)
    });
    !event.paths.is_empty()
}

fn canonicalized_is_watched(path: &PathBuf, watched_paths: &HashSet<PathBuf>) -> bool {
    match path.canonicalize() {
        Ok(path) => watched_paths.contains(&path),
        Err(_) => false,
    }
}

fn canonicalize_or_path(path: &str) -> PathBuf {
    let path = PathBuf::from(path);
    path.canonicalize().unwrap_or(path)
}

pub fn build_module() -> FFIModule {
    file_watcher_module()
}
