# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
let
  yazi-themes = pkgs.fetchFromGitHub { owner = "yazi-rs"; repo = "themes"; rev = "8abf251851b9b7559f810a65932cd7735b202dfa"; sha256 = "sha256-f8Mwacw8FoZ5S0wUdQcmtFZwrxDyabJfL7kPKhmOD1A="; };
in
{
  home.file.".config/yazi/theme.toml".source = "${yazi-themes}/catppuccin/mocha.toml";

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
  };
}
