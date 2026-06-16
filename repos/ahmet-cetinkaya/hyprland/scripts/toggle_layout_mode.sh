#!/bin/bash

CONFIG_DIR="/home/ac/Configs/hyprland"
SYMLINK_PATH="$CONFIG_DIR/windowrules.current_mode.conf"
STATE_FILE="/tmp/hypr_mode"

# Set initial state if the state file doesn't exist
if [ ! -f "$STATE_FILE" ]; then
  echo "tiled" > "$STATE_FILE"
fi

# Read the current mode
CURRENT_MODE=$(cat "$STATE_FILE")

if [ "$CURRENT_MODE" == "tiled" ]; then
  # Switch to Free Mode
  ln -sf "$CONFIG_DIR/windowrules.free.conf" "$SYMLINK_PATH"
  echo "free" > "$STATE_FILE"
  notify-send "Hyprland Layout" "Switched to Free Mode" -i "window-new"
else
  # Switch to Tiled Mode
  ln -sf "$CONFIG_DIR/windowrules.tile.conf" "$SYMLINK_PATH"
  echo "tiled" > "$STATE_FILE"
  notify-send "Hyprland Layout" "Switched to Tiled Mode" -i "view-grid"
fi

hyprctl reload
