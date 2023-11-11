{ config, lib, ... }:
let
  cfg = config.my.home.bluetooth;
in
{
  options.my.home.bluetooth = with lib; {
    enable = mkEnableOption "bluetooth configuration";
  };

  config = lib.mkIf cfg.enable {
    services.blueman-applet = {
      enable = true;
    };

    services.mpris-proxy = {
      enable = true;
    };
  };
}
