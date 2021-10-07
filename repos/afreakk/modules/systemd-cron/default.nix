{ lib, pkgs, config, ... }:
let
  cfg = config.services.systemd-cron;
  toService = {unitName, ExecStart, Description}: {
    Unit = {
      Description = Description;
      Wants = "${unitName}.timer";
    };
    Service = {
      Type="oneshot";
      ExecStart=ExecStart;
    };
    Install = {
      WantedBy = [ "multi-user.target" ];
    };
  };
  toTimer = {unitName, OnCalendar, Description}: {
    Unit = {
      Description = "${Description} timer";
      #https://superuser.com/a/1559534 we dont want it run on bootup, only on  timer
      #Requires = "${unitName}.service";
    };
    Timer = {
      Unit="${unitName}.service";
      OnCalendar=OnCalendar;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
  toTimerAndService = unitName: {ExecStart, Description, OnCalendar}: {
    services.${unitName} = (toService {inherit unitName ExecStart Description;});
    timers.${unitName} = (toTimer {inherit unitName OnCalendar Description;});
  };
  timerAndServices = lib.mapAttrsToList toTimerAndService cfg.crons;
in {
  options.services.systemd-cron = {
    crons = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      example = ''
      {
        myCronJob = {ExecStart="%h/bin/somescript.sh"; Description="whatever"; OnCalendar="Tue *-*-* 03:00:00";};
      }
      '';
      description = ''
        Simplify creating cron-like systemd service + timer pairs.
      '';
    };
  };

  config = lib.mkIf (builtins.length timerAndServices > 0) {
    systemd.user = (lib.mkMerge timerAndServices);
  };
}
