#!/bin/bash

# Get current keyboard layout using hyprctl
layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' 2>/dev/null)

# If hyprctl fails, try alternative methods
if [ -z "$layout" ] || [ "$layout" = "null" ]; then
    # Try with setxkbmap
    layout=$(setxkbmap -query | grep layout | awk '{print $2}' 2>/dev/null)
fi

# If still empty, try localectl
if [ -z "$layout" ]; then
    layout=$(localectl status | grep "X11 Layout" | awk '{print $3}' 2>/dev/null)
fi

# Default to "us" if nothing found
if [ -z "$layout" ]; then
    layout="us"
fi

# Convert specific layouts to desired display format
case "${layout,,}" in
    "tr"|"turkish")
        echo "TR"
        ;;
    "us"|"en"|"english"|"US"|"english (us)")
        echo "EN"
        ;;
    *)
        echo "${layout^^}"
        ;;
esac