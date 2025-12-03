{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.alsa-ucm-conf;
  deprioritize = pkg: pkg.overrideAttrs (base: {
      meta = (base.meta or {}) // {
        # let the other alsa ucm packages override configs from this one
        priority = ((base.meta or {}).priority or 10) + 20;
      };
  });
  alsa-ucm-latest = pkgs.alsa-ucm-conf.overrideAttrs (upstream: rec {
    # XXX(2025-07-18): see <https://github.com/NixOS/nixpkgs/pull/414818>
    version = "1.2.14";
    src = lib.warnIf (lib.versionAtLeast upstream.version "1.2.14") "upstream alsa-ucm-conf is up to date with my own: remove override?" pkgs.fetchurl {
      url = "mirror://alsa/lib/alsa-ucm-conf-${version}.tar.bz2";
      hash = "sha256-MumAn1ktkrl4qhAy41KTwzuNDx7Edfk3Aiw+6aMGnCE=";
    };
    installPhase = lib.replaceStrings
      [ ''for file in "''${files[@]}"'' ]
      [ ''for file in ucm2/common/ctl/led.conf'' ]
      upstream.installPhase
    ;
  });
in
{
  sane.programs.alsa-ucm-conf = {
    packageUnwrapped = deprioritize pkgs.alsa-ucm-conf;
    # packageUnwrapped = deprioritize alsa-ucm-latest;
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
