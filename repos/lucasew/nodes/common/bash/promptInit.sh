export PATH="$PATH:$HOME/.yarn/bin"

mkcd(){ [ ! -z "$1" ] && mkdir -p "$1" && cd "$_"; }

# direnv
eval "$(direnv hook bash)"

function title() {
    if [[ -z "$ORIG" ]]; then
        ORIG=$PS1
    fi
    TITLE="\[\e]2;$*\a\]"
    PS1=${ORIG}${TITLE}
}
# add scripts from bin folder in dotfiles to PATH
if [[ -v NIXCFG_ROOT_PATH ]]; then
    PATH=$PATH:$NIXCFG_ROOT_PATH/bin
else
    PATH=$PATH:~/.dotfiles/bin
fi
