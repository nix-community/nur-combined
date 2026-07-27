#!/bin/sh
tm() {
  if [ -z $1 ]; then
    tmux switch-client -l
  else
    if [ -z "$TMUX" ]; then
      tmux new-session -As $1
    else
      if ! tmux has-session -t $1 2>/dev/null; then
        TMUX= tmux new-session -ds $1
      fi
      tmux switch-client -t $1
    fi
  fi
}

tm $1
