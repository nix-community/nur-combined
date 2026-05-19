{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkForce;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ../base/ghostty.nix
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
          mkForce "light:catppuccin-${cfg.lightFlavor}, dark:catppuccin-${cfg.darkFlavor}"
        );
        font-family = "Iosevka Inconsolata";
        font-size = 13;
      };
    };
  };
}
