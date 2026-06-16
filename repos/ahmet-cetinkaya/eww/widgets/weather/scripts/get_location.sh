#!/bin/bash

# Get location using IP geolocation service
IP_DATA=$(curl -s "http://ip-api.com/json/" 2>/dev/null)

if [ -n "$IP_DATA" ] && [ "$IP_DATA" != "null" ]; then
    # Parse city and country from JSON response
    CITY=$(echo "$IP_DATA" | jq -r '.regionName // empty')
    COUNTRY=$(echo "$IP_DATA" | jq -r '.country // empty')
    
    if [ -n "$CITY" ] && [ -n "$COUNTRY" ]; then
        LOCATION="$CITY, $COUNTRY"
    elif [ -n "$CITY" ]; then
        LOCATION="$CITY"
    elif [ -n "$COUNTRY" ]; then
        LOCATION="$COUNTRY"
    else
        LOCATION="Unknown Location"
    fi
    
    echo "$LOCATION"
else
    # Fallback to default location
    echo "Istanbul, Turkey"
fi