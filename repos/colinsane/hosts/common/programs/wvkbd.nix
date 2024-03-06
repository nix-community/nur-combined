{ config, ... }:
let
  cfg = config.sane.programs.wvkbd;
in
{
  sane.programs.wvkbd = {
    sandbox.method = "bwrap";
    sandbox.whitelistWayland = true;

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

      # wvkbd layers:
      # - full
      # - landscape
      # - special  (e.g. coding symbols like ~)
      # - emoji
      # - nav
      # - simple  (like landscape, but no parens/tab/etc; even fewer chars)
      # - simplegrid  (simple, but grid layout)
      # - dialer  (digits)
      # - cyrillic
      # - arabic
      # - persian
      # - greek
      # - georgian
      environment.WVKBD_LANDSCAPE_LAYERS = "landscape,special,emoji";
      environment.WVKBD_LAYERS = "full,special,emoji";
    };
  };
}
