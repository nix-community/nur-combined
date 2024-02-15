{ config, ... }:
let
  cfg = config.sane.programs.waybar;
in
{
  sane.programs.waybar = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.net = "all";  #< to show net connection status and BW
    sandbox.whitelistDbus = [ "user" ];
    sandbox.whitelistWayland = true;
    sandbox.extraRuntimePaths = [ "/" ];  #< needs to talk to sway IPC. TODO: give the sway IPC a predictable name.
    sandbox.extraHomePaths = [ ".config/waybar" ];  #< TODO: migrate config files to this file and then safe to remove

    services.waybar = {
      description = "sway header bar";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig.ExecStart = "${cfg.package}/bin/waybar";
      serviceConfig.Type = "simple";
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = "10s";
      # environment.G_MESSAGES_DEBUG = "all";
    };
  };
}
