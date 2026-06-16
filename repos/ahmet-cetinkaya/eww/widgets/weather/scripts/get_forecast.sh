#!/bin/bash

# 3-day forecast data
LOCATION="${1:-}"

# Get tomorrow's weather
tomorrow=$(curl -s "wttr.in/$LOCATION" 2>/dev/null | grep -A 5 "Tomorrow" | head -n 6)

if [ -n "$tomorrow" ]; then
    # Extract day name, icon, and temperature
    day=$(echo "$tomorrow" | head -n 1 | sed 's/.*┤//' | sed 's/├.*//' | tr -d ' ')
    icon=$(echo "$tomorrow" | grep -o "🌧\|🌦\|☁\|⛅\|☀\|🌩\|❄\|🌨" | head -n 1)
    temp=$(echo "$tomorrow" | grep -o "[0-9]\+/[0-9]\+" | head -n 1)

    if [ -z "$icon" ]; then
        icon="🌦"
    fi

    if [ -z "$temp" ]; then
        temp="17°/12°"
    fi

    echo "$day|$icon|$temp"
else
    echo "Tomorrow|🌦|17°/12°"
fi