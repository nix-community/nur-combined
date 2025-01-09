{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.cursors = {
    enable = mkExternalEnableOption config "catppuccin cursor theme. Complementary to catppuccin/nix";
    monochromeAccent = mkEnableOption "using polarity for accent";
  };

  config = mkIf cfg.cursors.enable {
    abszero.themes.catppuccin.enable = true;
    catppuccin.cursors = {
      enable = true;
      accent = mkIf cfg.cursors.monochromeAccent cfg.polarity;
    };
    home.pointerCursor.size = 48;
  };
}
