{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kde.catppuccin;
  catppuccin-kde = (
    pkgs.catppuccin-kde.override {
      flavour = [ config.catppuccin.flavor ];
      accents = [ config.catppuccin.accent ];
      winDecStyles = [ "classic" ];
    }
  );
in
{
  options.programs.kde.catppuccin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.profiles.gui.enable && pkgs.stdenv.isLinux;
      description = "Enable Catppuccin KDE theme";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      catppuccin-kde
    ];
  };
}
