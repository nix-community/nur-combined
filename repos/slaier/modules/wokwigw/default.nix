{ lib, pkgs, ... }:
{
  systemd.services.wokwigw = {
    description = "Wokwi IoT Gateway";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.wokwigw} --listenPort 9081";
      Restart = "always";
      RestartSec = "10";
      Type = "simple";
      User = "wokwigw";
      Group = "wokwigw";
    };
  };

  users.users.wokwigw = {
    isSystemUser = true;
    group = "wokwigw";
    description = "Wokwi IoT Gateway service user";
  };

  users.groups.wokwigw = { };
}
