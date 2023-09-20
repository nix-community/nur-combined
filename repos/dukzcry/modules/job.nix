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
      environment = {
        systemPackages = with pkgs; [
          networkmanagerapplet remmina
          skypeforlinux zoom-us mattermost-desktop
        ];
      };
      programs.evolution.plugins = [ pkgs.evolution-ews ];
    })
    (mkIf cfg.server {
      networking.firewall.extraCommands = ''
        iptables -t nat -A POSTROUTING -o job -j MASQUERADE
      '';
      services.dnsmasq.settings = {
        hostsdir = "/var/lib/dnsmasq/hosts";
      };
    })
  ];
}
