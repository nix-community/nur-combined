/// Player-facing locale. Engine I/O only — mods still return English keys.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
pub enum Locale {
    #[default]
    English,
    Maori,
    French,
    TaiwanChinese,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum TextCommand {
    MoveForward,
    BreakBlock,
    PlaceBlock,
    EnterVehicle,
    Look,
    AcceptJob,
    CompleteJob,
    Fence,
    Craft,
    SetLang(Locale),
    Unknown,
}

impl Locale {
    pub fn code(self) -> &'static str {
        match self {
            Locale::English => "en",
            Locale::Maori => "mi",
            Locale::French => "fr",
            Locale::TaiwanChinese => "zh-TW",
        }
    }

    pub fn native_name(self) -> &'static str {
        match self {
            Locale::English => "English",
            Locale::Maori => "te reo Māori",
            Locale::French => "français",
            Locale::TaiwanChinese => "台灣中文",
        }
    }

    pub fn parse(input: &str) -> Option<Self> {
        let raw = input.trim();
        let no_dot = raw.split('.').next().unwrap_or(raw);
        let folded = no_dot.replace('_', "-").to_lowercase();
        let primary = folded.split('-').next().unwrap_or(&folded);
        match folded.as_str() {
            "en" | "eng" | "english" | "en-us" | "en-gb" | "en-nz" | "en-au" => Some(Locale::English),
            "mi" | "mao" | "mri" | "maori" | "māori" | "te-reo" | "te reo" | "mi-nz" => {
                Some(Locale::Maori)
            }
            "fr" | "fra" | "fre" | "french" | "francais" | "français" | "fr-fr" | "fr-ca"
            | "fr-be" => Some(Locale::French),
            "zh-tw" | "zh-hant" | "zh-hant-tw" | "zh-taiwan" | "taiwan" | "taiwanese"
            | "tw" => Some(Locale::TaiwanChinese),
            _ => match primary {
                "en" => Some(Locale::English),
                "mi" | "mao" | "mri" => Some(Locale::Maori),
                "fr" => Some(Locale::French),
                "zh" => Some(Locale::TaiwanChinese),
                _ => None,
            },
        }
    }

    pub fn next(self) -> Self {
        match self {
            Locale::English => Locale::Maori,
            Locale::Maori => Locale::French,
            Locale::French => Locale::TaiwanChinese,
            Locale::TaiwanChinese => Locale::English,
        }
    }

    pub fn from_env_and_args(args: &[String]) -> Self {
        if let Some(pair) = args.windows(2).find(|w| w[0] == "--lang" || w[0] == "--locale") {
            if let Some(locale) = Self::parse(&pair[1]) {
                return locale;
            }
        }
        for var in ["HANGA_LANG", "LANG"] {
            if let Ok(value) = std::env::var(var) {
                if let Some(locale) = Self::parse(&value) {
                    return locale;
                }
            }
        }
        Locale::English
    }

    pub fn all() -> [Locale; 4] {
        [
            Locale::English,
            Locale::Maori,
            Locale::French,
            Locale::TaiwanChinese,
        ]
    }
}

#[cfg(test)]
const UI_KEYS: &[&str] = &[
    "sys_prefix",
    "moving",
    "breaking",
    "placing",
    "entering",
    "no_vehicle",
    "accepting",
    "completing",
    "fencing",
    "crafting",
    "no_recipe",
    "unknown",
    "lang_set",
    "status",
    "job_active",
    "job_offer",
    "job_offer_bind",
    "job_none",
    "look",
    "commands_help",
    "menu_title",
    "menu_play",
    "menu_multiplayer",
    "menu_room",
    "menu_game",
    "menu_lang",
    "menu_controls",
    "menu_quit",
    "menu_hint",
    "play_hint",
    "p2p_off",
    "p2p_room_off",
    "p2p_wait",
    "p2p_live",
    "p2p_dead",
    "held",
    "hands_empty",
    "empty_slot",
    "hud_hotbar",
    "controls_title",
    "controls_hint",
    "controls_waiting",
    "controls_back",
    "bind_move_forward",
    "bind_move_back",
    "bind_move_left",
    "bind_move_right",
    "bind_jump",
    "bind_break",
    "bind_explode",
    "bind_place",
    "bind_enter_vehicle",
    "bind_craft",
    "bind_accept_contract",
    "bind_complete_contract",
    "bind_fence",
    "bind_inventory",
    "bind_pause",
    "bind_hotbar_1",
    "bind_hotbar_2",
    "bind_hotbar_3",
    "bind_hotbar_4",
    "bind_hotbar_5",
    "bind_hotbar_6",
    "bind_hotbar_7",
    "bind_hotbar_8",
    "bind_hotbar_9",
    "bind_menu_play",
    "bind_menu_multiplayer",
    "bind_menu_room",
    "bind_menu_game",
    "bind_menu_lang",
    "bind_menu_controls",
    "bind_menu_quit",
];

fn ui_en(key: &str) -> Option<&'static str> {
    Some(match key {
        "sys_prefix" => "System: ",
        "moving" => "Moving forward.",
        "breaking" => "Attempting to break block at {pos}",
        "placing" => "Attempting to place block at {pos}",
        "entering" => "Attempting to hijack vehicle!",
        "no_vehicle" => "No vehicle nearby.",
        "accepting" => "Accepting the offered job.",
        "completing" => "Cashing out the job.",
        "fencing" => "Fencing loot at the city market.",
        "crafting" => "Crafting {a} + {b} -> {out}.",
        "no_recipe" => "No recipe for those items.",
        "unknown" => "Unknown command '{cmd}'.",
        "lang_set" => "Language set to {name} ({code}).",
        "status" => "Wanted {wanted}. Credits {credits}. {job}. {held}",
        "job_active" => "active job: {name} (${payout}, danger {danger})",
        "job_offer" => "offer: {name} (${payout}, danger {danger}). Type '{accept}'.",
        "job_offer_bind" => "offer: {name} (${payout}, danger {danger}). {accept} to take it.",
        "job_none" => "no job",
        "look" => "{status}. Ahead is {label} at {pos}. Commands: {commands}.",
        "commands_help" => "move forward, break block, place block, craft, accept job, complete job, fence, lang",
        "menu_title" => "HANGA",
        "menu_play" => "Play",
        "menu_multiplayer" => "Multiplayer",
        "menu_room" => "Room",
        "menu_game" => "Game",
        "menu_lang" => "Language",
        "menu_controls" => "Controls",
        "menu_quit" => "Quit",
        "menu_hint" => "Click a row, or use the keys shown",
        "play_hint" => "Mouse look  |  I inventory  |  see Controls  |  Esc pause",
        "p2p_off" => "Single-player",
        "p2p_room_off" => "off",
        "p2p_wait" => "Room {room}: waiting for peers (hanga-signal)",
        "p2p_live" => "Room {room}: {n} peer(s)",
        "p2p_dead" => "Room {room}: dropped — Multiplayer to reconnect",
        "held" => "holding {label} x{count}",
        "hands_empty" => "hands empty",
        "empty_slot" => "Hotbar slot is empty.",
        "hud_hotbar" => "{slots}",
        "controls_title" => "CONTROLS",
        "controls_hint" => "Click a row, then press a key or mouse button. File is written on change.",
        "controls_waiting" => "Press a key or mouse button for {action}...",
        "controls_back" => "Back",
        "bind_move_forward" => "Move forward",
        "bind_move_back" => "Move back",
        "bind_move_left" => "Move left",
        "bind_move_right" => "Move right",
        "bind_jump" => "Jump",
        "bind_break" => "Break block",
        "bind_explode" => "Explode",
        "bind_place" => "Place block",
        "bind_enter_vehicle" => "Enter vehicle",
        "bind_craft" => "Craft",
        "bind_accept_contract" => "Accept job",
        "bind_complete_contract" => "Complete job",
        "bind_fence" => "Fence loot",
        "bind_inventory" => "Inventory",
        "bind_pause" => "Pause / menu",
        "bind_hotbar_1" => "Hotbar 1",
        "bind_hotbar_2" => "Hotbar 2",
        "bind_hotbar_3" => "Hotbar 3",
        "bind_hotbar_4" => "Hotbar 4",
        "bind_hotbar_5" => "Hotbar 5",
        "bind_hotbar_6" => "Hotbar 6",
        "bind_hotbar_7" => "Hotbar 7",
        "bind_hotbar_8" => "Hotbar 8",
        "bind_hotbar_9" => "Hotbar 9",
        "bind_menu_play" => "Menu: Play",
        "bind_menu_multiplayer" => "Menu: Multiplayer",
        "bind_menu_room" => "Menu: Room",
        "bind_menu_game" => "Menu: Game",
        "bind_menu_lang" => "Menu: Language",
        "bind_menu_controls" => "Menu: Controls",
        "bind_menu_quit" => "Menu: Quit",
        _ => return None,
    })
}

fn ui_mi(key: &str) -> Option<&'static str> {
    Some(match key {
        "sys_prefix" => "Pūnaha: ",
        "moving" => "E neke whakamua ana.",
        "breaking" => "E ngana ana ki te whati poraka kei {pos}",
        "placing" => "E ngana ana ki te whakatū poraka kei {pos}",
        "entering" => "E ngana ana ki te eke waka!",
        "no_vehicle" => "Kāore he waka tata.",
        "accepting" => "E whakaae ana i te mahi kua tukuna.",
        "completing" => "E tango moni ana mō te mahi.",
        "fencing" => "E hoko ana i ngā taonga ki te mākete.",
        "crafting" => "E waihanga ana {a} + {b} -> {out}.",
        "no_recipe" => "Kāore he tohutao mō aua taonga.",
        "unknown" => "Whakahau tē mōhiotia '{cmd}'.",
        "lang_set" => "Kua tautuhia te reo ki {name} ({code}).",
        "status" => "Taumata hiahiatia {wanted}. Moni {credits}. {job}. {held}",
        "job_active" => "mahi kaha: {name} (${payout}, mōrearea {danger})",
        "job_offer" => "tuku mahi: {name} (${payout}, mōrearea {danger}). Patohia '{accept}'.",
        "job_offer_bind" => "tuku mahi: {name} (${payout}, mōrearea {danger}). {accept} hei tango.",
        "job_none" => "kāore he mahi",
        "look" => "{status}. Kei mua ko {label} kei {pos}. Ngā whakahau: {commands}.",
        "commands_help" => "neke whakamua, whati poraka, whakatū poraka, waihanga, whakaae mahi, whakaoti mahi, hoko taonga, reo",
        "menu_title" => "HANGA",
        "menu_play" => "Tākaro",
        "menu_multiplayer" => "Tuki tāngata-maha",
        "menu_room" => "Rūma",
        "menu_game" => "Kēmu",
        "menu_lang" => "Reo",
        "menu_controls" => "Whakatika pātene",
        "menu_quit" => "Puta",
        "menu_hint" => "Pāwhiria tētahi rārangi, kāore rānei ngā pātene",
        "play_hint" => "Kiore titiro  |  I pūkoro  |  tirohia ngā pātene  |  Esc okioki taunoa",
        "p2p_off" => "Takitahi",
        "p2p_room_off" => "weto",
        "p2p_wait" => "Rūma {room}: e tatari hoa (hanga-signal)",
        "p2p_live" => "Rūma {room}: {n} hoa",
        "p2p_dead" => "Rūma {room}: kua motu — Tuki tāngata-maha hei hono anō",
        "held" => "e mau ana {label} x{count}",
        "hands_empty" => "kua takoto ngā ringa",
        "empty_slot" => "Kua wātea te kōwae pae-wera.",
        "hud_hotbar" => "{slots}",
        "controls_title" => "PĀTENE",
        "controls_hint" => "Pāwhiria tētahi rārangi, kātahi patohia tētahi pātene. Ka tuhi te kōnae.",
        "controls_waiting" => "Patohia tētahi pātene mō {action}...",
        "controls_back" => "Hoki",
        "bind_move_forward" => "Neke whakamua",
        "bind_move_back" => "Neke whakamuri",
        "bind_move_left" => "Neke maui",
        "bind_move_right" => "Neke matau",
        "bind_jump" => "Peke",
        "bind_break" => "Whati poraka",
        "bind_explode" => "Pāhu",
        "bind_place" => "Whakatū poraka",
        "bind_enter_vehicle" => "Eke waka",
        "bind_craft" => "Waihanga",
        "bind_accept_contract" => "Whakaae mahi",
        "bind_complete_contract" => "Whakaoti mahi",
        "bind_fence" => "Hoko taonga",
        "bind_inventory" => "Pūkoro",
        "bind_pause" => "Okioki / tahua",
        "bind_hotbar_1" => "Pae-wera 1",
        "bind_hotbar_2" => "Pae-wera 2",
        "bind_hotbar_3" => "Pae-wera 3",
        "bind_hotbar_4" => "Pae-wera 4",
        "bind_hotbar_5" => "Pae-wera 5",
        "bind_hotbar_6" => "Pae-wera 6",
        "bind_hotbar_7" => "Pae-wera 7",
        "bind_hotbar_8" => "Pae-wera 8",
        "bind_hotbar_9" => "Pae-wera 9",
        "bind_menu_play" => "Tahua: Tākaro",
        "bind_menu_multiplayer" => "Tahua: Tuki tāngata-maha",
        "bind_menu_room" => "Tahua: Rūma",
        "bind_menu_game" => "Tahua: Kēmu",
        "bind_menu_lang" => "Tahua: Reo",
        "bind_menu_controls" => "Tahua: Pātene",
        "bind_menu_quit" => "Tahua: Puta",
        _ => return None,
    })
}

fn ui_fr(key: &str) -> Option<&'static str> {
    Some(match key {
        "sys_prefix" => "Système : ",
        "moving" => "Avance.",
        "breaking" => "Tentative de casser le bloc en {pos}",
        "placing" => "Tentative de poser un bloc en {pos}",
        "entering" => "Tentative de voler un véhicule !",
        "no_vehicle" => "Aucun véhicule à proximité.",
        "accepting" => "Acceptation du contrat proposé.",
        "completing" => "Encaissement du contrat.",
        "fencing" => "Revente du butin au marché.",
        "crafting" => "Fabrication {a} + {b} -> {out}.",
        "no_recipe" => "Aucune recette pour ces objets.",
        "unknown" => "Commande inconnue « {cmd} ».",
        "lang_set" => "Langue définie : {name} ({code}).",
        "status" => "Recherché {wanted}. Crédits {credits}. {job}. {held}",
        "job_active" => "contrat actif : {name} ({payout} $, danger {danger})",
        "job_offer" => "offre : {name} ({payout} $, danger {danger}). Tapez « {accept} ».",
        "job_offer_bind" => "offre : {name} ({payout} $, danger {danger}). {accept} pour accepter.",
        "job_none" => "aucun contrat",
        "look" => "{status}. Devant : {label} en {pos}. Commandes : {commands}.",
        "commands_help" => "avancer, casser un bloc, poser un bloc, fabriquer, accepter le contrat, terminer le contrat, revendre, langue",
        "menu_title" => "HANGA",
        "menu_play" => "Jouer",
        "menu_multiplayer" => "Multijoueur",
        "menu_room" => "Salle",
        "menu_game" => "Jeu",
        "menu_lang" => "Langue",
        "menu_controls" => "Commandes",
        "menu_quit" => "Quitter",
        "menu_hint" => "Cliquez une ligne, ou utilisez les touches indiquées",
        "play_hint" => "Souris  |  I inventaire  |  voir Commandes  |  Échap pause par défaut",
        "p2p_off" => "Solo",
        "p2p_room_off" => "off",
        "p2p_wait" => "Salle {room} : en attente (hanga-signal)",
        "p2p_live" => "Salle {room} : {n} pair(s)",
        "p2p_dead" => "Salle {room} : coupé — Multijoueur pour reconnecter",
        "held" => "tient {label} x{count}",
        "hands_empty" => "mains vides",
        "empty_slot" => "L’emplacement de la barre est vide.",
        "hud_hotbar" => "{slots}",
        "controls_title" => "COMMANDES",
        "controls_hint" => "Cliquez une ligne, puis appuyez sur une touche. Le fichier est enregistré.",
        "controls_waiting" => "Appuyez sur une touche pour {action}...",
        "controls_back" => "Retour",
        "bind_move_forward" => "Avancer",
        "bind_move_back" => "Reculer",
        "bind_move_left" => "Gauche",
        "bind_move_right" => "Droite",
        "bind_jump" => "Sauter",
        "bind_break" => "Casser",
        "bind_explode" => "Explosion",
        "bind_place" => "Poser",
        "bind_enter_vehicle" => "Véhicule",
        "bind_craft" => "Fabriquer",
        "bind_accept_contract" => "Accepter le contrat",
        "bind_complete_contract" => "Terminer le contrat",
        "bind_fence" => "Revendre",
        "bind_inventory" => "Inventaire",
        "bind_pause" => "Pause / menu",
        "bind_hotbar_1" => "Barre 1",
        "bind_hotbar_2" => "Barre 2",
        "bind_hotbar_3" => "Barre 3",
        "bind_hotbar_4" => "Barre 4",
        "bind_hotbar_5" => "Barre 5",
        "bind_hotbar_6" => "Barre 6",
        "bind_hotbar_7" => "Barre 7",
        "bind_hotbar_8" => "Barre 8",
        "bind_hotbar_9" => "Barre 9",
        "bind_menu_play" => "Menu : Jouer",
        "bind_menu_multiplayer" => "Menu : Multijoueur",
        "bind_menu_room" => "Menu : Salle",
        "bind_menu_game" => "Menu : Jeu",
        "bind_menu_lang" => "Menu : Langue",
        "bind_menu_controls" => "Menu : Commandes",
        "bind_menu_quit" => "Menu : Quitter",
        _ => return None,
    })
}

fn ui_zh_tw(key: &str) -> Option<&'static str> {
    Some(match key {
        "sys_prefix" => "系統：",
        "moving" => "正在前進。",
        "breaking" => "正在嘗試破壞 {pos} 的方塊",
        "placing" => "正在嘗試在 {pos} 放置方塊",
        "entering" => "正在嘗試搶車！",
        "no_vehicle" => "附近沒有載具。",
        "accepting" => "正在接受委託任務。",
        "completing" => "正在結算任務酬勞。",
        "fencing" => "正在市集銷贓。",
        "crafting" => "正在合成 {a} + {b} -> {out}。",
        "no_recipe" => "這些物品沒有配方。",
        "unknown" => "未知指令「{cmd}」。",
        "lang_set" => "語言已設為{name}（{code}）。",
        "status" => "通緝 {wanted}。信用點 {credits}。{job}。{held}",
        "job_active" => "進行中任務：{name}（${payout}，危險 {danger}）",
        "job_offer" => "可接任務：{name}（${payout}，危險 {danger}）。輸入「{accept}」。",
        "job_offer_bind" => "可接任務：{name}（${payout}，危險 {danger}）。按 {accept} 接受。",
        "job_none" => "沒有任務",
        "look" => "{status}。前方是{label}，位置 {pos}。指令：{commands}。",
        "commands_help" => "前進、破壞方塊、放置方塊、合成、接受任務、完成任務、銷贓、語言",
        "menu_title" => "HANGA",
        "menu_play" => "開始遊戲",
        "menu_multiplayer" => "多人連線",
        "menu_room" => "房間",
        "menu_game" => "遊戲",
        "menu_lang" => "語言",
        "menu_controls" => "按鍵設定",
        "menu_quit" => "離開",
        "menu_hint" => "點選一列，或使用畫面上的按鍵",
        "play_hint" => "滑鼠視角  |  I 物品欄  |  見按鍵設定  |  預設 Esc 暫停",
        "p2p_off" => "單人",
        "p2p_room_off" => "關閉",
        "p2p_wait" => "房間 {room}：等待玩家（hanga-signal）",
        "p2p_live" => "房間 {room}：{n} 位玩家",
        "p2p_dead" => "房間 {room}：已斷線 — 按多人連線重連",
        "held" => "手持 {label} x{count}",
        "hands_empty" => "兩手空空",
        "empty_slot" => "快捷欄是空的。",
        "hud_hotbar" => "{slots}",
        "controls_title" => "按鍵",
        "controls_hint" => "點一列，再按鍵盤或滑鼠。變更會寫入檔案。",
        "controls_waiting" => "請為{action}按下按鍵...",
        "controls_back" => "返回",
        "bind_move_forward" => "前進",
        "bind_move_back" => "後退",
        "bind_move_left" => "左移",
        "bind_move_right" => "右移",
        "bind_jump" => "跳躍",
        "bind_break" => "破壞",
        "bind_explode" => "爆炸",
        "bind_place" => "放置",
        "bind_enter_vehicle" => "上車",
        "bind_craft" => "合成",
        "bind_accept_contract" => "接受任務",
        "bind_complete_contract" => "完成任務",
        "bind_fence" => "銷贓",
        "bind_inventory" => "物品欄",
        "bind_pause" => "暫停／選單",
        "bind_hotbar_1" => "快捷欄 1",
        "bind_hotbar_2" => "快捷欄 2",
        "bind_hotbar_3" => "快捷欄 3",
        "bind_hotbar_4" => "快捷欄 4",
        "bind_hotbar_5" => "快捷欄 5",
        "bind_hotbar_6" => "快捷欄 6",
        "bind_hotbar_7" => "快捷欄 7",
        "bind_hotbar_8" => "快捷欄 8",
        "bind_hotbar_9" => "快捷欄 9",
        "bind_menu_play" => "選單：開始",
        "bind_menu_multiplayer" => "選單：多人",
        "bind_menu_room" => "選單：房間",
        "bind_menu_game" => "選單：遊戲",
        "bind_menu_lang" => "選單：語言",
        "bind_menu_controls" => "選單：按鍵",
        "bind_menu_quit" => "選單：離開",
        _ => return None,
    })
}

fn ui_lookup(locale: Locale, key: &str) -> Option<&'static str> {
    match locale {
        Locale::English => ui_en(key),
        Locale::Maori => ui_mi(key),
        Locale::French => ui_fr(key),
        Locale::TaiwanChinese => ui_zh_tw(key),
    }
}

/// Translate a UI catalog key. Falls back to English, then the key itself.
pub fn t(locale: Locale, key: &str) -> &'static str {
    ui_lookup(locale, key)
        .or_else(|| ui_en(key))
        .unwrap_or("")
}

fn fill(template: &str, pairs: &[(&str, &str)]) -> String {
    let mut out = template.to_string();
    for (name, value) in pairs {
        out = out.replace(&format!("{{{name}}}"), value);
    }
    out
}

pub fn say(locale: Locale, body: &str) -> String {
    format!("{}{body}", t(locale, "sys_prefix"))
}

pub fn accept_job_cmd(locale: Locale) -> &'static str {
    match locale {
        Locale::English => "accept job",
        Locale::Maori => "whakaae mahi",
        Locale::French => "accepter le contrat",
        Locale::TaiwanChinese => "接受任務",
    }
}

pub fn format_crafting(locale: Locale, a: &str, b: &str, out: &str) -> String {
    fill(
        t(locale, "crafting"),
        &[("a", a), ("b", b), ("out", out)],
    )
}

pub fn format_held(locale: Locale, label: &str, count: u32) -> String {
    if label.is_empty() || count == 0 {
        return t(locale, "hands_empty").to_string();
    }
    fill(
        t(locale, "held"),
        &[("label", label), ("count", &count.to_string())],
    )
}

pub fn format_hotbar(locale: Locale, slots: &str) -> String {
    fill(t(locale, "hud_hotbar"), &[("slots", slots)])
}

pub fn format_status(locale: Locale, wanted: u32, credits: i32, job: &str, held: &str) -> String {
    fill(
        t(locale, "status"),
        &[
            ("wanted", &wanted.to_string()),
            ("credits", &credits.to_string()),
            ("job", job),
            ("held", held),
        ],
    )
}

pub fn format_job_active(locale: Locale, name: &str, payout: i32, danger: i32) -> String {
    fill(
        t(locale, "job_active"),
        &[
            ("name", name),
            ("payout", &payout.to_string()),
            ("danger", &danger.to_string()),
        ],
    )
}

pub fn format_job_offer(locale: Locale, name: &str, payout: i32, danger: i32) -> String {
    fill(
        t(locale, "job_offer"),
        &[
            ("name", name),
            ("payout", &payout.to_string()),
            ("danger", &danger.to_string()),
            ("accept", accept_job_cmd(locale)),
        ],
    )
}

pub fn format_job_offer_bind(
    locale: Locale,
    name: &str,
    payout: i32,
    danger: i32,
    accept: &str,
) -> String {
    fill(
        t(locale, "job_offer_bind"),
        &[
            ("name", name),
            ("payout", &payout.to_string()),
            ("danger", &danger.to_string()),
            ("accept", accept),
        ],
    )
}

pub fn format_p2p(locale: Locale, room: Option<&str>, peers: usize, dead: bool) -> String {
    match room {
        None => t(locale, "p2p_off").to_string(),
        Some(room) if dead => fill(t(locale, "p2p_dead"), &[("room", room)]),
        Some(room) if peers > 0 => fill(
            t(locale, "p2p_live"),
            &[("room", room), ("n", &peers.to_string())],
        ),
        Some(room) => fill(t(locale, "p2p_wait"), &[("room", room)]),
    }
}

pub fn format_look(locale: Locale, status: &str, label: &str, pos: &str) -> String {
    fill(
        t(locale, "look"),
        &[
            ("status", status),
            ("label", label),
            ("pos", pos),
            ("commands", t(locale, "commands_help")),
        ],
    )
}

pub fn format_lang_set(locale: Locale) -> String {
    fill(
        t(locale, "lang_set"),
        &[("name", locale.native_name()), ("code", locale.code())],
    )
}

/// Longest-prefix first. English plus every shipped locale so scripts keep working.
const COMMAND_ALIASES: &[(TextCommand, &[&str])] = &[
    (
        TextCommand::MoveForward,
        &["move forward", "neke whakamua", "avancer", "前進"],
    ),
    (
        TextCommand::BreakBlock,
        &[
            "break block",
            "whati poraka",
            "casser un bloc",
            "casser bloc",
            "破壞方塊",
        ],
    ),
    (
        TextCommand::PlaceBlock,
        &[
            "place block",
            "whakatū poraka",
            "poser un bloc",
            "poser bloc",
            "放置方塊",
        ],
    ),
    (
        TextCommand::EnterVehicle,
        &[
            "enter vehicle",
            "eke waka",
            "entrer dans un véhicule",
            "entrer vehicule",
            "進入載具",
        ],
    ),
    (
        TextCommand::AcceptJob,
        &[
            "accept contract",
            "accept job",
            "whakaae mahi",
            "accepter le contrat",
            "accepter contrat",
            "接受任務",
        ],
    ),
    (
        TextCommand::CompleteJob,
        &[
            "complete contract",
            "complete job",
            "whakaoti mahi",
            "terminer le contrat",
            "terminer contrat",
            "完成任務",
        ],
    ),
    (
        TextCommand::Fence,
        &["sell loot", "fence", "hoko taonga", "revendre", "銷贓"],
    ),
    (
        TextCommand::Craft,
        &["craft", "waihanga", "fabriquer", "合成"],
    ),
    (
        TextCommand::Look,
        &["look", "status", "titiro", "tūnga", "regarder", "statut", "查看", "狀態"],
    ),
];

fn strip_lang_prefix(folded: &str) -> Option<&str> {
    for prefix in ["lang ", "locale ", "reo ", "langue ", "語言 ", "語言"] {
        if let Some(rest) = folded.strip_prefix(prefix) {
            let rest = rest.trim();
            if !rest.is_empty() {
                return Some(rest);
            }
        }
    }
    None
}

pub fn parse_text_command(line: &str) -> TextCommand {
    let folded = line.trim().to_lowercase();
    if folded.is_empty() {
        return TextCommand::Unknown;
    }
    if let Some(code) = strip_lang_prefix(&folded) {
        return Locale::parse(code)
            .map(TextCommand::SetLang)
            .unwrap_or(TextCommand::Unknown);
    }
    for (command, aliases) in COMMAND_ALIASES {
        for alias in *aliases {
            if folded == *alias || folded.starts_with(&format!("{alias} ")) {
                return *command;
            }
        }
    }
    TextCommand::Unknown
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_english_aliases() {
        assert_eq!(Locale::parse("en"), Some(Locale::English));
        assert_eq!(Locale::parse("en_NZ.UTF-8"), Some(Locale::English));
        assert_eq!(Locale::parse("english"), Some(Locale::English));
    }

    #[test]
    fn parse_maori_aliases() {
        assert_eq!(Locale::parse("mi"), Some(Locale::Maori));
        assert_eq!(Locale::parse("Māori"), Some(Locale::Maori));
        assert_eq!(Locale::parse("maori"), Some(Locale::Maori));
        assert_eq!(Locale::parse("mi_NZ.UTF-8"), Some(Locale::Maori));
    }

    #[test]
    fn parse_french_aliases() {
        assert_eq!(Locale::parse("fr"), Some(Locale::French));
        assert_eq!(Locale::parse("fr_FR.UTF-8"), Some(Locale::French));
        assert_eq!(Locale::parse("Français"), Some(Locale::French));
    }

    #[test]
    fn parse_taiwan_chinese_aliases() {
        assert_eq!(Locale::parse("zh-TW"), Some(Locale::TaiwanChinese));
        assert_eq!(Locale::parse("zh_TW.UTF-8"), Some(Locale::TaiwanChinese));
        assert_eq!(Locale::parse("zh-Hant"), Some(Locale::TaiwanChinese));
        assert_eq!(Locale::parse("taiwan"), Some(Locale::TaiwanChinese));
        assert_eq!(Locale::parse("zh"), Some(Locale::TaiwanChinese));
    }

    #[test]
    fn unknown_locale_is_none() {
        assert_eq!(Locale::parse("de"), None);
        assert_eq!(Locale::parse(""), None);
    }

    #[test]
    fn locale_cycles_through_shipped_languages() {
        assert_eq!(Locale::English.next(), Locale::Maori);
        assert_eq!(Locale::TaiwanChinese.next(), Locale::English);
        assert_ne!(t(Locale::French, "menu_play"), t(Locale::English, "menu_play"));
        assert_eq!(t(Locale::Maori, "menu_play"), "Tākaro");
        assert_eq!(t(Locale::English, "menu_controls"), "Controls");
    }

    #[test]
    fn every_locale_has_every_ui_key() {
        for locale in Locale::all() {
            for key in UI_KEYS {
                let text = ui_lookup(locale, key).expect(key);
                assert!(!text.is_empty(), "{locale:?} {key} empty");
            }
        }
    }

    #[test]
    fn non_english_ui_differs_from_english() {
        for locale in [Locale::Maori, Locale::French, Locale::TaiwanChinese] {
            assert_ne!(t(locale, "moving"), t(Locale::English, "moving"));
            assert_ne!(t(locale, "job_none"), t(Locale::English, "job_none"));
            assert_ne!(t(locale, "sys_prefix"), t(Locale::English, "sys_prefix"));
        }
    }

    #[test]
    fn p2p_status_covers_off_wait_live_and_dead() {
        assert_eq!(format_p2p(Locale::English, None, 0, false), "Single-player");
        let wait = format_p2p(Locale::English, Some("hanga_room"), 0, false);
        assert!(wait.contains("hanga_room"));
        assert!(wait.contains("waiting"));
        let live = format_p2p(Locale::French, Some("hanga_heist"), 2, false);
        assert!(live.contains("hanga_heist"));
        assert!(live.contains('2'));
        let dead = format_p2p(Locale::TaiwanChinese, Some("hanga_test"), 0, true);
        assert!(dead.contains("hanga_test"));
        assert!(dead.contains("斷線"));
    }

    #[test]
    fn job_offer_bind_uses_the_key_not_a_typed_command() {
        let line = format_job_offer_bind(Locale::English, "smash-and-grab", 400, 1, "KeyJ");
        assert!(line.contains("KeyJ"));
        assert!(line.contains("smash-and-grab"));
        assert!(!line.contains("Type"));
    }

    #[test]
    fn english_and_localized_commands_parse() {
        assert_eq!(parse_text_command("move forward"), TextCommand::MoveForward);
        assert_eq!(parse_text_command("neke whakamua"), TextCommand::MoveForward);
        assert_eq!(parse_text_command("avancer"), TextCommand::MoveForward);
        assert_eq!(parse_text_command("前進"), TextCommand::MoveForward);
        assert_eq!(parse_text_command("Casser un bloc"), TextCommand::BreakBlock);
        assert_eq!(parse_text_command("破壞方塊"), TextCommand::BreakBlock);
        assert_eq!(parse_text_command("whakaae mahi"), TextCommand::AcceptJob);
        assert_eq!(parse_text_command("接受任務"), TextCommand::AcceptJob);
        assert_eq!(parse_text_command("銷贓"), TextCommand::Fence);
        assert_eq!(parse_text_command("craft"), TextCommand::Craft);
        assert_eq!(parse_text_command("合成"), TextCommand::Craft);
        assert_eq!(parse_text_command("titiro"), TextCommand::Look);
        assert_eq!(parse_text_command("狀態"), TextCommand::Look);
        assert_eq!(
            parse_text_command("lang mi"),
            TextCommand::SetLang(Locale::Maori)
        );
        assert_eq!(
            parse_text_command("語言 zh-TW"),
            TextCommand::SetLang(Locale::TaiwanChinese)
        );
        assert_eq!(
            parse_text_command("langue fr"),
            TextCommand::SetLang(Locale::French)
        );
        assert_eq!(parse_text_command("blorp"), TextCommand::Unknown);
    }

    #[test]
    fn status_line_substitutes_numbers() {
        let line = format_status(Locale::TaiwanChinese, 3, 250, "沒有任務", "兩手空空");
        assert!(line.contains("3"));
        assert!(line.contains("250"));
        assert!(line.contains("通緝"));
        assert!(line.contains("信用點"));
        assert!(line.contains("兩手空空"));
        assert_eq!(
            format_held(Locale::English, "concrete", 2),
            "holding concrete x2"
        );
        assert_eq!(format_held(Locale::French, "", 0), "mains vides");
    }

    #[test]
    fn accept_hint_uses_locale_command() {
        let offer = format_job_offer(Locale::French, "vol à la sauvette", 250, 1);
        assert!(offer.contains("accepter le contrat"));
        assert!(offer.contains("250"));
    }

    #[test]
    fn cli_lang_flag_wins() {
        let args = vec![
            "hanga".into(),
            "--lang".into(),
            "zh-TW".into(),
        ];
        assert_eq!(Locale::from_env_and_args(&args), Locale::TaiwanChinese);
        let args = vec!["hanga".into(), "--locale".into(), "mi".into()];
        assert_eq!(Locale::from_env_and_args(&args), Locale::Maori);
    }
}
