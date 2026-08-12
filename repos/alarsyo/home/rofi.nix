{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.home.rofi;
in {
  options.my.home.rofi = {
    enable = (mkEnableOption "rofi configuration") // {default = config.my.home.x.enable;};
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      terminal = "${pkgs.alacritty}/bin/alacritty";
    };
  };
}
