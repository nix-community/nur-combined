# shellcheck disable=2154

# Fix Ctrl+u killing from the cursor instead of the whole line
bindkey '^u' backward-kill-line

# Use Ctrl+x-(Ctrl+)e to edit the current command line in VISUAL/EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# The expression: (( ${+terminfo} )) should never fail, but does if we
# don't have a tty, perhaps due to a bug in the zsh/terminfo module.
if ! { [ "$TERM" != emacs ] && (( ${+terminfo} )) 2>/dev/null; }; then
    return
fi

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget

    zle_application_mode_start() { echoti smkx; }
    zle_application_mode_stop() { echoti rmkx; }

    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi


# Fix delete key not working
if [ -n "${terminfo[kdch1]}" ]; then
    bindkey -M emacs "${terminfo[kdch1]}" delete-char
    bindkey -M viins "${terminfo[kdch1]}" delete-char
    bindkey -M vicmd "${terminfo[kdch1]}" delete-char
else
    bindkey -M emacs "^[[3~" delete-char
    bindkey -M viins "^[[3~" delete-char
    bindkey -M vicmd "^[[3~" delete-char

    bindkey -M emacs "^[3;5~" delete-char
    bindkey -M viins "^[3;5~" delete-char
    bindkey -M vicmd "^[3;5~" delete-char
fi

# Ctrl-Delete to delete a whole word forward
if [ -n "${terminfo[kdl1]}" ]; then
    bindkey -M emacs "${terminfo[kdl1]}" kill-word
    bindkey -M viins "${terminfo[kdl1]}" kill-word
    bindkey -M vicmd "${terminfo[kdl1]}" kill-word
else
    bindkey -M emacs '^[[3;5~' kill-word
    bindkey -M viins '^[[3;5~' kill-word
    bindkey -M vicmd '^[[3;5~' kill-word
fi

# Enable Shift-Tab to go backwards in completion list
if [ -n "${terminfo[kcbt]}" ]; then
    bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
    bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
    bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete
else
    bindkey -M emacs '^[[Z' reverse-menu-complete
    bindkey -M viins '^[[Z' reverse-menu-complete
    bindkey -M vicmd '^[[Z' reverse-menu-complete
fi

# Ctrl-Left moves backward one word
if [ -n "${terminfo[kLFT5]}" ]; then
    bindkey -M emacs "${terminfo[kLFT5]}" backward-word
    bindkey -M viins "${terminfo[kLFT5]}" backward-word
    bindkey -M vicmd "${terminfo[kLFT5]}" backward-word
else
    bindkey -M emacs '^[[1;5D' backward-word
    bindkey -M viins '^[[1;5D' backward-word
    bindkey -M vicmd '^[[1;5D' backward-word
fi

# Ctrl-Right moves forward one word
if [ -n "${terminfo[kRIT5]}" ]; then
    bindkey -M emacs "${terminfo[kRIT5]}" forward-word
    bindkey -M viins "${terminfo[kRIT5]}" forward-word
    bindkey -M vicmd "${terminfo[kRIT5]}" forward-word
else
    bindkey -M emacs '^[[1;5C' forward-word
    bindkey -M viins '^[[1;5C' forward-word
    bindkey -M vicmd '^[[1;5C' forward-word
fi

# PageUp goes backwards in history
if [ -n "${terminfo[kpp]}" ]; then
    bindkey -M emacs "${terminfo[kpp]}" up-line-or-history
    bindkey -M viins "${terminfo[kpp]}" up-line-or-history
    bindkey -M vicmd "${terminfo[kpp]}" up-line-or-history
fi

# PageDown goes forward in history
if [ -n "${terminfo[knp]}" ]; then
  bindkey -M emacs "${terminfo[knp]}" down-line-or-history
  bindkey -M viins "${terminfo[knp]}" down-line-or-history
  bindkey -M vicmd "${terminfo[knp]}" down-line-or-history
fi

# Home goes to the beginning of the line
if [ -n "${terminfo[khome]}" ]; then
    bindkey -M emacs "${terminfo[khome]}" beginning-of-line
    bindkey -M viins "${terminfo[khome]}" beginning-of-line
    bindkey -M vicmd "${terminfo[khome]}" beginning-of-line
fi

# End goes to the end of the line
if [ -n "${terminfo[kend]}" ]; then
    bindkey -M emacs "${terminfo[kend]}"  end-of-line
    bindkey -M viins "${terminfo[kend]}"  end-of-line
    bindkey -M vicmd "${terminfo[kend]}"  end-of-line
fi
