#!/usr/bin/env bash
set -Eemuo pipefail
trap 'exit' INT TERM

readonly original="$1"

#
# Choose encoder
#

readonly encoders_menu=(
  'TRUE' 'AVIF: cavif'
  'FALSE' 'JPEG: Guetzli'
  'FALSE' 'JPEG: MozJPEG'
)
encoder="$(
  zenity --list --radiolist --hide-header \
    --height "$(( 200 + ( ${#encoders_menu[@]} / 2 + 1 ) * 30 ))" \
    --title 'Image quality gradient' \
    --text 'Select which encoder to use:' \
    --column 'Selected' \
    --column 'Encoder' \
    --separator=$'\n' \
    "${encoders_menu[@]}"
)"
[[ -n "$encoder" ]] || exit

case "$encoder" in
  'AVIF: cavif')
    readonly extension='avif'
    readonly qualities_menu=(
      'FALSE' '95' 'TRUE' '90'
      'FALSE' '85' 'TRUE' '80'
      'FALSE' '75' 'TRUE' '70'
      'FALSE' '65' 'TRUE' '60'
      'FALSE' '55' 'TRUE' '50'
      'FALSE' '45' 'FALSE' '40'
      'FALSE' '35' 'FALSE' '30'
      'FALSE' '25' 'FALSE' '20'
      'FALSE' '15' 'FALSE' '10'
    )
    ;;
  'JPEG: Guetzli')
    readonly extension='jpg'
    readonly qualities_menu=(
      'TRUE' '95' 'FALSE' '94' 'FALSE' '93' 'FALSE' '92' 'FALSE' '91' 'TRUE' '90'
      'FALSE' '89' 'FALSE' '88' 'FALSE' '87' 'FALSE' '86' 'FALSE' '85' 'TRUE' '84'
    )
    ;;
  'JPEG: MozJPEG')
    readonly extension='jpg'
    readonly qualities_menu=(
      'FALSE' '95' 'FALSE' '90'
      'FALSE' '83' 'TRUE' '80'
      'TRUE' '75' 'TRUE' '70'
      'TRUE' '65' 'TRUE' '60'
      'TRUE' '55' 'TRUE' '50'
      'FALSE' '45' 'FALSE' '40'
      'FALSE' '35' 'FALSE' '30'
      'FALSE' '25' 'FALSE' '20'
      'FALSE' '15' 'FALSE' '10'
    )
    ;;
  *) echo "Not implemented for: ${encoder@A}" >&2; exit 1;;
esac

#
# Choose qualities
#

readarray -t qualities <<< "$(
  zenity --list --checklist --hide-header \
    --height "$(( 200 + ( ${#qualities_menu[@]} / 2 + 1 ) * 30 ))" \
    --title 'Image quality gradient' \
    --text 'Select which qualities to encode:' \
    --column 'Encode' \
    --column 'Quality' \
    --separator=$'\n' \
    "${qualities_menu[@]}"
)"
[[ -n "${qualities[0]}" ]] || exit

#
# Decode input
#

case "$(file --brief --mime "$original")" in
  'image/heic;'*)
    png="$(mktemp --tmpdir='/dev/shm' --suffix='.png')"; trap 'rm --force "$png"' EXIT
    heif-dec "$original" "$png"
    ;;
  'image/png;'*)
    png="$original"
    ;;
  *) echo "Not implemented for: ${original@A}" >&2; exit 1;;
esac

#
# Determine resource limits
#

cores_available="$(nproc)"
memory_available="$(( "$(sed --quiet '/^MemTotal:/ s/[^[:digit:]]//gp' '/proc/meminfo')" * 1024 ))"
read -r width height < <(identify -format '%w %h\n' "$png")

case "$encoder" in
  'AVIF: cavif')
    cores_per_image="$(( width * height / (2048 * 2048) ))"
    (( cores_per_image >= 1 )) || cores_per_image='1'
    (( cores_per_image <= cores_available )) || cores_per_image="$cores_available"
    max_jobs="$(( cores_available / cores_per_image ))"
    ;;
  'JPEG: Guetzli')
    by_memory="$(( memory_available / (width * height * 300) ))"
    max_jobs="$(( by_memory < 1 ? 1 : (by_memory > cores_available ? cores_available : by_memory) ))"
    ;;
  'JPEG: MozJPEG')
    max_jobs="$cores_available"
    ;;
  *) echo "Not implemented for: ${encoder@A}" >&2; exit 1;;
esac

#
# Encode
#

active='0' completed='0' outputs=()
declare -A status

await_active() { local count="$1"
  local jid

  while (( active >= count )); do
    wait -n -p jid
    progress_update stop "$jid"
  done
}

encode() { local quality="$1" output="$2"
  echo "Encoding $output" >&2
  case "$encoder" in
    'AVIF: cavif') nice cavif --speed '1' --quality "$quality" --overwrite --output "$output" "$png";;
    'JPEG: Guetzli') nice guetzli --quality "$quality" "$png" "$output";;
    'JPEG: MozJPEG') magick "$png" -flatten 'ppm:-' | nice cjpeg -optimize -quality "$quality" > "$output";;
    *) echo "Not implemented for: ${encoder@A}" >&2; exit 1;;
  esac

  exiftool -quiet -overwrite_original -TagsFromFile "$original" -all:all -ICC_Profile "$output"
  touch --reference "$original" "$output"
}

progress_start() {
  exec 3> >(
    zenity \
      --width '600' \
      --progress \
      --percentage='0' \
      --auto-close \
      --auto-kill \
      --title 'Image quality gradient' \
      --text 'Initializing'
  )
}

progress_stop() {
  exec 3>&-
}

progress_update() { local action="$1" jid="$2"
  case "$action" in
    'start') status[$jid]="q${qualities[i]}"; (( active++ )) ||:;;
    'stop') [[ -z "${status[$jid]:-}" ]] || { unset "status[$jid]"; (( active--, completed++ )) ||:; };;
    *) echo "Not implemented for: ${action@A}" >&2; exit 1;;
  esac

  echo "# Encoding: ${status[*]}" >&3;
  echo "$(( completed * 100 / ${#qualities[@]} ))%" >&3;
}

stop_jobs() {
  for jid in "${!status[@]}"; do
    echo "Stopping ${status[$jid]}" >&2
    kill -- "-$jid"
  done
}

trap 'stop_jobs' EXIT
progress_start
for i in "${!qualities[@]}"; do
  await_active "$max_jobs"
  output="$original.q${qualities[i]}.$extension"; outputs+=("$output")
  encode "${qualities[i]}" "$output" & progress_update start "$!"
done
await_active '1'
progress_stop

#
# Display results
#

identity "$original" "${outputs[@]}" & disown
