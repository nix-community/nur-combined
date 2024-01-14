# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = pkgs.lib.importTOML ./starship.toml;
  };
}
