{ config, pkgs, lib, flake, ... }:

let
  inherit (flake) common;
  inherit (flake.common.home-manager-module-sets) linux-desktop;
  inherit (flake.lib) merge-user-config;

  builder = common.users.builder {
    inherit config pkgs;
    modules = [ ];
  };

  jay = common.users.jay {
    inherit config pkgs;
    modules = linux-desktop;
  };

  merged = merge-user-config { users = [ builder jay ]; };

in {
  inherit flake;
  inherit (merged) users home-manager;

  imports = [ ./hardware-configuration.nix ./modules.nix ./wireless.nix ];

  environment.systemPackages = with pkgs; [ libraspberrypi ];

  security.sudo.wheelNeedsPassword = false;

  # Add wireless key to identity path
  age.identityPaths =
    [ "/agenix/id-ed25519-ssh-primary" "/agenix/id-ed25519-wireless-primary" ];

  networking.hostName = "wigglytuff";
  networking.hostId = "d2a7b80b";
  system.stateVersion = "22.05";
}
