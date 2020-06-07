{ config, lib, pkgs, shamilton, options,
home, modulesPath
}:

with lib;

let
  cfg = config.services.day-night-plasma-wallpapers;
  package-day-night-plasma-wallpapers = pkgs.callPackage ./../pkgs/day-night-plasma-wallpapers { 
    qttools = pkgs.qt5.qttools;  
  };
in {

  options.services.day-night-plasma-wallpapers = {
    enable = mkEnableOption "Day-Night Plasma Wallpapers, a software to update your wallpaper according to the day light";

    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* 16:00:00"; # Run at 4 pm everyday (16h)
      description = "When in the evening do you want your wallpaper to go to bed. Default is at 4 pm. See systemd.time(7) for more information about the format.";
    };

    sleepDuration = mkOption {
      type = types.int;
      default = 10; # Wait 10 seconds before running
      description = "Delay hack to make the autostart-script run successfully.";
    };
  };
  config = mkIf cfg.enable (mkMerge ([
    {
      home.file.".config/autostart-scripts/update-day-night-plasma-wallpapers.sh".source 
      = "${package-day-night-plasma-wallpapers}/.config/autostart-scripts/update-day-night-plasma-wallpapers.sh";

      # Writing JSON configuration file.
      home.file.".config/day-night-plasma-wallpapers.conf".text = builtins.toJSON cfg;

      systemd.user.services.day-night-plasma-wallpapers = {
        Unit = {
          Description = "Day-night-plasma-wallpapers: a software to update your wallpaper according to the day light";
          Requires = [ "graphical-session.target" ];
           
        };

        Service = {
          Type = "oneshot";
          # Environment = [ "\"PATH=${pkgs.coreutils}/bin\"" ];
          ExecStart = "${pkgs.coreutils}/bin/env PATH=\"${pkgs.coreutils}/bin:${pkgs.qt5.qttools.bin}/bin\" ${package-day-night-plasma-wallpapers}/bin/update-day-night-plasma-wallpapers.sh";
        };

        # Install = { WantedBy = s "timers.target" ]; };
      };
    }
    (mkIf (cfg.onCalendar != null) {
      systemd.user.timers.day-night-plasma-wallpapers = {
        Unit = { 
          Description = "Day-night-plasma-wallpapers timer updating the wallpapers according to sun light";
          partOf = [ "day-night-plasma-wallpapers.service" ];
        };

        Timer = { OnCalendar = cfg.onCalendar; };

        Install = { WantedBy = [ "timers.target" ]; };
      };
    })
  ]));


  # config = {
  #   systemd.user.services.day-night-plasma-wallpapers = {
  #     description = "Day-night-plasma-wallpapers: a software to update your wallpaper according to the day light";
  #     path = [ pkgs.qt5.qttools.bin cfg.package ];
  #     script = ''${cfg.package}/bin/update-day-night-plasma-wallpapers.sh'';
  #   };
  #   systemd.user.timers.day-night-plasma-wallpapers = {
  #     description = "Day-night-plasma-wallpapers timer updating the wallpapers according to sun light";
  #     wantedBy = [ "timers.target" ];

  #     timerConfig.OnCalendar = cfg.onCalendar;
  #     # start immediately after computer is started:
  #     # timerConfig.Persistent = "true";
  #   };
  # };
}
