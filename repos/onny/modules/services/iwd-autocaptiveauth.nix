{ config, lib, pkgs, ... }:

with lib;
let

  cfg = config.services.iwd-autocaptiveauth;

in
{
  options = {
    services.iwd-autocaptiveauth = {
      enable = mkEnableOption "iwd auto authenticate to captive portals";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."iwd-autocaptiveauth" = {
      description = "iwd auto authenticate to captive portals";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''${pkgs.iwd}/bin/iwd-autocaptiveauth'';
        Restart = "on-failure";
        User = "iwdautocaptiveauth";
        RestartIntervalSec = 30;
        WorkingDirectory = ''${pkgs.iwd}/'';
      };
      restartIfChanged = true;
    };
  };
}

