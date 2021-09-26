{ config, lib, ... }:
let
  cfg = config.my.home.power-alert;
in
{
  options.my.home.power-alert = with lib; {
    enable = mkEnableOption "power-alert configuration";
  };

  config = lib.mkIf cfg.enable {
    services.poweralertd = {
      enable = true;
    };
  };
}
