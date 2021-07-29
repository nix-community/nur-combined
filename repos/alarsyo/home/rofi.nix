{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.rofi;
in
{
  options.my.home.rofi = with lib; {
    enable = (mkEnableOption "rofi configuration") // { default = config.my.home.x.enable; };
  };

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;

      terminal = "${pkgs.alacritty}/bin/alacritty";
      extraConfig = {
        ssh-client = "${pkgs.mosh}/bin/mosh";
      };
    };
  };
}
