export NIX_SHELL_PRESERVE_PROMPT="1";
export PS1='\u@\h \w $?\$ \[$(tput sgr0)\]';

# load set-environment on shell start
if test -f /etc/set-environment; then
    . /etc/set-environment
fi

# PS1 workaround for nix-shell
if test -v IN_NIX_SHELL; then
    PS1="(shell:$IN_NIX_SHELL) $PS1"
fi

