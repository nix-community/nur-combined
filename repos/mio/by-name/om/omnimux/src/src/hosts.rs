/// Host query after `user@` prefix for SSH autocomplete.
pub fn host_query(input: &str) -> &str {
    if input.contains('@') {
        input.split('@').next_back().unwrap_or("")
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

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct HostItem {
    pub host: String,
    pub is_open: bool,
    pub is_recent: bool,
    pub is_ssh_config: bool,
}

pub fn filter_hosts(query: &str, hosts: &[HostItem]) -> Vec<HostItem> {
    let q = query.to_lowercase();
    hosts
        .iter()
        .filter(|h| h.host.to_lowercase().contains(&q))
        .cloned()
        .collect()
}

/// Resolve the SSH host string from prompt text and optional list selection.
pub fn resolve_host(input: &str, selected: Option<&str>) -> String {
    if input.chars().filter(|&c| c == '@').count() > 1 {
        return input.to_string();
    }

    let prefix = host_prefix(input);
    match selected {
        Some("localhost") => "localhost".to_string(),
        Some(host) => format!("{prefix}{host}"),
        None => input.to_string(),
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct InvalidSshDestination;

pub fn validate_host_option(final_host: &str) -> Result<Option<String>, InvalidSshDestination> {
    let trimmed = final_host.trim();
    if trimmed.is_empty() || trimmed == "localhost" {
        Ok(None)
    } else if is_safe_ssh_destination(trimmed) {
        Ok(Some(trimmed.to_string()))
    } else {
        Err(InvalidSshDestination)
    }
}

/// Reject host strings that could confuse `ssh` argv or shell tooling.
///
/// Allows `user@host`, DNS names, IPv4/IPv6-ish characters, and `:` / `%` for
/// ports / zone IDs. Rejects whitespace, shell metacharacters, and leading `-`.
pub fn is_safe_ssh_destination(host: &str) -> bool {
    if host.is_empty() || host.starts_with('-') {
        return false;
    }
    if host.chars().filter(|&c| c == '@').count() > 1 {
        return false;
    }
    host.chars().all(|c| {
        c.is_ascii_alphanumeric()
            || matches!(c, '.' | '_' | '-' | '@' | ':' | '%' | '[' | ']')
    })
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
        let hosts = vec![
            HostItem { host: "WebServer".into(), is_open: false, is_recent: false, is_ssh_config: false },
            HostItem { host: "db.local".into(), is_open: false, is_recent: false, is_ssh_config: false }
        ];
        let filtered = filter_hosts("web", &hosts);
        assert_eq!(filtered[0].host, "WebServer".to_string());
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
    fn resolve_host_rejects_ambiguous_user_host_input() {
        assert_eq!(resolve_host("dev@dev@mbp", Some("mbp")), "dev@dev@mbp");
    }

    #[test]
    fn validate_host_option_distinguishes_localhost_from_invalid() {
        assert_eq!(validate_host_option("localhost"), Ok(None));
        assert_eq!(validate_host_option(""), Ok(None));
        assert_eq!(validate_host_option("dev@mbp"), Ok(Some("dev@mbp".into())));
        assert_eq!(validate_host_option("dev@dev@mbp"), Err(InvalidSshDestination));
    }

    #[test]
    fn rejects_unsafe_ssh_destinations() {
        assert!(!is_safe_ssh_destination("-oProxyCommand=evil"));
        assert!(!is_safe_ssh_destination("host;rm -rf /"));
        assert!(!is_safe_ssh_destination("host$(id)"));
        assert!(!is_safe_ssh_destination("host with spaces"));
        assert!(is_safe_ssh_destination("user@web.example"));
        assert!(is_safe_ssh_destination("192.168.1.1"));
        assert!(is_safe_ssh_destination("[::1]:22"));
        assert!(!is_safe_ssh_destination("a@b@host"));
        assert_eq!(
            validate_host_option("-oProxyCommand=x"),
            Err(InvalidSshDestination)
        );
    }
}
