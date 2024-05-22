_click="${0:A:h}/click.wav"

_click_preexec() {
  _click_start_seconds=${_click_start_seconds:-$SECONDS}
}

_click_precmd() {
  [[ $+_click_start_seconds ]] || return

  if (( SECONDS - _click_start_seconds >= 20 )); then
    pw-play "$_click" &!
  fi

  unset _click_start_seconds
}

preexec_functions+=(_click_preexec)
precmd_functions+=(_click_precmd)
