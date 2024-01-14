# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
let
  catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "fish";
    rev = "0ce27b518e8ead555dec34dd8be3df5bd75cff8e";
    sha256 = "sha256-Dc/zdxfzAUM5NX8PxzfljRbYvO9f9syuLO8yBr+R3qg=";
  };
in
{
  xdg.configFile."fish/themes" = {
    recursive = true;
    source = "${catppuccin}/themes";
  };

  programs.fish.interactiveShellInit = ''
    set fish_greeting
    fish_config theme choose "Catppuccin Mocha"
  '';
}
