# Options
setopt COMBINING_CHARS
setopt HIST_FIND_NO_DUPS
setopt INTERACTIVE_COMMENTS
setopt LIST_PACKED
setopt LONG_LIST_JOBS
setopt NOCLOBBER
setopt PUSHD_SILENT
setopt RC_QUOTES

# Generated variables
export DIRENV_LOG_FORMAT="$(print -P "%B%F{8}┃ %%s%f")"
TIMEFMT="$(print -P "%B%F{8}┃ Duration: %%*Es, CPU: %%P, Memory: %%MkB%f")"

# Keybindings
bindkey '^H' backward-kill-word # Ctrl+Backspace
bindkey '\e[1;5D' backward-word # Ctrl+Left
bindkey '\e[1;5C' forward-word # Ctrl+Right
bindkey '^Z' undo # Ctrl+Z

# Completions
zstyle '*' single-ignored show
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list \
  'm:{[:lower:]}={[:upper:]}' `# a ⇒ [aA], A ⇒ A` \
  'l:|=* r:|=*' `# b ⇒ ab`
zstyle ':completion:*' squeeze-slashes 'true'
zstyle ':completion:*:*:*:*:*' menu 'select'
zstyle ':completion:*:*:*:users' ignored-patterns \
  'avahi' 'colord' 'cups' 'gdm' 'geoclue' 'messagebus' 'nixbld*' \
  'nm-*' 'polkituser' 'postfix' 'qemu-*' 'rpc' 'rtkit' 'systemd*'
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%B%F{8}# %d%f'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*:manuals' separate-sections 'true'
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:warnings' format '%B%F{8}# No matches%f'
zstyle ':completion:*:*:extract-pdf-images:*' file-patterns '*.pdf:all-files *(-/):directories'
compdef '_values passwords $(gopass ls --flat)' gopass-env
compdef '_values passwords $(gopass ls --flat)' gopass-ydotool

# Abbreviations
source @zsh-abbr@

# Syntax highlighting
source @zsh-syntax-highlighting@
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main regexp)
ZSH_HIGHLIGHT_REGEXP+=('^[[:blank:][:space:]]*('${(j:|:)${(k)ABBR_REGULAR_USER_ABBREVIATIONS}}')$' 'fg=blue,bold')
ZSH_HIGHLIGHT_STYLES[arg0]='fg=white,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=white,italic'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=blue'

# Powerlevel10k
source @zsh-powerlevel10k@
source ~/.p10k.zsh

# Terminal title
zstyle ':prezto:module:terminal' auto-title 'yes'
zstyle ':prezto:module:terminal:multiplexer-title' format '%1~'
zstyle ':prezto:module:terminal:tab-title' format '%1~'
zstyle ':prezto:module:terminal:window-title' format '%1~'
source @zsh-prezto-terminal@

# Click
source @zsh-click@

# Procedural aliases
extract-pdf-images() { mkdir "${1%.pdf}" && @pdfimages@ -all -p "$1" "${1%.pdf}/${1%.pdf}" }
idiff() { compare "$@" png:- | kitty +kitten icat }
mkcd() { mkdir --parents "$@" && cd "${@:$#}" }
nest() { mv --no-clobber --verbose "$1" "$1.original" && mkdir "$1" && mv --no-clobber --verbose "$1.original" "$1/$(basename "$1")" }
rd() { diff --recursive --unified "$@" | delta }
rdw() { diff --ignore-all-space --ignore-blank-lines --recursive --unified "$@" | delta }
rmdir-all() { find "$@" -type 'd' -empty -delete }
