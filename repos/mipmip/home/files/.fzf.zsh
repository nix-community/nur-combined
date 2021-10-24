# Setup fzf
# ---------
if [[ ! "$PATH" == */home/pim/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/pim/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/pim/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/pim/.fzf/shell/key-bindings.zsh"
