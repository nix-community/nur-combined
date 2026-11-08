#!/bin/bash

# Get current location
LOCATION=$(~/Configs/eww/widgets/weather/scripts/get_location.sh)

# Day 3 forecast
LOCATION="${LOCATION:-}"

# Get the forecast data and find the third day
forecast_data=$(curl -s "wttr.in/$LOCATION" 2>/dev/null)

# Find the third forecast day
day3_section=$(echo "$forecast_data" | sed -n '/Tomorrow/,/^$/p' | tail -n +20 | grep -A 10 "┌─" | head -n 15)

if [ -n "$day3_section" ]; then
    # Extract day name from header
    day=$(echo "$day3_section" | grep "┌─" | sed 's/.*┤//' | sed 's/├.*//' | tr -d ' ' | awk '{print substr($1,1,3)}')

    # Extract weather icon
    icon=$(echo "$day3_section" | grep -o "🌧\|🌦\|☁\|⛅\|☀\|🌩\|❄\|🌨\|🌫\|🌪\|⛈\|🌥\|🌞\|❄️\|🌨️\|   \\\\|   /" | head -n 1 | sed 's/   \\\\|☀/;s/   /|/g' | tr -d ' ')

    # If no emoji found, try to map ASCII art to emoji
    if [ -z "$icon" ] || [ "$icon" = "|" ]; then
        if echo "$day3_section" | grep -q "   /"; then
            icon="☀"
        elif echo "$day3_section" | grep -q ".-."; then
            icon="⛅"
        elif echo "$day3_section" | grep -q "(   )"; then
            icon="🌦"
        else
            icon="🌦"
        fi
    fi

    # Extract temperature range
    temp=$(echo "$day3_section" | grep -o "[0-9]\+/[0-9]\+\|[0-9]\+([0-9]\+)" | head -n 1 | sed 's/(/°\//;s/)/°/')

    # Clean data
    day=$(echo "$day" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    icon=$(echo "$icon" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    temp=$(echo "$temp" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Set defaults
    [ -z "$day" ] && day="Wed"
    [ -z "$icon" ] && icon="☀"
    [ -z "$temp" ] && temp="21°/14°"

    echo "$day|$icon|$temp"
else
    echo "Wed|☀|21°/14°"
fi