# Fix delete key not working
bindkey "\e[3~" delete-char

# Fix Ctrl+u killing from the cursor instead of the whole line
bindkey '^u' backward-kill-line

# Use Ctrl+x-(Ctrl+)e to edit the current command line in VISUAL/EDITOR
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

# Enable Shift-Tab to go backwards in completion list
bindkey '^[[Z' reverse-menu-complete
