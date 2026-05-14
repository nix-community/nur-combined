#!/usr/bin/env bash
set -Eeuo pipefail

src="$1"
jpg="$HOME/Downloads/cover.jpg"

magick "$src" -resize '1200x>' "ppm:-" \
  | cjpeg -optimize -quality '75' \
  > "$jpg"

description="$(identify \
  -precision '3' \
  -format '%[magick] · %[bit-depth]-bit %[colorspace] · %[width]×%[height]px · %[size]\n' \
  "$jpg" \
)"

if [[ -n "${KITTY_WINDOW_ID-}" ]]; then
  kitty +kitten icat "$jpg"
  echo "$description"
else
  magick \
    "$jpg" \
    -bordercolor 'black' -border '64x64' \
    -background 'black' -fill 'white' -pointsize '24' label:"$description" \
    -gravity 'center' \
    -append \
    -border '64x64' \
    ppm:- \
  | display
fi
