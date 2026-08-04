# Adapted from https://github.com/romkatv/powerlevel10k/issues/888#issuecomment-657969840

zle-line-init() {
  emulate -L zsh

  [[ $CONTEXT == start ]] || return 0

  while true; do
    zle .recursive-edit
    local -i result="$?"
    [[ "$result" == '0' && "$KEYS" == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt="$PROMPT"
  local saved_rprompt="$RPROMPT"

  PROMPT='%B%F{magenta}%D{%H:%M:%S} ❯%f%b '
  RPROMPT=''
  zle .reset-prompt

  PROMPT="$saved_prompt"
  RPROMPT="$saved_rprompt"

  if (( result )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return result
}

zle -N zle-line-init
