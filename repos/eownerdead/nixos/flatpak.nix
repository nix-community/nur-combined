{ lib, pkgs, config, ... }:
with lib; {
  options.eownerdead.flatpak = mkEnableOption (mdDoc ''
    See the (wiki)[https://nixos.wiki/wiki/Flatpak]
  '');

  config = mkIf config.eownerdead.flatpak {
    services.flatpak.enable = mkDefault true;

    # Required by flatpak.
    xdg.portal = {
      enable = mkDefault true;
      # error: infinite recursion encountered
      # extraPortals = optional
      #   (config.xdg.portal.extraPortals == [ ])
      #   pkgs.xdg-desktop-portal-gtk;
      extraPortals = mkDefault [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
