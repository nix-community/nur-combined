/// Host query after `user@` prefix for SSH autocomplete.
pub fn host_query(input: &str) -> &str {
    if input.contains('@') {
        input.split('@').last().unwrap_or("")
    } else {
        input
    }
}

/// `user@` prefix when the prompt contains `@`.
pub fn host_prefix(input: &str) -> String {
    if input.contains('@') {
        format!("{}@", input.split('@').next().unwrap_or(""))
    } else {
        String::new()
    }
}

pub fn filter_hosts(query: &str, hosts: &[String]) -> Vec<String> {
    let q = query.to_lowercase();
    hosts
        .iter()
        .filter(|h| h.to_lowercase().contains(&q))
        .cloned()
        .collect()
}

/// Resolve the SSH host string from prompt text and optional list selection.
pub fn resolve_host(input: &str, selected: Option<&str>) -> String {
    let prefix = host_prefix(input);
    match selected {
        Some("localhost") => "localhost".to_string(),
        Some(host) => format!("{prefix}{host}"),
        None => input.to_string(),
    }
}

pub fn host_option(final_host: &str) -> Option<String> {
    let trimmed = final_host.trim();
    if trimmed.is_empty() || trimmed == "localhost" {
        None
    } else {
        Some(trimmed.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn host_query_after_at() {
        assert_eq!(host_query("user@web"), "web");
        assert_eq!(host_query("web"), "web");
    }

    #[test]
    fn host_prefix_preserves_user() {
        assert_eq!(host_prefix("user@"), "user@");
        assert_eq!(host_prefix("host"), "");
    }

    #[test]
    fn filter_hosts_case_insensitive() {
        let hosts = vec!["WebServer".into(), "db.local".into()];
        let filtered = filter_hosts("web", &hosts);
        assert_eq!(filtered, vec!["WebServer".to_string()]);
    }

    #[test]
    fn resolve_host_with_selection() {
        assert_eq!(
            resolve_host("user@", Some("web")),
            "user@web"
        );
        assert_eq!(resolve_host("", Some("localhost")), "localhost");
        assert_eq!(resolve_host("mybox", None), "mybox");
    }

    #[test]
    fn host_option_localhost_is_none() {
        assert_eq!(host_option("localhost"), None);
        assert_eq!(host_option("  "), None);
        assert_eq!(host_option("web.example"), Some("web.example".into()));
    }
}
