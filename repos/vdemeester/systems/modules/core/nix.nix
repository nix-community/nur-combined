{ config, lib, pkgs, ... }:

with lib;
let
  dummyConfig = pkgs.writeText "configuration.nix" ''
    # assert builtins.trace "This is a dummy config, use switch!" false;
    {}
  '';
  cfg = config.core.nix;
in
{
  options = {
    core.nix = {
      enable = mkOption { type = types.bool; default = true; description = "Enable core.nix"; };
      gcDates = mkOption {
        default = "daily";
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
    environment.systemPackages = [ pkgs.git ];
    nix = {
      allowedUsers = [ "@wheel" ];
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
      buildCores = cfg.buildCores;
      daemonIONiceLevel = 5;
      daemonNiceLevel = 10;
      # if hydra is down, don't wait forever
      extraOptions = ''
        connect-timeout = 20
        build-cores = 0
        keep-outputs = true
        keep-derivations = true
      '';
      gc = {
        automatic = true;
        dates = cfg.gcDates;
        options = "--delete-older-than ${cfg.olderThan}";
      };
      nixPath = [
        "nixos-config=${dummyConfig}"
        "nixpkgs=/run/current-system/nixpkgs"
        "nixpkgs-overlays=/run/current-system/overlays/compat"
      ];
      optimise = {
        automatic = true;
        dates = [ "01:10" "12:10" ];
      };
      nrBuildUsers = config.nix.maxJobs * 2;
      trustedUsers = [ "root" "@wheel" ];
      useSandbox = true;
    };

    nixpkgs = {
      overlays = [
        (import ../../../overlays/mkSecret.nix)
        (import ../../../overlays/sbr.nix)
        (import ../../../overlays/unstable.nix)
        (import ../../../nix).emacs
      ];
      config = {
        allowUnfree = true;
      };
    };
    system = {
      extraSystemBuilderCmds = ''
        ln -sv ${pkgs.path} $out/nixpkgs
        ln -sv ${../../../overlays} $out/overlays
      '';

      stateVersion = "20.03";
    };
  };
}
