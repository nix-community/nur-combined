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
    };
  };
}
