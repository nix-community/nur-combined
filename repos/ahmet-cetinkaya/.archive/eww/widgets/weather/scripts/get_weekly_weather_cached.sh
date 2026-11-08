#!/bin/bash

# Weekly weather data caching script with timestamp check
CACHE_FILE="/tmp/eww_weekly_weather_cache.txt"
CACHE_TIME_FILE="/tmp/eww_weekly_weather_cache_time.txt"
MAX_CACHE_AGE=1800  # 30 minutes in seconds

LOCATION=""
if [ -n "$1" ]; then
    LOCATION="$1"
fi

# Check if cache exists and is still fresh
if [ -f "$CACHE_FILE" ] && [ -f "$CACHE_TIME_FILE" ]; then
    CACHE_TIME=$(cat "$CACHE_TIME_FILE")
    CURRENT_TIME=$(date +%s)
    AGE=$((CURRENT_TIME - CACHE_TIME))
    
    if [ $AGE -lt $MAX_CACHE_AGE ]; then
        # Cache is fresh, use it
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Cache is stale or doesn't exist, fetch new data
weather_data=$(curl -s "wttr.in/$LOCATION?format=%c+%t+tomorrow" 2>/dev/null)

if [ -n "$weather_data" ]; then
    # Save new data to cache
    echo "$weather_data" | sed 's/[[:space:]]*$//' > "$CACHE_FILE"
    date +%s > "$CACHE_TIME_FILE"
    echo "$weather_data" | sed 's/[[:space:]]*$//'
else
    echo "Forecast unavailable"
fi