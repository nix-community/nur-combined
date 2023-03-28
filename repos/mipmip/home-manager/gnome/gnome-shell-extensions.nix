{ lib, pkgs, unstable, config, ... }:

# TODO create module, check https://github.com/smashstate/gnome-manager/blob/main/gnome.nix

with lib;
let
  mipmip_pkg = import (../../pkgs){};

  gnomeExtensionsWithOutConf = [

    mipmip_pkg.gnomeExtensions.custom-menu-panel
    unstable.gnomeExtensions.favorites-menu
    pkgs.gnomeExtensions.emoji-selector
    pkgs.gnomeExtensions.espresso
    pkgs.gnomeExtensions.lightdark-theme-switcher
    pkgs.gnomeExtensions.spotify-tray
    pkgs.gnomeExtensions.tray-icons-reloaded
    pkgs.gnomeExtensions.wayland-or-x11
    pkgs.gnomeExtensions.focus-changer

    # TODO
    #pkgs.gnomeExtensions.hotkeys-popup NUR or replace with new hotkeys app

  ];

  gnomeExtensions = map (ext: { extpkg = ext; } ) gnomeExtensionsWithOutConf ++ [
    {
      extpkg = pkgs.gnomeExtensions.color-picker;
      dconf = {
        name = "org/gnome/shell/extensions/color-picker";
        value = {
          color-picker-shortcut = [ "<Super>l" ];
          enable-shortcut = false;
        };
      };
    }

    {
      extpkg = mipmip_pkg.gnomeExtensions.gs-git;
      dconf = {
        name = "org/gnome/shell/extensions/gs-git";
        value = {
          alert-dirty-repos = true;
          disable-hiding = true;
          open-in-terminal-command = "st -d '%WORKING_DIRECTORY' -- bash -c 'git status; bash'";
          show-changed-files = false;
        };
      };
    }

    # TODO Soup.URI is not a constructor bug
    {
      extpkg = mipmip_pkg.gnomeExtensions.github-notifications;
      dconf = {
        name = "org/gnome/shell/extensions/github-notifications";
        value = {
          hide-notification-count = false;
          hide-widget = false;
          show-alert = false;
          show-participating-only = false;
          token = "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";
        };
      };
    }

    # TODO readonly bug
    {
      extpkg = unstable.gnomeExtensions.search-light;
      dconf = {
        name = "org/gnome/shell/extensions/search-light";
        value = {
          blur-background = false;
          blur-brightness = 0.59999999999999998;
          blur-sigma = 30.0;
          border-radius = 1.22;
          border-thickness = 1;
          entry-font-size = 1;
          monitor-count = 1;
          scale-height = 0.29999999999999999;
          scale-width = 0.19;
          shortcut-search= [ "<Super>space "];
          show-panel-icon=false;
        };
      };
    }

    # TODO readonly bug
    {
      extpkg = unstable.gnomeExtensions.highlight-focus;
      dconf = {
        name = "org/gnome/shell/extensions/highlight-focus";
        value = {
          border-color = "#3584e4";
          border-radius = 9;
          border-width = 6;
        };
      };
    }


    # TODO no activated bug
    {
      extpkg = unstable.gnomeExtensions.useless-gaps;
      dconf = {
        name = "org/gnome/shell/extensions/useless-gaps";
        value = {
          gap-size = 25;
          margin-bottom = 25;
          margin-left = 0;
          margin-right = 0;
          margin-top = 0;
          no-gap-when-maximized = false;
        };
      };
    }

    # TODO configure
    {
      extpkg = pkgs.gnomeExtensions.dash-to-panel;
    }

  ];

  dconfEnabledExtensions = {
    "org/gnome/shell" = {
      enabled-extensions = map (ext: ext.extpkg.extensionUuid) gnomeExtensions ++ [
        "GPaste@gnome-shell-extensions.gnome.org"
      ];
    };
  };

  dconfExtConfs = builtins.listToAttrs (builtins.catAttrs "dconf" gnomeExtensions);

  # TODO fix recursiveMerge2
  #recursiveMerge2 = import ../../lib/recursive-merge.nix;
  recursiveMerge = attrList:
    let f = attrPath:
      zipAttrsWith (n: values:
        if tail values == []
        then head values
        else if all isList values
        then unique (concatLists values)
        else if all isAttrs values
        then f (attrPath ++ [n]) values
        else last values
      );
    in f [] attrList;

in
  {
    home.packages = map (ext: ext.extpkg) gnomeExtensions;
    dconf.settings = recursiveMerge [dconfEnabledExtensions dconfExtConfs];
  }
