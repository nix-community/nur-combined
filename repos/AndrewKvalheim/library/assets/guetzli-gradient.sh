#!/usr/bin/env bash
set -Eeuo pipefail
trap 'exit' INT TERM
trap 'kill 0' EXIT

readonly original="$1"
readonly guetzli_b_per_px='300'
readonly qualities=( {84..95} )
jpgs=()

case "$(file --brief --mime "$original")" in
  'image/heic;'*)
    png="$(mktemp --tmpdir='/dev/shm' --suffix='.png')"; trap 'rm --force "$png"' EXIT
    heif-dec "$original" "$png"
    ;;
  'image/png;'*)
    png="$original"
    ;;
  *) echo "Not implemented for: $original" >&2; exit 1;;
esac

memory_available_kb="$(sed --quiet '/^MemTotal:/ s/[^[:digit:]]//gp' '/proc/meminfo')"
read -r width height < <(identify -format '%w %h\n' "$png")
concurrency_by_mem="$(( memory_available_kb * 1024 / (width * height * guetzli_b_per_px) ))"
concurrency_bp_cpu="$(nproc)"
concurrency="$(( concurrency_by_mem > concurrency_bp_cpu ? concurrency_bp_cpu : concurrency_by_mem ))"
concurrency="$(( concurrency < 1 ? 1 : concurrency ))"
echo "Concurrency: $concurrency" >&2

encode() { local quality="$1" png="$2" jpg="$3"
  echo "Encoding $jpg" >&2

  nice guetzli --quality "$quality" "$png" "$jpg"
  exiftool -quiet -overwrite_original -TagsFromFile "$original" -all:all -ICC_Profile "$jpg"
  touch --reference "$original" "$jpg"
}

active='0'
completed='0'
declare -A status

await_any_job() {
  local jid; wait -n -p jid
  unset "status[$jid]"
  (( active--, completed++ )) ||:
  update_progress
}

exec 3> >(
  zenity \
    --width '600' \
    --progress \
    --percentage='0' \
    --auto-close \
    --auto-kill \
    --title "Guetzli gradient" \
    --text "Encoding qualities: ${qualities[*]}"
)
update_progress() {
  echo "# Encoding: ${status[*]}" >&3;
  echo "$(( completed * 100 / ${#qualities[@]} ))%" >&3;
}

for i in "${!qualities[@]}"; do
  while (( active >= concurrency )); do
    await_any_job
  done

  jpg="$original.q${qualities[i]}.jpg"
  jpgs+=("$jpg")
  encode "${qualities[i]}" "$png" "$jpg" & jid="$!"
  status[$jid]="q${qualities[i]}"
  (( active++ )) ||:
  update_progress
done
while (( active > 0 )); do
  await_any_job
done

exec 3>&-
echo 'Done encoding' >&2

identity "${jpgs[@]}" & disown
