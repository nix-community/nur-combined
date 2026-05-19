{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ../base/cursors.nix
  ];

  options.abszero.themes.catppuccin.cursors = {
    enable = mkEnableOption "catppuccin cursor theme. Complementary to catppuccin/nix";
    monochromeAccent = mkEnableOption "using polarity for accent";
  };

  config = mkIf cfg.cursors.enable {
    abszero.themes = {
      base.pointerCursor.enable = true;
      catppuccin.enable = true;
    };
    catppuccin.cursors = {
      enable = true;
      accent = mkIf cfg.cursors.monochromeAccent cfg.polarity;
    };
    home.pointerCursor.size = 48;
  };
}
