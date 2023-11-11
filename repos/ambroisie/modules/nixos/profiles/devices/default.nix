{ config, lib, ... }:
let
  cfg = config.my.profiles.devices;
in
{
  options.my.profiles.devices = with lib; {
    enable = mkEnableOption "devices profile";
  };

  config = lib.mkIf cfg.enable {
    my.hardware = {
      ergodox.enable = true;

      mx-ergo.enable = true;
    };

    # MTP devices auto-mount via file explorers
    services.gvfs.enable = true;
  };
}
