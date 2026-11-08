#!/bin/bash

# Script to get the microphone icon
if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "yes"; then
    echo ""
else
    echo ""
fi