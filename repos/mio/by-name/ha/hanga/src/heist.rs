//! A contract mark is a place the host can point at. The game owns the job.

#[derive(Clone, Debug, PartialEq)]
pub struct ContractMark {
    pub pos: [i32; 3],
    pub radius: f32,
    pub rgb: [f32; 3],
    /// If true, the host takes the selected hotbar item on a successful cash-out.
    pub take: bool,
}

/// Parse a mod `contract-mark` string. Empty / unknown → `None`.
///
/// ```text
/// x=531;y=3;z=550;radius=12;take=1;r=0.9;g=0.7;b=0.2
/// ```
pub fn parse_contract_mark(text: &str) -> Option<ContractMark> {
    parse_contract_mark_node(&crate::kit::Node::Text(text.into()))
}

pub fn parse_contract_mark_fields(fields: &crate::kit::Fields) -> Option<ContractMark> {
    parse_contract_mark_node(&fields.as_node())
}

pub fn parse_contract_mark_node(node: &crate::kit::Node) -> Option<ContractMark> {
    if node.is_empty() {
        return None;
    }
    let mut pos = [0, 0, 0];
    let mut radius = 8.0;
    let mut rgb = [0.92, 0.78, 0.28];
    let mut take = false;
    let mut saw_x = false;
    let mut saw_y = false;
    let mut saw_z = false;
    for (key, cell) in node.entries() {
        match key.as_str() {
            "x" => {
                if let Some(v) = cell.as_i32() {
                    pos[0] = v;
                    saw_x = true;
                }
            }
            "y" => {
                if let Some(v) = cell.as_i32() {
                    pos[1] = v;
                    saw_y = true;
                }
            }
            "z" => {
                if let Some(v) = cell.as_i32() {
                    pos[2] = v;
                    saw_z = true;
                }
            }
            "radius" => {
                if let Some(v) = cell.as_f32() {
                    radius = v.max(0.5);
                }
            }
            "take" => take = cell.as_flag(),
            "r" => {
                if let Some(v) = cell.as_f32() {
                    rgb[0] = scale_channel(v);
                }
            }
            "g" => {
                if let Some(v) = cell.as_f32() {
                    rgb[1] = scale_channel(v);
                }
            }
            "b" => {
                if let Some(v) = cell.as_f32() {
                    rgb[2] = scale_channel(v);
                }
            }
            _ => {}
        }
    }
    (saw_x && saw_y && saw_z).then_some(ContractMark {
        pos,
        radius,
        rgb,
        take,
    })
}

/// Host → mod context. The engine does not interpret `held`.
pub fn contract_context(held: &str, pos: [i32; 3], in_vehicle: bool, near: bool) -> String {
    format!(
        "held={held};x={};y={};z={};vehicle={};near={}",
        pos[0],
        pos[1],
        pos[2],
        i32::from(in_vehicle),
        i32::from(near)
    )
}

pub fn mark_reached(px: f32, py: f32, pz: f32, mark: &ContractMark) -> bool {
    let dx = px - mark.pos[0] as f32;
    let dy = py - mark.pos[1] as f32;
    let dz = pz - mark.pos[2] as f32;
    dx * dx + dy * dy + dz * dz <= mark.radius * mark.radius
}

fn scale_channel(n: f32) -> f32 {
    if n > 1.0 {
        (n / 255.0).clamp(0.0, 1.0)
    } else {
        n.clamp(0.0, 1.0)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_mark_is_none() {
        assert_eq!(parse_contract_mark(""), None);
        assert_eq!(parse_contract_mark("need=held:glass"), None);
        assert_eq!(parse_contract_mark("x=531"), None);
    }

    #[test]
    fn storefront_mark_parses() {
        let mark = parse_contract_mark("x=531;y=3;z=550;radius=12;take=1;r=0.9;g=0.2;b=0.2").unwrap();
        assert_eq!(mark.pos, [531, 3, 550]);
        assert!(mark.take);
        assert!((mark.radius - 12.0).abs() < 1e-5);
        assert!(mark_reached(531.0, 3.0, 550.0, &mark));
        assert!(!mark_reached(600.0, 3.0, 550.0, &mark));
    }

    #[test]
    fn context_is_opaque_to_the_host() {
        let ctx = contract_context("glass", [504, 2, 508], false, true);
        assert!(ctx.contains("held=glass"));
        assert!(ctx.contains("near=1"));
        assert!(ctx.contains("vehicle=0"));
        assert!(ctx.contains("y=2"));
    }
}
