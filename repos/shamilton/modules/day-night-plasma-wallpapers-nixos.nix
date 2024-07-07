{ day-night-plasma-wallpapers }:
{ config, lib, pkgs, options,
  modulesPath, ...
}:

with lib;

let
  cfg = config.services.day-night-plasma-wallpapers;
in {

  options.services.day-night-plasma-wallpapers = {
    enable = mkEnableOption "Day-Night Plasma Wallpapers, a software to update your wallpaper according to the day light";

    package = mkOption {
      type = types.package;
      default = day-night-plasma-wallpapers;
      defaultText = "shamilton.day-night-plasma-wallpapers";
      description = "Day-night-plasma-wallpapers derivation to use.";
    };

    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* 16:00:00"; # Run at 4 pm everyday (16h)
      description = "When in the evening do you want your wallpaper to go to bed. Default is at 4 pm. See systemd.time(7) for more information about the format.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.day-night-plasma-wallpapers = {
      description = "Day-night-plasma-wallpapers: a software to update your wallpaper according to the day light";
      path = [ pkgs.qt5.qttools.bin cfg.package ];
      script = ''${cfg.package}/bin/update-day-night-plasma-wallpapers.sh'';
    };
    systemd.user.timers.day-night-plasma-wallpapers = {
      description = "Day-night-plasma-wallpapers timer updating the wallpapers according to sun light";
      partOf = [ "day-night-plasma-wallpapers.service" ];
      wantedBy = [ "timers.target" ];

      timerConfig.OnCalendar = cfg.onCalendar;
      # start immediately after computer is started:
      # timerConfig.Persistent = "true";
    };
  };
}
