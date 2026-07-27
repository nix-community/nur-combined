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
        default = [ ];
        description = "List of local nix caches";
        type = types.listOf types.str;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.git ];
    nix = {
      settings = {
        cores = cfg.buildCores;
        substituters = cfg.localCaches ++ [
          "https://cache.nixos.org/"
          "https://r-ryantm.cachix.org"
          "https://shortbrain.cachix.org"
          "https://vdemeester.cachix.org"
          "https://chapeau-rouge.cachix.org"
	  "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "r-ryantm.cachix.org-1:gkUbLkouDAyvBdpBX0JOdIiD2/DP1ldF3Z3Y6Gqcc4c="
          "shortbrain.cachix.org-1:dqXcXzM0yXs3eo9ChmMfmob93eemwNyhTx7wCR4IjeQ="
          "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
          "chapeau-rouge.cachix.org-1:r34IG766Ez4Eeanr7Zx+egzXLE2Zgvc+XRspYZPDAn8="
          "vdemeester.cachix.org-1:eZWNOrLR9A9szeMahn9ENaoT9DB3WgOos8va+d2CU44="
	  "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };
      # On laptops at least, make the daemon and builders low priority
      # to have a responding system while building
      daemonIOSchedClass = "idle";
      daemonCPUSchedPolicy = "idle";
      # FIXME: On servers, we may change this.
      # daemonIOSchedPriority = 5;
      # daemonCPUSchedPolicy = "batch";

      # if hydra is down, don't wait forever
      extraOptions = ''
        connect-timeout = 20
        build-cores = 0
        keep-outputs = true
        keep-derivations = true
        builders-use-substitutes = true
        experimental-features = flakes nix-command
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
      nrBuildUsers = 32;
      #nrBuildUsers = config.nix.maxJobs * 2;
      settings = {
        sandbox = true;
        allowed-users = [ "@wheel" ];
        trusted-users = [ "root" "@wheel" ];
      };
    };

    # `nix-daemon` will hit the stack limit when using `nixFlakes`.
    systemd.services.nix-daemon.serviceConfig."LimitSTACK" = "infinity";

    nixpkgs = {
      overlays = [
        # (import ../../../nix/overlays/mkSecret.nix)
        # (import ../../../nix/overlays/sbr.nix)
        # (import ../../../nix/overlays/unstable.nix)
        # (import ../../../nix).emacs
      ];
      config = {
        allowUnfree = true;
        #allowBroken = true;
      };
    };
    system = {
      extraSystemBuilderCmds = ''
        ln -sv ${pkgs.path} $out/nixpkgs
        ln -sv ${../../../nix/overlays} $out/overlays
      '';

      stateVersion = "22.05";
    };
  };
}
