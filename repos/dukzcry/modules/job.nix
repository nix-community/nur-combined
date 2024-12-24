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
      environment.systemPackages = with pkgs; [
        remmina postman zip
      ];
      programs.evolution.plugins = [ pkgs.evolution-ews ];
    })
    (mkIf cfg.server {
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
  ];
}
