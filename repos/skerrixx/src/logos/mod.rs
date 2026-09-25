//! distro logo registry.
//!
//! every distro logo lives in its own submodule (`src/logos/<id>.rs`) as a
//! `pub const LOGO: Logo`. this module owns the registry (`LOGOS`) and the
//! lookup api used by the rest of the program.

pub mod alma;
pub mod alpine;
pub mod android;
pub mod arch;
pub mod archcraft;
pub mod archlabs;
pub mod artix;
pub mod bedrock;
pub mod cachyos;
pub mod centos;
pub mod chimera;
pub mod debian;
pub mod elementary;
pub mod endeavouros;
pub mod fedora;
pub mod garuda;
pub mod gentoo;
pub mod haliade;
pub mod kali;
pub mod kyon;
pub mod lfs;
pub mod mageia;
pub mod manjaro;
pub mod mint;
pub mod mist;
pub mod netbsd;
pub mod nix;
pub mod omarchy;
pub mod openmandriva;
pub mod opensuse;
pub mod pop;
pub mod raspbian;
pub mod rfetch;
pub mod rhel;
pub mod rocky;
pub mod ubuntu;
pub mod unknown;
pub mod void;

/// a single distro logo: identity, search aliases, display label, ascii art
/// and the accent color used when coloring the art.
pub struct Logo {
    pub id: &'static str,
    pub aliases: &'static [&'static str],
    pub display_name: &'static str,
    pub art: &'static str,
    pub color: (u8, u8, u8),
}

/// every known distro logo, in display/selection order.
///
/// `unknown` is deliberately excluded: it is the fallback only.
/// the three opensuse variants share one `opensuse` art constant.
pub static LOGOS: &[&Logo] = &[
    &arch::LOGO,
    &artix::LOGO,
    &manjaro::LOGO,
    &omarchy::LOGO,
    &endeavouros::LOGO,
    &archlabs::LOGO,
    &archcraft::LOGO,
    &kyon::LOGO,
    &garuda::LOGO,
    &ubuntu::LOGO,
    &debian::LOGO,
    &fedora::LOGO,
    &rhel::LOGO,
    &bedrock::LOGO,
    &gentoo::LOGO,
    &mint::LOGO,
    &lfs::LOGO,
    &kali::LOGO,
    &cachyos::LOGO,
    &void::LOGO,
    &rfetch::LOGO,
    &centos::LOGO,
    &pop::LOGO,
    &nix::LOGO,
    &opensuse::TUMBLEWEED,
    &opensuse::LEAP,
    &opensuse::SLES,
    &mist::LOGO,
    &openmandriva::LOGO,
    &mageia::LOGO,
    &alma::LOGO,
    &rocky::LOGO,
    &raspbian::LOGO,
    &elementary::LOGO,
    &chimera::LOGO,
    &alpine::LOGO,
    &haliade::LOGO,
    &netbsd::LOGO,
    &android::LOGO,
];

/// trim surrounding whitespace and lowercase a user-supplied distro name.
fn normalize(name: &str) -> String {
    name.trim().to_lowercase()
}

/// resolve a name to a logo by matching its id or any of its aliases.
fn lookup(name: &str) -> Option<&'static Logo> {
    let v = normalize(name);
    LOGOS
        .iter()
        .copied()
        .find(|logo| logo.id == v.as_str() || logo.aliases.contains(&v.as_str()))
}

/// ascii art for `name`, falling back to the generic tux art.
pub fn get_ascii_art(name: &str) -> &'static str {
    lookup(name).map_or(unknown::LOGO.art, |logo| logo.art)
}

/// accent color for `name`, falling back to white.
pub fn get_logo_color(name: &str) -> (u8, u8, u8) {
    lookup(name).map_or((255, 255, 255), |logo| logo.color)
}

/// display label for `name`, falling back to the generic unknown label.
pub fn display_name_for(name: &str) -> &'static str {
    lookup(name).map_or(unknown::LOGO.display_name, |logo| logo.display_name)
}

/// the distros offered to the user, in selection order.
pub fn known_distros() -> Vec<&'static str> {
    vec![
        "arch",
        "debian",
        "ubuntu",
        "linuxmint",
        "kali",
        "raspbian",
        "fedora",
        "rhel",
        "centos",
        "rocky",
        "almalinux",
        "opensuse-tumbleweed",
        "opensuse-leap",
        "sles",
        "gentoo",
        "void",
        "nixos",
        "pop",
        "elementary",
        "mageia",
        "openmandriva",
        "lfs",
        "bedrock",
        "rfetch",
        "cachyos",
        "mist",
        "chimera",
        "haliade",
        "alpine",
        "android",
    ]
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashSet;

    #[test]
    fn ids_are_unique_and_complete() {
        assert_eq!(LOGOS.len(), 39, "expected exactly 39 logos");
        let mut seen = HashSet::new();
        for logo in LOGOS {
            assert!(seen.insert(logo.id), "duplicate logo id: {}", logo.id);
        }
        assert_eq!(seen.len(), LOGOS.len());
    }

    #[test]
    fn aliases_are_unique_and_disjoint_from_ids() {
        let ids: HashSet<&str> = LOGOS.iter().map(|logo| logo.id).collect();
        let mut seen: HashSet<&str> = HashSet::new();
        for logo in LOGOS {
            for &alias in logo.aliases {
                assert!(
                    !ids.contains(alias),
                    "alias {alias:?} collides with a logo id"
                );
                assert!(seen.insert(alias), "duplicate alias: {alias:?}");
            }
        }
    }

    #[test]
    fn every_known_distro_resolves() {
        let distros = known_distros();
        assert_eq!(distros.len(), 30, "expected exactly 30 known distros");
        assert!(
            !distros.contains(&"unknown"),
            "unknown is a fallback, not a distro"
        );
        for name in distros {
            assert!(
                lookup(name).is_some(),
                "known distro {name:?} does not resolve"
            );
        }
    }

    #[test]
    fn fallback_is_unknown() {
        let missing = "definitely-not-a-distro";
        assert_eq!(get_ascii_art(missing), unknown::LOGO.art);
        assert_eq!(get_logo_color(missing), (255, 255, 255));
        assert_eq!(display_name_for(missing), unknown::LOGO.display_name);
        assert!(unknown::LOGO.display_name.contains('\u{f31a}'));
    }

    #[test]
    fn opensuse_variants_share_art() {
        assert_eq!(opensuse::TUMBLEWEED.art, opensuse::LEAP.art);
        assert_eq!(opensuse::LEAP.art, opensuse::SLES.art);
    }

    #[test]
    fn normalization_trims_and_lowercases() {
        assert_eq!(normalize("  ArCh  "), "arch");
        assert_eq!(get_ascii_art("  ArCh  "), get_ascii_art("arch"));
        assert_eq!(get_logo_color("  ArCh  "), get_logo_color("arch"));
        assert_eq!(display_name_for("  ArCh  "), display_name_for("arch"));
    }

    #[test]
    fn lookup_matches_ids_and_aliases() {
        assert_eq!(lookup("arch").map(|logo| logo.id), Some("arch"));
        assert_eq!(lookup("archlinux").map(|logo| logo.id), Some("arch"));
        assert_eq!(lookup("nixos").map(|logo| logo.id), Some("nix"));
        assert!(lookup("").is_none());
    }

    #[test]
    fn haliade_rename() {
        assert_eq!(LOGOS.len(), 39);
        assert_eq!(lookup("haliade").map(|logo| logo.id), Some("haliade"));
        assert_eq!(lookup("zerene").map(|logo| logo.id), Some("haliade"));
        assert!(known_distros().contains(&"haliade"));
        assert!(!known_distros().contains(&"zerene"));
        assert!(display_name_for("haliade").contains("haliade"));
        assert!(display_name_for("haliade").contains('\u{efa7}'));
    }
}
