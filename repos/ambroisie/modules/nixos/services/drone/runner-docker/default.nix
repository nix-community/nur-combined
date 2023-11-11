{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.drone;
  hasRunner = (name: builtins.elem name cfg.runners);
in
{
  config = lib.mkIf (cfg.enable && hasRunner "docker") {
    systemd.services.drone-runner-docker = {
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.socket" ]; # Needs the socket to be available
      # might break deployment
      restartIfChanged = false;
      confinement.enable = true;
      serviceConfig = {
        Environment = [
          "DRONE_SERVER_HOST=drone.${config.networking.domain}"
          "DRONE_SERVER_PROTO=https"
          "DRONE_RUNNER_CAPACITY=10"
          "CLIENT_DRONE_RPC_HOST=127.0.0.1:${toString cfg.port}"
        ];
        BindPaths = [
          "/var/run/docker.sock"
        ];
        EnvironmentFile = [
          cfg.sharedSecretFile
        ];
        ExecStart = lib.getExe pkgs.drone-runner-docker;
        User = "drone-runner-docker";
        Group = "drone-runner-docker";
      };
    };

    # Make sure it is activated in that case
    my.system.docker.enable = true;

    users.users.drone-runner-docker = {
      isSystemUser = true;
      group = "drone-runner-docker";
      extraGroups = [ "docker" ]; # Give access to the daemon
    };
    users.groups.drone-runner-docker = { };
  };
}
