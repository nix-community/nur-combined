{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.firefox.tridactyl;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."tridactyl/tridactylrc".source = pkgs.substituteAll {
      src = ./tridactylrc;

      editorcmd = lib.concatStringsSep " " [
        # Use my configured terminal
        config.my.home.terminal.program
        # Make it easy to pick out with a window class name
        "--class tridactyl_editor"
        # Open vim with the cursor in the correct position
        ''-e "vim %f '+normal!%lGzv%c|'"''
      ];
    };
  };
}
