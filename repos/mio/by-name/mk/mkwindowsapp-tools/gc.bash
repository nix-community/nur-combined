#!/usr/bin/env bash

set -euo pipefail

shopt -s nullglob

function print_layer_info() {
  local status=$1
  local id=$2
  local size=$3
  local mutable=$4

  printf '%s\t%s\t%s\t%s\n' "$id" "$size" "$mutable" "$status"
}

CACHE_DIR="${HOME:?HOME is not set}/.cache/mkWindowsApp"

printf 'LAYER ID                                                        \tSIZE\tMUTABLE\tACTION\n'

# API 0
for file in "$CACHE_DIR"/*.referrers; do
  filename=$(basename -s .referrers "$file")
  size=$(du -h -s -- "$CACHE_DIR/$filename" 2>/dev/null | cut -f 1) || size="?"
  temp_file=$(mktemp --suffix .mkwindowsapp-gc)

  while IFS= read -r ref_path || [[ -n $ref_path ]]; do
    if [[ -e $ref_path ]]; then
      printf '%s\n' "$ref_path" >> "$temp_file"
    fi
  done < "$file"

  if [[ -s $temp_file ]]; then
    print_layer_info "keeping" "$filename" "$size" "?"
    mv "$temp_file" "$file"
  else
    print_layer_info "deleting" "$filename" "$size" "?"
    rm -rf -- "${CACHE_DIR:?}/${filename:?}"
    rm -f -- "$file"
    rm -f -- "$temp_file"
  fi
done

# API 1
for layer in "$CACHE_DIR"/*/; do
  layer=${layer%/}
  if [[ ! -f "$layer/api" ]]; then
    continue
  fi
  if [[ $layer == *incomplete* ]]; then
    continue
  fi

  filename=$(basename "$layer")
  size=$(du -h -s -- "$CACHE_DIR/$filename" 2>/dev/null | cut -f 1) || size="?"
  temp_file=$(mktemp --suffix .mkwindowsapp-gc)
  mutable="?"
  if [[ -f "$layer/mutable" ]]; then
    mutable=$(<"$layer/mutable")
  fi

  if [[ -f "$layer/refs" ]]; then
    while IFS= read -r ref_path || [[ -n $ref_path ]]; do
      if [[ -e $ref_path ]]; then
        printf '%s\n' "$ref_path" >> "$temp_file"
      fi
    done < "$layer/refs"
  fi

  if [[ -s $temp_file ]]; then
    print_layer_info "keeping" "$filename" "$size" "$mutable"
    mv "$temp_file" "$layer/refs"
  else
    print_layer_info "deleting" "$filename" "$size" "$mutable"
    rm -rf -- "${layer:?}"
    rm -f -- "$temp_file"
  fi
done
