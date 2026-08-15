#[allow(dead_code)]
fn kit_get<'a>(text: &'a str, key: &str) -> Option<&'a str> {
    for rec in text.split(|c| c == ';' || c == '\n') {
        let rec = rec.trim();
        if rec.is_empty() || rec.starts_with('#') {
            continue;
        }
        let Some((k, v)) = rec.split_once('=') else {
            continue;
        };
        if k.trim() == key {
            return Some(v.trim());
        }
    }
    None
}

fn kit_f32(text: &str, key: &str, default: f32) -> f32 {
    kit_get(text, key)
        .and_then(|v| v.parse().ok())
        .unwrap_or(default)
}

fn kit_bool(text: &str, key: &str) -> bool {
    matches!(
        kit_get(text, key).unwrap_or("0").to_ascii_lowercase().as_str(),
        "1" | "true" | "yes" | "on"
    )
}

use hanga::engine::host::{Cell, Field, Value};

fn push_cell(cells: &mut Vec<Cell>, cell: Cell) -> u32 {
    let at = cells.len() as u32;
    cells.push(cell);
    at
}

fn shift_cell(cell: Cell, base: u32) -> Cell {
    match cell {
        Cell::Items(idx) => Cell::Items(idx.into_iter().map(|at| at + base).collect()),
        Cell::Dict(fields) => Cell::Dict(
            fields
                .into_iter()
                .map(|field| Field {
                    key: field.key,
                    at: field.at + base,
                })
                .collect(),
        ),
        other => other,
    }
}

fn append_tree(cells: &mut Vec<Cell>, child: Value) -> u32 {
    if child.cells.is_empty() {
        return push_cell(cells, Cell::Empty);
    }
    let base = cells.len() as u32;
    for cell in child.cells {
        cells.push(shift_cell(cell, base));
    }
    base + child.root
}

fn leaf(cell: Cell) -> Value {
    Value {
        cells: vec![cell],
        root: 0,
    }
}

fn root_cell(payload: &Value) -> Cell {
    payload
        .cells
        .get(payload.root as usize)
        .cloned()
        .unwrap_or(Cell::Empty)
}

fn at_tree(payload: &Value, at: u32) -> Value {
    Value {
        cells: payload.cells.clone(),
        root: at,
    }
}

fn wire_flag(value: bool) -> Value {
    leaf(Cell::Flag(value))
}

fn wire_empty() -> Value {
    leaf(Cell::Empty)
}

fn wire_int(value: i64) -> Value {
    leaf(Cell::Int(value))
}

fn wire_float(value: f64) -> Value {
    leaf(Cell::Float(value))
}

fn field(key: impl Into<String>, value: Value) -> (String, Value) {
    (key.into(), value)
}

fn wire_dict(fields: Vec<(String, Value)>) -> Value {
    if fields.is_empty() {
        return wire_empty();
    }
    let mut cells = Vec::new();
    let mut bag = Vec::new();
    for (key, child) in fields {
        bag.push(Field {
            key,
            at: append_tree(&mut cells, child),
        });
    }
    let root = push_cell(&mut cells, Cell::Dict(bag));
    Value { cells, root }
}

fn atom_text(text: impl Into<String>) -> Value {
    leaf(Cell::Text(text.into()))
}

fn atom_float(value: f64) -> Value {
    leaf(Cell::Float(value))
}

fn atom_int(value: i64) -> Value {
    leaf(Cell::Int(value))
}

fn atom_flag(value: bool) -> Value {
    leaf(Cell::Flag(value))
}

fn part_dict(
    name: &str,
    size: [f32; 3],
    offset: [f32; 3],
    rgb: [f32; 3],
) -> Value {
    wire_dict(vec![
        field("name", atom_text(name)),
        field("sx", atom_float(size[0] as f64)),
        field("sy", atom_float(size[1] as f64)),
        field("sz", atom_float(size[2] as f64)),
        field("ox", atom_float(offset[0] as f64)),
        field("oy", atom_float(offset[1] as f64)),
        field("oz", atom_float(offset[2] as f64)),
        field("r", atom_float(rgb[0] as f64)),
        field("g", atom_float(rgb[1] as f64)),
        field("b", atom_float(rgb[2] as f64)),
    ])
}

fn beam_dict(a: &str, b: &str) -> Value {
    wire_dict(vec![
        field("a", atom_text(a)),
        field("b", atom_text(b)),
    ])
}

fn wire_list(items: Vec<Value>) -> Value {
    let mut cells = Vec::new();
    let mut idx = Vec::new();
    for item in items {
        idx.push(append_tree(&mut cells, item));
    }
    let root = push_cell(&mut cells, Cell::Items(idx));
    Value { cells, root }
}

fn wire_xyz(x: i32, y: i32, z: i32) -> Value {
    wire_dict(vec![
        field("x", wire_int(x as i64)),
        field("y", wire_int(y as i64)),
        field("z", wire_int(z as i64)),
    ])
}

fn wire_xyz_name(x: i32, y: i32, z: i32, name: impl Into<String>) -> Value {
    wire_dict(vec![
        field("x", wire_int(x as i64)),
        field("y", wire_int(y as i64)),
        field("z", wire_int(z as i64)),
        field("name", atom_text(name)),
    ])
}

fn wire_methods(topics: &str) -> Value {
    wire_dict(
        topics
            .split(',')
            .map(str::trim)
            .filter(|topic| !topic.is_empty())
            .map(|topic| field(topic, atom_flag(true)))
            .collect(),
    )
}

fn catalog_names(csv: &str) -> Vec<String> {
    csv.split(',')
        .map(str::trim)
        .filter(|name| !name.is_empty())
        .map(|name| name.to_string())
        .collect()
}

fn bus_has(methods: &str, payload: &Value) -> Value {
    let name = match root_cell(payload) {
        Cell::Text(text) => text,
        Cell::Dict(fields) => fields
            .iter()
            .find(|field| field.key == "name" || field.key == "method")
            .and_then(|field| match at_tree(payload, field.at).cells.get(field.at as usize) {
                Some(Cell::Text(text)) => Some(text.clone()),
                _ => None,
            })
            .unwrap_or_default(),
        _ => String::new(),
    };
    wire_flag(
        methods
            .split(',')
            .map(str::trim)
            .any(|method| method == name),
    )
}

fn wire_text(text: impl Into<String>) -> Value {
    let text = text.into();
    if text.is_empty() {
        wire_empty()
    } else {
        leaf(Cell::Text(text))
    }
}

fn wire_fail(reason: impl Into<String>) -> Value {
    leaf(Cell::Fail(reason.into()))
}

fn wire_as_text(payload: &Value) -> Option<&str> {
    match payload.cells.get(payload.root as usize) {
        Some(Cell::Text(text)) => Some(text.as_str()),
        _ => None,
    }
}

fn greet_peers() {
    #[cfg(target_arch = "wasm32")]
    {
        for peer in hanga::engine::host::peers() {
            hanga::engine::host::send(&peer, "hello", &wire_empty());
        }
    }
}

#[allow(dead_code)]
fn host_peers() -> Vec<String> {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::peers()
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        Vec::new()
    }
}

#[allow(dead_code)]
fn beside_peer(name: &str) -> bool {
    host_has_mod(name)
}

fn host_has_mod(name: &str) -> bool {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::has_mod(name)
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        let _ = name;
        false
    }
}

#[allow(dead_code)]
fn host_emit(method: &str, args: &hanga::engine::host::Value) -> bool {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::emit(method, args)
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        let _ = (method, args);
        false
    }
}

#[allow(dead_code)]
fn host_send(peer: &str, method: &str, args: &hanga::engine::host::Value) {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::send(peer, method, args);
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        let _ = (peer, method, args);
    }
}

#[allow(dead_code)]
fn host_voxel_set(x: i32, y: i32, z: i32, name: &str) {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::voxel_set(x, y, z, name);
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        let _ = (x, y, z, name);
    }
}

#[allow(dead_code)]
fn host_player() -> hanga::engine::host::Value {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::player()
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        wire_empty()
    }
}

#[allow(dead_code)]
fn host_after(ms: i32, method: &str, args: &hanga::engine::host::Value) {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::after(ms, method, args);
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        let _ = (ms, method, args);
    }
}

fn host_voxel_at(x: i32, y: i32, z: i32) -> String {
    payload_str(&host_voxel_probe(x, y, z), "name").to_string()
}

fn host_voxel_probe(x: i32, y: i32, z: i32) -> hanga::engine::host::Value {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::voxel(x, y, z)
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        let _ = (x, y, z);
        wire_dict(vec![
            field("name", atom_text("air")),
            field("edit", atom_flag(false)),
        ])
    }
}

#[allow(dead_code)]
fn dict_child(payload: &Value, key: &str) -> Option<Value> {
    match root_cell(payload) {
        Cell::Dict(fields) => fields
            .iter()
            .find(|field| field.key == key)
            .map(|field| at_tree(payload, field.at)),
        _ => None,
    }
}

#[allow(dead_code)]
fn as_list(payload: &Value) -> Option<Vec<Value>> {
    match root_cell(payload) {
        Cell::Items(idx) => Some(idx.into_iter().map(|at| at_tree(payload, at)).collect()),
        _ => None,
    }
}

fn payload_text<'a>(payload: &'a Value, key: &str) -> Option<&'a str> {
    let Cell::Dict(fields) = payload.cells.get(payload.root as usize)? else {
        return None;
    };
    let field = fields.iter().find(|field| field.key == key)?;
    match payload.cells.get(field.at as usize) {
        Some(Cell::Text(text)) => Some(text.as_str()),
        _ => None,
    }
}

fn payload_flag(payload: &Value, key: &str) -> bool {
    let Cell::Dict(fields) = root_cell(payload) else {
        return false;
    };
    fields.iter().any(|field| {
        field.key == key
            && matches!(
                payload.cells.get(field.at as usize),
                Some(Cell::Flag(true) | Cell::Int(1))
            )
    })
}

fn payload_str<'a>(payload: &'a Value, key: &str) -> &'a str {
    if let Some(text) = payload_text(payload, key) {
        return text;
    }
    match payload.cells.get(payload.root as usize) {
        Some(Cell::Text(text)) => text.as_str(),
        _ => "",
    }
}

fn payload_as_i32(payload: &Value) -> i32 {
    match root_cell(payload) {
        Cell::Int(value) => value as i32,
        Cell::Float(value) => value as i32,
        Cell::Text(text) => text.parse().unwrap_or(0),
        Cell::Dict(_) => {
            let index = payload_i64(payload, "index");
            if index != 0 || payload_text(payload, "index").is_some() {
                index as i32
            } else {
                payload_i64(payload, "state") as i32
            }
        }
        _ => 0,
    }
}

fn payload_f32(payload: &Value, key: &str) -> f32 {
    match root_cell(payload) {
        Cell::Float(value) => value as f32,
        Cell::Int(value) => value as f32,
        Cell::Dict(fields) => fields
            .iter()
            .find(|field| field.key == key)
            .and_then(|field| match payload.cells.get(field.at as usize) {
                Some(Cell::Float(value)) => Some(*value as f32),
                Some(Cell::Int(value)) => Some(*value as f32),
                Some(Cell::Text(text)) => text.parse().ok(),
                _ => None,
            })
            .unwrap_or(0.0),
        _ => 0.0,
    }
}

fn payload_i64(payload: &Value, key: &str) -> i64 {
    match root_cell(payload) {
        Cell::Dict(fields) => fields
            .iter()
            .find(|field| field.key == key)
            .and_then(|field| match payload.cells.get(field.at as usize) {
                Some(Cell::Int(v)) => Some(*v),
                Some(Cell::Text(t)) => t.parse().ok(),
                _ => None,
            })
            .unwrap_or(0),
        _ => 0,
    }
}

#[allow(dead_code)]
fn wire_is_null(payload: &Value) -> bool {
    matches!(root_cell(payload), Cell::Empty)
        || matches!(root_cell(payload), Cell::Text(text) if text.is_empty())
        || matches!(root_cell(payload), Cell::Dict(fields) if fields.is_empty())
}

#[allow(dead_code)]
fn wire_is_flag(payload: &Value, want: bool) -> bool {
    matches!(root_cell(payload), Cell::Flag(flag) if flag == want)
}

fn host_log(level: &str, message: &str) {
    #[cfg(target_arch = "wasm32")]
    hanga::engine::host::log(level, message);
    #[cfg(not(target_arch = "wasm32"))]
    {
        let _ = (level, message);
    }
}

include!("host_bus.rs");
