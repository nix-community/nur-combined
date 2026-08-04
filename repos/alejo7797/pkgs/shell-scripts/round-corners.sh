#!/usr/bin/env bash

# Round off an image's corners.

w=$(identify -format "%w" "$1")
h=$(identify -format "%h" "$1")

r=$(bc <<<"scale=0; $h/${2:-6.4}")

magick -size "${w}x${h}" xc:black \
    -fill white -draw "roundRectangle 0,0,$w,$h $r,$r" "${tmp_mask:=$(mktemp --suffix=.png)}"

magick "$1" "${tmp_mask}" \
    -alpha Off -compose CopyOpacity -composite \
    "${3:-${1%.*}_rounded_corners.png}"

rm "${tmp_mask}"
