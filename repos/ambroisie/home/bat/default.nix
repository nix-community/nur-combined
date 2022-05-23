{ config, lib, ... }:
let
  cfg = config.my.home.bat;
in
{
  options.my.home.bat = with lib.my; {
    enable = mkDisableOption "bat configuration";
  };

  config.programs.bat = lib.mkIf cfg.enable {
    enable = true;
    config = {
      theme = "gruvbox-dark";

      pager = with config.home.sessionVariables; "${PAGER} ${LESS}";
    };
  };
}
