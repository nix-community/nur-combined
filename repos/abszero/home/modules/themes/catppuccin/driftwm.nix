{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;

  palette = config.lib.catppuccin.palette.${ctpCfg.flavor}.colors;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ../base/driftwm.nix
    ./fonts.nix
  ];

  options.abszero.themes.catppuccin.driftwm.enable = mkEnableOption "catppuccin driftwm theme";

  config.abszero = mkIf cfg.driftwm.enable {
    themes = {
      base.driftwm.enable = true;
      catppuccin = {
        enable = true;
        fonts.enable = true;
      };
    };
    programs.driftwm.settings.decorations = {
      font = "Maple Mono NF CN";
      font_size = 14;
      border_color_focused = palette.pink.hex;
    };
  };
}
