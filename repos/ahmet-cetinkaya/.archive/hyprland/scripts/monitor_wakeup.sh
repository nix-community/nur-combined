#!/bin/bash

# --- Monitor Configuration ---
# This script is used to refresh the monitor configuration in Hyprland.
# It is triggered by a keybinding or on resume from sleep.

# --- Monitor Settings ---
# Define the settings for each monitor.
# Format: name,resolution@refresh_rate,position,scale

MONITOR_1="DP-1,2560x1440@143.97,0x0,1"
MONITOR_2="DP-2,1920x1080@59.94,2560x243,1"

# --- Script ---

# Turn on the monitors
hyprctl dispatch dpms on

# Wait for the monitors to be ready
sleep 1

# Set the monitor configuration
hyprctl keyword monitor $MONITOR_1
hyprctl keyword monitor $MONITOR_2
