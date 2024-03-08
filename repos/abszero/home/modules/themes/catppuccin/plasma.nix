{ config, pkgs, ... }:

let
  inherit (config.lib.catppuccin) getVariant;
  cfg = config.abszero.themes.catppuccin;

  theme = pkgs.catppuccin-kde.override {
    flavour = [ getVariant ];
    accents = [ cfg.accent ];
  };
in

{
  imports = [ ./_options.nix ];

  home.packages = [ theme ];
}
