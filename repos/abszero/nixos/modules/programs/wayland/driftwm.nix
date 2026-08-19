{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.driftwm;
in

{
  options.abszero.programs.driftwm.enable = mkEnableOption "infinite canvas wayland compositor";

  config = mkIf cfg.enable {
    xdg.portal = {
      wlr.enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];
      # configPackages is ignored when config is set, so we need to include
      # the package config.
      config.driftwm = {
        default = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "gnome";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        "org.freedesktop.impl.portal.Inhibit" = "none";
      };
    };
    programs.driftwm.enable = true;
  };
}
