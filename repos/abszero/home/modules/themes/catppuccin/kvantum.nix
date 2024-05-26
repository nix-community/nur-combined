{ config, pkgs, ... }:

let
  inherit (config.lib.catppuccin) toTitleCase;
  cfg = config.catppuccin;

  theme = pkgs.catppuccin-kvantum.override {
    variant = toTitleCase cfg.flavor;
    accent = toTitleCase cfg.accent;
  };
in

{
  imports = [ ./catppuccin.nix ];

  home.packages = [ theme ];
}
