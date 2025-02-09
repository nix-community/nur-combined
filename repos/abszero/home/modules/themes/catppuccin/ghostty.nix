{ config, lib, ... }:

let
  inherit (lib) mkIf mkForce;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ../base/ghostty.nix
    ./fonts.nix
  ];

  options.abszero.themes.catppuccin.ghostty.enable =
    mkExternalEnableOption config "Ghostty terminal emulator";

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
