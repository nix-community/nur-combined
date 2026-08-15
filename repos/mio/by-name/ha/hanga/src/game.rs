//! A game is a collection of mods plus presentation the engine must not invent.
//!
//! `.game` files live next to gameplay WASM (`share/hanga/games`). The host only
//! parses keys, discovers files, and paints what the file asked for.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

pub const DEFAULT_GAME: &str = "urban_chaos";

/// Neutral host fallback when `--mod` points at a lone WASM with no `.game`.
pub const NEUTRAL_BACKDROP: MenuBackdrop = MenuBackdrop {
    clear: [0.08, 0.08, 0.10],
    panel: [0.04, 0.04, 0.05, 0.82],
    accent: [0.82, 0.82, 0.78],
    button: [0.16, 0.16, 0.18],
    button_hover: [0.28, 0.28, 0.32],
    sky: [0.10, 0.10, 0.12],
};

pub const NEUTRAL_ATMOSPHERE: Atmosphere = Atmosphere {
    sun: [1.0, 1.0, 1.0],
    sun_illuminance: 8_000.0,
    ambient: [0.50, 0.50, 0.55],
    ambient_brightness: 200.0,
    cloud: None,
    cloud_color: [0.92, 0.92, 0.94],
    cloud_height: 160.0,
    cloud_scale: 480.0,
    fog: None,
    fog_start: 80.0,
    fog_end: 420.0,
    voxel_palette: None,
    palette: None,
};

#[derive(Clone, Debug, PartialEq)]
pub struct Atmosphere {
    pub sun: [f32; 3],
    pub sun_illuminance: f32,
    pub ambient: [f32; 3],
    pub ambient_brightness: f32,
    /// `None` = no clouds. `Some("generated")` or a PNG name next to the `.game`.
    pub cloud: Option<String>,
    pub cloud_color: [f32; 3],
    pub cloud_height: f32,
    pub cloud_scale: f32,
    pub fog: Option<[f32; 3]>,
    pub fog_start: f32,
    pub fog_end: f32,
    pub voxel_palette: Option<String>,
    pub palette: Option<[[u8; 3]; 16]>,
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct MenuBackdrop {
    pub clear: [f32; 3],
    pub panel: [f32; 4],
    pub accent: [f32; 3],
    pub button: [f32; 3],
    pub button_hover: [f32; 3],
    pub sky: [f32; 3],
}

#[derive(Clone, Debug, PartialEq)]
pub struct GameSpec {
    pub id: String,
    pub mods: Vec<String>,
    pub titles: BTreeMap<String, String>,
    pub backdrop: MenuBackdrop,
    pub atmosphere: Atmosphere,
    /// Directory that contained the `.game` file, if loaded from disk.
    pub asset_dir: Option<PathBuf>,
}

impl GameSpec {
    pub fn lead_mod(&self) -> &str {
        self.mods.first().map(String::as_str).unwrap_or(&self.id)
    }

    pub fn has_clouds(&self) -> bool {
        self.atmosphere
            .cloud
            .as_deref()
            .is_some_and(|name| !name.is_empty() && name != "none")
    }

    pub fn palette_layers(&self) -> [[u8; 3]; 16] {
        self.atmosphere
            .palette
            .unwrap_or(crate::palette::DEFAULT_LAYER_RGB)
    }

    /// Wire id for P2P: game id plus mods in load order. Mismatched peers drop actions.
    pub fn collection_key(&self) -> String {
        format!("{}:{}", self.id, self.mods.join("+"))
    }

    pub fn title(&self, locale: &str) -> String {
        let folded = locale.trim().to_lowercase();
        let primary = folded.split('-').next().unwrap_or(&folded);
        self.titles
            .get(&folded)
            .or_else(|| self.titles.get(primary))
            .or_else(|| self.titles.get("en"))
            .cloned()
            .unwrap_or_else(|| self.id.clone())
    }
}

/// `--game urban_chaos`. `None` if the flag is absent.
pub fn parse_game_spec(args: &[String]) -> Option<String> {
    args.windows(2)
        .find(|w| w[0] == "--game")
        .map(|w| w[1].clone())
}

/// `--game` wins, then `--mod`, then the shipped default game.
pub fn selected_game_id(args: &[String], default_mod: &str) -> String {
    if let Some(game) = parse_game_spec(args) {
        return game;
    }
    args.windows(2)
        .find(|w| w[0] == "--mod")
        .map(|w| w[1].clone())
        .unwrap_or_else(|| default_mod.to_string())
}

pub fn implicit_game(spec: &str) -> GameSpec {
    let id = spec.trim();
    GameSpec {
        id: id.to_string(),
        mods: vec![id.to_string()],
        titles: BTreeMap::new(),
        backdrop: NEUTRAL_BACKDROP,
        atmosphere: NEUTRAL_ATMOSPHERE,
        asset_dir: None,
    }
}

pub fn resolve_game(catalog: &[GameSpec], spec: &str) -> GameSpec {
    catalog
        .iter()
        .find(|game| game.id == spec)
        .or_else(|| {
            catalog
                .iter()
                .find(|game| game.lead_mod() == spec && game.mods.len() == 1)
        })
        .or_else(|| catalog.iter().find(|game| game.lead_mod() == spec))
        .or_else(|| catalog.iter().find(|game| game.mods.iter().any(|m| m == spec)))
        .cloned()
        .unwrap_or_else(|| implicit_game(spec))
}

pub fn cycle_game(catalog: &[GameSpec], current: &str) -> String {
    if catalog.is_empty() {
        return current.to_string();
    }
    let idx = catalog
        .iter()
        .position(|game| game.id == current || game.lead_mod() == current)
        .unwrap_or(0);
    catalog[(idx + 1) % catalog.len()].id.clone()
}

pub fn parse_game_file(text: &str) -> Result<GameSpec, String> {
    let mut id = String::new();
    let mut mods = Vec::new();
    let mut titles = BTreeMap::new();
    let mut backdrop = NEUTRAL_BACKDROP;
    let mut atmosphere = NEUTRAL_ATMOSPHERE;
    let mut palette = [[0u8; 3]; 16];
    let mut palette_set = [false; 16];
    for raw in text.lines() {
        let line = raw.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let Some((key, value)) = line.split_once('=') else {
            return Err(format!("expected key=value, got {line}"));
        };
        let key = key.trim();
        let value = value.trim();
        match key {
            "id" => id = value.to_string(),
            "mods" => {
                mods = value
                    .split(|c: char| c == ',' || c.is_whitespace())
                    .filter(|part| !part.is_empty())
                    .map(|part| part.to_string())
                    .collect();
            }
            "title" => {
                titles.insert("en".into(), value.to_string());
            }
            key if key.starts_with("title.") => {
                titles.insert(key[6..].to_lowercase(), value.to_string());
            }
            "sky" => backdrop.sky = parse_rgb(value).ok_or_else(|| format!("bad sky: {value}"))?,
            "menu_clear" => {
                backdrop.clear = parse_rgb(value).ok_or_else(|| format!("bad menu_clear: {value}"))?
            }
            "menu_panel" => {
                backdrop.panel =
                    parse_rgba(value).ok_or_else(|| format!("bad menu_panel: {value}"))?
            }
            "menu_accent" => {
                backdrop.accent =
                    parse_rgb(value).ok_or_else(|| format!("bad menu_accent: {value}"))?
            }
            "menu_button" => {
                backdrop.button =
                    parse_rgb(value).ok_or_else(|| format!("bad menu_button: {value}"))?
            }
            "menu_button_hover" => {
                backdrop.button_hover =
                    parse_rgb(value).ok_or_else(|| format!("bad menu_button_hover: {value}"))?
            }
            "sun" => atmosphere.sun = parse_rgb(value).ok_or_else(|| format!("bad sun: {value}"))?,
            "sun_illuminance" => {
                atmosphere.sun_illuminance = parse_one(value)
                    .ok_or_else(|| format!("bad sun_illuminance: {value}"))?
            }
            "ambient" => {
                atmosphere.ambient =
                    parse_rgb(value).ok_or_else(|| format!("bad ambient: {value}"))?
            }
            "ambient_brightness" => {
                atmosphere.ambient_brightness = parse_one(value)
                    .ok_or_else(|| format!("bad ambient_brightness: {value}"))?
            }
            "cloud" => {
                atmosphere.cloud = if value.is_empty() || value == "none" {
                    None
                } else {
                    Some(value.to_string())
                };
            }
            "cloud_color" => {
                atmosphere.cloud_color =
                    parse_rgb(value).ok_or_else(|| format!("bad cloud_color: {value}"))?
            }
            "cloud_height" => {
                atmosphere.cloud_height =
                    parse_one(value).ok_or_else(|| format!("bad cloud_height: {value}"))?
            }
            "cloud_scale" => {
                atmosphere.cloud_scale =
                    parse_one(value).ok_or_else(|| format!("bad cloud_scale: {value}"))?
            }
            "fog" => {
                atmosphere.fog = Some(parse_rgb(value).ok_or_else(|| format!("bad fog: {value}"))?)
            }
            "fog_start" => {
                atmosphere.fog_start =
                    parse_one(value).ok_or_else(|| format!("bad fog_start: {value}"))?
            }
            "fog_end" => {
                atmosphere.fog_end =
                    parse_one(value).ok_or_else(|| format!("bad fog_end: {value}"))?
            }
            "voxel_palette" => atmosphere.voxel_palette = Some(value.to_string()),
            key if key.starts_with("palette.") => {
                let idx: usize = key[8..]
                    .parse()
                    .map_err(|_| format!("bad palette index: {key}"))?;
                if idx >= 16 {
                    return Err(format!("palette index {idx} out of range"));
                }
                let rgb = parse_rgb(value).ok_or_else(|| format!("bad {key}: {value}"))?;
                palette[idx] = [
                    (rgb[0] * 255.0).round() as u8,
                    (rgb[1] * 255.0).round() as u8,
                    (rgb[2] * 255.0).round() as u8,
                ];
                palette_set[idx] = true;
            }
            _ => {}
        }
    }
    if id.is_empty() {
        return Err("game file needs id=".into());
    }
    if mods.is_empty() {
        mods.push(id.clone());
    }
    if palette_set.iter().any(|set| *set) {
        let mut layers = crate::palette::DEFAULT_LAYER_RGB;
        for (i, set) in palette_set.iter().enumerate() {
            if *set {
                layers[i] = palette[i];
            }
        }
        atmosphere.palette = Some(layers);
    }
    Ok(GameSpec {
        id,
        mods,
        titles,
        backdrop,
        atmosphere,
        asset_dir: None,
    })
}

fn parse_one(value: &str) -> Option<f32> {
    value.trim().parse().ok()
}

/// Look up a texture the game named, next to the `.game` file or under `games/<id>/`.
pub fn resolve_game_texture(game: &GameSpec, name: &str, search: &[PathBuf]) -> Option<PathBuf> {
    let file = Path::new(name);
    if file.is_absolute() && file.is_file() {
        return Some(file.to_path_buf());
    }
    let mut dirs = Vec::new();
    if let Some(dir) = &game.asset_dir {
        dirs.push(dir.clone());
        dirs.push(dir.join(&game.id));
    }
    for dir in search {
        dirs.push(dir.clone());
        dirs.push(dir.join(&game.id));
    }
    for dir in dirs {
        let path = dir.join(name);
        if path.is_file() {
            return Some(path);
        }
    }
    None
}

fn parse_channels(value: &str) -> Vec<f32> {
    value
        .split(|c: char| c == ',' || c.is_whitespace())
        .filter(|part| !part.is_empty())
        .filter_map(|part| part.parse::<f32>().ok())
        .collect()
}

fn scale_channel(n: f32, byte: bool) -> f32 {
    if byte {
        (n / 255.0).clamp(0.0, 1.0)
    } else {
        n.clamp(0.0, 1.0)
    }
}

fn parse_rgb(value: &str) -> Option<[f32; 3]> {
    let nums = parse_channels(value);
    if nums.len() < 3 {
        return None;
    }
    let byte = nums.iter().take(3).any(|n| *n > 1.0);
    Some([
        scale_channel(nums[0], byte),
        scale_channel(nums[1], byte),
        scale_channel(nums[2], byte),
    ])
}

fn parse_rgba(value: &str) -> Option<[f32; 4]> {
    let nums = parse_channels(value);
    if nums.len() < 3 {
        return None;
    }
    let rgb_byte = nums.iter().take(3).any(|n| *n > 1.0);
    let a = nums.get(3).copied().unwrap_or(1.0);
    Some([
        scale_channel(nums[0], rgb_byte),
        scale_channel(nums[1], rgb_byte),
        scale_channel(nums[2], rgb_byte),
        a.clamp(0.0, 1.0),
    ])
}

pub fn game_search_dirs(
    cwd: &Path,
    exe_dir: Option<&Path>,
    env_games: Option<&Path>,
    env_mods: Option<&Path>,
) -> Vec<PathBuf> {
    let mut dirs = Vec::new();
    if let Some(dir) = env_games {
        dirs.push(dir.to_path_buf());
    }
    if let Some(mods) = env_mods {
        if let Some(parent) = mods.parent() {
            dirs.push(parent.join("games"));
        }
    }
    if let Some(exe) = exe_dir {
        dirs.push(exe.join("games"));
        if let Some(root) = exe.parent() {
            dirs.push(root.join("share/hanga/games"));
        }
    }
    dirs.push(cwd.join("games"));
    if let Some(manifest) = option_env!("CARGO_MANIFEST_DIR") {
        dirs.push(PathBuf::from(manifest).join("games"));
    }
    dirs
}

pub fn shipped_games() -> Vec<GameSpec> {
    [
        include_str!("../games/urban_chaos.game"),
        include_str!("../games/testbed.game"),
        include_str!("../games/sandbox.game"),
    ]
    .into_iter()
    .filter_map(|text| parse_game_file(text).ok())
    .collect()
}

/// Disk `.game` files override the same id from the shipped defaults.
pub fn load_game_catalog(dirs: &[PathBuf]) -> Vec<GameSpec> {
    let mut by_id = BTreeMap::new();
    for game in shipped_games() {
        by_id.insert(game.id.clone(), game);
    }
    for dir in dirs {
        let Ok(entries) = std::fs::read_dir(dir) else {
            continue;
        };
        for entry in entries.flatten() {
            let path = entry.path();
            if path.extension().and_then(|ext| ext.to_str()) != Some("game") {
                continue;
            }
            let Ok(text) = std::fs::read_to_string(&path) else {
                continue;
            };
            if let Ok(mut game) = parse_game_file(&text) {
                game.asset_dir = path.parent().map(Path::to_path_buf);
                by_id.insert(game.id.clone(), game);
            }
        }
    }
    by_id.into_values().collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn shipped_games_are_distinct_collections() {
        let games = shipped_games();
        assert_eq!(games.len(), 3);
        let urban = games.iter().find(|g| g.id == "urban_chaos").unwrap();
        let bed = games.iter().find(|g| g.id == "testbed").unwrap();
        let sandbox = games.iter().find(|g| g.id == "sandbox").unwrap();
        assert_eq!(urban.mods, vec!["urban_chaos".to_string()]);
        assert_eq!(bed.mods, vec!["testbed".to_string()]);
        assert_eq!(
            sandbox.mods,
            vec!["urban_chaos".to_string(), "testbed".to_string()]
        );
        assert_eq!(urban.title("en"), "Urban Chaos");
        assert_eq!(bed.title("zh-TW"), "測試台");
        assert_eq!(bed.title("mi"), "Pae whakamātau");
        assert_ne!(urban.backdrop.clear, bed.backdrop.clear);
        assert_ne!(urban.backdrop.accent, NEUTRAL_BACKDROP.accent);
        assert!(urban.has_clouds());
        assert!(sandbox.has_clouds());
        assert!(!bed.has_clouds());
        assert_eq!(sandbox.title("en"), "Sandbox");
        assert_eq!(
            urban.collection_key(),
            "urban_chaos:urban_chaos"
        );
        assert_eq!(
            sandbox.collection_key(),
            "sandbox:urban_chaos+testbed"
        );
        assert_ne!(urban.collection_key(), sandbox.collection_key());
        assert_ne!(urban.palette_layers()[1], crate::palette::DEFAULT_LAYER_RGB[1]);
    }

    #[test]
    fn parse_accepts_bytes_or_unit_floats() {
        let game = parse_game_file(
            "id=demo\nmods=alpha, beta\ntitle=Demo\nmenu_clear=255 0 0\nmenu_panel=0 0 0 0.5\n",
        )
        .unwrap();
        assert_eq!(game.mods, vec!["alpha".to_string(), "beta".to_string()]);
        assert_eq!(game.title("fr"), "Demo");
        assert!((game.backdrop.clear[0] - 1.0).abs() < 1e-5);
        assert!((game.backdrop.panel[3] - 0.5).abs() < 1e-5);
    }

    #[test]
    fn cycle_walks_catalog_ids() {
        let catalog = shipped_games();
        assert_eq!(cycle_game(&catalog, "urban_chaos"), "testbed");
        assert_eq!(cycle_game(&catalog, "testbed"), "sandbox");
        assert_eq!(cycle_game(&catalog, "sandbox"), "urban_chaos");
        assert_eq!(cycle_game(&catalog, "missing.wasm"), "testbed");
    }

    #[test]
    fn flags_pick_game_then_mod() {
        assert_eq!(
            selected_game_id(&["hanga".into()], DEFAULT_GAME),
            "urban_chaos"
        );
        assert_eq!(
            selected_game_id(
                &["hanga".into(), "--mod".into(), "testbed".into()],
                DEFAULT_GAME
            ),
            "testbed"
        );
        assert_eq!(
            selected_game_id(
                &[
                    "hanga".into(),
                    "--game".into(),
                    "urban_chaos".into(),
                    "--mod".into(),
                    "testbed".into()
                ],
                DEFAULT_GAME
            ),
            "urban_chaos"
        );
    }

    #[test]
    fn urban_chaos_id_is_not_the_sandbox_collection() {
        let catalog = shipped_games();
        let game = resolve_game(&catalog, "urban_chaos");
        assert_eq!(game.id, "urban_chaos");
        assert_eq!(game.mods, vec!["urban_chaos".to_string()]);
        let sandbox = resolve_game(&catalog, "sandbox");
        assert_eq!(sandbox.id, "sandbox");
        assert_eq!(sandbox.mods.len(), 2);
    }

    #[test]
    fn unknown_spec_is_a_one_mod_game() {
        let game = resolve_game(&[], "/tmp/custom.wasm");
        assert_eq!(game.lead_mod(), "/tmp/custom.wasm");
        assert_eq!(game.backdrop, NEUTRAL_BACKDROP);
        assert!(!game.has_clouds());
    }

    #[test]
    fn game_png_next_to_manifest_wins() {
        let root = std::env::temp_dir().join(format!("hanga-tex-{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&root);
        let pack = root.join("urban_chaos");
        std::fs::create_dir_all(&pack).unwrap();
        std::fs::write(pack.join("cloud.png"), b"\x89PNG fake").unwrap();
        let mut game = implicit_game("urban_chaos");
        game.asset_dir = Some(root.clone());
        let found = resolve_game_texture(&game, "cloud.png", &[]).unwrap();
        assert_eq!(found, pack.join("cloud.png"));
        let _ = std::fs::remove_dir_all(&root);
    }

    #[test]
    fn disk_file_overrides_shipped_title() {
        let root = std::env::temp_dir().join(format!("hanga-games-{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&root);
        std::fs::create_dir_all(&root).unwrap();
        std::fs::write(
            root.join("testbed.game"),
            "id=testbed\nmods=testbed\ntitle.en=Override Bed\n",
        )
        .unwrap();
        let catalog = load_game_catalog(&[root.clone()]);
        let bed = catalog.iter().find(|g| g.id == "testbed").unwrap();
        assert_eq!(bed.title("en"), "Override Bed");
        assert!(catalog.iter().any(|g| g.id == "urban_chaos"));
        let _ = std::fs::remove_dir_all(&root);
    }
}
