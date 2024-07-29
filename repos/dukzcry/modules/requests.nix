{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.requests;
in {
  options.services.requests = {
    enable = mkEnableOption "requests manager";
  };

  config = mkIf cfg.enable {
    services.jellyseerr.enable = true;
    services.sonarr.enable = true;
    services.sonarr.group = config.services.transmission.group;
    services.radarr.enable = true;
    services.radarr.group = config.services.transmission.group;
    services.jackett.enable = true;
    # todo: replace with services.flaresolver option
    systemd.services.flaresolverr = {
      after = [ "network.target" ];
      serviceConfig = {
        User = config.services.jackett.user;
        Group = config.services.jackett.group;
        Restart = "always";
        RestartSec = 5;
        TimeoutStopSec = 30;
        ExecStart = "${pkgs.nur.repos.xddxdd.flaresolverr}/bin/flaresolverr";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
