{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.report;
in
{
  options.services.report = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    calendars = mkOption {
      type = types.listOf types.str;
      default = [ "*-*-* 12:00:00" ];
    };
  };

  config = mkIf cfg.enable {
    systemd.timers.report-kernel-log = {
      description = "report kernel log through ntfy";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.calendars;
      };
    };
    systemd.services.report-kernel-log = {
      wantedBy = [ "timer.target" ];
      description = "report kernel log through ntfy";
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = toString (
          pkgs.lib.getExe (
            pkgs.nuenv.writeScriptBin {
              name = "post-ntfy-msg";
              script = ''
                let log = journalctl -k --since "yesterday" --priority=0..3
                cat /run/agenix/ntfy-token | str trim | http post --password $in --headers [tags green_circle] https://ntfy.nyaw.xyz/eihort $log
              '';
            }
          )
        );
        Restart = "on-failure";
      };
    };
  };
}
