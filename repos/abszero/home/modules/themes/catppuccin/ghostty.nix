{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkForce;
  inherit (config.lib.catppuccin) toTitleCase;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ../base/ghostty
    ./fonts.nix
  ];

  options.abszero.themes.catppuccin.ghostty.enable = mkEnableOption "Ghostty terminal emulator";

  config = mkIf cfg.ghostty.enable {
    abszero.themes = {
      base.ghostty.enable = true;
      catppuccin = {
        enable = true;
        fonts.enable = true;
      };
    };
    catppuccin.ghostty.enable = true;
    programs.ghostty = {
      settings = {
        theme = mkIf cfg.useSystemPolarity (
          mkForce "light:Catppuccin ${toTitleCase cfg.lightFlavor}, dark:Catppuccin ${toTitleCase cfg.darkFlavor}"
        );
        font-family = "Iosevka Inconsolata";
        font-size = 13;
      };
    };
  };
}
