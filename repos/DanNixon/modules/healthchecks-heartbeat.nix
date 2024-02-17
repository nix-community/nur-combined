{
  config,
  pkgs,
  lib,
  ...
}: {
  options.services.healthchecksHeartbeat = with lib; {
    enable = mkOption {
      description = "Enable sending regular heartbeats to healthchecks.io";
      type = types.bool;
      default = false;
    };

    interval = mkOption {
      description = "Interval at which to send heartbeats (see `man 5 systemd.timer`";
      type = types.str;
      default = "*:0/5";
    };

    uuidFile = mkOption {
      description = "File containing UUID of the check to send heartbeats to";
      type = types.path;
    };

    url = mkOption {
      description = "URL of the healthchecks.io instance";
      type = types.str;
      default = "https://hc-ping.com";
    };
  };

  config.systemd = let
    conf = config.services.healthchecksHeartbeat;
  in {
    timers.healthchecks-heartbeat = {
      description = "Send regular heartbeats to healthchecks.io";
      enable = conf.enable;

      timerConfig = {
        OnCalendar = conf.interval;
        Persistent = true;
      };

      wantedBy = ["multi-user.target"];
    };

    services.healthchecks-heartbeat = {
      description = "Send heartbeat to healthchecks.io";
      enable = conf.enable;

      serviceConfig = {
        Type = "oneshot";
      };

      script = let
        url = conf.url;
        uuidFile = conf.uuidFile;
      in ''
        ${pkgs.curl}/bin/curl -m 10 --retry 5 "${url}/$(cat ${uuidFile})"
      '';
    };
  };
}
