#!/bin/bash

# Get current location
LOCATION=$(~/Configs/eww/widgets/weather/scripts/get_location.sh)

# Day 1 forecast (tomorrow)
LOCATION="${LOCATION:-}"

# Get tomorrow's weather from wttr.in
tomorrow=$(curl -s "wttr.in/$LOCATION" 2>/dev/null | grep -A 5 "Tomorrow" | head -n 6)

if [ -n "$tomorrow" ]; then
    # Extract day name (should be "Tomorrow" or actual day name)
    day=$(echo "$tomorrow" | head -n 1 | sed 's/.*┤//' | sed 's/├.*//' | tr -d ' ' | sed 's/Tomorrow/Mon/')

    # Extract weather icon
    icon=$(echo "$tomorrow" | grep -o "🌧\|🌦\|☁\|⛅\|☀\|🌩\|❄\|🌨\|🌫\|🌪\|⛈\|🌥\|🌞\|🌈\|❄️\|🌨️" | head -n 1)

    # Extract temperature range
    temp=$(echo "$tomorrow" | grep -o "[0-9]\+/[0-9]\+" | head -n 1)

    # Clean data
    day=$(echo "$day" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    icon=$(echo "$icon" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    temp=$(echo "$temp" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Set defaults if empty
    [ -z "$day" ] && day="Mon"
    [ -z "$icon" ] && icon="🌦"
    [ -z "$temp" ] && temp="17°/12°"

    echo "$day|$icon|$temp"
else
    echo "Mon|🌦|17°/12°"
fi