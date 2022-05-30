it2prof() { echo -e "\033]50;SetProfile=$1\a" }

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

