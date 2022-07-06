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
      eval "$(direnv hook bash)"
      if test -f /etc/set-environment; then
        . /etc/set-environment
      fi
    '';
  };
}
