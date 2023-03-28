{ pkgs, config, ... }:


let
  mipmip_pkg = import (../../pkgs){};
in
  {
    home.packages = [
      mipmip_pkg.gnomeExtensions.gs-git
      mipmip_pkg.gnomeExtensions.vitals

      pkgs.gnomeExtensions.highlight-focus #GH
      pkgs.gnomeExtensions.hotkeys-popup #GH
      pkgs.gnomeExtensions.useless-gaps

      #custom-menu
      pkgs.gnomeExtensions.dash-to-panel
      pkgs.gnomeExtensions.color-picker
      pkgs.gnomeExtensions.emoji-selector
      pkgs.gnomeExtensions.espresso
      pkgs.gnomeExtensions.favorites-menu
      pkgs.gnomeExtensions.focus-changer
      #github-notificatons
      pkgs.gnomeExtensions.lightdark-theme-switcher
      pkgs.gnomeExtensions.search-light
      pkgs.gnomeExtensions.spotify-tray
      pkgs.gnomeExtensions.tray-icons-reloaded
      pkgs.gnomeExtensions.wayland-or-x11
    ];

#    dconf.settings = {
#      "org/gnome/shell" = {
#        disable-user-extensions = false;
#
#        enabled-extensions = [
#          "user-theme@gnome-shell-extensions.gcampax.github.com"
#          "trayIconsReloaded@selfmade.pl"
#          "Vitals@CoreCoding.com"
#          "dash-to-panel@jderose9.github.com"
#          "sound-output-device-chooser@kgshank.net"
#          "space-bar@luchrioh"
#        ];
#      };
#    };


  }
