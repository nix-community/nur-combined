{ config, lib, ... }:
let
  cfg = config.my.hardware.sound;
in
{
  options.my.hardware.sound = with lib; {
    enable = mkEnableOption "sound configuration";

    pipewire = {
      enable = mkEnableOption "pipewire configuration";
    };

    pulse = {
      enable = mkEnableOption "pulseaudio configuration";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Basic configuration
    {
      sound.enable = true;
    }

    (lib.mkIf cfg.pipewire.enable {
      # RealtimeKit is recommended
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;

        alsa = {
          enable = true;
          support32Bit = true;
        };

        pulse = {
          enable = true;
        };

        jack = {
          enable = true;
        };

        media-session = {
          enable = true;
        };
      };
    })

    # Pulseaudio setup
    (lib.mkIf cfg.pulse.enable {
      hardware.pulseaudio.enable = true;
    })
  ]);
}
