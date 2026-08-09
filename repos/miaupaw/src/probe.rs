//! Probe modes — acquisition paths that bypass the overlay and emit straight
//! to stdout/clipboard/history. The CLI surface for automation, scripts,
//! and AI-agent consumers. No daemon, no tray, no hotkeys.
//!
//! Layout:
//! - [`Capturer`] — bring-up once, capture many. Wayland uses the same
//!   `CaptureContext` the daemon does (WLR ≈ 20ms tier); off-Wayland
//!   falls back to Portal. Windows: GDI/DXGI direct.
//! - [`emit_pixel`] — single point that resolves a pixel through the relay
//!   set and returns the formatted value. Clipboard batching is the
//!   caller's job (see `run_pixels` / `run_stdin`).
//! - [`run_pixels`] / [`run_stdin`] — the `--pixel` / `--pixels` / `--stdin`
//!   runners. Atomic vs resilient OOB policy split lives here.
//! - [`finish_pick`] (Unix) — terminus for `--pick` one-shot: relays the
//!   collected deck and `process::exit`s. Reuses the overlay runner from
//!   `main.rs`, only the finalization is probe-side.
//!
//! Naming: «probe» is the CLI-domain term for these modes (was «headless»).
//! Wayland-level `connectors/wayland/headless.rs` keeps its name as the
//! technically-correct Wayland term for a connection without a compositor
//! surface — different layer, different audience.

use anyhow::Result;

use crate::cli::{RelaySet, PickReq, PixelCoord};
use crate::core;
use crate::core::capture;
use crate::daemon::color_service::ColorService;
#[cfg(unix)]
use crate::core::terminal::{log_info, log_warn};
#[cfg(unix)]
use crate::connectors;

// ─── User-visible state vs automation contract ──────────────────────────────
//
// CONTRACT: probe modes (--pixel / --pixels / --stdin / --history) are
// AUTOMATION endpoints. A shell script can't see the overlay or the tray
// menu, so it can't react to format flips made there.
//
// `config.templates.selected` mutates via two interactive channels:
//   • tray menu  (right-click → format submenu)
//   • overlay    (digit keys 1..0 + finalize_overlay saving back to disk)
//
// Both channels are USER-VISIBLE: the human sees the result in the
// overlay and reacts. Probe has no such reaction loop — silently drifting
// output would break long-lived scripts. So probe takes a STATELESS
// BASELINE here, independent of how the daemon's interactive preference
// drifts. The explicit `-f / --format` flag overrides everything.
//
// Note: `[templates.copy]` (the format DEFINITIONS — what "html" means)
// still come from config — those are SCHEMA, not selection, and only
// mutate via manual TOML edit (no surprise channel).
//
// Same principle should apply to any future probe-affecting field that
// mutates via interactive channels (e.g. NDJSON toggle if one ever
// lands). User-edits-toml-manually fields (float_precision, deck_separator,
// [history] size/show) stay config-driven — the user did it deliberately.
pub fn default_format_for_probe() -> &'static str {
    "html"
}

/// Captures once (`--pixels`) or many times (`--stdin`). Bring-up is paid
/// exactly once — the keystone that makes `--stdin` warm without a daemon.
///
/// Tier order on Unix: Wayland (WLR/KWin/Portal selector at ≈20ms) → X11
/// (`capture_x11_root` via XCB get_image — also fast, ≈30ms typical) →
/// Portal (last resort, ≈500ms). Each tier is tried only when the previous
/// fails its bring-up / env check.
#[cfg(unix)]
enum UnixCapturer {
    /// Wayland: same bring-up the daemon does → tier selector (WLR ≈20ms).
    Wayland(Box<connectors::wayland::headless::CaptureContext>),
    /// X11 native: XCB get_image on the root window. Stateless — `capture()`
    /// just calls the function each time. Used on pure-X11 systems and
    /// XWayland boxes where the Wayland bring-up declined.
    X11,
    /// Off-Wayland-and-X11 fallback: legacy single-capture Portal, recaptured per call.
    Portal(Option<zbus::blocking::Connection>),
}

#[cfg(unix)]
pub struct Capturer {
    rt: tokio::runtime::Runtime,
    inner: UnixCapturer,
}
#[cfg(windows)]
pub struct Capturer;

#[cfg(unix)]
impl Capturer {
    pub fn new() -> Result<Self> {
        let rt = tokio::runtime::Runtime::new()?;
        let inner = {
            let _guard = rt.enter();
            let dbus_conn = zbus::blocking::Connection::session().ok();
            match connectors::wayland::headless::CaptureContext::bringup(dbus_conn.clone()) {
                Ok(ctx) => UnixCapturer::Wayland(Box::new(ctx)),
                Err(e) => {
                    // Wayland declined. Prefer X11 native if a display is
                    // exposed — much faster than Portal, and the daemon
                    // already does the same via capture_x11_root().
                    //
                    // X11 fallback on a pure-X11 box is the normal path,
                    // not a warning (mirrors run_x11_daemon's `log_info`
                    // on the same fork). Portal is the last resort and
                    // truly off-tier — still INFO, surfaces only with -v.
                    if std::env::var("DISPLAY").is_ok() {
                        log_info(&format!("Wayland connection failed ({e}). Falling back to X11."));
                        UnixCapturer::X11
                    } else {
                        log_warn(&format!("probe Wayland bring-up failed ({e}); portal fallback"));
                        UnixCapturer::Portal(dbus_conn)
                    }
                }
            }
        };
        Ok(Self { rt, inner })
    }

    pub fn capture(&mut self) -> Result<capture::PhysicalCanvas> {
        let _guard = self.rt.enter();
        match &mut self.inner {
            UnixCapturer::Wayland(ctx) => ctx.capture(),
            UnixCapturer::X11 => {
                let cap = connectors::x11::capture_x11_root()?;
                // X11 root starts at (0,0) by protocol — origin is exact.
                Ok(capture::PhysicalCanvas::from_single(cap, None, (0, 0)))
            }
            UnixCapturer::Portal(d) => {
                let cap = capture::portal::capture_screen(d.as_ref())?;
                // No Wayland connection on this tier → no layout metadata;
                // (0,0) is best effort (wrong only on offset layouts).
                Ok(capture::PhysicalCanvas::from_single(cap, None, (0, 0)))
            }
        }
    }
}

#[cfg(windows)]
impl Capturer {
    pub fn new() -> Result<Self> { Ok(Self) }
    pub fn capture(&mut self) -> Result<capture::PhysicalCanvas> {
        capture::capture_all_outputs()
    }
}

/// Resolved output format. Owned template so the caller can mutate `config`
/// (history) afterwards without a lingering borrow.
pub struct Fmt {
    pub tmpl: String,
    pub prec: usize,
}

pub fn resolve_format(config: &core::config::Config, key: &str) -> Result<Fmt> {
    let t = match key {
        "html" => &config.templates.copy.html,
        "hex" => &config.templates.copy.hex,
        "rgb" => &config.templates.copy.rgb,
        "float" => &config.templates.copy.float,
        "hsl" => &config.templates.copy.hsl,
        "hsv" => &config.templates.copy.hsv,
        "cmyk" => &config.templates.copy.cmyk,
        "delphi" => &config.templates.copy.delphi,
        "vb" => &config.templates.copy.vb,
        "long" => &config.templates.copy.long,
        _ => anyhow::bail!("unknown format '{key}'. Available: html, hex, rgb, float, hsl, hsv, cmyk, delphi, vb, long"),
    };
    Ok(Fmt { tmpl: t.clone(), prec: config.templates.float_precision })
}

pub fn flush_std() {
    use std::io::Write;
    let _ = std::io::stdout().flush();
    let _ = std::io::stderr().flush();
}

/// Emit one resolved pixel through stdout/swatch/history relays and return
/// its formatted value. Clipboard is the caller's job (batched join for
/// `--pixels`, rejected for `--stdin`), so it is deliberately not here.
/// `coord_prefix` adds `<coord>\t` — self-correlating output for `--stdin`,
/// where positional zip is unreliable (lines may be skipped). The coord
/// keeps its input form: `X,Y` (logical) or `N:X,Y` (physical).
pub fn emit_pixel(
    coord: PixelCoord, px: u32,
    fmt: &Fmt,
    relays: &RelaySet, config: &mut core::config::Config,
    coord_prefix: bool,
) -> String {
    use core::formats;
    use core::terminal::Styled;
    let r = ((px >> 16) & 0xFF) as u8;
    let g = ((px >> 8) & 0xFF) as u8;
    let b = (px & 0xFF) as u8;
    let value = formats::format_color(&fmt.tmpl, r, g, b, fmt.prec);
    let hex = formats::rgb_to_hex(r, g, b);
    let coord_str = coord.as_input_string();

    if relays.swatch {
        let swatch = "██".rgb(r, g, b);
        eprintln!("{} {} ({})", swatch, hex.as_str().bold(), coord_str);
    }
    if relays.stdout {
        if coord_prefix {
            println!("{coord_str}\t{value}");
        } else {
            println!("{value}");
        }
    }
    if relays.history {
        // Disk write deferred — caller saves once after the batch/stream.
        config.push_history(hex);
    }
    value
}

/// `--pick` terminus: relay the picked deck (no coords) and exit. Empty deck
/// means the user cancelled (Esc/RMB) — that is NOT a failure and NOT bad
/// input, so it gets its own exit code (130, the conventional "user aborted").
/// Never returns: a one-shot pick has nothing left to do.
pub fn finish_pick(
    svc: &mut ColorService,
    deck: Vec<image::Rgba<u8>>,
    coords: Vec<(i32, i32)>,
    phys_coords: Vec<(usize, i32, i32)>,
    req: &PickReq,
) -> ! {
    use core::formats;
    use core::terminal::Styled;

    if deck.is_empty() {
        eprintln!("pick cancelled");
        flush_std();
        std::process::exit(130);
    }

    let key = req
        .format
        .clone()
        .unwrap_or_else(|| svc.config.templates.selected.clone());
    let mut fmt = match resolve_format(&svc.config, &key) {
        Ok(f) => f,
        Err(e) => {
            eprintln!("error: {e}");
            flush_std();
            std::process::exit(2);
        }
    };
    if let Some(p) = req.float_precision { fmt.prec = p; }

    let relays = &req.relays;
    let mut relay_failed = false;
    let mut values = Vec::with_capacity(deck.len());
    for (i, c) in deck.iter().enumerate() {
        let (r, g, b) = (c.0[0], c.0[1], c.0[2]);
        let value = formats::format_color(&fmt.tmpl, r, g, b, fmt.prec);
        let hex = formats::rgb_to_hex(r, g, b);
        // Emit-side dual-mode: `--phys` opt-in formats the coord as
        // `N:X,Y` (per-tile physical, lossless). Default → `X,Y` logical.
        // Both swatch and `--with-coords` stdout follow the same string.
        let coord_str = if req.phys {
            phys_coords.get(i).map(|&(idx, x, y)| format!("{idx}:{x},{y}"))
        } else {
            coords.get(i).map(|&(x, y)| format!("{x},{y}"))
        };
        if relays.swatch {
            match &coord_str {
                Some(s) => eprintln!("{} {} ({s})", "██".rgb(r, g, b), hex.as_str().bold()),
                None    => eprintln!("{} {}", "██".rgb(r, g, b), hex.as_str().bold()),
            }
        }
        if relays.stdout {
            match (req.with_coords, &coord_str) {
                (true, Some(s)) => println!("{s}\t{value}"),
                _               => println!("{value}"),
            }
        }
        if relays.history {
            svc.config.push_history(hex);
        }
        values.push(value);
    }
    if relays.clipboard && let Err(e) = core::clipboard::set_text(&values.join("\n")) {
        eprintln!("warning: clipboard relay failed: {e}");
        relay_failed = true;
    }
    if relays.history {
        svc.config.save();
    }

    flush_std();
    std::process::exit(if relay_failed { 1 } else { 0 });
}

/// `--monitors` — dump canvas monitor layout as TSV → stdout.
///
/// Sixth acquisition mode (the second Reader after `--history`): source is
/// the captured `PhysicalCanvas` metadata, not pixels. Forces one capture
/// (cheap, ≈20-50ms on Wayland WLR/X11) — the metadata is harvested as a
/// side-effect, no separate metadata-only path needed.
///
/// TSV format (a `#`-prefixed header line, then one row per monitor):
/// ```text
/// # coords: absolute logical (compositor space)
/// index<TAB>name<TAB>WxH<TAB>X,Y<TAB>scale<TAB>transform
/// ```
/// — `WxH` and `X,Y` are absolute LOGICAL (post-scale) dimensions/position
/// in compositor space — directly substitutable into `--pixel X,Y`.
/// The header names the coord space so scripts (and agents) never have to
/// guess it; TSV consumers skip `#` lines.
/// — `name` is the compositor's output name (e.g. `DP-2`, `eDP-1` on
/// Wayland; `\\.\DISPLAY1` on Win32). Empty `-` placeholder for fused
/// single-tile backends (Portal, X11 root capture).
///
/// Composes with `-q` (mute stdout) only meaningfully; other relays
/// (clipboard/swatch) are silently inert — metadata isn't a colour.
pub fn run_monitors(relays: RelaySet) -> Result<()> {
    let mut capturer = Capturer::new()?;
    let canvas = capturer.capture()?;

    if relays.stdout {
        println!("{}", MONITORS_HEADER);
        for (idx, tile) in canvas.tiles.iter().enumerate() {
            println!("{}", monitor_row(idx, tile, &canvas));
        }
    }
    flush_std();
    Ok(())
}

/// Self-describing header of the `--monitors` TSV. Consumers skip `#` lines.
pub(crate) const MONITORS_HEADER: &str = "# coords: absolute logical (compositor space)";

/// One `--monitors` row. Pure (no I/O) so the round-trip contract
/// «printed coord re-parses as `--pixel` input» is testable — see
/// `test_monitors_row_feeds_back_into_pixel_input`.
pub(crate) fn monitor_row(
    idx: usize,
    tile: &capture::MonitorTile,
    canvas: &capture::PhysicalCanvas,
) -> String {
    let name = if tile.name.is_empty() { "-" } else { tile.name.as_str() };
    let transform = tile_transform_str(tile);
    // Coord invariant: every printed coordinate exits through render_coord —
    // identity today, the future `--origin` key's single hook tomorrow.
    let pos = crate::cli::render_coord(
        canvas,
        crate::cli::PixelCoord::Logical(tile.logical_pos.0, tile.logical_pos.1),
        false,
    );
    format!(
        "{}\t{}\t{}x{}\t{}\t{:.2}\t{}",
        idx,
        name,
        tile.logical_w, tile.logical_h,
        pos.as_input_string(),
        tile.scale,
        transform,
    )
}

/// Compositor's orientation tag for a tile. Unix reports the real Wayland
/// `wl_output::Transform`; Windows/single-tile-fused backends report
/// `"normal"` (DXGI rotation extract is a future-work TODO if anyone hits
/// a rotated mon on Win32 — the pixel buffer is already de-rotated at
/// capture time, so this is purely a diagnostic-display gap).
fn tile_transform_str(tile: &capture::MonitorTile) -> &'static str {
    #[cfg(unix)]
    {
        use wayland_client::protocol::wl_output::Transform as T;
        match tile.transform {
            T::Normal     => "normal",
            T::_90        => "90",
            T::_180       => "180",
            T::_270       => "270",
            T::Flipped    => "flipped",
            T::Flipped90  => "flipped-90",
            T::Flipped180 => "flipped-180",
            T::Flipped270 => "flipped-270",
            _             => "unknown",
        }
    }
    #[cfg(windows)]
    {
        let _ = tile;
        "normal"
    }
}

/// `--history` — dump saved color history → stdout. The fifth acquisition
/// mode: source is **disk**, not the screen. No capture, no overlay, no
/// daemon spin-up — just read `~/.local/state/ie-r/history.toml` (loaded
/// transparently by `Config::load`), format, and emit.
///
/// Output is always chronological (oldest → newest, newest is the **last**
/// line). The `reverse_order` config flag applies only to the tray menu,
/// where orientation is host-dependent; the terminal stream is always
/// top-down, so `ie-r --history | tail -n 1` gives the most recent pick
/// without surprises.
///
/// `limit`:
/// - `None`  → use `config.history.show` (matches what the tray displays)
/// - `Some(0)` → emit all entries (capped by `config.history.size`)
/// - `Some(n)` → emit the most recent `n` entries
///
/// Composes with the relay axis: `-s` swatches in stderr, `-c` copies the
/// full dump into clipboard, `-f` reformats. `--with-coords` is silently
/// ignored (history has no positions). Empty history → silent exit 0.
pub fn run_history(format_key: Option<String>, float_precision: Option<usize>, relays: RelaySet, limit: Option<usize>) -> Result<()> {
    use core::config::Config;
    use core::formats;
    use core::terminal::Styled;

    let config = Config::load_quiet();
    let key = format_key.unwrap_or_else(|| default_format_for_probe().to_string());
    let mut fmt = resolve_format(&config, &key)?;
    if let Some(p) = float_precision { fmt.prec = p; }

    // Source: on-disk history slice, in saved (insertion) order. push_history
    // inserts newest at index 0, so we reverse here to get chronological
    // (oldest first → newest last) for terminal output.
    let all: Vec<&String> = config.history.colors.iter().rev().collect();
    if all.is_empty() {
        // Silent empty: composable with scripts, no spurious warnings.
        flush_std();
        return Ok(());
    }

    // Apply limit. Some(0) = unlimited; None defers to config.history.show.
    let take_n = match limit {
        Some(0) => all.len(),
        Some(n) => n.min(all.len()),
        None    => config.history.show.min(all.len()),
    };
    // Take the LAST `take_n` (most recent), preserving chronological order.
    let slice = &all[all.len() - take_n..];

    let mut relay_failed = false;
    let mut clipboard_values: Vec<String> = Vec::new();

    for hex in slice {
        // Parse stored "#RRGGBB" back into RGB to feed format_color.
        let s = hex.trim_start_matches('#');
        let Ok(val) = u32::from_str_radix(s, 16) else {
            // Defensive: a corrupted history entry shouldn't kill the dump.
            eprintln!("warning: skipping unparsable history entry '{hex}'");
            continue;
        };
        let r = ((val >> 16) & 0xFF) as u8;
        let g = ((val >> 8) & 0xFF) as u8;
        let b = (val & 0xFF) as u8;
        let value = formats::format_color(&fmt.tmpl, r, g, b, fmt.prec);

        if relays.swatch {
            let swatch = "██".rgb(r, g, b);
            eprintln!("{} {}", swatch, hex.as_str().bold());
        }
        if relays.stdout {
            println!("{value}");
        }
        if relays.clipboard {
            clipboard_values.push(value);
        }
    }

    if relays.clipboard
        && !clipboard_values.is_empty()
        && let Err(e) = core::clipboard::set_text(&clipboard_values.join("\n"))
    {
        eprintln!("warning: clipboard relay failed: {e}");
        relay_failed = true;
    }

    flush_std();
    if relay_failed {
        std::process::exit(1);
    }
    Ok(())
}

/// `--pixel x,y` / `--pixels "a;b;c"` — ONE capture, N samples.
///
/// Zone 6: batch is ATOMIC — any out-of-bounds coord aborts with exit 2 and
/// no partial output (a batch with a bad coord is a malformed request;
/// fail-fast keeps stdout strictly 1:1 with input order).
/// Resolve any `PixelCoord::PhysicalDefaulted` entries (`--phys` without
/// explicit `N:` syntax) now that the canvas — and therefore tile count —
/// is known. Single-monitor canvas → silent promotion to `Physical(0, x, y)`.
/// Multi-monitor canvas → collect all offending coords and emit a single
/// stderr block with a `use N:X,Y` hint, then return Err. Caller decides
/// failure policy: atomic (`run_pixels` → exit 2) or resilient (`run_stdin`
/// → per-line warn+skip, calls `resolve_one_defaulted` instead).
fn resolve_defaulted_coords(
    coords: &[PixelCoord],
    canvas: &capture::PhysicalCanvas,
) -> Result<Vec<PixelCoord>, ()> {
    let tile_count = canvas.tiles.len();
    let ambiguous: Vec<(i32, i32)> = coords
        .iter()
        .filter_map(|c| match *c {
            PixelCoord::PhysicalDefaulted(x, y) if tile_count > 1 => Some((x, y)),
            _ => None,
        })
        .collect();
    if !ambiguous.is_empty() {
        eprintln!(
            "error: --phys without N: prefix is ambiguous on multi-monitor canvas \
             ({tile_count} monitors detected)"
        );
        for (x, y) in &ambiguous {
            eprintln!("       ambiguous coord: {x},{y}");
        }
        eprintln!(
            "help:  use N:X,Y syntax to specify a monitor (run `ie-r --monitors` \
             to list available indices)"
        );
        return Err(());
    }
    Ok(coords
        .iter()
        .map(|c| match *c {
            PixelCoord::PhysicalDefaulted(x, y) => PixelCoord::Physical(0, x, y),
            other => other,
        })
        .collect())
}

/// Resilient sibling for `--stdin`: resolve one coord or emit a per-line
/// warning and return None (caller skips the line). Mirrors `--stdin`'s
/// resilient OOB policy — bad coords don't poison the whole stream.
fn resolve_one_defaulted(
    coord: PixelCoord,
    canvas: &capture::PhysicalCanvas,
    line_num: usize,
) -> Option<PixelCoord> {
    match coord {
        PixelCoord::PhysicalDefaulted(x, y) => {
            if canvas.tiles.len() == 1 {
                Some(PixelCoord::Physical(0, x, y))
            } else {
                eprintln!(
                    "warning: line {line_num}: --phys without N: is ambiguous on \
                     multi-monitor canvas ({x},{y}) — skipped (use N:X,Y)"
                );
                None
            }
        }
        other => Some(other),
    }
}

pub fn run_pixels(coords: Vec<PixelCoord>, format_key: Option<String>, float_precision: Option<usize>, relays: RelaySet, average: Option<u32>, phys: bool) -> Result<()> {
    use core::config::Config;

    let mut config = Config::load_quiet();
    let key = format_key.unwrap_or_else(|| default_format_for_probe().to_string());
    let mut fmt = resolve_format(&config, &key)?;
    if let Some(p) = float_precision { fmt.prec = p; }

    let mut capturer = Capturer::new()?;
    let canvas = capturer.capture()?;
    // aim_radius = average.max(1)/2 — matches magnifier.rs convention
    // (side-length N → (2r+1)² area, where r = N/2; 1 → 0 → single pixel).
    let aim_radius = average.map(|n| n.max(1) as i32 / 2).unwrap_or(0);

    // Resolve PhysicalDefaulted now that the canvas (and tile count) is
    // known. Single-monitor → implicit monitor 0. Multi-monitor → atomic
    // failure with a helpful message (matches the `--pixels` OOB style:
    // any ambiguity aborts the whole batch, no partial output).
    let coords: Vec<PixelCoord> = match resolve_defaulted_coords(&coords, &canvas) {
        Ok(c) => c,
        Err(_) => std::process::exit(2),
    };

    // Sample each coord through its native space: Logical → sample_vector
    // (absolute-logical lookup, tile + scale conversion under the hood);
    // Physical → sample_in_tile_average (direct buffer read on the named
    // monitor). Both honour the same aim_radius semantics.
    let sampled: Vec<Option<u32>> = coords.iter().map(|c| match *c {
        PixelCoord::Logical(x, y) => {
            canvas.sample_vector(&[(x, y)], aim_radius).into_iter().next().flatten()
        }
        PixelCoord::Physical(idx, x, y) => {
            canvas.sample_in_tile_average(idx, x, y, aim_radius)
        }
        // resolve_defaulted_coords guarantees no PhysicalDefaulted reaches here.
        PixelCoord::PhysicalDefaulted(_, _) => unreachable!(),
    }).collect();

    let oob: Vec<PixelCoord> = coords
        .iter()
        .zip(&sampled)
        .filter(|(_, p)| p.is_none())
        .map(|(c, _)| *c)
        .collect();
    if !oob.is_empty() {
        for c in &oob {
            eprintln!("error: coordinates {} are out of bounds", c.as_input_string());
        }
        std::process::exit(2);
    }

    let mut relay_failed = false;
    let mut values = Vec::with_capacity(coords.len());
    for (coord, px) in coords.iter().copied().zip(sampled) {
        // unwrap safe: the atomic OOB check above guarantees every Some.
        // `phys` toggles the emit-side form (independent of input form).
        let display = crate::cli::render_coord(&canvas, coord, phys);
        values.push(emit_pixel(display, px.unwrap(), &fmt, &relays, &mut config, false));
    }

    if relays.clipboard && let Err(e) = core::clipboard::set_text(&values.join("\n")) {
        eprintln!("warning: clipboard relay failed: {e}");
        relay_failed = true;
    }
    if relays.history {
        config.save();
    }

    flush_std();
    if relay_failed {
        std::process::exit(1);
    }
    Ok(())
}

/// `--stdin` — coords from stdin.
///
/// **Default = SNAPSHOT**: ONE eager capture before reading any line; all
/// stdin lines sample against that single frame. Deterministic, ~17× cheaper
/// than live, matches the `--pixels` semantic for the streaming-input case.
///
/// `--realtime`/`--rt` opt-in: fresh capture per line (live screen). For
/// "watch a coord against the live screen over time"-style consumers.
///
/// Zone 6 (resilient stream): malformed/oob line → warn+skip+continue;
/// clean EOF → 0 even with skips. Zone 7: self-correlating `X,Y\tVALUE`.
/// Clipboard relay: under snapshot, joins all values like `--pixels -c`
/// (set once at end). Under `--realtime` it would be thrash → refused.
pub fn run_stdin(format_key: Option<String>, float_precision: Option<usize>, relays: RelaySet, realtime: bool, with_coords: bool, average: Option<u32>, phys: bool) -> Result<()> {
    use core::config::Config;
    use std::io::BufRead;

    if realtime && relays.clipboard {
        eprintln!("error: --clipboard is not supported with --stdin --realtime (per-line clipboard = thrash)");
        std::process::exit(2);
    }
    // aim_radius — same convention as run_pixels (side N → r = N/2).
    let aim_radius = average.map(|n| n.max(1) as i32 / 2).unwrap_or(0);

    // TTY hint: when stdin is a tty (no pipe), an interactive user typed
    // `ie-r --stdin` and the process would otherwise sit silent — looks
    // frozen. Print one informer to stderr; behaviour is unchanged.
    use std::io::IsTerminal;
    if std::io::stdin().is_terminal() {
        eprintln!(
            "reading coords from terminal; one per line as \"X,Y\" (Ctrl-D to end{}{})",
            if realtime { ", --realtime: fresh capture per line" } else { ", snapshot mode" },
            if with_coords { ", --with-coords: emit X,Y<tab>VALUE" } else { "" }
        );
    }

    let mut config = Config::load_quiet();
    let key = format_key.unwrap_or_else(|| default_format_for_probe().to_string());
    let mut fmt = resolve_format(&config, &key)?;
    if let Some(p) = float_precision { fmt.prec = p; }

    let mut capturer = Capturer::new()?; // warm bring-up — paid once

    // SNAPSHOT default: one capture before the loop; `--realtime` defers
    // capture into the loop (fresh per line).
    let snapshot = if realtime { None } else { Some(capturer.capture()?) };

    let mut wrote_history = false;
    let mut relay_failed = false;
    let mut clipboard_values: Vec<String> = Vec::new();

    let stdin = std::io::stdin();
    for (i, line) in stdin.lock().lines().enumerate() {
        let line = line?;
        let s = line.trim();
        if s.is_empty() {
            continue;
        }
        let coord = match crate::cli::parse_pixel_coords(s, phys) {
            Ok(c) => c,
            Err(e) => {
                eprintln!("warning: line {}: {e} — skipped", i + 1);
                continue;
            }
        };

        // Pick the canvas — snapshot's once-captured frame, or a fresh one.
        let fresh;
        let canvas: &capture::PhysicalCanvas = match &snapshot {
            Some(c) => c,
            None => {
                fresh = capturer.capture()?;
                &fresh
            }
        };
        // Resolve PhysicalDefaulted now that the canvas is known. Resilient
        // policy: skip+warn on ambiguous multi-monitor, continue with rest.
        let coord = match resolve_one_defaulted(coord, canvas, i + 1) {
            Some(c) => c,
            None => continue,
        };
        // Sample via native space for this coord. Logical → absolute-logical
        // lookup; Physical → direct buffer read on the named monitor.
        let px_opt = match coord {
            PixelCoord::Logical(x, y) => {
                canvas.sample_vector(&[(x, y)], aim_radius).into_iter().next().flatten()
            }
            PixelCoord::Physical(idx, x, y) => {
                canvas.sample_in_tile_average(idx, x, y, aim_radius)
            }
            // resolve_one_defaulted guarantees no PhysicalDefaulted reaches here.
            PixelCoord::PhysicalDefaulted(_, _) => unreachable!(),
        };
        match px_opt {
            Some(px) => {
                let display = crate::cli::render_coord(canvas, coord, phys);
                let value = emit_pixel(display, px, &fmt, &relays, &mut config, with_coords);
                wrote_history |= relays.history;
                if !realtime && relays.clipboard {
                    clipboard_values.push(value);
                }
            }
            None => eprintln!("warning: {} out of bounds — skipped", coord.as_input_string()),
        }
    }

    // Snapshot + --clipboard: join all sampled values and set once at the
    // end — same pattern as `--pixels -c` (one capture, one clipboard write).
    if !realtime
        && relays.clipboard
        && !clipboard_values.is_empty()
        && let Err(e) = core::clipboard::set_text(&clipboard_values.join("\n"))
    {
        eprintln!("warning: clipboard relay failed: {e}");
        relay_failed = true;
    }

    if wrote_history {
        config.save();
    }
    flush_std();
    if relay_failed {
        std::process::exit(1);
    }
    Ok(())
}
