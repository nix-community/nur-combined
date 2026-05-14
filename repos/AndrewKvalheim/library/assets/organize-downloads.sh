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

stage() { local path="$1"
  staged+=( "$HOME/screenshots/⏳️ ${path##*/}" )
  mkdir --parents --verbose "${staged[-1]%/*}"
  mv --no-clobber --verbose "$path" "${staged[-1]}"
}

unstage() { local path="$1"
  [[ "$(< /sys/class/power_supply/AC/online)" == '1' ]] && o='8' || o='3'
  ect -"$o" -keep "$path"
  mv --no-clobber --verbose "$path" "${path/⏳️ /}"
}

for path in \
  ~/.local/share/PrismLauncher/instances/*/.minecraft/screenshots/*.png \
  ~/Downloads/Screen{s,\ S}hot\ *.png \
  ~/VirtualBox\ VMs/*/VirtualBox_*.png
do
  await_writes "$path"
  stage "$path"
done

for path in "${staged[@]}"; do
  unstage "$path"
done
