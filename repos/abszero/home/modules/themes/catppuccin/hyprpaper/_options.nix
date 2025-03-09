{ config, lib, ... }:

let
  inherit (lib) types mkOption mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [ ../../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.hyprpaper = {
    enable = mkExternalEnableOption config "catppuccin hyprpaper theme";
    wallpaper = mkOption {
      type = types.enum [
        "nixos-logo"
        "xppen-chan"
      ];
      description = "Wallpaper to use";
    };
  };

  config.abszero.themes.catppuccin.enable = mkIf cfg.hyprpaper.enable true;
}
