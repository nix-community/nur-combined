{ config, lib, pkgs, ... }:

let
  cfg = config.quriosity.sddm-themes.echo;
in
{
  options.quriosity.sddm-themes.echo = {
      enable = lib.mkEnableOption "Echo SDDM theme";
      wallpaper = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable background wallpaper in the theme.";
        };
        image = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Custom wallpaper image to use instead of the default (only .png)";
        };
      };
    };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.wallpaper.image == null || cfg.wallpaper.enable;
        message = "quriosity.sddm-themes.echo: wallpaper.image is set, but wallpaper is disabled (wallpaper.enable = false). Wallpaper image will be ignored";
      }
    ];

    environment.systemPackages = [
      (pkgs.echo-sddm.override {
        enableWallpaper = cfg.wallpaper.enable;
        wallpaper = cfg.wallpaper.image;
      })
    ];
    fonts.packages = [ pkgs.jetbrains-mono ];
  };
}
