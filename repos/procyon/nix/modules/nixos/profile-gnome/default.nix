# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Elizabeth Paź <me@ehllie.xyz>
#
# SPDX-License-Identifier: MIT

{ pkgs, lib, ... }:
{
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  programs = {
    dconf.enable = true;
    kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
  };

  programs.dconf.profiles.gdm.databases = [{
    lockAll = true;
    settings = {
      "org/gnome/desktop/peripherals/keyboard".numlock-state = true;
      "org/gnome/desktop/interface" = {
        cursor-size = lib.gvariant.mkInt32 32;
        cursor-theme = "Catppuccin-Mocha-Dark-Cursors";
      };
    };
  }];

  nixpkgs = {
    overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope' (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [ ./shell_colors.patch ];
            postPatch = let colors = ./_colors.scss; in old.postPatch + ''
              rm data/theme/gnome-shell-sass/{_colors.scss,_palette.scss}
              cp ${colors} data/theme/gnome-shell-sass/_colors.scss
            '';
          });
        });
      })
    ];
  };

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      gnome.dconf-editor
      gnome.gnome-tweaks
      catppuccin-cursors.mochaDark
    ];
    gnome.excludePackages =
      (with pkgs; [
        gnome-tour
        gnome-console
        gnome-text-editor
        gnome-connections
      ])
      ++ (with pkgs.gnome; [
        gnome-initial-setup
        gnome-backgrounds
        gnome-calculator
        gnome-contacts
        gnome-calendar
        gnome-weather
        gnome-clocks
        simple-scan
        gnome-music
        gnome-maps
        epiphany
        totem
        geary
        yelp
      ]);
  };
}
