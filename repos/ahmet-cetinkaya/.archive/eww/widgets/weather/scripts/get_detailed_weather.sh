#!/bin/bash

# Current weather data
LOCATION="${1:-}"
CURRENT_DATA=$(curl -s "wttr.in/$LOCATION?format=%l|%c|%C|%t|%h|%w" 2>/dev/null)

if [ -n "$CURRENT_DATA" ]; then
    # Parse the data
    IFS='|' read -r location icon condition temp humidity wind <<< "$CURRENT_DATA"

    # Clean and trim the data
    location=$(echo "$location" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    icon=$(echo "$icon" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    condition=$(echo "$condition" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    temp=$(echo "$temp" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    humidity=$(echo "$humidity" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    wind=$(echo "$wind" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Output data with delimiters for easy parsing
    echo "LOCATION:$location"
    echo "ICON:$icon"
    echo "CONDITION:$condition"
    echo "TEMP:$temp"
    echo "HUMIDITY:💧 $humidity"
    echo "WIND:🌬️ $wind"
else
    echo "LOCATION:Istanbul, Turkey"
    echo "ICON:🌦"
    echo "CONDITION:Mostly Cloudy"
    echo "TEMP:18°C day/night"
    echo "HUMIDITY:💧 62%"
    echo "WIND:🌬️ 8 km/h"
fi