use crate::*;
use serde::Deserialize;
use std::{
    fs,
    os::unix::{ffi::OsStrExt, fs::PermissionsExt},
};

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Plugin {
    pub id: String,
    pub name: String,
    pub version: String,
    pub author: String,
    pub description: String,
    pub source: String,
    pub artifact: String,
    pub sha256: String,
    #[serde(default)]
    pub mode: extensions::Mode,
}
#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct Catalog {
    schema_version: u32,
    plugins: Vec<Plugin>,
}
pub fn catalog_path() -> Option<PathBuf> {
    let installed = std::env::current_exe()
        .ok()
        .and_then(|p| p.parent().map(|p| p.join("community-plugins.toml")));
    [
        Some(core::data_dir().join("community-plugins.toml")),
        installed,
    ]
    .into_iter()
    .flatten()
    .find(|p| p.is_file())
}
pub fn catalog() -> Result<Vec<Plugin>, String> {
    let text = if let Some(path) = catalog_path() {
        if fs::metadata(&path).map_err(|e| e.to_string())?.len() > 262144 {
            return Err("Plugin catalog exceeds 256 KiB".into());
        }
        fs::read_to_string(path).map_err(|e| e.to_string())?
    } else {
        include_str!("../docs/community-plugins.toml").into()
    };
    let json = boosters::run_input(
        Command::new("python3").args([
            "-c",
            "import sys,tomllib,json; print(json.dumps(tomllib.loads(sys.stdin.read(262145))))",
        ]),
        4,
        Some(text.as_bytes()),
    )
    .map_err(|_| "Could not parse plugin catalog · requires Python 3.11+ and valid TOML")?;
    let catalog: Catalog =
        serde_json::from_str(&json).map_err(|e| format!("Invalid plugin catalog: {e}"))?;
    if catalog.schema_version != 1 || catalog.plugins.len() > 100 {
        return Err("Use catalog schema 1 and at most 100 plugins".into());
    }
    let mut ids = std::collections::HashSet::new();
    for p in &catalog.plugins {
        p.validate()?;
        if !ids.insert(&p.id) {
            return Err("Duplicate plugin catalog ID".into());
        }
    }
    Ok(catalog.plugins)
}
fn github_url(url: &str, release: bool) -> bool {
    let Some(path) = url.strip_prefix("https://github.com/") else {
        return false;
    };
    let parts: Vec<_> = path.split('/').collect();
    !url.chars().any(|c| c.is_whitespace() || c.is_control())
        && !url.contains(['?', '#', '\\', '%'])
        && parts.len() >= 2
        && parts.iter().all(|p| {
            !p.is_empty()
                && *p != "."
                && *p != ".."
                && p.bytes()
                    .all(|c| c.is_ascii_alphanumeric() || b"-_.+".contains(&c))
        })
        && (!release
            || (parts.len() == 6
                && parts[2] == "releases"
                && parts[3] == "download"
                && parts[5].ends_with(".wasm")))
}
impl Plugin {
    pub fn validate(&self) -> Result<(), String> {
        if self.id.is_empty()
            || self.id.len() > 64
            || !self
                .id
                .bytes()
                .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == b'-')
            || self.id.starts_with('-')
        {
            return Err("Invalid catalog plugin ID".into());
        }
        if self.name.is_empty()
            || self.name.len() > 160
            || self.description.len() > 1024
            || self.author.is_empty()
            || self.author.len() > 160
            || self.version.is_empty()
            || self.version.len() > 80
            || [&self.name, &self.description, &self.author, &self.version]
                .iter()
                .any(|v| v.chars().any(char::is_control))
        {
            return Err("Invalid catalog plugin metadata".into());
        }
        if !github_url(&self.source, false)
            || !(self.artifact == "bundled:text-tools" || github_url(&self.artifact, true))
            || self.sha256.len() != 64
            || !self.sha256.bytes().all(|c| c.is_ascii_hexdigit())
        {
            return Err("Plugins require a GitHub source, a pinned GitHub release .wasm URL, and a SHA-256 digest".into());
        }
        Ok(())
    }
    pub fn installed(&self) -> bool {
        core::data_dir().join("plugins").join(&self.id).exists()
    }
}
pub fn entries(filter: &str) -> Result<Vec<boosters::Entry>, String> {
    let mut result = Vec::new();
    for p in catalog()? {
        if core::score(
            filter,
            &format!("{} {} {}", p.name, p.description, p.author),
        )
        .is_some()
        {
            result.push(boosters::entry(
                p.name.clone(),
                format!(
                    "{} · {} · {}",
                    p.version,
                    p.author,
                    if p.installed() {
                        "Installed"
                    } else if p.artifact.starts_with("bundled:") {
                        "Bundled example"
                    } else {
                        "Community · GitHub release"
                    }
                ),
                "Store",
                boosters::Operation::Productivity(crate::productivity::Operation::Plugin(p)),
            ));
        }
    }
    if result.is_empty() {
        result.push(boosters::hint(
            "No matching catalog plugins",
            "Add compatible community releases to the local community-plugins.toml catalog",
        ));
    }
    Ok(result)
}
pub fn install(plugin: &Plugin) -> Result<(), String> {
    plugin.validate()?;
    if plugin.installed() {
        return Err(
            "That plugin ID already exists · existing plugins are never overwritten".into(),
        );
    }
    let bytes = if plugin.artifact == "bundled:text-tools" {
        include_bytes!("../assets/store/text-tools.wasm").to_vec()
    } else {
        let runtime = core::data_dir().join("runtime");
        fs::create_dir_all(&runtime).map_err(|e| e.to_string())?;
        let temporary = runtime.join(format!("store-download-{}", glib::uuid_string_random()));
        fs::create_dir(&temporary).map_err(|e| e.to_string())?;
        fs::set_permissions(&temporary, fs::Permissions::from_mode(0o700))
            .map_err(|e| e.to_string())?;
        let target = temporary.join("module.wasm");
        let result = (|| {
            boosters::run(
                Command::new("python3")
                    .args(["-c", include_str!("store_download.py"), &plugin.artifact])
                    .arg(&target),
                40,
            )?;
            if fs::metadata(&target).map_err(|e| e.to_string())?.len()
                > wasmplugins::MODULE_LIMIT as u64
            {
                return Err("Plugin module exceeds 4 MiB".into());
            }
            fs::read(&target).map_err(|e| e.to_string())
        })();
        let _ = fs::remove_file(&target);
        let _ = fs::remove_dir(&temporary);
        result?
    };
    if bytes.len() > wasmplugins::MODULE_LIMIT || !bytes.starts_with(b"\0asm") {
        return Err("Expected a binary WASM module, at most 4 MiB".into());
    }
    let digest = glib::compute_checksum_for_data(glib::ChecksumType::Sha256, &bytes)
        .ok_or("Could not hash plugin")?;
    if !digest.eq_ignore_ascii_case(&plugin.sha256) {
        return Err("Plugin checksum does not match the catalog".into());
    }
    let engine = wasmi::Engine::default();
    let module = wasmi::Module::new(&engine, &bytes).map_err(|e| format!("Invalid WASM: {e}"))?;
    if module.imports().any(|i| {
        i.module() != "spotlight" || !["request_len", "read_request", "emit"].contains(&i.name())
    }) {
        return Err("This module imports capabilities outside Spotlight’s WASM ABI".into());
    }
    if !module.exports().any(|e| e.name() == "memory")
        || !module.exports().any(|e| e.name() == "spotlight_run")
    {
        return Err("Plugin must export memory and spotlight_run".into());
    }
    let root = core::data_dir().join("plugins");
    fs::create_dir_all(&root).map_err(|e| e.to_string())?;
    let root = root.canonicalize().map_err(|e| e.to_string())?;
    let stage = root.join(format!(".store-{}", glib::uuid_string_random()));
    fs::create_dir(&stage).map_err(|e| e.to_string())?;
    fs::set_permissions(&stage, fs::Permissions::from_mode(0o700)).map_err(|e| e.to_string())?;
    let result = (|| {
        fs::write(stage.join("plugin.wasm"), bytes).map_err(|e| e.to_string())?;
        let manifest = serde_json::json!({"schema_version":1,"id":plugin.id,"name":plugin.name,"description":plugin.description,"runtime":"wasm","module":"plugin.wasm","mode":plugin.mode,"timeout_ms":1500});
        fs::write(
            stage.join("manifest.json"),
            serde_json::to_vec_pretty(&manifest).unwrap(),
        )
        .map_err(|e| e.to_string())?;
        for name in ["plugin.wasm", "manifest.json"] {
            fs::set_permissions(stage.join(name), fs::Permissions::from_mode(0o600))
                .map_err(|e| e.to_string())?;
        }
        let source =
            std::ffi::CString::new(stage.as_os_str().as_bytes()).map_err(|e| e.to_string())?;
        let dest = std::ffi::CString::new(root.join(&plugin.id).as_os_str().as_bytes())
            .map_err(|e| e.to_string())?;
        unsafe extern "C" {
            fn renameat2(
                oldfd: i32,
                old: *const std::ffi::c_char,
                newfd: i32,
                new: *const std::ffi::c_char,
                flags: u32,
            ) -> i32;
        }
        if unsafe { renameat2(-100, source.as_ptr(), -100, dest.as_ptr(), 1) } != 0 {
            return Err(format!(
                "Could not install without overwriting: {}",
                std::io::Error::last_os_error()
            ));
        }
        Ok(())
    })();
    if stage.exists() {
        let _ = fs::remove_file(stage.join("manifest.json"));
        let _ = fs::remove_file(stage.join("plugin.wasm"));
        let _ = fs::remove_dir(&stage);
    }
    result
}
impl Ui {
    pub(super) fn plugin_details(self: &Rc<Self>, plugin: Plugin) {
        let dialog = gtk::Window::builder()
            .title("Extension Store")
            .transient_for(&self.window)
            .modal(true)
            .default_width(570)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        for line in [
            plugin.name.clone(),
            format!("{} · {}", plugin.version, plugin.author),
            plugin.description.clone(),
            "Sandboxed WASM · no filesystem, network, or process access".into(),
            format!("Source: {}", plugin.source),
            format!("Artifact: {}", plugin.artifact),
            format!("SHA-256: {}", plugin.sha256),
        ] {
            let label = gtk::Label::new(Some(&line));
            label.set_wrap(true);
            label.set_wrap_mode(gtk::pango::WrapMode::WordChar);
            label.set_xalign(0.);
            label.set_selectable(true);
            panel.append(&label);
        }
        let status = gtk::Label::new(None);
        status.set_wrap(true);
        status.set_xalign(0.);
        panel.append(&status);
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let install = gtk::Button::with_label(if plugin.installed() {
            "Installed"
        } else {
            "Install plugin"
        });
        install.set_sensitive(!plugin.installed());
        install.set_widget_name("store-install");
        row.append(&install);
        let source = gtk::LinkButton::with_label(&plugin.source, "View source");
        row.append(&source);
        let close = gtk::Button::with_label("Close");
        row.append(&close);
        panel.append(&row);
        dialog.set_child(Some(&panel));
        let weak = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        let weak_ui = Rc::downgrade(self);
        let weak = dialog.downgrade();
        install.connect_clicked(move |button| {
            button.set_sensitive(false);
            status.set_text("Installing verified WASM module…");
            let p = plugin.clone();
            let (tx, rx) = mpsc::channel();
            std::thread::spawn(move || {
                let _ = tx.send(crate::pluginstore::install(&p));
            });
            let status = status.clone();
            let button = button.clone();
            let weak = weak.clone();
            let weak_ui = weak_ui.clone();
            glib::timeout_add_local(Duration::from_millis(80), move || {
                if weak.upgrade().is_none() {
                    return glib::ControlFlow::Break;
                }
                match rx.try_recv() {
                    Ok(Ok(())) => {
                        status
                            .set_text("Installed · available in Script Commands and plugin search");
                        button.set_label("Installed");
                        if let Some(ui) = weak_ui.upgrade() {
                            ui.booster_cache.borrow_mut().clear();
                            ui.load_extensions();
                        }
                        glib::ControlFlow::Break
                    }
                    Ok(Err(e)) => {
                        status.set_text(&e);
                        button.set_sensitive(true);
                        glib::ControlFlow::Break
                    }
                    Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                    Err(_) => {
                        status.set_text("Installation interrupted");
                        button.set_sensitive(true);
                        glib::ControlFlow::Break
                    }
                }
            });
        });
        dialog.present();
    }
}
