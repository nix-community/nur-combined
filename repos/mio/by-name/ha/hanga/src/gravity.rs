//! Gravity is a field the game defines. The host only applies it.

#[derive(Clone, Debug, PartialEq)]
pub enum GravityKind {
    None,
    Constant {
        accel: [f32; 3],
    },
    Point {
        center: [f32; 3],
        strength: f32,
        inv_sq: bool,
    },
}

#[derive(Clone, Debug, PartialEq)]
pub struct GravityKit {
    pub kind: GravityKind,
    /// Leave-ground speed along the anti-gravity axis. 0 = no jump.
    pub jump: f32,
    /// Planar walk speed. 0 = cannot walk.
    pub walk: f32,
    /// Walk/jump axis when the field does not imply one (`none`).
    pub up: [f32; 3],
}

impl Default for GravityKit {
    fn default() -> Self {
        Self {
            kind: GravityKind::None,
            jump: 0.0,
            walk: 10.0,
            up: [0.0, 1.0, 0.0],
        }
    }
}

/// Parse a mod `gravity` string. Unknown keys are ignored.
///
/// ```text
/// kind=constant;x=0;y=-9.81;z=0;jump=5;walk=10
/// kind=down;g=9.81;jump=5
/// kind=none;walk=8
/// kind=point;x=0;y=0;z=0;strength=20
/// kind=point;x=0;y=0;z=0;strength=500;falloff=invsq
/// ```
pub fn parse_gravity(text: &str) -> GravityKit {
    parse_gravity_fields(&crate::kit::Fields::from_text(text))
}

pub fn parse_gravity_fields(fields: &crate::kit::Fields) -> GravityKit {
    let mut kit = GravityKit::default();
    let mut kind = String::new();
    let mut x = 0.0;
    let mut y = 0.0;
    let mut z = 0.0;
    let mut g = 9.81;
    let mut saw_axis = false;
    let mut saw_g = false;
    let mut strength = 20.0;
    let mut inv_sq = false;
    for (key, cell) in &fields.pairs {
        let value = cell.text();
        match key.as_str() {
            "kind" | "type" => kind = value.trim().to_ascii_lowercase(),
            "x" => {
                if let Some(v) = cell.as_f32() {
                    x = v;
                    saw_axis = true;
                }
            }
            "y" => {
                if let Some(v) = cell.as_f32() {
                    y = v;
                    saw_axis = true;
                }
            }
            "z" => {
                if let Some(v) = cell.as_f32() {
                    z = v;
                    saw_axis = true;
                }
            }
            "g" | "magnitude" => {
                if let Some(v) = cell.as_f32() {
                    g = v.abs();
                    saw_g = true;
                }
            }
            "strength" => {
                if let Some(v) = cell.as_f32() {
                    strength = v;
                }
            }
            "falloff" => {
                inv_sq = cell.as_flag()
                    || matches!(value.trim(), "invsq" | "inv-sq" | "inverse-square")
            }
            "jump" => {
                if let Some(v) = cell.as_f32() {
                    kit.jump = v.max(0.0);
                }
            }
            "walk" => {
                if let Some(v) = cell.as_f32() {
                    kit.walk = v.max(0.0);
                }
            }
            "up" => {
                if let Some(v) = parse_n(&value, 3) {
                    kit.up = unit([v[0], v[1], v[2]], [0.0, 1.0, 0.0]);
                }
            }
            "up.x" => {
                if let Some(v) = cell.as_f32() {
                    kit.up[0] = v;
                }
            }
            "up.y" => {
                if let Some(v) = cell.as_f32() {
                    kit.up[1] = v;
                }
            }
            "up.z" => {
                if let Some(v) = cell.as_f32() {
                    kit.up[2] = v;
                }
            }
            _ => {}
        }
    }
    kit.kind = match kind.as_str() {
        "none" | "zero" | "off" => GravityKind::None,
        "point" | "attractor" | "planet" => GravityKind::Point {
            center: [x, y, z],
            strength,
            inv_sq,
        },
        "down" | "earth" => {
            let accel = if saw_axis {
                [x, y, z]
            } else {
                [0.0, -g, 0.0]
            };
            GravityKind::Constant { accel }
        }
        "constant" | "linear" | "uniform" => {
            let accel = if saw_axis {
                [x, y, z]
            } else if saw_g {
                [0.0, -g, 0.0]
            } else {
                [0.0, 0.0, 0.0]
            };
            GravityKind::Constant { accel }
        }
        _ if !kind.is_empty() && saw_axis => GravityKind::Constant { accel: [x, y, z] },
        _ => GravityKind::None,
    };
    kit
}

/// Constant acceleration the physics engine should use. Point/none are `[0,0,0]`.
pub fn avian_accel(kit: &GravityKit) -> [f32; 3] {
    match kit.kind {
        GravityKind::Constant { accel } => accel,
        _ => [0.0, 0.0, 0.0],
    }
}

/// Unit axis to walk on / jump along (anti-gravity, or `up` for none).
pub fn walk_up(kit: &GravityKit, pos: [f32; 3]) -> [f32; 3] {
    match kit.kind {
        GravityKind::None => kit.up,
        GravityKind::Constant { accel } => unit([-accel[0], -accel[1], -accel[2]], kit.up),
        GravityKind::Point { center, .. } => unit(
            [pos[0] - center[0], pos[1] - center[1], pos[2] - center[2]],
            kit.up,
        ),
    }
}

/// Acceleration at `pos` for a point field. Constant/none return zero here.
pub fn point_accel(kit: &GravityKit, pos: [f32; 3]) -> [f32; 3] {
    let GravityKind::Point {
        center,
        strength,
        inv_sq,
    } = kit.kind
    else {
        return [0.0, 0.0, 0.0];
    };
    let delta = [center[0] - pos[0], center[1] - pos[1], center[2] - pos[2]];
    let dist2 = delta[0] * delta[0] + delta[1] * delta[1] + delta[2] * delta[2];
    if dist2 < 1e-8 {
        return [0.0, 0.0, 0.0];
    }
    let dist = dist2.sqrt();
    let mag = if inv_sq {
        strength / dist2
    } else {
        strength
    };
    [
        delta[0] / dist * mag,
        delta[1] / dist * mag,
        delta[2] / dist * mag,
    ]
}

/// Replace the planar part of `vel` with `wish * speed`; keep the `up` component.
pub fn set_planar_velocity(vel: [f32; 3], wish: [f32; 3], speed: f32, up: [f32; 3]) -> [f32; 3] {
    let up = unit(up, [0.0, 1.0, 0.0]);
    let along = dot(vel, up);
    let planar = [
        wish[0] - up[0] * dot(wish, up),
        wish[1] - up[1] * dot(wish, up),
        wish[2] - up[2] * dot(wish, up),
    ];
    let planar = scale(unit(planar, [0.0, 0.0, 0.0]), speed);
    [
        planar[0] + up[0] * along,
        planar[1] + up[1] * along,
        planar[2] + up[2] * along,
    ]
}

/// Cell under the feet along `-up`, used to ask the voxel world if we can jump.
pub fn support_cell(pos: [f32; 3], up: [f32; 3], reach: f32) -> [i32; 3] {
    let up = unit(up, [0.0, 1.0, 0.0]);
    [
        (pos[0] - up[0] * reach).round() as i32,
        (pos[1] - up[1] * reach).round() as i32,
        (pos[2] - up[2] * reach).round() as i32,
    ]
}

/// True if any sample along `-up` sits on a solid.
pub fn can_jump_from(pos: [f32; 3], up: [f32; 3], solid: impl Fn([i32; 3]) -> bool) -> bool {
    [0.55, 1.05, 1.55].iter().any(|reach| solid(support_cell(pos, up, *reach)))
}

/// Zero-g kits treat jump as a thruster. Fields with a down need a floor.
pub fn jump_needs_floor(kit: &GravityKit) -> bool {
    !matches!(kit.kind, GravityKind::None)
}

/// Set speed along `up` to `jump`, keeping the planar part.
pub fn set_jump(vel: [f32; 3], jump: f32, up: [f32; 3]) -> [f32; 3] {
    let up = unit(up, [0.0, 1.0, 0.0]);
    let planar = [
        vel[0] - up[0] * dot(vel, up),
        vel[1] - up[1] * dot(vel, up),
        vel[2] - up[2] * dot(vel, up),
    ];
    [
        planar[0] + up[0] * jump,
        planar[1] + up[1] * jump,
        planar[2] + up[2] * jump,
    ]
}

fn parse_n(value: &str, n: usize) -> Option<Vec<f32>> {
    let nums: Vec<f32> = value
        .split(|c: char| c == ',' || c.is_whitespace())
        .filter(|p| !p.is_empty())
        .filter_map(|p| p.parse().ok())
        .collect();
    (nums.len() >= n).then_some(nums)
}

fn dot(a: [f32; 3], b: [f32; 3]) -> f32 {
    a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
}

fn scale(v: [f32; 3], s: f32) -> [f32; 3] {
    [v[0] * s, v[1] * s, v[2] * s]
}

fn unit(v: [f32; 3], fallback: [f32; 3]) -> [f32; 3] {
    let len = (v[0] * v[0] + v[1] * v[1] + v[2] * v[2]).sqrt();
    if len < 1e-6 {
        fallback
    } else {
        [v[0] / len, v[1] / len, v[2] / len]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_kit_is_no_gravity() {
        let kit = parse_gravity("");
        assert_eq!(kit.kind, GravityKind::None);
        assert_eq!(avian_accel(&kit), [0.0, 0.0, 0.0]);
        assert_eq!(kit.jump, 0.0);
        assert!((kit.walk - 10.0).abs() < 1e-5);
    }

    #[test]
    fn earth_down_is_just_one_constant_field() {
        let kit = parse_gravity("kind=down;g=9.81;jump=5");
        assert_eq!(
            kit.kind,
            GravityKind::Constant {
                accel: [0.0, -9.81, 0.0]
            }
        );
        assert!((kit.jump - 5.0).abs() < 1e-5);
        assert_eq!(walk_up(&kit, [0.0, 0.0, 0.0]), [0.0, 1.0, 0.0]);
    }

    #[test]
    fn sideways_constant_walks_on_the_yz_plane() {
        let kit = parse_gravity("kind=constant;x=-10;y=0;z=0;jump=3");
        let up = walk_up(&kit, [0.0, 0.0, 0.0]);
        assert!((up[0] - 1.0).abs() < 1e-5);
        let next = set_planar_velocity([1.0, 2.0, 3.0], [0.0, 1.0, 0.0], 4.0, up);
        assert!((next[0] - 1.0).abs() < 1e-4, "keep fall along gravity");
        assert!((next[1] - 4.0).abs() < 1e-4);
    }

    #[test]
    fn point_field_pulls_toward_the_center() {
        let kit = parse_gravity("kind=point;x=0;y=0;z=0;strength=10");
        let a = point_accel(&kit, [10.0, 0.0, 0.0]);
        assert!((a[0] + 10.0).abs() < 1e-4);
        assert!(a[1].abs() < 1e-4);
        let inv = parse_gravity("kind=point;x=0;y=0;z=0;strength=40;falloff=invsq");
        let b = point_accel(&inv, [2.0, 0.0, 0.0]);
        assert!((b[0] + 10.0).abs() < 1e-4);
    }

    #[test]
    fn jump_replaces_the_up_component() {
        let v = set_jump([3.0, -2.0, 0.0], 5.0, [0.0, 1.0, 0.0]);
        assert!((v[0] - 3.0).abs() < 1e-5);
        assert!((v[1] - 5.0).abs() < 1e-5);
    }

    #[test]
    fn walk_speed_is_the_games() {
        let kit = parse_gravity("kind=none;walk=4;jump=2");
        assert!((kit.walk - 4.0).abs() < 1e-5);
    }

    #[test]
    fn jump_needs_a_floor_along_up() {
        let pos = [504.0, 2.0, 508.0];
        let up = [0.0, 1.0, 0.0];
        assert!(can_jump_from(pos, up, |c| c == [504, 0, 508] || c == [504, 1, 508]));
        assert!(!can_jump_from(pos, up, |_| false));
        assert!(jump_needs_floor(&parse_gravity("kind=down;g=9.81")));
        assert!(!jump_needs_floor(&parse_gravity("kind=none;jump=2")));
    }
}
