use std::path::PathBuf;
use std::process::Command;

fn state_dir() -> PathBuf {
    if let Ok(dir) = std::env::var("XDG_RUNTIME_DIR") {
        PathBuf::from(dir).join("herdr-tab-rename")
    } else {
        PathBuf::from("/tmp/herdr-tab-rename")
    }
}

fn tab_name(tab_id: &str) -> Option<String> {
    let out = Command::new("herdr")
        .args(["tab", "get", tab_id])
        .output().ok()?;
    let val: serde_json::Value = serde_json::from_slice(&out.stdout).ok()?;
    val["result"]["tab"]["label"].as_str().map(|s| s.to_owned())
}

fn rename(tab_id: &str, name: &str) -> bool {
    Command::new("herdr")
        .args(["tab", "rename", tab_id, name])
        .output()
        .is_ok()
}

fn auto_name(tab_id: &str, cwd: &str) {
    let Some(current) = tab_name(tab_id) else { return };

    let sf = state_dir().join(tab_id);
    let last_auto = std::fs::read_to_string(&sf).ok();

    if let Some(ref last) = last_auto {
        if last != &current {
            return;
        }
    }

    let name = match cwd {
        "/" => "/".into(),
        c if c == std::env::var("HOME").unwrap_or_default() => "~".into(),
        _ => std::path::Path::new(cwd)
            .file_name()
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_else(|| "~".into()),
    };

    if rename(tab_id, &name) {
        if let Some(dir) = state_dir().parent() {
            std::fs::create_dir_all(dir).ok();
        }
        std::fs::write(&sf, &name).ok();
    }
}

fn ssh_name(tab_id: &str, host: &str) {
    let name = format!("ssh:{}", host);
    if rename(tab_id, &name) {
        let sf = state_dir().join(tab_id);
        if let Some(dir) = sf.parent() {
            std::fs::create_dir_all(dir).ok();
        }
        std::fs::write(&sf, &name).ok();
    }
}

fn opencode_before(tab_id: &str, project: &str) {
    let name = format!("\u{f029a} {project}");
    let sf = state_dir().join(tab_id);
    if let Some(dir) = sf.parent() {
        std::fs::create_dir_all(dir).ok();
    }
    std::fs::write(&sf, &name).ok();
    rename(tab_id, &name);
}

fn opencode_after(tab_id: &str, project: &str, exit_code: i32) {
    let name = if exit_code == 0 {
        format!("\u{f058} {project}")
    } else {
        format!("\u{f00d} {project}")
    };
    let sf = state_dir().join(tab_id);
    if let Some(dir) = sf.parent() {
        std::fs::create_dir_all(dir).ok();
    }
    std::fs::write(&sf, &name).ok();
    rename(tab_id, &name);
}

fn arg(args: &[String], name: &str) -> Option<String> {
    args.windows(2).find_map(|w| {
        if w[0] == name { Some(w[1].clone()) } else { None }
    })
}

fn env(key: &str) -> String {
    std::env::var(key).unwrap_or_default()
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let cmd = args.get(1).map(|s| s.as_str()).unwrap_or("");

    match cmd {
        "on-pwd" => {
            let tab_id = arg(&args, "--tab-id").unwrap_or_else(|| env("HERDR_TAB_ID"));
            let cwd = arg(&args, "--cwd").unwrap_or_else(|| {
                std::env::current_dir().ok()
                    .map(|p| p.to_string_lossy().to_string())
                    .unwrap_or_default()
            });
            auto_name(&tab_id, &cwd);
        }
        "on-ssh" => {
            let tab_id = arg(&args, "--tab-id").unwrap_or_else(|| env("HERDR_TAB_ID"));
            let host = arg(&args, "--host").unwrap_or_default();
            ssh_name(&tab_id, &host);
        }
        "opencode-before" => {
            let tab_id = arg(&args, "--tab-id").unwrap_or_else(|| env("HERDR_TAB_ID"));
            let project = arg(&args, "--project").unwrap_or_default();
            opencode_before(&tab_id, &project);
        }
        "opencode-after" => {
            let tab_id = arg(&args, "--tab-id").unwrap_or_else(|| env("HERDR_TAB_ID"));
            let project = arg(&args, "--project").unwrap_or_default();
            let exit_code: i32 = arg(&args, "--exit-code")
                .and_then(|s| s.parse().ok())
                .unwrap_or(0);
            opencode_after(&tab_id, &project, exit_code);
        }
        _ => {
            eprintln!(
                "Usage: herdr-tab-rename <command> [--tab-id ID] [options]

Commands:
  on-pwd          根据当前目录重命名标签页
                  选项: --tab-id, --cwd
  on-ssh          标记 SSH 会话标签
                  选项: --tab-id, --host
  opencode-before 标记 opencode 开始
                  选项: --tab-id, --project
  opencode-after  标记 opencode 结束（带退出码）
                  选项: --tab-id, --project, --exit-code

未提供 --tab-id 时默认使用 $HERDR_TAB_ID 环境变量。"
            );
            std::process::exit(1);
        }
    }
}
