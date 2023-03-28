{ pkgs, unstable, config, ... }:


let
  mipmip_pkg = import (../../pkgs){};
  gnomeExtensions = [
    pkgs.gnomeExtensions.highlight-focus
    pkgs.gnomeExtensions.useless-gaps
    pkgs.gnomeExtensions.focus-changer

    mipmip_pkg.gnomeExtensions.gs-git
    mipmip_pkg.gnomeExtensions.vitals

    #custom-menu
    #github-notificatons
    #pkgs.gnomeExtensions.hotkeys-popup #GH

    pkgs.gnomeExtensions.highlight-focus
    pkgs.gnomeExtensions.useless-gaps

    pkgs.gnomeExtensions.dash-to-panel
    pkgs.gnomeExtensions.color-picker
    pkgs.gnomeExtensions.emoji-selector
    pkgs.gnomeExtensions.espresso
    pkgs.gnomeExtensions.favorites-menu
    pkgs.gnomeExtensions.focus-changer
    pkgs.gnomeExtensions.lightdark-theme-switcher
    pkgs.gnomeExtensions.search-light
    pkgs.gnomeExtensions.spotify-tray
    pkgs.gnomeExtensions.tray-icons-reloaded
    pkgs.gnomeExtensions.wayland-or-x11

  ];
in
  {
    home.packages = gnomeExtensions;
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = map (ext: ext.extensionUuid) gnomeExtensions ++ [
          "GPaste@gnome-shell-extensions.gnome.org"
        ];
      };
    };
  }
