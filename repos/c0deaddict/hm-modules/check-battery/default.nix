{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.check-battery;

  # TODO: wrap this, put script in another file.
  script = threshold: pkgs.writeScriptBin "check-battery" ''
    #!${pkgs.bash}/bin/bash

    BATTINFO=$(${pkgs.acpi}/bin/acpi -b)
    if [[ $(echo $BATTINFO | ${pkgs.gnugrep}/bin/grep Discharging) && $(echo $BATTINFO | ${pkgs.coreutils}/bin/cut -f 5 -d " ") < ${threshold} ]] ; then
        DISPLAY=:0.0 ${pkgs.libnotify}/bin/notify-send -u critical "Low battery" "$BATTINFO"
    fi
  '';

in

{

  options.services.check-battery = {
    enable = mkEnableOption "Warn when battery is almost empty";

    interval = mkOption {
      default = "60";
      type = types.str;
      description = ''
        Interval in seconds at which battery level is checked.
      '';
    };

    threshold = mkOption {
      default = "00:45:00";
      type = types.str;
      description = ''
        Must be formatted as 00:00:00
        This is string compared to the level shown by `acpi -b`.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.check-battery = {
      Unit = {
        Description = "Check battery level";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${script cfg.threshold}/bin/check-battery";
        IOSchedulingClass = "idle";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    systemd.user.timers.check-battery = {
      Unit = {
        Description = "Check battery level";
      };

      Timer = {
        OnActiveSec = cfg.interval;
        OnUnitActiveSec = cfg.interval;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };

}
