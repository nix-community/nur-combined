{ config, ... }:
{
  sane.programs.playerctl = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";
    sandbox.whitelistDbus = [ "user" ];  # notifications

    services.playerctld = {
      description = "playerctl daemon to keep track of which MPRIS players were recently active";
      documentation = [ "https://github.com/altdesktop/playerctl/issues/161" ];
      wantedBy = [ "default.target" ];  #< TODO: maybe better to zero `wantedBy` here and have the specific consumers (e.g. swaync) explicitly depend on this.
      serviceConfig.ExecStart = "${config.sane.programs.playerctl.package}/bin/playerctld";
      # serviceConfig.Type = "dbus";
      # serviceConfig.BusName = "org.mpris.MediaPlayer2.Player";
      serviceConfig.Type = "simple";  # playerctl also supports a --daemon option, idk if that's better
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = "10s";
    };
  };
}
