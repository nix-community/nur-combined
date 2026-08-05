{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.debspawn;
in
{
  options.services.debspawn = {
    enable = lib.mkEnableOption "debspawn";
  };
  config = lib.mkIf cfg.enable {
    systemd.services.debspawn-clear-caches = {
      description = "Clear debspawn caches";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe cfg.package} maintain --clear-caches";

        PrivateTmp = true;
        PrivateDevices = true;
        PrivateNetwork = true;
      };
    };
    systemd.timers.debspawn-clear-caches = {
      description = "Clear debspawn caches";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "monthly";
        RandomizedDelaySec = "12h";
        AccuracySec = "20min";
        Persistent = true;
      };
    };
  };
}
