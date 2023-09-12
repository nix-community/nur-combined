{ config, lib, ... }:
{
  sane.programs.playerctl.services.playerctld = {
    description = "playerctl daemon to keep track of which MPRIS players were recently active";
    documentation = [ "https://github.com/altdesktop/playerctl/issues/161" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${config.sane.programs.playerctl.package}/bin/playerctld";
    # serviceConfig.Type = "dbus";
    # serviceConfig.BusName = "org.mpris.MediaPlayer2.Player";
    serviceConfig.Type = "simple";  # playerctl also supports a --daemon option, idk if that's better
    serviceConfig.Restart = "on-failure";
    serviceConfig.RestartSec = "10s";
  };
}
