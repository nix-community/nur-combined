//! Headless Wayland bring-up for the CLI path (`--pixel`).
//!
//! `CaptureContext` — bring-up ONCE (connection, registry, OutputState
//! roundtrip, screencopy/shm bind), capture MANY. No layer-shell surface,
//! no overlay, no calloop, no signals: it reuses [`IEWaylandState`] purely
//! as an SCTK delegate carrier and never builds a window.
//!
//! This is the capture-engine a future resident daemon reuses verbatim —
//! daemon-readiness is "this struct lives longer" (process-scoped today,
//! daemon-scoped later), not a rewrite.

use anyhow::{Context, Result};
use wayland_client::{Connection, globals::registry_queue_init};

use super::IEWaylandState;
use crate::core::capture::{self, PhysicalCanvas};

pub struct CaptureContext {
    state: IEWaylandState,
    event_queue: wayland_client::EventQueue<IEWaylandState>,
    /// Only consumed by Tier-2/3 fallback (KWin/Portal). On wlroots Tier-1
    /// fires first and this stays untouched — that's the ~10ms fast path.
    dbus_conn: Option<zbus::blocking::Connection>,
}

impl CaptureContext {
    /// Wayland bring-up done once. `registry_queue_init` + `IEWaylandState`
    /// as a bare delegate carrier, then roundtrip until every output reports
    /// xdg-output logical geometry (headless has no event loop to do it for us).
    pub fn bringup(dbus_conn: Option<zbus::blocking::Connection>) -> Result<Self> {
        let conn = Connection::connect_to_env()
            .context("Wayland connect failed (no $WAYLAND_DISPLAY?)")?;
        let (globals, mut event_queue) = registry_queue_init::<IEWaylandState>(&conn)
            .context("Wayland registry init failed")?;
        let qh = event_queue.handle();
        let mut state = IEWaylandState::new(conn.clone(), &globals, &qh);

        // First roundtrip: outputs appear. Subsequent: their geometry.
        // Headless has no event loop, and many compositors never send
        // xdg-output to a windowless client — so we wait for the *mode*
        // (always delivered via wl_output) and derive logical geometry in
        // capture(). Bounded loop: proceed rather than hang.
        for _ in 0..8 {
            event_queue
                .roundtrip(&mut state)
                .context("Wayland roundtrip failed")?;
            let mut outs = state.output_state.outputs();
            let any = outs.next().is_some();
            let all_known = state.output_state.outputs().all(|o| {
                state
                    .output_state
                    .info(&o)
                    .map(|i| i.logical_size.is_some() || i.modes.iter().any(|m| m.current))
                    .unwrap_or(false)
            });
            if any && all_known {
                break;
            }
        }

        Ok(Self { state, event_queue, dbus_conn })
    }

    /// One fresh capture → [`PhysicalCanvas`] via the tier selector
    /// (Tier-1 WLR ≈10ms → Tier-2 KWin → Tier-3 Portal). Mirrors the
    /// daemon's `render.rs` assembly. `output_meta` is rebuilt per call so
    /// a later `--stdin` loop tracks monitor hotplug for free.
    pub fn capture(&mut self) -> Result<PhysicalCanvas> {
        // Drain pending events (hotplug etc.) before reading geometry.
        self.event_queue
            .roundtrip(&mut self.state)
            .context("Wayland roundtrip failed")?;

        // Headless rarely gets xdg-output — collect_output_meta's mode/scale
        // fallback (which originated here) reconstructs logical geometry.
        let output_meta = self.state.collect_output_meta();

        let screencopy = match (&self.state.screencopy_manager, &self.state.shm) {
            (Some(manager), Some(shm)) => Some((&self.state.conn, manager, shm.wl_shm())),
            _ => None,
        };

        capture::capture_all_outputs(&output_meta, screencopy, self.dbus_conn.as_ref())
    }
}
