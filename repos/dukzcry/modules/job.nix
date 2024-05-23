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
    number = mkOption {
     type = types.str;
     default = "161";
    };
  };

  config = mkMerge [
    (mkIf cfg.client {
      environment.systemPackages = with pkgs; with pkgs.nur.repos.dukzcry; [ remmina ydcmd ];
      programs.evolution.plugins = [ pkgs.evolution-ews ];
    })
    (mkIf cfg.server {
      networking.iproute2 = {
        enable = true;
        rttablesExtraConfig = "${cfg.number} job";
      };
      environment.etc."vpnc/post-connect.d/fwmark".text = ''
        ${pkgs.iproute2}/bin/ip rule add fwmark ${cfg.number} lookup job
      '';
    })
    (mkIf (cfg.server && config.networking.nftables.enable) {
      networking.nftables.tables = {
        job = {
          family = "ip";
          content = ''
            chain post {
              type nat hook postrouting priority srcnat;
              oifname "job" counter masquerade
            }
          '';
        };
      };
    })
    (mkIf (cfg.server && !config.networking.nftables.enable) {
      networking.firewall.extraCommands = ''
        iptables -t nat -A POSTROUTING -o job -j MASQUERADE
      '';
    })
  ];
}
