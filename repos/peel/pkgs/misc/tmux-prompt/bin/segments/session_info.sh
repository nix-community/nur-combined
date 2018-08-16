#!/usr/bin/env bash

# Prints tmux session info.
# Assumes that [ -n "$TMUX"].

run_segment() {
  session_name=$(tmux display-message -p '#S')

  if test "${session_name#*-}" != "$session_name"
  then
    first_part=${session_name%-*}
    second_part=${session_name#*-}
    initials=${first_part:0:1}${second_part:0:1}
    session_name=$initials
  else
    cols=$(tput cols)
    length=5

    if test $cols -gt 80; then
      echo ${session_name}
      # length=${#${session_name}}
    fi

    session_name=${session_name:0:length}
  fi

	echo -n "#[bold]${session_name}"
  return 0
}
