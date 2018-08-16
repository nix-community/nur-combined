#!/usr/bin/env bash

export TMUX_POWERLINE_DIR_SEGMENTS="${TMUX_POWERLINE_DIR_HOME}/segments"
export TMUX_POWERLINE_DIR_LIB="${TMUX_POWERLINE_DIR_HOME}/lib"

get_pane_width() {
	tmux_path=$(get_tmux_cwd)
	cd "$tmux_path"
  local pane_width="$(tmux display-message -p -t 1 '#{pane_width}')"

	if [ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]; then
    export TMUX_PANE_WIDTH=$(($pane_width-30))
  else
    export TMUX_PANE_WIDTH=$pane_width
  fi
}

# Get the current path in the segment.
get_tmux_cwd() {
  local env_name=$(tmux display -p "TMUXPWD_#D" | tr -d '%')
  local env_val=$(tmux show-environment | grep --color=never "$env_name")
  # The version below is still quite new for tmux. Uncomment this in the future :-)
  #local env_val=$(tmux show-environment "$env_name" 2>&1)

  if [[ ! $env_val =~ "unknown variable" ]]; then
    local tmux_pwd=$(echo "$env_val" | sed 's/^.*=//')
    echo "$tmux_pwd"
  fi
}

# separator characters
SEPARATOR_LEFT_BOLD=""
SEPARATOR_LEFT_THIN=""
SEPARATOR_RIGHT_BOLD=""
SEPARATOR_RIGHT_THIN=""

DEFAULT_BACKGROUND_COLOR=255
DEFAULT_FOREGROUND_COLOR=0

# This function creates the actual segment
segment() {
  local segment="$1"
  local foreground="$2"
  local background="$3"
  local autohide="$4"

  source "${TMUX_POWERLINE_DIR_HOME}/segments/${segment}.sh"
  local result=$(run_segment)

  local output="#[fg=${foreground}, bg=${background}, noreverse]${result}"

  local exit_code="$?"
  unset -f run_segment

  if [ "$exit_code" -ne 0 ]; then
    echo "Segment '${segment_name}' exited with code ${exit_code}. Aborting."
    exit 1
  fi

  # don't show output if the result is empty
  # or if the screen is small and has autohide enabled
  if [[ $TMUX_PANE_WIDTH -lt $4 ]]; then
    local display="hidden"
  fi

  if [[ -z "${result// }" || $display == "hidden" ]]; then
    echo -n ""
  else
    echo -n "#[fg=black, bg=black] "
    echo -n "${output}"
  fi
}

double_segment() {
  local label="$1"
  local label_fg="$2"
  local label_bg="$3"

  local segment="$4"
  local seg_fg="$5"
  local seg_bg="$6"

  local output="#[fg=${label_fg}, bg=${label_bg}, noreverse] ${label} "

  source "${TMUX_POWERLINE_DIR_HOME}/segments/${segment}.sh"
  local result=$(run_segment)

  output="${output}#[fg=${seg_fg}, bg=${seg_bg}, noreverse] ${result} "

  local exit_code="$?"
  unset -f run_segment

  # Show error when exit code != 0
  if [ "$exit_code" -ne 0 ]; then
    echo "Segment '${segment_name}' exited with code ${exit_code}. Aborting."
    exit 1
  fi

  # don't show output if the result is empty
  # or if the screen is small and has autohide enabled

  if [[ $TMUX_PANE_WIDTH -lt $7 ]]; then
    local display="hidden"
  fi

  if [[ -z "${result// }" || $display == "hidden" ]]; then
    echo -n ""
  else
    echo -n "#[fg=black, bg=black] "
    echo -n "${output}"
  fi
}
