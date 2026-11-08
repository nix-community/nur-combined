#!/bin/bash

# Get active window info in JSON format
WINDOW_INFO=$(hyprctl -j activewindow)

# Extract details using jq
TITLE=$(echo "$WINDOW_INFO" | jq -r '.title')
CLASS=$(echo "$WINDOW_INFO" | jq -r '.class')
PID=$(echo "$WINDOW_INFO" | jq -r '.pid')
BIN_PATH=$(readlink -f "/proc/$PID/exe")
ADDRESS=$(echo "$WINDOW_INFO" | jq -r '.address')
WORKSPACE=$(echo "$WINDOW_INFO" | jq -r '.workspace.name')
XY=$(echo "$WINDOW_INFO" | jq -r '.at | "\(. | tostring)"')
SIZE=$(echo "$WINDOW_INFO" | jq -r '.size | "\(. | tostring)"')
FLOATING=$(echo "$WINDOW_INFO" | jq -r '.floating')

# Format the output
OUTPUT=$(
  cat << EOF
{
  "title": "$TITLE",
  "class": "$CLASS",
  "pid": $PID,
  "bin_path": "$BIN_PATH",
  "address": "$ADDRESS",
  "workspace": "$WORKSPACE",
  "position": $XY,
  "size": $SIZE,
  "floating": $FLOATING
}
EOF
)

# Create a notification string
NOTIF_BODY=$(echo -e "Title: $TITLE\nClass: $CLASS\nPID: $PID")

# Send notification and copy to clipboard
notify-send "Window Info Copied" "$NOTIF_BODY"
wl-copy "$OUTPUT"
