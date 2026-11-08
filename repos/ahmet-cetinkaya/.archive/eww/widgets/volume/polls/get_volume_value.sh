#!/bin/bash

# Script to get the current volume value
pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '[0-9]+%' | head -1 | sed 's/%//' || echo 0