use crate::{Action, Item, core, item, workflow::Operation};
use std::{fs, io::Write, os::unix::fs::OpenOptionsExt, path::Path};

pub fn read(path: &Path) -> Result<String, String> {
    match fs::metadata(path) {
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(String::new()),
        Err(e) => return Err(e.to_string()),
        Ok(m) if m.len() > 1_048_576 => return Err("Todo file exceeds 1 MiB".into()),
        _ => {}
    }
    fs::read_to_string(path).map_err(|e| e.to_string())
}
pub fn write(path: &Path, previous: &str, next: &str) -> Result<(), String> {
    if next.len() > 1_048_576 {
        return Err("Todo file exceeds 1 MiB".into());
    }
    if read(path)? != previous {
        return Err("Todos changed on disk; search again before editing".into());
    }
    fs::create_dir_all(path.parent().unwrap()).map_err(|e| e.to_string())?;
    let temporary = path.with_extension(format!("{}.tmp", gtk::glib::uuid_string_random()));
    let result = (|| {
        let mut file = fs::OpenOptions::new()
            .write(true)
            .create_new(true)
            .mode(0o600)
            .open(&temporary)
            .map_err(|e| e.to_string())?;
        file.write_all(next.as_bytes()).map_err(|e| e.to_string())?;
        file.sync_all().map_err(|e| e.to_string())?;
        fs::rename(&temporary, path).map_err(|e| e.to_string())
    })();
    if result.is_err() {
        let _ = fs::remove_file(temporary);
    }
    result
}
pub fn add(path: &Path, text: &str) -> Result<(), String> {
    if text.trim().is_empty() || text.contains(['\n', '\r']) {
        return Err("Type todo followed by one line of text".into());
    }
    let previous = read(path)?;
    let mut next = previous.clone();
    if !next.is_empty() && !next.ends_with('\n') {
        next.push('\n');
    }
    next.push_str(&format!("- [ ] {}\n", text.trim()));
    write(path, &previous, &next)
}
pub fn toggle(path: &Path, line: usize, expected: &str) -> Result<(), String> {
    let previous = read(path)?;
    let mut lines: Vec<_> = previous.split_inclusive('\n').map(str::to_owned).collect();
    let value = lines
        .get_mut(line)
        .ok_or("Todo was removed; search again")?;
    if value.trim_end_matches(['\r', '\n']) != expected {
        return Err("Todo changed; search again".into());
    }
    let offset = value.len() - value.trim_start().len();
    let check = value
        .get(offset + 3..offset + 4)
        .ok_or("Invalid Markdown todo")?;
    value.replace_range(offset + 3..offset + 4, if check == " " { "x" } else { " " });
    write(path, &previous, &lines.concat())
}
pub fn rows(query: &str) -> Vec<Item> {
    let path = core::data_dir().join("todos.md");
    let explicit = matches!(query, "todo" | "todos" | "todo done");
    let mut rows = Vec::new();
    if let Some(text) = query
        .strip_prefix("todo add ")
        .or_else(|| query.strip_prefix("todo ").filter(|s| *s != "add"))
        .filter(|s| !s.is_empty() && *s != "done")
    {
        rows.push(item(
            "todo-add",
            &format!("Add todo · {text}"),
            "Save to todos.md",
            "list-add-symbolic",
            "Todo",
            Action::Workflow(Operation::AddTodo(text.into())),
        ));
    }
    match read(&path) {
        Ok(content) => {
            for (line, value) in content.lines().enumerate() {
                let trimmed = value.trim_start();
                let done = trimmed.starts_with("- [x] ") || trimmed.starts_with("- [X] ");
                if !trimmed.starts_with("- [ ] ") && !done {
                    continue;
                }
                if done && query != "todo done" {
                    continue;
                }
                let title = &trimmed[6..];
                if !explicit && core::score(query, title).is_none() {
                    continue;
                }
                rows.push(item(
                    &format!("todo:{line}"),
                    &format!("{} {title}", if done { "☑" } else { "☐" }),
                    if done {
                        "Enter to reopen · todos.md"
                    } else {
                        "Enter to complete · todos.md"
                    },
                    "checkbox-checked-symbolic",
                    "Todo",
                    Action::Workflow(Operation::ToggleTodo(line, value.into())),
                ));
            }
        }
        Err(e) if explicit => rows.push(item(
            "todo-error",
            "Cannot read todos.md",
            &e,
            "dialog-warning-symbolic",
            "Todo",
            Action::Noop,
        )),
        _ => {}
    }
    rows.truncate(200);
    if explicit {
        rows.push(item(
            "todo-edit",
            "Open todos.md",
            "Edit your Markdown checklist · add with todo add buy milk",
            "document-edit-symbolic",
            "Todo",
            Action::Workflow(Operation::EditTodos),
        ));
    }
    rows
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn markdown_round_trip_and_external_edits() {
        let dir = std::env::temp_dir().join(format!(
            "spotlight-todos-{}",
            gtk::glib::uuid_string_random()
        ));
        fs::create_dir(&dir).unwrap();
        let path = dir.join("todos.md");
        fs::write(&path, "# Shopping\r\n\r\n  - [ ] milk\r\nNotes").unwrap();
        toggle(&path, 2, "  - [ ] milk").unwrap();
        assert_eq!(
            read(&path).unwrap(),
            "# Shopping\r\n\r\n  - [x] milk\r\nNotes"
        );
        assert!(toggle(&path, 2, "  - [ ] milk").is_err());
        add(&path, "bread").unwrap();
        assert!(read(&path).unwrap().ends_with("Notes\n- [ ] bread\n"));
        assert!(add(&path, "bad\nline").is_err());
        assert!(write(&path, "stale", "oops").is_err());
        fs::remove_dir_all(dir).unwrap();
    }
}
