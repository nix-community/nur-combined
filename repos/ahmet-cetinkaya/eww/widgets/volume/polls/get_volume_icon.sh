#!/bin/bash

# Script to get the volume icon
if pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes"; then
    echo ""
else
    echo ""
fi