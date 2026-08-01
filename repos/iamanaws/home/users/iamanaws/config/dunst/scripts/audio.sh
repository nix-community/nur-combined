#!/usr/bin/env bash

mode=${1:-volume}

case "$mode" in
mic)
  device=@DEFAULT_AUDIO_SOURCE@
  icon_active="󰍬"
  icon_muted="󰍭"
  label="Microphone"
  ;;
volume)
  device=@DEFAULT_AUDIO_SINK@
  icon_active=""
  icon_muted=""
  label="Volume"
  ;;
*)
  echo "Usage: $0 [volume|mic]" >&2
  exit 1
  ;;
esac

volume_data=$(wpctl get-volume "$device")
read -r _ vol_float muted_status <<<"$volume_data"

dunstify_args=(-a "osd" -u "low")

if [[ -n $muted_status ]]; then
  icon=$icon_muted
  message="${label} mute"
else
  volume=$(printf "%.0f" "${vol_float}e2")
  icon=$icon_active
  message="${label}: ${volume}%"
  dunstify_args+=(-h "int:value:${volume}")
fi

dunstify "${dunstify_args[@]}" "${icon} ${message}"
