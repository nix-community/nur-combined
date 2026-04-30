{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.hermes-dashboard;
in
{
  options.services.hermes-dashboard = {
    enable = lib.mkEnableOption "Hermes Agent dashboard web UI";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "The hermes-agent package providing the dashboard command.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address to bind the dashboard to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 9119;
      description = "Port for the dashboard.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/hermes";
      description = "State directory (HERMES_HOME).";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hermes-dashboard = {
      description = "Hermes Agent dashboard";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "hermes-agent.service"
      ];
      wants = [ "hermes-agent.service" ];

      environment = {
        HOME = cfg.stateDir;
        HERMES_HOME = "${cfg.stateDir}/.hermes";
      };

      serviceConfig = {
        User = config.services.hermes-agent.user or "hermes";
        Group = config.services.hermes-agent.group or "hermes";
        Restart = "always";
        RestartSec = "5s";
      };

      script = ''
        exec ${cfg.package}/bin/hermes dashboard \
          --host ${cfg.host} \
          --port ${toString cfg.port} \
          --no-open
      '';
    };
  };
}
