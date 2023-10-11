{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.programs.hyprland.enable {
    programs.regreet.enable = true;
    environment.systemPackages = [
      pkgs.custom.rofi
    ];
  };
}
