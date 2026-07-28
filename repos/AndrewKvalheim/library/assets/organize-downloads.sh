#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

staged=()

await_writes() { local path="$1"
  while [[ -n "$(find "$path" -newermt '1 second ago')" ]]; do
    echo "Waiting for writing to complete: $path"
    sleep 1s
  done
}

if_battery() { local if_yes="$1" if_no="$2"
  if [[ "$(< /sys/class/power_supply/AC/online)" == '1' ]]; then
    echo "$if_no"
  else
    echo "$if_yes"
  fi
}

stage() { local path="$1"
  local name="${path##*/}"
  local base="${name%%.*}"
  local extensions=".${name#*.}"

  if [[ ! "$base" =~ [0-9] ]]; then
    base+=" $(date --date "@$(stat --format '%W' "$path")" --iso-8601=seconds)"
  fi

  staged+=( "$HOME/screenshots/⏳️ $base$extensions" )
  mkdir --parents --verbose "${staged[-1]%/*}"
  mv --no-clobber --verbose "$path" "${staged[-1]}"
}

unstage() { local path="$1"
  case "${path##*.}" in
    'jpg')
      local jxl="${path%.jpg}.jxl"
      cjxl --effort "$(if_battery 7 10)" --lossless_jpeg '1' "$path" "${jxl/⏳️ /}"
      rm --verbose "$path"
      ;;

    'png')
      ect -"$(if_battery 3 8)" -keep "$path"
      mv --no-clobber --verbose "$path" "${path/⏳️ /}"
      ;;

    *)
      echo "Not implemented for $path" >&2
      exit 1
      ;;
  esac
}

for path in \
  ~/.local/share/PrismLauncher/instances/*/.minecraft/screenshots/*.png \
  ~/Downloads/iKVM_capture.jpg \
  ~/Downloads/Screen{s,\ S}hot\ *.png \
  ~/VirtualBox\ VMs/*/VirtualBox_*.png
do
  [[ -e "$path" ]] || continue

  await_writes "$path"
  stage "$path"
done

for path in "${staged[@]}"; do
  unstage "$path"
done
