#!/bin/bash

# Get current location
LOCATION=$(~/Configs/eww/widgets/weather/scripts/get_location.sh)

# Get weather data for the location
~/Configs/eww/widgets/weather/scripts/get_detailed_weather.sh "$LOCATION" | grep "CONDITION:" | cut -d: -f2-