{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.firefox.tridactyl;

  term = config.my.home.terminal.program;

  vimCommandLine = {
    alacritty = ''-e "vim" "%f" "+normal!%lGzv%c|"'';
    # Termite wants the whole command in a single argument...
    termite = ''-e "vim %f '+normal!%lGzv%c|'"'';
  };
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."tridactyl/tridactylrc".source = pkgs.substituteAll {
      src = ./tridactylrc;

      editorcmd = lib.concatStringsSep " " [
        # Use my configured terminal
        term
        # Make it easy to pick out with a window class name
        "--class tridactyl_editor"
        # Open vim with the cursor in the correct position
        vimCommandLine.${term}
      ];
    };
  };
}
