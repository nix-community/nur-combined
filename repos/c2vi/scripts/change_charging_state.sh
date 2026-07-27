#!/usr/bin/env bash

export XDG_RUNTIME_DIR="/run/user/$(id -u $SENDER_USER)"
export WAYLAND_DISPLAY="wayland-0"
ALERT_SCRIPT="sudo ./keyboard_alert.sh 2"

status=$1
if [[ $status -eq 0 ]]; then
  dunstctl close-all
  notify-send "No mommy put it back pwp" -u low
  $ALERT_SCRIPT
else
  dunstctl close-all
  notify-send "Thank you for plugging me mommy ~" -u low
  $ALERT_SCRIPT
fi
