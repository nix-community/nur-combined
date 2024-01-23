{ config, lib, pkgs, ... }:
{
  sane.programs.gnome-keyring = {
    packageUnwrapped = pkgs.gnome.gnome-keyring;
  };
  # adds gnome-keyring as a xdg-data-portal (xdg.portal)
  # TODO: the gnome-keyring which this puts on PATH isn't sandboxed!
  #   nixos service doesn't even let it be pluggable
  services.gnome.gnome-keyring = lib.mkIf config.sane.programs.gnome-keyring.enabled {
    enable = true;
  };
}
