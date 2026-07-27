{
  config,
  pkgs,
  lib,
  ...
}:
lib.mkIf config.services.flatpak.enable {
  xdg.portal.enable = lib.mkDefault true;
  # xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  environment.systemPackages = [ pkgs.gnome-software ];
}
