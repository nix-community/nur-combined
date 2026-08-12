/// Shared locale ids for WASM mods. 0=en, 1=mi, 2=fr, 3=zh-TW.
/// Unknown tags fall back to English so a host can send any BCP-47 string.
pub fn locale_id(locale: &str) -> u8 {
    let raw = locale.trim();
    let no_dot = raw.split('.').next().unwrap_or(raw);
    let folded = no_dot.replace('_', "-").to_lowercase();
    let primary = folded.split('-').next().unwrap_or(&folded);
    match folded.as_str() {
        "mi" | "mao" | "mri" | "maori" | "māori" | "mi-nz" | "te-reo" => 1,
        "fr" | "fra" | "fre" | "french" | "francais" | "français" | "fr-fr" | "fr-ca" => 2,
        "zh-tw" | "zh-hant" | "zh-hant-tw" | "zh-taiwan" | "taiwan" | "tw" => 3,
        _ => match primary {
            "mi" | "mao" | "mri" => 1,
            "fr" => 2,
            "zh" => 3,
            _ => 0,
        },
    }
}

pub fn supported_locales() -> String {
    "en,mi,fr,zh-TW".into()
}
