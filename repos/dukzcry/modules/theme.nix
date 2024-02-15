imports: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.theme;
in {
  inherit imports;

  options.programs.theme = {
    enable = mkEnableOption "theming.";
    theme = mkOption {
      type = types.str;
      default = "Adwaita";
    };
  };

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      theme.name = cfg.theme;
      gtk3noCsd = true;
    };
    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };
    environment.systemPackages = with pkgs; [ adwaita-qt adwaita-qt6 ];
  };
}
