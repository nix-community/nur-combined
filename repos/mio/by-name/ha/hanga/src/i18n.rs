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
    "unknown",
    "lang_set",
    "status",
    "job_active",
    "job_offer",
    "job_none",
    "look",
    "commands_help",
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
        "unknown" => "Unknown command '{cmd}'.",
        "lang_set" => "Language set to {name} ({code}).",
        "status" => "Wanted {wanted}. Credits {credits}. {job}",
        "job_active" => "active job: {name} (${payout}, danger {danger})",
        "job_offer" => "offer: {name} (${payout}, danger {danger}). Type '{accept}'.",
        "job_none" => "no job",
        "look" => "{status}. Ahead is {label} at {pos}. Commands: {commands}.",
        "commands_help" => "move forward, break block, accept job, complete job, fence, lang",
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
        "unknown" => "Whakahau tē mōhiotia '{cmd}'.",
        "lang_set" => "Kua tautuhia te reo ki {name} ({code}).",
        "status" => "Taumata hiahiatia {wanted}. Moni {credits}. {job}",
        "job_active" => "mahi kaha: {name} (${payout}, mōrearea {danger})",
        "job_offer" => "tuku mahi: {name} (${payout}, mōrearea {danger}). Patohia '{accept}'.",
        "job_none" => "kāore he mahi",
        "look" => "{status}. Kei mua ko {label} kei {pos}. Ngā whakahau: {commands}.",
        "commands_help" => "neke whakamua, whati poraka, whakaae mahi, whakaoti mahi, hoko taonga, reo",
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
        "unknown" => "Commande inconnue « {cmd} ».",
        "lang_set" => "Langue définie : {name} ({code}).",
        "status" => "Recherché {wanted}. Crédits {credits}. {job}",
        "job_active" => "contrat actif : {name} ({payout} $, danger {danger})",
        "job_offer" => "offre : {name} ({payout} $, danger {danger}). Tapez « {accept} ».",
        "job_none" => "aucun contrat",
        "look" => "{status}. Devant : {label} en {pos}. Commandes : {commands}.",
        "commands_help" => "avancer, casser un bloc, accepter le contrat, terminer le contrat, revendre, langue",
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
        "unknown" => "未知指令「{cmd}」。",
        "lang_set" => "語言已設為{name}（{code}）。",
        "status" => "通緝 {wanted}。信用點 {credits}。{job}",
        "job_active" => "進行中任務：{name}（${payout}，危險 {danger}）",
        "job_offer" => "可接任務：{name}（${payout}，危險 {danger}）。輸入「{accept}」。",
        "job_none" => "沒有任務",
        "look" => "{status}。前方是{label}，位置 {pos}。指令：{commands}。",
        "commands_help" => "前進、破壞方塊、接受任務、完成任務、銷贓、語言",
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

pub fn tr_label(locale: Locale, key: &str) -> String {
    let folded = key.trim().to_lowercase();
    let translated = match locale {
        Locale::English => None,
        Locale::Maori => match folded.as_str() {
            "air" => Some("hau"),
            "concrete" => Some("raima"),
            "asphalt" => Some("huarahi tā"),
            "glass" => Some("karaihe"),
            "sidewalk" => Some("ara hīkoi"),
            "grass" => Some("pātītī"),
            "unknown" => Some("tē mōhiotia"),
            "quiet streets" => Some("ngā huarahi mārie"),
            "smash-and-grab contract" => Some("kirimina pakaru-hopu"),
            "armored-truck heist" => Some("keehi taraka pākaha"),
            "void" => Some("korekore"),
            "unknown event" => Some("takahanga tē mōhiotia"),
            _ => None,
        },
        Locale::French => match folded.as_str() {
            "air" => Some("air"),
            "concrete" => Some("béton"),
            "asphalt" => Some("asphalte"),
            "glass" => Some("verre"),
            "sidewalk" => Some("trottoir"),
            "grass" => Some("herbe"),
            "unknown" => Some("inconnu"),
            "quiet streets" => Some("rues calmes"),
            "smash-and-grab contract" => Some("contrat de vol à la sauvette"),
            "armored-truck heist" => Some("casse de fourgon blindé"),
            "void" => Some("vide"),
            "unknown event" => Some("événement inconnu"),
            _ => None,
        },
        Locale::TaiwanChinese => match folded.as_str() {
            "air" => Some("空氣"),
            "concrete" => Some("混凝土"),
            "asphalt" => Some("柏油"),
            "glass" => Some("玻璃"),
            "sidewalk" => Some("人行道"),
            "grass" => Some("草地"),
            "unknown" => Some("未知"),
            "quiet streets" => Some("平靜的街道"),
            "smash-and-grab contract" => Some("搶劫合約"),
            "armored-truck heist" => Some("運鈔車搶案"),
            "void" => Some("虛空"),
            "unknown event" => Some("未知事件"),
            _ => None,
        },
    };
    translated.unwrap_or(key).to_string()
}

pub fn accept_job_cmd(locale: Locale) -> &'static str {
    match locale {
        Locale::English => "accept job",
        Locale::Maori => "whakaae mahi",
        Locale::French => "accepter le contrat",
        Locale::TaiwanChinese => "接受任務",
    }
}

pub fn format_status(locale: Locale, wanted: u32, credits: i32, job: &str) -> String {
    fill(
        t(locale, "status"),
        &[
            ("wanted", &wanted.to_string()),
            ("credits", &credits.to_string()),
            ("job", job),
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
    fn labels_cover_city_and_heist_keys() {
        for locale in Locale::all() {
            for key in [
                "air",
                "concrete",
                "asphalt",
                "glass",
                "sidewalk",
                "grass",
                "quiet streets",
                "smash-and-grab contract",
                "armored-truck heist",
                "void",
            ] {
                let label = tr_label(locale, key);
                assert!(!label.is_empty(), "{locale:?} {key}");
            }
        }
        assert_eq!(tr_label(Locale::Maori, "asphalt"), "huarahi tā");
        assert_eq!(tr_label(Locale::French, "glass"), "verre");
        assert_eq!(tr_label(Locale::TaiwanChinese, "asphalt"), "柏油");
        assert_eq!(tr_label(Locale::TaiwanChinese, "armored-truck heist"), "運鈔車搶案");
        assert_eq!(tr_label(Locale::English, "asphalt"), "asphalt");
        assert_eq!(tr_label(Locale::French, "mystery-block"), "mystery-block");
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
        let line = format_status(Locale::TaiwanChinese, 3, 250, "沒有任務");
        assert!(line.contains("3"));
        assert!(line.contains("250"));
        assert!(line.contains("通緝"));
        assert!(line.contains("信用點"));
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
