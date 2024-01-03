# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [ wl-clipboard ];
    settings = pkgs.lib.importTOML ./settings.toml;
    languages = pkgs.lib.importTOML ./languages.toml;
    package = flake.inputs.helix.packages.${pkgs.system}.default;
  };
}
