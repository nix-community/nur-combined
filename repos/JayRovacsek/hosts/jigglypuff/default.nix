{ config, pkgs, lib, flake, ... }:

let
  inherit (flake) common;
  inherit (flake.common.home-manager-module-sets) cli;
  inherit (flake.lib) merge-user-config;

  jay = common.users.jay {
    inherit config pkgs;
    modules = cli;
  };

  merged = merge-user-config { users = [ jay ]; };

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
    identityPaths = [ "/agenix/id-ed25519-ssh-primary" ];
  };

  services.tailscale.tailnet = "dns";

  environment.systemPackages = with pkgs; [ libraspberrypi ];

  imports = [ ./hardware-configuration.nix ./modules.nix ./vlans.nix ];

  # Remote deploy requires passwordless root access. We can do this via --use-remote-sudo
  security.sudo.wheelNeedsPassword = false;

  virtualisation.oci-containers.backend = "docker";

  networking.hostName = "jigglypuff";
  networking.hostId = "d2a7f613";
  system.stateVersion = "22.05";
}
