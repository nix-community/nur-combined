{ pkgs, ... }:
{
  extpkg = pkgs.gnomeExtensions.tray-icons-reloaded;
  dconf = {
    name = "org/gnome/shell/extensions/trayIconsReloaded";
    value = {
      icon-brightness = -10;
      icon-contrast = 0;
      icon-margin-horizontal = 1;
      icon-padding-horizontal = 1;
      icon-saturation = 0;
      icons-limit = 7;
      position-weight = 2;
      tray-margin-left = 0;
      wine-behavior = false;
    };
  };
}

