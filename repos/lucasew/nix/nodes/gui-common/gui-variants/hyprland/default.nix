{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.programs.hyprland.enable {
    programs.regreet.enable = true;
    programs.waybar.enable = true;
    environment.systemPackages = [
      pkgs.custom.rofi
    ];
  };
}
