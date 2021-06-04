{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.alacritty;
  alacrittyTheme = config.my.theme.alacrittyTheme;
in
{
  options.my.home.alacritty.enable = lib.mkEnableOption "Alacritty terminal";

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {
        window = {
          padding = {
            x = 8;
            y = 8;
          };
        };

        font = {
          normal = {
            family = "Iosevka Fixed";
            style = "Medium";
          };
          size = 10.0;
        };

        colors = alacrittyTheme;
      };
    };

    home.packages = with pkgs; [
      iosevka-bin
    ];
    # make sure font is discoverable
    fonts.fontconfig.enable = true;
  };
}
