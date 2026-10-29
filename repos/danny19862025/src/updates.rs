use gtk::{glib, prelude::*};
use std::{process::Command, sync::mpsc, time::Duration};

const RELEASES: &str = "https://github.com/danny19862025/spotlight/releases";
const API: &str = "https://api.github.com/repos/danny19862025/spotlight/releases/latest";

fn release_summary(body: &str, current: &str) -> Result<String, String> {
    let release: serde_json::Value = serde_json::from_str(body)
        .map_err(|_| "GitHub returned an unreadable release. Try again later.".to_string())?;
    if release["draft"] == true || release["prerelease"] == true {
        return Err("No stable release is available yet.".into());
    }
    let tag = release["tag_name"]
        .as_str()
        .ok_or("Release version unavailable.")?;
    let latest = semver::Version::parse(tag.strip_prefix('v').unwrap_or(tag))
        .map_err(|_| "The latest release has an unsupported version tag.".to_string())?;
    let installed =
        semver::Version::parse(current).map_err(|_| "Installed version unavailable.")?;
    if !latest.pre.is_empty() {
        return Err("No stable release is available yet.".into());
    }
    Ok(if latest > installed {
        format!("Update available: {tag}. Installed: {current}. Open Releases to download it.")
    } else {
        format!("You’re up to date. Installed: {current}; latest stable: {tag}.")
    })
}

fn check_latest() -> Result<String, String> {
    let output = Command::new("curl")
        .args([
            "--silent",
            "--show-error",
            "--connect-timeout",
            "5",
            "--max-time",
            "15",
            "--max-filesize",
            "1048576",
            "--proto",
            "=https",
            "--header",
            "Accept: application/vnd.github+json",
            "--header",
            "User-Agent: Spotlight",
            "--write-out",
            "\n%{http_code}",
            API,
        ])
        .output()
        .map_err(|_| {
            "Could not start the update check. Make sure curl is installed.".to_string()
        })?;
    if !output.status.success() {
        return Err(
            "Couldn’t reach GitHub. Check your connection and try again, or open Releases.".into(),
        );
    }
    let response = String::from_utf8_lossy(&output.stdout);
    let (body, status) = response
        .rsplit_once('\n')
        .ok_or("Invalid response from GitHub.")?;
    match status.trim() {
        "200" => release_summary(body, env!("CARGO_PKG_VERSION")),
        "404" => Ok("No published release found. Open Releases to check GitHub.".into()),
        "403" | "429" => Err(
            "GitHub temporarily limited update checks. Try again later or open Releases.".into(),
        ),
        _ => Err("Update check unavailable. Try again later or open Releases.".into()),
    }
}

pub fn add_controls(panel: &gtk::Box) {
    let row = gtk::Box::new(gtk::Orientation::Horizontal, 10);
    row.set_halign(gtk::Align::Center);
    let button = gtk::Button::with_label("Check for updates");
    button.set_widget_name("check-app-updates");
    row.append(&button);
    row.append(&gtk::LinkButton::with_label(RELEASES, "Releases ↗"));
    panel.append(&row);
    let status = gtk::Label::new(Some("Check GitHub for the latest stable release."));
    status.set_widget_name("app-update-status");
    status.set_wrap(true);
    status.set_max_width_chars(48);
    status.set_justify(gtk::Justification::Center);
    status.add_css_class("subtitle");
    panel.append(&status);
    button.connect_clicked(move |button| {
        button.set_sensitive(false);
        status.set_text("Checking GitHub for updates…");
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(check_latest());
        });
        let button = button.downgrade();
        let status = status.downgrade();
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let (Some(button), Some(status)) = (button.upgrade(), status.upgrade()) else {
                return glib::ControlFlow::Break;
            };
            let message = match rx.try_recv() {
                Ok(result) => result.unwrap_or_else(|error| error),
                Err(mpsc::TryRecvError::Empty) => return glib::ControlFlow::Continue,
                Err(_) => "Update check interrupted. Please try again.".into(),
            };
            status.set_text(&message);
            button.set_sensitive(true);
            glib::ControlFlow::Break
        });
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn compares_release_versions_numerically() {
        assert!(
            release_summary(r#"{"tag_name":"v0.10.0"}"#, "0.4.0")
                .unwrap()
                .contains("Update available")
        );
        for tag in ["v0.4.0", "0.3.9"] {
            assert!(
                release_summary(&format!(r#"{{"tag_name":"{tag}"}}"#), "0.4.0")
                    .unwrap()
                    .contains("up to date")
            );
        }
    }

    #[test]
    fn rejects_invalid_and_unstable_releases() {
        for body in [
            "not json",
            "{}",
            r#"{"tag_name":"bad"}"#,
            r#"{"tag_name":"v1.0.0","draft":true}"#,
            r#"{"tag_name":"v1.0.0","prerelease":true}"#,
            r#"{"tag_name":"v1.0.0-rc.1"}"#,
        ] {
            assert!(release_summary(body, "0.4.0").is_err(), "{body}");
        }
    }
}
