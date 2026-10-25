use crate::{
    boosters::{self, Entry, Operation},
    core,
};
use gtk::{gio, glib, prelude::*};
use std::{
    collections::HashMap,
    fs,
    io::Write,
    os::unix::fs::{OpenOptionsExt, PermissionsExt},
    sync::{Mutex, OnceLock, mpsc},
    time::Duration,
};
#[derive(serde::Deserialize, Debug)]
pub struct Window {
    pub id: String,
    pub title: String,
    pub app: String,
    #[serde(default)]
    pub pid: u32,
    #[serde(default)]
    pub active: bool,
    #[serde(default)]
    pub minimized: bool,
    #[serde(default)]
    pub desktops: Vec<String>,
}
#[derive(serde::Deserialize, Debug)]
pub struct Desktop {
    pub id: String,
    pub name: String,
    pub number: usize,
    pub current: bool,
    pub windows: usize,
}
#[derive(serde::Serialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
enum Request<'a> {
    Windows,
    CaptureLayout,
    RestoreLayout { placements: &'a [Placement] },
    Desktops,
    FocusWindow { id: &'a str },
    SwitchDesktop { id: &'a str },
    CloseWindow { id: &'a str, pid: u32, all: bool },
}
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
pub struct Placement {
    pub id: String,
    pub app: String,
    pub title: String,
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
    pub minimized: bool,
    pub fullscreen: bool,
    pub vertical: bool,
    pub horizontal: bool,
    pub desktops: Vec<String>,
}
pub fn capture_layout() -> Result<Vec<Placement>, String> {
    let payload = request(Request::CaptureLayout)?;
    let placements: Vec<Placement> =
        serde_json::from_str(&payload).map_err(|_| format!("Cannot capture layout: {payload}"))?;
    if placements.is_empty() {
        return Err("No application windows to save".into());
    }
    Ok(placements)
}
pub fn restore_layout(placements: &[Placement]) -> Result<String, String> {
    if placements.len() > 200
        || placements.iter().any(|p| {
            ![p.x, p.y, p.width, p.height].iter().all(|n| n.is_finite())
                || p.width <= 0.
                || p.height <= 0.
        })
    {
        return Err("Invalid saved window geometry".into());
    }
    let payload = request(Request::RestoreLayout { placements })?;
    let value: serde_json::Value =
        serde_json::from_str(&payload).map_err(|_| "Invalid layout response")?;
    if let Some(error) = value["error"].as_str() {
        return Err(error.into());
    }
    Ok(format!(
        "Restored {} windows · {} missing",
        value["restored"], value["missing"]
    ))
}
type Replies = Mutex<HashMap<String, mpsc::Sender<String>>>;
static REPLIES: OnceLock<Replies> = OnceLock::new();
static BUS_NAME: OnceLock<String> = OnceLock::new();
pub struct Bridge {
    bus: gio::DBusConnection,
    registration: Option<gio::RegistrationId>,
}
impl Drop for Bridge {
    fn drop(&mut self) {
        if let Some(id) = self.registration.take() {
            let _ = self.bus.unregister_object(id);
        }
    }
}
pub fn register() -> Result<Bridge, String> {
    let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
        .map_err(|e| e.to_string())?;
    let info=gio::DBusNodeInfo::for_xml("<node><interface name='local.spotlight.Windows'><method name='Result'><arg type='s' direction='in'/><arg type='s' direction='in'/></method></interface></node>").map_err(|e|e.to_string())?.lookup_interface("local.spotlight.Windows").unwrap();
    let registration = bus
        .register_object("/local/spotlight/Windows", &info)
        .method_call(|_, _, _, _, _, params, invocation| {
            if let Some((token, payload)) = params.get::<(String, String)>()
                && payload.len() <= 262144
                && let Some(replies) = REPLIES.get()
                && let Ok(mut replies) = replies.lock()
                && let Some(tx) = replies.remove(&token)
            {
                let _ = tx.send(payload);
            }
            invocation.return_value(None);
        })
        .build()
        .map_err(|e| e.to_string())?;
    let _ = BUS_NAME.set(
        bus.unique_name()
            .ok_or("D-Bus connection has no unique name")?
            .into(),
    );
    REPLIES.get_or_init(Default::default);
    Ok(Bridge {
        bus,
        registration: Some(registration),
    })
}
fn call(
    bus: &gio::DBusConnection,
    path: &str,
    interface: &str,
    method: &str,
    args: Option<&glib::Variant>,
) -> Result<glib::Variant, String> {
    bus.call_sync(
        Some("org.kde.KWin"),
        path,
        interface,
        method,
        args,
        None,
        gio::DBusCallFlags::NONE,
        1000,
        None::<&gio::Cancellable>,
    )
    .map_err(|e| format!("KWin: {e}"))
}
fn request(request: Request<'_>) -> Result<String, String> {
    let name = BUS_NAME
        .get()
        .ok_or("Window switching requires a KDE KWin desktop session")?;
    let token = glib::uuid_string_random().to_string();
    let plugin = format!("spotlight-{token}");
    let directory = core::data_dir().join("runtime");
    fs::create_dir_all(&directory).map_err(|e| e.to_string())?;
    fs::set_permissions(&directory, fs::Permissions::from_mode(0o700))
        .map_err(|e| e.to_string())?;
    let path = directory.join(format!("{token}.js"));
    let script = script(name, &token, &request);
    let mut file = fs::OpenOptions::new()
        .write(true)
        .create_new(true)
        .mode(0o600)
        .open(&path)
        .map_err(|e| e.to_string())?;
    file.write_all(script.as_bytes())
        .map_err(|e| e.to_string())?;
    drop(file);
    let (tx, rx) = mpsc::channel();
    REPLIES
        .get()
        .unwrap()
        .lock()
        .map_err(|_| "Window request lock failed")?
        .insert(token.clone(), tx);
    let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
        .map_err(|e| e.to_string())?;
    let result = (|| {
        let response = call(
            &bus,
            "/Scripting",
            "org.kde.kwin.Scripting",
            "loadScript",
            Some(&(path.to_string_lossy().as_ref(), plugin.as_str()).to_variant()),
        )?;
        let (id,) = response
            .get::<(i32,)>()
            .ok_or("Unexpected KWin script response")?;
        if id < 0 {
            return Err("KWin could not load its temporary window script".into());
        }
        // Plasma 6 exposes each loaded JavaScript script under this path.
        call(
            &bus,
            &format!("/Scripting/Script{id}"),
            "org.kde.kwin.Script",
            "run",
            None,
        )?;
        rx.recv_timeout(Duration::from_secs(3))
            .map_err(|_| "KWin window request timed out".into())
    })();
    let _ = call(
        &bus,
        "/Scripting",
        "org.kde.kwin.Scripting",
        "unloadScript",
        Some(&(plugin,).to_variant()),
    );
    REPLIES
        .get()
        .unwrap()
        .lock()
        .map_err(|_| "Window request lock failed")?
        .remove(&token);
    let _ = fs::remove_file(path);
    result
}
fn script(service: &str, token: &str, request: &Request<'_>) -> String {
    let service = serde_json::to_string(service).unwrap();
    let token = serde_json::to_string(token).unwrap();
    let request = serde_json::to_string(request).unwrap();
    format!(
        r#"(function() {{
function reply(value) {{ callDBus({service}, '/local/spotlight/Windows', 'local.spotlight.Windows', 'Result', {token}, JSON.stringify(value)); }}
try {{
const windows = workspace.windowList(); const request = {request};
const normal = windows.filter(w => !w.deleted && !w.specialWindow && !w.skipTaskbar && !w.skipSwitcher && w.normalWindow && !['local.spotlight.spotlight','local.spotlight.smoke','local.spotlight.features.test','local.spotlight.workflow.test','spotlight'].some(name => String(w.resourceClass).toLowerCase() === name || String(w.resourceClass).toLowerCase().startsWith(name + '.')));
if (request.kind === 'capture_layout') {{
 reply(normal.slice(0,200).map(w => ({{id:String(w.internalId),app:String(w.desktopFileName || w.resourceClass),title:String(w.caption),x:w.frameGeometry.x,y:w.frameGeometry.y,width:w.frameGeometry.width,height:w.frameGeometry.height,minimized:!!w.minimized,fullscreen:!!w.fullScreen,vertical:!!(Number(w.maximizeMode)&1),horizontal:!!(Number(w.maximizeMode)&2),desktops:w.desktops.map(d=>String(d.id))}}))); return;
}}
if (request.kind === 'restore_layout') {{
 const used = []; let restored = 0;
 request.placements.forEach(p => {{
  const available = normal.filter(w => used.indexOf(w)<0 && String(w.desktopFileName || w.resourceClass)===p.app);
  const w = available.find(w => String(w.internalId)===p.id) || available.find(w=>String(w.caption)===p.title) || (available.length===1 ? available[0] : null);
  if (!w) return;
  used.push(w); w.fullScreen=false; w.setMaximize(false,false);
  if (w.tile) w.tile=null;
  const screens=workspace.screens; const original={{x:p.x,y:p.y,width:p.width,height:p.height}};
  const screen=screens.find(s=>p.x+p.width>s.geometry.x && p.x<s.geometry.x+s.geometry.width && p.y+p.height>s.geometry.y && p.y<s.geometry.y+s.geometry.height) || screens[0];
  if (screen) {{ const g=screen.geometry; original.width=Math.min(p.width,g.width); original.height=Math.min(p.height,g.height); original.x=Math.max(g.x,Math.min(p.x,g.x+g.width-original.width)); original.y=Math.max(g.y,Math.min(p.y,g.y+g.height-original.height)); }}
  w.frameGeometry=original;
  const desktops=workspace.desktops.filter(d=>p.desktops.indexOf(String(d.id))>=0);
  if (!p.desktops.length || desktops.length) w.desktops=desktops;
  w.setMaximize(p.vertical,p.horizontal); w.fullScreen=p.fullscreen; w.minimized=p.minimized; restored++;
 }});
 reply({{restored:restored,missing:request.placements.length-restored}}); return;
}}
if (request.kind === 'close_window') {{
 const w = normal.find(w => String(w.internalId) === request.id);
 if (!w || (request.pid > 0 && Number(w.pid) !== request.pid)) {{ reply({{error:'That window has closed or changed'}}); return; }}
 if (request.all && request.pid <= 1) {{ reply({{error:'Cannot identify this application process'}}); return; }}
 const targets = request.all ? normal.filter(t => Number(t.pid) === request.pid) : [w];
 targets.forEach(t => t.closeWindow()); reply({{closed:targets.length}}); return;
}}
if (request.kind === 'desktops') {{
 reply(workspace.desktops.map((d,i) => ({{id:String(d.id),name:String(d.name),number:i+1,current:d===workspace.currentDesktop,windows:normal.filter(w => !w.desktops.length || w.desktops.indexOf(d)>=0).length}}))); return;
}}
if (request.kind === 'switch_desktop') {{
 const d = workspace.desktops.find(d => String(d.id) === request.id);
 if (!d) {{ reply({{error:'That virtual desktop no longer exists'}}); return; }}
 workspace.currentDesktop = d;
 reply({{focused:String(workspace.currentDesktop.id)===request.id}}); return;
}}
if (request.kind === 'focus_window') {{
 const target = request.id;
 const w = windows.find(w => String(w.internalId) === target && !w.deleted);
 if (!w) {{ reply({{error:'That window has closed'}}); return; }}
 if (w.activities && w.activities.length && w.activities.indexOf(workspace.currentActivity) < 0) workspace.currentActivity = w.activities[0];
 if (w.desktops && w.desktops.length && w.desktops.indexOf(workspace.currentDesktop) < 0) workspace.currentDesktop = w.desktops[0];
 w.minimized = false;
 if (typeof workspace.activateWindow === 'function') workspace.activateWindow(w); else workspace.activeWindow = w;
 reply({{focused: String(workspace.activeWindow && workspace.activeWindow.internalId) === target}}); return;
}}
reply(normal.slice(0,200).map(w => ({{id:String(w.internalId),title:String(w.caption),app:String(w.desktopFileName || w.resourceClass),pid:Number(w.pid)||0,active:!!w.active,minimized:!!w.minimized,desktops:w.desktops.map(d => String(d.name))}})));
}} catch(e) {{ reply({{error:String(e)}}); }}
}})();"#
    )
}
pub fn list() -> Result<Vec<Window>, String> {
    let payload = request(Request::Windows)?;
    if let Ok(value) = serde_json::from_str::<serde_json::Value>(&payload)
        && let Some(error) = value.get("error").and_then(|s| s.as_str())
    {
        return Err(error.into());
    }
    serde_json::from_str(&payload).map_err(|_| "Invalid KWin window list".into())
}
pub fn fetch(query: &str) -> Result<Vec<Entry>, String> {
    let mut windows: Vec<_> = list()?
        .into_iter()
        .filter_map(|window| {
            core::score(
                query,
                &format!(
                    "{} {} {}",
                    window.app,
                    window.title,
                    window.desktops.join(" ")
                ),
            )
            .map(|score| (score, window))
        })
        .collect();
    windows.sort_by(|a, b| b.0.cmp(&a.0).then(b.1.active.cmp(&a.1.active)));
    let mut rows: Vec<_> = windows
        .into_iter()
        .take(60)
        .map(|(_, w)| Entry {
            title: w.title,
            detail: format!(
                "{} · {} · {} · Enter to switch",
                w.app,
                if w.desktops.is_empty() {
                    "All desktops".into()
                } else {
                    w.desktops.join(", ")
                },
                if w.minimized {
                    "Minimized"
                } else if w.active {
                    "Active"
                } else {
                    "Open"
                }
            ),
            badge: "Window",
            operation: Some(Operation::FocusWindow(w.id)),
        })
        .collect();
    if rows.is_empty() {
        rows.push(boosters::hint(
            "No matching open windows",
            "Type window chrome, window terminal, or window · KWin",
        ));
    }
    Ok(rows)
}
pub fn focus(id: &str) -> Result<String, String> {
    if id.len() > 64
        || !id
            .chars()
            .all(|c| c.is_ascii_hexdigit() || "{}-".contains(c))
    {
        return Err("Invalid window identity".into());
    }
    let response: serde_json::Value = serde_json::from_str(&request(Request::FocusWindow { id })?)
        .map_err(|_| "Invalid KWin focus response")?;
    if response["focused"] == true {
        Ok("Switched window".into())
    } else {
        Err(response["error"]
            .as_str()
            .unwrap_or("KWin could not activate that window")
            .into())
    }
}
pub fn close_window(id: &str, pid: u32, all: bool) -> Result<String, String> {
    if id.is_empty()
        || id.len() > 64
        || !id
            .chars()
            .all(|c| c.is_ascii_hexdigit() || "{}-".contains(c))
    {
        return Err("Invalid window identity".into());
    }
    let response: serde_json::Value =
        serde_json::from_str(&request(Request::CloseWindow { id, pid, all })?)
            .map_err(|_| "Invalid KWin close response")?;
    if let Some(count) = response["closed"].as_u64() {
        Ok(format!("Requested a normal close for {count} window(s)"))
    } else {
        Err(response["error"]
            .as_str()
            .unwrap_or("KWin could not close that window")
            .into())
    }
}
pub fn desktops() -> Result<Vec<Desktop>, String> {
    let payload = request(Request::Desktops)?;
    if let Ok(value) = serde_json::from_str::<serde_json::Value>(&payload)
        && let Some(error) = value.get("error").and_then(|e| e.as_str())
    {
        return Err(error.into());
    }
    serde_json::from_str(&payload).map_err(|_| "Invalid KWin desktop list".into())
}
pub fn fetch_desktops(query: &str) -> Result<Vec<Entry>, String> {
    let mut rows: Vec<_> = desktops()?
        .into_iter()
        .filter_map(|d| {
            core::score(query, &format!("{} {}", d.number, d.name)).map(|score| (score, d))
        })
        .collect();
    rows.sort_by(|a, b| b.0.cmp(&a.0).then(a.1.number.cmp(&b.1.number)));
    let mut rows: Vec<_> = rows
        .into_iter()
        .map(|(_, d)| Entry {
            title: format!("Desktop {} · {}", d.number, d.name),
            detail: format!(
                "{} · {} open windows · Enter to switch",
                if d.current {
                    "Current"
                } else {
                    "Virtual desktop"
                },
                d.windows
            ),
            badge: "Desktop",
            operation: Some(Operation::SwitchDesktop(d.id)),
        })
        .collect();
    if rows.is_empty() {
        rows.push(boosters::hint(
            "No matching virtual desktops",
            "Search desktop <name or number> · configure desktops in KDE System Settings",
        ));
    }
    Ok(rows)
}
pub fn fetch_switcher(query: &str) -> Result<Vec<Entry>, String> {
    let mut rows = fetch(query)?;
    rows.extend(fetch_desktops(query)?);
    if rows.iter().any(|e| e.operation.is_some()) {
        rows.retain(|e| e.operation.is_some());
    }
    Ok(rows)
}
pub fn switch_desktop(id: &str) -> Result<String, String> {
    if id.is_empty()
        || id.len() > 64
        || !id
            .chars()
            .all(|c| c.is_ascii_hexdigit() || "{}-".contains(c))
    {
        return Err("Invalid desktop identity".into());
    }
    let response: serde_json::Value =
        serde_json::from_str(&request(Request::SwitchDesktop { id })?)
            .map_err(|_| "Invalid KWin desktop response")?;
    if response["focused"] == true {
        Ok("Switched virtual desktop".into())
    } else {
        Err(response["error"]
            .as_str()
            .unwrap_or("KWin could not switch desktops")
            .into())
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn script_arguments_are_json_escaped() {
        let text = script(":1.1", "token", &Request::FocusWindow { id: "a\"b" });
        assert!(text.contains(r#"a\"b"#));
        assert!(text.contains("workspace.windowList()"));
        assert!(text.contains("workspace.activeWindow = w"));
    }
}
