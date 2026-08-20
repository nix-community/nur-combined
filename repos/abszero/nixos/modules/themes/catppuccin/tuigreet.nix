{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
  ];

  options.abszero.themes.catppuccin.tuigreet.enable = mkEnableOption "catppuccin tuigreet theme";

  config = mkIf cfg.tuigreet.enable {
    abszero.themes.catppuccin.enable = true;
    abszero.services.displayManager.tuigreet.settings = {
      secret.characters = "●";
      background = {
        kind = "matrix";
        matrix = {
          head_color = "bright-yellow";
          bright_color = "bright-yellow";
          dim_color = "bright-gray";
        };
      };
      theme = {
        time = "green";
        border = "blue";
        title = "magenta";
        prompt = "cyan";
        button = "magenta";
      };
    };
  };
}
