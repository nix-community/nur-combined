#!/bin/sh
# Wrapper script that runs `claude /usage` via expect to handle the
# interactive TUI, parses the output, and emits clean JSON on a single line.
# Must run from a trusted workspace directory.

cd "$HOME/universe" || cd "$HOME" || exit 1

# Ensure claude is in PATH (may not be when running as a systemd service)
for p in "$HOME/.nix-profile/bin" /etc/profiles/per-user/"${USER:-root}"/bin /run/current-system/sw/bin; do
    if [ -x "$p/claude" ]; then
        export PATH="$p:$PATH"
        break
    fi
done

RAW=$(timeout 30 @expect@ -c '
    log_user 1
    spawn claude --permission-mode default --effort medium
    # Wait for the prompt to be ready
    sleep 4
    send "/usage\r"
    # Wait for the usage panel to fully render
    sleep 8
    # Send Escape then Ctrl+C to exit
    send "\x1b"
    sleep 0.5
    send "\x03"
    expect eof
' 2>&1)

EXIT_CODE=$?
if [ "$EXIT_CODE" -ne 0 ]; then
    printf '{"session":{"percentUsed":0,"resetsAt":"error"},"weekAll":{"percentUsed":0,"resetsAt":"error"},"weekSonnet":{"percentUsed":0,"resetsAt":"error"}}\n'
    exit 0
fi

# Strip ANSI escape sequences and non-printable chars
CLEAN=$(printf '%s' "$RAW" | sed 's/\x1b\[[^a-zA-Z]*[a-zA-Z]//g' | tr -cd '[:print:]\n' | tr -s ' ')

# Extract percentages
# After ANSI stripping, spaces may be missing, e.g.:
#   "Current session 25%usedReses8pm (Europe/Rome)"
#   "Currentweek(allmodels)"  /  " 16%used"  /  "ResetsMar20,7am(Europe/Rome)"
SESSION_PCT=$(printf '%s\n' "$CLEAN" | grep -oP 'Current\s*session\s*\K\d+(?=%)' | head -1)
WEEK_ALL_PCT=$(printf '%s\n' "$CLEAN" | grep -A2 'week.*all\s*models' | grep -oP '\d+(?=%\s*used)' | head -1)
WEEK_SONNET_PCT=$(printf '%s\n' "$CLEAN" | grep -A2 'week.*Sonnet\s*only' | grep -oP '\d+(?=%\s*used)' | head -1)

# Extract reset times
# After stripping, "Resets" may appear as "Reses" or "Resets" depending on rendering
# Use Rese[ts]* to match any variant, then capture everything after it
SESSION_RESET=$(printf '%s\n' "$CLEAN" | grep 'Current\s*session' | grep -oP 'Rese[ts]*\K\S.*' | head -1)
WEEK_RESET=$(printf '%s\n' "$CLEAN" | grep -A3 'week.*all\s*models' | grep -oP 'Rese[ts]*\K\S.*' | head -1)

# Default to 0 if not found
SESSION_PCT=${SESSION_PCT:-0}
WEEK_ALL_PCT=${WEEK_ALL_PCT:-0}
WEEK_SONNET_PCT=${WEEK_SONNET_PCT:-0}
SESSION_RESET=${SESSION_RESET:-"unknown"}
WEEK_RESET=${WEEK_RESET:-"unknown"}

printf '{"session":{"percentUsed":%d,"resetsAt":"%s"},"weekAll":{"percentUsed":%d,"resetsAt":"%s"},"weekSonnet":{"percentUsed":%d,"resetsAt":"%s"}}\n' \
  "$SESSION_PCT" "$SESSION_RESET" "$WEEK_ALL_PCT" "$WEEK_RESET" "$WEEK_SONNET_PCT" "$WEEK_RESET"
