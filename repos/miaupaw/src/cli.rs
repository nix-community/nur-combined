//! CLI surface: argument parsing, mode definitions, relay axis, help text.
//!
//! Pure types + parser + presenter — no runtime side effects. The dispatcher
//! in `main.rs` consumes [`Mode`] and routes to either a probe runner (see
//! `probe.rs`) or a daemon dispatcher (still in `main.rs` next to platform
//! event loops).
//!
//! Naming note: «probe» replaces the older «headless» term across CLI-domain
//! surfaces (acquisition modes that bypass the overlay and talk straight to
//! stdout/clipboard/history). Wayland-level `connectors/wayland/headless.rs`
//! keeps its name — that's a different layer where «headless» is the
//! Wayland-domain technical term for a connection without a compositor
//! surface.

use anyhow::Result;
use lexopt::prelude::*;

use crate::core;

// Coord-parser and render_coord tests live in cli_tests.rs.
#[cfg(test)]
#[path = "cli_tests.rs"]
mod tests;

/// Where the resolved color is relayed. Orthogonal, composable axis:
/// default is stdout-only; every other relay is opt-in (explicit flag).
#[derive(Clone, Copy)]
pub struct RelaySet {
    pub stdout: bool,
    pub clipboard: bool,
    pub history: bool,
    pub swatch: bool,
}

impl Default for RelaySet {
    fn default() -> Self {
        Self { stdout: true, clipboard: false, history: false, swatch: false }
    }
}

/// Probe-input coordinate. Logical = absolute compositor space (default,
/// the same numbers grim/slurp/hyprctl speak; virtual-screen coords on
/// Windows). Physical = per-tile with a monitor-index tag, opt-in via the
/// `N:X,Y` syntax. PhysicalDefaulted = intermediate state when `--phys`
/// is set but `N:` is omitted; the monitor is resolved at runtime once the
/// canvas is known (single-monitor → 0, multi-monitor → error with help).
#[derive(Clone, Copy, Debug)]
pub enum PixelCoord {
    Logical(i32, i32),
    Physical(usize, i32, i32),
    PhysicalDefaulted(i32, i32),
}

impl PixelCoord {
    /// Reconstruct the CLI form for diagnostic output. `PhysicalDefaulted`
    /// shows as `?:X,Y` — the `?` marks "monitor not yet resolved".
    pub fn as_input_string(&self) -> String {
        match *self {
            PixelCoord::Logical(x, y) => format!("{x},{y}"),
            PixelCoord::Physical(idx, x, y) => format!("{idx}:{x},{y}"),
            PixelCoord::PhysicalDefaulted(x, y) => format!("?:{x},{y}"),
        }
    }
}

/// Render a coord in the form the user requested at emit time: `phys=true`
/// → `N:X,Y` (per-tile physical); `phys=false` → `X,Y` (absolute logical).
/// Identity when input form already matches; converts via canvas tile
/// lookup otherwise.
///
/// INVARIANT: every mode that prints coordinates goes through this fn —
/// the single exit point of the coord contract. CLI logical space IS the
/// compositor's absolute logical space (`tile.logical_pos` verbatim, the
/// grim/slurp convention; virtual-screen coords on Windows) — no origin
/// shift on either side. A future `--origin` key plugs in here and at
/// the input-resolve boundary, nowhere else. Off-canvas / mid-flight
/// conversion failures emit a stderr warning + fall back to the input
/// form so the caller sees the mix (no silent emit corruption).
pub fn render_coord(canvas: &core::capture::PhysicalCanvas, coord: PixelCoord, phys: bool) -> PixelCoord {
    if phys {
        match coord {
            PixelCoord::Logical(x, y) => canvas
                .logical_to_physical(x, y)
                .map(|(idx, px, py)| PixelCoord::Physical(idx, px, py))
                .unwrap_or_else(|| {
                    eprintln!(
                        "warning: cannot convert logical {x},{y} to physical (off-canvas?); emitting input form"
                    );
                    coord
                }),
            // Defensive: PhysicalDefaulted should be resolved before
            // render by the probe runner. If somehow we got here, fall
            // through unchanged.
            other => other,
        }
    } else {
        match coord {
            PixelCoord::Physical(idx, x, y) => canvas
                .physical_to_logical(idx, x, y)
                .map(|(lx, ly)| PixelCoord::Logical(lx, ly))
                .unwrap_or_else(|| {
                    eprintln!(
                        "warning: cannot convert physical {}:{},{} to logical (bad monitor index?); emitting input form",
                        idx, x, y
                    );
                    coord
                }),
            other => other,
        }
    }
}

/// `--pick` one-shot: raise the interactive overlay, user clicks, the picked
/// color(s) go through the relay set instead of the daemon's clipboard flow.
pub struct PickReq {
    pub format: Option<String>,
    /// Per-invocation override for `templates.float_precision`. None →
    /// take config default. Only meaningful when the active format uses
    /// `{rf}/{gf}/{bf}` tokens (i.e. `float`); silently ignored otherwise.
    pub float_precision: Option<usize>,
    pub relays: RelaySet,
    /// When true, stdout becomes self-correlating `X,Y\tVALUE` instead of
    pub with_coords: bool,
    /// Per-invocation N×N box-filter sampling size (1 = single pixel,
    /// the default). On the --pick path this overrides
    /// `config.magnifier.aim_size` for both the aim-frame visualisation
    /// and the click-sample averaging.
    pub average: Option<u32>,
    /// `--with-coords` output format. False (default) → emit LOGICAL
    /// coords `X,Y\tVALUE` matching `--pixel X,Y` input contract.
    /// True (opt-in via `--phys`) → emit per-tile physical with monitor
    /// tag: `monitor_idx:X,Y\tVALUE` — self-describing, lossless across
    /// fractional scales, roundtrips via `ie-r --pixel N:X,Y`.
    pub phys: bool,
}

/// Operating mode determined by CLI arguments.
pub enum Mode {
    /// Default: launch background daemon with tray and hotkeys.
    Daemon,
    /// Print help and exit.
    Help,
    /// Print version and exit.
    Version,
    /// Probe: one capture → sample N coords → format → relay(s) → exit.
    /// `--pixel x,y` is the n=1 case; `--pixels "a;b;c"` the batch.
    /// `float_precision`: per-invocation override for the float format
    /// precision; None → config default. Same semantics in all variants below.
    /// `average`: per-invocation N×N box-filter sample size (1 = single
    /// pixel, the default). Same semantics across probe + pick variants.
    /// `phys`: emit coord side (swatch line, `--with-coords` stdout) as
    /// `N:X,Y` instead of logical `X,Y`. Orthogonal to input form —
    /// input is auto-detected via `:` syntax independently. Identity
    /// when input form already matches the requested emit form;
    /// converts via canvas tile lookup otherwise.
    Pixel { coords: Vec<PixelCoord>, format: Option<String>, float_precision: Option<usize>, relays: RelaySet, average: Option<u32>, phys: bool },
    /// Probe streaming: coords from stdin.
    /// Default: ONE eager capture, all lines sample against it (snapshot).
    /// `realtime` = true: fresh capture per line (live screen, opt-in).
    /// `with_coords` = true: prepend `<coord>\t` to each output line for
    /// self-correlating output (useful when RESILIENT skip+warn may drop
    /// rows). Default = bare VALUE, symmetric with `--pick`.
    /// `phys`: same emit-side toggle as in Pixel.
    Stdin { format: Option<String>, float_precision: Option<usize>, relays: RelaySet, realtime: bool, with_coords: bool, average: Option<u32>, phys: bool },
    /// Interactive one-shot: raise the overlay, user clicks, relay → exit.
    /// `phys`: when true, `--with-coords` emits `monitor_idx:X,Y\tVALUE`
    /// (per-tile physical, lossless). Default → logical `X,Y\tVALUE`.
    Pick { format: Option<String>, float_precision: Option<usize>, relays: RelaySet, with_coords: bool, average: Option<u32>, phys: bool },
    /// Probe acquisition #5: read color history from disk → format → relay → exit.
    /// `limit = None` defers to `config.history.show`; `Some(0)` means "all".
    /// Output is always chronological (oldest → newest, newest is the last
    /// line) — natural for `| tail -n 1` and unambiguous across tray-host
    /// orientations. `reverse_order` config applies only to the tray menu.
    History { format: Option<String>, float_precision: Option<usize>, relays: RelaySet, limit: Option<usize> },
    /// Probe acquisition #6: read canvas monitor metadata → TSV → exit.
    /// Lists each monitor as `index<TAB>name<TAB>WxH<TAB>X,Y<TAB>scale`.
    /// Diagnostic primitive for shell scripts that need layout info
    /// (e.g. multi-monitor scan tools, geometry-aware automation).
    Monitors { relays: RelaySet },
    /// Capture screen → PNG → exit (Windows smoke test).
    #[cfg(windows)]
    CaptureTest,
}

/// Parses command-line arguments via lexopt.
/// Returns a Mode for dispatch in main().
pub fn parse_args() -> Result<(Mode, bool, Option<std::path::PathBuf>)> {
    let mut parser = lexopt::Parser::from_env();
    // Raw coord strings — parsed after the loop, once `phys` is final.
    // Flag order is unconstrained: `--pixel X,Y --phys` and `--phys --pixel X,Y`
    // must produce identical results.
    let mut coord_strs: Vec<String> = Vec::new();
    let mut stdin = false;
    let mut pick = false;
    let mut history_mode = false;
    let mut monitors_mode = false;
    let mut limit: Option<usize> = None;
    let mut realtime = false;
    let mut with_coords = false;
    let mut phys = false;
    let mut format: Option<String> = None;
    let mut float_precision: Option<usize> = None;
    let mut average: Option<u32> = None;
    let mut relays = RelaySet::default();
    let mut verbose = false;
    let mut config_override: Option<std::path::PathBuf> = None;

    while let Some(arg) = parser.next()? {
        match arg {
            Short('h') | Long("help") => return Ok((Mode::Help, verbose, config_override)),
            Short('V') | Long("version") => return Ok((Mode::Version, verbose, config_override)),
            Short('v') | Long("verbose") => verbose = true,
            Long("config") => {
                let val: String = parser.value()?.parse()?;
                config_override = Some(std::path::PathBuf::from(val));
            }
            Long("pixel") => {
                let val: String = parser.value()?.parse()?;
                coord_strs.push(val);
            }
            Long("pixels") => {
                let val: String = parser.value()?.parse()?;
                for seg in val.split(';').filter(|s| !s.trim().is_empty()) {
                    coord_strs.push(seg.to_string());
                }
            }
            Long("stdin") => stdin = true,
            Long("pick") => pick = true,
            // `--history` is an ACQUISITION mode (read disk), not a relay.
            // The previous write-relay `--history` is now `--write-history`.
            // Verb-default = read (like `ls`, `git log`); write is explicit.
            Long("history") => history_mode = true,
            Long("monitors") => monitors_mode = true,
            Short('n') => {
                let val: String = parser.value()?.parse()?;
                let n: usize = val.parse().map_err(|_| {
                    anyhow::anyhow!("-n expects a non-negative integer (got '{}')", val)
                })?;
                limit = Some(n);
            }
            Long("realtime") | Long("rt") => realtime = true,
            Long("with-coords") | Long("coords") => with_coords = true,
            // Flips both directions of the dual-mode coord axis:
            //  · `--pick --with-coords --ph` → emit `N:X,Y\tVALUE` (per-tile
            //    physical, lossless across fractional scales).
            //  · `--pixel X,Y --ph` → input default becomes physical
            //    (single-mon → monitor 0; multi-mon → must use N:X,Y).
            // Canonical short = `--ph`, canonical long = `--physical`.
            // `--phys` kept as an undocumented alias (was the short form
            // before; alias avoids breaking habits / pinned references).
            // Default off → logical (absolute compositor space, grim/slurp).
            Long("ph") | Long("phys") | Long("physical") => phys = true,
            Short('f') | Long("format") => {
                format = Some(parser.value()?.parse()?);
            }
            Long("float-precision") => {
                let val: String = parser.value()?.parse()?;
                let n: usize = val.parse().map_err(|_| {
                    anyhow::anyhow!("--float-precision expects a non-negative integer (got '{}')", val)
                })?;
                float_precision = Some(n);
            }
            // N×N box-filter sample size — orthogonal modifier on the
            // acquisition side. Applies to --pixel/--pixels/--stdin (passed
            // as aim_radius into sample_vector) and --pick (overrides
            // magnifier.aim_size at overlay init). 1 = single pixel.
            // Silently ignored by --history/--monitors (no sampling).
            Long("average") | Long("avg") => {
                let val: String = parser.value()?.parse()?;
                let n: u32 = val.parse().map_err(|_| {
                    anyhow::anyhow!("--average expects a positive integer ≥ 1 (got '{}')", val)
                })?;
                if n == 0 {
                    anyhow::bail!("--average must be ≥ 1 (got 0)");
                }
                average = Some(n);
            }
            // Relay axis — additive on top of the stdout default.
            Long("stdout") => relays.stdout = true,
            Short('q') | Long("quiet") | Long("no-stdout") => relays.stdout = false,
            Short('c') | Long("clipboard") => relays.clipboard = true,
            Long("write-history") => relays.history = true,
            Short('s') | Long("swatch") => relays.swatch = true,
            #[cfg(windows)]
            Long("capture-test") => return Ok((Mode::CaptureTest, verbose, config_override)),
            _ => return Err(arg.unexpected().into()),
        }
    }

    // Resolve raw coord strings now that `phys` is final — flag order doesn't
    // matter, syntax (`N:X,Y`) always wins over the flag default.
    let coords: Vec<PixelCoord> = coord_strs
        .iter()
        .map(|s| parse_pixel_coords(s, phys))
        .collect::<Result<_>>()?;

    if [stdin, pick, history_mode, monitors_mode, !coords.is_empty()].iter().filter(|&&v| v).count() > 1 {
        anyhow::bail!("--pick, --stdin, --history, --monitors and --pixel/--pixels are mutually exclusive");
    }
    if monitors_mode {
        return Ok((Mode::Monitors { relays }, verbose, config_override));
    }
    if history_mode {
        return Ok((Mode::History { format, float_precision, relays, limit }, verbose, config_override));
    }
    if pick {
        return Ok((Mode::Pick { format, float_precision, relays, with_coords, average, phys }, verbose, config_override));
    }
    if stdin {
        return Ok((Mode::Stdin { format, float_precision, relays, realtime, with_coords, average, phys }, verbose, config_override));
    }
    if !coords.is_empty() {
        return Ok((Mode::Pixel { coords, format, float_precision, relays, average, phys }, verbose, config_override));
    }

    Ok((Mode::Daemon, verbose, config_override))
}

/// Accepts `"N:X,Y"` (explicit physical syntax, always wins) and `"X,Y"`.
/// For the latter, `phys_default = true` (the `--phys` flag) produces a
/// PhysicalDefaulted variant that the runner resolves once the canvas is
/// captured: single-monitor → Physical(0, x, y) silently; multi-monitor
/// → error with a `use N:X,Y` hint.
pub fn parse_pixel_coords(s: &str, phys_default: bool) -> Result<PixelCoord> {
    // Detect physical-coord syntax: `N:X,Y`. The `:` separator is unique —
    // no logical coord can contain it. Syntax always wins over the flag.
    if let Some((tag_part, xy_part)) = s.split_once(':') {
        let monitor_idx: usize = tag_part.trim().parse().map_err(|_| {
            anyhow::anyhow!("expected non-negative monitor index before ':' (got '{}')", tag_part)
        })?;
        let (x, y) = parse_xy_pair(xy_part)?;
        return Ok(PixelCoord::Physical(monitor_idx, x, y));
    }
    let (x, y) = parse_xy_pair(s)?;
    if phys_default {
        Ok(PixelCoord::PhysicalDefaulted(x, y))
    } else {
        Ok(PixelCoord::Logical(x, y))
    }
}

fn parse_xy_pair(s: &str) -> Result<(i32, i32)> {
    let parts: Vec<&str> = if s.contains(',') {
        s.split(',').map(|p| p.trim()).collect()
    } else {
        s.split_whitespace().collect()
    };
    if parts.len() != 2 {
        anyhow::bail!("expected X,Y coordinates (e.g. 100,200)");
    }
    let x: i32 = parts[0].parse().map_err(|_| anyhow::anyhow!("invalid X coordinate: '{}'", parts[0]))?;
    let y: i32 = parts[1].parse().map_err(|_| anyhow::anyhow!("invalid Y coordinate: '{}'", parts[1]))?;
    Ok((x, y))
}

/// Prints help text: a narrative about hotkeys, signals, and config.
pub fn print_help() {
    use core::terminal::Styled;

    let version = env!("CARGO_PKG_VERSION");
    let default_hotkey = core::config::Config::default_hotkey();
    let config_path = core::config::Config::get_config_path();

    println!("{} {}", "Instant Eyedropper Reborn".cyan().bold(), version.gray());
    println!("{}", "Click → Color → Done. <10ms.".gray());
    println!();
    //    USAGE: one-line ready-to-copy commands.
    //    Order = mental hierarchy: daemon → interactive → probe.
    //    Mode labels are colour-coded (green/blue/cyan) so the eye anchors
    //    on which family each row belongs to.
    println!("{}", "USAGE:".bold());
    println!("  ie-r                          {} tray icon + hotkey listener", "Daemon:".green().bold());
    println!("  ie-r --pick                   {} click a pixel → stdout", "Interactive:".blue().bold());
    println!("  ie-r --pixel X,Y              {} sample one pixel → stdout", "Probe:".cyan().bold());
    println!("  ie-r --pixels \"X,Y;X,Y;...\"   {} batch — one capture, N samples", "Probe:".cyan().bold());
    println!("  ie-r --stdin                  {} stream coords from stdin", "Probe:".cyan().bold());
    println!("  ie-r --history                {} dump saved color history", "Probe:".cyan().bold());
    println!("  ie-r --monitors               {} list monitor layout (TSV)", "Probe:".cyan().bold());
    println!("  ie-r --help                   Show this help");
    println!("  ie-r --version                Show version");
    println!();

    //    MODES: what each mode does semantically. Per-mode caveats live
    //    inside their card — they don't float across blocks.
    println!("{}", "MODES:".bold());
    println!("  {}", "Daemon (default, no flags):".green().bold());
    println!("    Long-lived background process. Tray icon + global hotkey listener.");
    println!("    Triggers an overlay on hotkey/tray-click for an interactive pick.");
    println!();
    println!("  {}", "Interactive (--pick):".blue().bold());
    println!("    One-shot. Raises the overlay; click → color via relays, exit 0.");
    println!("    Esc/RMB cancels → exit 130. Does NOT disturb a running tray daemon.");
    println!();
    println!("  {}", "Probe (--pixel / --pixels / --stdin / --history / --monitors):".cyan().bold());
    println!("    No daemon, no overlay. Direct: source → format → relays → exit.");
    println!("    Coords are absolute LOGICAL by default — compositor space, the same");
    println!("    numbers grim/slurp/hyprctl speak (virtual-screen coords on Windows).");
    println!("    Opt-in PHYSICAL per-tile with `N:X,Y` syntax (N = monitor index");
    println!("    from --monitors).");
    println!();
    println!("    --pixels:   atomic — any out-of-bounds aborts (exit 2).");
    println!("    --stdin:    snapshot by default (ONE capture / N lines); --realtime/");
    println!("                --rt opts into fresh capture per line.");
    println!("    --history:  reads disk (no capture). -n N overrides config.history.show");
    println!("                (-n 0 = all up to history.size). Chronological — newest is");
    println!("                the last line.");
    println!("    --monitors: lists canvas layout — `index<TAB>name<TAB>WxH<TAB>X,Y<TAB>scale`");
    println!("                (absolute logical dims/position — plugs straight into --pixel).");
    println!("                A `# coords:` header names the space. Diagnostic primitive.");
    println!();

    //    OPTIONS: compose across modes; flag→mode hint in parens.
    //    Default = stdout only; everything else is additive.
    println!("{}", "OPTIONS:".bold().to_string() + &"  (compose across modes; default = stdout only)".gray());
    let opts: &[(&str, &str)] = &[
        ("-f, --format <NAME>", "hex rgb hsl hsv cmyk html float delphi vb long"),
        ("    --float-precision <N>", "(`-f float` only) decimals per channel; overrides config"),
        ("    --avg / --average <N>", "(probe/pick) N×N box-filter sampling; 1=single px (default)"),
        ("-c, --clipboard",     "Also copy to the system clipboard"),
        ("    --write-history", "Also append picked color(s) to saved history"),
        ("-s, --swatch",        "Also print an ANSI swatch to stderr"),
        ("-q, --no-stdout",     "Suppress stdout (e.g. clipboard-only)"),
        ("-n <N>",              "(--history) emit N items (0 = all up to history.size)"),
        ("    --rt / --realtime", "(--stdin) fresh capture per line, live screen"),
        ("    --with-coords",    "(--pick / --stdin) emit X,Y<tab>VALUE instead of bare VALUE"),
        ("    --ph / --physical", "physical coord-space (input + emit): N:X,Y syntax, monitor-tagged"),
        ("    --config <PATH>",  "Use PATH as the config file (presets, magnifier mode, etc)"),
        ("-v, --verbose",        "Show INFO-tier stderr logs (capture, overlay, hints)"),
    ];
    let opt_w = opts.iter().map(|(k, _)| k.chars().count()).max().unwrap_or(0);
    for (key, desc) in opts {
        println!("  {}  {}", format!("{:<width$}", key, width = opt_w).bright_yellow(), desc);
    }
    println!();
    println!("  {}  Exit codes:  0 ok · 1 fail · 2 bad args/oob · 130 pick cancelled", "•".bright_red());
    println!();

    //    EXAMPLES: composition recipes — how the axes stack in practice.
    //    Each example shows 3+ orthogonal axes in action.
    println!("{}", "EXAMPLES:".bold().to_string() + &"  (composition recipes — how the axes stack)".gray());
    println!();
    println!("  {}", "ie-r --pick --config ~/.config/ie-r/magnifier.toml".blue().bold());
    println!("    Point --config at any TOML file you've assembled — same schema,");
    println!("    your choice of toggles. A preset with [pick] enabled=false +");
    println!("    [magnifier] show_aim=false + [hud] show=false morphs the overlay");
    println!("    into a read-only magnifier (Esc closes).");
    println!();
    println!("  {}", "COLOR=$(ie-r --pick)".blue().bold());
    println!("    Capture a single pick into a shell variable (stdout-only by default).");
    println!("    Exit 0 on success, 130 on Esc cancel — append `|| true`");
    println!("    if the script should survive cancellation.");
    println!();
    println!("  {}", "ie-r --pixels \"100,100;350,20\" -q -s -f rgb --write-history".cyan().bold());
    println!("    Batch sample two coords, format as RGB, mute stdout, show ANSI");
    println!("    swatches in stderr, append both colors to saved history.");
    println!();
    println!("  {}", "cat coords.txt | ie-r --stdin -f hex > sampled.txt".cyan().bold());
    println!("    Pipe a list of `X,Y` lines from a file, sample each against a");
    println!("    single snapshot (default), emit bare hex per line into another");
    println!("    file. Add --with-coords if the input may have skipped/invalid");
    println!("    lines (preserves correlation via X,Y<tab>HEX).");
    println!();
    println!("  {}", "ie-r --history -n 0 -f hex > palette.txt".cyan().bold());
    println!("    Dump ALL saved history (-n 0) as plain hex into a file — backup");
    println!("    or restore source. Round-trips with `cat palette.txt | ie-r --stdin`.");
    println!();
    println!("{}", "ACTIVATION:".bold());
    println!("  IE-R runs as a background daemon. To pick a color, use one of:");
    println!();
    #[cfg(unix)]
    {
        println!("  {}  Click the tray icon", "•".cyan());
        println!("  {}  Press the global hotkey (X11/Windows, default: {})", "•".cyan(), default_hotkey.yellow());
        println!("  {}  Send SIGUSR1: {}", "•".cyan(), "pkill -SIGUSR1 ie-r".green());
        println!("  {}  Send SIGUSR2 to open the menu: {}", "•".cyan(), "pkill -SIGUSR2 ie-r".green());
        println!();
        println!("  {}", "Wayland compositors block X11 global hotkeys.".gray());
        println!("  {}", "Bind SIGUSR1 to your compositor's shortcut instead:".gray());
        println!();
        println!("  {}  bind = SUPER SHIFT, P, exec, pkill -SIGUSR1 ie-r", "Hyprland:".yellow());
        println!("  {}      bindsym $mod+Shift+p exec pkill -SIGUSR1 ie-r", "Sway:".yellow());
    }
    #[cfg(windows)]
    {
        println!("  {}  Click the tray icon", "•".cyan());
        println!("  {}  Press the global hotkey (default: {})", "•".cyan(), default_hotkey.yellow());
    }
    println!();
    println!("{}", "CONTROLS (while active):".bold());
    let controls: &[(&str, &str)] = &[
        ("LMB / Enter",     "Pick color → clipboard"),
        ("RMB / Esc",       "Cancel"),
        ("MMB / Space",     "Pick color → stash (serial picks)"),
        ("Arrows",          "Move 1px at a time"),
        ("Shift+←↑↓→",      "Jump to next distinct color"),
        ("1..0",            "Switch color format (1=HTML, 2=Hex, ...0=Long)"),
        ("Scroll",          "Zoom in/out"),
        ("Shift+Scroll",    "Change magnifier size"),
        ("Ctrl+Scroll",     "Change font size"),
        ("Alt+Scroll",      "Resize aim area (average color)"),
    ];
    let max_w = controls.iter().map(|(k, _)| k.chars().count()).max().unwrap_or(0);
    for (key, desc) in controls {
        let padded = format!("{:<width$}", key, width = max_w);
        println!("  {}  {}", padded.yellow(), desc);
    }
    println!();
    // Both paths are pure resolvers — they don't create or read the files.
    // Until the first pick, neither file exists; a gray marker calls that out
    // so a fresh installer doesn't worry about a missing path.
    let history_path = core::config::Config::get_history_path();
    let cfg_marker = if config_path.exists() { String::new() } else { "  (will be created on first pick)".gray() };
    let hist_marker = if history_path.exists() { String::new() } else { "  (will be created on first pick)".gray() };
    println!("{}", "CONFIG & HISTORY:".bold());
    println!("  {}{}", config_path.display().to_string().magenta(), cfg_marker);
    println!("  {}{}", history_path.display().to_string().magenta(), hist_marker);
    println!();
    println!("  All visual settings, hotkeys, templates, and physics are configurable");
    println!("  in config.toml — hot-reloaded on each pick, comments preserved on save.");
    println!("  history.toml is auto-managed via the [history] section above.");
    println!();
    println!("{}", "MORE INFO:".bold());
    println!("  {} https://instant-eyedropper.com", "Home:".gray());
    println!("  {} https://github.com/miaupaw/ie-r", "Repo:".gray());
}
