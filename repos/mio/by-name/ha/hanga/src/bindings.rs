/// Player-editable input map. Engine I/O only — no Bevy types.
///
/// File format (comments and blank lines allowed):
/// ```text
/// move_forward = KeyW
/// place = KeyF, MouseMiddle
/// ```
use std::collections::BTreeMap;

pub const ACTION_FORWARD: &str = "move_forward";
pub const ACTION_BACK: &str = "move_back";
pub const ACTION_LEFT: &str = "move_left";
pub const ACTION_RIGHT: &str = "move_right";
pub const ACTION_JUMP: &str = "jump";
pub const ACTION_BREAK: &str = "break";
pub const ACTION_EXPLODE: &str = "explode";
pub const ACTION_PLACE: &str = "place";
pub const ACTION_ENTER: &str = "enter_vehicle";
pub const ACTION_CRAFT: &str = "craft";
pub const ACTION_ACCEPT: &str = "accept_contract";
pub const ACTION_COMPLETE: &str = "complete_contract";
pub const ACTION_FENCE: &str = "fence";
pub const ACTION_INVENTORY: &str = "inventory";
pub const ACTION_PAUSE: &str = "pause";
pub const ACTION_MENU_PLAY: &str = "menu_play";
pub const ACTION_MENU_MULTI: &str = "menu_multiplayer";
pub const ACTION_MENU_ROOM: &str = "menu_room";
pub const ACTION_MENU_GAME: &str = "menu_game";
pub const ACTION_MENU_LANG: &str = "menu_lang";
pub const ACTION_MENU_CONTROLS: &str = "menu_controls";
pub const ACTION_MENU_QUIT: &str = "menu_quit";

pub const ALL_ACTIONS: &[&str] = &[
    ACTION_FORWARD,
    ACTION_BACK,
    ACTION_LEFT,
    ACTION_RIGHT,
    ACTION_JUMP,
    ACTION_BREAK,
    ACTION_EXPLODE,
    ACTION_PLACE,
    ACTION_ENTER,
    ACTION_CRAFT,
    ACTION_ACCEPT,
    ACTION_COMPLETE,
    ACTION_FENCE,
    ACTION_INVENTORY,
    ACTION_PAUSE,
    "hotbar_1",
    "hotbar_2",
    "hotbar_3",
    "hotbar_4",
    "hotbar_5",
    "hotbar_6",
    "hotbar_7",
    "hotbar_8",
    "hotbar_9",
    ACTION_MENU_PLAY,
    ACTION_MENU_MULTI,
    ACTION_MENU_ROOM,
    ACTION_MENU_GAME,
    ACTION_MENU_LANG,
    ACTION_MENU_CONTROLS,
    ACTION_MENU_QUIT,
];

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct BindingSet {
    map: BTreeMap<String, Vec<String>>,
}

impl Default for BindingSet {
    fn default() -> Self {
        Self::defaults()
    }
}

impl BindingSet {
    pub fn defaults() -> Self {
        let mut map = BTreeMap::new();
        let add = |map: &mut BTreeMap<String, Vec<String>>, action: &str, binds: &[&str]| {
            map.insert(
                action.to_string(),
                binds.iter().map(|s| (*s).to_string()).collect(),
            );
        };
        add(&mut map, ACTION_FORWARD, &["KeyW"]);
        add(&mut map, ACTION_BACK, &["KeyS"]);
        add(&mut map, ACTION_LEFT, &["KeyA"]);
        add(&mut map, ACTION_RIGHT, &["KeyD"]);
        add(&mut map, ACTION_JUMP, &["Space"]);
        add(&mut map, ACTION_BREAK, &["MouseLeft"]);
        add(&mut map, ACTION_EXPLODE, &["MouseRight"]);
        add(&mut map, ACTION_PLACE, &["KeyF", "MouseMiddle"]);
        add(&mut map, ACTION_ENTER, &["KeyE"]);
        add(&mut map, ACTION_CRAFT, &["KeyC"]);
        add(&mut map, ACTION_ACCEPT, &["KeyJ"]);
        add(&mut map, ACTION_COMPLETE, &["KeyK"]);
        add(&mut map, ACTION_FENCE, &["KeyL"]);
        add(&mut map, ACTION_INVENTORY, &["KeyI"]);
        add(&mut map, ACTION_PAUSE, &["Escape"]);
        for i in 1..=9 {
            add(&mut map, &format!("hotbar_{i}"), &[&format!("Digit{i}")]);
        }
        add(&mut map, ACTION_MENU_PLAY, &["Digit1", "Enter"]);
        add(&mut map, ACTION_MENU_MULTI, &["Digit2"]);
        add(&mut map, ACTION_MENU_ROOM, &["KeyR", "Digit7"]);
        add(&mut map, ACTION_MENU_GAME, &["KeyG", "Digit6"]);
        add(&mut map, ACTION_MENU_LANG, &["Digit3"]);
        add(&mut map, ACTION_MENU_CONTROLS, &["Digit4"]);
        add(&mut map, ACTION_MENU_QUIT, &["Digit5", "Escape"]);
        Self { map }
    }

    pub fn binds(&self, action: &str) -> &[String] {
        self.map
            .get(action)
            .map(Vec::as_slice)
            .unwrap_or(&[])
    }

    pub fn display(&self, action: &str) -> String {
        let binds = self.binds(action);
        if binds.is_empty() {
            "—".into()
        } else {
            binds.join(", ")
        }
    }

    /// Short labels for menus (`Digit1` → `1`, `KeyR` → `R`). Config files keep Bevy names.
    pub fn display_pretty(&self, action: &str) -> String {
        let binds = self.binds(action);
        if binds.is_empty() {
            "—".into()
        } else {
            binds.iter().map(|b| pretty_bind(b)).collect::<Vec<_>>().join(" / ")
        }
    }

    pub fn set_bind(&mut self, action: &str, bind: String) {
        if !ALL_ACTIONS.contains(&action) {
            return;
        }
        if let Some(name) = canonical_bind(&bind) {
            self.map.insert(action.to_string(), vec![name]);
        }
    }

    /// Overlay file entries onto defaults. An action present in `other` replaces that row.
    pub fn overlay(&self, other: &BindingSet) -> Self {
        let mut map = self.map.clone();
        for (action, binds) in &other.map {
            if ALL_ACTIONS.contains(&action.as_str()) && !binds.is_empty() {
                map.insert(action.clone(), binds.clone());
            }
        }
        Self { map }
    }
}

/// `--bindings PATH` if present.
pub fn parse_bindings_path(args: &[String]) -> Option<String> {
    args.windows(2)
        .find(|w| w[0] == "--bindings")
        .map(|w| w[1].clone())
}

pub fn parse_bindings(text: &str) -> BindingSet {
    let mut map = BTreeMap::new();
    for raw in text.lines() {
        let line = raw.trim();
        if line.is_empty() || line.starts_with('#') || line.starts_with(';') {
            continue;
        }
        let Some((action, rest)) = line.split_once('=') else {
            continue;
        };
        let action = action.trim();
        if !ALL_ACTIONS.contains(&action) {
            continue;
        }
        let mut binds = Vec::new();
        for part in rest.split(',') {
            if let Some(name) = canonical_bind(part) {
                if !binds.contains(&name) {
                    binds.push(name);
                }
            }
        }
        if !binds.is_empty() {
            map.insert(action.to_string(), binds);
        }
    }
    BindingSet { map }
}

pub fn format_bindings(set: &BindingSet) -> String {
    let mut out = String::from(
        "# Hanga key bindings. Edit this file or use the in-game Controls menu.\n\
         # Names match Bevy (KeyW, Digit1, Space, Escape) or MouseLeft / MouseRight / MouseMiddle.\n\
         # Comma-separate several binds for one action.\n\n",
    );
    for action in ALL_ACTIONS {
        out.push_str(action);
        out.push_str(" = ");
        out.push_str(&set.display(action));
        out.push('\n');
    }
    out
}

pub fn pretty_bind(name: &str) -> String {
    let name = name.trim();
    if let Some(rest) = name.strip_prefix("Digit") {
        return rest.to_string();
    }
    if let Some(rest) = name.strip_prefix("Key") {
        if rest.len() == 1 {
            return rest.to_string();
        }
    }
    match name {
        "Escape" => "Esc".into(),
        "Enter" | "Return" => "Enter".into(),
        "Space" => "Space".into(),
        "ShiftLeft" | "ShiftRight" => "Shift".into(),
        "ControlLeft" | "ControlRight" => "Ctrl".into(),
        "AltLeft" | "AltRight" => "Alt".into(),
        "ArrowUp" => "↑".into(),
        "ArrowDown" => "↓".into(),
        "ArrowLeft" => "←".into(),
        "ArrowRight" => "→".into(),
        "MouseLeft" => "LMB".into(),
        "MouseRight" => "RMB".into(),
        "MouseMiddle" => "MMB".into(),
        other => other.to_string(),
    }
}

pub fn canonical_bind(raw: &str) -> Option<String> {
    let trimmed = raw.trim();
    if trimmed.is_empty() {
        return None;
    }
    let folded = trimmed.replace(['-', ' '], "_").to_ascii_lowercase();
    if let Some(name) = alias_bind(&folded) {
        return Some(name.into());
    }
    if looks_like_bevy_name(trimmed) {
        return Some(trimmed.to_string());
    }
    None
}

fn looks_like_bevy_name(s: &str) -> bool {
    let mut chars = s.chars();
    let Some(first) = chars.next() else {
        return false;
    };
    first.is_ascii_uppercase() && s.chars().all(|c| c.is_ascii_alphanumeric())
}

fn alias_bind(folded: &str) -> Option<&'static str> {
    Some(match folded {
        "w" | "keyw" => "KeyW",
        "a" | "keya" => "KeyA",
        "s" | "keys" => "KeyS",
        "d" | "keyd" => "KeyD",
        "e" | "keye" => "KeyE",
        "f" | "keyf" => "KeyF",
        "g" | "keyg" => "KeyG",
        "c" | "keyc" => "KeyC",
        "j" | "keyj" => "KeyJ",
        "k" | "keyk" => "KeyK",
        "l" | "keyl" => "KeyL",
        "q" | "keyq" => "KeyQ",
        "space" | "spacebar" => "Space",
        "esc" | "escape" => "Escape",
        "enter" | "return" => "Enter",
        "tab" => "Tab",
        "shift" | "shift_left" | "lshift" => "ShiftLeft",
        "ctrl" | "control" | "control_left" => "ControlLeft",
        "alt" | "alt_left" => "AltLeft",
        "up" | "arrowup" => "ArrowUp",
        "down" | "arrowdown" => "ArrowDown",
        "left" | "arrowleft" => "ArrowLeft",
        "right" | "arrowright" => "ArrowRight",
        "mouseleft" | "mouse_left" | "lmb" | "mouse1" => "MouseLeft",
        "mouseright" | "mouse_right" | "rmb" | "mouse2" => "MouseRight",
        "mousemiddle" | "mouse_middle" | "mmb" | "mouse3" => "MouseMiddle",
        "mouseback" | "mouse_back" => "MouseBack",
        "mouseforward" | "mouse_forward" => "MouseForward",
        "1" | "digit1" | "num1" => "Digit1",
        "2" | "digit2" | "num2" => "Digit2",
        "3" | "digit3" | "num3" => "Digit3",
        "4" | "digit4" | "num4" => "Digit4",
        "5" | "digit5" | "num5" => "Digit5",
        "6" | "digit6" | "num6" => "Digit6",
        "7" | "digit7" | "num7" => "Digit7",
        "8" | "digit8" | "num8" => "Digit8",
        "9" | "digit9" | "num9" => "Digit9",
        "0" | "digit0" | "num0" => "Digit0",
        _ => return None,
    })
}

pub fn hotbar_action(slot: usize) -> Option<&'static str> {
    match slot {
        0 => Some("hotbar_1"),
        1 => Some("hotbar_2"),
        2 => Some("hotbar_3"),
        3 => Some("hotbar_4"),
        4 => Some("hotbar_5"),
        5 => Some("hotbar_6"),
        6 => Some("hotbar_7"),
        7 => Some("hotbar_8"),
        8 => Some("hotbar_9"),
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn defaults_cover_every_action() {
        let set = BindingSet::defaults();
        for action in ALL_ACTIONS {
            assert!(!set.binds(action).is_empty(), "{action}");
        }
    }

    #[test]
    fn aliases_and_bevy_names_parse() {
        assert_eq!(canonical_bind("w"), Some("KeyW".into()));
        assert_eq!(canonical_bind("MouseLeft"), Some("MouseLeft".into()));
        assert_eq!(canonical_bind("lmb"), Some("MouseLeft".into()));
        assert_eq!(canonical_bind("esc"), Some("Escape".into()));
        assert_eq!(canonical_bind("Digit3"), Some("Digit3".into()));
        assert_eq!(canonical_bind("not-a-key"), None);
    }

    #[test]
    fn pretty_bind_hides_bevy_prefixes() {
        assert_eq!(pretty_bind("Digit1"), "1");
        assert_eq!(pretty_bind("KeyR"), "R");
        assert_eq!(pretty_bind("Escape"), "Esc");
        assert_eq!(pretty_bind("MouseLeft"), "LMB");
        let set = BindingSet::defaults();
        assert_eq!(set.display_pretty(ACTION_MENU_PLAY), "1 / Enter");
        assert_eq!(set.display(ACTION_MENU_PLAY), "Digit1, Enter");
    }

    #[test]
    fn file_overlays_one_action() {
        let base = BindingSet::defaults();
        let file = parse_bindings("# comment\nmove_forward = KeyI\nplace = e, MouseMiddle\n");
        let merged = base.overlay(&file);
        assert_eq!(merged.binds(ACTION_FORWARD), &["KeyI".to_string()]);
        assert_eq!(
            merged.binds(ACTION_PLACE),
            &["KeyE".to_string(), "MouseMiddle".to_string()]
        );
        assert_eq!(merged.binds(ACTION_JUMP), &["Space".to_string()]);
    }

    #[test]
    fn format_roundtrip_keeps_defaults() {
        let original = BindingSet::defaults();
        let again = original.overlay(&parse_bindings(&format_bindings(&original)));
        assert_eq!(original, again);
    }

    #[test]
    fn set_bind_replaces_the_row() {
        let mut set = BindingSet::defaults();
        set.set_bind(ACTION_FORWARD, "ArrowUp".into());
        assert_eq!(set.binds(ACTION_FORWARD), &["ArrowUp".to_string()]);
        set.set_bind("nope", "KeyW".into());
        assert!(set.binds("nope").is_empty());
    }

    #[test]
    fn bindings_flag_reads_path() {
        assert_eq!(parse_bindings_path(&["hanga".into()]), None);
        assert_eq!(
            parse_bindings_path(&["hanga".into(), "--bindings".into(), "/tmp/b.conf".into()]),
            Some("/tmp/b.conf".into())
        );
    }
}
