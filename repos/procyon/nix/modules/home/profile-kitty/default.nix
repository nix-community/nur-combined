# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  xdg.configFile."kitty/codepoints.conf".source = ./codepoints.conf;

  home.shellAliases = {
    "icat" = "kitten icat";
  };

  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    extraConfig = builtins.readFile ./kitty.conf;
    shellIntegration = with config.programs; {
      enableZshIntegration = zsh.enable;
      enableBashIntegration = bash.enable;
      enableFishIntegration = fish.enable;
    };
  };
}
