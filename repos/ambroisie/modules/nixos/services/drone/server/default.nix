{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.drone;
in
{
  config = lib.mkIf cfg.enable {
    systemd.services.drone-server = {
      wantedBy = [ "multi-user.target" ];
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      serviceConfig = {
        EnvironmentFile = [
          cfg.secretFile
          cfg.sharedSecretFile
        ];
        Environment = [
          "DRONE_DATABASE_DATASOURCE=postgres:///drone?host=/run/postgresql"
          "DRONE_SERVER_HOST=drone.${config.networking.domain}"
          "DRONE_SERVER_PROTO=https"
          "DRONE_DATABASE_DRIVER=postgres"
          "DRONE_SERVER_PORT=:${toString cfg.port}"
          "DRONE_USER_CREATE=username:${cfg.admin},admin:true"
          "DRONE_JSONNET_ENABLED=true"
          "DRONE_STARLARK_ENABLED=true"
        ];
        ExecStart = "${pkgs.drone}/bin/drone-server";
        User = "drone";
        Group = "drone";
      };
    };

    users.users.drone = {
      isSystemUser = true;
      createHome = true;
      group = "drone";
    };
    users.groups.drone = { };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "drone" ];
      ensureUsers = [{
        name = "drone";
        ensureDBOwnership = true;
      }];
    };

    my.services.nginx.virtualHosts = {
      drone = {
        inherit (cfg) port;
      };
    };
  };
}
