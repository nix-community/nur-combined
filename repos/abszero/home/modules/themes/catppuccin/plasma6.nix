{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;

  theme = pkgs.catppuccin-kde.override {
    flavour = [ ctpCfg.flavor ];
    accents = [ ctpCfg.accent ];
  };
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ../../services/desktop-managers/plasma6.nix
  ];

  options.abszero.themes.catppuccin.plasma6.enable = mkEnableOption "catppuccin plasma 6 theme";

  config = mkIf cfg.plasma6.enable {
    abszero = {
      services.desktopManager.plasma6.enable = true;
      themes.catppuccin.enable = true;
    };
    home.packages = [ theme ];
    # Disable kvantum since we use the plasma theme
    catppuccin.kvantum.enable = false;
  };
}
