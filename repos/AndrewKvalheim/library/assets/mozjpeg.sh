#!/usr/bin/env bash
set -Eeuo pipefail

readonly input="$1"

mime="$(file --brief --mime "$input")"
output="${input%.*}.jpg"

if [[ "$mime" == 'image/heic'* ]]; then
  png="$(mktemp --suffix='.png')"; trap 'rm -f "$png"' EXIT

  heif-dec "$input" "$png"

  from="png:$png"
else
  from="$input"
fi

magick "$from" -flatten 'ppm:-' \
  | cjpeg -optimize -quality '90' "${@:2}" \
> "$output"

exiftool -overwrite_original -TagsFromFile "$input" -all:all -ICC_Profile "$output"
