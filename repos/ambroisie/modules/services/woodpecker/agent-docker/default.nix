{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.woodpecker;

  hasRunner = (name: builtins.elem name cfg.runners);
in
{
  config = lib.mkIf (cfg.enable && hasRunner "docker") {
    services.woodpecker-agents = {
      agents.docker = {
        enable = true;

        package = pkgs.ambroisie.woodpecker-agent;

        environment = {
          WOODPECKER_SERVER = "localhost:${toString cfg.rpcPort}";
          WOODPECKER_MAX_WORKFLOWS = "10";
          WOODPECKER_BACKEND = "docker";
          WOODPECKER_FILTER_LABELS = "type=docker";
          WOODPECKER_HEALTHCHECK = "false";
        };

        environmentFile = [ cfg.sharedSecretFile ];

        extraGroups = [ "docker" ];
      };
    };

    # Make sure it is activated in that case
    virtualisation.docker.enable = true;

    # FIXME: figure out the issue
    services.unbound.resolveLocalQueries = false;

    # Adjust runner service for nix usage
    systemd.services.woodpecker-agent-docker = {
      after = [ "docker.socket" ]; # Needs the socket to be available
      # might break deployment
      restartIfChanged = false;
      serviceConfig = {
        BindPaths = [
          "/var/run/docker.sock"
        ];
      };
    };
  };
}
