{ config, lib, ... }:
let
  cfg = config.services.go-hass-agent;

  inherit (lib) mkEnableOption;
in
{
  options.services.go-hass-agent = {
    enable = mkEnableOption "run go-hass-agent as headless service";
  };

  config = mkIf cfg.enable {
    users.users.go-hass-agent = {
      isSystemUser = true;
      group = "go-hass-agent";
    };
    systemd.services.go-hass-agent = {
      wantedBy = [ "default.target" ];

      unitConfig = {
        Wants = [ "network-online.target" ];
        After = [ "network.online.target" ];
      };

      serviceConfig = {
        Type = "simple";

        User = "gohassagent";
        Group = "gohassagent";

        ExecStart = "${lib.getExe config.nur.repos.sebrut.go-hass-agent} --terminal run";
      };
    };
  };
}
