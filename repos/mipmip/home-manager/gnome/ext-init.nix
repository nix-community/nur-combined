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

    (import ./extension-tray-icons-reloaded.nix { pkgs = pkgs; })
    (import ./extension-color-picker.nix { pkgs = pkgs; })
    (import ./extension-favorites-menu.nix { unstable = unstable; })
    (import ./extension-dash-to-panel.nix { pkgs = pkgs; })
    (import ./extension-gs-git.nix { mipmip_pkg = mipmip_pkg; })
    (import ./extension-useless-gaps.nix { unstable = unstable; })

    (import ./extension-hotkeys-popup.nix { unstable = unstable; })

    # TODO Soup.URI is not a constructor bug
    (import ./extension-github-notifications.nix { mipmip_pkg = mipmip_pkg; })

    # TODO readonly bug
    (import ./extension-highlight-focus.nix { mipmip_pkg = mipmip_pkg; })

    # TODO readonly bug
    (import ./extension-search-light.nix { unstable = unstable; })

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
