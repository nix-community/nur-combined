{ config, lib, pkgs, ... }:
with lib;
let
  common = import ./common.nix { inherit config pkgs lib; };
in
recursiveUpdate common {
  # X-Server and Gnome3 desktop configuration
  services.xserver.enable = mkDefault true;
  services.xserver.layout = mkDefault "de";

  services.xserver.displayManager.gdm.enable = mkDefault true;
  # Disable wayland if the nvidia driver is used
  services.xserver.displayManager.gdm.wayland = mkDefault (!(any (v: v == "nvidia") config.services.xserver.videoDrivers));
  services.xserver.desktopManager.gnome3.enable = mkDefault true;

  # Typically needed for wifi drivers and the like
  hardware.enableRedistributableFirmware = mkDefault true;
}
