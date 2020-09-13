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
      serviceConfig = {
        ExecStart = let
            python = pkgs.python3.withPackages (ps: with ps; [ pygobject3 dbus-python ]);
          in
            ''${python.interpreter} ${pkgs.nur-onny.iwd-autocaptiveauth}/iwd-autocaptiveauth.py'';
        Restart = "on-failure";
        User = "iwd-autocaptiveauth";
        RestartSec = 30;
        WorkingDirectory = ''${pkgs.nur-onny.iwd-autocaptiveauth}/'';
      };
      restartIfChanged = true;
    };
  };

}

