ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
CASE_SENSITIVE="false"
DISABLE_AUTO_UPDATE="true"
#export UPDATE_ZSH_DAYS=13
DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"
# DISABLE_CORRECTION="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# plugins=(git vagrant osx capistrano rails ruby tmuxinator)
plugins=(ssh-agent)
source $ZSH/oh-my-zsh.sh
PROMPT="%n@%m"$PROMPT
