{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg;
in
{
  config = lib.mkIf (cfg.gui.enable && pkgs.stdenv.isLinux) {
    catppuccin.cursors = {
      accent = config.catppuccin.accent;
      enable = lib.mkDefault true;
      flavor = config.catppuccin.flavor;
    };
    gtk = {
      cursorTheme = {
        name = config.home.pointerCursor.name;
        size = 24;
      };
      enable = true;
      font = {
        name = "Noto Sans";
        size = 10;
      };
      iconTheme = {
        name = lib.mkDefault "Papirus-Dark";
        package = lib.mkDefault (
          pkgs.catppuccin-papirus-folders.override {
            accent = config.catppuccin.accent;
            flavor = config.catppuccin.flavor;
          }
        );
      };
    };
    home.pointerCursor.enable = true;
    xdg.enable = true;
  };
}
