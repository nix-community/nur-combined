{ pkgs
, config
, lib
, ...
}:
with lib;
let
  cfg = config.services.sundial;
in
{
  options.services.sundial = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    powersave-calendars = mkOption {
      type = types.listOf types.str;
      default = [ "Sun..Thu 23:18:00" "Fri,Sat 23:48:00" ];
    };

    performance-calendars = mkOption {
      type = types.listOf types.str;
      default = [ "Sun..Thu 06:00:00" "Fri,Sat 06:00:00" ];
    };
  };

  config =
    mkIf cfg.enable
      (
        let
          genMode = x: with builtins;
            listToAttrs (map
              x [ "performance" "powersave" ]);

        in
        {
          systemd.timers = genMode (mode: {
            name = "sundial-${mode}";
            value = {
              description = "intime switch power mode";
              wantedBy = [ "timers.target" ];
              timerConfig = {
                OnCalendar = cfg."${mode}-calendars";
              };
            };
          });
          systemd.services = genMode (mode: {
            name = "sundial-${mode}";
            value = {
              wantedBy = [ "timer.target" ];
              description = "turn power mode to ${mode}";
              serviceConfig = {
                Type = "simple";
                User = "root";
                ExecStart = "${lib.getExe' pkgs.linuxKernel.packages.linux_latest_libre.cpupower "cpupower"} frequency-set -g ${mode}";
                Restart = "on-failure";
              };
            };
          });
        }
      );
}
