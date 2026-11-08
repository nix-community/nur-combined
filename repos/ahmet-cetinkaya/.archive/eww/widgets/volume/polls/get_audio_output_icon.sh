#!/bin/bash

# Script to get the audio output icon
if pactl get-default-sink | grep -q "Razer_USB_Sound_Card"; then
    echo ""
else
    echo "󰓃"
fi