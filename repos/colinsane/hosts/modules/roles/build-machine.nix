{ config, lib, pkgs, sane-lib, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.sane.roles.build-machine;
in
{
  options.sane.roles.build-machine = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # enable opt-in emulation of any package at runtime.
      # i.e. `nix build '.#hostPkgs.moby.bash' ; qemu-aarch64 ./result/bin/bash`.
      sane.programs.qemu.enableFor.user.colin = true;

      # act as a remote builder
      nix.settings.trusted-users = [ "nixremote" ];
      users.users.nixremote = {
        isNormalUser = true;
        home = "/home/nixremote";
        # remove write permissions everywhere in the home dir.
        # combined with an ownership of root:nixremote, that means not even nixremote can write anything below this directory
        # (in which case, i'm not actually sure why nixremote needs a home)
        homeMode = "550";
        group = "nixremote";
        subUidRanges = [
          { startUid=300000; count=1; }
        ];
        initialPassword = "";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4KI7I2w5SvXRgUrXYiuBXPuTL+ZZsPoru5a2YkIuCf root@nixremote"
        ];
      };

      users.groups.nixremote = {};

      sane.users.nixremote = {
        fs."/".dir.acl = {
          # don't allow the user to write anywhere
          user = "root";
          group = "nixremote";
        };
      };

      # each concurrent derivation realization uses a different nix build user.
      # default is 32 build users, limiting us to that many concurrent jobs.
      # it's nice to not be limited in that way, so increase this a bit.
      nix.nrBuildUsers = 64;

      nix.settings.system-features = [ "big-parallel" ];

      # corresponds to env var: NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1
      # nixpkgs.config.allowUnsupportedSystem = true;
    })
  ];
}
