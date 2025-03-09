{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
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
  imports = [ ./_options.nix ];

  config.services.hyprpaper.settings =
    mkIf (cfg.hyprpaper.enable && cfg.hyprpaper.wallpaper == "nixos-logo")
      {
        preload = wallpaper;
        wallpaper = ",${wallpaper}";
      };
}
