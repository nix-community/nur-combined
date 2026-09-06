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

if ! volume_data=$(wpctl get-volume "$device"); then
  printf 'Unable to read %s state.\n' "$label" >&2
  exit 1
fi
read -r _ vol_float muted_status <<<"$volume_data"

if [[ ! $vol_float =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  printf 'Unexpected wpctl volume: %s\n' "$volume_data" >&2
  exit 1
fi

dunstify_args=(-a "osd" -u "low")

if [[ $muted_status == "[MUTED]" ]]; then
  icon=$icon_muted
  message="${label} mute"
else
  volume=$(printf "%.0f" "${vol_float}e2")
  icon=$icon_active
  message="${label}: ${volume}%"
  dunstify_args+=(-h "int:value:${volume}")
fi

dunstify "${dunstify_args[@]}" "${icon} ${message}"
