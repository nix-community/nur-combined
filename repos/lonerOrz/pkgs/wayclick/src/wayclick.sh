#!/usr/bin/env bash
set -euo pipefail

APP_NAME="wayclick"
CONFIG_ENABLE_TRACKPADS="false"

BASE_DIR="$HOME/.cache/wayclick"
RUNNER_SCRIPT="${WAYCLICK_RUNNER}"
CONFIG_DIR="$HOME/.config/wayclick"

cleanup() {
    tput cnorm 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# Root check
if [[ $EUID -eq 0 ]]; then
    echo "Do not run as root"
    exit 1
fi

# Toggle
if pgrep -f "$RUNNER_SCRIPT" >/dev/null; then
    pkill -f "$RUNNER_SCRIPT"
    notify-send "WayClick" "Disabled" 2>/dev/null || true
    exit 0
fi

# Permission check
if ! groups | grep -q '\binput\b'; then
    notify-send "WayClick" "User not in input group" 2>/dev/null || true
    exit 1
fi

# Config check
if [[ ! -f "$CONFIG_DIR/config.json" ]]; then
    notify-send "WayClick" "Missing ~/.config/wayclick/config.json"
    exit 1
fi

notify-send "WayClick" "Enabled" 2>/dev/null || true

ENABLE_TRACKPADS="$CONFIG_ENABLE_TRACKPADS" \
  "$PYTHON" -O "$RUNNER_SCRIPT" "$CONFIG_DIR"
