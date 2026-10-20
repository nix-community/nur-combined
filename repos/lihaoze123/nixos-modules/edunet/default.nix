{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.services.edunet;
in
{
  options.services.edunet = import ./options.nix {
    inherit lib;
    defaultPackage = (import ../../default.nix { inherit pkgs; }).edunet;
    defaultEnvironmentFile = "/var/lib/edunet/check.env";
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          lib.hasPrefix "/" cfg.environmentFile && !(lib.hasPrefix "/nix/store/" cfg.environmentFile);
        message = "services.edunet.environmentFile must be an external absolute path outside the Nix store.";
      }
    ];
    environment.systemPackages = [ cfg.package ];
    systemd.services.edunet-check = {
      description = "Check campus connectivity and log in when offline";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} --no-color --timeout ${toString cfg.timeout} login --no-input --require-portal";
        EnvironmentFile = cfg.environmentFile;
        TimeoutStartSec = cfg.serviceTimeout;
        StandardOutput = "journal";
        StandardError = "journal";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
      };
      environment.PYTHONUNBUFFERED = "1";
    };
    systemd.timers.edunet-check = {
      description = "Periodically reconnect the campus network";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnStartupSec = cfg.startupDelay;
        OnUnitActiveSec = cfg.interval;
        RandomizedDelaySec = cfg.randomizedDelay;
        AccuracySec = "1s";
        Unit = "edunet-check.service";
      };
    };
  };
}
