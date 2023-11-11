{ config, lib, ... }:
let
  cfg = config.my.profiles.bluetooth;
in
{
  options.my.profiles.bluetooth = with lib; {
    enable = mkEnableOption "bluetooth profile";
  };

  config = lib.mkIf cfg.enable {
    my.hardware.bluetooth.enable = true;

    my.home.bluetooth.enable = true;
  };
}
