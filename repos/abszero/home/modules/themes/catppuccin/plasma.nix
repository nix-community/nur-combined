{ config, pkgs, ... }:

let
  cfg = config.catppuccin;

  theme = pkgs.catppuccin-kde.override {
    flavour = [ cfg.flavor ];
    accents = [ cfg.accent ];
  };
in

{
  imports = [ ./catppuccin.nix ];

  home.packages = [ theme ];
}
