{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.security.polkit.agent;
in

{
  options = {
    security.polkit.agent = {
      enable = lib.mkEnableOption "polkit agent";
      agent = lib.mkOption {
        type = lib.types.path;
        description = "Where the polkit agent is located";
        default = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # from: https://nixos.wiki/wiki/Polkit
    systemd.user.services.polkit-agent = {
      description = "Polkit Agent";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = cfg.agent;
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
