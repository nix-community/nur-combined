{ pkgs, ... }:
let
  fhs = pkgs.buildFHSUserEnv {
    name = "usb_tixati";
    targetPkgs = pkgs: with pkgs; [
      glib
      zlib
      dbus
      dbus-glib
      gtk2
      gdk-pixbuf
      cairo
      pango
    ];
    runScript = "/run/media/lucasew/Dados/PortableApps/PROGRAMAS/Tixati_portable/tixati_Linux64bit";
  };
  desktop = pkgs.makeDesktopItem {
    name = "TixatiUSB";
    desktopName = "Tixati (USB mode)";
    icon = "tixati";
    type = "Application";
    exec = "${fhs}/bin/usb_tixati";
  };
in
desktop
