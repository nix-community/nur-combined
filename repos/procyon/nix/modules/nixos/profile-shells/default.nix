# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  programs = {
    zsh.enable = true;
    fish.enable = true;
  };

  environment = {
    binsh = "${pkgs.dash}/bin/dash";
    pathsToLink = [
      "/share/zsh"
      "/share/fish"
    ];
    shells = with pkgs; [
      zsh
      bashInteractive
      fish
    ];
  };
}
