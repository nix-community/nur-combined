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
