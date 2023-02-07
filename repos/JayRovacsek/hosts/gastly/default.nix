{ config, pkgs, lib, flake, ... }:

let
  inherit (flake) common;
  inherit (flake.common.home-manager-module-sets) linux-desktop;
  inherit (flake.lib) merge-user-config;

  jay = common.users.jay {
    inherit config pkgs;
    modules = linux-desktop;
  };

  merged = merge-user-config { users = [ jay ]; };

in {
  inherit flake;
  inherit (merged) users home-manager;

  age.identityPaths = [ "/agenix/id-ed25519-ssh-primary" ];

  imports =
    [ ./hardware-configuration.nix ./modules.nix ./system-packages.nix ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      enableCryptodisk = true;
      efiSupport = true;
    };
  };

  networking.hostName = "gastly";

  system.stateVersion = "22.11";
}

