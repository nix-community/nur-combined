{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.networking.awl;
in {
  options.networking.awl = {
    enable = mkEnableOption "Anywherelan service.";
  };

  config = mkIf cfg.enable {
    systemd.services.awl = {
      description = "Anywherelan server";
      after = [ "network-online.target" "nss-lookup.target" ];
      wants = [ "network-online.target" "nss-lookup.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ inetutils openresolv ];
      environment = {
        AWL_DATA_DIR = "/etc/anywherelan";
      };
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/etc/anywherelan/";
        ExecStart = "${pkgs.nur.repos.dukzcry.awl}/bin/awl";
        Restart = "always";
        RestartSec = "5s";
        LimitNOFILE = 4000;
      };
    };
  };
}
