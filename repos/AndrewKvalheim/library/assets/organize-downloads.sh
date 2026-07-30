#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

EXIT_CONTINUE='193'

handlers_dir="$HOME/.organize-downloads/handlers"
screenshots_dir="$HOME/screenshots"

emit() { local from="$1" dir="${2%/*}" name="${2##*/}"
  local stem="${name%%.*}"
  local extensions="${name#"$stem"}"

  echo "Emit: $dir/$stem$extensions" >&2
  mkdir --parents "$dir"
  strict_mv "$from" "$dir/$stem$extensions" && return || :

  local mtime; mtime="$(stat --format '%Y' "$from")"
  local timestamp; timestamp="$(date --date "@$mtime" --iso-8601=seconds)"
  echo "Retry emit: $dir/$stem ($timestamp)$extensions" >&2
  strict_mv "$from" "$dir/$stem ($timestamp)$extensions" && return || :

  local n='1'; while (( n++ && n <= 100 )); do
    echo "Retry emit: $dir/$stem ($timestamp #$n)$extensions" >&2
    strict_mv "$from" "$dir/$stem ($timestamp #$n)$extensions" && return || :
  done

  echo "Failed to emit from: $from" >&2
  return 1
}

if_battery() { local y="$1" n="$2"
  [[ "$(< /sys/class/power_supply/AC/online)" == '1' ]] && echo "$n" || echo "$y"
}

intake() { local path="$1"
  [[ "$path" != *'⏳️ '* ]] || exit 1
  local intaken_path="${path%/*}/⏳️ ${path##*/}"

  while [[ -n "$(find "$path" -newermt '1 second ago')" ]]; do sleep '1s'; done
  strict_mv "$path" "$intaken_path"
  process "$intaken_path" & disown
}

optimize_jpg_jxl() { local path="$1"
  {
    cjxl --effort "$(if_battery 7 10)" --lossless_jpeg '1' "$path" "$path.jxl"
    touch --reference "$path" "$path.jxl"
    rm "$path"
  } >&2
  echo "$path.jxl"
}

optimize_png() { local path="$1"
  ect -"$(if_battery 3 8)" -keep "$path" >&2
  echo "$path"
}

process() { local path="$1"
  echo "Process: ${path/⏳️ /}" >&2

  local rc; for handler in "$handlers_dir/"*; do
    [[ -x "$handler" ]] || continue
    $handler "$path" && rc="$?" || rc="$?"
    (( rc == EXIT_CONTINUE )) && continue || return "$rc"
  done

  case "${path/⏳️ /}" in
    "$HOME/.local/share/PrismLauncher/instances/"*'/.minecraft/screenshots/'*'.png') process_screenshot "$path";;
    "$HOME/Downloads/iCloud Photos.zip") process_zip_transport "$path";;
    "$HOME/Downloads/iKVM_capture.jpg") process_screenshot "$path";;
    "$HOME/Downloads/Screen Shot "*'.png') process_screenshot "$path";;
    "$HOME/Downloads/Screenshot "*'.png') process_screenshot "$path";;
    "$HOME/VirtualBox VMs/VirtualBox_"*'.png') process_screenshot "$path";;
    *) echo "Unimplemented: $path" >&2; return 1;;
  esac
}

process_screenshot() { local path="$1"
  local name="${path##*/}"; name="${name#⏳️ }"
  local stem="${name%%.*}" extensions=".${name#*.}"

  local mtime; mtime="$(stat --format '%Y' "$path")"
  if [[ "$stem" != *"$(date --date "@$mtime" +'%Y')"* ]]; then
    stem+=" $(date --date "@$mtime" --iso-8601=seconds)"
    name="$stem$extensions"
  fi

  case "${extensions##*.}" in
    'jpg') emit "$(optimize_jpg_jxl "$path")" "$screenshots_dir/${name%.jpg}.jxl";;
    'png') emit "$(optimize_png "$path")" "$screenshots_dir/$name";;
    *) echo "Unimplemented: $path" >&2; return 1;;
  esac
}

process_zip_transport() { local path="$1"
  local fq_stem="${path%.zip}"

  emit "$(unpack_zip "$path")" "${fq_stem/⏳️ /}"
}

strict_mv() {
  mv --no-target-directory --update=none-fail "$@"
}

unpack_zip() { local path="$1"
  {
    unzip "$path" -d "${path%.zip}"
    rm "$path"
  } >&2
  echo "${path%.zip}"
}

main() {
  local path; for path in @GLOBS@; do
    [[ -e "$path" ]] || continue
    intake "$path" &
  done

  wait
}

main "$@"
