#!/usr/bin/env bash
export WAYLAND_DISPLAY="wayland-1"
export XDG_RUNTIME_DIR="/run/user/1000"
EWW_CONFIG_DIR="/home/ac/Configs/eww"
sleep 3 # Wait for monitors to initialize after resume
/usr/bin/eww -c $EWW_CONFIG_DIR daemon
/usr/bin/eww -c $EWW_CONFIG_DIR open bar
