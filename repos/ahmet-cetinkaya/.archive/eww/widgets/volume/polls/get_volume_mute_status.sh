#!/bin/bash

# Script to get the volume mute status
if pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes"; then
    echo "muted"
else
    echo ""
fi