# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, pkgs, ... }:
let
  spicePkgs = flake.inputs.spicetify-nix.packages.${pkgs.system}.default;
in
{
  imports = [ flake.inputs.spicetify-nix.homeManagerModule ];

  programs.spicetify =
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
      enabledCustomApps = with spicePkgs.apps; [
        marketplace
        lyrics-plus
      ];
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        shuffle
        bookmark
        trashbin
        autoVolume
        popupLyrics
        hidePodcasts
        autoSkipVideo
        fullAppDisplay
        keyboardShortcut
      ];
    };
}
