{
  self,
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
in

{
  options = {
    services.pocket2kindle.enable = mkEnableOption "pocket2kindle";
  };

  config = mkIf config.services.pocket2kindle.enable {
    users = {
      users.pocket2kindle = {
        isSystemUser = true;
        group = "pocket2kindle";
      };
      groups.pocket2kindle = { };
    };

    sops.secrets.pocket2kindle = {
      sopsFile = ../../../secrets/p2k.env;
      format = "dotenv";
    };

    systemd.services.pocket2kindle = {
      description = "Transforma uma quantidade de artigos para enviar para um kindle";
      path = with pkgs; [
        p2k
        calibre
      ];
      stopIfChanged = true;
      serviceConfig = {
        EnvironmentFile = "/run/secrets/pocket2kindle";
        # https://gist.github.com/ageis/f5595e59b1cddb1513d1b425a323db04
        User = config.users.users.pocket2kindle.name;
        Group = config.users.users.pocket2kindle.group;
        DevicePolicy = "closed";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectSystem = "strict";
      };

      script = ''
        cd /tmp
        p2k -a -c 10 -t 30 -k $KINDLE_EMAIL
      '';
    };

    # any user can start the unit
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" && action.lookup("unit") == "pocket2kindle.service") {
          return polkit.Result.YES;
        }
      })
    '';
  };
}
