if ! brightness_data=$(brightnessctl -m); then
  printf 'Unable to read backlight state.\n' >&2
  exit 1
fi

IFS=, read -r _ _ _ raw _ <<<"$brightness_data"
brightness=${raw%\%}

if [[ ! $brightness =~ ^[0-9]+$ ]]; then
  printf 'Unexpected brightness information: %s\n' "$brightness_data" >&2
  exit 1
fi

dunstify -a "osd" -u low -h int:value:"$brightness" "󰃠 Brightness: ${brightness}%"
