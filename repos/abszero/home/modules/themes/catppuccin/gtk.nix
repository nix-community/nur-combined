{ config, pkgs, ... }:

let
  inherit (config.lib.catppuccin) getVariant toTitleCase;
  cfg = config.abszero.themes.catppuccin;
in

{
  gtk = {
    enable = true;
    theme = {
      package = pkgs.catppuccin-gtk.override {
        variant = getVariant;
        accents = [ cfg.accent ];
      };
      name = "Catppuccin-${toTitleCase getVariant}-Standard-${toTitleCase cfg.accent}-${toTitleCase cfg.defaultVariant}";
    };
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = getVariant;
        accent = cfg.accent;
      };
      name = "Papirus-${toTitleCase cfg.defaultVariant}";
    };
  };
}
