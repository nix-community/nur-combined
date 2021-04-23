{ config, lib, ... }:
let
  cfg = config.my.home.pager;
in
{
  options.my.home.pager = with lib.my; {
    enable = mkDisableOption "pager configuration";
  };

  config.programs.lesspipe.enable = cfg.enable;

  config.home.sessionVariables = lib.mkIf cfg.enable {
    # My default pager
    PAGER = "less";
    # Clear the screen on start and exit
    LESS = "-R -+X -c";
  };
}
