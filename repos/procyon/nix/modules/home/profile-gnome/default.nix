# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2022 Alexander Sosedkin <monk@unboiled.info>
#
# SPDX-License-Identifier: MIT

{ osConfig, pkgs, lib, ... }:
lib.mkIf osConfig.services.xserver.desktopManager.gnome.enable {
  home.packages = with pkgs; [
    pitivi
    komikku
    fragments
    newsflash
    celluloid
  ];

  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=SSH Agent
    Comment=GNOME Keyring: SSH Agent
    Exec=/usr/bin/env true
    Hidden=true
  '';
}
