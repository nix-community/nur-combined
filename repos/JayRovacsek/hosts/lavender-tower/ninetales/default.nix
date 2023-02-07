{ config, pkgs, ... }:
let
  userFunction = import ../../functions/map-reduce-users.nix;
  userConfigs = import ./users.nix { inherit config pkgs; };
  users = userFunction { inherit userConfigs; };
in {
  inherit users;
  imports =
    [ ./hardware-configuration.nix ./modules.nix ./system-packages.nix ];

  networking.hostName = "ninetales";
  networking.hostId = "4148aee3";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.kernelBuildIsCross = true;

  nixpkgs.config.allowUnsupportedSystem = true;
}
