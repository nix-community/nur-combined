{ config, lib, pkgs, options, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    optionalAttrs
  ;

  cfg = config.my.services.pipewire;
  my = config.my;
in
{
  options.my.services.pipewire = {
    enable = mkEnableOption "Pipewire sound backend";
  };

  # HACK: services.pipewire.alsa doesn't exist on 20.09, avoid evaluating this
  # config (my 20.09 machine is a server anyway)
  config = optionalAttrs (options ? services.pipewire.alsa) (mkIf cfg.enable {
    # from NixOS wiki, causes conflicts with pipewire
    sound.enable = false;
    # recommended for pipewire as well
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;

      media-session = {
        enable = true;
        config.bluez-monitor.rules = [
          {
            # Matches all cards
            matches = [{ "device.name" = "~bluez_card.*"; }];
            actions = {
              "update-props" = {
                "bluez5.reconnect-profiles" = [
                  "a2dp_sink"
                  "hfp_hf"
                  "hsp_hs"
                ];
                # mSBC provides better audio + microphone
                "bluez5.msbc-support" = true;
                # SBC XQ provides better audio
                "bluez5.sbc-xq-support" = true;
              };
            };
          }
          {
            matches = [
              # Matches all sources
              {
                "node.name" = "~bluez_input.*";
              }
              # Matches all outputs
              {
                "node.name" = "~bluez_output.*";
              }
            ];
            actions = {
              "node.pause-on-idle" = false;
            };
          }
        ];
      };
    };

    # FIXME: a shame pactl isn't available by itself, eventually this should be
    #        replaced by pw-cli or a wrapper, I guess?
    environment.systemPackages = [ pkgs.pulseaudio ];
  });
}
