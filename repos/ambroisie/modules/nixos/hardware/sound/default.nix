{ config, lib, ... }:
let
  cfg = config.my.hardware.sound;
in
{
  options.my.hardware.sound = with lib; {
    pipewire = {
      enable = mkEnableOption "pipewire configuration";
    };

    pulse = {
      enable = mkEnableOption "pulseaudio configuration";
    };
  };

  config = (lib.mkMerge [
    # Sanity check
    {
      assertions = [
        {
          assertion = builtins.all (lib.id) [
            (cfg.pipewire.enable -> !cfg.pulse.enable)
            (cfg.pulse.enable -> !cfg.pipewire.enable)
          ];
          message = ''
            `config.my.hardware.sound.pipewire.enable` and
            `config.my.hardware.sound.pulse.enable` are incompatible.
          '';
        }
      ];
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
      };
    })

    # Pulseaudio setup
    (lib.mkIf cfg.pulse.enable {
      # ALSA
      sound.enable = true;

      hardware.pulseaudio.enable = true;
    })
  ]);
}
