# bash
# Dev-shell banner — a dashboard, after the neighbours (prizm, vikno): on entry
# you see whether the binaries are fresh, whether the daemon is up, and which
# capture tier this session will get.
#
# Everything goes to STDERR. Not paranoia — measured twice: direnv routes hook
# output to stderr on its own, but `nix develop --command` leaks it into stdout,
# so `$(nix develop -c cargo metadata)` comes back with the banner glued to the
# front and the JSON unparseable. The brace group holds the redirect for the
# whole block. IER_QUIET=1 silences it.
#
# Cheap probes only — this runs on every cd into the tree: stat, pgrep, env
# vars, one rustc. No captures, no network, no git log.
[ -n "${IER_QUIET:-}" ] || {
    off='\033[0m'; dim='\033[2m'; bold='\033[1m'
    cyan='\033[1;36m'; mag='\033[1;35m'
    ok='\033[32m✓\033[0m'; no='\033[2m·\033[0m'
    warn='\033[33m⚠\033[0m'; live='\033[32m●\033[0m'

    root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

    # A binary is "stale" when its own sources changed after it was linked.
    # Compared against file times, not git: binaries are built before the
    # commit, so a commit timestamp would mark a fresh binary as old. Catches
    # uncommitted edits too — which is exactly when you forget to rebuild.
    bin() {
        local f="$root/$1" label=$2 note=$3
        if [ ! -x "$f" ]; then
            printf "  $no %-14s ${dim}not built — %s${off}\n" "$label" "$note"
            return
        fi
        local mark=$ok tail=""
        if [ -n "$(cd "$root" && find src build.rs Cargo.toml Cargo.lock -newer "$f" -print -quit 2>/dev/null)" ]; then
            mark=$warn; tail="stale — sources moved on"
        fi
        printf "  $mark %-14s %s  ${dim}%s${off}\n" "$label" "$(date -r "$f" +'%d.%m %H:%M')" "$tail"
    }

    printf '\n'
    # ⦿ is the icon itself reduced to one glyph: a picked pixel inside the
    # aperture ring. Monochrome on purpose — it takes the accent colour below
    # instead of whatever an emoji font decides, and stays single-cell-ish.
    printf "  ${cyan}⦿  IE-R${off} :: click ${mag}→${off} colour ${mag}→${off} done, under 10 ms\n"
    printf "  ${dim}────────────────────────────────────────────────${off}\n"

    printf "  ${bold}Binaries:${off}\n"
    bin target/release/ie-r "release"  "just build"
    bin target/debug/ie-r   "debug"    "just probe — probe.rb wants this one"

    printf "\n  ${bold}Session:${off}\n"
    if [ -n "${WAYLAND_DISPLAY:-}" ]; then
        printf "  $live %-14s ${dim}%s — tier 1 wlr / tier 2 kwin / portal${off}\n" \
            "wayland" "${XDG_CURRENT_DESKTOP:-unknown compositor}"
    elif [ -n "${DISPLAY:-}" ]; then
        printf "  $live %-14s ${dim}native XCB root capture${off}\n" "x11"
    else
        printf "  $warn %-14s ${dim}no display — probes and overlay will decline${off}\n" "headless"
    fi

    if pgrep -x ie-r >/dev/null 2>&1; then
        printf "  $live %-14s ${dim}tray up — pkill -SIGUSR1 ie-r to pick${off}\n" "daemon"
    else
        printf "  $no %-14s ${dim}not running — just run${off}\n" "daemon"
    fi

    printf "\n  ${bold}Toolchain:${off}\n"
    printf "  $ok %-14s ${dim}must match dtolnay stable in CI${off}\n" \
        "$(rustc --version 2>/dev/null | cut -d' ' -f2 || echo '?')"
    printf '\n'
} >&2
