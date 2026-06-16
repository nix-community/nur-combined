#!/bin/bash

# Script to get the microphone mute status
if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "yes"; then
    echo "muted"
else
    echo ""
fi