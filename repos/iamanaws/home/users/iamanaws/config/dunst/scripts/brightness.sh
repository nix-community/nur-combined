#!/usr/bin/env bash

IFS=, read -r _ _ _ raw _ < <(brightnessctl -m)
brightness=${raw%\%}
dunstify -a "osd" -u low -h int:value:"$brightness" "󰃠 Brightness: ${brightness}%"
