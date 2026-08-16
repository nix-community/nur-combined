//! Generic crash math. The mod returns a kit; the host only applies it.

pub const CRASH_SEVERITY_MAX: i32 = 100;

pub fn clamp_crash_severity(severity: i32) -> i32 {
    severity.clamp(0, CRASH_SEVERITY_MAX)
}

/// Maps crumple 0-100 to a remaining scale (1.0 = intact, ~0.45 = folded).
pub fn crumple_scale(crumple: i32) -> f32 {
    let t = clamp_crash_severity(crumple) as f32 / CRASH_SEVERITY_MAX as f32;
    1.0 - t * 0.55
}

fn unit3(dir: [f32; 3]) -> [f32; 3] {
    let len = (dir[0] * dir[0] + dir[1] * dir[1] + dir[2] * dir[2]).sqrt();
    if len < 1e-4 {
        [0.0, 0.0, 0.0]
    } else {
        [dir[0] / len, dir[1] / len, dir[2] / len]
    }
}

/// Squash along the impact/travel axis; the other axes stay closer to 1.
/// Cheap BeamNG-like fold without a node-beam solver.
pub fn crumple_axes(crumple: i32, dir: [f32; 3]) -> [f32; 3] {
    let s = crumple_scale(crumple);
    let n = unit3(dir);
    let t = 1.0 - s;
    [
        (1.0 - t * n[0].abs()).clamp(0.35, 1.0),
        (1.0 - t * n[1].abs()).clamp(0.35, 1.0),
        (1.0 - t * n[2].abs()).clamp(0.35, 1.0),
    ]
}

/// Slide a still-attached part toward the impact (shortening beam).
pub fn crumple_node_shift(offset: [f32; 3], dir: [f32; 3], crumple: i32) -> [f32; 3] {
    let n = unit3(dir);
    let pull = clamp_crash_severity(crumple) as f32 / CRASH_SEVERITY_MAX as f32 * 0.22;
    [
        offset[0] - n[0] * pull,
        offset[1] - n[1] * pull,
        offset[2] - n[2] * pull,
    ]
}

/// Impact speed worth asking the mod about. Sudden stop or hitting a solid.
pub fn impact_speed(last_speed: f32, current_speed: f32, into_solid: bool) -> Option<f32> {
    let last = last_speed.max(0.0);
    let current = current_speed.max(0.0);
    let drop = last - current;
    if into_solid && last >= 8.0 {
        return Some(last);
    }
    if drop >= 8.0 {
        return Some(last);
    }
    None
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct CrashKit {
    pub severity: i32,
    pub crumple: i32,
    pub wrecks: bool,
    pub ignites: bool,
    pub action: String,
    pub impulse: f32,
    pub detach: Vec<String>,
}

pub fn parse_crash_kit(text: &str) -> CrashKit {
    parse_crash_kit_fields(&crate::kit::Fields::from_text(text))
}

pub fn parse_crash_kit_node(node: &crate::kit::Node) -> CrashKit {
    use crate::kit::Node;
    if node.is_empty() {
        return CrashKit::default();
    }
    match node {
        Node::Text(text) => parse_crash_kit(text),
        Node::Dict(_) => {
            let mut kit = CrashKit::default();
            if let Some(v) = node.get("severity").and_then(Node::as_i32) {
                kit.severity = clamp_crash_severity(v);
            }
            if let Some(v) = node.get("crumple").and_then(Node::as_i32) {
                kit.crumple = clamp_crash_severity(v);
            }
            kit.wrecks = node.flag("wrecks");
            kit.ignites = node.flag("ignites") || node.flag("burn") || node.flag("fire");
            if let Some(action) = node.get("action") {
                kit.action = action.text();
            }
            if let Some(v) = node.get("impulse").and_then(Node::as_f32) {
                kit.impulse = v.max(0.0);
            }
            if let Some(detach) = node.get("detach") {
                kit.detach = detach.names();
            }
            kit
        }
        _ => CrashKit::default(),
    }
}

pub fn parse_crash_kit_fields(fields: &crate::kit::Fields) -> CrashKit {
    let mut kit = CrashKit::default();
    for (key, cell) in &fields.pairs {
        if let Some(rest) = key.strip_prefix("detach.") {
            if rest.parse::<usize>().is_ok() {
                let name = cell.text();
                if !name.is_empty() {
                    kit.detach.push(name);
                }
            } else if cell.as_flag() {
                kit.detach.push(rest.to_string());
            }
            continue;
        }
        let value = cell.text();
        match key.as_str() {
            "severity" => {
                if let Some(v) = cell.as_i32() {
                    kit.severity = clamp_crash_severity(v);
                }
            }
            "crumple" => {
                if let Some(v) = cell.as_i32() {
                    kit.crumple = clamp_crash_severity(v);
                }
            }
            "wrecks" => kit.wrecks = cell.as_flag(),
            "ignites" | "burn" | "fire" => kit.ignites = cell.as_flag(),
            "action" => kit.action = value,
            "impulse" => {
                if let Some(v) = cell.as_f32() {
                    kit.impulse = v.max(0.0);
                }
            }
            "detach" => {
                kit.detach = value
                    .split(',')
                    .map(|n| n.trim().to_string())
                    .filter(|n| !n.is_empty())
                    .collect();
            }
            _ => {}
        }
    }
    kit
}

pub fn crash_kit_detaches(kit: &CrashKit, part: &str) -> bool {
    kit.detach.iter().any(|name| name == part)
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct FractureKit {
    pub can: bool,
    pub spread: i32,
    pub impulse: f32,
}

pub fn parse_fracture_kit(text: &str) -> FractureKit {
    parse_fracture_kit_node(&crate::kit::Node::Text(text.into()))
}

pub fn parse_fracture_kit_fields(fields: &crate::kit::Fields) -> FractureKit {
    parse_fracture_kit_node(&fields.as_node())
}

pub fn parse_fracture_kit_node(node: &crate::kit::Node) -> FractureKit {
    if node.is_empty() {
        return FractureKit::default();
    }
    let mut kit = FractureKit::default();
    for (key, cell) in node.entries() {
        match key.as_str() {
            "can" => kit.can = cell.as_flag(),
            "spread" => {
                if let Some(v) = cell.as_i32() {
                    kit.spread = v.max(0);
                }
            }
            "impulse" => {
                if let Some(v) = cell.as_f32() {
                    kit.impulse = v.max(0.0);
                }
            }
            _ => {}
        }
    }
    kit
}

#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub struct PlanarVel {
    pub vx: f32,
    pub vz: f32,
}

pub fn parse_planar(text: &str) -> Option<PlanarVel> {
    parse_planar_node(&crate::kit::Node::Text(text.into()))
}

pub fn parse_planar_fields(fields: &crate::kit::Fields) -> Option<PlanarVel> {
    parse_planar_node(&fields.as_node())
}

pub fn parse_planar_node(node: &crate::kit::Node) -> Option<PlanarVel> {
    if node.is_empty() {
        return None;
    }
    let mut vel = PlanarVel::default();
    let mut saw = false;
    for (key, cell) in node.entries() {
        match key.as_str() {
            "vx" => {
                if let Some(v) = cell.as_f32() {
                    vel.vx = v;
                    saw = true;
                }
            }
            "vz" => {
                if let Some(v) = cell.as_f32() {
                    vel.vz = v;
                    saw = true;
                }
            }
            _ => {}
        }
    }
    saw.then_some(vel)
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct FireKit {
    pub heat: f32,
    pub range: f32,
    pub consume: bool,
    pub jump: bool,
    pub burst: bool,
    pub out: bool,
}

pub fn parse_fire_kit(text: &str) -> FireKit {
    parse_fire_kit_node(&crate::kit::Node::Text(text.into()))
}

pub fn parse_fire_kit_fields(fields: &crate::kit::Fields) -> FireKit {
    parse_fire_kit_node(&fields.as_node())
}

pub fn parse_fire_kit_node(node: &crate::kit::Node) -> FireKit {
    if node.is_empty() {
        return FireKit {
            out: true,
            ..FireKit::default()
        };
    }
    let mut kit = FireKit::default();
    for (key, cell) in node.entries() {
        match key.as_str() {
            "heat" => {
                if let Some(v) = cell.as_f32() {
                    kit.heat = v.max(0.0);
                }
            }
            "range" => {
                if let Some(v) = cell.as_f32() {
                    kit.range = v.max(0.0);
                }
            }
            "consume" => kit.consume = cell.as_flag(),
            "jump" => kit.jump = cell.as_flag(),
            "burst" => kit.burst = cell.as_flag(),
            "out" => kit.out = cell.as_flag(),
            _ => {}
        }
    }
    kit
}

/// Fold remaining after the rideable's stiffness (0 = kit crumple, 100 = none).
pub fn apply_stiffness(crumple: i32, stiffness: i32) -> i32 {
    let crumple = clamp_crash_severity(crumple);
    let stiff = stiffness.clamp(0, 100) as f32 / 100.0;
    (crumple as f32 * (1.0 - stiff)).round() as i32
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn taps_are_not_impacts() {
        assert_eq!(impact_speed(6.0, 5.0, false), None);
        assert_eq!(impact_speed(6.0, 5.0, true), None);
    }

    #[test]
    fn empty_crash_shapes_are_default() {
        assert_eq!(parse_crash_kit_node(&crate::kit::Node::Empty), CrashKit::default());
        assert_eq!(
            parse_crash_kit_node(&crate::kit::Node::Text(String::new())),
            CrashKit::default()
        );
        assert_eq!(
            parse_crash_kit_node(&crate::kit::Node::Dict(vec![])),
            CrashKit::default()
        );
    }

    #[test]
    fn wall_at_drive_speed_is_an_impact() {
        assert_eq!(impact_speed(25.0, 4.0, true), Some(25.0));
    }

    #[test]
    fn hard_brake_without_a_wall_still_counts() {
        assert_eq!(impact_speed(22.0, 10.0, false), Some(22.0));
    }

    #[test]
    fn folded_metal_is_shorter_than_stock() {
        assert!((crumple_scale(0) - 1.0).abs() < 1e-5);
        assert!(crumple_scale(100) < 0.5);
        assert!(crumple_scale(50) < crumple_scale(10));
    }

    #[test]
    fn crumple_follows_the_impact_axis() {
        let along_z = crumple_axes(80, [0.0, 0.0, 20.0]);
        assert!(along_z[2] < along_z[0]);
        assert!(along_z[2] < along_z[1]);
        let intact = crumple_axes(0, [1.0, 0.0, 0.0]);
        assert!((intact[0] - 1.0).abs() < 1e-5);
        let shifted = crumple_node_shift([0.0, 0.4, 1.2], [0.0, 0.0, 10.0], 100);
        assert!(shifted[2] < 1.2);
        assert!((shifted[0]).abs() < 1e-5);
        let still = crumple_axes(80, [0.0, 0.0, 0.0]);
        assert!((still[0] - 1.0).abs() < 1e-5);
        assert!((still[1] - 1.0).abs() < 1e-5);
        assert!((still[2] - 1.0).abs() < 1e-5);
        assert_eq!(
            crumple_node_shift([0.0, 0.4, 1.2], [0.0, 0.0, 0.0], 100),
            [0.0, 0.4, 1.2]
        );
    }

    #[test]
    fn crash_kit_is_opaque_to_the_host() {
        let kit = parse_crash_kit(
            "severity=75;crumple=70;wrecks=1;ignites=1;action=crash;impulse=12;detach=lamp,wheel",
        );
        assert_eq!(kit.severity, 75);
        assert!(kit.wrecks && kit.ignites);
        assert_eq!(kit.detach, vec!["lamp", "wheel"]);
        let nested = parse_crash_kit_node(&crate::kit::Node::Dict(vec![
            ("severity".into(), crate::kit::Node::Int(40)),
            (
                "detach".into(),
                crate::kit::Node::Items(vec![
                    crate::kit::Node::Text("lamp".into()),
                    crate::kit::Node::Text("wheel".into()),
                ]),
            ),
        ]));
        assert_eq!(nested.severity, 40);
        assert_eq!(nested.detach, vec!["lamp", "wheel"]);
        assert_eq!(kit.action, "crash");
        assert!(crash_kit_detaches(&kit, "lamp"));
        assert!(!crash_kit_detaches(&kit, "hull"));
        assert_eq!(parse_crash_kit("").severity, 0);
        let frac = parse_fracture_kit("can=1;spread=3;impulse=15");
        assert!(frac.can && frac.spread == 3);
        assert_eq!(parse_fracture_kit(""), FractureKit::default());
        assert_eq!(parse_fracture_kit("can=1;spread=3").impulse, 0.0);
        assert_eq!(parse_planar("vx=1;vz=-2"), Some(PlanarVel { vx: 1.0, vz: -2.0 }));
        assert_eq!(parse_planar(""), None);
        let fire = parse_fire_kit("heat=1.2;range=8;consume=1;jump=1;burst=0;out=0");
        assert!(fire.consume && fire.jump && !fire.out);
        assert!(parse_fire_kit("").out);
        assert_eq!(parse_fire_kit("jump=1").heat, 0.0);
        assert_eq!(parse_fire_kit("jump=1").range, 0.0);
        assert_eq!(apply_stiffness(80, 0), 80);
        assert_eq!(apply_stiffness(80, 100), 0);
        assert!(apply_stiffness(80, 50) < 80);
    }
}
