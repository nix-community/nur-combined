{ config, lib, pkgs, ... }:
with lib;

let

  xcfg = config.services.xserver;
  cfg = xcfg.desktopManager.plasma5;

  inherit (pkgs) kdeApplications plasma5 libsForQt5 qt5;

in

{
  environment.systemPackages = with pkgs; with qt5; with libsForQt5; with plasma5; with kdeApplications;
    [
      #file manager
      plasma-integration
      kio

      #icons
      breeze-qt5
      breeze-icons
      kde-gtk-config breeze-gtk

      #extra-thumbnails
      kio-extras
      ffmpegthumbs
      kdegraphics-thumbnailers
    ];


  environment.pathsToLink = [
    # FIXME: modules should link subdirs of `/share` rather than relying on this
    "/share"
  ];

  environment.etc = singleton {
    source = xcfg.xkbDir;
    target = "X11/xkb";
  };

  # Enable GTK applications to load SVG icons
  services.xserver.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];

}

