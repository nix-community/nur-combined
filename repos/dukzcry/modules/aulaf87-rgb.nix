{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.hardware.aulaf87-rgb;
in {
  options.hardware.aulaf87-rgb = {
    enable = mkEnableOption "Control of Aula F87 keyboard leds";
  };

  config = mkIf cfg.enable {
    services.udev.packages = [ pkgs.nur.repos.dukzcry.aulaf87-rgb ];
    systemd.packages = [ pkgs.nur.repos.dukzcry.aulaf87-rgb ];
    environment.systemPackages = [ pkgs.nur.repos.dukzcry.aulaf87-rgb ];
  };
}
