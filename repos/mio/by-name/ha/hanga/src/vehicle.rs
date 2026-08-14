//! A vehicle is any rideable the host can move occupants with.
//! Looks, part names, and colors come from the mod kit string.

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
    /// Named rest-length links. The host shortens these on crumple; it does not solve a lattice.
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
    let mut kit = VehicleKit::default();
    let mut saw_part = false;
    for raw in text.split(|c| c == ';' || c == '\n') {
        let rec = raw.trim();
        if rec.is_empty() || rec.starts_with('#') {
            continue;
        }
        if let Some(rest) = rec.strip_prefix("part=") {
            if let Some(part) = parse_part(rest) {
                if !saw_part {
                    kit.parts.clear();
                    saw_part = true;
                }
                kit.parts.push(part);
            }
            continue;
        }
        let Some((key, value)) = rec.split_once('=') else {
            continue;
        };
        match key.trim() {
            "kind" => kit.kind = value.trim().to_string(),
            "traffic" | "ai" => kit.traffic = parse_flag(value),
            "speed" => {
                if let Ok(speed) = value.trim().parse::<f32>() {
                    kit.speed = speed.max(0.0);
                }
            }
            "collider" => {
                if let Some(v) = parse_n(value, 3) {
                    kit.collider = [v[0].max(0.1), v[1].max(0.1), v[2].max(0.1)];
                }
            }
            "stiffness" | "stiff" => {
                if let Ok(v) = value.trim().parse::<i32>() {
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
            _ => {}
        }
    }
    if kit.kind.is_empty() {
        kit.kind = "vehicle".into();
    }
    kit
}

fn parse_flag(value: &str) -> bool {
    matches!(value.trim(), "1" | "true" | "yes")
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

pub const BEAM_ROUNDS: u32 = 4;

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
        assert_eq!(kit.stiffness, 50);
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
        assert!(beam_length(1.0, 80, 0) < beam_length(1.0, 80, 90));
        let hull = [0.0, 0.0, 0.0];
        let mut cabin = [0.0, 1.0, 0.0];
        let mut lamp = [0.0, 2.0, 0.0];
        lamp = beam_constrain(cabin, lamp, 0.5);
        cabin = beam_constrain(hull, cabin, 0.5);
        assert!((lamp[1] - 2.0).abs() > 0.4);
        for _ in 0..BEAM_ROUNDS {
            cabin = beam_constrain(hull, cabin, 0.5);
            lamp = beam_constrain(cabin, lamp, 0.5);
        }
        assert!((cabin[1] - 0.5).abs() < 1e-4);
        assert!((lamp[1] - 1.0).abs() < 1e-4);
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
