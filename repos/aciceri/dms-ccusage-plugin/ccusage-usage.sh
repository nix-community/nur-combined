#!/bin/sh
# Wrapper script that runs `claude /usage` in a virtual terminal,
# parses the output, and emits clean JSON on a single line.
# Must run from a trusted workspace directory.

cd "$HOME/universe" || cd "$HOME" || exit 1

RAW=$(timeout 20 script -qc "echo '/usage' | @claude@ --permission-mode default" /dev/null 2>&1)

# Strip ANSI escape sequences and non-printable chars
CLEAN=$(printf '%s' "$RAW" | sed 's/\x1b\[[^a-zA-Z]*[a-zA-Z]//g' | tr -cd '[:print:]\n' | tr -s ' ')

# Extract percentages in order: session, week all, week sonnet
SESSION_PCT=$(printf '%s\n' "$CLEAN" | grep -oP 'Current session.*?\K\d+(?=%)' | head -1)
WEEK_ALL_PCT=$(printf '%s\n' "$CLEAN" | grep -A2 'week (all models)' | grep -oP '\d+(?=% used)' | head -1)
WEEK_SONNET_PCT=$(printf '%s\n' "$CLEAN" | grep -A2 'week .Sonnet only.' | grep -oP '\d+(?=% used)' | head -1)

# Extract reset times
SESSION_RESET=$(printf '%s\n' "$CLEAN" | grep 'Current session' | grep -oP 'Rese[ts]*\K.*' | head -1 | sed 's/^ *//')
WEEK_RESET=$(printf '%s\n' "$CLEAN" | grep -A3 'week (all models)' | grep -oP 'Resets? \K.*' | head -1)

# Default to 0 if not found
SESSION_PCT=${SESSION_PCT:-0}
WEEK_ALL_PCT=${WEEK_ALL_PCT:-0}
WEEK_SONNET_PCT=${WEEK_SONNET_PCT:-0}
SESSION_RESET=${SESSION_RESET:-"unknown"}
WEEK_RESET=${WEEK_RESET:-"unknown"}

printf '{"session":{"percentUsed":%d,"resetsAt":"%s"},"weekAll":{"percentUsed":%d,"resetsAt":"%s"},"weekSonnet":{"percentUsed":%d,"resetsAt":"%s"}}\n' \
  "$SESSION_PCT" "$SESSION_RESET" "$WEEK_ALL_PCT" "$WEEK_RESET" "$WEEK_SONNET_PCT" "$WEEK_RESET"
