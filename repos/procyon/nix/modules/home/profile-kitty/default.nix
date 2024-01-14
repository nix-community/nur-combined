# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  xdg.configFile."kitty/codepoints.conf".source = ./codepoints.conf;

  home.shellAliases = {
    "+ssh" = "kitty +kitten ssh";
    "+cat" = "kitty +kitten icat";
    "+diff" = "kitty +kitten diff";
    "+clip" = "kitty +kitten clipboard";
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
