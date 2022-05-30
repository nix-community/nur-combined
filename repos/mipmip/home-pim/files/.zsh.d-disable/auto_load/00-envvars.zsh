
#export COMPOSE_PROJECT_NAME=redash
#export COMPOSE_FILE=/opt/redash/docker-compose.yml
case `uname` in
  Darwin)
    export PATH="$PATH:/usr/local/bin"
    export PATH="$PATH:/usr/local/sbin"
    export PATH="$PATH:/usr/local/MacGPG2/bin"
    export PATH="$PATH:/usr/local/opt/gnu-getopt/bin"
    export PATH="$PATH:/usr/local/texlive/2019basic/bin/x86_64-darwin"

    export PATH="$PATH:/opt/local/bin"
    export PATH="$PATH:/opt/local/sbin"
    export PATH="$PATH:/opt/X11/bin"
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    export EDITOR="/usr/local/bin/vim"

    export LANG="nl_NL.UTF-8"
    export LC_COLLATE="nl_NL.UTF-8"
    export LC_CTYPE="nl_NL.UTF-8"
    export LC_MESSAGES="nl_NL.UTF-8"
    export LC_MONETARY="nl_NL.UTF-8"
    export LC_NUMERIC="nl_NL.UTF-8"
    export LC_TIME="nl_NL.UTF-8"

    ;;
  Linux)
    GTK_THEME=Default
    EDITOR="vim"
    ;;
esac

export PATH="$PATH:/bin"
export PATH="$PATH:/sbin"
export PATH="$PATH:$HOME/.nix-profile/bin"

export PATH="$PATH:/usr/bin"
export PATH="$PATH:/usr/sbin"

export PATH="$PATH:$HOME/.bin"
#export PATH="$PATH:$HOME/.pyenv/bin"
#export PATH="$PATH:$HOME/.rbenv/bin"
#export PATH="$HOME/.rbenv/shims:$PATH"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/go/bin"

export PATH="$PATH:$HOME/Library/Python/3.7/bin"

export PYENV_ROOT="$HOME/.pyenv"
export NNN_DE_FILE_MANAGER=open
export GOPATH=~/go
#export XDG_DATA_DIRS=/home/pim/.local/share/gnome-shell/extensions/hotkeys-popup@pimsnel.com/schemas:$XDG_DATA_DIRS
