{ config, pkgs, lib, flake, ... }:

let
  inherit (flake) common;
  inherit (flake.common.home-manager-module-sets) cli;
  inherit (flake.lib) merge-user-config;

  builder = common.users.builder {
    inherit config pkgs;
    modules = [ ];
  };

  jay = common.users.jay {
    inherit config pkgs;
    modules = cli;
  };

  merged = merge-user-config { users = [ builder jay ]; };

in {
  inherit flake;
  inherit (merged) users home-manager;

  age = {
    secrets = {
      "git-signing-key" = rec {
        file = ../../secrets/ssh/git-signing-key.age;
        owner = builtins.head (builtins.attrNames jay.users.users);
        path = "/home/${owner}/.ssh/git-signing-key";
      };

      "git-signing-key.pub" = rec {
        file = ../../secrets/ssh/git-signing-key.pub.age;
        owner = builtins.head (builtins.attrNames jay.users.users);
        path = "/home/${owner}/.ssh/git-signing-key.pub";
      };
    };
    identityPaths = [
      "/agenix/id-ed25519-ssh-primary"
      "/agenix/id-ed25519-headscale-primary"
    ];
  };

  services.tailscale.tailnet = "admin";

  imports = [
    ./hardware-configuration.nix
    ./modules.nix
    ./networking.nix
    ./system-packages.nix
  ];

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  system.stateVersion = "22.11";
}
