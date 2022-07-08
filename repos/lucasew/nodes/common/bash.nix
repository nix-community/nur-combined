{...}: {
  programs.bash = {
    shellAliases = {
      "la" = "ls -a";
      "cd.." = "cd ..";
      ".." = "cd ..";
      "simbora"="git add -A && git commit --amend && git push origin master -f";
    };
    promptInit = ''
      export PATH="$PATH:$HOME/.yarn/bin"

      mkcd(){ [ ! -z "$1" ] && mkdir -p "$1" && cd "$_"; }

      # direnv
      eval "$(direnv hook bash)"

      # load set-environment on shell start
      if test -f /etc/set-environment; then
        . /etc/set-environment
      fi

      # PS1 workaround for nix-shell
      if test -v IN_NIX_SHELL; then
        PS1="(shell:$IN_NIX_SHELL) $PS1"
      fi

      # add scripts from bin folder in dotfiles to PATH
      if [[ -v NIXCFG_ROOT_PATH ]]; then
        PATH=$PATH:$NIXCFG_ROOT_PATH/bin
      else
        PATH=$PATH:~/.dotfiles/bin
      fi
    '';
  };
}
