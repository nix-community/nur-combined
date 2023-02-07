{ config, pkgs, lib, flake, ... }:
let
  inherit (flake) common;
  inherit (flake.common.home-manager-module-sets) darwin-desktop;
  inherit (flake.lib) merge-user-config;

  jay = common.users."j.rovacsek" {
    inherit config pkgs;
    modules = darwin-desktop;
  };
  merged = merge-user-config { users = [ jay ]; };
in {
  inherit flake;
  inherit (merged) users home-manager;

  imports = [ ./modules.nix ./system-packages.nix ./secrets.nix ];

  services.nix-daemon.enable = true;

  networking = {
    computerName = "victreebel";
    hostName = "victreebel";
    localHostName = "victreebel";
  };

  system.stateVersion = 4;
}
