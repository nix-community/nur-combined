{ config, lib, pkgs, ... }:
{
  sane.programs.gnome-keyring = {
    package = pkgs.gnome.gnome-keyring;
  };
  # adds gnome-keyring as a xdg-data-portal (xdg.portal)
  services.gnome.gnome-keyring = lib.mkIf config.sane.programs.gnome-keyring.enabled {
    enable = true;
  };
}
