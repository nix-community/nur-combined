{ lib, pkgs, config, ... }:
let
  cfg = config.services.joystickwake;
in
{
  options.services.joystickwake = {
    enable = lib.mkEnableOption "joystickwake";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.joystickwake = {
      Unit = {
        Description = "joystickwake";
        Requires = "graphical-session.target";
        After = "graphical-session.target";
      };
      Service = {
        Environment = "PATH=${lib.makeBinPath [pkgs.xorg.xset pkgs.xscreensaver]}";
        ExecStart = "${pkgs.joystickwake}/bin/joystickwake";
        RestartSec = "10";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
