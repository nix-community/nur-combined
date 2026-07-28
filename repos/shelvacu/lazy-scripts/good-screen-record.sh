#!/usr/bin/env bash
# Notes: decent command for recording screen at very good quality. gpu-accelerated
# -w portal: records from xdg-desktop-portal/pipewire, so no admin and can select which screen/window
# -fm content: select framerate based on content
# -f 400: record a *maximum* of 400 FPS
# -cr full: color range, no reason to not do full in modern times
# -a default_{input,output}: adds an audio track with the default {input,output} device
# -ac flac: supposed to record audio in flac but "Flac audio codec is option is disable at the moment because of a temporary issue"

source shellvaculib.bash || exit 1

svl_no_args $#

declare -a cmd=(gpu-screen-recorder)

if ! type -- "${cmd[0]}"; then
  cmd=(nr gpu-screen-recorder)
fi

if ! type -- "${cmd[0]}"; then
  cmd=(nix run 'nixpkgs#gpu-screen-recorder' --)
fi

cmd+=(
  -w portal        # records from xdg-desktop-portal/pipewire, so no admin and can select which screen/window
  -fm content      # select framerate based on content
  -f 400           # record a *maximum* of 400 FPS
  -cr full         # color range, no reason to not do full in modern times
  -a default_input # adds an audio track with the default {input,output} device
  -a default_output
  -ac flac # supposed to record audio in flac but "Flac audio codec is option is disable at the moment because of a temporary issue"
  -o "recording-$(date -u '+%F_%H-%M-%SZ').mkv"
)

svl_log_verbose_run "${cmd[@]}"

if [[ ${ONLY_SHOW_COMMAND:-} != 1 ]]; then
  exec "${cmd[@]}"
fi
