#!/bin/bash

# Script to return the complete volume label class based on volume level
VOLUME_VALUE=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '[0-9]+%' | head -1 | sed 's/%//')

if [ "$VOLUME_VALUE" -gt 100 ]; then
    echo "volume-label volume-high"
else
    echo "volume-label"
fi