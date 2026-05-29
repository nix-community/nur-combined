{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.firefox.tridactyl;

  term = config.my.home.terminal.default;

  vimCommandLine =
    let
      # Termite wants the whole command in a single argument...
      brokenExecCommand = {
        termite = true;
      };
      # Assume most other terminals are sane and not broken...
      isBroken = brokenExecCommand.${term} or false;
    in
    if isBroken then
      ''-e "vim %f '+normal!%lGzv%c|'"''
    else
      ''-e "vim" "%f" "+normal!%lGzv%c|"'';
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."tridactyl/tridactylrc".source = pkgs.replaceVars ./tridactylrc {
      editorcmd = lib.concatStringsSep " " [
        # Use my configured terminal
        term
        # Make it easy to pick out with a window class name
        "--title=tridactyl_editor"
        # Open vim with the cursor in the correct position
        vimCommandLine
      ];
    };
  };
}
