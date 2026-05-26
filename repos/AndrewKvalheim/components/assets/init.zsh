# Generated variables
export DIRENV_LOG_FORMAT="$(print -P "%B%F{8}┃ %%s%f")"
TIMEFMT="$(print -P "%B%F{8}┃ Duration: %%*Es, CPU: %%P, Memory: %%MkB%f")"

# Syntax highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main regexp)
ZSH_HIGHLIGHT_REGEXP+=('^[[:blank:][:space:]]*('${(j:|:)${(k)ABBR_REGULAR_USER_ABBREVIATIONS}}')$' 'fg=cyan,bold')
ZSH_HIGHLIGHT_STYLES[arg0]='fg=white,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=white,italic'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=cyan'

# Completions
compdef '_values passwords $(gopass ls --flat)' gopass-env
compdef '_values passwords $(gopass ls --flat)' gopass-ydotool
