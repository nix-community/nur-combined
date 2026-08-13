//! Generic crash math. The mod decides severity; the host only applies it.

pub const CRASH_SEVERITY_MAX: i32 = 100;

pub fn clamp_crash_severity(severity: i32) -> i32 {
    severity.clamp(0, CRASH_SEVERITY_MAX)
}

/// Maps crumple 0-100 to a remaining scale (1.0 = intact, ~0.45 = folded).
pub fn crumple_scale(crumple: i32) -> f32 {
    let t = clamp_crash_severity(crumple) as f32 / CRASH_SEVERITY_MAX as f32;
    1.0 - t * 0.55
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn taps_are_not_impacts() {
        assert_eq!(impact_speed(6.0, 5.0, false), None);
        assert_eq!(impact_speed(6.0, 5.0, true), None);
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
}
