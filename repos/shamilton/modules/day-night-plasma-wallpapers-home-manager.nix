{ day-night-plasma-wallpapers }:
{ config, lib, pkgs, options,
home, modulesPath, ... }:
with lib;
let
  cfg = config.services.day-night-plasma-wallpapers;
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
      home.file.".config/autostart-scripts/update-day-night-plasma-wallpapers".source 
      = "${day-night-plasma-wallpapers}/.config/autostart-scripts/update-day-night-plasma-wallpapers";

      # Writing JSON configuration file.
      home.file.".config/day-night-plasma-wallpapers.conf".text = builtins.toJSON cfg;

      systemd.user.services.day-night-plasma-wallpapers = {
        Unit = {
          Description = "Day-night-plasma-wallpapers: a software to update your wallpaper according to the day light";
          Requires = [ "graphical-session.target" ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.coreutils}/bin/env PATH=\"${pkgs.coreutils}/bin:${pkgs.qt5.qttools.bin}/bin\" ${day-night-plasma-wallpapers}/bin/update-day-night-plasma-wallpapers";
        };
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
}
