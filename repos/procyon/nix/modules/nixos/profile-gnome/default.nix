# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Elizabeth Paź <me@ehllie.xyz>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
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

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      gnome.dconf-editor
      gnome.gnome-tweaks
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
