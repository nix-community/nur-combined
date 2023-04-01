{ config, lib, pkgs, ... }:
let
  cfg = config.my.hardware.bluetooth;
in
{
  options.my.hardware.bluetooth = with lib; {
    enable = mkEnableOption "bluetooth configuration";

    enableHeadsetIntegration = my.mkDisableOption "A2DP sink configuration";

    loadExtraCodecs = my.mkDisableOption "extra audio codecs";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Enable bluetooth devices and GUI to connect to them
    {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
    }

    # Support for additional bluetooth codecs
    (lib.mkIf cfg.loadExtraCodecs {
      hardware.pulseaudio = {
        extraModules = [ pkgs.pulseaudio-modules-bt ];
        package = pkgs.pulseaudioFull;
      };

      environment.etc = {
        "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
          bluez_monitor.properties = {
            -- SBC XQ provides better audio
            ["bluez5.enable-sbc-xq"] = true,

            -- mSBC provides better audio + microphone
            ["bluez5.enable-msbc"] = true,

            -- Synchronize volume with bluetooth device
            ["bluez5.enable-hw-volume"] = true,

            -- FIXME: Some devices may now support both hsp_ag and hfp_ag
            ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
          }
        '';
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
  ]);
}
