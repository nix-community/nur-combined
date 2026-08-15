use wasmtime::{Engine, Config, Store};
use wasmtime::component::{Component, HasSelf, Linker};
use bevy::prelude::*;
use std::sync::atomic::{AtomicU64, Ordering};
use std::cell::Cell;
use std::collections::HashSet;
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
        topics: HashSet::new(),
    }
}

pub struct HostData {
    pub name: String,
    pub bus: Arc<dyn EngineBus>,
    pub topics: HashSet<String>,
}

struct AfterJob {
    at_ms: i64,
    pack: String,
    method: String,
    args: Wire,
}

static AFTER_JOBS: Mutex<Vec<AfterJob>> = Mutex::new(Vec::new());

fn queue_after(pack: String, ms: i32, method: String, args: Wire) {
    let delay = ms.max(0) as i64;
    if let Ok(mut jobs) = AFTER_JOBS.lock() {
        jobs.push(AfterJob {
            at_ms: host_now_ms().saturating_add(delay),
            pack,
            method,
            args,
        });
    }
}

fn due_after_jobs() -> Vec<AfterJob> {
    let now = host_now_ms();
    let Ok(mut jobs) = AFTER_JOBS.lock() else {
        return Vec::new();
    };
    let mut keep = Vec::new();
    let mut due = Vec::new();
    for job in std::mem::take(&mut *jobs) {
        if job.at_ms <= now {
            due.push(job);
        } else {
            keep.push(job);
        }
    }
    *jobs = keep;
    due
}

pub fn flush_after_bus(bus: &dyn EngineBus) {
    for job in due_after_jobs() {
        bus.send("host", &job.pack, &job.method, job.args);
    }
}

/// JSON tree on the host. WIT carries the same tree as a cell arena
/// (`value.cells` + indexes) because WIT types cannot recurse.
#[derive(Clone, Debug)]
pub enum Wire {
    Empty,
    Flag(bool),
    Int(i64),
    Float(f64),
    Text(String),
    Items(Vec<Wire>),
    Dict(Vec<WireField>),
    Fail(String),
}

#[derive(Clone, Debug)]
pub struct WireField {
    pub key: String,
    pub value: Wire,
}

type AbiValue = hanga::engine::host::Value;
type AbiCell = hanga::engine::host::Cell;
type AbiField = hanga::engine::host::Field;

pub fn lift_wire(value: &AbiValue) -> Wire {
    lift_cell(value, value.root)
}

fn lift_cell(value: &AbiValue, at: u32) -> Wire {
    let Some(cell) = value.cells.get(at as usize) else {
        return Wire::Empty;
    };
    match cell {
        AbiCell::Empty => Wire::Empty,
        AbiCell::Flag(flag) => Wire::Flag(*flag),
        AbiCell::Int(n) => Wire::Int(*n),
        AbiCell::Float(n) => Wire::Float(*n),
        AbiCell::Text(text) => Wire::Text(text.clone()),
        AbiCell::Items(idx) => Wire::Items(idx.iter().map(|child| lift_cell(value, *child)).collect()),
        AbiCell::Dict(fields) => Wire::Dict(
            fields
                .iter()
                .map(|field| WireField {
                    key: field.key.clone(),
                    value: lift_cell(value, field.at),
                })
                .collect(),
        ),
        AbiCell::Fail(reason) => Wire::Fail(reason.clone()),
    }
}

pub fn lower_wire(value: &Wire) -> AbiValue {
    let mut cells = Vec::new();
    let root = lower_into(&mut cells, value);
    AbiValue { cells, root }
}

fn lower_into(cells: &mut Vec<AbiCell>, value: &Wire) -> u32 {
    match value {
        Wire::Empty => push_cell(cells, AbiCell::Empty),
        Wire::Flag(flag) => push_cell(cells, AbiCell::Flag(*flag)),
        Wire::Int(n) => push_cell(cells, AbiCell::Int(*n)),
        Wire::Float(n) => push_cell(cells, AbiCell::Float(*n)),
        Wire::Text(text) => push_cell(cells, AbiCell::Text(text.clone())),
        Wire::Items(items) => {
            let idx: Vec<u32> = items.iter().map(|item| lower_into(cells, item)).collect();
            push_cell(cells, AbiCell::Items(idx))
        }
        Wire::Dict(fields) => {
            let bag: Vec<AbiField> = fields
                .iter()
                .map(|field| AbiField {
                    key: field.key.clone(),
                    at: lower_into(cells, &field.value),
                })
                .collect();
            push_cell(cells, AbiCell::Dict(bag))
        }
        Wire::Fail(reason) => push_cell(cells, AbiCell::Fail(reason.clone())),
    }
}

fn push_cell(cells: &mut Vec<AbiCell>, cell: AbiCell) -> u32 {
    let at = cells.len() as u32;
    cells.push(cell);
    at
}

pub const ABI_MAJOR: i32 = 6;

thread_local! {
    static ASK_DEPTH: Cell<u32> = const { Cell::new(0) };
}

pub fn wire_empty() -> Wire {
    Wire::Empty
}

pub fn wire_int(value: i64) -> Wire {
    Wire::Int(value)
}

pub fn wire_float(value: f64) -> Wire {
    Wire::Float(value)
}

pub fn wire_text(text: impl Into<String>) -> Wire {
    Wire::Text(text.into())
}

pub fn wire_flag(value: bool) -> Wire {
    Wire::Flag(value)
}

pub fn wire_fail(reason: impl Into<String>) -> Wire {
    Wire::Fail(reason.into())
}

pub fn wire_is_fail(value: &Wire) -> bool {
    matches!(value, Wire::Fail(_))
}

/// First non-skip reply. `fail` is `{error, Reason}`, not “not mine”.
pub fn first_override(replies: impl IntoIterator<Item = Wire>) -> Wire {
    for reply in replies {
        if wire_is_fail(&reply) || !wire_is_empty(&reply) {
            return reply;
        }
    }
    wire_empty()
}

pub fn wire_bag(fields: Vec<(&str, Wire)>) -> Wire {
    Wire::Dict(
        fields
            .into_iter()
            .map(|(key, value)| WireField {
                key: key.into(),
                value,
            })
            .collect(),
    )
}

pub fn player_snapshot_wire(
    snap: &::hanga::PlayerSnap,
    wanted: bool,
    wallet: bool,
) -> Wire {
    let mut fields = vec![
        ("x", Wire::Float(snap.x as f64)),
        ("y", Wire::Float(snap.y as f64)),
        ("z", Wire::Float(snap.z as f64)),
        ("yaw", Wire::Float(snap.yaw as f64)),
    ];
    if wanted {
        fields.push(("state", Wire::Int(snap.state as i64)));
    }
    if wallet {
        fields.push(("wallet", Wire::Int(snap.wallet as i64)));
    }
    wire_bag(fields)
}

pub fn parse_topics(payload: &Wire) -> HashSet<String> {
    match payload {
        Wire::Text(csv) => csv
            .split(',')
            .map(str::trim)
            .filter(|name| !name.is_empty())
            .map(|name| name.to_string())
            .collect(),
        Wire::Dict(fields) => fields.iter().map(|field| field.key.clone()).collect(),
        Wire::Items(items) => items
            .iter()
            .filter_map(|item| match item {
                Wire::Text(name) if !name.is_empty() => Some(name.clone()),
                _ => None,
            })
            .collect(),
        _ => HashSet::new(),
    }
}

pub fn payload_text<'a>(payload: &'a Wire, key: &str) -> &'a str {
    match payload {
        Wire::Text(text) => text.as_str(),
        Wire::Dict(fields) => fields
            .iter()
            .find(|field| field.key == key)
            .and_then(|field| match &field.value {
                Wire::Text(text) => Some(text.as_str()),
                _ => None,
            })
            .unwrap_or(""),
        _ => "",
    }
}

pub fn payload_i64(payload: &Wire, key: &str) -> i64 {
    match payload {
        Wire::Int(value) => *value,
        Wire::Float(value) => *value as i64,
        Wire::Text(text) => text.parse().unwrap_or(0),
        Wire::Dict(fields) => fields
            .iter()
            .find(|field| field.key == key)
            .and_then(|field| match &field.value {
                Wire::Int(value) => Some(*value),
                Wire::Float(value) => Some(*value as i64),
                Wire::Text(text) => text.parse().ok(),
                _ => None,
            })
            .unwrap_or(0),
        _ => 0,
    }
}

pub fn payload_f32(payload: &Wire, key: &str) -> f32 {
    match payload {
        Wire::Float(value) => *value as f32,
        Wire::Int(value) => *value as f32,
        Wire::Dict(fields) => fields
            .iter()
            .find(|field| field.key == key)
            .and_then(|field| match &field.value {
                Wire::Float(value) => Some(*value as f32),
                Wire::Int(value) => Some(*value as f32),
                Wire::Text(text) => text.parse().ok(),
                _ => None,
            })
            .unwrap_or(0.0),
        _ => 0.0,
    }
}

pub fn payload_xyz(payload: &Wire, fallback: (i32, i32, i32)) -> (i32, i32, i32) {
    if wire_is_fail(payload) || wire_is_empty(payload) {
        return fallback;
    }
    (
        payload_i64(payload, "x") as i32,
        payload_i64(payload, "y") as i32,
        payload_i64(payload, "z") as i32,
    )
}

pub fn wire_voxel_probe(name: impl Into<String>, edit: bool) -> Wire {
    wire_bag(vec![
        ("name", Wire::Text(name.into())),
        ("edit", Wire::Flag(edit)),
    ])
}

pub fn wire_is_empty(value: &Wire) -> bool {
    match value {
        Wire::Empty => true,
        Wire::Text(text) if text.is_empty() => true,
        Wire::Dict(fields) if fields.is_empty() => true,
        _ => false,
    }
}

pub fn node_from_wire(value: &Wire) -> ::hanga::kit::Node {
    match value {
        Wire::Empty | Wire::Fail(_) => ::hanga::kit::Node::Empty,
        Wire::Flag(flag) => ::hanga::kit::Node::Flag(*flag),
        Wire::Int(n) => ::hanga::kit::Node::Int(*n),
        Wire::Float(n) => ::hanga::kit::Node::Float(*n),
        Wire::Text(text) => ::hanga::kit::Node::Text(text.clone()),
        Wire::Items(items) => {
            ::hanga::kit::Node::Items(items.iter().map(node_from_wire).collect())
        }
        Wire::Dict(fields) => ::hanga::kit::Node::Dict(
            fields
                .iter()
                .map(|field| (field.key.clone(), node_from_wire(&field.value)))
                .collect(),
        ),
    }
}

/// Name-shaped replies (`loot-item`, labels). Dicts are not flattened into a fake name.
pub fn wire_as_text(value: &Wire) -> String {
    match value {
        Wire::Text(text) => text.clone(),
        _ => String::new(),
    }
}

pub fn wire_is_veto(value: &Wire) -> bool {
    matches!(value, Wire::Flag(true) | Wire::Int(1))
}

/// Missing method uses `fallback`. `fail` is closed (range 0), not a skip.
pub fn reply_range(reply: &Wire, fallback: f32) -> f32 {
    if wire_is_fail(reply) {
        return 0.0;
    }
    if wire_is_empty(reply) {
        return fallback;
    }
    payload_f32(reply, "value")
}

/// Missing method uses `fallback`. `fail` also keeps `fallback` (current state,
/// wallet, tick) instead of parsing 0 from an empty shape.
pub fn reply_i32(reply: &Wire, fallback: i32) -> i32 {
    if wire_is_fail(reply) || wire_is_empty(reply) {
        fallback
    } else {
        payload_i64(reply, "value") as i32
    }
}

fn emit_blocks(reply: Result<&Wire, ()>) -> bool {
    match reply {
        Ok(value) => wire_is_veto(value) || wire_is_fail(value),
        Err(()) => true,
    }
}

pub trait EngineBus: Send + Sync {
    fn log(&self, from: &str, level: &str, message: &str);
    fn peers(&self, from: &str) -> Vec<String>;
    fn has_mod(&self, name: &str) -> bool;
    fn invoke(&self, from: &str, peer: &str, method: &str, args: Wire) -> Wire;
    fn send(&self, from: &str, peer: &str, method: &str, args: Wire);
    fn emit(&self, from: &str, method: &str, args: Wire) -> bool;
    fn voxel(&self, x: i32, y: i32, z: i32) -> Wire;
    fn flush_deferred(&self) {}
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

    fn peers(&self, _from: &str) -> Vec<String> {
        Vec::new()
    }

    fn has_mod(&self, _name: &str) -> bool {
        false
    }

    fn invoke(&self, _from: &str, _peer: &str, _method: &str, _args: Wire) -> Wire {
        wire_empty()
    }

    fn send(&self, _from: &str, _peer: &str, _method: &str, _args: Wire) {}

    fn emit(&self, _from: &str, _method: &str, _args: Wire) -> bool {
        false
    }

    fn voxel(&self, _x: i32, _y: i32, _z: i32) -> Wire {
        wire_voxel_probe("air", false)
    }
}

const MAILBOX_CAP: usize = 256;
const MAILBOX_DRAIN_ROUNDS: usize = 32;
const TRAP_RESTART_COOLDOWN_MS: u128 = 2000;

fn trap_restart_ready(last: Option<Instant>, now: Instant) -> bool {
    last.is_none_or(|at| now.duration_since(at).as_millis() >= TRAP_RESTART_COOLDOWN_MS)
}

struct QueuedAsk {
    slot: Arc<Mutex<Option<MainModContext>>>,
    from: String,
    topic: String,
    payload: Wire,
}

fn mailbox_evict_if_full<T>(pending: &mut Vec<T>, cap: usize) -> bool {
    if pending.len() >= cap {
        pending.remove(0);
        true
    } else {
        false
    }
}

struct LiveBus {
    lead_name: String,
    lead: Arc<Mutex<Option<MainModContext>>>,
    packs: Vec<(String, Arc<Mutex<Option<MainModContext>>>)>,
    pending: Mutex<Vec<QueuedAsk>>,
    logs: Mutex<Vec<(String, String, String)>>,
}

impl EngineBus for LiveBus {
    fn log(&self, from: &str, level: &str, message: &str) {
        NoopBus.log(from, level, message);
        let mut logs = self.logs.lock().unwrap();
        if logs.len() >= 32 {
            logs.remove(0);
        }
        logs.push((from.into(), level.into(), message.into()));
    }

    fn peers(&self, from: &str) -> Vec<String> {
        let mut names = Vec::new();
        if self.lead_name != from && !self.lead_name.is_empty() {
            names.push(self.lead_name.clone());
        }
        for (name, _) in &self.packs {
            if name != from {
                names.push(name.clone());
            }
        }
        names
    }

    fn has_mod(&self, name: &str) -> bool {
        self.lead_name == name || self.packs.iter().any(|(pack, _)| pack == name)
    }

    fn invoke(&self, from: &str, peer: &str, method: &str, args: Wire) -> Wire {
        if peer.is_empty() {
            for (name, ctx) in self.packs.iter().rev() {
                if name == from {
                    continue;
                }
                match self.call_now(ctx, from, method, &args) {
                    Ok(reply) if wire_is_fail(&reply) || !wire_is_empty(&reply) => return reply,
                    Ok(_) => {}
                    Err(()) => return wire_fail("busy"),
                }
            }
            if self.lead_name != from {
                return match self.call_now(&self.lead, from, method, &args) {
                    Ok(reply) => reply,
                    Err(()) => wire_fail("busy"),
                };
            }
            return wire_empty();
        }
        if peer == from {
            return wire_fail("self");
        }
        let Some(slot) = self.slot(peer) else {
            return wire_fail("noproc");
        };
        match self.call_now(slot, from, method, &args) {
            Ok(reply) => reply,
            Err(()) => wire_fail("busy"),
        }
    }

    fn send(&self, from: &str, peer: &str, method: &str, args: Wire) {
        if peer.is_empty() {
            if self.lead_name != from {
                self.cast(&self.lead, from, method, &args);
            }
            for (name, ctx) in &self.packs {
                if name != from {
                    self.cast(ctx, from, method, &args);
                }
            }
            return;
        }
        if peer == from {
            if let Some(slot) = self.slot(from) {
                self.enqueue(slot, from, method, &args);
            }
            return;
        }
        if let Some(slot) = self.slot(peer) {
            self.cast(slot, from, method, &args);
        }
    }

    fn emit(&self, from: &str, method: &str, args: Wire) -> bool {
        let mut veto = false;
        if self.lead_name != from {
            match self.call_now(&self.lead, from, method, &args) {
                Ok(reply) => {
                    if emit_blocks(Ok(&reply)) {
                        veto = true;
                    }
                }
                Err(()) => veto = true,
            }
        }
        for (name, ctx) in &self.packs {
            if name == from {
                continue;
            }
            match self.call_now(ctx, from, method, &args) {
                Ok(reply) => {
                    if emit_blocks(Ok(&reply)) {
                        veto = true;
                    }
                }
                Err(()) => veto = true,
            }
        }
        veto
    }

    fn voxel(&self, x: i32, y: i32, z: i32) -> Wire {
        probe_lead_voxel(x, y, z)
    }

    fn flush_deferred(&self) {
        for _ in 0..MAILBOX_DRAIN_ROUNDS {
            let batch = {
                let Ok(mut pending) = self.pending.lock() else {
                    return;
                };
                if pending.is_empty() {
                    return;
                }
                std::mem::take(&mut *pending)
            };
            let mut stuck = Vec::new();
            for queued in batch {
                let Ok(mut guard) = queued.slot.try_lock() else {
                    stuck.push(queued);
                    continue;
                };
                if let Some(ctx) = guard.as_mut() {
                    let _ = ctx.call(&queued.from, &queued.topic, &queued.payload);
                }
            }
            if !stuck.is_empty() {
                if let Ok(mut pending) = self.pending.lock() {
                    stuck.append(&mut *pending);
                    *pending = stuck;
                }
            }
        }
        if let Ok(pending) = self.pending.lock() {
            if !pending.is_empty() {
                warn!(
                    "mod mailbox still has {} message(s) after {MAILBOX_DRAIN_ROUNDS} drain rounds",
                    pending.len()
                );
            }
        }
    }
}

impl LiveBus {
    fn new(
        lead_name: String,
        lead: Arc<Mutex<Option<MainModContext>>>,
        packs: Vec<(String, Arc<Mutex<Option<MainModContext>>>)>,
    ) -> Self {
        Self {
            lead_name,
            lead,
            packs,
            pending: Mutex::new(Vec::new()),
            logs: Mutex::new(Vec::new()),
        }
    }

    fn slot(&self, name: &str) -> Option<&Arc<Mutex<Option<MainModContext>>>> {
        if name == self.lead_name {
            return Some(&self.lead);
        }
        self.packs
            .iter()
            .find(|(pack, _)| pack == name)
            .map(|(_, slot)| slot)
    }

    fn enqueue(
        &self,
        slot: &Arc<Mutex<Option<MainModContext>>>,
        from: &str,
        topic: &str,
        payload: &Wire,
    ) {
        if let Ok(mut pending) = self.pending.lock() {
            if mailbox_evict_if_full(&mut *pending, MAILBOX_CAP) {
                warn!("mod mailbox full ({MAILBOX_CAP}); dropping oldest cast");
            }
            pending.push(QueuedAsk {
                slot: Arc::clone(slot),
                from: from.to_string(),
                topic: topic.to_string(),
                payload: payload.clone(),
            });
        }
    }

    /// OTP call: run now or `{error, busy}`. Never queues a pretend reply.
    fn call_now(
        &self,
        slot: &Arc<Mutex<Option<MainModContext>>>,
        from: &str,
        topic: &str,
        payload: &Wire,
    ) -> Result<Wire, ()> {
        let Ok(mut guard) = slot.try_lock() else {
            return Err(());
        };
        let Some(ctx) = guard.as_mut() else {
            return Ok(wire_empty());
        };
        Ok(ctx.call(from, topic, payload))
    }

    /// OTP cast: run now if free, else mailbox.
    fn cast(
        &self,
        slot: &Arc<Mutex<Option<MainModContext>>>,
        from: &str,
        topic: &str,
        payload: &Wire,
    ) {
        match self.call_now(slot, from, topic, payload) {
            Ok(_) => {}
            Err(()) => self.enqueue(slot, from, topic, payload),
        }
    }
}

fn probe_lead_voxel(x: i32, y: i32, z: i32) -> Wire {
    match ::hanga::overlay_get(x, y, z) {
        Some(::hanga::VoxelOverlay::Air) => wire_voxel_probe("air", true),
        Some(::hanga::VoxelOverlay::Solid(name)) => wire_voxel_probe(name, true),
        None => wire_voxel_probe(sample_lead_worldgen(x, y, z), false),
    }
}

fn sample_lead_worldgen(x: i32, y: i32, z: i32) -> String {
    let Ok(shared) = SHARED_WASM.read() else {
        return "air".into();
    };
    let Some((_, engine, component)) = shared.as_ref() else {
        return "air".into();
    };
    let mut store = Store::new(engine, noop_host("sample"));
    let mut linker = Linker::new(engine);
    if Plugin::add_to_linker::<HostData, HasSelf<_>>(&mut linker, |data| data).is_err() {
        return "air".into();
    }
    let Ok(bindings) = Plugin::instantiate(&mut store, component, &linker) else {
        return "air".into();
    };
    let gp = bindings.hanga_engine_guest();
    let index = gp.call_query_voxel(&mut store, x, y, z).unwrap_or(0);
    let names = gp.call_voxel_catalog(&mut store).unwrap_or_default();
    ::hanga::catalog_name(&names, index)
        .unwrap_or("air")
        .to_string()
}

impl hanga::engine::host::Host for HostData {
    fn log(&mut self, level: String, message: String) {
        self.bus.log(&self.name, &level, &message);
    }

    fn now_ms(&mut self) -> i64 {
        host_now_ms()
    }

    fn id(&mut self) -> String {
        self.name.clone()
    }

    fn peers(&mut self) -> Vec<String> {
        self.bus.peers(&self.name)
    }

    fn has_mod(&mut self, name: String) -> bool {
        name == self.name || self.bus.has_mod(&name)
    }

    fn invoke(&mut self, peer: String, method: String, args: AbiValue) -> AbiValue {
        ASK_DEPTH.with(|depth| depth.set(depth.get().saturating_add(1)));
        let reply = self.bus.invoke(&self.name, &peer, &method, lift_wire(&args));
        let remaining = ASK_DEPTH.with(|depth| {
            let next = depth.get().saturating_sub(1);
            depth.set(next);
            next
        });
        if remaining == 0 {
            self.bus.flush_deferred();
        }
        lower_wire(&reply)
    }

    fn send(&mut self, peer: String, method: String, args: AbiValue) {
        ASK_DEPTH.with(|depth| depth.set(depth.get().saturating_add(1)));
        self.bus.send(&self.name, &peer, &method, lift_wire(&args));
        let remaining = ASK_DEPTH.with(|depth| {
            let next = depth.get().saturating_sub(1);
            depth.set(next);
            next
        });
        if remaining == 0 {
            self.bus.flush_deferred();
        }
    }

    fn emit(&mut self, method: String, args: AbiValue) -> bool {
        ASK_DEPTH.with(|depth| depth.set(depth.get().saturating_add(1)));
        let veto = self.bus.emit(&self.name, &method, lift_wire(&args));
        let remaining = ASK_DEPTH.with(|depth| {
            let next = depth.get().saturating_sub(1);
            depth.set(next);
            next
        });
        if remaining == 0 {
            self.bus.flush_deferred();
        }
        veto
    }

    fn voxel(&mut self, x: i32, y: i32, z: i32) -> AbiValue {
        lower_wire(&self.bus.voxel(x, y, z))
    }

    fn voxel_set(&mut self, x: i32, y: i32, z: i32, name: String) {
        ::hanga::queue_voxel_write(x, y, z, name);
    }

    fn player(&mut self) -> AbiValue {
        lower_wire(&match ::hanga::player_snap() {
            Some(snap) => player_snapshot_wire(
                &snap,
                self.topics.contains("evaluate-action") || self.topics.contains("tick"),
                self.topics.contains("wallet-after"),
            ),
            None => wire_empty(),
        })
    }

    fn after(&mut self, ms: i32, method: String, args: AbiValue) {
        queue_after(self.name.clone(), ms, method, lift_wire(&args));
    }
}

/// A persistent WASM context that holds the main Store and Instance.
/// Used by the main thread for game logic, preserving global mod state
/// (e.g. static variables) between game ticks.
pub struct MainModContext {
    pub store: Store<HostData>,
    pub bindings: Plugin,
    pub topics: HashSet<String>,
    wasm_path: PathBuf,
    is_lead: bool,
    last_restart: Option<Instant>,
}

impl MainModContext {
    pub fn offers(&self, topic: &str) -> bool {
        self.topics.is_empty() || self.topics.contains(topic)
    }

    fn wake(&mut self) {
        let gp = self.bindings.hanga_engine_guest();
        let _ = gp.call_ready(&mut self.store);
        let methods = gp
            .call_invoke(&mut self.store, "host", "methods", &lower_wire(&wire_empty()))
            .map(|value| lift_wire(&value))
            .unwrap_or_else(|_| wire_empty());
        self.topics = parse_topics(&methods);
        self.store.data_mut().topics = self.topics.clone();
    }

    pub fn call(&mut self, from: &str, topic: &str, payload: &Wire) -> Wire {
        if topic != "has" && topic != "methods" && !self.offers(topic) {
            return wire_empty();
        }
        match self
            .bindings
            .hanga_engine_guest()
            .call_invoke(&mut self.store, from, topic, &lower_wire(payload))
        {
            Ok(value) => lift_wire(&value),
            Err(_) => {
                self.restart_after_trap();
                wire_fail("trap")
            }
        }
    }

    fn restart_after_trap(&mut self) {
        let name = self.store.data().name.clone();
        let now = Instant::now();
        if !trap_restart_ready(self.last_restart, now) {
            warn!("mod {name} trapped again; waiting before another restart");
            return;
        }
        let bus = Arc::clone(&self.store.data().bus);
        let path = self.wasm_path.clone();
        let lead = self.is_lead;
        warn!("mod {name} trapped; restarting {}", path.display());
        match ModRuntime::instantiate(&path, &name, bus, lead) {
            Some(mut fresh) => {
                fresh.wake();
                fresh.last_restart = Some(now);
                *self = fresh;
            }
            None => {
                self.last_restart = Some(now);
                error!("mod {name} trapped and failed to restart");
            }
        }
    }

    pub fn bus(&mut self, topic: &str, payload: &Wire) -> Wire {
        self.call("host", topic, payload)
    }

    pub fn bus_node(&mut self, topic: &str, payload: &Wire) -> ::hanga::kit::Node {
        node_from_wire(&self.bus(topic, payload))
    }

    pub fn bus_text(&mut self, topic: &str) -> String {
        match self.bus(topic, &wire_empty()) {
            Wire::Text(text) => text,
            Wire::Dict(fields) => fields
                .iter()
                .map(|field| field.key.clone())
                .collect::<Vec<_>>()
                .join(","),
            _ => String::new(),
        }
    }

    pub fn bus_text_payload(&mut self, topic: &str, payload: &Wire) -> String {
        match self.bus(topic, payload) {
            Wire::Text(text) => text,
            _ => String::new(),
        }
    }

    pub fn bus_i32(&mut self, topic: &str, payload: &Wire, fallback: i32) -> i32 {
        reply_i32(&self.bus(topic, payload), fallback)
    }

    pub fn bus_xyz(&mut self, topic: &str, payload: &Wire, fallback: (i32, i32, i32)) -> (i32, i32, i32) {
        payload_xyz(&self.bus(topic, payload), fallback)
    }

    pub fn bus_xyz_name(
        &mut self,
        topic: &str,
        payload: &Wire,
        fallback: (i32, i32, i32, String),
    ) -> (i32, i32, i32, String) {
        let reply = self.bus(topic, payload);
        if wire_is_empty(&reply) || wire_is_fail(&reply) {
            return fallback;
        }
        (
            payload_i64(&reply, "x") as i32,
            payload_i64(&reply, "y") as i32,
            payload_i64(&reply, "z") as i32,
            payload_text(&reply, "name").to_string(),
        )
    }

    pub fn query_voxel(&mut self, x: i32, y: i32, z: i32) -> i32 {
        self.bindings
            .hanga_engine_guest()
            .call_query_voxel(&mut self.store, x, y, z)
            .unwrap_or(0)
    }

    pub fn voxel_catalog(&mut self) -> Vec<String> {
        self.bindings
            .hanga_engine_guest()
            .call_voxel_catalog(&mut self.store)
            .unwrap_or_default()
    }
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
    woken: bool,
    _watcher: notify::RecommendedWatcher,
}

impl ModRuntime {
    pub fn lead_name(&self) -> &str {
        &self.lead_name
    }

    /// Later packs first, then lead. First real reply wins (Luanti override_item).
    /// `fail` stops the walk (OTP `{error, Reason}` is not a missing method).
    /// A locked pack is `fail("busy")`, not a blocking wait.
    pub fn ask_any(&self, method: &str, args: &Wire) -> Wire {
        let mut replies = Vec::new();
        for pack in self.packs.iter().rev() {
            replies.push(match pack.context.try_lock() {
                Ok(mut guard) => guard
                    .as_mut()
                    .map(|ctx| ctx.call("host", method, args))
                    .unwrap_or_else(wire_empty),
                Err(_) => wire_fail("busy"),
            });
        }
        replies.push(match self.context.try_lock() {
            Ok(mut guard) => guard
                .as_mut()
                .map(|ctx| ctx.call("host", method, args))
                .unwrap_or_else(wire_empty),
            Err(_) => wire_fail("busy"),
        });
        first_override(replies)
    }

    pub fn ask_any_text(&self, method: &str, args: &Wire) -> String {
        wire_as_text(&self.ask_any(method, args))
    }

    pub fn ask_any_node(&self, method: &str, args: &Wire) -> ::hanga::kit::Node {
        node_from_wire(&self.ask_any(method, args))
    }

    pub fn wake_all(&mut self) {
        if let Ok(mut guard) = self.context.lock() {
            if let Some(ctx) = guard.as_mut() {
                ctx.wake();
            }
        }
        for pack in &self.packs {
            if let Ok(mut guard) = pack.context.lock() {
                if let Some(ctx) = guard.as_mut() {
                    ctx.wake();
                }
            }
        }
        self.notify_all("on-mods-loaded", &wire_empty());
        self.woken = true;
    }

    pub fn flush_after(&self) {
        flush_after_bus(&*self.bus);
    }

    /// OTP `gen_event:notify`. No reply, no veto. Mailbox if a pack is in a call.
    pub fn notify_all(&self, method: &str, args: &Wire) {
        self.bus.send("host", "", method, args.clone());
    }

    /// OTP `gen_event:call` to every pack. Veto flag, `fail`, or a busy listener
    /// stops the engine action (do not skip `before-dig`).
    pub fn emit_all(&self, method: &str, args: &Wire) -> bool {
        let mut veto = false;
        match self.context.try_lock() {
            Ok(mut guard) => {
                if let Some(ctx) = guard.as_mut() {
                    if emit_blocks(Ok(&ctx.call("host", method, args))) {
                        veto = true;
                    }
                }
            }
            Err(_) => veto = true,
        }
        for pack in &self.packs {
            match pack.context.try_lock() {
                Ok(mut guard) => {
                    if let Some(ctx) = guard.as_mut() {
                        if emit_blocks(Ok(&ctx.call("host", method, args))) {
                            veto = true;
                        }
                    }
                }
                Err(_) => veto = true,
            }
        }
        veto
    }

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
        let bus: Arc<dyn EngineBus> = Arc::new(LiveBus::new(
            lead_name.clone(),
            Arc::clone(&context),
            Vec::new(),
        ));
        *context.lock().unwrap() = Self::instantiate(&watch_path, &lead_name, Arc::clone(&bus), true);

        Self {
            context,
            packs: Vec::new(),
            rx,
            watch_path: watch_path.clone(),
            lead_name,
            bus,
            loaded_paths: vec![watch_path],
            woken: false,
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
        // Kotlin/Wasm guests (hanga-contrib) use WasmGC and funcrefs.
        config.wasm_reference_types(true);
        config.wasm_function_references(true);
        config.wasm_gc(true);
        let _ = config.wasm_tail_call(true);
        let _ = config.wasm_exceptions(true);
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
                topics: HashSet::new(),
            },
        );
        let mut linker = Linker::new(&engine);
        Plugin::add_to_linker::<HostData, HasSelf<_>>(&mut linker, |data| data).ok()?;
        let bindings = Plugin::instantiate(&mut store, &component, &linker).ok()?;
        let gp = bindings.hanga_engine_guest();
        let abi = gp.call_abi(&mut store).unwrap_or(0);
        if abi != ABI_MAJOR {
            error!(
                "Refusing {name}: ABI {abi} (host wants {ABI_MAJOR})"
            );
            return None;
        }
        let methods = gp
            .call_invoke(&mut store, "host", "methods", &lower_wire(&wire_empty()))
            .map(|value| lift_wire(&value))
            .unwrap_or_else(|_| wire_empty());
        let topics = parse_topics(&methods);
        store.data_mut().topics = topics.clone();

        Some(MainModContext {
            store,
            bindings,
            topics,
            wasm_path: path.to_path_buf(),
            is_lead: publish_shared,
            last_restart: None,
        })
    }

    /// Lead is `mods[0]` (terrain + gameplay). Later entries are packs (vehicles, agents, extra voxels).
    pub fn load_collection(&mut self, mods: &[(String, PathBuf)]) {
        if mods.is_empty() {
            return;
        }
        let paths: Vec<PathBuf> = mods.iter().map(|(_, path)| path.clone()).collect();
        let already = self
            .context
            .lock()
            .ok()
            .map(|ctx| ctx.is_some())
            .unwrap_or(false);
        if self.loaded_paths == paths && already {
            if !self.woken {
                self.wake_all();
            }
            return;
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
        let bus: Arc<dyn EngineBus> = Arc::new(LiveBus::new(
            lead_name.clone(),
            Arc::clone(&self.context),
            pack_slots
                .iter()
                .map(|(name, _, ctx)| (name.clone(), Arc::clone(ctx)))
                .collect(),
        ));
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
        self.wake_all();
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
    runtime.wake_all();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn fail_is_not_empty() {
        assert!(wire_is_empty(&Wire::Empty));
        assert!(wire_is_empty(&Wire::Text(String::new())));
        assert!(!wire_is_empty(&wire_fail("busy")));
        assert!(wire_is_fail(&wire_fail("self")));
    }

    #[test]
    fn player_snapshot_omits_unadvertised_keys() {
        let snap = ::hanga::PlayerSnap {
            x: 1.0,
            y: 2.0,
            z: 3.0,
            yaw: 0.5,
            state: 4,
            wallet: 9,
        };
        let pose = node_from_wire(&player_snapshot_wire(&snap, false, false));
        assert_eq!(pose.get("x").and_then(::hanga::kit::Node::as_f32), Some(1.0));
        assert!(pose.get("state").is_none());
        assert!(pose.get("wallet").is_none());
        let full = node_from_wire(&player_snapshot_wire(&snap, true, true));
        assert_eq!(full.get("state").and_then(::hanga::kit::Node::as_i32), Some(4));
        assert_eq!(full.get("wallet").and_then(::hanga::kit::Node::as_i32), Some(9));
    }

    #[test]
    fn trap_restart_waits_two_seconds() {
        let t0 = Instant::now();
        assert!(trap_restart_ready(None, t0));
        assert!(!trap_restart_ready(
            Some(t0),
            t0 + std::time::Duration::from_millis(1999)
        ));
        assert!(trap_restart_ready(
            Some(t0),
            t0 + std::time::Duration::from_millis(2000)
        ));
    }

    #[test]
    fn fail_roundtrips_the_arena() {
        let lowered = lower_wire(&wire_fail("noproc"));
        match lift_wire(&lowered) {
            Wire::Fail(reason) => assert_eq!(reason, "noproc"),
            other => panic!("{other:?}"),
        }
    }

    #[test]
    fn mailbox_sheds_oldest_when_full() {
        let mut pending = vec![1, 2, 3];
        assert!(mailbox_evict_if_full(&mut pending, 3));
        pending.push(4);
        assert_eq!(pending, vec![2, 3, 4]);
        assert!(!mailbox_evict_if_full(&mut pending, 8));
        pending.push(5);
        assert_eq!(pending, vec![2, 3, 4, 5]);
    }

    #[test]
    fn held_mutex_is_busy_for_call_and_enqueue_for_cast() {
        let slot = Mutex::new(Some(1u8));
        let _hold = slot.lock().unwrap();
        assert!(slot.try_lock().is_err());
        let call = match slot.try_lock() {
            Ok(_) => wire_empty(),
            Err(_) => wire_fail("busy"),
        };
        assert!(wire_is_fail(&call));
        let mut mailbox = Vec::new();
        if slot.try_lock().is_err() {
            mailbox.push("cast");
        }
        assert_eq!(mailbox, ["cast"]);
    }

    #[test]
    fn methods_list_is_topics() {
        let topics = parse_topics(&Wire::Items(vec![
            wire_text("ping"),
            wire_text("gravity"),
        ]));
        assert!(topics.contains("ping") && topics.contains("gravity"));
    }

    #[test]
    fn name_replies_ignore_dicts() {
        assert_eq!(wire_as_text(&wire_text("glass")), "glass");
        assert_eq!(
            wire_as_text(&wire_bag(vec![("name", Wire::Text("glass".into()))])),
            ""
        );
    }

    #[test]
    fn reply_range_empty_fallback_and_fail_closed() {
        assert_eq!(reply_range(&wire_empty(), 10.0), 10.0);
        assert_eq!(reply_range(&Wire::Text(String::new()), 10.0), 10.0);
        assert_eq!(reply_range(&wire_fail("busy"), 10.0), 0.0);
        assert_eq!(reply_range(&Wire::Float(30.0), 10.0), 30.0);
    }

    #[test]
    fn reply_i32_and_xyz_empty_shapes_use_fallback() {
        assert_eq!(reply_i32(&wire_empty(), 7), 7);
        assert_eq!(reply_i32(&Wire::Text(String::new()), 7), 7);
        assert_eq!(reply_i32(&wire_fail("busy"), 7), 7);
        assert_eq!(reply_i32(&Wire::Int(4), 7), 4);
        assert_eq!(payload_xyz(&wire_empty(), (1, 2, 3)), (1, 2, 3));
        assert_eq!(
            payload_xyz(&Wire::Text(String::new()), (1, 2, 3)),
            (1, 2, 3)
        );
        assert_eq!(payload_xyz(&wire_fail("busy"), (1, 2, 3)), (1, 2, 3));
    }

    #[test]
    fn nested_wire_becomes_a_node_tree() {
        let wire = Wire::Dict(vec![WireField {
            key: "tires".into(),
            value: Wire::Items(vec![wire_text("wheel")]),
        }]);
        let node = node_from_wire(&wire);
        assert_eq!(node.get("tires").unwrap().names(), vec!["wheel"]);
    }

    #[test]
    fn emit_blocks_on_busy_fail_and_veto() {
        assert!(emit_blocks(Err(())));
        assert!(emit_blocks(Ok(&wire_fail("trap"))));
        assert!(emit_blocks(Ok(&wire_fail("busy"))));
        assert!(emit_blocks(Ok(&Wire::Flag(true))));
        assert!(!emit_blocks(Ok(&wire_empty())));
        assert!(!emit_blocks(Ok(&wire_text("ok"))));
    }

    #[test]
    fn first_override_stops_on_fail() {
        assert!(matches!(
            first_override([wire_empty(), wire_fail("busy"), wire_text("pong")]),
            Wire::Fail(reason) if reason == "busy"
        ));
        assert_eq!(
            wire_as_text(&first_override([wire_empty(), wire_text("pong")])),
            "pong"
        );
        assert!(wire_is_empty(&first_override([wire_empty(), Wire::Text(String::new())])));
    }

    #[test]
    fn parse_topics_csv_dict_and_items() {
        let csv = parse_topics(&wire_text("ping, gravity ,"));
        assert!(csv.contains("ping") && csv.contains("gravity"));
        let dict = parse_topics(&wire_bag(vec![("ping", Wire::Flag(true))]));
        assert!(dict.contains("ping"));
    }

    #[test]
    fn live_bus_otp_errors_and_mailbox() {
        let pack = Arc::new(Mutex::new(None));
        let bus = LiveBus::new(
            "lead".into(),
            Arc::new(Mutex::new(None)),
            vec![("pack".into(), Arc::clone(&pack))],
        );
        assert!(matches!(
            bus.invoke("lead", "lead", "ping", wire_empty()),
            Wire::Fail(reason) if reason == "self"
        ));
        assert!(matches!(
            bus.invoke("lead", "gone", "ping", wire_empty()),
            Wire::Fail(reason) if reason == "noproc"
        ));
        assert!(wire_is_empty(&bus.invoke("lead", "pack", "ping", wire_empty())));
        assert!(bus.has_mod("pack") && bus.has_mod("lead"));
        assert_eq!(bus.peers("pack"), vec!["lead".to_string()]);

        let hold = pack.lock().unwrap();
        assert!(matches!(
            bus.invoke("lead", "pack", "ping", wire_empty()),
            Wire::Fail(reason) if reason == "busy"
        ));
        bus.send("lead", "pack", "hello", wire_empty());
        assert_eq!(bus.pending.lock().unwrap().len(), 1);
        assert!(bus.emit("lead", "before-dig", wire_empty()));
        bus.flush_deferred();
        assert_eq!(bus.pending.lock().unwrap().len(), 1);
        drop(hold);
        bus.flush_deferred();
        assert!(bus.pending.lock().unwrap().is_empty());
    }

    fn mods_wasm(name: &str) -> Option<PathBuf> {
        let dir = std::env::var_os("HANGA_MODS")?;
        let path = PathBuf::from(dir).join(format!("{name}.wasm"));
        path.is_file().then_some(path)
    }

    fn instantiate_live(
        name: &str,
    ) -> Option<(
        Arc<LiveBus>,
        Arc<Mutex<Option<MainModContext>>>,
        MainModContext,
    )> {
        let path = mods_wasm(name)?;
        let slot = Arc::new(Mutex::new(None));
        let bus = Arc::new(LiveBus::new(name.into(), Arc::clone(&slot), Vec::new()));
        let ctx = ModRuntime::instantiate(
            &path,
            name,
            Arc::clone(&bus) as Arc<dyn EngineBus>,
            false,
        )
        .unwrap_or_else(|| panic!("load {name}.wasm"));
        Some((bus, slot, ctx))
    }

    fn instantiate_live_pair(
        lead_name: &str,
        pack_name: &str,
    ) -> Option<(
        Arc<LiveBus>,
        Arc<Mutex<Option<MainModContext>>>,
        Arc<Mutex<Option<MainModContext>>>,
    )> {
        let lead_path = mods_wasm(lead_name)?;
        let pack_path = mods_wasm(pack_name)?;
        let lead = Arc::new(Mutex::new(None));
        let pack = Arc::new(Mutex::new(None));
        let bus = Arc::new(LiveBus::new(
            lead_name.into(),
            Arc::clone(&lead),
            vec![(pack_name.into(), Arc::clone(&pack))],
        ));
        let host: Arc<dyn EngineBus> = Arc::clone(&bus) as Arc<dyn EngineBus>;
        *lead.lock().unwrap() = Some(
            ModRuntime::instantiate(&lead_path, lead_name, Arc::clone(&host), true)
                .unwrap_or_else(|| panic!("load {lead_name}.wasm")),
        );
        *pack.lock().unwrap() = Some(
            ModRuntime::instantiate(&pack_path, pack_name, host, false)
                .unwrap_or_else(|| panic!("load {pack_name}.wasm")),
        );
        Some((bus, lead, pack))
    }

    fn instantiate_live_runtime(lead: &str, pack: &str) -> Option<ModRuntime> {
        let lead_path = mods_wasm(lead)?;
        let pack_path = mods_wasm(pack)?;
        let mut runtime = ModRuntime::new(&lead_path);
        runtime.load_collection(&[(lead.into(), lead_path), (pack.into(), pack_path)]);
        Some(runtime)
    }

    #[test]
    fn live_wasm_testbed_ping_and_self_cast() {
        let Some((bus, slot, ctx)) = instantiate_live("testbed") else {
            return;
        };
        assert!(ctx.offers("ping"));
        assert!(ctx.offers("veto"));
        *slot.lock().unwrap() = Some(ctx);

        assert_eq!(
            wire_as_text(&bus.invoke("host", "testbed", "ping", wire_empty())),
            "pong"
        );
        assert!(wire_is_empty(&bus.invoke(
            "host",
            "testbed",
            "bark",
            wire_empty()
        )));
        assert!(bus.logs.lock().unwrap().iter().any(|(from, level, message)| {
            from == "testbed" && level == "warn" && message == "woof"
        }));
        {
            let mut guard = slot.lock().unwrap();
            let ctx = guard.as_mut().expect("testbed");
            let names = ctx.voxel_catalog();
            assert_eq!(
                ::hanga::catalog_name(&names, ctx.query_voxel(0, 0, 0)),
                Some("concrete")
            );
            assert_eq!(
                ::hanga::catalog_name(&names, ctx.query_voxel(1, 0, 0)),
                Some("glass")
            );
            assert_eq!(
                ::hanga::catalog_name(&names, ctx.query_voxel(0, 1, 0)),
                Some("air")
            );
            let gravity = ctx.bus_node("gravity", &wire_empty());
            assert_eq!(
                gravity.get("kind").map(::hanga::kit::Node::text).as_deref(),
                Some("none")
            );
            assert_eq!(
                gravity.get("jump").and_then(::hanga::kit::Node::as_f32),
                Some(2.0)
            );
        }
        assert!(bus.emit("host", "veto", wire_empty()));
        assert!(!bus.emit("host", "ping", wire_empty()));
        ::hanga::set_player_snap(::hanga::PlayerSnap {
            x: 1.5,
            y: 2.0,
            z: 3.0,
            yaw: 0.25,
            state: 2,
            wallet: 40,
        });
        let selfie = node_from_wire(&bus.invoke("host", "testbed", "selfie", wire_empty()));
        assert_eq!(
            selfie.get("x").and_then(::hanga::kit::Node::as_f32),
            Some(1.5)
        );
        assert_eq!(
            selfie.get("state").and_then(::hanga::kit::Node::as_i32),
            Some(2)
        );
        assert_eq!(
            selfie.get("wallet").and_then(::hanga::kit::Node::as_i32),
            Some(40)
        );
        ::hanga::clear_player_snap();
        assert_eq!(
            wire_as_text(&bus.invoke("host", "testbed", "who", wire_empty())),
            "testbed"
        );
        assert!(matches!(
            bus.invoke("host", "testbed", "see", Wire::Text("testbed".into())),
            Wire::Flag(true)
        ));
        assert!(matches!(
            bus.invoke("host", "testbed", "see", Wire::Text("missing".into())),
            Wire::Flag(false)
        ));
        assert_eq!(
            payload_i64(&bus.invoke("host", "testbed", "count", wire_empty()), "value"),
            0
        );
        assert!(wire_is_empty(&bus.invoke(
            "host",
            "testbed",
            "later",
            wire_empty()
        )));
        flush_after_bus(&*bus);
        assert_eq!(
            payload_i64(&bus.invoke("host", "testbed", "count", wire_empty()), "value"),
            1
        );
        assert!(matches!(
            bus.invoke("host", "testbed", "boom", wire_empty()),
            Wire::Fail(reason) if reason == "trap"
        ));
        assert_eq!(
            payload_i64(&bus.invoke("host", "testbed", "count", wire_empty()), "value"),
            0
        );
        assert!(wire_is_empty(&bus.invoke(
            "host",
            "testbed",
            "toss",
            wire_bag(vec![
                ("peer", wire_text("testbed")),
                ("method", wire_text("note")),
            ])
        )));
        assert_eq!(bus.pending.lock().unwrap().len(), 1);
        bus.flush_deferred();
        assert_eq!(
            payload_i64(&bus.invoke("host", "testbed", "count", wire_empty()), "value"),
            1
        );
        let t0 = payload_i64(&bus.invoke("host", "testbed", "clock", wire_empty()), "value");
        let t1 = payload_i64(&bus.invoke("host", "testbed", "clock", wire_empty()), "value");
        assert!(t0 >= 0 && t1 >= t0);
        let crew = node_from_wire(&bus.invoke("host", "testbed", "crew", wire_empty()));
        assert!(crew.items().is_empty());
        assert!(matches!(
            bus.invoke("host", "testbed", "yell", wire_empty()),
            Wire::Flag(false)
        ));
        assert!(matches!(
            bus.invoke("testbed", "testbed", "ping", wire_empty()),
            Wire::Fail(reason) if reason == "self"
        ));
        bus.send("testbed", "testbed", "hello", wire_empty());
        assert_eq!(bus.pending.lock().unwrap().len(), 1);
        bus.flush_deferred();
        assert!(bus.pending.lock().unwrap().is_empty());
    }

    #[test]
    fn live_wasm_testbed_mailbox_cap_and_drain() {
        let Some((bus, slot, ctx)) = instantiate_live("testbed") else {
            return;
        };
        *slot.lock().unwrap() = Some(ctx);
        {
            let hold = slot.lock().unwrap();
            bus.send("host", "testbed", "note", wire_empty());
            bus.flush_deferred();
            assert_eq!(bus.pending.lock().unwrap().len(), 1);
            for _ in 0..MAILBOX_CAP {
                bus.send("host", "testbed", "note", wire_empty());
            }
            assert_eq!(bus.pending.lock().unwrap().len(), MAILBOX_CAP);
            drop(hold);
        }
        bus.flush_deferred();
        assert!(bus.pending.lock().unwrap().is_empty());
        assert_eq!(
            payload_i64(&bus.invoke("host", "testbed", "count", wire_empty()), "value"),
            MAILBOX_CAP as i64
        );
    }

    #[test]
    fn live_wasm_testbed_trap_cooldown_keeps_dead_store() {
        let Some((bus, slot, ctx)) = instantiate_live("testbed") else {
            return;
        };
        *slot.lock().unwrap() = Some(ctx);
        assert!(matches!(
            bus.invoke("host", "testbed", "boom", wire_empty()),
            Wire::Fail(reason) if reason == "trap"
        ));
        assert_eq!(
            payload_i64(&bus.invoke("host", "testbed", "count", wire_empty()), "value"),
            0
        );
        assert!(matches!(
            bus.invoke("host", "testbed", "boom", wire_empty()),
            Wire::Fail(reason) if reason == "trap"
        ));
        assert!(matches!(
            bus.invoke("host", "testbed", "count", wire_empty()),
            Wire::Fail(reason) if reason == "trap"
        ));
    }

    #[test]
    fn live_wasm_testbed_hello_name_has_methods() {
        let Some((bus, slot, ctx)) = instantiate_live("testbed") else {
            return;
        };
        *slot.lock().unwrap() = Some(ctx);
        assert_eq!(
            wire_as_text(&bus.invoke("host", "testbed", "hello", wire_empty())),
            "hello host"
        );
        assert_eq!(
            wire_as_text(&bus.invoke("host", "testbed", "name", wire_empty())),
            "testbed"
        );
        assert!(matches!(
            bus.invoke("host", "testbed", "has", Wire::Text("ping".into())),
            Wire::Flag(true)
        ));
        assert!(matches!(
            bus.invoke("host", "testbed", "has", Wire::Text("nope".into())),
            Wire::Flag(false)
        ));
        let methods = parse_topics(&bus.invoke("host", "testbed", "methods", wire_empty()));
        assert!(methods.contains("ping") && methods.contains("hello"));
    }

    #[test]
    fn live_wasm_two_packs_ready_greets_peer() {
        let Some((bus, lead, pack)) = instantiate_live_pair("testbed", "urban_chaos") else {
            return;
        };
        {
            let hold = pack.lock().unwrap();
            {
                let mut guard = lead.lock().unwrap();
                guard.as_mut().expect("testbed").wake();
            }
            assert!(
                bus.pending
                    .lock()
                    .unwrap()
                    .iter()
                    .any(|queued| queued.topic == "hello" && queued.from == "testbed")
            );
            drop(hold);
        }
        bus.flush_deferred();
        assert!(bus.pending.lock().unwrap().is_empty());
        assert!(bus.logs.lock().unwrap().iter().any(|(from, level, message)| {
            from == "testbed" && level == "info" && message == "testbed ready"
        }));
    }

    #[test]
    fn live_wasm_two_packs_empty_peer_ping() {
        let Some((bus, _lead, _pack)) = instantiate_live_pair("testbed", "urban_chaos") else {
            return;
        };
        assert!(bus.has_mod("testbed") && bus.has_mod("urban_chaos"));
        assert_eq!(bus.peers("testbed"), vec!["urban_chaos".to_string()]);
        assert_eq!(
            wire_as_text(&bus.invoke("host", "", "ping", wire_empty())),
            "pong"
        );
        assert_eq!(
            wire_as_text(&bus.invoke("testbed", "urban_chaos", "ping", wire_empty())),
            "pong"
        );
        assert!(matches!(
            bus.invoke("host", "testbed", "refuse", wire_empty()),
            Wire::Fail(reason) if reason == "busy"
        ));
        assert!(matches!(
            bus.invoke("host", "", "refuse", wire_empty()),
            Wire::Fail(reason) if reason == "busy"
        ));
        let crew = node_from_wire(&bus.invoke("host", "testbed", "crew", wire_empty()));
        assert_eq!(
            crew.items()
                .iter()
                .map(::hanga::kit::Node::text)
                .collect::<Vec<_>>(),
            vec!["urban_chaos".to_string()]
        );
        assert_eq!(
            wire_as_text(&bus.invoke(
                "host",
                "testbed",
                "ask",
                wire_bag(vec![
                    ("peer", wire_text("urban_chaos")),
                    ("method", wire_text("ping")),
                ])
            )),
            "pong"
        );
        assert!(matches!(
            bus.invoke(
                "host",
                "testbed",
                "ask",
                wire_bag(vec![
                    ("peer", wire_text("gone")),
                    ("method", wire_text("ping")),
                ])
            ),
            Wire::Fail(reason) if reason == "noproc"
        ));
        assert!(matches!(
            bus.invoke(
                "host",
                "testbed",
                "ask",
                wire_bag(vec![
                    ("peer", wire_text("testbed")),
                    ("method", wire_text("ping")),
                ])
            ),
            Wire::Fail(reason) if reason == "self"
        ));
        assert!(wire_is_empty(&bus.invoke(
            "host",
            "testbed",
            "toss",
            wire_bag(vec![
                ("peer", wire_text("urban_chaos")),
                ("method", wire_text("ping")),
            ])
        )));
        assert!(bus.pending.lock().unwrap().is_empty());
        assert_eq!(
            wire_as_text(&bus.invoke(
                "host",
                "",
                "craft-result",
                wire_bag(vec![
                    ("a", wire_text("concrete")),
                    ("b", wire_text("glass")),
                ])
            )),
            "tile"
        );
        let at = wire_bag(vec![
            ("x", Wire::Int(0)),
            ("y", Wire::Int(0)),
            ("z", Wire::Int(0)),
        ]);
        let world = node_from_wire(&bus.invoke("host", "testbed", "probe", at));
        assert_eq!(
            world.get("name").map(::hanga::kit::Node::text).as_deref(),
            Some("concrete")
        );
        assert!(!world.get("edit").is_some_and(::hanga::kit::Node::as_flag));
        let lead_voxel = node_from_wire(&bus.voxel(0, 0, 0));
        assert_eq!(
            lead_voxel.get("name").map(::hanga::kit::Node::text).as_deref(),
            Some("concrete")
        );
        assert!(!lead_voxel.get("edit").is_some_and(::hanga::kit::Node::as_flag));
        let painted = wire_bag(vec![
            ("x", Wire::Int(99)),
            ("y", Wire::Int(1)),
            ("z", Wire::Int(99)),
            ("name", wire_text("glass")),
        ]);
        assert!(wire_is_empty(&bus.invoke(
            "host",
            "testbed",
            "paint",
            painted
        )));
        let overlay = node_from_wire(&bus.invoke(
            "host",
            "testbed",
            "probe",
            wire_bag(vec![
                ("x", Wire::Int(99)),
                ("y", Wire::Int(1)),
                ("z", Wire::Int(99)),
            ]),
        ));
        assert_eq!(
            overlay.get("name").map(::hanga::kit::Node::text).as_deref(),
            Some("glass")
        );
        assert!(overlay.get("edit").is_some_and(::hanga::kit::Node::as_flag));
        let host_overlay = node_from_wire(&bus.voxel(99, 1, 99));
        assert_eq!(
            host_overlay
                .get("name")
                .map(::hanga::kit::Node::text)
                .as_deref(),
            Some("glass")
        );
        assert!(host_overlay.get("edit").is_some_and(::hanga::kit::Node::as_flag));
        ::hanga::overlay_clear();
        let _ = ::hanga::take_voxel_writes();
    }

    #[test]
    fn live_wasm_mod_runtime_ask_any_and_emit_all() {
        let Some(runtime) = instantiate_live_runtime("testbed", "urban_chaos") else {
            return;
        };
        assert_eq!(runtime.lead_name(), "testbed");
        assert_eq!(runtime.ask_any_text("ping", &wire_empty()), "pong");
        assert_eq!(
            runtime.ask_any_text(
                "craft-result",
                &wire_bag(vec![
                    ("a", wire_text("concrete")),
                    ("b", wire_text("glass")),
                ])
            ),
            "tile"
        );
        assert!(matches!(
            runtime.ask_any("refuse", &wire_empty()),
            Wire::Fail(reason) if reason == "busy"
        ));
        assert!(runtime.emit_all("veto", &wire_empty()));
        assert!(runtime.emit_all("refuse", &wire_empty()));
        assert!(!runtime.emit_all("ping", &wire_empty()));
        assert_eq!(
            reply_range(
                &runtime.ask_any("action-range", &wire_text("explode")),
                10.0
            ),
            30.0
        );
        assert_eq!(reply_range(&runtime.ask_any("nope", &wire_empty()), 10.0), 10.0);
        assert_eq!(
            reply_range(&runtime.ask_any("refuse", &wire_empty()), 10.0),
            0.0
        );
        runtime.notify_all("hello", &wire_empty());
    }

    #[test]
    fn live_wasm_mod_runtime_busy_pack_is_fail_closed() {
        let Some(runtime) = instantiate_live_runtime("testbed", "urban_chaos") else {
            return;
        };
        {
            let _hold = runtime.packs[0].context.lock().unwrap();
            assert!(matches!(
                runtime.ask_any("ping", &wire_empty()),
                Wire::Fail(reason) if reason == "busy"
            ));
            assert!(runtime.emit_all("ping", &wire_empty()));
        }
        assert_eq!(runtime.ask_any_text("ping", &wire_empty()), "pong");
        assert!(!runtime.emit_all("ping", &wire_empty()));
    }

    #[test]
    fn live_wasm_urban_chaos_loot_and_kits() {
        let Some((_bus, slot, mut ctx)) = instantiate_live("urban_chaos") else {
            return;
        };
        let names = ctx.voxel_catalog();
        assert!(names.contains(&"asphalt".to_string()));
        let index = ctx.query_voxel(0, 0, 0);
        assert!(::hanga::catalog_name(&names, index).is_some());
        assert_eq!(
            ctx.bus_text_payload("loot-item", &wire_text("glass")),
            "glass"
        );
        assert!(ctx
            .bus_text_payload("loot-item", &wire_text("asphalt"))
            .is_empty());
        assert_eq!(
            ctx.bus_text_payload(
                "craft-result",
                &wire_bag(vec![
                    ("a", wire_text("concrete")),
                    ("b", wire_text("glass")),
                ])
            ),
            "tile"
        );
        let gravity = ctx.bus_node("gravity", &wire_empty());
        assert_eq!(
            gravity.get("kind").map(::hanga::kit::Node::text).as_deref(),
            Some("constant")
        );
        assert_eq!(gravity.get("y").and_then(::hanga::kit::Node::as_f32), Some(-9.81));
        let fracture = ctx.bus_node(
            "fracture-kit",
            &wire_bag(vec![
                ("voxel", wire_text("glass")),
                ("action", wire_text("break")),
            ]),
        );
        assert!(fracture.get("can").is_some_and(::hanga::kit::Node::as_flag));
        assert_eq!(
            fracture.get("spread").and_then(::hanga::kit::Node::as_i32),
            Some(3)
        );
        assert_eq!(
            ctx.bus_i32(
                "evaluate-action",
                &wire_bag(vec![
                    ("action", wire_text("explode")),
                    ("state", Wire::Int(0)),
                ]),
                -1
            ),
            5
        );
        *slot.lock().unwrap() = Some(ctx);
    }

    #[test]
    fn live_wasm_urban_chaos_world_and_steer() {
        let Some((_bus, slot, mut ctx)) = instantiate_live("urban_chaos") else {
            return;
        };
        assert_eq!(
            ctx.bus_xyz("player-spawn", &wire_empty(), (0, 0, 0)),
            (504, 2, 508)
        );
        assert_eq!(
            ctx.bus_i32("vehicle-spawn-count", &wire_empty(), 0),
            6
        );
        let car = ctx.bus_node("vehicle-kit", &wire_int(0));
        assert_eq!(
            car.get("kind").map(::hanga::kit::Node::text).as_deref(),
            Some("car")
        );
        assert!(!car.get("traffic").is_some_and(::hanga::kit::Node::as_flag));
        assert_eq!(
            ctx.bus_i32(
                "wallet-after",
                &wire_bag(vec![
                    ("action", wire_text("break")),
                    ("wallet", Wire::Int(10)),
                    ("extra", Wire::Int(0)),
                ]),
                -1
            ),
            15
        );
        assert_eq!(
            ctx.bus_text_payload(
                "voxel-label",
                &wire_bag(vec![
                    ("locale", wire_text("mi")),
                    ("voxel", wire_text("glass")),
                ])
            ),
            "karaihe"
        );
        assert_eq!(
            ctx.bus_i32(
                "economy-price",
                &wire_bag(vec![
                    ("base", Wire::Int(80)),
                    ("supply", Wire::Int(0)),
                    ("demand", Wire::Int(1)),
                ]),
                -1
            ),
            800
        );
        let mark = ctx.bus_node(
            "contract-mark",
            &wire_bag(vec![("kind", wire_text("smash-and-grab"))]),
        );
        assert_eq!(mark.get("x").and_then(::hanga::kit::Node::as_i32), Some(531));
        assert!(mark.get("take").is_some_and(::hanga::kit::Node::as_flag));
        assert_eq!(
            ctx.bus_i32("ambient-agent-count", &wire_empty(), 0),
            6
        );
        assert_eq!(
            ctx.bus_xyz_name(
                "ambient-agent-spawn",
                &wire_int(0),
                (0, 0, 0, String::new())
            ),
            (502, 2, 500, "pedestrian".into())
        );
        assert_eq!(
            ctx.bus_text_payload(
                "should-spawn-agent",
                &wire_bag(vec![
                    ("action", wire_text("break")),
                    ("old", Wire::Int(0)),
                    ("new", Wire::Int(1)),
                ])
            ),
            "cop"
        );
        assert_eq!(
            ctx.bus_node("action-range", &wire_bag(vec![("action", wire_text("explode"))]))
                .as_f32(),
            Some(30.0)
        );
        assert_eq!(
            ctx.bus_i32(
                "can-complete",
                &wire_bag(vec![
                    ("action", wire_text("accept_contract")),
                    ("state", Wire::Int(0)),
                    ("kind", wire_text("smash-and-grab")),
                    ("danger", Wire::Int(1)),
                    ("held", wire_text("")),
                    ("y", Wire::Int(0)),
                    ("vehicle", Wire::Flag(false)),
                    ("near", Wire::Flag(false)),
                ]),
                -1
            ),
            1
        );
        let crash = ctx.bus_node(
            "crash-kit",
            &wire_bag(vec![
                ("speed", Wire::Float(30.0)),
                ("solid", Wire::Flag(true)),
            ]),
        );
        assert_eq!(
            crash.get("severity").and_then(::hanga::kit::Node::as_i32),
            Some(100)
        );
        let fire = ctx.bus_node(
            "fire-kit",
            &wire_bag(vec![
                ("age", Wire::Int(0)),
                ("nearby", wire_text("glass")),
            ]),
        );
        assert!(fire.get("consume").is_some_and(::hanga::kit::Node::as_flag));
        assert!(!fire.get("out").is_some_and(::hanga::kit::Node::as_flag));
        assert_eq!(
            ctx.bus_i32(
                "tick",
                &wire_bag(vec![("state", Wire::Int(3)), ("dt", Wire::Int(8000))]),
                -1
            ),
            2
        );
        assert_eq!(
            ctx.bus_i32(
                "should-despawn-agent",
                &wire_bag(vec![
                    ("agent", wire_text("cop")),
                    ("state", Wire::Int(0)),
                ]),
                -1
            ),
            1
        );
        assert_eq!(
            ctx.bus_text_payload("story-event", &wire_int(0)),
            "quiet-streets"
        );
        let offer = ctx.bus_node("offer-contract", &wire_int(0));
        assert_eq!(
            offer.get("kind").map(::hanga::kit::Node::text).as_deref(),
            Some("smash-and-grab")
        );
        assert_eq!(
            offer.get("payout").and_then(::hanga::kit::Node::as_i32),
            Some(250)
        );
        assert_eq!(
            ctx.bus_i32("economy-params", &wire_empty(), 0),
            (5 << 16) | 8
        );
        let steer = ctx.bus_node(
            "steer",
            &wire_bag(vec![
                ("role", wire_text("cop")),
                ("cur-x", Wire::Float(0.0)),
                ("cur-z", Wire::Float(0.0)),
                ("target-x", Wire::Float(10.0)),
                ("target-z", Wire::Float(0.0)),
            ]),
        );
        assert_eq!(steer.get("vx").and_then(::hanga::kit::Node::as_f32), Some(8.0));
        let traffic = ctx.bus_node(
            "steer",
            &wire_bag(vec![
                ("role", wire_text("traffic")),
                ("fwd-x", Wire::Float(1.0)),
                ("fwd-z", Wire::Float(0.0)),
                ("blocked", Wire::Flag(false)),
            ]),
        );
        assert_eq!(
            traffic.get("vx").and_then(::hanga::kit::Node::as_f32),
            Some(10.0)
        );
        assert_eq!(
            traffic.get("vz").and_then(::hanga::kit::Node::as_f32),
            Some(0.0)
        );
        let jammed = ctx.bus_node(
            "steer",
            &wire_bag(vec![
                ("role", wire_text("traffic")),
                ("fwd-x", Wire::Float(1.0)),
                ("fwd-z", Wire::Float(1.0)),
                ("blocked", Wire::Flag(true)),
            ]),
        );
        assert_eq!(
            jammed.get("vx").and_then(::hanga::kit::Node::as_f32),
            Some(0.0)
        );
        assert_eq!(
            jammed.get("vz").and_then(::hanga::kit::Node::as_f32),
            Some(0.0)
        );
        assert_eq!(
            ctx.bus_xyz("vehicle-spawn", &wire_int(0), (0, 0, 0)),
            (500, 2, 495)
        );
        *slot.lock().unwrap() = Some(ctx);
    }

    #[test]
    fn live_wasm_urban_chaos_locales() {
        let Some((_bus, slot, mut ctx)) = instantiate_live("urban_chaos") else {
            return;
        };
        let locales = ctx.bus_node("supported-locales", &wire_empty());
        assert!(locales.get("en").is_some_and(::hanga::kit::Node::as_flag));
        assert!(locales.get("mi").is_some_and(::hanga::kit::Node::as_flag));
        assert_eq!(
            ctx.bus_text_payload(
                "contract-label",
                &wire_bag(vec![
                    ("locale", wire_text("en")),
                    ("kind", wire_text("smash-and-grab")),
                ])
            ),
            "smash-and-grab"
        );
        assert_eq!(
            ctx.bus_text_payload(
                "item-label",
                &wire_bag(vec![
                    ("locale", wire_text("mi")),
                    ("item", wire_text("glass")),
                ])
            ),
            "karaihe"
        );
        assert_eq!(
            ctx.bus_text_payload(
                "event-label",
                &wire_bag(vec![
                    ("locale", wire_text("mi")),
                    ("event", wire_text("quiet-streets")),
                ])
            ),
            "ngā huarahi mārie"
        );
        *slot.lock().unwrap() = Some(ctx);
    }
}
