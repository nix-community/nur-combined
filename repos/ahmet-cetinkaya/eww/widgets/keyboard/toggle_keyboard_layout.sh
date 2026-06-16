#!/bin/bash

# Get the main keyboard name dynamically
KEYBOARD_NAME=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .name')

if [ -n "$KEYBOARD_NAME" ]; then
    hyprctl switchxkblayout "$KEYBOARD_NAME" next
else
    echo "Error: Main keyboard not found." >&2
    exit 1
fi
