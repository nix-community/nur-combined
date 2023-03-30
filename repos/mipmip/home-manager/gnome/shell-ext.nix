{ lib, pkgs, unstable, config, ... }:

# TODO create module, check https://github.com/smashstate/gnome-manager/blob/main/gnome.nix

with lib;
let
  mipmip_pkg = import (../../pkgs){};

  gnomeExtensionsWithOutConf = [

    mipmip_pkg.gnomeExtensions.custom-menu-panel
    pkgs.gnomeExtensions.emoji-selector
    pkgs.gnomeExtensions.espresso
    pkgs.gnomeExtensions.lightdark-theme-switcher
    pkgs.gnomeExtensions.spotify-tray
    pkgs.gnomeExtensions.wayland-or-x11
    pkgs.gnomeExtensions.focus-changer
  ];

  gnomeExtensions = map (ext: { extpkg = ext; } ) gnomeExtensionsWithOutConf ++ [

    (import ./shell-ext-tray-icons-reloaded.nix { pkgs = pkgs; })
    (import ./shell-ext-color-picker.nix { pkgs = pkgs; })
    (import ./shell-ext-favorites-menu.nix { unstable = unstable; })
    (import ./shell-ext-dash-to-panel.nix { pkgs = pkgs; })
    (import ./shell-ext-gs-git.nix { mipmip_pkg = mipmip_pkg; })
    (import ./shell-ext-useless-gaps.nix { unstable = unstable; })
    (import ./shell-ext-hotkeys-popup.nix { unstable = unstable; })
    (import ./shell-ext-highlight-focus.nix { mipmip_pkg = mipmip_pkg; })
    (import ./shell-ext-search-light.nix { lib = lib; mipmip_pkg = mipmip_pkg; })

    # TODO Soup.URI is not a constructor bug
    (import ./shell-ext-github-notifications.nix { mipmip_pkg = mipmip_pkg; })

  ];

  dconfEnabledExtensions = {
    "org/gnome/shell" = {
      enabled-extensions = map (ext: ext.extpkg.extensionUuid) gnomeExtensions ++ [
        "GPaste@gnome-shell-extensions.gnome.org"
      ];
    };
  };

  dconfExtConfs = builtins.listToAttrs (builtins.catAttrs "dconf" gnomeExtensions);
  recursiveMerge = import ../../lib/recursive-merge.nix {lib = lib;};

in
  {
    home.packages = map (ext: ext.extpkg) gnomeExtensions;
    dconf.settings = recursiveMerge [dconfEnabledExtensions dconfExtConfs];
  }
