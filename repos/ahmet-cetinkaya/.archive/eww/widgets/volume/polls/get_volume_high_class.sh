#!/bin/bash

# Script to return CSS class if volume is above 100%
VOLUME_VALUE=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '[0-9]+%' | head -1 | sed 's/%//')

if [ "$VOLUME_VALUE" -gt 100 ]; then
    echo "volume-high"
else
    echo ""
fi