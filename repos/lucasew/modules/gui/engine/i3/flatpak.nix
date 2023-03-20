{ config, pkgs, lib, ... }:
lib.mkIf config.services.flatpak.enable {
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
}
