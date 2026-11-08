#!/bin/bash

SINK=$(pactl get-default-sink)

if [ "$1" = "up" ]; then
    # Get current volume
    VOLUME_INFO=$(pactl get-sink-volume "$SINK")
    CURRENT_VOLUME=$(echo "$VOLUME_INFO" | grep -oP '\d+%' | head -n 1 | sed 's/%//')

    # Calculate new volume aligned to 5% steps
    # Round up to the next 5% increment
    NEW_VOLUME=$(( (CURRENT_VOLUME + 4) / 5 * 5 + 5 ))  # Add 4 before division to round up, then add 5

    # Cap at 150%
    if (( NEW_VOLUME > 150 )); then
        NEW_VOLUME=150
    fi
    pactl set-sink-volume "$SINK" "${NEW_VOLUME}%"
elif [ "$1" = "down" ]; then
    # Get current volume
    VOLUME_INFO=$(pactl get-sink-volume "$SINK")
    CURRENT_VOLUME=$(echo "$VOLUME_INFO" | grep -oP '\d+%' | head -n 1 | sed 's/%//')

    # Calculate new volume aligned to 5% steps
    # Round down to the previous 5% increment
    NEW_VOLUME=$((CURRENT_VOLUME / 5 * 5 - 5))  # Round down to 5-step, then subtract 5
    
    # Ensure it doesn't go below 0
    if (( NEW_VOLUME < 0 )); then
        NEW_VOLUME=0
    fi
    pactl set-sink-volume "$SINK" "${NEW_VOLUME}%"
fi