echo_debug "DEBUG: sourcing ~/.zshrc"

for i in $ZAUTOLOADDIR/auto_load/*.zsh
do
  echo_debug "DEBUG: sourcing $i"
  source $i
done

print_env_vars

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
#[[ -f /Users/pim/cClones/gitlab-time-tracker-taskbar/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /Users/pim/cClones/gitlab-time-tracker-taskbar/node_modules/tabtab/.completions/electron-forge.zsh
#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
