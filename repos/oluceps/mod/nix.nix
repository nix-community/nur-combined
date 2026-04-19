{ inputs, ... }:
{
  flake.modules.nixos.nix =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      systemd.services = {
        # systemd-networkd.serviceConfig.TimeoutStopSec = "10s";
        nix-daemon.serviceConfig = {
          MemoryAccounting = true;
          MemoryMax = "90%";
          OOMScoreAdjust = 500;
        };
      };
      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 10d";
        };

        # package = pkgs.nixVersions.stable;
        package = pkgs.lixPackageSets.git.lix;

        nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        channel.enable = false;
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
        settings = {
          flake-registry = "";
          nix-path = [ "nixpkgs=${pkgs.path}" ];
          # fsync-store-paths = true;
          keep-outputs = true;
          keep-derivations = true;
          trusted-users = [
            config.identity.user
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
            "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
            # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
            "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
            "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
            "cache.nyaw.xyz:c8dPG7KwH3Qf+/pfJJ+k2yUpiFCa1Mg1DbdqKyZlBis="
          ];
          extra-substituters = [
            # "https://cache.lix.systems"
          ]
          ++ (map (n: "https://${n}.cachix.org") [
            "nix-community"
            "nixpkgs-wayland"
            "microvm"
            "devenv"
          ]);
          substituters = [
            # "https://cache.garnix.io"
            "http://cache.nyaw.xyz:8501"
          ];
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
            "auto-allocate-uids"
            "cgroups"
            "flake-self-attrs"
            # "recursive-nix"
            # "ca-derivations"
            "pipe-operator"
            # "pipe-operators"
            # "blake3-hashes"
          ];
          auto-allocate-uids = true;
          use-cgroups = true;

          # Avoid disk full
          max-free = lib.mkDefault (1000 * 1000 * 1000);
          min-free = lib.mkDefault (128 * 1000 * 1000);
          max-jobs = "auto";
          cores = 0;
          builders-use-substitutes = true;
          allow-import-from-derivation = true;
          # download-buffer-size = 524288000;
        };

        daemonCPUSchedPolicy = lib.mkDefault "batch";
        daemonIOSchedClass = lib.mkDefault "idle";
        daemonIOSchedPriority = lib.mkDefault 7;

        extraOptions = ''
          !include ${config.vaultix.secrets.gh-token.path}
        '';

      };

      vaultix.secrets.gh-token = {
        owner = config.identity.user;
        group = "users";
        mode = "400";
      };
    };
}
