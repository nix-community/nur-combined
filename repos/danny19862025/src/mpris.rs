use gtk::{gio, glib, prelude::*};
use std::{
    collections::HashMap,
    time::{Duration, Instant},
};

const PREFIX: &str = "org.mpris.MediaPlayer2.";
const PATH: &str = "/org/mpris/MediaPlayer2";
const PLAYER: &str = "org.mpris.MediaPlayer2.Player";
type Properties = HashMap<String, glib::Variant>;

pub struct Player {
    pub service: String,
    pub identity: String,
    pub track: String,
    pub status: String,
    properties: Properties,
}
fn call(
    bus: &gio::DBusConnection,
    service: &str,
    path: &str,
    interface: &str,
    method: &str,
    parameters: Option<&glib::Variant>,
) -> Result<glib::Variant, String> {
    bus.call_sync(
        Some(service),
        path,
        interface,
        method,
        parameters,
        None,
        gio::DBusCallFlags::NO_AUTO_START,
        500,
        None::<&gio::Cancellable>,
    )
    .map_err(|e| e.to_string())
}
fn properties(
    bus: &gio::DBusConnection,
    service: &str,
    interface: &str,
) -> Result<Properties, String> {
    let reply = call(
        bus,
        service,
        PATH,
        "org.freedesktop.DBus.Properties",
        "GetAll",
        Some(&(interface,).to_variant()),
    )?;
    reply
        .child_value(0)
        .get()
        .ok_or("Invalid MPRIS properties".into())
}
fn text(properties: &Properties, key: &str) -> String {
    properties
        .get(key)
        .and_then(|v| v.get::<String>())
        .unwrap_or_default()
}
fn flag(properties: &Properties, key: &str) -> bool {
    properties
        .get(key)
        .and_then(|v| v.get::<bool>())
        .unwrap_or(false)
}
fn supported(properties: &Properties, command: &str) -> bool {
    flag(properties, "CanControl")
        && match command {
            "play" => flag(properties, "CanPlay"),
            "pause" | "play-pause" => flag(properties, "CanPause"),
            "next" => flag(properties, "CanGoNext"),
            "previous" => flag(properties, "CanGoPrevious"),
            "stop" => true,
            _ => false,
        }
}
impl Player {
    pub fn supports(&self, command: &str) -> bool {
        supported(&self.properties, command)
    }
}
pub fn players() -> Result<Vec<Player>, String> {
    let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
        .map_err(|e| e.to_string())?;
    let reply = call(
        &bus,
        "org.freedesktop.DBus",
        "/org/freedesktop/DBus",
        "org.freedesktop.DBus",
        "ListNames",
        None,
    )?;
    let mut names = reply
        .child_value(0)
        .get::<Vec<String>>()
        .ok_or("Invalid session bus response")?;
    names.retain(|n| n.starts_with(PREFIX));
    names.sort();
    names.truncate(20);
    let started = Instant::now();
    let mut players = Vec::new();
    for service in names {
        if started.elapsed() > Duration::from_secs(3) {
            break;
        }
        let Ok(props) = properties(&bus, &service, PLAYER) else {
            continue;
        };
        let identity = properties(&bus, &service, "org.mpris.MediaPlayer2")
            .ok()
            .map(|p| text(&p, "Identity"))
            .filter(|s| !s.is_empty())
            .unwrap_or_else(|| service[PREFIX.len()..].into());
        let metadata = props
            .get("Metadata")
            .and_then(|v| v.get::<Properties>())
            .unwrap_or_default();
        let title = text(&metadata, "xesam:title");
        let artists = metadata
            .get("xesam:artist")
            .and_then(|v| v.get::<Vec<String>>())
            .unwrap_or_default()
            .join(", ");
        let track = [artists, title]
            .into_iter()
            .filter(|s| !s.is_empty())
            .collect::<Vec<_>>()
            .join(" — ");
        let status = text(&props, "PlaybackStatus");
        players.push(Player {
            service,
            identity,
            track,
            status,
            properties: props,
        });
    }
    players.sort_by_key(|p| if p.status == "Playing" { 0 } else { 1 });
    Ok(players)
}
pub fn control(service: &str, command: &str) -> Result<(), String> {
    let method = match command {
        "play-pause" => "PlayPause",
        "play" => "Play",
        "pause" => "Pause",
        "next" => "Next",
        "previous" => "Previous",
        "stop" => "Stop",
        _ => return Err("Invalid music control".into()),
    };
    if !service.starts_with(PREFIX) || !gio::dbus_is_name(service) {
        return Err("Invalid MPRIS player".into());
    }
    let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
        .map_err(|e| e.to_string())?;
    // Resolve once so a player exiting cannot redirect this operation to a new owner.
    let owner = call(
        &bus,
        "org.freedesktop.DBus",
        "/org/freedesktop/DBus",
        "org.freedesktop.DBus",
        "GetNameOwner",
        Some(&(service,).to_variant()),
    )?
    .child_value(0)
    .get::<String>()
    .ok_or("Player is no longer available")?;
    let props = properties(&bus, &owner, PLAYER)?;
    if !supported(&props, command) {
        return Err("This player does not support that control".into());
    }
    call(&bus, &owner, PATH, PLAYER, method, None).map(|_| ())
}
