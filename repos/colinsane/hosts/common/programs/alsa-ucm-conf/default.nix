{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.alsa-ucm-conf;
in
{
  sane.programs.alsa-ucm-conf = {
    packageUnwrapped = pkgs.alsa-ucm-conf.overrideAttrs (base: {
      meta = (base.meta or {}) // {
        # let the other alsa ucm packages override configs from this one
        priority = ((base.meta or {}).priority or 10) + 20;
      };
    });
    sandbox.enable = false;  #< only provides $out/share/alsa

    # alsa-lib package only looks in its $out/share/alsa to find runtime config data, by default.
    # but ALSA_CONFIG_UCM2 is an env var that can override that.
    # this is particularly needed by wireplumber;
    #   also *maybe* pipewire and pipewire-pulse.
    # taken from <repo:nixos/mobile-nixos:modules/quirks/audio.nix>
    # the other option is to `override` pkgs.alsa-ucm-conf,
    # but that triggers 500+ rebuilds
    env.ALSA_CONFIG_UCM2 = "/run/current-system/sw/share/alsa/ucm2";

    enableFor.system = lib.mkIf (builtins.any (en: en) (builtins.attrValues cfg.enableFor.user)) true;
  };

  environment.pathsToLink = lib.mkIf cfg.enabled [
    "/share/alsa/ucm2"
  ];
}
