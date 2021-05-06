{ config, lib, pkgs, ... }:
let
  cfg = config.my.bluetooth;
  mkRelatedOption = desc: lib.mkEnableOption desc // { default = cfg.enable; };
in
{
  options.my.bluetooth = with lib; {
    enable = mkEnableOption "wireless configuration";

    enableHeadsetIntegration = mkRelatedOption "A2DP sink configuration";

    loadExtraCodecs = mkRelatedOption "extra audio codecs";
  };

  config = lib.mkMerge [
    # Enable bluetooth devices and GUI to connect to them
    (lib.mkIf cfg.enable {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
    })

    # Support for additional bluetooth codecs
    (lib.mkIf cfg.loadExtraCodecs {
      hardware.pulseaudio = {
        extraModules = [ pkgs.pulseaudio-modules-bt ];
        package = pkgs.pulseaudioFull;
      };
    })

    # Support for A2DP audio profile
    (lib.mkIf cfg.enableHeadsetIntegration {
      hardware.bluetooth.settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    })
  ];
}
