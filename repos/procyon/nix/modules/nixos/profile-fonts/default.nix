# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ pkgs, ... }:
{
  nixpkgs.config.joypixels.acceptLicense = true;

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      # Serif
      prociono # 🦝
      zilla-slab
      roboto-slab
      noto-fonts-cjk-serif
      # Sans
      manrope
      fira-go
      montserrat
      noto-fonts-cjk-sans
      # Mono
      monaspace
      sarasa-gothic
      jetbrains-mono
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      # Emoji
      joypixels
      noto-fonts-color-emoji
    ];
  };
}
