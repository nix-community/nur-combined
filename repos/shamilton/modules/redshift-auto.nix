{ config, lib, pkgs, options,
home, modulesPath, specialArgs
}:

with lib;

let
  cfg = config.services.redshift-auto;
in {

  options.services.redshift-auto = {
    enable = mkEnableOption "Redshift service that automatically triggers when your eyes are tired of the blue light.";

    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* 16:00:00"; # Run at 4 pm everyday (16h)
      description = "When in the evening do you want your screen to be more respectful of you eyes ? Default is at 4 pm. See systemd.time(7) for more information about the format.";
    };

    lightColour = mkOption {
      type = types.str;
      default = "5000";
      description = "How many kelvins do you want when working the day ? The lower, the more red.";
    };

    nightColour = mkOption {
      type = types.str;
      default = "3000";
      description = "How many kelvins do you want when working late ? The lower, the more red thus the better it is for your eyes.";
    };
  };
  config = mkIf cfg.enable (mkMerge ([
    {
      home.file.".config/autostart-scripts/redshift-auto.py" = 
      {
        text = ''
          #! /usr/bin/env python3

          import time
          import os
          from subprocess import call

          home = os.environ["HOME"]
          configThreshold = "${cfg.onCalendar}"
          thresholdTime = configThreshold.split(' ')[1]
          dayTime = time.strftime("%d-%m-%y", time.localtime(time.time()))
          thresholdDate = time.strptime(dayTime+' '+thresholdTime, "%d-%m-%y %H:%M:%S")
          if thresholdDate>time.localtime(time.time()):
            call(["redshift", "-P", "-O", "${cfg.lightColour}"])
          else:
            call(["redshift", "-P", "-O", "${cfg.nightColour}"])
        '';
        executable = true;
      };

      systemd.user.services.redshift-auto = {
        Unit = {
          Description = "Redshift service that automatically triggers when your eyes are tired of the blue light.";
          Requires = [ "graphical-session.target" ];
        };

        Service = {
          Type = "oneshot";
          # Environment = [ "\"PATH=${pkgs.coreutils}/bin\"" ];
          ExecStart = "${pkgs.redshift}/bin/redshift -P -O "+cfg.nightColour;
        };
      };
    }
    (mkIf (cfg.onCalendar != null) {
      systemd.user.timers.redshift-auto = {
        Unit = { 
          Description = "Redshift service that automatically triggers when your eyes are tired of the blue light.";
          partOf = [ "redshift-auto.service" ];
        };

        Timer = { OnCalendar = cfg.onCalendar; };

        Install = { WantedBy = [ "timers.target" ]; };
      };
    })
  ]));
}
