# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ osConfig, ezModules, pkgs, ... }:
{
  imports = [
    ezModules.suite-cli
    ezModules.profile-xdg
  ];

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  targets.genericLinux.enable = pkgs.stdenv.isLinux;

  programs = {
    bash.enable = true;
    zsh.enable = osConfig.programs.zsh.enable;
    fish.enable = osConfig.programs.fish.enable;
  };
}
