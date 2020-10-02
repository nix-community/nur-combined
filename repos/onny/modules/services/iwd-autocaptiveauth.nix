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

    users.users."iwd-autocaptiveauth" = {
      description = "iwd-autocaptiveauth daemon user";
      group = "wheel";
    };

    systemd.services."iwd-autocaptiveauth" = {
      description = "iwd auto authenticate to captive portals";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        PYTHONUNBUFFERED = "1";
      };
      serviceConfig = {
        ExecStart = "${pkgs.nur-onny.iwd-autocaptiveauth}/bin/iwd-autocaptiveauth --profileDir ${pkgs.nur-onny.iwd-autocaptiveauth}/profiles";
        Restart = "on-failure";
        User = "iwd-autocaptiveauth";
        RestartSec = 30;
        WorkingDirectory = ''${pkgs.nur-onny.iwd-autocaptiveauth}/'';
      };
      restartIfChanged = true;
    };
  };

}

