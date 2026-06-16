#!/bin/bash

# Start Betterbird
flatpak run eu.betterbird.Betterbird &

# Wait for Betterbird window to appear and initialize
while ! hyprctl clients | grep -q "class: eu.betterbird.Betterbird"; do
  sleep 0.1
done

# Give Betterbird time to initialize tray functionality
sleep 1

# Move to workspace 9 and close (should go to tray)
hyprctl dispatch movetoworkspace 9 'class:^(eu.betterbird.Betterbird)$'
sleep 0.3
hyprctl dispatch closewindow 'class:^(eu.betterbird.Betterbird)$'
