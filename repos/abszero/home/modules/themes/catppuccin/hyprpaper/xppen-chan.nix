{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.abszero.themes.catppuccin;

  # https://www.pixiv.net/en/artworks/124691157
  wallpaper = ./xppen-chan.png;
in

{
  imports = [ ./_options.nix ];

  config.services.hyprpaper.settings =
    mkIf (cfg.hyprpaper.enable && cfg.hyprpaper.wallpaper == "xppen-chan")
      {
        # For some reason toString returns a different path
        preload = "${wallpaper}";
        wallpaper = ", ${wallpaper}";
      };
}
