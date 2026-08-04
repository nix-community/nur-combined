{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
{
  imports = [
    (
      { lib, config, ... }:
      {
        options.eownerdead.gc = mkEnableOption (mdDoc ''
          Run Nix garbage collection weekly.

          See the (manual)[https://nixos.org/manual/nix/stable/package-management/garbage-collection.html].
        '');

        config = (
          mkIf config.eownerdead.gc {
            nix.gc = {
              automatic = mkDefault true;
              dates = mkDefault "weekly";
              options = mkDefault "--delete-older-than 7d";
            };
          }
        );
      }
    )
    (
      { lib, config, ... }:
      {
        options.eownerdead.binaryCaches = mkEnableOption (mdDoc ''
          Add flequency used binary caches.

          See the (wiki)[https://nixos.wiki/wiki/Binary_Cache]
        '');

        config = (
          mkIf config.eownerdead.binaryCaches {
            nix.settings = {
              trusted-users = [ "@wheel" ];
              trusted-substituters = [ "https://ai.cachix.org" ];
              substituters = [ "https://nix-community.cachix.org" ];
              trusted-public-keys = [
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
              ];
            };
          }
        );
      }
    )
    (
      { ... }:
      {
        options.eownerdead.nixTmp = mkEnableOption ''
          See the (issue)[https://github.com/NixOS/nixpkgs/issues/54707]
        '';

        config = mkIf config.eownerdead.nixTmp {
          systemd.services.nix-daemon = {
            environment.TMPDIR = "/nix/tmp";
          };

          systemd.tmpfiles.rules = [ "d /nix/tmp 0755 root root 1d" ];
        };
      }
    )
  ];

  options.eownerdead.nix = mkEnableOption (mdDoc ''
    Nix settings I recommend.
  '');

  config = mkIf config.eownerdead.nix {
    eownerdead = {
      gc = mkDefault true;
      binaryCaches = mkDefault true;
      nixTmp = mkDefault true;
    };
    nix.settings = {
      auto-optimise-store = mkDefault true;
      auto-allocate-uids = true;
      use-cgroups = true;
      use-xdg-base-directories = true;
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "dynamic-derivations"
        "fetch-closure"
        "fetch-tree"
        "flakes"
        "git-hashing"
        "impure-derivations"
        "mounted-ssh-store"
        "nix-command"
        "pipe-operators"
        "recursive-nix"
        "verified-fetches"
      ];
    };
    # Fix `error: executing 'git': No such file or directory`
    programs.git.enable = mkDefault true;
  };
}
