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
    # - still true as of 2024-05-26
    # - see: <https://github.com/alsa-project/alsa-ucm-conf/pull/134>
    #
    # we can substitute working UCM conf in two ways:
    # 1. nixpkgs' override for the `alsa-ucm-conf` package
    #   - that forces a rebuild of ~500 packages (including webkitgtk).
    # 2. set ALSA_CONFIG_UCM2 = /path/to/ucm2 in the relevant places
    #   - e.g. pulsewire service.
    #   - easy to miss places, though.
    #
    # alsa-ucm-pinephone-manjaro (2024-05-26):
    # - headphones work
    # - "internal earpiece" works
    # - "internal speaker" is silent (maybe hardware issue)
    # - 3.5mm connection is flapping when playing to my car, which eventually breaks audio and requires restarting wireplumber
    # packageUnwrapped = pkgs.alsa-ucm-pinephone-manjaro.override {
    #   inherit (cfg.config) preferEarpiece;
    # };
    # alsa-ucm-pinephone-pmos (2024-05-26):
    # - headphones work
    # - "internal earpiece" works
    # - "internal speaker" is silent (maybe hardware issue)
    packageUnwrapped = pkgs.alsa-ucm-pinephone-pmos.override {
      inherit (cfg.config) preferEarpiece;
    };

    sandbox.enable = false;  #< only provides $out/share/alsa

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
