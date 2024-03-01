{ config, ... }:
let
  cfg = config.sane.programs.wvkbd;
in
{
  sane.programs.wvkbd = {
    services.wvkbd = {
      description = "wvkbd: wayland virtual keyboard";
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        # --hidden: send SIGUSR2 to unhide
        ExecStart = "${cfg.package}/bin/wvkbd-mobintl --hidden";
        Type = "simple";
        Restart = "always";
        RestartSec = "3s";
      };
    };
  };
}
