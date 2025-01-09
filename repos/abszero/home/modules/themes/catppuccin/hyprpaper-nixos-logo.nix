{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;

  wallpaperName =
    if ctpCfg.accent == "magenta" || ctpCfg.accent == "pink" then
      "nix-magenta-pink-1920x1080"
    else if ctpCfg.accent == "blue" then
      "nix-magenta-blue-1920x1080"
    else
      "nix-black-4k";
  wallpaper =
    pkgs.catppuccin-wallpapers.override { wallpapers = [ wallpaperName ]; }
    + "/share/wallpapers/catppuccin/${wallpaperName}.png";
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.hyprpaper.nixosLogo =
    mkExternalEnableOption config "catppuccin nixos logo wallpaper from catppuccin-wallpapers";

  config = mkIf cfg.hyprpaper.nixosLogo {
    abszero.themes.catppuccin.enable = true;
    services.hyprpaper.settings = {
      preload = wallpaper;
      wallpaper = ",${wallpaper}";
    };
  };
}
