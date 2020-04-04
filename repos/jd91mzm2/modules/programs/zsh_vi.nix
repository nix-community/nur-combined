{ config, lib, ... }:

with lib;

let
  cfg = config.programs.zsh.vi;
in
{
  options.programs.zsh.vi = {
    enable = mkEnableOption "ZSH vi bindings";
  };
  config.programs.zsh = mkIf cfg.enable {
    enable = true;
    interactiveShellInit = mkAfter ''
      # Vi keybindings
      bindkey -v
      export KEYTIMEOUT=1

      # Sync with cursor
      vi-mode-cursor() {
        case $KEYMAP in
          vicmd)
            echo -ne "\e[0 q"
            ;;
          viins|main)
            echo -ne "\e[5 q"
            ;;
        esac
      }
      zle -N zle-keymap-select vi-mode-cursor
      zle -N zle-line-init vi-mode-cursor
    '';
  };
}
