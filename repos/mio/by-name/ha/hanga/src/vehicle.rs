//! A vehicle is any rideable the host can move occupants with.
//! Looks, part names, and colors come from the mod `vehicle-kit` dict.

#[derive(Clone, Debug, PartialEq)]
pub struct VehiclePartSpec {
    pub name: String,
    pub size: [f32; 3],
    pub offset: [f32; 3],
    pub rgb: [f32; 3],
}

#[derive(Clone, Debug, PartialEq)]
pub struct VehicleKit {
    pub kind: String,
    pub traffic: bool,
    pub speed: f32,
    pub collider: [f32; 3],
    /// 0 = crumple as the crash kit says; 100 = almost no fold.
    pub stiffness: i32,
    /// Part names the host may squash on the local up axis (tires, pads, …).
    pub tires: Vec<String>,
    /// Named rest-length links. The host shortens these on crumple and relaxes a lattice
    /// (first kit part stays pinned so the collider origin does not drift).
    pub beams: Vec<(String, String)>,
    pub parts: Vec<VehiclePartSpec>,
}

impl Default for VehicleKit {
    fn default() -> Self {
        Self {
            kind: "vehicle".into(),
            traffic: false,
            speed: 12.0,
            collider: [2.0, 1.0, 3.0],
            stiffness: 50,
            tires: Vec::new(),
            beams: Vec::new(),
            parts: vec![VehiclePartSpec {
                name: "body".into(),
                size: [2.0, 0.8, 3.0],
                offset: [0.0, 0.0, 0.0],
                rgb: [0.45, 0.45, 0.48],
            }],
        }
    }
}

/// Parse a mod `vehicle-kit` string. Unknown keys are ignored.
///
/// ```text
/// kind=car;traffic=1;speed=25;collider=2,1.2,4
/// part=hull,1.85,0.48,3.80,0,-0.22,0,0.78,0.18,0.14
/// ```
pub fn parse_vehicle_kit(text: &str) -> VehicleKit {
    parse_vehicle_kit_fields(&crate::kit::Fields::from_text(text))
}

pub fn parse_vehicle_kit_node(node: &crate::kit::Node) -> VehicleKit {
    use crate::kit::Node;
    if node.is_empty() {
        return VehicleKit::default();
    }
    match node {
        Node::Text(text) => parse_vehicle_kit(text),
        Node::Dict(_) => parse_vehicle_kit_tree(node),
        _ => VehicleKit::default(),
    }
}

fn parse_vehicle_kit_tree(node: &crate::kit::Node) -> VehicleKit {
    use crate::kit::Node;
    let mut kit = VehicleKit::default();
    kit.speed = 0.0;
    kit.stiffness = 0;
    kit.parts.clear();
    if let Some(kind) = node.get("kind") {
        let kind = kind.text();
        if !kind.is_empty() {
            kit.kind = kind;
        }
    }
    kit.traffic = node.flag("traffic") || node.flag("ai");
    if let Some(speed) = node.get("speed").and_then(Node::as_f32) {
        kit.speed = speed.max(0.0);
    }
    if let Some(stiff) = node
        .get("stiffness")
        .or_else(|| node.get("stiff"))
        .and_then(Node::as_i32)
    {
        kit.stiffness = stiff.clamp(0, 100);
    }
    if let Some(collider) = node.get("collider") {
        match collider {
            Node::Dict(_) => {
                kit.collider = [
                    collider.f32("x", kit.collider[0]).max(0.1),
                    collider.f32("y", kit.collider[1]).max(0.1),
                    collider.f32("z", kit.collider[2]).max(0.1),
                ];
            }
            other => {
                if let Some(v) = parse_n(&other.text(), 3) {
                    kit.collider = [v[0].max(0.1), v[1].max(0.1), v[2].max(0.1)];
                }
            }
        }
    }
    if let Some(tires) = node.get("tires").or_else(|| node.get("tire")) {
        kit.tires = tires.names();
    }
    if let Some(beams) = node.get("beams").or_else(|| node.get("beam")) {
        kit.beams = match beams {
            Node::Items(items) => items
                .iter()
                .filter_map(|item| {
                    let a = item.get("a").map(Node::text).unwrap_or_default();
                    let b = item.get("b").map(Node::text).unwrap_or_default();
                    (!a.is_empty() && !b.is_empty()).then_some((a, b))
                })
                .collect(),
            Node::Text(text) => {
                let mut bits = text.split(',').map(str::trim);
                match (bits.next(), bits.next()) {
                    (Some(a), Some(b)) if !a.is_empty() && !b.is_empty() => {
                        vec![(a.to_string(), b.to_string())]
                    }
                    _ => Vec::new(),
                }
            }
            _ => Vec::new(),
        };
    }
    if let Some(parts) = node.get("parts").or_else(|| node.get("part")) {
        let parsed: Vec<VehiclePartSpec> = match parts {
            Node::Items(items) => items.iter().filter_map(parse_part_node).collect(),
            Node::Dict(_) => parse_part_node(parts).into_iter().collect(),
            Node::Text(text) => parse_part(text).into_iter().collect(),
            _ => Vec::new(),
        };
        if !parsed.is_empty() {
            kit.parts = parsed;
        }
    }
    if kit.kind.is_empty() {
        kit.kind = "vehicle".into();
    }
    kit
}

fn parse_part_node(node: &crate::kit::Node) -> Option<VehiclePartSpec> {
    use crate::kit::Node;
    if let Node::Text(text) = node {
        return parse_part(text);
    }
    let name = node.get("name").map(Node::text).unwrap_or_default();
    if name.is_empty() {
        return None;
    }
    Some(VehiclePartSpec {
        name,
        size: [
            node.f32("sx", 1.0).max(0.05),
            node.f32("sy", 1.0).max(0.05),
            node.f32("sz", 1.0).max(0.05),
        ],
        offset: [node.f32("ox", 0.0), node.f32("oy", 0.0), node.f32("oz", 0.0)],
        rgb: [
            scale_rgb(node.f32("r", 0.5)),
            scale_rgb(node.f32("g", 0.5)),
            scale_rgb(node.f32("b", 0.5)),
        ],
    })
}

pub fn parse_vehicle_kit_fields(fields: &crate::kit::Fields) -> VehicleKit {
    let mut kit = VehicleKit::default();
    if !fields.is_empty() {
        kit.speed = 0.0;
        kit.stiffness = 0;
        kit.parts.clear();
    }
    let mut saw_part = false;
    let mut indexed_parts: std::collections::BTreeMap<usize, VehiclePartSpec> =
        std::collections::BTreeMap::new();
    let mut indexed_beams: std::collections::BTreeMap<usize, (String, String)> =
        std::collections::BTreeMap::new();
    for (key, cell) in &fields.pairs {
        if let Some((i, field)) = indexed_field(key, &["parts.", "part."]) {
            let part = indexed_parts.entry(i).or_insert_with(|| VehiclePartSpec {
                name: String::new(),
                size: [1.0, 1.0, 1.0],
                offset: [0.0, 0.0, 0.0],
                rgb: [0.5, 0.5, 0.5],
            });
            match field {
                "name" => part.name = cell.text(),
                "sx" => {
                    if let Some(v) = cell.as_f32() {
                        part.size[0] = v.max(0.05);
                    }
                }
                "sy" => {
                    if let Some(v) = cell.as_f32() {
                        part.size[1] = v.max(0.05);
                    }
                }
                "sz" => {
                    if let Some(v) = cell.as_f32() {
                        part.size[2] = v.max(0.05);
                    }
                }
                "ox" => {
                    if let Some(v) = cell.as_f32() {
                        part.offset[0] = v;
                    }
                }
                "oy" => {
                    if let Some(v) = cell.as_f32() {
                        part.offset[1] = v;
                    }
                }
                "oz" => {
                    if let Some(v) = cell.as_f32() {
                        part.offset[2] = v;
                    }
                }
                "r" => {
                    if let Some(v) = cell.as_f32() {
                        part.rgb[0] = scale_rgb(v);
                    }
                }
                "g" => {
                    if let Some(v) = cell.as_f32() {
                        part.rgb[1] = scale_rgb(v);
                    }
                }
                "b" => {
                    if let Some(v) = cell.as_f32() {
                        part.rgb[2] = scale_rgb(v);
                    }
                }
                _ => {}
            }
            continue;
        }
        if let Some(rest) = key
            .strip_prefix("tires.")
            .or_else(|| key.strip_prefix("tire."))
        {
            if rest.parse::<usize>().is_ok() {
                let name = cell.text();
                if !name.is_empty() {
                    kit.tires.push(name);
                }
            } else if cell.as_flag() {
                kit.tires.push(rest.to_string());
            }
            continue;
        }
        if let Some((i, end)) = indexed_field(key, &["beams.", "beam."]) {
            let beam = indexed_beams
                .entry(i)
                .or_insert_with(|| (String::new(), String::new()));
            match end {
                "a" => beam.0 = cell.text(),
                "b" => beam.1 = cell.text(),
                _ => {}
            }
            continue;
        }
        if key == "collider.x" {
            if let Some(v) = cell.as_f32() {
                kit.collider[0] = v.max(0.1);
            }
            continue;
        }
        if key == "collider.y" {
            if let Some(v) = cell.as_f32() {
                kit.collider[1] = v.max(0.1);
            }
            continue;
        }
        if key == "collider.z" {
            if let Some(v) = cell.as_f32() {
                kit.collider[2] = v.max(0.1);
            }
            continue;
        }
        let value = cell.text();
        match key.as_str() {
            "kind" => kit.kind = value,
            "traffic" | "ai" => kit.traffic = cell.as_flag(),
            "speed" => {
                if let Some(speed) = cell.as_f32() {
                    kit.speed = speed.max(0.0);
                }
            }
            "collider" => {
                if let Some(v) = parse_n(&value, 3) {
                    kit.collider = [v[0].max(0.1), v[1].max(0.1), v[2].max(0.1)];
                }
            }
            "stiffness" | "stiff" => {
                if let Some(v) = cell.as_i32() {
                    kit.stiffness = v.clamp(0, 100);
                }
            }
            "tire" | "tires" => {
                kit.tires = value
                    .split(',')
                    .map(|n| n.trim().to_string())
                    .filter(|n| !n.is_empty())
                    .collect();
            }
            "beam" => {
                let mut bits = value.split(',').map(str::trim);
                if let (Some(a), Some(b)) = (bits.next(), bits.next()) {
                    if !a.is_empty() && !b.is_empty() {
                        kit.beams.push((a.to_string(), b.to_string()));
                    }
                }
            }
            "part" => {
                if let Some(part) = parse_part(&value) {
                    if !saw_part {
                        kit.parts.clear();
                        saw_part = true;
                    }
                    kit.parts.push(part);
                }
            }
            _ => {}
        }
    }
    if !indexed_parts.is_empty() {
        kit.parts = indexed_parts
            .into_values()
            .filter(|part| !part.name.is_empty())
            .collect();
    }
    for (a, b) in indexed_beams.into_values() {
        if !a.is_empty() && !b.is_empty() {
            kit.beams.push((a, b));
        }
    }
    if kit.kind.is_empty() {
        kit.kind = "vehicle".into();
    }
    kit
}

fn indexed_field<'a>(key: &'a str, prefixes: &[&str]) -> Option<(usize, &'a str)> {
    for prefix in prefixes {
        if let Some(rest) = key.strip_prefix(prefix) {
            if let Some((index, field)) = rest.split_once('.') {
                if let Ok(i) = index.parse::<usize>() {
                    return Some((i, field));
                }
            }
        }
    }
    None
}

fn scale_rgb(n: f32) -> f32 {
    if n > 1.0 {
        (n / 255.0).clamp(0.0, 1.0)
    } else {
        n.clamp(0.0, 1.0)
    }
}

fn parse_n(value: &str, n: usize) -> Option<Vec<f32>> {
    let nums: Vec<f32> = value
        .split(|c: char| c == ',' || c.is_whitespace())
        .filter(|p| !p.is_empty())
        .filter_map(|p| p.parse().ok())
        .collect();
    (nums.len() >= n).then_some(nums)
}

fn parse_part(value: &str) -> Option<VehiclePartSpec> {
    let mut bits = value.split(',').map(str::trim);
    let name = bits.next()?.to_string();
    if name.is_empty() {
        return None;
    }
    let sx: f32 = bits.next()?.parse().ok()?;
    let sy: f32 = bits.next()?.parse().ok()?;
    let sz: f32 = bits.next()?.parse().ok()?;
    let ox: f32 = bits.next()?.parse().ok()?;
    let oy: f32 = bits.next()?.parse().ok()?;
    let oz: f32 = bits.next()?.parse().ok()?;
    let r: f32 = bits.next()?.parse().ok()?;
    let g: f32 = bits.next()?.parse().ok()?;
    let b: f32 = bits.next()?.parse().ok()?;
    let rgb = if r > 1.0 || g > 1.0 || b > 1.0 {
        [r / 255.0, g / 255.0, b / 255.0]
    } else {
        [r, g, b]
    };
    Some(VehiclePartSpec {
        name,
        size: [sx.max(0.05), sy.max(0.05), sz.max(0.05)],
        offset: [ox, oy, oz],
        rgb,
    })
}

pub fn is_tire(kit: &VehicleKit, name: &str) -> bool {
    kit.tires.iter().any(|part| part == name)
}

/// Local-up scale for a named tire. Stiffer kits squash less. Airborne = 1.
pub fn tire_squash(speed: f32, stiffness: i32, grounded: bool) -> f32 {
    if !grounded {
        return 1.0;
    }
    let give = (1.0 - stiffness.clamp(0, 100) as f32 / 100.0) * 0.4;
    let load = (speed.max(0.0) / 35.0).clamp(0.0, 1.0);
    (1.0 - give * (0.35 + 0.65 * load)).clamp(0.55, 1.0)
}

fn offset_len(a: [f32; 3], b: [f32; 3]) -> f32 {
    let dx = b[0] - a[0];
    let dy = b[1] - a[1];
    let dz = b[2] - a[2];
    (dx * dx + dy * dy + dz * dz).sqrt()
}

pub fn part_offset(parts: &[VehiclePartSpec], name: &str) -> Option<[f32; 3]> {
    parts.iter().find(|part| part.name == name).map(|part| part.offset)
}

pub fn beam_rest(parts: &[VehiclePartSpec], a: &str, b: &str) -> Option<f32> {
    Some(offset_len(part_offset(parts, a)?, part_offset(parts, b)?))
}

/// Rest length after crumple. Stiffer kits shorten less.
pub fn beam_length(rest: f32, crumple: i32, stiffness: i32) -> f32 {
    let give = (1.0 - stiffness.clamp(0, 100) as f32 / 100.0)
        * (crumple.clamp(0, 100) as f32 / 100.0)
        * 0.5;
    rest * (1.0 - give).clamp(0.45, 1.0)
}

/// Keep `other` on the ray from `anchor`, at `length`.
pub fn beam_constrain(anchor: [f32; 3], other: [f32; 3], length: f32) -> [f32; 3] {
    let dx = other[0] - anchor[0];
    let dy = other[1] - anchor[1];
    let dz = other[2] - anchor[2];
    let len = (dx * dx + dy * dy + dz * dz).sqrt();
    if len < 1e-4 {
        return other;
    }
    let s = length / len;
    [
        anchor[0] + dx * s,
        anchor[1] + dy * s,
        anchor[2] + dz * s,
    ]
}

/// Split the length error equally (neither node pinned).
pub fn beam_relax(a: [f32; 3], b: [f32; 3], length: f32) -> ([f32; 3], [f32; 3]) {
    let dx = b[0] - a[0];
    let dy = b[1] - a[1];
    let dz = b[2] - a[2];
    let len = (dx * dx + dy * dy + dz * dz).sqrt();
    if len < 1e-4 {
        return (a, b);
    }
    let half = (len - length) * 0.5;
    let ux = dx / len;
    let uy = dy / len;
    let uz = dz / len;
    (
        [a[0] + ux * half, a[1] + uy * half, a[2] + uz * half],
        [b[0] - ux * half, b[1] - uy * half, b[2] - uz * half],
    )
}

/// One Gauss–Seidel step. A pinned node stays put; the other slides to `length`.
pub fn beam_step(
    a: [f32; 3],
    b: [f32; 3],
    length: f32,
    pin_a: bool,
    pin_b: bool,
) -> ([f32; 3], [f32; 3]) {
    match (pin_a, pin_b) {
        (true, true) => (a, b),
        (true, false) => (a, beam_constrain(a, b, length)),
        (false, true) => (beam_constrain(b, a, length), b),
        (false, false) => beam_relax(a, b, length),
    }
}

pub fn beam_pin_name(parts: &[VehiclePartSpec]) -> Option<&str> {
    parts.first().map(|part| part.name.as_str())
}

pub const BEAM_ROUNDS: u32 = 8;

/// True when `other` sits in front of a traffic vehicle on the XZ plane.
pub fn traffic_ahead_blocks(
    origin: [f32; 3],
    fwd: [f32; 3],
    other: [f32; 3],
    reach: f32,
    half_width: f32,
) -> bool {
    let dy = other[1] - origin[1];
    if dy.abs() > 3.0 {
        return false;
    }
    let dx = other[0] - origin[0];
    let dz = other[2] - origin[2];
    let along = dx * fwd[0] + dz * fwd[2];
    if along < 1.0 || along > reach {
        return false;
    }
    let side = dx * -fwd[2] + dz * fwd[0];
    side.abs() < half_width
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_kit_is_a_plain_rideable() {
        let kit = parse_vehicle_kit("");
        assert_eq!(kit.kind, "vehicle");
        assert!(!kit.traffic);
        assert_eq!(kit.parts.len(), 1);
        assert_eq!(
            parse_vehicle_kit_node(&crate::kit::Node::Dict(vec![])),
            VehicleKit::default()
        );
        assert!(parse_vehicle_kit("kind=car").parts.is_empty());
    }

    #[test]
    fn nested_vehicle_kit_keeps_lists() {
        use crate::kit::Node;
        let kit = parse_vehicle_kit_node(&Node::Dict(vec![
            ("kind".into(), Node::Text("car".into())),
            ("stiffness".into(), Node::Int(32)),
            (
                "collider".into(),
                Node::Dict(vec![
                    ("x".into(), Node::Float(2.0)),
                    ("y".into(), Node::Float(1.2)),
                    ("z".into(), Node::Float(4.0)),
                ]),
            ),
            (
                "tires".into(),
                Node::Items(vec![Node::Text("wheel".into())]),
            ),
            (
                "beams".into(),
                Node::Items(vec![Node::Dict(vec![
                    ("a".into(), Node::Text("hull".into())),
                    ("b".into(), Node::Text("cabin".into())),
                ])]),
            ),
            (
                "parts".into(),
                Node::Items(vec![Node::Dict(vec![
                    ("name".into(), Node::Text("hull".into())),
                    ("sx".into(), Node::Float(1.85)),
                    ("sy".into(), Node::Float(0.48)),
                    ("sz".into(), Node::Float(3.8)),
                ])]),
            ),
        ]));
        assert_eq!(kit.kind, "car");
        assert_eq!(kit.stiffness, 32);
        assert!((kit.collider[1] - 1.2).abs() < 1e-5);
        assert_eq!(kit.tires, vec!["wheel"]);
        assert_eq!(kit.beams, vec![("hull".into(), "cabin".into())]);
        assert_eq!(kit.parts[0].name, "hull");
    }

    #[test]
    fn car_kit_stays_opaque_to_the_host() {
        let kit = parse_vehicle_kit(
            "kind=car;traffic=1;speed=25;collider=2,1.2,4\n\
             part=hull,1.85,0.48,3.80,0,-0.22,0,0.78,0.18,0.14\n\
             part=lamp,0.18,0.12,0.10,-0.62,-0.08,-1.88,0.92,0.86,0.55",
        );
        assert_eq!(kit.kind, "car");
        assert!(kit.traffic);
        assert_eq!(kit.stiffness, 0);
        assert!((kit.speed - 25.0).abs() < 1e-5);
        assert_eq!(kit.parts.len(), 2);
        assert_eq!(kit.parts[0].name, "hull");
        assert!((kit.parts[0].rgb[0] - 0.78).abs() < 1e-5);
    }

    #[test]
    fn eight_bit_rgb_scales_down() {
        let kit = parse_vehicle_kit("part=deck,1,1,1,0,0,0,255,128,0");
        assert!((kit.parts[0].rgb[0] - 1.0).abs() < 1e-5);
        assert!((kit.parts[0].rgb[1] - 128.0 / 255.0).abs() < 1e-5);
        let kit = parse_vehicle_kit("kind=platform;stiffness=95;part=deck,1,1,1,0,0,0,1,1,1");
        assert_eq!(kit.stiffness, 95);
        let kit = parse_vehicle_kit("tire=wheel,pad;part=wheel,1,1,1,0,0,0,1,1,1");
        assert!(is_tire(&kit, "wheel"));
        assert!(is_tire(&kit, "pad"));
        assert!(!is_tire(&kit, "hull"));
        assert!((tire_squash(0.0, 0, false) - 1.0).abs() < 1e-5);
        assert!(tire_squash(30.0, 0, true) < tire_squash(30.0, 90, true));
        assert!(tire_squash(30.0, 32, true) < 1.0);
        let kit = parse_vehicle_kit(
            "beam=hull,cabin;beam=hull,wheel\n\
             part=hull,1,1,1,0,0,0,1,1,1\n\
             part=cabin,1,1,1,0,0.5,0,1,1,1\n\
             part=wheel,1,1,1,0,-0.5,0,1,1,1",
        );
        assert_eq!(kit.beams.len(), 2);
        let rest = beam_rest(&kit.parts, "hull", "cabin").unwrap();
        assert!((rest - 0.5).abs() < 1e-5);
        let pulled = beam_constrain([0.0, 0.0, 0.0], [0.0, 1.0, 0.0], 0.4);
        assert!((pulled[1] - 0.4).abs() < 1e-5);
        let (left, right) = beam_relax([0.0, 0.0, 0.0], [0.0, 2.0, 0.0], 1.0);
        assert!((left[1] - 0.5).abs() < 1e-5);
        assert!((right[1] - 1.5).abs() < 1e-5);
        assert_eq!(beam_pin_name(&kit.parts), Some("hull"));
        assert!(beam_length(1.0, 80, 0) < beam_length(1.0, 80, 90));
        let mut hull = [0.0, 0.0, 0.0];
        let mut cabin = [0.0, 1.0, 0.0];
        let mut lamp = [0.0, 2.0, 0.0];
        for _ in 0..BEAM_ROUNDS {
            (hull, cabin) = beam_step(hull, cabin, 0.5, true, false);
            (cabin, lamp) = beam_step(cabin, lamp, 0.5, false, false);
            (cabin, lamp) = beam_step(cabin, lamp, 0.5, false, false);
            (hull, cabin) = beam_step(hull, cabin, 0.5, true, false);
        }
        assert!((hull[1]).abs() < 1e-4);
        assert!((cabin[1] - 0.5).abs() < 1e-3);
        assert!((lamp[1] - 1.0).abs() < 1e-2);
    }

    #[test]
    fn traffic_stops_for_a_body_ahead() {
        assert!(traffic_ahead_blocks(
            [0.0, 2.0, 0.0],
            [0.0, 0.0, 1.0],
            [0.2, 2.0, 6.0],
            12.0,
            2.5
        ));
        assert!(!traffic_ahead_blocks(
            [0.0, 2.0, 0.0],
            [0.0, 0.0, 1.0],
            [8.0, 2.0, 6.0],
            12.0,
            2.5
        ));
        assert!(!traffic_ahead_blocks(
            [0.0, 2.0, 0.0],
            [0.0, 0.0, 1.0],
            [0.0, 2.0, -4.0],
            12.0,
            2.5
        ));
    }
}
