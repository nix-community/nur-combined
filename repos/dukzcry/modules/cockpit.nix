{ config, lib, pkgs, ... }:

with lib;
let
  cpkgs = pkgs.nur.repos.dukzcry;
  cfg = config.programs.cockpit;
in {
  options.programs.cockpit = {
    enable = mkEnableOption ''
      Cockpit with cockpit-machines
    '';
  };

  config = mkIf cfg.enable {
    services.cockpit.enable = true;
    services.cockpit.port = 9092;
    services.cockpit.settings = {
      WebService = {
        AllowUnencrypted = true;
      };
    };

    environment.systemPackages = with pkgs; with cpkgs; [ cockpit-machines libvirt-dbus virtmanager ];
  };
}
