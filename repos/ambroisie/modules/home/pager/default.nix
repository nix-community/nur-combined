{ config, lib, ... }:
let
  cfg = config.my.home.pager;
in
{
  options.my.home.pager = with lib; {
    enable = my.mkDisableOption "pager configuration";
  };


  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      # My default pager
      PAGER = "less";
      # Clear the screen on start and exit
      LESS = "-R -+X -c";
      # Better XDG compliance
      LESSHISTFILE = "${config.xdg.stateHome}/less/history";
    };

    xdg.configFile."lesskey".text = ''
      # Quit without clearing the screen on `Q`
      Q toggle-option -!^Predraw-on-quit\nq
    '';
  };
}
