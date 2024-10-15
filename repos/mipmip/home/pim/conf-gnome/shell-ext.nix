{ lib, pkgs, unstable, ... }:

# TODO create module, check https://github.com/smashstate/gnome-manager/blob/main/gnome.nix

let
  mipmip_pkg = import (../../../pkgs){};

  gnomeExtensionsWithOutConf = [
    mipmip_pkg.gnomeExtensions.custom-menu-panel
    pkgs.gnomeExtensions.emoji-copy
    pkgs.gnomeExtensions.espresso
    pkgs.gnomeExtensions.show-favorite-apps
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.spotify-tray
    pkgs.gnomeExtensions.wayland-or-x11
  ];

  gnomeExtensions = map (ext: { extpkg = ext; } ) gnomeExtensionsWithOutConf ++ [

    #(import ./shell-ext-tray-icons-reloaded.nix { pkgs = pkgs; })
    #(import ./shell-ext-favorites-menu.nix { unstable = unstable; })
    #(import ./shell-ext-gs-git.nix { mipmip_pkg = mipmip_pkg; })
    #(import ./shell-ext-hotkeys-popup.nix { unstable = unstable; })

    (import ./shell-ext-color-picker.nix { pkgs = pkgs; })
    (import ./shell-ext-focus-changer.nix { pkgs = pkgs; })
    (import ./shell-ext-dash-to-panel.nix { pkgs = pkgs; })
    (import ./shell-ext-useless-gaps.nix { unstable = unstable; })
    (import ./shell-ext-highlight-focus.nix { mipmip_pkg = mipmip_pkg; })
    (import ./shell-ext-search-light.nix { lib = lib; mipmip_pkg = mipmip_pkg; })

  ];

  dconfEnabledExtensions = {
    "org/gnome/shell" = {
      enabled-extensions = map (ext: ext.extpkg.extensionUuid) gnomeExtensions ++ [
        "GPaste@gnome-shell-extensions.gnome.org"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
      ];
    };
  };

  dconfExtConfs = builtins.listToAttrs (builtins.catAttrs "dconf" gnomeExtensions);
  recursiveMerge = import ../../../lib/recursive-merge.nix {lib = lib;};

in
  {
    home.packages = map (ext: ext.extpkg) gnomeExtensions;
    dconf.settings = recursiveMerge [dconfEnabledExtensions dconfExtConfs];
  }
