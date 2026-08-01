{ lib, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = lib.mkForce "ls -F --color=auto --show-control-chars";
      open = "xdg-open";
      o = "xdg-open";
    };
    bashrcExtra = "\n
      # If not running interactively, don't do anything
      [[ $- != *i* ]] && return

      export GPG_TTY=$(tty)
      
      parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \\(.*\\)/ (\\1)/'
      }
      
      function parse_nix_shell() {
        if [[ -n \"\$IN_NIX_SHELL\" ]]; then
          echo \"  \"
        fi
      }

      PS1='\\n\\[\\033[01;34m\\]\\w\\[\\033[1;35m\\]$(parse_git_branch)\\[\\033[1;36m\\]$(parse_nix_shell)\\[\\033[00m\\]\\n\\$ '
      
      PROMPT_DIRTRIM=2
      
      # ignore upper and lowercase when TAB completion
      bind \"set completion-ignore-case on\"
      
      # Deny overwriting
      set -o noclobber
      
      if [ \"$TERM\" = \"linux\" ]; then
        echo -en \"\\e]P05A6374\" #black
        echo -en \"\\e]P8282C34\" #darkgrey
        echo -en \"\\e]P1E06C75\" #darkred
        echo -en \"\\e]P9E06C75\" #red
        echo -en \"\\e]P298C379\" #darkgreen
        echo -en \"\\e]PA98C379\" #green
        echo -en \"\\e]P3E5C07B\" #brown
        echo -en \"\\e]PBE5C07B\" #yellow
        echo -en \"\\e]P461AFEF\" #darkblue
        echo -en \"\\e]PC61AFEF\" #blue
        echo -en \"\\e]P5C678DD\" #darkmagenta
        echo -en \"\\e]PDC678DD\" #magenta
        echo -en \"\\e]P656B6C2\" #darkcyan
        echo -en \"\\e]PE56B6C2\" #cyan
        echo -en \"\\e]P7DCDFE4\" #lightgrey
        echo -en \"\\e]PFDCDFE4\" #white
        clear #for background artifacting
      fi
      
      fet.sh
      
      # if uwsm check may-start && uwsm select; then
      # 	exec systemd-cat -t uwsm_start uwsm start default
      # fi
      
      if uwsm check may-start; then
        # exec uwsm start hyprland.desktop
        # exec uwsm start hyprland-systemd.desktop
        exec uwsm start hyprland-uwsm.desktop
      fi
    ";
  };

}
