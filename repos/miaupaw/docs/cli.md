# IE-R Command-Line Interface

Complete reference for `ie-r` invocations beyond the default daemon mode.

> `ie-r --help` always shows a colour-coded condensed version of this content.
> Use this document when you need full examples, configuration recipes,
> and platform notes.

---

## TL;DR

```bash
ie-r                          # Daemon (default): tray icon + global hotkey
ie-r --pick                   # Interactive: overlay → click → color → stdout
ie-r --pixel X,Y              # Probe: sample one screen pixel → stdout
ie-r --pixels "X,Y;X,Y;..."   # Probe: batch — one capture, N samples
ie-r --stdin                  # Probe: stream coords from stdin, sample each
ie-r --history                # Probe: dump saved color history → stdout
ie-r --monitors               # Probe: list canvas layout as TSV
```

Compose with `-c` (clipboard), `-s` (swatch in stderr), `-q` (mute stdout),
`--write-history` (append to saved history), `-f NAME` (format),
`--config PATH` (alternate config file), `-v` (verbose stderr logs).

---

## Three Mode Families

IE-R has **three orthogonal mode families**. The flag you start with picks
the family; everything else composes on top.

### 1. Daemon (default, no flags)

```bash
ie-r
```

Long-lived background process. Registers a system-tray icon (SNI on Linux,
Shell_NotifyIcon on Windows) and a global hotkey listener. When triggered
by the hotkey or a tray click, raises the magnifier overlay; you pick a
colour, the result lands in clipboard + history per your config.

Designed to be **launched once** at session start (via autostart, see the
main README). Stays resident until you quit it.

### 2. Interactive one-shot — `--pick`

```bash
ie-r --pick                   # → stdout (bare hex)
ie-r --pick -c                # → stdout + clipboard
COLOR=$(ie-r --pick)          # → capture into shell variable
```

Raises the overlay **without** registering a tray icon or grabbing the
hotkey (so it doesn't clash with a running daemon). You click — the
picked colour goes through the relay set (stdout by default; add flags
to fan out to clipboard / history / stderr swatch). Process exits.

- Esc / right-mouse-button: cancels, **exit 130** (the "user aborted"
  convention from `fzf` etc — distinguishes intentional cancel from
  failures and bad arguments).
- Does **not** disturb a running tray daemon — they live in separate
  surfaces; your tray pick still works during a one-shot.

### 3. Probe modes

Headless acquisition — no overlay, no daemon spin-up. Source → format →
relay → exit, fast (≈20-50ms typical on Wayland WLR/X11).

| Flag | What it samples |
|---|---|
| `--pixel X,Y` | One screen pixel at absolute logical coordinates |
| `--pixels "X,Y;X,Y;..."` | Batch: one capture, N samples (atomic) |
| `--stdin` | Streams coords from stdin, one `X,Y` per line |
| `--history` | Reads saved colour history from disk |
| `--monitors` | Lists monitor layout as TSV (diagnostic) |

Coordinates default to **absolute logical** — the compositor's own layout
space, the same numbers `grim`, `slurp` and `hyprctl cursorpos` speak
(virtual-screen coordinates on Windows). Whatever a neighbouring tool
reports plugs straight into `--pixel`, including the rows printed by
`ie-r --monitors`. On layouts where the compositor anchors the leftmost
monitor away from zero, coordinates simply follow the layout — negative
values are legal input.

**Per-tile physical opt-in** — same `--pixel`/`--pixels`/`--stdin` flags
accept the form `N:X,Y`, where `N` is the monitor index from
`ie-r --monitors`. Use it when you want lossless coords across fractional
scales (`X,Y` rounds at the logical↔physical boundary) or when scripts
already work in raw buffer space.

```bash
ie-r --pixel 100,200          # absolute logical (compositor space)
ie-r --pixel 0:100,200        # physical, monitor 0
cat coords.txt | ie-r --stdin # each line may use either form
```

**`--ph` as default coord space.** Setting `--ph` makes physical the
default for coords *without* explicit `N:` syntax, symmetric to its
output-side role. Resolution rules:

- **Explicit `N:X,Y` always wins** — flag is bypassed.
- **`X,Y` + `--ph` on single-monitor canvas** → implicit monitor 0
  (the only one available, no ambiguity).
- **`X,Y` + `--ph` on multi-monitor canvas** → ambiguous. `--pixel`/
  `--pixels` fail atomically (exit 2 with a `use N:X,Y` hint); `--stdin`
  skips the line with a stderr warning and continues.
- **Without `--ph`** → `X,Y` is always logical (current behaviour).

```bash
ie-r --pixel 100,200 --ph           # single-mon: monitor 0; multi-mon: exit 2
ie-r --pixel 0:100,200 --ph         # syntax wins, monitor 0 regardless
ie-r --ph --pixel 0:100,200         # flag order irrelevant (deferred parse)
```

The two systems are **interchangeable per coord** — a single `--stdin`
stream can mix logical and `N:X,Y` lines freely; each line is parsed
independently. The emit-side form (swatch lines and `--with-coords`
stdout) is determined by `--ph`, **not** by the per-line input form —
so the output stream is uniform even when the input was mixed.

```bash
# Input mixed, output uniformly logical (default):
printf "10,10\n0:50,50\n" | ie-r --stdin --with-coords -f hex
# 10,10     0x...
# 1970,50   0x...   ← physical converted to logical

# Same input, output uniformly physical:
printf "10,10\n0:50,50\n" | ie-r --stdin --with-coords --ph -f hex
# 0:10,10   0x...   ← logical converted to physical
# 0:50,50   0x...
```

**Per-mode caveats:**

- **`--pixels`** is **atomic**: any out-of-bounds coordinate aborts with
  exit 2 and **zero** partial stdout. A batch with a bad coord is a
  malformed request; fail-fast keeps stdout strictly 1:1 with input.

- **`--stdin`** is **resilient**: malformed/OOB lines emit a stderr
  warning and are skipped, clean EOF returns 0 even with skips. Output
  by default is bare `VALUE` per line; add `--with-coords` for
  self-correlating `X,Y<tab>VALUE` (useful when skips may misalign your
  consumer). `--realtime` / `--rt` opts into one capture per line (live
  screen sampling); default is **snapshot** (one capture, all lines
  against it — ~17× faster).

- **`--history`** reads the on-disk history file (no capture). `-n N`
  overrides the default count from `[history] show`; `-n 0` dumps all
  entries up to `[history] size`. Output is **always chronological**
  (oldest → newest, newest is the last line) regardless of the
  `[history] reverse_order` config flag (which only affects the tray
  menu, where orientation is host-dependent).

- **`--monitors`** dumps `index<TAB>name<TAB>WxH<TAB>X,Y<TAB>scale<TAB>transform`
  per monitor, preceded by a self-describing `# coords: absolute logical`
  header line (skip `#`-prefixed lines when parsing). Positions are
  absolute logical — each row's `X,Y` plugs straight into `--pixel`.
  Diagnostic primitive for shell scripts that need layout info — see
  `stuff/scan.rb` for a multi-monitor scanner that uses it.

---

## Output Format

Selected via `-f / --format <NAME>` from these templates:

| Name | Example | Notes |
|---|---|---|
| `html` | `#A1B2C3` | Probe default (script-stable, see below) |
| `hex` | `0xA1B2C3` | C-style |
| `rgb` | `161, 178, 195` | Decimal |
| `hsl` | `hsl(207, 23%, 70%)` | |
| `hsv` | `hsv(207, 17%, 76%)` | |
| `cmyk` | `cmyk(17%, 9%, 0%, 24%)` | |
| `float` | `0.63137255, 0.69803922, 0.76470588` | See `--float-precision` |
| `delphi` | `$00C3B2A1` | BGR byte order |
| `vb` | `&H00C3B2A1&` | Visual Basic |
| `long` | `12694721` | Decimal integer |

The exact token-replacement strings live in `[templates.copy]` of your
config — feel free to customise them (e.g. swap `rgb` for `rgba(...)`).

**Float precision** (default 20 decimals, from `[templates]
float_precision`): override per-invocation with `--float-precision N`,
e.g. `--pixel 100,100 -f float --float-precision 5` →
`0.40000, 0.40000, 0.40000`. Silently ignored for non-float formats.

### Box-filter sampling — `--average / --avg N`

By default, every coordinate samples **one** pixel. Pass `--average N`
(or its short alias `--avg N`) to take the mean colour of an **N×N**
window around each coordinate — a box-filter mean-pool, useful for
anti-aliased sampling of textured regions or for matching a decimation
step in downsampler scripts (see `stuff/scan.rb`).

| Mode | Behaviour with `--average N` |
|---|---|
| `--pixel` / `--pixels` / `--stdin` | center pixel must be in bounds; out-of-bounds neighbours silently excluded from the average. `N=1` ≡ omitted (single pixel, default). |
| `--pick` | overrides `[magnifier] aim_size` for both the visual aim-frame and the click-sample average — one knob, both consumers. The runtime `Alt+Scroll` (Resize aim area) starts from this baseline. |
| `--history` / `--monitors` | silent no-op (these modes don't sample pixels). |

```bash
ie-r --pixel 320,180 --avg 12 -f hex       # 12×12 mean colour at (320,180)
ie-r --pick --avg 5 -c                     # 5×5 aim frame; clipboard gets the averaged colour
cat coords.txt | ie-r --stdin --avg 3 -f hex   # 3×3 box-filter per coord
```

### Probe baseline = `html`

Probe modes (`--pixel`/`--pixels`/`--stdin`/`--history`) deliberately
**do not** read `[templates.selected]` from config — they always
default to `html` unless `-f` is given. Reason: scripts can't see the
overlay or tray menu to react if you change the selected format
interactively. The baseline is **script-deterministic**.

Daemon and `--pick` modes **do** read `[templates.selected]` — the user
is physically present and sees the result immediately.

---

## Relay Axis

The output side is an orthogonal set of relays — compose any combination
on any acquisition mode. Default = stdout only; everything else opt-in.

| Flag | Effect |
|---|---|
| `-c` / `--clipboard` | Copy the picked colour to the system clipboard |
| `-s` / `--swatch` | Print an ANSI true-colour swatch (`██ #...`) to stderr |
| `-q` / `--no-stdout` | Suppress stdout (use with `-c` for clipboard-only) |
| `--write-history` | Append picked colour(s) to the saved history file |
| `--ph` / `--physical` | Coord-space default for both input and output. **Output:** emit coords as `N:X,Y` (physical) instead of `X,Y` (logical) — applies to swatch lines and `--with-coords` stdout. **Input:** when `N:` syntax is absent, treat `X,Y` as physical — silently resolves to monitor 0 on single-mon, fails with a helpful error on multi-mon. Explicit `N:X,Y` syntax always wins. |

Compose freely:

```bash
ie-r --pick -c                    # pick → stdout + clipboard
ie-r --pick -q -c                 # pick → clipboard only (silent)
ie-r --pick -c --write-history    # pick → stdout + clipboard + history
ie-r --pixels "10,10;50,50" -q -s -f rgb --write-history
    # batch sample, mute stdout, show swatch in stderr, RGB format, append both to history
```

---

## Examples

### Quick scripting

```bash
# Grab one pixel into a shell variable
COLOR=$(ie-r --pick) || true   # || true survives Esc-cancel (exit 130)

# Get HTML colour at coordinate, append to history
ie-r --pixel 320,180 --write-history

# Dump all saved colours to a file, one per line
ie-r --history -n 0 -f hex > palette.txt

# Round-trip: read coords from file, sample each
cat coords.txt | ie-r --stdin -f hex > sampled.txt

# Lossless roundtrip via per-tile physical (preserves precision on
# fractional-scale monitors): pick, then re-sample at the same point.
ie-r --pick --with-coords --ph | cut -f1 | xargs -I{} ie-r --pixel {} -f hex
```

### Stream-based automation

```bash
# Skip-resilient stream with self-correlated output:
cat coords.txt | ie-r --stdin --with-coords -f hex
# 100,200<TAB>#A1B2C3
# 150,250<TAB>#F4F4F4
# warning: line 3: invalid coordinates 'bad' — skipped
# 300,400<TAB>#1A2B3C
# (no positional zip needed — each output line includes its coord)
```

### Multi-monitor diagnostic

```bash
ie-r --monitors
# 0   DP-2     2560x1440   1920,0   1.00   normal
# 1   eDP-1    1920x1200   0,0      2.00   normal

# Render a scan of monitor 0:
ruby stuff/scan.rb --monitor 0 --width 200
```

### Magnifier-mode preset (no clicking, no chrome)

```toml
# ~/.config/ie-r/magnifier.toml
[pick]
enabled = false              # clicks are no-op; Esc to close
[magnifier]
show_aim = false             # no centre crosshair
[hud]
show = false                 # no help panel
[system]
auto_cancel = 0              # never timeout on inactivity
cursor = "none"              # hide the OS cursor entirely
[font]
size = 0                     # collapse the HEX text box
```

```bash
ie-r --pick --config ~/.config/ie-r/magnifier.toml
# → overlay is a pure zoomed-pixel viewer. Esc to close.
```

Bind this to a hotkey alongside the normal one for instant zoom on
demand without disturbing your pick workflow.

---

## Configuration

### Default location

| OS | Path |
|---|---|
| Linux | `$XDG_CONFIG_HOME/ie-r/config.toml` or `~/.config/ie-r/config.toml` |
| Windows | Three-tier resolution — see below |

**Windows resolution chain** (first match wins):

1. **Next to the executable** — `<exe_dir>\config.toml`, used if that file
   already exists **or** if the exe's directory is writable. This is the
   portable-install path: drop `ie-r.exe` into any folder and the config
   lives next to it.
2. **`%HOME%`** — `%HOME%\.config\ie-r\config.toml`, used when `HOME` is
   defined (cross-platform shells, MSYS2/Git Bash, manually-set env).
3. **`%APPDATA%`** — `%APPDATA%\ie-r\config.toml`, the standard Windows
   user-data location. Default for installer-driven installs.

History file (`history.toml`) lives in `$XDG_STATE_HOME/ie-r/history.toml`
on Linux, or alongside `config.toml` on Windows (wherever the chain
resolved to). Both files are auto-created on first run; user comments in
the config are preserved across saves.

### `--config PATH` override

```bash
ie-r --config ~/.config/ie-r/alt.toml
```

Loads the named file as the authoritative config for this invocation.
The path must exist (typo → exit 2 with a clear error — won't silently
seed a new file). Works for any mode — daemon, `--pick`, probe. Daemon
saves runtime tweaks back into the override file, not the default.

### Key settings touched by the CLI

- `[templates] selected` — interactive format preference (daemon + `--pick`).
  Probe modes ignore this (see "Probe baseline = `html`" above).
- `[templates] float_precision` — decimal places for the `float` format;
  override per-invocation with `--float-precision N`.
- `[history] size` / `[history] show` — disk cap vs tray-menu display slice.
  `--history -n N` overrides the display slice per-invocation.
- `[pick] enabled` / `clipboard` / `write_history` — overlay click policy
  and default side-effects on tray-driven picks.
- `[magnifier] show_aim` — draw the centre crosshair in the lens.
- `[system] cursor` — `crosshair` (default) / `default` / `none`.
- `[system] auto_cancel` — overlay inactivity timeout in seconds (0 disables).

See the comments in `~/.config/ie-r/config.toml` itself for the full schema.

---

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | System/capture/relay failure (e.g. clipboard write failed) |
| `2` | Invalid arguments or out-of-bounds coordinate (in `--pixels` batch) |
| `130` | `--pick` cancelled by user (Esc/RMB) — convention from `fzf` et al |

Scripts that want to survive cancellation: `COLOR=$(ie-r --pick) || true`.

---

## Clipboard Persistence Notes

Linux clipboard protocols (X11 ICCCM, Wayland data-source) require the
*owner* process to stay alive to serve content requests. A short-lived CLI
exits immediately — the platform's *clipboard manager* normally rescues
content by grabbing it from us. IE-R's behaviour per backend:

- **Wayland** — shells out to `wl-copy` (from the `wl-clipboard` package)
  which forks a daemon to hold the selection. Falls back to direct
  `arboard` if `wl-copy` is missing — that path works on compositors
  with a built-in manager (GNOME / KDE) and fails on bare wlroots
  setups (Sway / Hyprland) without an external one.
- **X11** — holds the selection briefly (100ms) so any clipboard
  manager (klipper / parcellite / xsel-daemon) can harvest. Typical
  Linux installs ship one of these; if you've stripped them out,
  `-c` content won't survive the CLI exit.
- **Windows** — clipboard is global system state and persists across
  process exit by design. Works without any of the above contortions.

If `-c` doesn't survive your shell exit: install `wl-clipboard` on
Wayland or any clipboard manager on bare X11.

---

## Verbosity

`-v` / `--verbose` reveals INFO-tier stderr logs (capture timings,
backend selection, overlay events). Default in non-daemon CLI is the
**Normal** tier — only WARN and ERROR reach stderr.

Useful for diagnosing why a pick fails, which capture tier was used,
or what bounding box the multi-monitor canvas reports.

---

## Diagnostic Scripts

The `stuff/` directory ships two reference scripts that exercise the
CLI surface end-to-end:

- **`probe.rb`** — contract probe. Runs ~40 smoke tests across all
  acquisition + relay axes (`--pixel`/`--pixels`/`--stdin`/`--history`/
  `--monitors`/`--average`/physical `N:X,Y` coords/mutexes). Use as a
  regression gate after CLI changes: `ruby stuff/probe.rb` (set `IER_BIN`
  to point at your binary).
- **`scan.rb`** — ANSI half-block screen mosaic. Samples a monitor (or
  the whole canvas) via `--stdin`, renders it in the terminal.
  Diagnostic for capture pipeline behaviour on real layouts:
  `ruby stuff/scan.rb --monitor all --width 200`.

Both are user-facing examples of how to consume `ie-r` from a script.

---

