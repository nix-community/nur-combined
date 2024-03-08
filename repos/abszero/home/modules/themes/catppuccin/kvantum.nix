{ config, pkgs, ... }:

let
  inherit (config.lib.catppuccin) getVariant toTitleCase;
  cfg = config.abszero.themes.catppuccin;

  theme = pkgs.catppuccin-kvantum.override {
    variant = toTitleCase getVariant;
    accent = toTitleCase cfg.accent;
  };
in

{
  imports = [ ./_options.nix ];

  home.packages = [ theme ];
}
