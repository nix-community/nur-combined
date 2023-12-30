# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 yuzukicat <yuzuki.cat@kamisu66.com>
#
# SPDX-License-Identifier: MIT

{ flake, pkgs, ... }:
let
  polarity = "dark";
  base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  image = "${flake.self.packages.${pkgs.system}."wallpapers/default".override {
    wallpaperFill = "#1e1e2e";
    wallpaperColorize = "75%";
    wallpaperParams = "-10,0";
  }}/dimmed.png";
in
{
  imports = [ flake.inputs.stylix.nixosModules.stylix ];

  stylix = {
    inherit polarity base16Scheme image;

    cursor = {
      size = 32;
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };
    opacity.terminal = 0.75;
    fonts = {
      # TODO: find alternative
      serif = {
        package = pkgs.sarasa-gothic;
        name = "Sarasa Mono Slab CL";
      };
      # TODO: find alternative
      sansSerif = {
        package = pkgs.sarasa-gothic;
        name = "Sarasa UI CL";
      };
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono Regular";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        popups = 12;
        desktop = 16;
        terminal = 18;
        applications = 14;
      };
    };
  };
}
