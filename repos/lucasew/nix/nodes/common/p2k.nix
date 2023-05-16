{ self, pkgs, config, ... }:

{
  users = {
    users.pocket2kindle = {
      isSystemUser = true;
      group = "pocket2kindle";
    };
    groups.pocket2kindle = {};
  };

  sops.secrets.pocket2kindle = {
    sopsFile = ../../secrets/p2k.env;
    owner = config.users.users.pocket2kindle.name;
    group = config.users.users.pocket2kindle.group;
    format = "dotenv";
  };

  systemd.services.pocket2kindle = {
    description = "Transforma uma quantidade de artigos para enviar para um kindle";
    path = with pkgs; [ dotenv p2k calibre ];
    stopIfChanged = true;
    serviceConfig = {
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
      dotenv @/run/secrets/pocket2kindle -- p2k -a -c 10 -t 30 -k $(cat /run/secrets/pocket2kindle | grep KINDLE_EMAIL | sed 's;KINDLE_EMAIL=;;')
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
}
