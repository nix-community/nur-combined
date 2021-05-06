{ config, lib, ... }:
let
  cfg = config.my.home.nm-applet;
in
{
  options.my.home.nm-applet = with lib; {
    enable = mkEnableOption "network-manager-applet configuration";
  };

  config.services.network-manager-applet = lib.mkIf cfg.enable {
    enable = true;
  };
}
