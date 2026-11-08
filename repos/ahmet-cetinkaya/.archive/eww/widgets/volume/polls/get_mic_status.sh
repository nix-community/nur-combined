#!/bin/bash

# Script to get the microphone status
if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "yes"; then
    echo "mic-muted"
else
    echo "mic-unmuted"
fi