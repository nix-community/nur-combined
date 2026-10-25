use gtk::{gio, prelude::*};
const REASON: &str = "Spotlight Caffeinate: keep the screen and computer awake";

struct Cookie {
    service: &'static str,
    path: &'static str,
    interface: &'static str,
    release: &'static str,
    value: u32,
}

/// KDE releases these inhibitors if this application's D-Bus connection exits.
pub struct Inhibitor {
    bus: gio::DBusConnection,
    cookies: Vec<Cookie>,
}

impl Inhibitor {
    pub fn start() -> Result<Self, String> {
        let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
            .map_err(|e| e.to_string())?;
        let mut inhibitor = Self {
            bus,
            cookies: Vec::new(),
        };
        // Screen blanking and automatic suspend have separate inhibitors.
        for (service, path, interface, acquire, release, parameters) in [
            (
                "org.kde.Solid.PowerManagement",
                "/org/kde/Solid/PowerManagement/PolicyAgent",
                "org.kde.Solid.PowerManagement.PolicyAgent",
                "AddInhibition",
                "ReleaseInhibition",
                (5u32, "Spotlight", REASON).to_variant(), // InterruptSession | ChangeScreenSettings
            ),
            (
                "org.freedesktop.ScreenSaver",
                "/ScreenSaver",
                "org.freedesktop.ScreenSaver",
                "Inhibit",
                "UnInhibit",
                ("Spotlight", REASON).to_variant(),
            ),
        ] {
            let result = inhibitor.bus.call_sync(
                Some(service),
                path,
                interface,
                acquire,
                Some(&parameters),
                None,
                gio::DBusCallFlags::NONE,
                3000,
                None::<&gio::Cancellable>,
            );
            let reply = match result {
                Ok(reply) => reply,
                Err(error) => {
                    let _ = inhibitor.stop();
                    return Err(format!("Could not enable Caffeinate: {error}"));
                }
            };
            let (value,) = reply.get::<(u32,)>().ok_or("Invalid Caffeinate response")?;
            inhibitor.cookies.push(Cookie {
                service,
                path,
                interface,
                release,
                value,
            });
        }
        Ok(inhibitor)
    }

    pub fn stop(&mut self) -> Result<(), String> {
        let mut errors = Vec::new();
        self.cookies.retain(|cookie| {
            match self.bus.call_sync(
                Some(cookie.service),
                cookie.path,
                cookie.interface,
                cookie.release,
                Some(&(cookie.value,).to_variant()),
                None,
                gio::DBusCallFlags::NONE,
                3000,
                None::<&gio::Cancellable>,
            ) {
                Ok(_) => false,
                Err(error) => {
                    errors.push(error.to_string());
                    true
                }
            }
        });
        if errors.is_empty() {
            Ok(())
        } else {
            Err(format!(
                "Could not fully turn off Caffeinate: {}",
                errors.join("; ")
            ))
        }
    }
}

impl Drop for Inhibitor {
    fn drop(&mut self) {
        for cookie in &self.cookies {
            self.bus.call(
                Some(cookie.service),
                cookie.path,
                cookie.interface,
                cookie.release,
                Some(&(cookie.value,).to_variant()),
                None,
                gio::DBusCallFlags::NONE,
                1000,
                None::<&gio::Cancellable>,
                |_| {},
            );
        }
    }
}
