{ config, pkgs, ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      export EDITOR="nvim"
      export PS1="\u@\h \w \$?\\$ \[$(tput sgr0)\]"
      export PATH="$PATH:~/.yarn/bin/"
      source ~/.dotfilerc
      alias la="ls -a"
      alias ncdu="rclone ncdu . 2> /dev/null"
      alias sqlite3="${pkgs.rlwrap}/bin/rlwrap sqlite3"
    '';
  };
}
