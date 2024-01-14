# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    package = pkgs.google-chrome;
    commandLineArgs = [ "--ozone-platform=wayland" ];
  };
}
