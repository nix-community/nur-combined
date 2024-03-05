{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.job;
in {
  options.services.job = {
    client = mkEnableOption ''
      Programs for job
    '';
    server = mkEnableOption ''
      Services for job
    '';
  };

  config = mkMerge [
    (mkIf cfg.client {
      environment.systemPackages = with pkgs; [ remmina yandex-disk ];
      programs.evolution.plugins = [ pkgs.evolution-ews ];
      services.xserver.displayManager.sessionCommands = ''
        yandex-disk start
      '';
    })
    (mkIf cfg.server {
      networking.firewall.extraCommands = ''
        iptables -t nat -A POSTROUTING -o job -j MASQUERADE
      '';
    })
  ];
}
