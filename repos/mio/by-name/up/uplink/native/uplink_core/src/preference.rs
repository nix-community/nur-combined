use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use std::sync::{LazyLock, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};

/// Persisted success/failure memory so the next upload prefers hosts that worked.
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct ProviderPrefs {
    #[serde(default)]
    providers: HashMap<String, ProviderStats>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
struct ProviderStats {
    #[serde(default)]
    ok: u64,
    #[serde(default)]
    fail: u64,
    #[serde(default)]
    last_ok: Option<u64>,
    #[serde(default)]
    last_fail: Option<u64>,
}

impl ProviderStats {
    /// Prefer the latest outcome; history is only a tiebreaker so hosts can recover.
    fn score(&self) -> i64 {
        let recent = match (self.last_ok, self.last_fail) {
            (Some(ok), Some(fail)) if ok >= fail => 100,
            (Some(_), None) => 100,
            (Some(_), Some(_)) => -100,
            (None, Some(_)) => -100,
            (None, None) => 0,
        };
        recent + self.ok as i64 - self.fail as i64
    }
}

fn now_unix() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0)
}

fn config_path() -> Option<PathBuf> {
    let mut dir = dirs::config_dir()?;
    dir.push("uplink");
    Some(dir.join("providers.json"))
}

impl ProviderPrefs {
    fn load() -> Self {
        let Some(path) = config_path() else {
            return Self::default();
        };
        match fs::read_to_string(&path) {
            Ok(raw) => serde_json::from_str(&raw).unwrap_or_default(),
            Err(_) => Self::default(),
        }
    }

    fn save(&self) {
        let Some(path) = config_path() else {
            return;
        };
        if let Some(parent) = path.parent() {
            let _ = fs::create_dir_all(parent);
        }
        let Ok(raw) = serde_json::to_string_pretty(self) else {
            return;
        };
        let tmp = path.with_extension("json.tmp");
        if fs::write(&tmp, raw).is_ok() {
            let _ = fs::rename(&tmp, &path);
        }
    }

    fn record_ok(&mut self, id: &str) {
        let entry = self.providers.entry(id.to_owned()).or_default();
        entry.ok = entry.ok.saturating_add(1);
        entry.last_ok = Some(now_unix());
    }

    fn record_fail(&mut self, id: &str) {
        let entry = self.providers.entry(id.to_owned()).or_default();
        entry.fail = entry.fail.saturating_add(1);
        entry.last_fail = Some(now_unix());
    }

    /// Stable sort: higher score first; ties keep the given default order.
    fn sort_ids<'a>(&self, ids: &mut [(&'a str, usize)]) {
        ids.sort_by(|(a, ai), (b, bi)| {
            let sa = self
                .providers
                .get(*a)
                .map(ProviderStats::score)
                .unwrap_or(0);
            let sb = self
                .providers
                .get(*b)
                .map(ProviderStats::score)
                .unwrap_or(0);
            sb.cmp(&sa).then_with(|| ai.cmp(bi))
        });
    }
}

static PREFS_LOCK: LazyLock<Mutex<()>> = LazyLock::new(|| Mutex::new(()));

/// One upload attempt: snapshot order up front, flush outcomes once on drop.
pub(crate) struct PrefsSession {
    outcomes: Vec<(String, bool)>,
}

impl PrefsSession {
    pub(crate) fn begin() -> Self {
        Self {
            outcomes: Vec::new(),
        }
    }

    pub(crate) fn ordered<'a>(&self, default: &[&'a str]) -> Vec<&'a str> {
        let _guard = PREFS_LOCK.lock().unwrap_or_else(|e| e.into_inner());
        let prefs = ProviderPrefs::load();
        let mut keyed: Vec<(&str, usize)> = default
            .iter()
            .copied()
            .enumerate()
            .map(|(i, id)| (id, i))
            .collect();
        prefs.sort_ids(&mut keyed);
        keyed.into_iter().map(|(id, _)| id).collect()
    }

    pub(crate) fn record_ok(&mut self, id: &str) {
        self.outcomes.push((id.to_owned(), true));
    }

    pub(crate) fn record_fail(&mut self, id: &str) {
        self.outcomes.push((id.to_owned(), false));
    }
}

impl Drop for PrefsSession {
    fn drop(&mut self) {
        if self.outcomes.is_empty() {
            return;
        }
        let _guard = PREFS_LOCK.lock().unwrap_or_else(|e| e.into_inner());
        let mut prefs = ProviderPrefs::load();
        for (id, ok) in self.outcomes.drain(..) {
            if ok {
                prefs.record_ok(&id);
            } else {
                prefs.record_fail(&id);
            }
        }
        prefs.save();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn prefers_successful_hosts() {
        let mut prefs = ProviderPrefs::default();
        prefs.record_ok("uguu");
        prefs.record_ok("uguu");
        prefs.record_fail("catbox");
        prefs.record_fail("catbox");

        let mut ids = vec![("catbox", 0), ("0x0", 1), ("uguu", 2), ("pasteboard", 3)];
        prefs.sort_ids(&mut ids);
        assert_eq!(ids[0].0, "uguu");
        assert_eq!(ids.last().map(|x| x.0), Some("catbox"));
    }

    #[test]
    fn recent_success_recovers_over_old_failures() {
        let mut prefs = ProviderPrefs::default();
        for _ in 0..5 {
            prefs.record_fail("catbox");
        }
        prefs.record_ok("catbox");
        prefs.record_fail("uguu");

        let mut ids = vec![("uguu", 0), ("catbox", 1)];
        prefs.sort_ids(&mut ids);
        assert_eq!(ids[0].0, "catbox");
    }

    #[test]
    fn unknown_hosts_keep_default_order() {
        let prefs = ProviderPrefs::default();
        let mut ids = vec![("catbox", 0), ("0x0", 1), ("uguu", 2)];
        prefs.sort_ids(&mut ids);
        assert_eq!(
            ids.iter().map(|x| x.0).collect::<Vec<_>>(),
            vec!["catbox", "0x0", "uguu"]
        );
    }
}
