# load set-environment on shell start
if test -f /etc/set-environment; then
    . /etc/set-environment
fi

if [ -f ~/.setup_nix_path ]; then
    loadDotfilesEnv
fi

if [ -d ~/.dotfiles ]; then
    source ~/.dotfiles/bin/source_me
elif [ -d /etc/.dotfiles ]; then
    source /etc/.dotfiles/bin/source_me
fi
