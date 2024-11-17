{ config, lib, ... }:

let
  cfg = config.sane.roles.build-machine;
in
{
  options.sane.roles.build-machine = with lib; {
    enable = mkEnableOption "allow my other machines to dispatch build jobs to this one";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
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

      # XXX(2024-xx): ccache _works_, but the cache hit rate is so low that it's often a net negative!
      # ElvishJerricco linked his ccache config in #nix-offtopic 2024-11-09, claiming he got it to
      # actually speed things up with the right env vars; didn't see anything obvious there.
      # programs.ccache.enable = true;
      # nix.settings.extra-sandbox-paths = [ "/var/cache/ccache" ];
      # sane.persist.sys.byStore.plaintext = [
      #   { group = "nixbld"; mode = "0775"; path = "/var/cache/ccache"; method = "bind"; }
      # ];
      # # `sloppiness = random_seed`: see <https://wiki.nixos.org/wiki/CCache#Sloppiness>
      # sane.fs."/var/cache/ccache/ccache.conf".file.text = ''
      #   max_size = 50G
      #   sloppiness = random_seed
      # '';

      # corresponds to env var: NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1
      # nixpkgs.config.allowUnsupportedSystem = true;
    })
  ];
}
