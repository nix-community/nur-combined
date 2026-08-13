//! Low-poly humanoid outfits. Kind names come from the mod; the host only paints.

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct FigurePalette {
    pub skin: [f32; 3],
    pub shirt: [f32; 3],
    pub pants: [f32; 3],
    pub accent: [f32; 3],
    pub has_hat: bool,
}

const SKIN: [[f32; 3]; 5] = [
    [0.93, 0.76, 0.64],
    [0.84, 0.64, 0.48],
    [0.62, 0.42, 0.28],
    [0.42, 0.26, 0.18],
    [0.96, 0.84, 0.72],
];

const SHIRTS: [[f32; 3]; 7] = [
    [0.22, 0.38, 0.58],
    [0.62, 0.28, 0.18],
    [0.38, 0.42, 0.22],
    [0.48, 0.16, 0.22],
    [0.72, 0.58, 0.38],
    [0.28, 0.28, 0.30],
    [0.82, 0.78, 0.68],
];

const PANTS: [[f32; 3]; 4] = [
    [0.18, 0.20, 0.28],
    [0.28, 0.24, 0.18],
    [0.16, 0.16, 0.16],
    [0.32, 0.34, 0.38],
];

/// Outfit for an agent kind. `salt` varies pedestrians so they are not clones.
pub fn figure_palette(kind: &str, salt: u32) -> FigurePalette {
    let skin = SKIN[(salt as usize) % SKIN.len()];
    match kind {
        "cop" => FigurePalette {
            skin,
            shirt: [0.12, 0.18, 0.40],
            pants: [0.08, 0.08, 0.12],
            accent: [0.78, 0.64, 0.22],
            has_hat: true,
        },
        _ => FigurePalette {
            skin,
            shirt: SHIRTS[(salt as usize / 5) % SHIRTS.len()],
            pants: PANTS[(salt as usize / 3) % PANTS.len()],
            accent: [0.15, 0.15, 0.16],
            has_hat: salt % 7 == 0,
        },
    }
}

pub fn figure_salt(x: f32, z: f32) -> u32 {
    let xi = x.to_bits().wrapping_mul(0x9E37_79B9);
    let zi = z.to_bits().wrapping_mul(0x85EB_CA6B);
    xi ^ zi.rotate_left(16)
}

/// Yaw so a Bevy mesh that faces `-Z` looks along XZ velocity.
pub fn yaw_toward(vx: f32, vz: f32) -> Option<f32> {
    if vx * vx + vz * vz < 1e-6 {
        return None;
    }
    Some((-vx).atan2(-vz))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cop_wears_navy_and_a_hat() {
        let pal = figure_palette("cop", 3);
        assert!(pal.has_hat);
        assert!(pal.shirt[2] > pal.shirt[0]);
        assert_ne!(figure_palette("cop", 0).skin, figure_palette("cop", 1).skin);
    }

    #[test]
    fn pedestrians_are_not_uniform_green() {
        let a = figure_palette("pedestrian", 1);
        let b = figure_palette("pedestrian", 40);
        assert_ne!(a.shirt, b.shirt);
        assert!(a.shirt != [0.2, 0.7, 0.3]);
    }

    #[test]
    fn faces_minus_z_when_moving_minus_z() {
        let yaw = yaw_toward(0.0, -1.0).unwrap();
        assert!(yaw.abs() < 1e-5);
    }

    #[test]
    fn faces_plus_x_when_moving_plus_x() {
        let yaw = yaw_toward(1.0, 0.0).unwrap();
        assert!((yaw + std::f32::consts::FRAC_PI_2).abs() < 1e-5);
    }

    #[test]
    fn still_returns_none() {
        assert_eq!(yaw_toward(0.0, 0.0), None);
    }
}
