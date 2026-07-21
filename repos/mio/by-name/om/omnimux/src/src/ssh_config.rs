use std::collections::HashSet;
use std::path::{Path, PathBuf};

fn strip_ssh_comment(line: &str) -> &str {
    let mut in_token_start = true;
    for (i, ch) in line.char_indices() {
        if ch == '#' && in_token_start {
            return line[..i].trim_end();
        }
        in_token_start = ch.is_whitespace();
    }
    line
}

fn is_usable_host_token(host: &str) -> bool {
    !host.is_empty()
        && !host.contains('*')
        && !host.contains('?')
        && !host.starts_with('!')
        && !host.starts_with('-')
}

fn parse_ssh_config(config_path: &Path, hosts: &mut Vec<String>, visited: &mut HashSet<PathBuf>) {
    if !visited.insert(config_path.to_path_buf()) {
        return;
    }

    let Ok(content) = std::fs::read_to_string(config_path) else {
        return;
    };

    for raw_line in content.lines() {
        let line = strip_ssh_comment(raw_line.trim());
        if line.is_empty() {
            continue;
        }

        let lower = line.to_ascii_lowercase();
        if lower.starts_with("host ") || lower.starts_with("host\t") {
            let rest = line[4..].trim_start();
            for host in rest.split_whitespace() {
                if is_usable_host_token(host) && !hosts.iter().any(|h| h == host) {
                    hosts.push(host.to_string());
                }
            }
        } else if lower.starts_with("include ") || lower.starts_with("include\t") {
            let rest = line[7..].trim_start();
            for include_path in rest.split_whitespace() {
                let expanded_path = if include_path.starts_with("~/") {
                    if let Ok(home) = std::env::var("HOME") {
                        PathBuf::from(home).join(&include_path[2..])
                    } else {
                        PathBuf::from(include_path)
                    }
                } else if include_path.starts_with('/') {
                    PathBuf::from(include_path)
                } else if let Ok(home) = std::env::var("HOME") {
                    PathBuf::from(home).join(".ssh").join(include_path)
                } else {
                    PathBuf::from(include_path)
                };

                if let Some(expanded_str) = expanded_path.to_str() {
                    if let Ok(paths) = glob::glob(expanded_str) {
                        for entry in paths.flatten() {
                            parse_ssh_config(&entry, hosts, visited);
                        }
                    }
                }
            }
        }
    }
}

pub fn get_ssh_hosts() -> Vec<String> {
    let mut hosts = vec!["localhost".to_string()];
    let mut visited = HashSet::new();
    if let Ok(home) = std::env::var("HOME") {
        let config_path = PathBuf::from(home).join(".ssh").join("config");
        parse_ssh_config(&config_path, &mut hosts, &mut visited);
    }
    hosts
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashSet;

    #[test]
    fn strip_ssh_comment_keeps_hash_in_tokens() {
        assert_eq!(strip_ssh_comment("Host foo#bar"), "Host foo#bar");
        assert_eq!(strip_ssh_comment("Host foo # comment"), "Host foo");
    }

    #[test]
    fn is_usable_host_token_rejects_patterns() {
        assert!(!is_usable_host_token(""));
        assert!(!is_usable_host_token("*"));
        assert!(!is_usable_host_token("?"));
        assert!(!is_usable_host_token("!foo"));
        assert!(is_usable_host_token("web"));
    }

    #[test]
    fn parse_ssh_config_collects_hosts_and_skips_wildcards() {
        let path = std::env::temp_dir().join(format!(
            "omnimux_ssh_config_test_{}",
            std::process::id()
        ));
        std::fs::write(
            &path,
            "Host web db\nHost *\n# wildcard line above\nHost backup\n",
        )
        .expect("write config");

        let mut hosts = Vec::new();
        let mut visited = HashSet::new();
        parse_ssh_config(&path, &mut hosts, &mut visited);

        assert_eq!(hosts, vec!["web", "db", "backup"]);
        assert!(visited.contains(&path));
        let _ = std::fs::remove_file(path);
    }
}
