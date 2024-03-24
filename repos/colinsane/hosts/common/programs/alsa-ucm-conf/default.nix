{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.alsa-ucm-conf;
in
{
  sane.programs.alsa-ucm-conf = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.preferEarpiece = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    # upstream alsa ships with PinePhone audio configs, but they don't actually produce sound.
    # see: <https://github.com/alsa-project/alsa-ucm-conf/pull/134>
    # these audio files come from some revision of:
    # - <https://gitlab.manjaro.org/manjaro-arm/packages/community/phosh/alsa-ucm-pinephone>
    #
    # alternative to patching is to plumb `ALSA_CONFIG_UCM2 = "${./ucm2}"` environment variable into the relevant places
    # e.g. `systemd.services.pulseaudio.environment`.
    # that leaves more opportunity for gaps (i.e. missing a service),
    # on the other hand this method causes about 500 packages to be rebuilt (including qt5 and webkitgtk).
    #
    # note that with these files, the following audio device support:
    # - headphones work.
    # - "internal earpiece" works.
    # - "internal speaker" doesn't work (but that's probably because i broke the ribbon cable)
    # - "analog output" doesn't work.
    packageUnwrapped = pkgs.alsa-ucm-conf.overrideAttrs (upstream: {
      postPatch = (upstream.postPatch or "") + ''
        cp ${./ucm2/PinePhone}/* ucm2/Allwinner/A64/PinePhone/

        # fix the self-contained ucm files i source from to have correct path within the alsa-ucm-conf source tree
        substituteInPlace ucm2/Allwinner/A64/PinePhone/PinePhone.conf \
          --replace-fail 'HiFi.conf' '/Allwinner/A64/PinePhone/HiFi.conf'
        substituteInPlace ucm2/Allwinner/A64/PinePhone/PinePhone.conf \
          --replace-fail 'VoiceCall.conf' '/Allwinner/A64/PinePhone/VoiceCall.conf'
      '' + lib.optionalString cfg.config.preferEarpiece ''
        # decrease the priority of the internal speaker so that sounds are routed
        # to the earpiece by default.
        # this is just personal preference.
        substituteInPlace ucm2/Allwinner/A64/PinePhone/{HiFi.conf,VoiceCall.conf} \
          --replace-fail 'PlaybackPriority 300' 'PlaybackPriority 100'
      '';
    });

    sandbox.enable = false;  #< only provides #out/share/alsa

    # alsa-lib package only looks in its $out/share/alsa to find runtime config data, by default.
    # but ALSA_CONFIG_UCM2 is an env var that can override that.
    # this is particularly needed by wireplumber;
    #   also *maybe* pipewire and pipewire-pulse.
    # taken from <repo:nixos/mobile-nixos:modules/quirks/audio.nix>
    env.ALSA_CONFIG_UCM2 = "/run/current-system/sw/share/alsa/ucm2";

    enableFor.system = lib.mkIf (builtins.any (en: en) (builtins.attrValues cfg.enableFor.user)) true;
  };

  environment.pathsToLink = lib.mkIf cfg.enabled [
    "/share/alsa/ucm2"
  ];
}
