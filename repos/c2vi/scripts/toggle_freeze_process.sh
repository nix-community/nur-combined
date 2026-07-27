#!/usr/bin/env bash

# Get the PID of the focused window
PID=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true).pid')
FOCUSED_WIN_ID=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true).id')

# Check if the process is frozen
STATE=$(ps -o state= -p $PID)

if [[ "$STATE" == *T* ]]; then
    # If the process is frozen, unfreeze it and reset border color
    kill -CONT $PID
    swaymsg [con_id=$FOCUSED_WIN_ID] border pixel 2
else
    # If the process is running, freeze it and change border color
    kill -STOP $PID
    swaymsg [con_id=$FOCUSED_WIN_ID] border pixel 10
fi
