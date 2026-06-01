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
    xdg.enable = true;
    gtk = {
      enable = true;
      font = {
        name = "Noto Sans";
        size = 10;
      };
      iconTheme = {
        name = lib.mkDefault "Papirus-Dark";
        package = lib.mkDefault (
          pkgs.catppuccin-papirus-folders.override {
            flavor = config.catppuccin.flavor;
            accent = config.catppuccin.accent;
          }
        );
      };
      cursorTheme = {
        name = config.home.pointerCursor.name;
        size = 24;
      };
    };
    catppuccin.cursors = {
      enable = lib.mkDefault true;
      flavor = config.catppuccin.flavor;
      accent = config.catppuccin.accent;
    };
  };
}
