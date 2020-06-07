{ config, lib, pkgs, ... }:

with lib;
let
  sources = import ../../nix/sources.nix;
  cfg = config.profiles.nix-config;
in
{
  options = {
    profiles.nix-config = {
      enable = mkOption {
        default = true;
        description = "Enable nix-config profile";
        type = types.bool;
      };
      gcDates = mkOption {
        default = "weekly";
        description = "Specification (in the format described by systemd.time(7)) of the time at which the garbage collector will run. ";
        type = types.str;
      };
      olderThan = mkOption {
        default = "15d";
        description = "Number of day to keep when garbage collect";
        type = types.str;
      };
      buildCores = mkOption {
        type = types.int;
        default = 2;
        example = 4;
        description = ''
          Maximum number of concurrent tasks during one build.
        '';
      };
      localCaches = mkOption {
        default = [ "http://nix.cache.home" ];
        description = "List of local nix caches";
        type = types.listOf types.str;
      };
    };
  };
  config = mkIf cfg.enable {
    nix = {
      buildCores = cfg.buildCores;
      useSandbox = true;
      gc = {
        automatic = true;
        dates = cfg.gcDates;
        options = "--delete-older-than ${cfg.olderThan}";
      };
      nixPath = [
        "nixpkgs=${sources.nixos}"
        "nixos-config=/etc/nixos/configuration.nix"
        "nixpkgs-overlays=/etc/nixos/overlays/compat"
      ];
      # if hydra is down, don't wait forever
      extraOptions = ''
        connect-timeout = 20
        build-cores = 0
        keep-outputs = true
        keep-derivations = true
      '';
      binaryCaches = cfg.localCaches ++ [
        "https://cache.nixos.org/"
        "https://r-ryantm.cachix.org"
        "https://vdemeester.cachix.org"
        "https://shortbrain.cachix.org"
      ];
      binaryCachePublicKeys = [
        "r-ryantm.cachix.org-1:gkUbLkouDAyvBdpBX0JOdIiD2/DP1ldF3Z3Y6Gqcc4c="
        "vdemeester.cachix.org-1:uCECG6so7v1rs77c5NFz2dCePwd+PGNeZ6E5DrkT7F0="
        "shortbrain.cachix.org-1:dqXcXzM0yXs3eo9ChmMfmob93eemwNyhTx7wCR4IjeQ="
        "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
      ];
      trustedUsers = [ "root" "vincent" ];
    };
    nixpkgs = {
      overlays = [
        (import ../../overlays/sbr.nix)
        (import ../../overlays/unstable.nix)
        (import ../../nix).emacs
      ];
      config = {
        allowUnfree = true;
        packageOverrides = pkgs: {
          nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
            inherit pkgs;
          };
        };
      };
    };
  };
}
