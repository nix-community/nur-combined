# speed up builds from e.g. moby or lappy by having them query desko and servo first.
# if one of these hosts is offline, instead manually specify just cachix:
# - `nixos-rebuild --option substituters https://cache.nixos.org/`
#
# additionally, sends build jobs to servo/desko (splits the jobs across all that are enabled).
# to verify one particular remote builder:
# - `nix store ping --store ssh://servo`
# NOTE: if your unix user doesn't have ssh access to the remote builder, do the above as root (not just sudo, actual root).
# - `sudo su; nix store ping --store ssh://servo`
#
# future improvements:
# - apply for community arm build box:
#   - <https://github.com/nix-community/aarch64-build-box>
# - don't require all substituters to be online:
#   - <https://github.com/NixOS/nix/pull/7188>

{ lib, config, ... }:

let
  cfg = config.sane.nixcache;
in
{
  options = with lib; {
    sane.nixcache.enable = mkEnableOption "fetch binaries from and build packages on one of my other machines";
    sane.nixcache.enable-trusted-keys = mkOption {
      default = config.sane.nixcache.enable;
      type = types.bool;
    };
    sane.nixcache.substituters = let
      subOpt = default: mkOption {
        inherit default;
        type = types.bool;
      };
    in {
      nixos = subOpt true;
      cachix = subOpt true;
    };
    sane.nixcache.remote-builders.desko = mkOption {
      default = true;
      type = types.bool;
    };
    sane.nixcache.remote-builders.servo = mkOption {
      default = false;  #< XXX(2025-11-01): servo is too often overloaded with asshole AI crawlers => not useful
      type = types.bool;
    };
  };

  config = {
    # use our own binary cache
    # to explicitly build from a specific cache (in case others are down):
    # - `nixos-rebuild ... --option substituters https://cache.nixos.org`
    # - `nix build ... --substituters ""`
    nix.settings.substituters = lib.mkIf cfg.enable (lib.flatten [
      (lib.optional cfg.substituters.nixos  "https://cache.nixos.org/")
      (lib.optional cfg.substituters.cachix "https://nix-community.cachix.org")
    ]);
    # always trust our keys (so one can explicitly use a substituter even if it's not the default).
    # note that these are also used to sign paths before deploying over SSH; not just nix-serve.
    nix.settings.trusted-public-keys = lib.mkIf cfg.enable-trusted-keys [
      "nixcache.uninsane.org:r3WILM6+QrkmsLgqVQcEdibFD7Q/4gyzD9dGT33GP70="
      "desko:Q7mjjqoBMgNQ5P0e63sLur65A+D4f3Sv4QiycDIKxiI="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    nix.buildMachines = [
      (lib.mkIf cfg.remote-builders.desko {
        hostName = "desko";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 4; # constrained by ram, for things like webkitgtk, etc.
        speedFactor = 8;
        supportedFeatures = [ "big-parallel" ];
        mandatoryFeatures = [ ];
        sshUser = "nixremote";
        sshKey = config.sops.secrets."nixremote_ssh_key".path;
      })
      (lib.mkIf cfg.remote-builders.servo {
        hostName = "servo";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 3; # constrained by ram, for things like webkitgtk, etc.
        speedFactor = 2;
        supportedFeatures = [
          # "big-parallel"  # it can't reliably build webkitgtk
        ];
        mandatoryFeatures = [ ];
        sshUser = "nixremote";
        sshKey = config.sops.secrets."nixremote_ssh_key".path;
      })
    ];
    nix.distributedBuilds = lib.mkIf (cfg.remote-builders.desko || cfg.remote-builders.servo) true;
  };
}
