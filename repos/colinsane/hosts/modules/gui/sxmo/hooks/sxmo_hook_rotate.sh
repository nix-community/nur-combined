#!/usr/bin/env nix-shell
#!nix-shell -i bash -p sway

# called whenever sxmo_rotate.sh is invoked.
# i.e. whenever the screen is rotated manually, or automatically if autorotate is enabled.
# $1 = the new orientation
# possible values are "normal", "invert", "left" and "right"

# exit fullscreen, if any app is in FS.
# this benefits UX because:
# - most of my FS use is in landscape mode
# - when i toggle apps or desktops i always do so in portrait mode
# - therefore when i rotate landscape -> portrait mode, i almost never want fullscreen anymore.
if [ "$1" = "normal" ] || [ "$1" = "invert" ]; then
  swaymsg fullscreen disable
fi
